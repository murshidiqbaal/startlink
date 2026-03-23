# StartLink Anti-Gravity UI System

This project contains a new **Anti-Gravity Design System** located in `lib/core/presentation/widgets/anti_gravity/` and `lib/features/design_showcase/`.

## Features Created

### 1. Physics-Based Levitation
- **Components**: `FloatingWidget`, `AntiGravityCard`, `LevitatingListTile`.
- **Behavior**: Elements float gently on a sine-wave curve (`Curves.easeInOutSine`), simulating zero-gravity suspension.
- **Customization**: Adjust floating intensity and duration for variable drifting speeds.

### 2. 3D Interaction
- **Components**: `TiltableWidget` (integrated into `AntiGravityCard`).
- **Behavior**: Cards tilt in 3D space based on mouse hover position or touch input, imitating physical interaction in a weightless environment.
- **Perspective**: Proper Matrix4 perspective transforms applied.

### 3. Glassmorphism 2.0
- **Components**: `GlassCard`, `FloatingNavBar`.
- **Aesthetics**: High-quality frosted glass blur (`BackdropFilter`) with subtle white/gradient borders and soft shadows.
- **Theme**: Designed for dark/deep space backgrounds.

### 4. Neon Dynamics
- **Components**: `NeonButton`, `HoverActionButton`.
- **Behavior**: Elements glow and scale up when hovered/pressed.
- **Visuals**: Uses cyan/teal accent colors typical of futuristic HUDs.

### 5. Deep Space Environment
- **Components**: `SpaceBackground`.
- **Visuals**: Procedurally generated starfield overlaid on a deep nebula gradient.

## How to Test

1. **Run the App**:
   ```bash
   flutter run
   ```

2. **Access the Showcase**:
   - On the initial **Login Screen**, search for the new text button at the bottom: **"View Anti-Gravity System"** (with a rocket icon).
   - Tap it to launch the `AntiGravityShowcasePage`.

3. **Interact**:
   - **Scroll**: See the parallax starfield.
   - **Hover/Touch Cards**: Watch them tilt in 3D.
   - **Hover Buttons**: See the neon glow and scale effect.
   - **Observe**: Notice the gentle, independent floating motion of different modules.
