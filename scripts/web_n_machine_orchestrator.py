#!/usr/bin/env python3
"""
Run N Flutter web (Chrome) dev sessions with `fvm flutter run --machine`.

Each instance uses unique `--web-port` so browser storage isolated.
Accepts interactive reload/restart/stop commands on stdin.

Protocol: https://github.com/flutter/flutter/blob/master/packages/flutter_tools/doc/daemon.md
"""

from __future__ import annotations

import json
import os
import re
import shutil
import signal
import socket
import subprocess
import sys
import threading
import time
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Optional

_scripts_dir = str(Path(__file__).resolve().parent)
if _scripts_dir not in sys.path:
    sys.path.insert(0, _scripts_dir)
from load_repo_dotenv import merge_repo_dotenv  # noqa: E402


def _env_int(name: str, default: int) -> int:
    raw = os.environ.get(name)
    if raw is None or raw == "":
        return default
    try:
        return int(raw)
    except ValueError as e:
        raise SystemExit(f"error: {name} must be an integer, got {raw!r}") from e


def _tcp_listen_port_in_use(port: int) -> bool:
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        s.bind(("127.0.0.1", port))
        return False
    except OSError:
        return True
    finally:
        s.close()


def _allocate_ports_fixed(n: int, base: int) -> list[int]:
    ports: list[int] = []
    for i in range(n):
        p = base + i
        if _tcp_listen_port_in_use(p):
            print(
                f"error: required port {p} already in use (BASE_WEB_PORT={base}).",
                file=sys.stderr,
            )
            raise SystemExit(1)
        ports.append(p)
    return ports


def _allocate_ports_auto(n: int, start: int, max_offsets: int) -> list[int]:
    for offset in range(max_offsets):
        base = start + offset
        ok = True
        for i in range(n):
            if _tcp_listen_port_in_use(base + i):
                ok = False
                break
        if ok:
            return [base + i for i in range(n)]
    print(
        f"error: could not find {n} consecutive free TCP ports after {max_offsets} "
        f"tries from {start}.",
        file=sys.stderr,
    )
    raise SystemExit(1)


def _chrome_listed(devices_out: str) -> bool:
    return re.search(r"•\s*chrome\s*•", devices_out, re.IGNORECASE) is not None


