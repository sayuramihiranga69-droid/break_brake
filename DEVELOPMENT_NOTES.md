# Breaker Braker - Development Notes

## 📅 Last Updated: 2025-11-18

## 🎯 Project Overview
**Breaker Braker** is a mobile trucking chaos game for Android/iOS. Players drive semi-trucks and DESTROY everything in their path to earn Damage Points (DP). The game features a career progression system (Company Driver → Lease Operator → Owner Operator) and an idle repair mechanic.

**Core Gameplay Loop**: Drive → Destroy → Earn DP → Repair while idle → Upgrade → Repeat

---

## ✅ COMPLETED FEATURES (Session 1)

### 1. Haptic Feedback System ✨
**Location**: `lib/components/effects/screen_shake.dart`, `lib/services/haptic_service.dart`

**What it does**:
- Provides tactile feedback on collisions through phone vibration
- 4 intensity levels: light, medium, heavy, extreme
- Collision-specific patterns (car tap, barrier bump, bridge SHAKE)
- Multi-stage vibrations for bridge hits (initial impact + debris settling)
- Device capability detection (checks for vibrator and amplitude control)

**Key Implementation**:
```dart
// Light collision (20ms vibration)
HapticService.carCollision();

// Bridge hit (multi-stage pattern)
HapticService.bridgeHit(); // 150ms strong → pause → 100ms medium → pause → 50ms light

// Truck totaled (500ms descending rumble)
HapticService.vehicleTotaled();
```

---

### 2. Traffic Cars + Collision Detection 🚗
**Location**: `lib/components/obstacles/car_component.dart`, `lib/components/obstacles/traffic_spawner.dart`

**What it does**:
- Spawns AI-controlled traffic cars on the road
- 4 car types: sedan, SUV, sports, minivan
- Randomized colors for visual variety
- Dynamic spawn rate (faster spawning at higher speeds)
- Full collision detection with player truck
- Destruction with wreckage fade-out animation

**Key Features**:
- Cars spawn in 3 lanes (left, center, right)
- Speed varies ±50 mph from player speed
- Collision triggers: DP award, haptics, screen shake, particles
- Wreckage displays for 0.5 seconds before removal

**Integration**:
```dart
// In TruckComponent.onCollisionStart()
if (other is CarComponent && !other.isDestroyed) {
  other.destroy();
  game.handleCollision(obstacleType: 'four-wheeler', impactForce: currentSpeed * 0.5);
}
```

---

### 3. Enhanced Truck Visuals 🚛
**Location**: `lib/components/truck/truck_component.dart` (lines 160-530)

**What it does**:
- Dramatically improved truck rendering with manufacturer-specific details
- 20% bigger trucks (50x120 pixels vs original 40x100)
- Manufacturer-specific rendering (KW W900, Pete 379, International, Volvo, Freightliner)

**Visual Enhancements**:
- **Long extended hoods** on classic trucks (45% of truck length vs 25%)
- **Massive chrome bumpers** with multi-layer gradients and highlights
- **TALL chrome exhaust stacks** (35% of truck height with shiny caps)
- **Bigger chrome wheels** (8px radius with detailed 6-spoke rims)
- **Large wraparound windshields** with realistic glare effects
- **Power dome** on hood (raised center section)
- **West Coast mirrors** with arms and mirror glass
- **Sleeper windows** behind the cab
- **Manufacturer-specific grilles** (vertical bars for Pete/KW, horizontal for Freightliner, etc.)

**Current Implementation**:
- Kenworth W900 & Peterbilt 379: Full detailed rendering (classic long-hood style)
- International Lonestar: Uses classic rendering as placeholder (TODO: implement specific design)
- Volvo VNL: Uses classic rendering as placeholder (TODO: short nose, huge windshield)
- Freightliner Cascadia: Uses classic rendering as placeholder (TODO: modern aero design)

---

### 4. Screen Shake System 📳
**Location**: `lib/components/effects/screen_shake.dart`

**What it does**:
- Camera shake on impact for visceral feedback
- Intensity-based shaking (light, medium, heavy, extreme)
- Smooth sinusoidal oscillation with random direction
- Decaying shake over time (fades out naturally)

