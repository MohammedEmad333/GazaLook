# GazaLook 🛍️

A fast, lightweight mobile e-commerce app for a local fashion store in Gaza —
styled like Shein, optimised for low-bandwidth connections and modest devices.

- **Currency:** Israeli Shekel (₪ / ILS)
- **Language:** Arabic-first (RTL), English fallback
- **Platform:** Flutter (Android + iOS)

## Architecture

The project follows **Clean Architecture** with a **feature-first** layout.
Each feature is split into three layers — `data`, `domain`, and `presentation`.

```
lib/
├── main.dart                     # Entry point (bindings, orientation lock)
├── app.dart                      # Root MaterialApp.router (theme, l10n, RTL)
├── core/                         # Shared, cross-feature building blocks
│   ├── theme/                    # AppTheme, colours, typography, dimensions
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   └── app_dimensions.dart
│   ├── router/                   # go_router config + route paths
│   │   ├── app_router.dart
│   │   └── app_routes.dart
│   ├── constants/                # App-wide constants (currency, governorates…)
│   ├── utils/                    # Helpers (currency formatter…)
│   ├── error/                    # Failures / exceptions (added per phase)
│   ├── network/                  # Dio client / interceptors (added per phase)
│   └── widgets/                  # Shared widgets (placeholder, states…)
└── features/
    ├── auth/                     # Phone/OTP login + guest browsing (Phase 2)
    ├── home/                     # Home feed, search, banners, grid (Phase 3)
    ├── products/                 # Product detail page (Phase 4)
    ├── cart/                     # Cart + localised checkout (Phase 5)
    └── orders/                   # Order history

# Every feature is structured as:
#   <feature>/
#   ├── data/        (datasources, models, repositories)
#   ├── domain/      (entities, repositories, usecases)
#   └── presentation/(bloc, pages, widgets)
```

## Tech stack

| Concern           | Package(s)                                     |
| ----------------- | ---------------------------------------------- |
| State management  | `flutter_bloc`, `bloc`, `equatable`            |
| Navigation        | `go_router`                                    |
| Local storage     | `hive`, `hive_flutter`, `shared_preferences`   |
| Networking        | `dio`                                          |
| Image caching     | `cached_network_image` (low-bandwidth-friendly)|
| Error handling    | `dartz`                                         |
| Dependency inject | `get_it`                                        |
| Formatting/i18n   | `intl`                                          |

## Design system

The theme (`core/theme/`) is derived directly from the approved mock-ups:

- **Primary:** muted rose `#805253` with `#E9AFAF` container
- **Background/Surface:** warm light `#FCF9F8` / white `#FFFFFF`
- **Type:** Montserrat (display/headline) + Inter (body)
- **Corners:** 12px rounded cards, buttons and inputs
- **Shadows:** soft `0 4px 20px rgba(0,0,0,0.04)`

## Build roadmap

- [x] **Phase 1** — Project setup, folder structure, theme
- [ ] **Phase 2** — Auth (phone/OTP, +970/+972, guest) + local session
- [ ] **Phase 3** — Home & catalog (search, filter chips, banners, grid)
- [ ] **Phase 4** — Product Detail Page (gallery, size guide, availability)
- [ ] **Phase 5** — Cart & localised checkout (governorates, COD, Jawwal Pay)

## Getting started

```bash
flutter pub get
flutter run
```

> Font assets (Montserrat, Inter) are referenced but commented out in
> `pubspec.yaml`. Drop the `.ttf` files into `assets/fonts/` and uncomment the
> `fonts:` block to bundle them; until then the app uses platform defaults.
