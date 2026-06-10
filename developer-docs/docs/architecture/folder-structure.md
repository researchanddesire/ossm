---
title: "Folder Structure"
description: "Understanding the OSSM firmware source code organization"
---

# Folder Structure

The OSSM firmware follows a modular, feature-based architecture. Each feature lives in its own namespace folder, making the codebase easier to navigate and maintain.

!!! info
    Browse the source code on GitHub: [Software/src/](https://github.com/KinkyMakers/OSSM-hardware/tree/main/Software/src)

## Overview

- **Software/**
  - **include/**
    - **boost/**
      - sml.hpp
  - **lib/**
    - **StrokeEngine/**
  - **src/**
    - main.cpp
    - **ossm/**
    - **services/**
    - **components/**
    - **constants/**
    - **structs/**
    - **utils/**
    - **extensions/**
  - **test/**
  - platformio.ini

| Folder | Purpose |
|--------|---------|
| `include/boost/` | Header-only libraries (Boost.SML state machine) |
| `lib/StrokeEngine/` | Motion pattern library (modified) |
| `src/` | Main source code |
| `test/` | Unit tests |

## Design Philosophy

The firmware uses a **feature-based organization** where related code lives together:

- **Namespaces over classes** - Features are organized as namespace functions rather than class methods
- **Co-located files** - Each feature's header, implementation, and related code live in the same folder
- **Global state structs** - Shared state is managed through dedicated state structs rather than class members
- **Stateless modules** - Feature functions operate on global state, making them easier to test and reason about

!!! note
    The `OSSM` class in `ossm/OSSM.h` is retained for backward compatibility with BLE command handling. New features should use stateless namespace functions.

## Core Application (`src/ossm/`)

The `ossm/` folder contains the core application logic, organized by feature.

- **ossm/**
  - Events.h
  - OSSM.h
  - OSSM.cpp
  - **state/**
  - **pages/**
  - **homing/**
  - **menu/**
  - **simple_penetration/**
  - **stroke_engine/**
  - **pattern_controls/**
  - **play_controls/**

| Folder | Purpose |
|--------|---------|
| `state/` | State machine architecture |
| `pages/` | UI screens |
| `homing/` | Homing sequence |
| `menu/` | Menu navigation |
| `simple_penetration/` | Simple Penetration mode |
| `stroke_engine/` | Stroke Engine mode |
| `pattern_controls/` | Pattern selection UI |
| `play_controls/` | Play/pause/speed controls |

### State Machine (`ossm/state/`)

The state machine components are separated for clarity and testability.

| File | Purpose |
|------|---------|
| [`machine.h`](https://github.com/KinkyMakers/OSSM-hardware/blob/main/Software/src/ossm/state/machine.h) | Transition table definition using Boost.SML |
| [`actions.h`](https://github.com/KinkyMakers/OSSM-hardware/blob/main/Software/src/ossm/state/actions.h) / `actions.cpp` | State transition actions (display updates, motor control) |
| [`guards.h`](https://github.com/KinkyMakers/OSSM-hardware/blob/main/Software/src/ossm/state/guards.h) / `guards.cpp` | Conditional checks for transitions |
| `state.h` / `state.cpp` | State machine initialization and global instance |

**State structs** manage different aspects of the application:

| File | Purpose |
|------|---------|
| `session.h` | Current session (start time, stroke count, distance) |
| `settings.h` | User settings (speed, stroke, sensation, depth, pattern) |
| `calibration.h` | Homing state (sensor offset, stroke steps, homed status) |
| `motion.h` | Motion targets (position, velocity, time) |
| `menu.h` | Current menu selection |
| `ble.h` | Bluetooth connection state |
| `error.h` | Error messages |

!!! tip
    For details on how the state machine works, see [State Machine Architecture](/ossm/architecture/state-machine).

### UI Pages (`ossm/pages/`)

Each screen in the user interface has its own module.

| Module | Description |
|--------|-------------|
| `hello.h` | Boot splash screen with animated logos |
| `preflight.h` | "Reduce speed to start" safety check screen |
| `error.h` | Error display with help option |
| `update.h` | OTA update screens (checking, updating, no update) |
| `wifi.h` | WiFi configuration portal |
| `help.h` | Help and support information |

### Operating Modes

Each operating mode is a self-contained module with its motion control logic.

| Module | Description |
|--------|-------------|
| `simple_penetration/` | Basic back-and-forth motion at controlled speed |
| `stroke_engine/` | Complex patterns using the StrokeEngine library |

### Control UIs

| Module | Description |
|--------|-------------|
| `menu/` | Main menu navigation and rendering |
| `pattern_controls/` | Pattern selection interface for Stroke Engine mode |
| `play_controls/` | Speed, stroke, depth, and sensation controls |

### Feature Modules

| Module | Description |
|--------|-------------|
| `homing/` | Homing sequence (forward scan, backward scan, calibration) |

## Hardware Services (`src/services/`)

The `services/` folder provides hardware abstraction layers.

- **services/**
  - stepper.h
  - stepper.cpp
  - display.h
  - display.cpp
  - encoder.h
  - encoder.cpp
  - led.h
  - led.cpp
  - board.h
  - board.cpp
  - tasks.h
  - tasks.cpp
  - wm.h
  - wm.cpp
  - **communication/**
    - nimble.h
    - nimble.cpp
    - queue.h
    - queue.cpp
    - command.hpp
    - state.hpp
    - patterns.hpp
    - gpio.hpp
    - wifi.hpp
    - config.hpp

| File | Purpose |
|------|---------|
| `stepper.h/.cpp` | Motor control (FastAccelStepper) |
| `display.h/.cpp` | OLED display (U8g2) |
| `encoder.h/.cpp` | Rotary encoder input |
| `led.h/.cpp` | RGB LED status indication |
| `board.h/.cpp` | Board initialization |
| `tasks.h/.cpp` | FreeRTOS task management |
| `wm.h/.cpp` | WiFi Manager |
| `communication/` | BLE and WiFi communication |

!!! info
    For BLE protocol details, see [BLE Communication](/ossm/communication/ble).

## Constants (`src/constants/`)

Configuration values and enums are centralized in the `constants/` folder.

- **constants/**
  - Config.h
  - Pins.h
  - Menu.h
  - Version.h
  - UserConfig.h
  - Images.h
  - LogTags.h
  - **copy/**
    - en-us.h
    - fr.h

| File | Purpose |
|------|---------|
| `Config.h` | System configuration (speeds, limits, timeouts) |
| `Pins.h` | GPIO pin definitions |
| `Menu.h` | Menu option enum |
| `Version.h` | Firmware version information |
| `UserConfig.h` | User-configurable settings |
| `Images.h` | Display bitmap assets |
| `LogTags.h` | ESP-IDF logging tags |
| `copy/` | Localized strings |

!!! tip
    For configuration options, see [Configuration](/ossm/getting-started/configuration).

## Utilities (`src/utils/`)

Helper functions and classes used throughout the codebase.

- **utils/**
  - StateLogger.h
  - RecursiveMutex.h
  - StrokeEngineHelper.h
  - format.h
  - analog.h
  - update.h
  - ble.h

| File | Purpose |
|------|---------|
| `StateLogger.h` | Logs state machine transitions for debugging |
| `RecursiveMutex.h` | Thread-safe mutex wrapper for ESP32 |
| `StrokeEngineHelper.h` | StrokeEngine integration utilities |
| `format.h` | String formatting helpers |
| `analog.h` | Analog input averaging and processing |
| `update.h` | OTA update utilities |
| `ble.h` | BLE helper functions |

## Data Structures (`src/structs/`)

Shared data types used across modules.

- **structs/**
  - SettingPercents.h
  - LanguageStruct.h
  - Points.h

| File | Purpose |
|------|---------|
| `SettingPercents.h` | User settings as percentages (0-100) |
| `LanguageStruct.h` | Language configuration |
| `Points.h` | Coordinate and point structures |

## Libraries

### Boost.SML (`include/boost/sml.hpp`)

[Boost.SML](https://boost-ext.github.io/sml/) is a header-only state machine library. It's included directly in the project for version stability.

### StrokeEngine (`lib/StrokeEngine/`)

A modified version of [theelims/StrokeEngine](https://github.com/theelims/StrokeEngine) that generates motion patterns. The library is vendored and customized for OSSM-specific requirements.

## Build Configuration

The `platformio.ini` file defines build environments:

| Environment | Purpose |
|-------------|---------|
| `development` | Local development with debug logging |
| `staging` | Pre-release testing |
| `production` | Release builds with optimizations |
| `test` | Unit test configuration |

## Further Reading

- **[State Machine](/ossm/architecture/state-machine)** — Deep dive into the Boost.SML state machine architecture.

- **[Configuration](/ossm/getting-started/configuration)** — Customize motion parameters, pins, and settings.

- **[Display Service](/ossm/getting-started/display)** — Learn about the thread-safe display API.

- **[BLE Communication](/ossm/communication/ble)** — Understand the Bluetooth protocol and characteristics.