**Technical Details**:
```dart
// Light shake: 0.15s duration, 3px intensity, 35Hz frequency
// Extreme shake: 0.6s duration, 18px intensity, 20Hz frequency
// Truck totaled: 1.0s duration (custom override)

// Applied to camera in game update loop:
gameCamera.viewfinder.position = baseCameraPosition + shakeOffset;
```

**Integration**: Triggered in `handleCollision()` for every collision type

---

### 5. Particle Effects System 💥
**Location**: `lib/components/effects/collision_particle.dart`

**What it does**:
- Explosive visual feedback on collisions
- 4 particle types with unique rendering and physics

**Particle Types**:
1. **Sparks** ✨
   - Yellow/orange gradient
   - Motion blur trails
   - Fast-fading
   - No gravity

2. **Debris** 🪨
   - Dark gray/brown chunks
   - Rectangular with edge highlights
   - Affected by gravity
   - Tumbles with rotation

3. **Smoke** 💨
   - Gray expanding puffs
   - Grows over time (2x expansion)
   - Rises upward
   - Slow fade

4. **Glass** 💎
   - Light blue shards
   - Triangle shapes with gradients
   - Affected by gravity
   - Catches light

**Collision-Specific Explosions**:
```dart
// Car collision: 25 particles (40% sparks, 30% debris, 30% glass) + 5 smoke puffs
particleEmitter.spawnExplosion(parent: gameWorld, position: pos, collisionType: 'car', particleCount: 25);

// Bridge hit: 50 particles (50% sparks, 50% debris) + 15 HUGE smoke puffs
particleEmitter.spawnExplosion(parent: gameWorld, position: pos, collisionType: 'bridge', particleCount: 50);
```

**Physics Simulation**:
- Velocity-based movement
- Gravity for debris/glass (500 px/s²)
- Air resistance (2% velocity reduction per frame)
- Rotation with random spin speed
- Lifetime-based fading (alpha reduces to 0)

---

## 🎮 Current Game State

### What Works:
✅ Truck drives with keyboard controls (Arrow keys / WASD for desktop, tap for mobile)
✅ Truck physics with momentum and drift
✅ Trailer follows truck with spring physics
✅ Road scrolls infinitely with 3 lanes
✅ Traffic cars spawn and drive
✅ Collisions detect and destroy cars
✅ **FULL CRASH FEEDBACK**: Haptics + Screen shake + Particles + DP award
✅ Game HUD displays speed, DP, career stage
✅ Damage tracking system
✅ Career progression (Company Driver starts with speed governor)

### What's Implemented But Not Visible Yet:
- Low bridge system (data models ready, not spawned)
- Destructible environment items (signs, barriers, cones - models ready)
- Dispatcher harassment system (framework exists)
- ELD timer (data model ready, not displayed)
- Achievement system (tracking works, no UI)
- Garage/customization (data models ready, no screens)

---

## 📋 TODO - Next Session Priorities

### High Priority (Core Gameplay):
1. **Destructible Environment** 🚧
   - Create SignComponent, BarrierComponent, ConeComponent
   - Add spawning system to road
   - Wire up collision detection
   - Each has unique particle effects

2. **Low Bridge Implementation** 🌉
   - THE signature feature!
   - Spawn bridge obstacles with height warnings
   - Detect collision with truck height
   - MASSIVE explosion effect (60+ particles)
   - "Can-opener" visual (truck scrapes under bridge)
   - Extra DP multiplier for lowboy trailer bridge hits

3. **Progressive Damage Visuals** 💔
   - Smoke particles from damaged engine
   - Cracked windshield overlay
   - Missing bumper/mirrors at high damage
   - Sparks trail from dragging parts
   - Red damage tint intensifies

### Medium Priority (Polish):
4. **Sound Effects** 🔊
   - Engine rumble (looping)
   - Collision impacts (pitched by severity)
   - Bridge hit (LOUD metallic scrape)
   - Glass breaking
   - Dispatcher voice lines (text-to-speech)

