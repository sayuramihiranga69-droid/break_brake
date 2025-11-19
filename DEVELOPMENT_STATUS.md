# BREAKER BRAKER - Development Status

## 🎮 Project Overview
**18 Wheels of Fury** - Mobile trucking chaos game for Android/iOS built with Flutter and Flame

---

## ✅ COMPLETED - Phase 1: Foundation & Architecture

### Project Setup
- ✅ Flutter project created with proper structure
- ✅ All dependencies installed (Flame, Provider, sensors, audio, storage)
- ✅ Landscape orientation locked
- ✅ Asset directories created
- ✅ Code compiles successfully

### Core Architecture
- ✅ **Game Configuration** (`lib/config/game_config.dart`)
  - All game constants and tuning parameters
  - Career stages, truck types, trailer types
  - ELD timing, repair times, damage thresholds
  - Color schemes and string constants
  - Trucker lingo and CB chatter

### Data Models
- ✅ **Truck Model** (`lib/models/truck_model.dart`)
  - 6 truck templates (cab-over, long-nose, modern)
  - Performance stats with upgrades
  - Visual customization system
  - Speed governor by career stage

- ✅ **Trailer Model** (`lib/models/trailer_model.dart`)
  - 7 trailer types (dry van, reefer, flatbed, tanker, lowboy, doubles, triples)
  - Destruction properties and multipliers
  - Bridge hit damage calculations

- ✅ **Damage Model** (`lib/models/damage_model.dart`)
  - Component-based damage system (hood, tires, windshield, etc.)
  - Visual and performance degradation
  - Collision types (head-on, sideswipe, bridge hit)
  - Repair time calculations

- ✅ **Player/Career Model** (`lib/models/player_model.dart`)
  - Three-tier career progression (Company → Lease → Owner)
  - Idle repair mechanic with real-time tracking
  - ELD timer system
  - Currency (DP, cash, premium)
  - Statistics tracking
  - Settings (gyro, audio volumes)

- ✅ **Achievement System** (`lib/models/achievement_model.dart`)
  - 25+ achievements across 6 categories
  - Progress tracking and rewards
  - Bronze/Silver/Gold/Platinum tiers

### State Management
- ✅ **Game State Provider** (`lib/providers/game_state_provider.dart`)
  - Complete player progression management
  - Truck/trailer selection and purchasing
  - Achievement tracking
  - Save/load game data (SharedPreferences)
  - Idle repair completion checking

### Game Engine
- ✅ **Main Flame Game** (`lib/game/breaker_braker_game.dart`)
  - Flame game class with collision detection
  - Touch controls (left/right/brake zones)
  - Keyboard support (desktop testing)
  - Input state management
  - Pause/resume functionality

### UI Screens
- ✅ **Splash Screen**
  - "BREAKER BRAKER" title with glow effect
  - "Firing up the diesel..." loading message
  - Auto-loads saved game data

- ✅ **Main Menu**
  - Career stage display with color coding
  - Stats (DP, Cash, Runs completed)
  - Current truck/trailer display
  - Repair status indicator
  - Menu buttons (Free Play, Hot Load, Garage, Achievements)
  - Repair timer blocks gameplay when truck damaged

- ✅ **Game Screen**
  - Flame game widget integration
  - Ready to add game components

---

## 🚧 IN PROGRESS - Phase 2: Core Gameplay

### Next Priority Tasks

#### 1. Truck Component & Physics
**Location:** `lib/components/truck/`
- Create truck sprite component
- Implement movement physics (auto-accelerate, steering, braking)
- Apply speed governor based on career stage
- Damage-based performance penalties
- Gyro control integration (sensors_plus)

#### 2. Road/Environment System
**Location:** `lib/components/environment/`
- Scrolling road generation
- Lane system
- Background scenery
- Road surface types

#### 3. Obstacle Components
**Location:** `lib/components/obstacles/`
- Four-wheeler (car) spawning and behavior
- Road signs (destructible)
- Construction barriers
- Traffic lights
- Guard rails
- Parked vehicles

#### 4. Low Bridge System ⭐ (Signature Feature)
**Location:** `lib/components/obstacles/bridge_system.dart`
- Progressive warning signs (1 mile → close approach)
- LED signs and flashing lights
- Bridge collision detection
- Trailer-specific destruction:
  - Dry van: Can-opener peel
  - Reefer: MASSIVE white insulation explosion
  - Lowboy: BRIDGE takes damage (10x DP!)
- Achievement tracking

#### 5. Collision & Destruction
**Location:** `lib/game/collision_handler.dart`
- Collision detection between truck and obstacles
- Damage application by impact type
- Visual effects (sparks, debris, explosions)
- Sound effect triggering
- DP awarding
- Achievement progress

#### 6. Audio System
**Location:** `lib/services/audio_service.dart`
- Audio manager using flame_audio
- Sound effects:
  - Engine varieties (Detroit Diesel, Cat, Cummins)
  - Jake brake (BRAP-BRAP)
  - Air horn
  - Crashes (metal, glass, different tones)
  - Reefer explosion (WHOOSH)
- Music/radio system with career progression
- CB chatter

#### 7. HUD/UI Overlays
**Location:** `lib/components/ui/`
- Damage meter
- DP counter
- Speed display
- ELD timer (color-coded: green → yellow → red)
- Control buttons (air horn, brake, boost)
- Dispatcher popup messages

#### 8. Game Loop Systems
**Location:** `lib/game/`
- Score/DP accumulation
- Combo multipliers
- Distance tracking
- ELD timer countdown
- Run completion detection

---

## 📋 PENDING - Phase 3: Advanced Features

