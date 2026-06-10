---
title: "Display Service"
description: "Use the thread‑safe display service to draw to the 128×64 SSD1306 OLED with U8G2"
---

## Overview

The display service is a global, thread‑safe wrapper around the U8G2 driver for a 128×64 SSD1306 OLED. You use it to render text and graphics from any task without flicker or tearing. A FreeRTOS mutex guarantees exclusive access while you draw; helper functions handle region clearing, partial refresh, clipping, and text caching.

!!! info
    This page documents the firmware‑level developer API used across our devices. For user‑facing display behavior (for example, hiding remaining time or device state screens), see the related pages at the end.

## Prerequisites

- ESP32 with hardware I2C available
- U8G2 library integrated in your firmware build
- FreeRTOS (for the display mutex)
- Pins configured for SDA/SCL in your board’s `Pins.h`

## Hardware configuration

| Property | Value |
|---|---|
| Display | SSD1306 OLED |
| Resolution | 128×64 pixels |
| Interface | I2C (hardware) |
| Rotation | U8G2_R0 (0°) |
| I2C address | 0x3C |
| Contrast | 255 (max) |

!!! note
    Some U8G2 constructors expect the 8‑bit I2C address. If so, pass `0x3C << 1`. Verify this matches your constructor signature.

## Layout model

The screen is treated as a grid of 8×8‑pixel cells:

- Grid: 8 rows × 16 columns
- Origin: (0,0) at the top‑left
- Cell size: 8×8 pixels

### Regions

??? note "Header (row 0)"
    - Cells 0–12: Header text (13 cells = 104 px)
    - Cells 13–15: State icons (3 cells = 24 px)

??? note "Page area (rows 1–6)"
    - 6 rows tall (48 px)
    - 16 cells wide (128 px)
    - All main content should render here

??? note "Footer (row 7)"
    - Cells 0–14: Footer text (15 cells = 120 px)
    - Cell 15: Timeout indicator (1 cell = 8 px)
!!! tip
    U8G2 text APIs use the baseline for `y`. For 8‑pixel‑tall fonts, start the first text line at `y = 8`, then add the font’s ascent/line height for subsequent lines.

## Thread safety

The display service exposes a FreeRTOS mutex. Always lock before drawing and unlock when done.

```cpp
#pragma once
#include <freertos/FreeRTOS.h>
#include <freertos/semphr.h>

extern SemaphoreHandle_t displayMutex;
```

!!! warning
    If you fail to release the mutex, all other tasks that need the display will block. Always pair a successful `xSemaphoreTake` with `xSemaphoreGive` in a `finally`‑style path.

### Basic usage pattern

```cpp
// Acquire, draw, refresh affected region(s), release
if (xSemaphoreTake(displayMutex, portMAX_DELAY) == pdTRUE) {
  // ... drawing commands, e.g.:
  display.drawStr(x, y, "HELLO WORLD");

  // Call an appropriate refresh helper (see below)
  refreshPage();

  xSemaphoreGive(displayMutex);
}
```

## Initialization

Call `initDisplay()` once at startup.

```cpp
#pragma once
void initDisplay();
```

### Step 1: Create resources and configure the panel

`initDisplay()` creates the display mutex, initializes the U8G2 display instance, sets addressing/rotation/contrast, and clears the buffer.

!!! success
    After initialization, the screen should be blank and backlit, and `displayMutex` must be non‑null.

### Step 2: Verify drawing

Render a single line of text in the page area.

```cpp
if (xSemaphoreTake(displayMutex, portMAX_DELAY) == pdTRUE) {
  clearPage();
  display.setFont(u8g2_font_spleen5x8_mu);
  display.drawStr(0, 16, "SANITY PASS");
  refreshPage();
  xSemaphoreGive(displayMutex);
}
```

## Clearing helpers

Efficiently clear only what you plan to redraw. All helpers use an internal `updateDisplayArea()` to perform a partial refresh of the affected region.

| Function | Description | Region cleared |
|---|---|---|
| `clearHeader()` | Clears header text only | Row 0, cells 0–12 |
| `clearIcons()` | Clears icon area only | Row 0, cells 13–15 |
| `clearFooter()` | Clears footer text only | Row 7, cells 0–14 |
| `clearTimeout()` | Clears timeout indicator | Row 7, cell 15 |
| `clearPage(includeFooter=false, includeHeader=false)` | Clears page area; optional header/footer | Rows 1–6 (plus header/footer when requested) |

```cpp
void clearHeader();
void clearIcons();
void clearFooter();
void clearTimeout();
void clearPage(bool includeFooter = false, bool includeHeader = false);
```

!!! note
    `clearPage()` sets a clipping window to keep content from spilling into the header or footer.

## Refresh helpers

Call a refresh helper after you modify a region. These perform minimal updates to the display.

| Function | Description | Region updated |
|---|---|---|
| `refreshHeader()` | Pushes header text | Row 0, cells 0–12 |
| `refreshIcons()` | Pushes icon area | Row 0, cells 13–15 |
| `refreshFooter()` | Pushes footer text | Row 7, cells 0–14 |
| `refreshTimeout()` | Pushes timeout indicator | Row 7, cell 15 |
| `refreshPage(includeFooter=false, includeHeader=false)` | Pushes main content; optional header/footer | Rows 1–6 (plus header/footer when requested) |