5. **Enhanced Truck Rendering** 🎨
   - Complete Volvo VNL specific rendering (short nose, huge windshield)
   - Complete International Lonestar rendering (angular, aggressive)
   - Complete Freightliner Cascadia rendering (modern aero)
   - Add more chrome details (fuel tanks, side skirts, mud flaps)

6. **Trailer Visual Variety** 🚚
   - Distinct rendering for each trailer type
   - Reefer (white box with cooling unit)
   - Flatbed (exposed deck with straps)
   - Lowboy (low-slung heavy hauler)
   - Tanker (cylindrical with baffles)
   - Dry van (currently implemented as default box)

### Low Priority (Systems):
7. **ELD Timer Display**
   - Add countdown to HUD
   - Visual warning when time low
   - Run ends when timer expires

8. **Garage Screen**
   - View/select trucks
   - View/select trailers
   - Apply customization (chrome, lights, paint)
   - Preview upgrades

9. **Achievement Popups**
   - Toast notifications when unlocked
   - Achievement detail screen
   - Progress tracking UI

---

## 🐛 Known Issues

### Current Bugs:
1. **None reported yet** - Fresh codebase!

### Technical Debt:
1. Some truck manufacturers use placeholder rendering (Volvo, International, Freightliner)
   - Location: `truck_component.dart` lines 442-461
   - Quick fix: They fall back to classic long-hood style
   - Proper fix: Implement manufacturer-specific rendering methods

2. Unused variable warning in `breaker_braker_game.dart:270` (`damageAmount`)
   - Calculated but not yet applied to truck components
   - Will be used when damage system is fully wired up

3. Dead code in `haptic_service.dart:23`
   - Non-null operators after null-safety checks
   - Harmless, can be cleaned up

---

## 🏗️ Architecture Notes

### Key Design Patterns:
1. **Component-Based Architecture** (Flame ECS)
   - TruckComponent, TrailerComponent, CarComponent, etc.
   - Each component handles its own rendering and updates
   - Collision detection via Flame's built-in system

2. **Provider State Management**
   - GameStateProvider manages global game state
   - Player progression, stats, damage tracking
   - Persists to SharedPreferences

3. **Service Layer**
   - HapticService: Platform-specific vibration
   - Future: AudioService, StorageService

4. **Particle System**
   - Emitter pattern for spawning
   - Individual particle components
   - Self-removing after lifetime

### Critical Files:
```
lib/
├── game/breaker_braker_game.dart       # Main game loop, collision handling
├── components/
│   ├── truck/truck_component.dart      # Player truck with ENHANCED visuals
│   ├── truck/trailer_component.dart    # Trailer with spring physics
│   ├── obstacles/car_component.dart    # Traffic cars (4 types)
│   ├── obstacles/traffic_spawner.dart  # Spawns cars dynamically
│   ├── effects/screen_shake.dart       # Camera shake system
│   └── effects/collision_particle.dart # Particle explosion system
├── services/
│   └── haptic_service.dart             # Vibration/haptics
└── providers/
    └── game_state_provider.dart        # Global state management
```

---

## 🎨 Visual Style Guide

### Color Palette:
- **Chrome Shine**: `Color(0xFFE0E0E0)` - Used for all chrome details
- **Company Driver**: `Color(0xFF4A90E2)` - Blue for starter career
- **Lease Operator**: `Color(0xFFF39C12)` - Orange for mid career
- **Owner Operator**: `Color(0xFF27AE60)` - Green for max career
- **Damage Red**: `Color(0xFFE74C3C)` - Overlays damaged areas
- **Warning Yellow**: `Color(0xFFF1C40F)` - ELD warnings, cautions
- **Safe Green**: `Color(0xFF2ECC71)` - Ready states

### Sizing Reference:
- Truck: 50x120 pixels (width x height)
- Car: 28-32x45-55 pixels (varies by type)
- Particle: 2-8 pixels (varies by type)
- Screen shake: 3-18 pixels offset (varies by intensity)

---

## 💡 Future Ideas (Not Prioritized)

