# Verify Flutter Changes

## Overview

Run the full quality-gate sequence for this Flutter app and its packages, then fix every failure before marking work complete. Follow `flutter-quality-gates` and `fvm-terminal` rules.

## Steps

1. **Analyze**
   - From the project root: `fvm dart analyze`
   - Use `ReadLints` on every file you edited.
   - Fix all errors and warnings introduced by your changes.

2. **Format**
   - `fvm dart format lib test packages` (or only changed paths).
   - Re-run analyze if formatting touched logic-adjacent files.

3. **Codegen** (only if `@JsonSerializable` models or `.g.dart` files changed)
   - `cd packages/m3t_api && fvm dart run build_runner build --delete-conflicting-outputs`
   - Commit generated `.g.dart` files with the model changes.

4. **Run tests**
   - App: `fvm flutter test` from the project root.
   - Packages: `fvm dart test` in `packages/domain`, `packages/auth_repository`, and `packages/m3t_api`.
   - Capture output and list every failing test (file and test name).

5. **Analyze failures**
   - Classify each failure: assertion error, compile error, missing mock, wrong expectation, or flaky.
   - Fix production code or tests following project conventions (private mocks `_MockX`, `buildBloc()` for bloc_test, matchers in `expect`, no shared mutable state).

6. **Fix one failure at a time**
   - Re-run the affected suite after each fix.

7. **Re-run full gate sequence**
   - Analyze → format (if needed) → full test suites. Confirm all green.

## Checklist

- [ ] `fvm dart analyze` passes with no new issues
- [ ] Changed files formatted with `fvm dart format`
- [ ] Generated code in sync (if models changed)
- [ ] `fvm flutter test` passes
- [ ] All package `fvm dart test` runs pass
- [ ] No shared mutable state or wrong mock setup in tests
