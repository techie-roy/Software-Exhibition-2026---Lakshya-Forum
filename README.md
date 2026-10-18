# AgriQueue

A multilingual Flutter app that helps farmers book **mandi (market yard) arrival
slots**, track their **live queue position**, and view **market prices** and
**procurement** information — with voice-assisted booking for low-literacy users.

> **Status: prototype / demonstration build.**
> Authentication, slot inventory, queue data, and market prices are backed by
> in-app **mock services** by default. Firebase Authentication (email/password)
> is wired up as an optional online sign-in path, but it is **not required** and
> the app falls back to mock mode when Firebase is not configured. See
> [Authentication modes](#authentication-modes) and
> [Known limitations](#known-limitations) before treating any part of this app
> as production-ready.

---

## Features

- **Slot booking** — pick a date and an available arrival slot, review and
  confirm the booking.
- **Voice booking** — speak the crop / intent and let the app match a slot;
  powered by `speech_to_text` with `flutter_tts` spoken feedback.
- **Live queue tracking** — see your token, position, and estimated wait.
- **Market prices** — browse crop prices by market.
- **Procurement** — view procurement centres and details.
- **Aadhaar scanning (optional)** — scan/OCR an Aadhaar card during registration
  via `camera` + Google ML Kit text recognition, with checksum validation.
- **Multilingual UI** — 9 selectable languages (see
  [Localization](#localization)).
- **Booking management** — cancel an active booking with a confirmation dialog.

## Screens / flow

```
Language  →  Login  ──(register)──►  Register  →  OTP  →  Main shell
                 └──(otp login)──────────────────────────►  Main shell
Main shell tabs: Home · Slot booking · Queue · Prices · Procurement · Profile
                 └─► Slot booking → Booking confirmation → Queue tracking
                 └─► Voice booking
```

Route constants live in `lib/app/routes.dart`.

## Tech stack

| Area | Package(s) |
| --- | --- |
| Framework | Flutter (Dart SDK `^3.13.2`) |
| State management | `provider` |
| Auth | `firebase_core`, `firebase_auth` (optional) + mock auth |
| Persistence | `shared_preferences` |
| Voice | `speech_to_text`, `flutter_tts` |
| Aadhaar OCR | `camera`, `google_mlkit_text_recognition`, `permission_handler` |
| UI | `google_fonts`, `intl`, `cupertino_icons` |

## Project structure

```
lib/
  app/        app shell, theme, routes, constants, localizations
  models/     plain data models (booking, farmer, slot, price, ...)
  providers/  ChangeNotifier state (auth, booking, queue, language)
  screens/    one file per screen
  services/   mock data/auth, Firebase auth, OCR, speech, local storage
  utils/      validators, formatters, Aadhaar validator
  widgets/    reusable UI components
test/
  unit/       unit tests
  widget/     widget tests
  widget_test.dart
```

## Getting started

### Prerequisites

- Flutter SDK (stable) — this project targets Dart `^3.13.2`.
- Android toolchain (or Windows/web/desktop target) per `flutter doctor`.

### Run

```bash
flutter pub get
flutter run            # choose a device
```

The app runs against **mock services out of the box** — no backend or Firebase
project is required to explore the prototype.

### Platforms

Generated for Android, iOS, web, Windows, macOS, and Linux. Day-to-day
development and the release build in this repository were done on **Android**;
other platforms should be treated as untested.

## Authentication modes

The app supports two modes and **never silently pretends mock auth is the real
backend**:

1. **Mock mode (default)** — used when Firebase is not configured. Sessions and
   farmer profiles come from `lib/services/mock_auth_service.dart`. This is
   **demo-only** and must not be used to protect real data.
2. **Firebase mode (optional)** — if `Firebase.initializeApp()` succeeds, email/
   password sign-in is handled by `lib/services/firebase_auth_service.dart`.

In **release** builds, if Firebase failed to initialize a red
`FirebaseConfigWarning` banner is shown so mock mode is never mistaken for a
real backend. Debug builds and widget tests intentionally stay quiet.

### Demo credentials (mock mode only)

The mock service recognises fixed demo accounts and the login screen is
pre-filled for convenience:

- Mobile `9876543210`, password `123456`

These are **fake, non-secret values** used only by the mock auth service (see
`lib/services/mock_auth_service.dart`). Mock mode also accepts **any non-empty
password** for a known number and accepts any 6-digit OTP — this is intentional
demo behaviour, **not** a real authentication flow.

## Firebase setup (Android)

`android/app/google-services.json` is **not committed** — it is project-specific
and listed in `.gitignore`. The Android build **requires this file to exist**
(the `com.google.gms.google-services` Gradle plugin fails without it), but the
app still runs in mock mode if Firebase fails to initialize.

To connect your own Firebase project:

1. Create a Firebase project and add an Android app with package name
   `com.agriqueue.agri_queue`.
2. Download `google-services.json` and place it at
   `android/app/google-services.json`.
3. Build/run normally — no code changes needed.

> `firebase_options.dart` (FlutterFire CLI) has **not** been generated. Android
> works because the Gradle plugin reads `google-services.json`; other platforms
> would need `flutterfire configure` to generate it.

### Google Sign-In (Android)

Google Sign-In is implemented (`lib/services/google_auth_service.dart`,
`FirebaseGoogleAuthService`) using `google_sign_in` v7 and Firebase Auth. The
"Continue with Google" button is **only shown when Firebase is configured**; on
success the Google ID token is exchanged with Firebase
(`FirebaseAuthService.signInWithGoogle`) and the session is persisted like any
other login. Cancellation is silent; configuration/network errors surface a
message (never a fake success).

The code is wired, but the Google provider is **not yet configured** for the
current `google-services.json` (its `oauth_client` array is empty), so the flow
will report "not configured" until these manual steps are done:

1. Firebase Console → **Authentication → Sign-in method** → enable **Google**.
2. Register the app's **SHA-1 / SHA-256** fingerprints on the Android OAuth
   client (Project settings → Your apps). For local debug builds use the debug
   keystore:
   `keytool -list -v -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore -storepass android -keypass android`
   For release, use the release keystore's fingerprints.
3. Ensure an **OAuth web client** exists (Authentication → Google, or Google
   Cloud Console → Credentials → OAuth client ID → Web application). The Gradle
   plugin turns this into the `default_web_client_id` string resource the plugin
   reads automatically.
4. Re-download `google-services.json` into `android/app/` (it now contains an
   `oauth_client` entry) and rebuild.

> If you prefer not to re-download the file, you can pass the web client ID at
> build time instead:
> `flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=<id>.apps.googleusercontent.com`.
> Never commit `google-services.json` or any client secret.

## Localization

`lib/models/language.dart` lists **9 selectable languages** (English, Hindi,
Telugu, Tamil, Marathi, Bengali, Gujarati, Punjabi, Kannada). Full UI strings
currently exist for **English (`en`) and Hindi (`hi`)** only; the other
languages fall back to English at runtime. See `lib/app/localizations.dart`.

## Testing

```bash
flutter analyze
flutter test
```

Unit tests cover the mock data/auth services, validators, OCR service, TTS
service, localization, and Google sign-in (via an injected fake — no real Google
credentials or Firebase project required); widget tests cover the main
navigation, auth, booking, voice, and Google button visibility.

## Known limitations

- **Mock data only** — slots, queues, prices, and procurement are simulated in
  app memory (`MockDataService`); nothing is shared between devices or users.
- **Demo authentication** — see
  [Demo credentials](#demo-credentials-mock-mode-only). Mock mode accepts any
  non-empty password / any OTP by design.
- **Firebase is optional and Android-only as configured** — no
  `firebase_options.dart`; other platforms need FlutterFire CLI setup.
- **Google Sign-In needs Console setup** — the code is implemented, but the
  Google provider / OAuth web client / SHA-1 fingerprints must be added and
  `google-services.json` re-downloaded before the button succeeds (see
  [Google Sign-In (Android)](#google-sign-in-android)). Until then it reports
  "not configured" rather than signing in.
- **Mobile + password and OTP remain simulated** — those paths use
  `MockAuthService` even when Firebase is configured; the demo banner always
  discloses this.
- **Release signing uses the debug keystore** in
  `android/app/build.gradle.kts` — not suitable for store distribution.
- **7 of 9 languages fall back to English** (untranslated strings).
- **Android release build note** — `android/gradle.properties` sets
  `kotlin.incremental=false` as a workaround for a cross-drive Kotlin
  incremental-cache failure; it can be removed once the toolchain layout allows.

## License

No license file is included in this repository.