### Gameplay Enhancements:
- Weather system (rain reduces visibility, increases slide)
- Night mode (reduced visibility, headlights matter)
- Police chases (earn DP but risk fine)
- Convoy mode (AI trucks to draft behind)
- Mad Max upgrades (spikes, armor, nitro)

### Monetization Options:
- Premium trucks (cosmetic only)
- Instant repair (pay to skip wait time)
- DP doubler (temporary boost)
- Ad removal
- Season pass with exclusive trucks/trailers

### Platform Features:
- Leaderboards (most DP in single run)
- Daily challenges
- Achievements with rewards
- Cloud save sync
- Cross-platform progression

---

## 📞 Developer Handoff Notes

### For Tomorrow's Session:

**START HERE**: The codebase compiles cleanly with no errors. All completed systems are integrated and working together.

**Quick Test Plan**:
1. Run `flutter analyze` - Should show only warnings, no errors
2. Test collision: Drive into a traffic car
3. Expected result: Phone vibrates, screen shakes, explosion of particles, DP increases

**Recommended Next Task**: Implement destructible environment (signs, barriers, cones)
- Start with `lib/components/obstacles/sign_component.dart`
- Copy structure from `car_component.dart`
- Simpler than cars (no AI, just static obstacles)
- Already have particle effects ready for them!

**Reference Images Provided**:
- Kenworth W900: `C:\Users\rober\Downloads\kw w900.jpg`
- International Lonestar: `C:\Users\rober\Downloads\International Lonestar.jpg`
- Volvo VNL 860: `C:\Users\rober\Downloads\Volvo VNL 860.jpg`
- Use these when implementing manufacturer-specific rendering for International and Volvo

**Key Wikipedia References**:
- Freightliner Cascadia: https://en.wikipedia.org/wiki/Freightliner_Cascadia
- Volvo VN: https://en.wikipedia.org/wiki/Volvo_VN

---

## 🔧 Development Setup

### Required Tools:
- Flutter SDK (3.10.0+)
- Dart SDK (included with Flutter)
- Android Studio / VS Code with Flutter extensions
- Android SDK for mobile testing
- Chrome/Edge for web testing (desktop controls work!)

### Key Dependencies:
```yaml
flame: ^1.18.0           # Game engine
flame_audio: ^2.1.0      # Sound effects (not yet used)
provider: ^6.1.0         # State management
vibration: ^2.0.0        # Haptic feedback
sensors_plus: ^4.0.0     # Gyro controls (future)
shared_preferences: ^2.2.0  # Save/load
```

### Run Commands:
```bash
# Check for issues
flutter analyze

# Run on connected device
flutter run

# Run on Chrome (desktop controls work!)
flutter run -d chrome

# Build for Android
flutter build apk

# Get dependencies
flutter pub get
```

---

## 📊 Progress Tracker

### Session 1 (2025-11-18):
✅ Haptic feedback system
✅ Traffic cars with collision detection
✅ Enhanced truck visuals (20% bigger, tons of chrome)
✅ Screen shake on impact
✅ Particle effects (sparks, debris, smoke, glass)

**Lines of Code Added**: ~1,200+
**Files Created**: 3 new effect/obstacle components
**Files Modified**: 5 core game files
**Compilation Status**: ✅ Clean (0 errors, minor warnings)

### Session 2 (TBD):
⏳ Destructible environment
⏳ Low bridge implementation
⏳ Progressive damage visuals

---

## 🙏 Credits & Inspiration

- **Game Concept**: Owner-operator trucking chaos
- **Visual Inspiration**: Wreckfest 2 (destruction physics)
- **Truck References**:
  - Kenworth W900 (classic chrome icon)
  - Peterbilt 379 (timeless design)
  - International Lonestar (modern aggressive)
  - Volvo VNL 860 (European aero)
  - Freightliner Cascadia (utilitarian workhorse)

---

**Last Session End Time**: Late evening 2025-11-18
**Status**: Ready to resume development
**Mood**: 🔥 ON FIRE! The foundation is SOLID and the crashes look AMAZING!

---

*This document will be updated after each development session*
