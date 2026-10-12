# Antigravity Changes & Refactors Roadmap

<!-- 
HANDOVER RULE:
The "## Next Change" section is strictly for the single upcoming handover task.
NEVER edit, modify, or accumulate completed items here. 
When the task is complete, either CLEAR it (set to None) or POPULATE it with the next active task.
-->
## Next Change

### Part 1: Final Lint Conformances & Minor Cleanups
- **Goal:** Finish remaining edge cases identified during the project-wide lint re-evaluation pass.
- **Files, Lines & Tasks:**
  - [`enemies/sphere/species/sphere_species.gd`](file:///home/brey/Godot/just_no_reason/enemies/sphere/species/sphere_species.gd#L3): Add `# vars` header above exports.
  - [`enemies/sphere/sphere.gd`](file:///home/brey/Godot/just_no_reason/enemies/sphere/sphere.gd#L3): Add `# vars` header above exports.
  - [`enemies/sphere/sphere.gd`](file:///home/brey/Godot/just_no_reason/enemies/sphere/sphere.gd#L17): Change `## virtual / private` to `## virtual`.
  - [`enemies/sphere/sphere.gd`](file:///home/brey/Godot/just_no_reason/enemies/sphere/sphere.gd#L47): Change singular `## signal` to `## signals`.
  - [`enemies/sphere/sphere.gd`](file:///home/brey/Godot/just_no_reason/enemies/sphere/sphere.gd#L49): Add `-> void` return type to `_on_hurtbox_damage_take(_damage: float)`.
  - [`globals/debug_jnr.gd`](file:///home/brey/Godot/just_no_reason/globals/debug_jnr.gd#L4): Separate combined `# var, const` into `# consts` and `# vars`.
  - [`globals/debug_jnr.gd`](file:///home/brey/Godot/just_no_reason/globals/debug_jnr.gd#L37): Add `-> void` return type to `set_debug_container(container: Node3D)`.
  - [`globals/debug_jnr.gd`](file:///home/brey/Godot/just_no_reason/globals/debug_jnr.gd#L40): Add `-> void` return type to `draw_between(...)`.
  - [`player/input_manager.gd`](file:///home/brey/Godot/just_no_reason/player/input_manager.gd#L1-L3): Ensure 2 blank lines after `class_name InputManager` and change `# static var` to `# static vars`.
  - [`player/state_machine/player_motion_state.gd`](file:///home/brey/Godot/just_no_reason/player/state_machine/player_motion_state.gd#L64): Ensure 2 blank lines before `## movement & physics`.
  - [`player/weapon_manager/projectiles/bullets/assault_rifle_bullet.gd`](file:///home/brey/Godot/just_no_reason/player/weapon_manager/projectiles/bullets/assault_rifle_bullet.gd#L3): Add `# vars` header above export.
  - [`player/weapon_manager/projectiles/projectile.gd`](file:///home/brey/Godot/just_no_reason/player/weapon_manager/projectiles/projectile.gd#L8): Add `-> void` return type to custom method `_set_weapon_projectile(...)`.
  - [`player/weapon_manager/projectiles/rigid_body_projectile.gd`](file:///home/brey/Godot/just_no_reason/player/weapon_manager/projectiles/rigid_body_projectile.gd#L51): Add `-> void` return type to `_set_weapon_projectile(...)`.
  - [`player/weapon_manager/weapons/weapon_model.gd`](file:///home/brey/Godot/just_no_reason/player/weapon_manager/weapons/weapon_model.gd#L1-L3): Ensure 2 blank lines after `class_name WeaponModel extends Node3D` and add `# vars` header.
  - [`state_machine/state.gd`](file:///home/brey/Godot/just_no_reason/state_machine/state.gd#L36): Ensure 2 blank lines before `## helper`.
  - [`ui/hud/ammo/ammo_graphics/ammo_instance_graphic.gd`](file:///home/brey/Godot/just_no_reason/ui/hud/ammo/ammo_graphics/ammo_instance_graphic.gd#L3-L9): Add `# vars` header, `### fn`, `## helper`, and `-> void` to `setup(...)`.
  - [`ui/menus/pause_menu/pause_menu.gd`](file:///home/brey/Godot/just_no_reason/ui/menus/pause_menu/pause_menu.gd#L6): Change singular `## signal` to `## signals`.

### Part 2: Standardize Variable Ordering within `# vars` across Codebase
- **Goal:** Audit and systematically organize variable declarations within `# vars` across all files once Part 1 completes.
- **Approaches to choose from:**
  - **Option A (Type / Lifecycle Order):** `@export` vars &rarr; regular state vars &rarr; internal `_` vars &rarr; `static var` &rarr; `@onready var`.
  - **Option B (Feature / Domain Grouping):** Group variables by feature domain (e.g., look/camera &rarr; stance [aim before sprint] &rarr; inventory [weapons before ammo]), keeping related exports/onready vars together with domain headers.
- **Safety Precaution:** Check `@onready` top-to-bottom dependency order and Godot Inspector export layouts during the pass.
- **Underscore Naming Convention (`_`) for Internal Variables:** Review and standardize the use of leading underscores on variables (similar to internal functions) — prefixing private/internal state variables with `_` while leaving public contracts clean.
- **Update Documentation:** Update [`CONVENTION.md`](file:///home/brey/Godot/just_no_reason/CONVENTION.md) upon completing this pass to document the finalized variable ordering standard and internal variable underscore convention.


---

## Minor Refactors and Changes

### 1. Deduplicate Sub-State Machines (`ArmedStateMachine` & `UnarmedStateMachine`)
- **Problem:** [`armed_state_machine.gd`](file:///home/brey/Godot/just_no_reason/player/state_machine/state_machines/armed_state_machine.gd) and [`unarmed_state_machine.gd`](file:///home/brey/Godot/just_no_reason/player/state_machine/state_machines/unarmed_state_machine.gd) contain 100% duplicate code for connecting/disconnecting `_animation_state_changed` and `_rotate_model` loops.
- **Solution:**
  Extract a common `PlayerSubStateMachine extends StateMachine` base class with this wiring logic and have both machines inherit from it.

### 2. Clean Up Zombie State Flags on `Player`
- **Problem:** `is_sprinting`, `is_crouching`, and `is_attacking` in [`player.gd`](file:///home/brey/Godot/just_no_reason/player/player.gd) are dead variables that are never updated or read.
- **Solution:**
  Connect `is_sprinting` to the sprint state event and prune unneeded dead flags to eliminate confusion over actual player state.

---

## Major Refactors and Changes

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
