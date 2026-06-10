---
title: "Patterns"
description: "Learn how patterns create variety in StrokeEngine motion by generating trapezoidal motion parameters"
---

Patterns are what set StrokeEngine apart from other motion systems. Each pattern is a small program that generates the next set of trapezoidal motion parameters: target position, speed, and acceleration.

## Available patterns

!!! note
    The OSSM firmware exposes **7 patterns** (indices 0-6): Simple Stroke, Teasing or Pounding, Robo Stroke, Half'n'Half, Deeper, Stop'n'Go, and Insist. Jack Hammer and Stroke Nibbler are available in the StrokeEngine library but are not currently implemented in the OSSM firmware.

### OSSM patterns (0-6)

??? note "Simple Stroke"
    Creates a trapezoidal stroke profile with 1/3 acceleration, 1/3 coasting, and 1/3 deceleration.

    !!! note
    The sensation parameter has no effect on this pattern.

??? note "Teasing or Pounding"
    Adjusts the speed ratio between in and out movements using the sensation value:

    - **Positive sensation (> 0)**: Makes the in-move faster (up to 5x) for a hard pounding sensation
    - **Negative sensation (< 0)**: Makes the out-move faster for a more teasing sensation

    The overall stroke time remains constant and depends only on the global speed parameter.

??? note "Robo Stroke"
    Controls stroke acceleration through the sensation value:

    - **Positive values**: Increase acceleration until motion becomes constant speed (feels robotic)
    - **Neutral (0)**: Equal to Simple Stroke (1/3, 1/3, 1/3 profile)
    - **Negative values**: Reduce acceleration into a triangle profile

??? note "Half'n'Half"
    Similar to Teasing or Pounding, but every second stroke reaches only half the depth.

    - **Positive sensation (> 0)**: Makes the in-move faster (up to 5x) for a hard pounding sensation
    - **Negative sensation (< 0)**: Makes the out-move faster for a more teasing sensation

    The stroke time remains the same for all strokes, including half-depth ones.

??? note "Deeper"
    Gradually ramps up the insertion depth with each stroke until reaching maximum, then resets and restarts.

    The sensation value controls how many strokes complete one ramp cycle.

??? note "Stop'n'Go"
    Inserts pauses between a series of strokes. The number of strokes ramps from 1 to 5 and back.

    The sensation value controls the pause duration between stroke series.

??? note "Insist"
    Reduces the effective stroke length while keeping stroke speed constant. This creates vibrational patterns at higher sensation values.

    - **Positive sensation**: Strokes wander towards the front
    - **Negative sensation**: Strokes wander towards the back
### Library-only patterns

These patterns are available in the StrokeEngine library but are **not currently implemented** in the OSSM firmware. They're documented here for developers building custom firmware or other StrokeEngine-based projects.

??? note "Jack Hammer"
    Creates a vibrational pattern that vibrates on the way in and pulls out smoothly in one motion.

    The sensation value sets the vibration amplitude from 3mm to 25mm.

??? note "Stroke Nibbler"
    Adds a vibrational overlay to strokes, vibrating on both the way in and out.

    The sensation value sets the vibration amplitude from 3mm to 25mm.
## Creating custom patterns

You can create your own patterns by subclassing the `Pattern` class in the header-only [pattern.h](https://github.com/theelims/StrokeEngine/blob/main/src/pattern.h) file.

### Step 1: Subclass the Pattern class

Create a new class that extends `Pattern`. See `SimpleStroke` for a minimal implementation:

```cpp
class SimpleStroke : public Pattern {
    public:
        SimpleStroke(const char *str) : Pattern(str) {} 
```

The constructor stores the pattern's display name string.

### Step 2: Override set-functions if needed

Reimplement set-functions when you need custom calculations:

```cpp
void setTimeOfStroke(float speed = 0) { 
    // In & Out have same time, so divide by 2
    _timeOfStroke = 0.5 * speed; 
}   
```

### Step 3: Implement the nextTarget function

This is the core function that StrokeEngine calls after each stroke to get the next motion parameters.

```cpp
motionParameter nextTarget(unsigned int index) {
    // Maximum speed of the trapezoidal motion 
    _nextMove.speed = int(1.5 * _stroke/_timeOfStroke);

    // Acceleration to meet the profile
    _nextMove.acceleration = int(3.0 * _nextMove.speed/_timeOfStroke);

    // Odd stroke moves out    
    if (index % 2) {
        _nextMove.stroke = _depth - _stroke;

    // Even stroke moves in
    } else {
        _nextMove.stroke = _depth;
    }

    _index = index;
    return _nextMove;
}
```

!!! info
    The `index` parameter starts at 0 when the pattern is first called and increments by 1 after each stroke. Use this to create patterns that vary over time.

### Step 4: Add debugging output

Encapsulate `Serial.print()` statements with preprocessor directives so they can be toggled:

```cpp
#ifdef DEBUG_PATTERN
    Serial.println("TimeOfInStroke: " + String(_timeOfInStroke));
    Serial.println("TimeOfOutStroke: " + String(_timeOfOutStroke));
#endif
```

### Step 5: Register the pattern

Add an instance of your pattern class to the `patternTable[]` array at the bottom of the file:

```cpp
static Pattern *patternTable[] = { 
    new SimpleStroke("Simple Stroke"),
    new TeasingPounding("Teasing or Pounding"),
    new YourNewPattern("Your Pattern Name")  // Add your pattern here
};
```

## Pattern requirements

### Depth and stroke boundaries

!!! warning
    Patterns must return stroke positions within the interval `[0, stroke]`. StrokeEngine monitors all returned `motionParameter` values and truncates positions outside `[depth - stroke, depth]` to prevent injuries.

Depth and stroke values set in StrokeEngine are axiomatic boundaries. Your pattern defines the envelope it uses within these limits. The same safety constraints apply to speed via `timeOfStroke`.

### Graceful parameter changes

Your pattern must handle parameter changes gracefully. When depth or stroke values change mid-operation, the pattern must:

- Stay within the interval `[depth, depth - stroke]` at all times
- Execute transfer moves at the same speed as regular moves
- Avoid erratic behavior

!!! tip
    Test your pattern thoroughly against parameter changes, especially depth and stroke modifications that may require additional stroke distances.

### Using the index parameter

The `index` parameter provides important state information:

- **Resets to 0** when `StrokeEngine.setPattern(int)` or `StrokeEngine.startMotion()` is called
- **Increments** after each successfully executed move
- **Comparing `index == _index`** determines if this is an update to the current stroke rather than a new stroke

Store the last index in `_index` before returning to track stroke state in time-varying patterns.

### Implementing pauses

Patterns can insert pauses between strokes. When the target position is reached, StrokeEngine polls for new motion commands every few milliseconds.

To implement a pause, return `_nextMove.skip = true` from your `nextTarget()` function. StrokeEngine will poll again later instead of starting a new motion.

The `Pattern` base class provides three helper functions for pause management:

| Function | Description |
|----------|-------------|
| `_startDelay()` | Starts the delay timer |
| `_updateDelay(int delayInMillis)` | Sets the pause duration in milliseconds (can be updated anytime) |
| `_isStillDelayed()` | Returns `true` if the scheduled time hasn't been reached |

!!! note
    If a stroke becomes overdue, it executes immediately. See the Stop'n'Go pattern for an example implementation.

## Contributing patterns

After thoroughly testing your pattern, submit a pull request with your updated [pattern.h](https://github.com/theelims/StrokeEngine/blob/main/src/pattern.h) file.
