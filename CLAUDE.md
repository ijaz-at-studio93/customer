# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

All common tasks are wrapped in `makefile`:

```sh
make get               # flutter pub get
make clean             # flutter clean + pub get
make generate          # dart run build_runner build --delete-conflicting-outputs
make watch             # build_runner watch (for active model generation)
make getAndGenerate    # make get && make generate
make fix               # dart fix + dart format + sort imports
make apk               # release APK
make devApk            # release APK with ENVIRONMENT=development
make pod-install       # cd ios && pod install
make reset-pod         # remove Podfile.lock + pod install
```

Standard Flutter: `flutter run` to launch on a connected device/emulator.

After adding or modifying model files with JSON serialization, run `make generate` to regenerate `.g.dart` files.

## Architecture

This is a Flutter app for a salon-booking customer experience, using **GetX** throughout for state management, routing, and dependency injection.

### Layers

```
lib/
├── api/          # Dio-based HTTP clients (one file per feature domain)
├── controller/   # GetX controllers — business logic and state
├── model/        # Data models; .g.dart files are build_runner-generated
├── page/         # UI pages, organized by feature subfolder
├── service/      # Thin service classes (e.g., AnalyticsService)
├── util/         # Helpers: SharedPrefs, NotificationUtils, Extensions
├── constant/     # API URLs, colors, asset paths, variable keys
└── project_specific/  # Shared custom widgets and text themes
```

### State Management (GetX)

The app has two long-lived controllers, both registered as permanent singletons in `main.dart`:

- **`AuthController`** (`lib/controller/auth_controller.dart`) — user authentication, profile, favorites, app reset/logout
- **`HomeController`** (`lib/controller/home_controller.dart`) — salon data, bookings, cart, artists, real-time socket

Reactive state pattern used everywhere:
```dart
final Rx<SomeModel> _model = SomeModel().obs;
SomeModel get model => _model.value;
set setModel(val) => _model.value = val;
```

### Routing

There is no centralized route table. Navigation uses GetX calls directly:
- `Get.to(() => SomePage())` — push
- `Get.offAll(() => SomePage())` — replace entire stack
- `Get.back()` — pop

The splash page (`lib/page/splash_page.dart`) is the auth guard and decides the initial destination based on login state, active appointments, and pending payments.

### Network Layer

`lib/api/dio_client.dart` configures a single Dio instance with:
- Bearer token injected on every request
- Silent token refresh on 401/403 (uses a Completer queue to prevent concurrent refresh races)
- Falls back to `AuthController.resetApp()` (logout) if refresh fails
- Pass `extra: {skipAuth: true}` to bypass auth on public endpoints

API files (`auth_api.dart`, `home_api.dart`, `analytics_api.dart`) are static-method classes that call `DioClient.client` directly and return typed models.

### Local Storage

`get_storage` is the persistence layer, wrapped by `lib/util/SharedPrefs.dart`. Key names are defined in `lib/constant/variable_constant.dart` (e.g., `token`, `refreshToken`, `isUserLogin`, `fcmToken`).

### Push Notifications & Real-Time

- **FCM** + **flutter_local_notifications** handle push notifications. Three Android channels: `confirm`, `complete`, `general_silent`.
- **Socket.IO** (`socket_io_client`) is used in `HomeController` for real-time booking confirmation events.
- Notification initialization and FCM token setup happen in `main.dart` before `runApp`.
