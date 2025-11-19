# Breaker Braker 🚛💥

**18 Wheels of Fury**

A mobile trucking chaos game where you drive semi-trucks and DESTROY everything in your path to earn Damage Points (DP).

---

## 🎮 Game Overview

**Genre**: Arcade Destruction / Endless Runner
**Platform**: Android / iOS (Flutter)
**Status**: Active Development

### Core Gameplay Loop
1. **Drive** your semi-truck down the highway
2. **Destroy** cars, signs, barriers, and hit bridges (THE signature move!)
3. **Earn DP** (Damage Points) for each collision
4. **Repair** your truck while the app is closed (idle mechanic)
5. **Upgrade** to better trucks and trailers
6. **Progress** through career stages

### Career Progression
- **Company Driver** (Starter) - Speed limited to 65 mph, basic truck
- **Lease Operator** (Mid) - Speed limited to 75 mph, better equipment
- **Owner Operator** (Max) - No speed limit, chrome everything!

---

## ✨ Implemented Features (v0.1)

### ✅ Core Gameplay
- **Truck physics** with momentum and drift
- **Trailer physics** with spring-based sway
- **Traffic cars** (4 types: sedan, SUV, sports, minivan)
- **Collision detection** and destruction
- **Infinite scrolling road** with 3 lanes

### ✅ Visual Effects
- **Enhanced truck rendering** (20% bigger, tons of chrome!)
  - Manufacturer-specific grilles (Kenworth, Peterbilt, International, Volvo, Freightliner)
  - Long extended hoods on classic trucks
  - Massive chrome bumpers with highlights
  - TALL chrome exhaust stacks
  - Large wraparound windshields
  - West Coast mirrors

- **Particle system** with 4 types:
  - ✨ Sparks (yellow/orange with motion trails)
  - 🪨 Debris (dark chunks with gravity)
  - 💨 Smoke (expanding puffs)
  - 💎 Glass (shiny shards)

- **Screen shake** on impact (intensity-based)

### ✅ Feedback Systems
- **Haptic feedback** (phone vibration on collisions)
  - Light tap for cars
  - Strong shake for bridges
  - Multi-stage patterns

- **HUD display**
  - Current speed
  - Damage Points
  - Career stage
  - Truck damage meter

---

## 🚧 Coming Soon

### Next Update (v0.2)
- [ ] Destructible environment (signs, barriers, cones)
- [ ] Low bridge obstacles (THE signature feature!)
- [ ] Progressive damage visuals (smoke, cracks, missing parts)

### Future Updates
- [ ] Sound effects and music
- [ ] Enhanced truck visuals (manufacturer-specific rendering for all trucks)
- [ ] Trailer visual variety
- [ ] ELD timer countdown
- [ ] Garage/customization screens
- [ ] Achievement popups
- [ ] Dispatcher harassment (calls/texts during gameplay)

---

## 🚀 Getting Started (Development)

### Prerequisites
- Flutter SDK 3.10 or higher
- Android Studio / VS Code with Flutter extensions
- Connected device or emulator

### Setup
```bash
# Navigate to project
cd break_brake

# Get dependencies
flutter pub get

# Run on connected device
flutter run

# Or run on Chrome (desktop controls)
flutter run -d chrome
```

### Controls
**Desktop (Testing)**:
- Arrow Keys or WASD: Steer left/right, brake
- Spacebar: Brake

**Mobile**:
- Tap left third of screen: Steer left
- Tap right third: Steer right
- Tap middle: Brake

---

## 📁 Project Structure

```
lib/
├── game/
│   └── breaker_braker_game.dart       # Main game loop
├── components/
│   ├── truck/
│   │   ├── truck_component.dart       # Player truck (ENHANCED!)
│   │   └── trailer_component.dart     # Trailer with spring physics
│   ├── obstacles/
│   │   ├── car_component.dart         # Traffic cars
│   │   └── traffic_spawner.dart       # Spawns cars
│   ├── effects/
│   │   ├── screen_shake.dart          # Camera shake
│   │   └── collision_particle.dart    # Particle explosions
│   └── ui/
│       └── game_hud.dart              # HUD overlay
├── models/
│   ├── truck_model.dart               # Truck data & templates
│   ├── trailer_model.dart             # Trailer data & templates
│   ├── damage_model.dart              # Component-based damage
│   └── player_model.dart              # Player progression & stats
├── providers/
│   └── game_state_provider.dart       # Global state
├── services/
│   └── haptic_service.dart            # Vibration/haptics
└── main.dart                          # App entry point
```

---

## 📝 Documentation

See `DEVELOPMENT_NOTES.md` for:
- Detailed implementation notes
- Session progress tracking
- TODO list with priorities
- Known issues and technical debt
- Architecture decisions
- Developer handoff notes

---

## 🎯 Development Status

**Current Version**: 0.1.0 (Foundation Complete)
**Last Updated**: 2025-11-18
**Compilation Status**: ✅ Clean (0 errors)

### Completed This Session:
✅ Haptic feedback system
✅ Traffic cars with collision detection
✅ Enhanced truck visuals (20% bigger, tons of chrome)
✅ Screen shake on impact
✅ Particle effects (sparks, debris, smoke, glass)

**Lines of Code Added**: 1,200+
**Files Created**: 3 new components
**Files Modified**: 5 core game files

---

## 🎨 Visual Style

### Design Goals
- **Arcade feel** with bright colors and exaggerated effects
- **Chrome everywhere** on trucks (show truck vibe)
- **Satisfying destruction** with screen shake + particles + haptics
- **Clean UI** with CB radio aesthetic

---

## 📊 Technical Stack

- **Framework**: Flutter 3.10+
- **Game Engine**: Flame 1.18+
- **State Management**: Provider
- **Persistence**: SharedPreferences

### Key Dependencies
```yaml
flame: ^1.18.0          # Game engine
provider: ^6.1.0        # State management
vibration: ^2.0.0       # Haptic feedback
shared_preferences: ^2.2.0  # Save data
```

---

**Status**: Active Development 🚧

*Keep on truckin'! 🚛*
