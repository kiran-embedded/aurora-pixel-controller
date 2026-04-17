# Project Architecture: Modules & Directory Structure

This project follows a clean, layered modular architecture designed for high maintainability, scalability, and easy debugging.

## Directory Overview

```text
lib/
  ├── core/                 # Foundation and shared global resources
  │   ├── theme/           # UI styling, color palettes, and layout scaling
  │   └── utils/           # Shared helper functions and extensions
  ├── logic/                # State management and business logic
  ├── views/                # High-level screens and page layouts
  └── widgets/              # Reusable UI components
```

---

## 1. Core Module (`lib/core`)
The **Core** module contains the fundamental building blocks of the application that are used globally.

- **`theme/app_theme.dart`**: Defines the visual identity of the app (colors, typography, component styles). Centralizing this makes it easy to perform global design updates.
- **`theme/layout_engine.dart`**: Handles responsive scaling across different screen sizes. Use this for font sizes, padding, and dimensions to ensure a consistent experience on all devices.

## 2. Logic Module (`lib/logic`)
The **Logic** module is the "brain" of the application. It manages state and coordinates interactions with external services.

- **`hardware_state.dart`**: A `ChangeNotifier` (Provider) that manages the state of the LED hardware (power, brightness, active animations, colors). This is the source of truth for the entire app's state.

## 3. Views Module (`lib/views`)
The **Views** module contains the primary screens and high-level layouts. These files coordinate multiple widgets to form a complete user interface.

- **`dashboard_screen.dart`**: The main scaffold of the app, containing the navigation bar and switching between tabs.
- **`home_tab.dart`**: The primary control center featuring master power and quick selection tiles.
- **`studio_tab.dart`**: Advanced control panel for fine-tuning animations, spectral hub (colors), and visual effects.
- **`settings_tab.dart`**: App configuration, hardware integration info, and system-level settings.

## 4. Widgets Module (`lib/widgets`)
The **Widgets** module contains standalone, reusable UI components. These should generally be "stateless" or manage only their own internal visual state, relying on the **Logic** module for application state.

- **`ws2812_strip.dart`**: A hyper-realistic simulation of an LED strip. It visualizes the current animation and color state in real-time.

---

## Debugging Tips

1.  **UI Glitches?** Check `lib/core/theme` for styling issues or `lib/core/theme/layout_engine.dart` if elements are poorly sized.
2.  **State Sync Issues?** Debug `lib/logic/hardware_state.dart`. Use print statements or breakpoints in the setters (e.g., `_syncToHardware`).
3.  **Component Rendering?** If a specific button or the LED strip looks wrong, investigate the corresponding file in `lib/widgets`.
4.  **Layout Problems?** Look at the specific screen file in `lib/views`.
