<p align="center">
  <img src="assets/readme/header_animation.svg" alt="Aurora Pixel Controller" width="100%">
</p>

## 🌌 Overview
**Aurora Pixel Controller** is a professional hardware control interface designed for robust LED management. Featuring a pure AMOLED-black aesthetic and high-fidelity hardware simulation, this project provides a premium structural environment for local and remote LED installations.

[![Version](https://img.shields.io/badge/version-v1.0.0--Stable-FF2D55?style=for-the-badge)](https://github.com/kiran-embedded)
[![Status](https://img.shields.io/badge/Status-Production_Ready-00F0FF?style=for-the-badge)](https://github.com/kiran-embedded)
[![Platform](https://img.shields.io/badge/Platform-Flutter_|_ESP32_|_ESP8266-white?style=for-the-badge)](https://flutter.dev)

---

## 🛰️ Project Status: v1.0.0 Stable (Hardware Sync Ready)

> [!IMPORTANT]  
> This project has officially exited Beta and is now in **Production Stable** status.
> - **Backend Connected**: Fully operational integration with Firebase Realtime Database for instantaneous hardware execution.
> - **In-App Firmware Extraction**: Production-certified C++ firmwares for ESP32 and ESP8266 are deeply embedded within the application. Users can grab the `.ino` files directly from the in-app Firmware Centre.

---

## ⚡ High-Fidelity Simulation System

Aurora doesn't just send values; it mathematically simulates the hardware. 

### 📉 Gravity Drop (VU Mode)
*Physics-based peak audio detection computing precise weight-drop release intervals.*
<p align="center">
  <img src="assets/readme/simulation_gravity_drop.svg" alt="Gravity Drop VU Simulation" width="100%">
</p>

### ☄️ Meteor Shower (Pixel Mode)
*Asynchronous streaking light pulses using continuous decay (`fadeToBlackBy`) algorithms.*
<p align="center">
  <img src="assets/readme/simulation_meteor_shower.svg" alt="Meteor Shower Simulation" width="100%">
</p>

### 🧘 Neon Pulse (Ambient Mode)
*Rhythmic timeline loops designed for structural immersion.*
<p align="center">
  <img src="assets/readme/simulation_neon_pulse.svg" alt="Neon Breath Simulation" width="100%">
</p>

---

## 🚀 Recent Updates (v1.0.0 Stable)

Built to enforce maximum reliability across both the digital layout and physical networks:

- **App-Based Hardware Firmwares**: Eradicated traditional GitHub dependency downloading. Fully functioning `FastLED` ESP32 and ESP8266 firmwares are packed tightly into the app's `assets/firmwares/` directory for direct extraction.
- **Firebase Synchronicity**: Engineered constant structural syncing. Variables like Active Animation, Color Hex, and Power natively map to identical Firebase pathways parsed safely by the ESP.
- **Advanced Topology Safeguards**: Overhauled Android Accessibility font-scaling logic. Typography is mathematically halted via `textScaleFactor`, ensuring UI layouts cannot geometrically break.
- **Legacy Haptic Engineering**: Stripped third-party vibration plugins that failed to fire on budget OEM partitions, re-routing tactile cues to universally supported Android core constants.
- **Branding Architecture**: Secured global product identity by rendering multi-density Android icons (`mdpi` through `xxxhdpi`).

---

## 🛠️ System Architecture

```mermaid
graph LR
    A["📱 App (Flutter)"] -- "JSON State" --> B["🔥 Firebase RTDB"]
    B -- "Wi-Fi Polling" --> C["🛰️ ESP32 / ESP8266 Hub"]
    C -- "PWM Out" --> D["💡 WS2812B Strip"]
    
    style A fill:#00F0FF,stroke:#000,stroke-width:2px,color:#000
    style B fill:#FF9500,stroke:#000,stroke-width:2px,color:#000
    style C fill:#FF2D55,stroke:#000,stroke-width:2px,color:#000
    style D fill:#AF52DE,stroke:#000,stroke-width:2px,color:#000
```

---

## 🚀 Installation
1.  **Clone Source**: `git clone https://github.com/kiran-embedded/aurora-pixel-controller.git`
2.  **Initialize**: Run `flutter pub get`
3.  **Config Database**: Integrate your own `firebase_options.dart`.
4.  **Hardware Deploy**: Access the Firmware Centre in the app, paste your WiFi/DB identifiers into the code, and flash your ESP.

---

## 👨‍💻 Engineering

Maintained by **[kiran-embedded](https://github.com/kiran-embedded)**

## 📄 License
MIT License. See `LICENSE` for more information.
