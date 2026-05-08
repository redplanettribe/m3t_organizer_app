## How-to: Force update via remote config

Goal: when backend raises minimum supported build, app must block all screens until user updates.

This repo implements force-update gate using layered architecture (presentation → domain → data).

### API contract

- **Endpoint**: `GET /mobile/remote-config`
- **Query params**:
  - `app`: `attendee` (or your app identifier)
  - `platform`: `android` | `ios`
- **Response**: `data` contains:
  - `min_build` (hard floor) + `min_version`
  - `latest_build` + `latest_version` (informational)
  - `android_store_url`, `ios_store_url`
- **Rule enforced**: **force update when** `currentBuild < min_build`.

### Design principles (UI/UX)

- **Block entire app**: force-update screen renders above router so user cannot deep-link around it.
- **Non-dismissable**: back navigation disabled.
- **Single primary action**: “Update now” opens store externally.
- **Fail-open** on network outage: if remote-config fetch fails and app was not already forced, app continues (avoid locking users out due to your outage).
- **Sticky forced update**: once forced, do not downgrade to “ok” on transient errors—only a successful check releasing the min build should unlock (prevents outage bypass).

### Implementation map (by layer)

#### 1) Domain (`packages/domain/`)

Add:

- **Entity**: `MobileRemoteConfig` (`packages/domain/lib/src/entities/mobile_remote_config.dart`)
- **Enum**: `MobileAppPlatform` (`packages/domain/lib/src/enums/mobile_app_platform.dart`)
- **Repository port**: `RemoteConfigRepository`
  (`packages/domain/lib/src/repositories/remote_config_repository.dart`)
- **Failure**: `GetMobileRemoteConfigFailure` sealed family
  (`packages/domain/lib/src/failures/get_mobile_remote_config_failure.dart`)

Export via domain barrel files so app layer can import `package:domain/domain.dart`.

#### 2) API client (`packages/m3t_api/`)

Add:

- **DTO**: `MobileRemoteConfigResponse`
  (`packages/m3t_api/lib/src/models/mobile_remote_config_response.dart`)
- **Data source**: `RemoteConfigDataSource`
  (`packages/m3t_api/lib/src/data_sources/remote_config_data_source.dart`)
- **Path**: `MobilePaths.remoteConfig` in
  `packages/m3t_api/lib/src/http/api_paths.dart`
- **Typed exception**: `GetMobileRemoteConfigFailure` in
  `packages/m3t_api/lib/src/exceptions.dart`
- Wire into `M3tApiClient`:
  `packages/m3t_api/lib/src/m3t_api_client.dart` exposes:
  `getMobileRemoteConfig({required String platform})` and always sends `app=attendee`.

Generate DTO serialization:

```bash
cd packages/m3t_api
fvm dart run build_runner build --delete-conflicting-outputs
```

#### 3) Repository implementation (data layer)

Create new pure-Dart package:

- `packages/remote_config_repository/`
  - `RemoteConfigRepositoryImpl` calls `M3tApiClient.getMobileRemoteConfig(...)`
  - Mapper converts DTO → domain entity
  - Translates API failures → domain failures

Add path dependency to app `pubspec.yaml`:

- `remote_config_repository: { path: packages/remote_config_repository }`

#### 4) Presentation: gate + UX

Add:

- **Cubit + state**:
  - `lib/core/remote_config/remote_config_cubit.dart`
  - `lib/core/remote_config/remote_config_state.dart`
- **Gate widget**:
  - `lib/core/remote_config/view/app_update_gate.dart`
- **Blocking screen**:
  - `lib/core/remote_config/view/force_update_page.dart`

Gate behavior:

- On cold start: create cubit and immediately call `check()`.
- On foreground resume: use `AppLifecycleListener(onResume: ...)` to call `check()` again.
- When forced: render isolated `MaterialApp(home: ForceUpdatePage(...))`.

Store launching:

- Dependency: `url_launcher`
- Call `launchUrl(storeUri, mode: LaunchMode.externalApplication)`

#### 5) Composition root (`lib/bootstrap.dart`) + App wiring

In `lib/bootstrap.dart`:

- Create `RemoteConfigRepositoryImpl(apiClient: apiClient)`
- Read installed build number:
  - `final info = await PackageInfo.fromPlatform();`
  - `final currentBuild = int.tryParse(info.buildNumber);`
- Detect platform (`android`/`ios`) and pass into `App(...)`.

In `lib/app/view/app.dart`:

- Provide `RemoteConfigRepository` via `RepositoryProvider`.
- Provide `RemoteConfigCubit` only when `(currentBuild != null && platform != null)`.
- Wrap router host with `AppUpdateGate`.

### Dependencies to add (app)

Add using FVM:

```bash
fvm flutter pub add package_info_plus url_launcher
```

### Tests to copy (recommended)

- **API** (`packages/m3t_api/test/src/data_sources/remote_config_data_source_test.dart`)
- **Repository** (`packages/remote_config_repository/test/remote_config_repository_test.dart`)
- **Cubit** (`test/core/remote_config/remote_config_cubit_test.dart`)
- **Gate widget** (`test/core/remote_config/app_update_gate_test.dart`)

### Local verification checklist

- Set app build below `min_build` and confirm app blocks on cold start.
- Put app in background, raise `min_build`, resume app, confirm block appears.
- Break network: confirm app **does not** block if not already forced.
- While forced, break network: confirm app **stays forced**.

