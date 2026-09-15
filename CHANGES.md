# Antigravity Changes & Refactors Roadmap

## Minor Refactors

### 1. Single Source of Truth for Aim (Decouple `WeaponManager`)
- **Problem:** [`WeaponManager`](file:///home/brey/Godot/just_no_reason/player/weapon_manager/weapon_manager.gd) polls input every frame in `_process()`, spamming `weapon_aim_entered` and causing redundant `set_animation()` calls on `AnimationTree`. Furthermore, aim intent is blocked while `WeaponManager` is in `UNAVAILABLE` status (e.g. during weapon equip/draw).
- **Solution:**
  1. Delete `_process()` and signals `weapon_aim_entered` / `weapon_aim_exited` from [`WeaponManager`](file:///home/brey/Godot/just_no_reason/player/weapon_manager/weapon_manager.gd). `WeaponManager` strictly manages inventory, ammo, and firing.
  2. In [`PlayerModelAnimated`](file:///home/brey/Godot/just_no_reason/player/player_model_animated.gd), connect `_on_aim_entered` and `_on_aim_exited` directly to character aim events, updating `weapon_idle_animation` via `weapon_manager.current_weapon`.
  3. In `load_new_weapon()`, check `if owner and owner.is_aiming` so drawing a weapon while holding aim immediately sets `rifle_aim` on frame 1.
  4. Remove leftover debug prints (`'Stop emitting weapon_aim_entered signal!'`).

### 2. Fix Empty Stub States Freezing Player in Mid-Air (`AimJump` & `AimFall`)
- **Problem:** In [`Armed/aim_walk.gd`](file:///home/brey/Godot/just_no_reason/player/state_machine/states/armed/aim_walk.gd) and `aim_idle.gd`, jumping or stepping off a ledge transitions to `ArmedStates.aim_jump` and `ArmedStates.aim_fall`. But [`aim_jump.gd`](file:///home/brey/Godot/just_no_reason/player/state_machine/states/armed/aim_jump.gd) and [`aim_fall.gd`](file:///home/brey/Godot/just_no_reason/player/state_machine/states/armed/aim_fall.gd) are empty 2-line stub scripts. The character freezes mid-air with no gravity or exit condition.
- **Solution:**
  Adopt `Unarmed`'s pattern: jumping or falling while aiming emits `aim_exited` and transitions to `jump` or `fall`. When landing, [`fall.gd`](file:///home/brey/Godot/just_no_reason/player/state_machine/states/armed/fall.gd) already checks `Input.is_action_pressed(aim)` to seamlessly re-enter `AimWalk` or `AimIdle`.

### 3. Direct State Transitions (Avoid Intermediate Hops)
- **Goal:** Always perform direct State switches when possible (e.g. Idle directly into Sprint or AimWalk, rather than Idle -> Walk -> Sprint/AimWalk). Ensure this across all paths in both Armed and Unarmed machines.
- **Immediate Fix:** In [`unarmed/idle.gd`](file:///home/brey/Godot/just_no_reason/player/state_machine/states/unarmed/idle.gd), moving while aiming currently transitions to `Walk` first and only on the next frame to `AimWalk` (unlike `armed/idle.gd` which already transitions directly). Check `Input.is_action_pressed(aim)` on movement in `unarmed/idle.gd` to transition directly into `AimWalk`.

### 4. Centralize Aim & Sprint Events (Eliminate Scene Spaghetti)
- **Problem:** [`player.tscn`](file:///home/brey/Godot/just_no_reason/player/player.tscn) contains 10+ manual inspector wires from leaf states (`Unarmed/AimIdle`, `Unarmed/AimWalk`, `Armed/AimIdle`, `Armed/AimWalk`, `Sprint`, `SprintFall`) directly to `Camera`. `Camera` mutates `owner.is_aiming` as a side effect.
- **Solution:**
  Expose `signal aim_changed(is_aiming: bool)` and `signal sprint_changed(is_sprinting: bool)` on [`player.gd`](file:///home/brey/Godot/just_no_reason/player/player.gd). States update `owner.set_aiming(true/false)`. `Camera` and `PlayerModelAnimated` connect to `Player` once in `_ready()`, deleting 10+ fragile wires from `player.tscn`.

### 5. Deduplicate Sub-State Machines (`ArmedStateMachine` & `UnarmedStateMachine`)
- **Problem:** [`armed_state_machine.gd`](file:///home/brey/Godot/just_no_reason/player/state_machine/state_machines/armed_state_machine.gd) and [`unarmed_state_machine.gd`](file:///home/brey/Godot/just_no_reason/player/state_machine/state_machines/unarmed_state_machine.gd) contain 100% duplicate code for connecting/disconnecting `_animation_state_changed` and `_rotate_model` loops.
- **Solution:**
  Extract a common `PlayerSubStateMachine extends StateMachine` base class with this wiring logic and have both machines inherit from it.

### 6. Clean Up Zombie State Flags on `Player`
- **Problem:** `is_sprinting`, `is_crouching`, and `is_attacking` in [`player.gd`](file:///home/brey/Godot/just_no_reason/player/player.gd) are dead variables that are never updated or read.
- **Solution:**
  Connect `is_sprinting` to the sprint state event and prune unneeded dead flags to eliminate confusion over actual player state.

---

## Major Refactors

### 1. Separate Upper-Body Action State Machine (Layered Animation Architecture)
> "As a recommendation, you can create a separate state machine to control the action in the upper body. That will avoid you having to do x100 crossovers of actions. E.g. instead of having: idle, idle-aim, walk, walk-aim, run, run-aim you'll have: state_machine -> idle, walk, run and action_state_machine -> aim.
>
> The action state_machine can control the top part of the body and the other the actual movement action. Otherwise for each action the player can do: grab, eat, talk,... you'll need to have x2/3 states in the state machine to match with idle, walk,..."
> *(Credit: @yukku121 / YouTube)*

### 2. State Machine & Landing Animation Refactor (Ghost Coroutines)
#### The Problem: Ghost Coroutines in `_enter()`
Currently, landing animations in `idle.gd`, `walk.gd`, and `sprint.gd` call `await animation_finished()` inside `_enter()`. 
When the player immediately moves upon landing, the state machine transitions to `walk`, but the suspended `_enter()` in `idle` wakes up once the landing animation finishes and executes `super._enter()`, snapping the player back into the `idle` animation while walking.

**Current Workaround:** `handle_animation_state_changed_signal()` dynamically connects and disconnects signals on every `_enter()` and `_exit()`. It functions, but spreads fragile signal-juggling across 6 separate state scripts.

#### Solutions for Future Refactor:
- **Option 1: AnimationTree `OneShot` Node (Recommended — Idiomatic Godot)**
  Treat landing as an animation-layer concern rather than a state-machine concern:
  1. In `AnimationTree`, add a `OneShot` blend node for `land` over the locomotion blend tree.
  2. When touching down from `jump`/`fall`, fire `OneShot.ONE_SHOT_REQUEST_FIRE` on the animated model.
  3. Locomotion states (`idle`, `walk`, `sprint`) remain 100% synchronous with zero `await`.
  4. Completely deletes `handle_animation_state_changed_signal()`, `animation_finished()`, and all dynamic signal connects/disconnects.
- **Option 2: Dedicated `Land` State (Best if landing freezes movement)**
  If hard landings are meant to briefly lock player movement:
  - Make `Land` its own discrete state in the state machine (`Fall` -> `Land` -> `Idle`/`Walk`).
  - Input is ignored while in `Land`, keeping all state transitions synchronous without coroutines inside `_enter()`.
- **Option 3: `is_active` Guard (Quick patch if keeping `await`)**
  If keeping `await` in `_enter()`:
  1. Add `var is_active := false` to `state.gd`, set to `true` on entry and `false` on `_exit()`.
  2. After `await animation_finished()`, check: `if not is_active: return`.
  3. Much cleaner than the current connect/disconnect hack, but still leaves asynchronous coroutines inside a synchronous state machine.

### 3. Weapon Pickup Separate Variables (`internal_current_ammo` & `internal_reserve_ammo`)
**Files:** [`assets/weapons/weapon_pickup.gd`](file:///home/brey/Godot/just_no_reason/assets/weapons/weapon_pickup.gd), [`player/weapon_manager/weapon_manager.gd`](file:///home/brey/Godot/just_no_reason/player/weapon_manager/weapon_manager.gd)

#### The Problem:
`WeaponPickup.internal_ammo` currently bundles the chambered magazine and spare magazines into one single array, relying on an implicit convention that "Index 0 is the chamber". 
When a player holding the same weapon walks over a dropped rifle to scavenge ammo, `add_ammo()` sorts the array descending. If the chambered magazine was partially depleted (e.g. 5 rounds), sorting shuffles it into the reserve, and a full 15-round magazine becomes the new Index 0. When that ground rifle is later picked up, it magically loads 15 rounds instead of the 5 rounds originally in its chamber.

#### The Solution:
Mirror `Weapon.gd` on `WeaponPickup` by explicitly separating the chamber from reserve pouches:
1. `WeaponPickup.internal_current_ammo: Ammo` (the magazine physically loaded in the gun).
2. `WeaponPickup.internal_reserve_ammo: Array[Ammo]` (loose/spare magazines).

#### The Diffs:
##### 1. `assets/weapons/weapon_pickup.gd`
```diff
diff --git a/assets/weapons/weapon_pickup.gd b/assets/weapons/weapon_pickup.gd
--- a/assets/weapons/weapon_pickup.gd
+++ b/assets/weapons/weapon_pickup.gd
@@ -9,2 +9,3 @@ signal became_ready(weapon_pickup: WeaponPickup)
 @export var internal_weapon: Weapon
-@export var internal_ammo: Array[Ammo]
+@export var internal_current_ammo: Ammo
+@export var internal_reserve_ammo: Array[Ammo]
 
@@ -19,3 +20,5 @@ func _ready():
-	for i in range(internal_ammo.size()):
-		internal_ammo[i] = internal_ammo[i].duplicate()
+	if internal_current_ammo:
+		internal_current_ammo = internal_current_ammo.duplicate()
+	for i in range(internal_reserve_ammo.size()):
+		internal_reserve_ammo[i] = internal_reserve_ammo[i].duplicate()
```

##### 2. `player/weapon_manager/weapon_manager.gd`
```diff
diff --git a/player/weapon_manager/weapon_manager.gd b/player/weapon_manager/weapon_manager.gd
--- a/player/weapon_manager/weapon_manager.gd
+++ b/player/weapon_manager/weapon_manager.gd
@@ -226,9 +226,4 @@ func add_weapon(weapon_pickup: WeaponPickup):
 	var new_weapon: Weapon = weapon_pickup.internal_weapon
 
-	new_weapon.reserve_ammo.clear()
-	new_weapon.reserve_ammo.append_array(weapon_pickup.internal_ammo)
-
-	if not new_weapon.reserve_ammo.is_empty():
-		new_weapon.current_ammo = new_weapon.reserve_ammo.pop_front()
-	else:
-		new_weapon.current_ammo = null
+	new_weapon.current_ammo = weapon_pickup.internal_current_ammo
+	new_weapon.reserve_ammo = weapon_pickup.internal_reserve_ammo.duplicate()
 	sort_reserve_ammo(new_weapon)
@@ -248,6 +243,4 @@ func drop_weapon() -> int:
 	if current_weapon.current_ammo:
-		weapon_to_load.internal_ammo.append(current_weapon.current_ammo)
+		weapon_to_load.internal_current_ammo = current_weapon.current_ammo
 		current_weapon.current_ammo = null
 
-	weapon_to_load.internal_ammo.append_array(current_weapon.reserve_ammo)
-	current_weapon.reserve_ammo.clear()
+	weapon_to_load.internal_reserve_ammo = current_weapon.reserve_ammo.duplicate()
 	current_weapon.reserve_ammo.clear()
@@ -314,6 +307,2 @@ func _on_pickup_area_weapon_detected(weapon_pickup: WeaponPickup):
 	else:
-		var remaining: Array[Ammo] = add_ammo(weapon_pickup.internal_ammo)
-
-		if remaining.is_empty():
-			weapon_pickup.queue_free()
-		else:
-			weapon_pickup.internal_ammo = remaining
+		weapon_pickup.internal_reserve_ammo = add_ammo(weapon_pickup.internal_reserve_ammo)
```