def _fuser_kill_ports(ports: list[int], sig: str) -> None:
    fuser = shutil.which("fuser")
    if not fuser:
        return
    for p in ports:
        subprocess.run(
            [fuser, "-k", sig, f"{p}/tcp"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )


def _resolve_api_url() -> str:
    url = (os.environ.get("M3T_API_URL") or "").strip()
    if url:
        return url
    port = _env_int("M3T_API_PORT", 8080)
    return f"http://127.0.0.1:{port}"


def _resolve_object_store_url() -> str:
    url = (os.environ.get("OBJECT_STORE_URL") or "").strip()
    if url:
        return url
    port = _env_int("M3T_OBJECT_STORE_PORT", 9000)
    return f"http://127.0.0.1:{port}"


@dataclass
class Instance:
    index: int
    port: int
    proc: subprocess.Popen[str]
    app_id: Optional[str] = None
    lock: threading.Lock = field(default_factory=threading.Lock)

    def prefix(self) -> str:
        return f"[{self.index + 1}]"


def _read_flutter_stdout(inst: Instance, on_event: Any) -> None:
    assert inst.proc.stdout is not None
    for raw in inst.proc.stdout:
        line = raw.rstrip("\n")
        if not line.strip():
            print(f"{inst.prefix()} ")
            continue
        if line.lstrip().startswith("["):
            try:
                msgs: list[dict[str, Any]] = json.loads(line)
            except json.JSONDecodeError:
                print(f"{inst.prefix()} {line}")
                continue
            for msg in msgs:
                if "event" in msg:
                    on_event(inst, msg)
                elif "id" in msg and ("result" in msg or "error" in msg):
                    err = msg.get("error")
                    if err is not None:
                        print(f"{inst.prefix()} rpc error: {err}", file=sys.stderr)
                else:
                    print(f"{inst.prefix()} {json.dumps(msg)}")
        else:
            print(f"{inst.prefix()} {line}")


class Orchestrator:
    def __init__(self, repo_root: str, ports: list[int], stagger: float) -> None:
        self.repo_root = repo_root
        self.ports = ports
        self.stagger = stagger
        self.instances: list[Instance] = []
        self._rpc_id = 0
        self._rpc_id_lock = threading.Lock()
        self._closing = False

    def _next_id(self) -> int:
        with self._rpc_id_lock:
            self._rpc_id += 1
            return self._rpc_id

    def _send_rpc(self, inst: Instance, method: str, params: dict[str, Any]) -> None:
        if inst.proc.stdin is None:
            print(f"{inst.prefix()} no stdin (process dead?)", file=sys.stderr)
            return
        payload = [{"method": method, "id": self._next_id(), "params": params}]
        line = json.dumps(payload, separators=(",", ":")) + "\n"
        with inst.lock:
            try:
                inst.proc.stdin.write(line)
                inst.proc.stdin.flush()
            except BrokenPipeError:
                print(f"{inst.prefix()} stdin broken", file=sys.stderr)

    def _on_event(self, inst: Instance, msg: dict[str, Any]) -> None:
        ev = msg.get("event")
        params = msg.get("params") or {}
        if ev == "app.start":
            aid = params.get("appId")
            if isinstance(aid, str):
                inst.app_id = aid
                print(
                    f"{inst.prefix()} app.start appId={aid} "
                    f"(http://127.0.0.1:{inst.port})"
                )
        elif ev in ("app.log", "daemon.log"):
            log = params.get("log")
            if isinstance(log, str) and log.strip():
                print(f"{inst.prefix()} {log}".rstrip())
        elif ev == "app.started":
            print(f"{inst.prefix()} app.started (ready for reload/restart)")
        elif ev == "app.stop":
            inst.app_id = None
            print(f"{inst.prefix()} app.stop")

    def start_all(self) -> None:
        api = _resolve_api_url()
        obj = _resolve_object_store_url()
        for i, port in enumerate(self.ports):
            cmd = [
                "fvm",
                "flutter",
                "run",
                "--machine",
                "--web-port",
                str(port),
                "-d",
                "chrome",
                f"--dart-define=M3T_API_URL={api}",
                f"--dart-define=OBJECT_STORE_URL={obj}",
            ]
            print(f">>> {' '.join(cmd)}", flush=True)
            proc = subprocess.Popen(
                cmd,
                cwd=self.repo_root,
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                bufsize=1,
                start_new_session=True,
            )
            inst = Instance(index=i, port=port, proc=proc)
            self.instances.append(inst)
            t = threading.Thread(
                target=_read_flutter_stdout,
                args=(inst, self._on_event),
                name=f"flutter-out-{i + 1}",
                daemon=True,
            )
            t.start()
            if i < len(self.ports) - 1 and self.stagger > 0:
                time.sleep(self.stagger)

    def reload(self, idx0: int, full_restart: bool) -> None:
        inst = self.instances[idx0]
        if not inst.app_id:
            print(f"{inst.prefix()} no appId yet (wait for app.started)", file=sys.stderr)
            return
        self._send_rpc(
            inst,
            "app.restart",
            {"appId": inst.app_id, "fullRestart": full_restart},
        )

    def stop_app(self, idx0: int) -> None:
        inst = self.instances[idx0]
        if not inst.app_id:
            self._kill_instance(inst)
            return
        self._send_rpc(inst, "app.stop", {"appId": inst.app_id})

    def _kill_instance(self, inst: Instance) -> None:
        try:
            if inst.proc.poll() is None and inst.proc.pid:
                os.killpg(inst.proc.pid, signal.SIGTERM)
        except ProcessLookupError:
            pass

    def shutdown(self) -> None:
        if self._closing:
            return
        self._closing = True
        print("\nStopping flutter run sessions...", flush=True)
        for inst in self.instances:
            if inst.app_id:
                self._send_rpc(inst, "app.stop", {"appId": inst.app_id})
        time.sleep(1.5)
        for inst in self.instances:
            self._kill_instance(inst)
            try:
                inst.proc.wait(timeout=3)
            except subprocess.TimeoutExpired:
                try:
                    if inst.proc.pid:
                        os.killpg(inst.proc.pid, signal.SIGKILL)
                except ProcessLookupError:
                    pass
        _fuser_kill_ports(self.ports, "-TERM")
        time.sleep(0.5)
        _fuser_kill_ports(self.ports, "-KILL")


def _print_help() -> None:
    print(
        """
Commands (stdin):
  reload <n>   Hot reload instance n (1..N)
  restart <n>  Hot restart instance n
  reload all   Hot reload every ready instance
  restart all  Hot restart every ready instance
  stop <n>     Stop instance n
  help         This text
  quit         Stop all instances and exit

Aliases: r/reload, rs/restart, q/quit/exit
""".strip()
    )


def _parse_tokens(line: str) -> list[str]:
    return [t for t in re.split(r"\s+", line.strip()) if t]


def _parse_cmd(tokens: list[str]) -> Optional[tuple[str, Optional[str]]]:
    if not tokens:
        return None
    low = [t.lower() for t in tokens]
    if low[0] in ("help", "h", "?"):
        return ("help", None)
    if low[0] in ("quit", "q", "exit"):
        return ("quit", None)

    if len(tokens) == 2:
        a, b = low[0], low[1]
        if a in ("reload", "r") and b.isdigit():
            return ("reload", b)
        if a in ("restart", "rs") and b.isdigit():
            return ("restart", b)
        if a == "stop" and b.isdigit():
            return ("stop", b)
        if b in ("reload", "r") and a.isdigit():
            return ("reload", a)
        if b in ("restart", "rs") and a.isdigit():
            return ("restart", a)
        if b == "stop" and a.isdigit():
            return ("stop", a)
        if a in ("reload", "r") and b == "all":
            return ("reload_all", None)
        if a in ("restart", "rs") and b == "all":
            return ("restart_all", None)
    return None


def main() -> None:
    if len(sys.argv) != 2:
        print("usage: web_n_machine_orchestrator.py <N>", file=sys.stderr)
        raise SystemExit(2)
    try:
        n = int(sys.argv[1])
    except ValueError:
        print("error: N must be a positive integer", file=sys.stderr)
        raise SystemExit(2)
    if n < 1:
        print("error: N must be >= 1", file=sys.stderr)
        raise SystemExit(2)

    repo_root = os.environ.get("REPO_ROOT") or os.getcwd()
    merge_repo_dotenv(repo_root, override=False)
    stagger = float(os.environ.get("START_STAGGER_SECONDS") or "6")
    scan_start = _env_int("WEB_PORT_SCAN_START", 39100)
    max_offsets = _env_int("WEB_PORT_MAX_OFFSETS", 5000)
    base_web = os.environ.get("BASE_WEB_PORT", "").strip()

    r = subprocess.run(
        ["fvm", "flutter", "devices"],
        cwd=repo_root,
        capture_output=True,
        text=True,
        check=False,
    )
    out = (r.stdout or "") + (r.stderr or "")
    if not _chrome_listed(out):
        print(
            "error: Chrome is not in `fvm flutter devices`. "
            "Install Chrome or enable the web target, then retry.",
            file=sys.stderr,
        )
        print("Current device list:", file=sys.stderr)
        print(out, file=sys.stderr)
        raise SystemExit(1)

    if base_web:
        ports = _allocate_ports_fixed(n, int(base_web))
    else:
        ports = _allocate_ports_auto(n, scan_start, max_offsets)

    api = _resolve_api_url()
    obj = _resolve_object_store_url()
    print(f"Starting {n} isolated web instance(s).")
    print(f"Using M3T_API_URL={api!r}")
    print(f"Using OBJECT_STORE_URL={obj!r}")
    print("Open each app at:")
    for i, p in enumerate(ports):
        print(f"  instance {i + 1}: http://127.0.0.1:{p}")
    print()
    print("Machine mode: type commands here (see `help`). Ctrl+C stops all instances.")
    if not shutil.which("fuser"):
        print("Tip: install psmisc (fuser) for more reliable port cleanup.", file=sys.stderr)

    orch = Orchestrator(repo_root, ports, stagger=stagger)
    orch.start_all()

    def handle_sig(_signum: int, _frame: Any) -> None:
        orch.shutdown()
        sys.exit(0)

    signal.signal(signal.SIGINT, handle_sig)
    signal.signal(signal.SIGTERM, handle_sig)

    try:
        for line in sys.stdin:
            tokens = _parse_tokens(line)
            cmd = _parse_cmd(tokens)
            if cmd is None:
                if tokens:
                    print("unknown command; try `help`", file=sys.stderr)
                continue
            action, arg = cmd
            if action == "help":
                _print_help()
                continue
            if action == "quit":
                break
            if action == "reload_all":
                for i in range(n):
                    orch.reload(i, full_restart=False)
                continue
            if action == "restart_all":
                for i in range(n):
                    orch.reload(i, full_restart=True)
                continue
            assert arg is not None
            idx = int(arg) - 1
            if idx < 0 or idx >= n:
                print(f"error: instance must be 1..{n}", file=sys.stderr)
                continue
            if action == "reload":
                orch.reload(idx, full_restart=False)
            elif action == "restart":
                orch.reload(idx, full_restart=True)
            elif action == "stop":
                orch.stop_app(idx)
    finally:
        orch.shutdown()


if __name__ == "__main__":
    main()