### Dispatcher System
- Call/text popup system
- Message frequency by career stage
- "Ignore call" achievement tracking
- Silence upon reaching Owner-Op

### Hot Load Mode
- Countdown timer
- Deadline pressure
- Bonus DP for completion
- Dispatcher responses based on performance

### Skill Challenges
- Threading the Needle
- Four-Wheeler Bowling
- Bridge Jump Series
- Weigh Station Escape
- Combo King challenges

### Garage Screen
- Truck selection and customization
- Chrome packages, lights, paint
- Performance upgrades
- Mad Max armor progression
- Preview and save custom builds

### Achievements Screen
- Achievement list with progress bars
- Category filtering
- Unlocked rewards display
- Completion statistics

### "Rage Quit" Mechanic
- Special rampage mode for Company Drivers
- Instant tier jump on successful completion
- Maximum chaos, no consequences
- "I QUIT!" achievement

### Idle Repair Polish
- Background repair progress
- Push notifications when repair complete (optional)
- Premium currency instant repair UI

### Monetization Integration
- Ad placement (optional bonuses)
- Premium currency shop
- Cosmetic-only premium items
- Pro version upgrade

---

## 🎯 Current Focus

**IMMEDIATE NEXT STEPS:**
1. Create basic truck sprite component (placeholder graphics)
2. Implement truck movement physics
3. Add scrolling road background
4. Create simple obstacle spawning (cars, signs)
5. Test touch controls and collision
6. Add basic sound effects

---

## 📂 Project Structure

```
lib/
├── config/
│   └── game_config.dart          ✅ All constants and configuration
├── models/
│   ├── truck_model.dart          ✅ Truck data and templates
│   ├── trailer_model.dart        ✅ Trailer data and templates
│   ├── damage_model.dart         ✅ Damage system
│   ├── player_model.dart         ✅ Player progression & career
│   └── achievement_model.dart    ✅ Achievement system
├── providers/
│   └── game_state_provider.dart  ✅ State management
├── game/
│   └── breaker_braker_game.dart  ✅ Main Flame game class
├── components/
│   ├── truck/                    🚧 Truck components (TODO)
│   ├── obstacles/                🚧 Obstacles (TODO)
│   ├── environment/              🚧 Road, scenery (TODO)
│   └── ui/                       🚧 HUD elements (TODO)
├── services/
│   └── audio_service.dart        📋 Audio manager (TODO)
├── screens/
│   ├── (integrated in main.dart) ✅ Splash, Menu, Game screens
│   └── garage_screen.dart        📋 Garage UI (TODO)
└── main.dart                     ✅ App entry, screens
```

---

## 🔧 How to Run

```bash
# Check dependencies
cd break_brake
flutter pub get

# Run on connected device/emulator
flutter run

# Or specify platform
flutter run -d android
flutter run -d ios

# For desktop testing
flutter run -d windows
```

---

## 🎨 Asset Pipeline (When Ready)

**Placeholder Strategy:**
- Use colored rectangles for trucks (green = player, red = enemies)
- Simple shapes for obstacles
- Solid color backgrounds
- Stock sound effects from Freesound.org

**Future Assets:**
- Truck sprite sheets (realistic garage view)
- Simplified truck sprites (gameplay)
- Trailer variations
- Destruction particle effects
- Premium audio recordings

---

## 📝 Development Notes

### Technical Decisions
- **Flutter + Flame**: Perfect for 2D arcade-style mobile game
- **Provider**: Simple, effective state management
- **Portrait Lock**: LANDSCAPE ONLY (90° locked)
- **Performance Target**: 30-60 FPS on 3+ year old devices
- **File Size Target**: < 200MB

### Authentic Trucker Details Implemented
- ✅ Three-tier career progression (the grind → freedom)
- ✅ Governor speed limits by stage
- ✅ ELD 11-hour drive time limit
- ✅ Dispatcher harassment system
- ✅ Trucker lingo throughout
- ✅ Idle repair mechanic (perfect for detention time)
- ✅ Reefer explosion physics
- ✅ Lowboy bridge damage multiplier
- ✅ "Rage Quit" career progression

### Rob's Experience Shining Through
- 25 years of real trucking frustrations built into game mechanics
- Authentic progression from mega carrier hell to owner-op freedom
- Industry in-jokes (Swift bridge hits, governed vs ungoverned)
- Real trailer destruction behaviors
- Genuine trucker terminology

---

## 🚀 Rapid Prototyping Strategy

Following your ServiceFlow development pace:
1. **Week 1-2**: Core gameplay prototype (truck, road, basic collision)
2. **Week 3-4**: Destruction system, audio, HUD
3. **Week 5-6**: Progression systems, garage, achievements
4. **Week 7-8**: Polish, testing, soft launch prep

**MVP Target**: 2-3 months to soft launch

---

## 💡 Testing Checklist (When Ready)

- [ ] App launches without crashes
- [ ] Touch controls feel responsive
- [ ] Truck handles well (arcade feel)
- [ ] Collisions are satisfying
- [ ] Damage accumulates correctly
- [ ] Idle repair works (close app, reopen later)
- [ ] Career progression triggers properly
- [ ] Achievements unlock correctly
- [ ] Audio is impactful and clear
- [ ] Runs on older Android devices smoothly

---

## 🎯 Success Metrics

- Session length: 5-15 minutes average
- High return rate (idle repair encourages returns)
- Achievement completion engagement
- Social sharing of spectacular wrecks
- Positive trucker community feedback

---

**Status Updated**: November 18, 2025
**Next Session**: Begin truck component and basic physics implementation

LET'S ROLL! 🚛💥
