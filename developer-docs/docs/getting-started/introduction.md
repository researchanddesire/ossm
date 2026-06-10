---
title: "Introduction"
description: ""
---

# Firmware Overview

The Open Source Sex Machine (OSSM) firmware is an ESP32-based control system that manages motion, user input, and communication for your device. This guide walks you through the project architecture and helps you set up your development environment.

## Core Technologies

The OSSM firmware relies on four key technologies that work together to deliver responsive, reliable motion control.

??? note "State Machine - Boost SML"
    [Boost SML](https://boost-ext.github.io/sml/) (State Machine Language) is a header-only C++ library that provides a domain-specific language for defining state machines.

    **Why we use it:**
    - Compile-time state machine verification catches errors before runtime
    - Zero runtime overhead compared to manual switch/case implementations
    - Clean, declarative syntax makes complex state transitions readable
    - Handles transitions between states like idle, running, error, and homing

    The state machine governs the device's operational modes, ensuring safe transitions and predictable behavior. For details, see the [State Machine Architecture](/ossm/architecture/state-machine) documentation.

??? note "Display - U8G2 Library"
    [U8G2](https://github.com/olikraus/u8g2) is a monochrome graphics library optimized for embedded systems and OLED displays.

    **Why we use it:**
    - Supports a wide range of display controllers including SSD1306 and SH1106
    - Minimal memory footprint suitable for ESP32's constrained RAM
    - Built-in font rendering with multiple sizes and styles
    - Hardware-accelerated drawing for smooth UI updates

    U8G2 renders the on-device interface including speed, depth, pattern selection, and system status.

??? note "Task Management - FreeRTOS"
    [FreeRTOS](https://www.freertos.org/) is a real-time operating system kernel that enables multitasking on embedded devices.

    **Why we use it:**
    - Runs multiple concurrent tasks (motion control, display updates, input handling)
    - Priority-based scheduling ensures time-critical motion tasks execute reliably
    - Inter-task communication via queues and semaphores
    - Integrated into the ESP32 Arduino framework by default

    FreeRTOS allows the firmware to simultaneously process user input, update the display, and maintain precise motor timing.

??? note "Motion Control - StrokeEngine"
    [StrokeEngine](https://github.com/theelims/StrokeEngine) is a motion pattern library created by theelims, modified for OSSM-specific requirements.

    **Why we use it:**
    - Generates smooth, customizable motion patterns with configurable speed and depth
    - Supports multiple pattern types (constant, random, oscillating, and more)
    - Handles acceleration ramping for motor protection
    - Provides real-time parameter adjustment without motion interruption

    StrokeEngine translates user settings into precise motor commands, enabling the variety of motion patterns available in OSSM.
## Getting Started

Set up your development environment by following these steps.

### Prerequisites

Before you begin, ensure you have:
- A computer running Windows, macOS, or Linux
- Git installed on your system
- An internet connection to download dependencies

### Step 1: Install VS Code and PlatformIO

Download and install [Visual Studio Code](https://code.visualstudio.com/), then add the PlatformIO extension.

1. Open VS Code
2. Navigate to the Extensions panel (Ctrl+Shift+X / Cmd+Shift+X)
3. Search for "PlatformIO IDE"
4. Click **Install** and wait for the installation to complete
5. Restart VS Code when prompted

!!! tip
    For detailed PlatformIO setup instructions, see our [PlatformIO setup guide](/ossm/getting-started/PlatformIO).

### Step 2: Clone the repository

Open a terminal and clone the OSSM repository to your local machine.

**HTTPS**

```bash
git clone https://github.com/KinkyMakers/OSSM-hardware.git
cd OSSM-hardware/Software
```

**SSH**

```bash
git clone git@github.com:KinkyMakers/OSSM-hardware.git
cd OSSM-hardware/Software
```

**GitHub CLI**

```bash
gh repo clone KinkyMakers/OSSM-hardware
cd OSSM-hardware/Software
```

!!! note
    If you plan to contribute changes, fork the repository first, then clone your fork instead.

### Step 3: Open the project in VS Code

Launch the project using PlatformIO.

1. Open VS Code
2. Select **File > Open Folder**
3. Navigate to the `OSSM-hardware/Software` directory you just cloned
4. Click **Select Folder** (or **Open** on macOS)

PlatformIO automatically detects the `platformio.ini` file and configures the project.

!!! success
    You should see the PlatformIO toolbar appear at the bottom of VS Code with build, upload, and monitor buttons.

### Step 4: Build and upload the firmware

Compile the project and flash it to your ESP32.

1. Connect your ESP32 board via USB
2. Click the **PlatformIO: Build** button (checkmark icon) to compile
3. Once the build succeeds, click **PlatformIO: Upload** (arrow icon) to flash the firmware

!!! warning
    Ensure you select the correct COM port if you have multiple serial devices connected. You can configure this in `platformio.ini` or through the PlatformIO device monitor.

## Next Steps

- **[Operating Modes](/ossm/getting-started/operating-modes)** — Learn about Simple Penetration, Stroke Engine, and Streaming modes.

- **[Safety Features](/ossm/getting-started/safety-features)** — Understand preflight checks, disconnect safety, and emergency stop.

- **[Configuration](/ossm/getting-started/configuration)** — Customize motion parameters, pins, and user preferences.

- **[WiFi and Updates](/ossm/getting-started/wifi-and-updates)** — Configure WiFi and install over-the-air firmware updates.

- **[Folder Structure](/ossm/architecture/folder-structure)** — Understand the source code organization and modular architecture.

- **[PlatformIO Setup](/ossm/getting-started/PlatformIO)** — Set up your development environment for firmware modifications.