```cpp
void refreshHeader();
void refreshIcons();
void refreshFooter();
void refreshTimeout();
void refreshPage(bool includeFooter = false, bool includeHeader = false);
```

## Content helpers

### `setHeader()`

Sets the header text. The service uppercases and caches the last value to avoid redundant redraws.

```cpp
void setHeader(String &text);
```

!!! tip
    If you call `setHeader()` with the same value, the service skips both drawing and refresh.

### `setFooter()`

Sets left‑ and right‑aligned footer text. Both are uppercased and cached.

```cpp
void setFooter(String &left, String &right);
```

- Left string aligns to the left edge of the footer region
- Right string aligns to the right edge of the footer region

### `drawWrappedText()`

Draw text with automatic word wrapping and optional center alignment.

```cpp
int drawWrappedText(int x, int y, const String &text, bool center = false);
```

- **`x`** — `int`, *required*

Starting x‑coordinate in pixels.
- **`y`** — `int`, *required*

Starting baseline y‑coordinate in pixels.
- **`text`** — `String`, *required*

Text to render. Supports literal `\n` for line breaks.
- **`center`** — `bool`, *default: `false`*

Center each wrapped line within the page area when `true`.

- **`return`** — `int`, *required*

Number of lines drawn.

## Common patterns

### Draw a complete screen

```cpp
if (xSemaphoreTake(displayMutex, portMAX_DELAY) == pdTRUE) {
  clearPage();
  display.setFont(u8g2_font_spleen5x8_mu);
  display.drawStr(0, 16, "MAIN CONTENT");
  refreshPage();
  xSemaphoreGive(displayMutex);
}
```

!!! success
    This pattern clears only the page area, draws new content, and performs a partial refresh for speed.

### Update the header only

```cpp
if (xSemaphoreTake(displayMutex, portMAX_DELAY) == pdTRUE) {
  String headerText = "NEW HEADER"; // case‑insensitive; will be uppercased
  setHeader(headerText);
  // setHeader internally decides whether a refresh is required
  xSemaphoreGive(displayMutex);
}
```

### Draw wrapped, centered text

```cpp
if (xSemaphoreTake(displayMutex, portMAX_DELAY) == pdTRUE) {
  clearPage();
  int lines = drawWrappedText(0, 16, "Long text that will wrap", /*center=*/true);
  (void)lines; // optionally use the line count
  refreshPage();
  xSemaphoreGive(displayMutex);
}
```

## Drawing guidelines

### Step 3: Lock the mutex for every drawing sequence

Wrap drawing and refresh in a critical section guarded by `displayMutex`.

```cpp
if (xSemaphoreTake(displayMutex, portMAX_DELAY) == pdTRUE) {
  // Drawing
  xSemaphoreGive(displayMutex);
}
```

### Step 4: Prefer region helpers over full clears

Minimize bus traffic and flicker by using `clear*()` and `refresh*()` helpers.

```cpp
clearPage();
display.drawStr(0, 16, "Content");
refreshPage();
```

```cpp
// Full‑buffer clears cost time and cause visible flicker
// display.clearBuffer();
```

### Step 5: Respect boundaries

Keep content within:

- Header: row 0, cells 0–12
- Icons: row 0, cells 13–15
- Page: rows 1–6
- Footer: row 7, cells 0–14; timeout at cell 15

Use `clearPage()` to clip page content away from header/footer.

### Step 6: Choose readable fonts

| Area | Recommended font |
|---|---|
| Header/Footer | `u8g2_font_spleen5x8_mu` |
| Page content | Pick for readability; adjust line spacing by font metrics |

!!! note
    Consider the font’s ascent and total line height when computing `y` offsets between lines.

## Performance considerations

- Partial updates only redraw the regions you changed
- Text caching avoids unnecessary draw/refresh cycles
- Clipping keeps drawing inside the intended region and reduces overdraw
- Mutex‑guarded sequences prevent mid‑frame tearing across tasks

## Troubleshooting

??? note "Nothing appears after init"
    - Confirm `initDisplay()` is called once
    - Verify the I2C address (try `0x3C` and `0x3C << 1` depending on constructor)
    - Ensure SDA/SCL match your board’s `Pins.h`

??? note "Display updates are slow or flicker"
    - Use region clears/refreshes instead of full‑buffer clears
    - Batch your drawing into one mutex‑protected block
    - Avoid unnecessary font changes between draw calls

??? note "Text appears misaligned vertically"
    - Remember U8G2 uses a baseline for `y`
    - Start the first 8‑px font line at `y = 8` or compute from font ascent

??? note "Deadlock or blocked tasks"
    - Always release the mutex in error paths
    - Prefer RAII‑style wrappers or `goto cleanup` patterns
## Dependencies

| Dependency | Purpose |
|---|---|
| U8G2 | SSD1306 rendering and font handling |
| FreeRTOS | Mutex for thread safety |
| ESP32 HAL | Hardware I2C interface |
| `Pins.h` | Board pin definitions for SDA/SCL |

## Related pages

- **[Hide display time (user feature)](/chastity-lockbox/using-your-lockbox/hiding-the-remaining-time)** — How the UI hides remaining time across device, dashboard, and notifications.

- **[Emergency unlock display flow](/chastity-lockbox/technical-documentation/device-states/emergency-unlock)** — Screen flow and consequences of triggering Emergency Unlock on device.

- **[Device support matrix](/research-and-desire-remote/device-support)** — Supported and planned devices across 2025–2026.
