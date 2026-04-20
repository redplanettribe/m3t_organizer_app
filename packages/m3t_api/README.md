# m3t_api

HTTP client and DTOs for the m3t Organizer backend. This package handles the network — it knows nothing about the domain.

---

## Usage

```dart
// tokenProvider is required — the client calls it on every authenticated request.
// baseUrl is optional; defaults to the Android emulator loopback for local dev.
final client = M3tApiClient(
  tokenProvider: () async => await secureStorage.read(),
  baseUrl: 'https://your-api-host.example.com', // optional, override via --dart-define
);

await client.requestLoginCode('user@example.com');

final response = await client.verifyLoginCode(
  email: 'user@example.com',
  code: '123456',
);
// response.token, response.user
```

---

## Response envelope

All JSON responses follow the backend's `helpers.APIResponse` shape:

```json
{
  "data": { /* success payload */ },
  "error": {
    "code": "session_full",
    "message": "Session is at capacity",
    "show_to_user": true
  }
}
```

`ApiError` carries:

- `code` — machine-readable business error code. Repositories branch on this.
- `message` — human-readable message.
- `showToUser` — backend hint that `message` is safe to render. Stays in the api layer; repositories do **not** propagate it to domain failures.

Envelope parsing lives in `ApiHttpExecutor.parseEnvelope` and `parseListEnvelope`. Both detect `error` first, then non-2xx status codes, then malformed bodies — converting all of them into a `M3tApiException` subclass via a caller-supplied factory.

---

## Exceptions

Every transport failure extends the abstract `M3tApiException`:

```dart
abstract class M3tApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;
  final bool showToUser;
}
```

One named subclass per endpoint so repositories can pattern-match:

| Exception | When |
|---|---|
| `RequestLoginCodeFailure` | Login-code request fails |
| `VerifyLoginCodeFailure` | Code verification fails |
| `GetCurrentUserFailure` | Fetching current user's profile fails |
| `UpdateCurrentUserFailure` | Updating current user's profile fails |
| `DeleteCurrentUserFailure` | Deleting the authenticated account fails |
| `RequestAvatarUploadFailure` | Requesting a presigned avatar upload URL fails |
| `UploadAvatarFailure` | Uploading avatar bytes to storage fails |
| `ConfirmAvatarFailure` | Confirming uploaded avatar with the backend fails |
| `GetMyEventsFailure` | Listing managed events fails |
| `GetEventByIdFailure` | Fetching a single event (with rooms/sessions) fails |
| `CheckInAttendeeFailure` | Checking an attendee into an event fails |
| `GetEventDeliverablesFailure` | Listing event deliverables fails |
| `GiveDeliverableFailure` | Recording a deliverable giveaway fails |
| `CheckInAttendeeToSessionFailure` | Checking an attendee into a specific session fails |
| `ReleaseSessionBookingsFailure` | Releasing unchecked-in session bookings fails |
| `GetSessionByIdFailure` | Fetching session details fails |
| `UpdateSessionStatusFailure` | Updating a session's lifecycle status fails |

Repositories catch these (often via `on M3tApiException catch`) and map them to domain failures. Always **branch on `errorCode` first**, fall back to `statusCode`. Known codes are enumerated per endpoint in `docs/api/swagger.json`.

---

## Testing

```bash
flutter test
```
