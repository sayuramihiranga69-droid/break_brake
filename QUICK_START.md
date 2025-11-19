# BREAKER BRAKER - Quick Start Guide

## 🚀 Ready to Test!

### What's Working Right Now:

✅ **Splash Screen** → **Main Menu** → **Playable Game**

- Scrolling 3-lane highway
- Player truck with physics (auto-accelerate, steering, braking)
- Working controls (touch + keyboard)
- Complete HUD showing:
  - Current speed (MPH)
  - DP counter
  - Damage meter
  - Career stage
  - Governor indicator (Company Driver/Lease Op)
  - Control instructions

### Running from Android Studio:

1. **Open the project:**
   - File → Open → Navigate to `C:\Users\rober\Git\break_brake\break_brake`

2. **Select a device:**
   - Click device dropdown in toolbar
   - Choose an Android emulator or connected device
   - OR use Chrome/Edge for web testing

3. **Run:**
   - Click the green play button ▶️
   - OR press `Shift+F10`
   - OR use terminal: `flutter run`

### Running from Command Line:

```bash
cd C:\Users\rober\Git\break_brake\break_brake

# Android (with emulator running or device connected)
flutter run

# Chrome (quick web test)
flutter run -d chrome

# Windows Desktop (with Windows support enabled)
flutter run -d windows
```

### Controls:

**Desktop/Keyboard:**
- ← → or A/D - Steer left/right
- Space - Brake
- ESC - Return to menu

**Mobile/Touch:**
- Tap left side of screen - Steer left
- Tap right side of screen - Steer right
- Tap center - Brake

**What You'll See:**

1. **Splash Screen:**
   - "BREAKER BRAKER" title with glow
   - "Firing up the diesel..." loading message
   - 2-second delay (adjust in main.dart if needed)

2. **Main Menu:**
   - Career stage: "Company Driver"
   - Stats: DP: 0, Cash: $1000, Runs: 0
   - Current truck: Freightliner Cascadia
   - Current trailer: 53' Dry Van
   - Status: "READY TO ROLL"
   - Click "FREE PLAY" to start

3. **Game Screen:**
   - White truck (Company Driver) on gray road
   - Auto-accelerates forward
   - Road scrolls to create forward motion
   - Steer left/right to change lanes
   - HUD shows speed, DP, damage, career stage
   - Governed to 65 MPH (Company Driver restriction)

### Current Game State:

**Career:** Company Driver (frustrated, governed, monitored)
**Truck:** Freightliner Cascadia (plain white)
**Trailer:** 53' Dry Van
**Speed Limit:** 65 MPH (GOVERNED - see red text on HUD)
**Damage:** 0% (pristine)
**DP:** 0 (no chaos yet!)

### What's Next to Add:

🚧 **Coming Soon:**
- Obstacle cars (four-wheelers to smash)
- Road signs (destructible)
- Collisions and damage
- Low bridges (THE signature feature)
- Sound effects
- DP rewards for destruction

---

## 🎮 Testing Checklist:

When you run it, test these:

- [ ] Splash screen displays correctly
- [ ] Main menu shows your stats
- [ ] "FREE PLAY" button works
- [ ] Game loads with truck on road
- [ ] Road scrolls smoothly
- [ ] Truck auto-accelerates (watch speed climb to 65 MPH)
- [ ] Left/right controls steer the truck
- [ ] Brake slows the truck down
- [ ] HUD displays correct information
- [ ] "GOVERNED (65 MPH)" shows in red (Company Driver restriction)
- [ ] Truck stays on screen (doesn't go off edges)

---

## 🐛 Known Issues:

- No obstacles yet (coming next!)
- No collisions
- No sound
- Truck can't leave the road edges (by design - keeps gameplay contained)
- Repair system works but no damage yet

---

## 📝 Code Tour:

**Entry point:** `lib/main.dart`
- Sets landscape orientation
- Loads splash → menu → game flow

**Game logic:** `lib/game/breaker_braker_game.dart`
- Main Flame game class
- Input handling
- Component coordination

**Truck:** `lib/components/truck/truck_component.dart`
- Physics simulation
- Auto-acceleration
- Steering and braking
- Damage effects (placeholder rectangle)

**Road:** `lib/components/environment/road_component.dart`
- Scrolling 3-lane highway
- Animated lane markings
- Shoulders

**HUD:** `lib/components/ui/game_hud.dart`
- Speed, DP, damage displays
- Career stage indicator
- Instructions overlay

**State:** `lib/providers/game_state_provider.dart`
- Player progression
- Save/load
- Achievement tracking

---

## 🎯 Next Development Session:

1. Add car obstacles (spawning, movement)
2. Implement collision detection
3. Apply damage on collision
4. Award DP for destruction
5. Add sound effects (crash, engine)
6. Build low bridge system

---

**Let's see this truck roll!** 🚛💨

Run it and let me know what you see!
