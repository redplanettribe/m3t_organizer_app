---
name: m3t-api-usage
description: How to call and use the backend API via packages/m3t_api — client construction, endpoints, response envelope, typed exceptions with business error codes, repository mapping, adding new endpoints. Use when calling the API, adding endpoints, handling API errors, or wiring a repository to the client.
---

# m3t_api — Backend API Usage

## When to Use

- Calling the backend API from the app.
- Adding a new API endpoint or wiring a repository to the client.
- Handling API errors or mapping business error codes to domain failures.

## Instructions

### 1. Where the client lives

- `M3tApiClient` lives in `packages/m3t_api`. The app does **not** call it from UI or BLoC. It is used only inside repository implementations (e.g. `AuthRepositoryImpl`, `EventsRepositoryImpl` in `packages/auth_repository`). BLoCs and widgets depend on domain repository interfaces and get them via `context.read<…Repository>()`.

### 2. Construction

- In `lib/bootstrap.dart`, the client is built with:
  - **tokenProvider:** Required for authenticated requests (e.g. `tokenStorage.read`). The client calls it on each request that needs auth.
  - **baseUrl:** Optional; defaults to Android emulator loopback (`http://10.0.2.2:8080`). Override for other environments (e.g. via `--dart-define` or `AppConfig.baseUrl`).
- Optional: `http.Client` for testing or custom behavior.

### 3. Available methods

| Method | Returns | Auth |
|--------|---------|------|
| `requestLoginCode(String email)` | `Future<void>` | No |
| `verifyLoginCode({required email, required code})` | `Future<LoginResponse>` | No |
| `getCurrentUser()` | `Future<User>` | Yes |
| `updateCurrentUser({String? name, String? lastName})` | `Future<User>` | Yes |
| `deleteCurrentUser()` | `Future<void>` | Yes |
| `requestAvatarUploadUrl()` | `Future<(Uri uploadUrl, String key)>` | Yes |
| `uploadAvatarBytes({required uploadUrl, bytes, contentType})` | `Future<void>` | No (upload to storage) |
| `confirmAvatar({required String key})` | `Future<User>` | Yes |
| `getMyEvents()` | `Future<List<Event>>` | Yes |
| `getEventById({required eventID})` | `Future<GetEventByIdResponse>` | Yes |
| `checkInAttendee({required eventID, userID})` | `Future<EventCheckIn>` | Yes |
| `getEventDeliverables({required eventID})` | `Future<List<EventDeliverable>>` | Yes |
| `giveDeliverableToUser({required eventID, deliverableID, userID, giveAnyway})` | `Future<DeliverableGiveaway>` | Yes |
| `checkInAttendeeToSession({required eventID, sessionID, userID})` | `Future<SessionCheckIn>` | Yes |
| `releaseUncheckedInSessionBookings({required eventID, sessionID})` | `Future<int>` | Yes |
| `getSessionById({required sessionID})` | `Future<Session>` | Yes |
| `updateSessionStatus({required eventID, sessionID, status})` | `Future<Session>` | Yes |

### 4. Response envelope

The backend returns every JSON response inside the standard `helpers.APIResponse` shape:

```json
{
  "data": { /* success payload — object, list, null, or absent */ },
  "error": {
    "code": "session_full",
    "message": "Session is at capacity",
    "show_to_user": true
  }
}
```

`ApiError` — `packages/m3t_api/lib/src/models/api_error.dart` — has:
- `code` — machine-readable **business error code**. Repositories branch on this.
- `message` — human-readable message. Localized on the backend when possible.
- `showToUser` (`show_to_user`) — backend hint that `message` is safe to render as-is. Stays in the api layer; repositories never propagate it to domain failures.

Parsing is centralized in `ApiHttpExecutor`:

- `parseEnvelope(response, onError: ...)` — for endpoints whose `data` is an object (or absent). Returns the decoded map or `null`, or throws via [`onError`].
- `parseListEnvelope(response, onError: ..., itemKeys: [...])` — for endpoints whose `data` is a list. Accepts array, `null`, empty object, or a wrapper object keyed by one of `itemKeys`, `items`, `results`, `data`.

Both helpers:
1. Detect an `error` field first and throw with `code`, `message`, `showToUser`.
2. Treat non-2xx status codes as failures when the body has no `error`.
3. Surface malformed bodies via the same exception factory.

### 5. Typed exceptions — `M3tApiException`

All api-layer failures extend the abstract `M3tApiException` (`packages/m3t_api/lib/src/exceptions.dart`) with a uniform shape:

```dart
abstract class M3tApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;
  final bool showToUser;
}
```

One named subclass per endpoint (e.g. `GiveDeliverableFailure`, `CheckInAttendeeToSessionFailure`, `UpdateSessionStatusFailure`, …) so repositories can still pattern-match with `on <Specific>Failure catch`. Use `on M3tApiException catch` when the mapping logic is identical across endpoints (as in `EventsRepositoryImpl`).

### 6. Mapping to domain failures — code first, status fallback

Repositories translate transport failures into domain failures at the boundary. **Always branch on `errorCode` first** and fall back to `statusCode` only when the code is unknown or missing:

```dart
Never _throwEventsFailure(api.M3tApiException e) {
  switch (e.errorCode) {
    case 'session_full':              throw domain.EventsSessionFull();
    case 'schedule_conflict':         throw domain.EventsScheduleConflict();
    case 'live_session_conflict':     throw domain.EventsLiveSessionConflict();
    case 'deliverable_already_given': throw domain.EventsDeliverableAlreadyGiven();
    case 'unprocessable_entity':      throw domain.EventsUnprocessableEntity();
    case 'not_registered_for_event':  throw domain.EventsNotRegisteredForEvent();
    case 'session_all_attend':        throw domain.EventsSessionAllAttend();
    case 'invalid_or_expired_token':  throw domain.EventsInvalidOrExpiredToken();
    case 'event_not_found':
    case 'session_not_found':         throw domain.EventsNotFound();
    case 'conflict':                  throw domain.EventsConflict();
    case 'tier_not_allowed':          throw domain.EventsForbidden();
    // …
  }
  switch (e.statusCode) {
    case 400: throw domain.EventsInvalidInput();
    case 401: throw domain.EventsUnauthorized();
    case 403: throw domain.EventsForbidden();
    case 404: throw domain.EventsNotFound();
    case 409: throw domain.EventsConflict();
    case 422: throw domain.EventsUnprocessableEntity();
    case 500: throw domain.EventsUnknownError();
  }
  throw domain.EventsNetworkError();
}
```

Known backend error codes (see swagger for the authoritative list):

| Code | Typical status | Meaning |
|------|----------------|---------|
| `session_full` | 409 | Session at capacity |
| `schedule_conflict` | 409 | Attendee already checked into overlapping session |
| `live_session_conflict` | 409 | Room already has a live session |
| `deliverable_already_given` | 409 | Item already delivered for this attendee |
| `unprocessable_entity` | 422 | Attendee not registered/checked in, etc. |
| `not_registered_for_event` | 403/404 | Attendee lacks a registration |
| `session_all_attend` | 400 | Attendee fully assigned within ticket tier |
| `invalid_or_expired_token` | 401 | JWT missing/expired — redirect to login |
| `event_not_found` / `session_not_found` | 404 | Resource missing |
| `conflict` | 409 | Generic conflict (e.g. account delete with active event) |
| `tier_not_allowed` | 403 | Ticket tier forbids action |
| `invalid_code` / `expired_code` | 400/401 | Login verification failed |
| `invalid_request_body` / `invalid_path_param` / … | 400 | Validation errors |
| `internal_error` | 500 | Server-side bug; map to unknown |

`showToUser` never appears in domain failures. If UI needs to show raw backend copy, surface that via a separate channel (e.g. a debug snackbar fed by the api layer).

### 7. API specification

- Source of truth: **`docs/api/swagger.json`** (OpenAPI/Swagger 2.0). Each endpoint enumerates its error codes under the response descriptions (e.g. `error.code: session_full | schedule_conflict`). When adding or changing client methods, align with the spec.

### 8. Adding a new endpoint

1. Check **`docs/api/swagger.json`** for the path, verb, parameters, response schema, and the list of `error.code` values per status.
2. If the success payload needs a new DTO, add it under `packages/m3t_api/lib/src/models/` (see `dart-model-from-json` skill) and run build_runner.
3. Add a dedicated exception class in `exceptions.dart` that extends `M3tApiException` with the standard fields:

    ```dart
    final class MyNewEndpointFailure extends M3tApiException {
      MyNewEndpointFailure(
        super.message, {
        super.statusCode,
        super.errorCode,
        super.showToUser,
      });
    }
    ```

4. Add a method on the appropriate data source (e.g. `EventsDataSource`) and wire it through `M3tApiClient`. Use `executor.parseEnvelope` (object payload) or `executor.parseListEnvelope` (list payload) and pass an `onError` closure that builds your new failure with `message`, `statusCode`, `errorCode`, `showToUser`.
5. In the repository, catch `M3tApiException` (or the specific subclass) and call the repo's `_throwXxxFailure` helper. **Branch on `errorCode` first, `statusCode` second.**
6. If the endpoint introduces new business codes that need distinct UX, add explicit domain failures in `packages/domain/lib/src/failures/` and extend the repo's helper + any failure-message switch (e.g. `lib/core/events/events_failure_message.dart`). Sealed switches will flag missing cases.
7. Add tests: JSON round-trip for new DTOs, and code→failure mapping in the repository test.

## References

- `docs/api/swagger.json` — backend API specification (paths, schemas, auth, per-endpoint error codes)
- `packages/m3t_api/README.md` — usage summary, envelope, exception base
- `packages/m3t_api/lib/src/http/api_http_executor.dart` — `parseEnvelope` / `parseListEnvelope`
- `packages/m3t_api/lib/src/m3t_api_client.dart` — client facade
- `packages/m3t_api/lib/src/exceptions.dart` — `M3tApiException` and per-endpoint subclasses
- `packages/m3t_api/lib/src/models/api_error.dart` — `ApiError` with `code`, `message`, `showToUser`
- `packages/auth_repository/lib/src/auth_repository.dart` — code-first auth error mapping
- `packages/auth_repository/lib/src/events_repository_impl.dart` — `_throwEventsFailure` helper
- `packages/domain/lib/src/failures/events_failure.dart` — domain failures keyed to business codes
- `lib/bootstrap.dart` — how the client is constructed and passed to the repository
