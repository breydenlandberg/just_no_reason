# Antigravity Changes & Refactors Roadmap

### NEXT PLANNED CHANGE: Decouple & Migrate UIManager and Player to Root Game

### Current Repo State: Mid-Refactor Checkpoint (Temporarily Broken)
The project is currently halted mid-refactor:
* **The Blocking Break:** In [`game.gd`](file:///home/brey/Godot/just_no_reason/game.gd#L81-L84), [`spawn_player()`](file:///home/brey/Godot/just_no_reason/game.gd#L81) calls `if player:`, but `player` is not declared as a variable in [`game.gd`](file:///home/brey/Godot/just_no_reason/game.gd). Godot breaks on startup with `Parser Error: Identifier "player" not declared in the current scope.`
* **Quick Temporary Patch:** Adding `@export var player: CharacterBody3D` back to line 12 of [`game.gd`](file:///home/brey/Godot/just_no_reason/game.gd) silences the crash and allows the game to boot into the menus.
* **The Architectural Debt:** [`Player`](file:///home/brey/Godot/just_no_reason/player/player.tscn) and [`UIManager`](file:///home/brey/Godot/just_no_reason/ui/ui_manager.tscn) are still trapped inside [`levels/level_0/level_0.tscn`](file:///home/brey/Godot/just_no_reason/levels/level_0/level_0.tscn) with fragile relative node paths (`../UIManager`, `../Pickups/Weapons`). Loading any other level (like [`levels/level_1/level_1.tscn`](file:///home/brey/Godot/just_no_reason/levels/level_1/level_1.tscn)) has neither a player nor a HUD.

---

### End Goal: The Complete Decoupled Architecture
Once this two-phase refactor is completed:
1. [`Game`](file:///home/brey/Godot/just_no_reason/game.gd) persistently owns the player instance (`player`) and HUD instance (`current_hud_container`).
2. Levels are 100% pure spatial environments: they only contain geometry, lighting, spawn markers (`PlayerSpawnPoint`), and pickup containers.
3. Every level (Level 0, Level 1, and future levels) will automatically share the exact same player and HUD without duplicating nodes or scene wiring.
4. Teleporting to `player_spawn` on level load will work across all levels dynamically.

---

### Phase 1: Migrate UIManager to `CurrentHUD`

#### Goal
Extract [`UIManager`](file:///home/brey/Godot/just_no_reason/ui/ui_manager.tscn) out of `level_0.tscn` into `Game/CurrentHUD`, decoupling [`Player`](file:///home/brey/Godot/just_no_reason/player/player.gd) from the UI hierarchy.

#### Architectural Decisions
1. **Decouple via `SignalBus`:**
   * [`SignalBus`](file:///home/brey/Godot/just_no_reason/globals/signal_bus.gd) gains `weapon_manager_started`, `weapon_manager_stopped`, and `ammo_updated`.
   * [`Player`](file:///home/brey/Godot/just_no_reason/player/player.gd) forwards `weapon_manager` events to [`SignalBus`](file:///home/brey/Godot/just_no_reason/globals/signal_bus.gd).
   * [`AmmoUI`](file:///home/brey/Godot/just_no_reason/ui/hud/ammo/ammo_ui.gd) connects to [`SignalBus`](file:///home/brey/Godot/just_no_reason/globals/signal_bus.gd) in `_ready()`.
   * [`MessageScrollContainer`](file:///home/brey/Godot/just_no_reason/ui/message_scroll_container.gd) connects directly to [`SignalBus._message`](file:///home/brey/Godot/just_no_reason/globals/signal_bus.gd) to append messages and auto-scroll.
   * Remove `ui_manager` export and message proxy function from [`player.gd`](file:///home/brey/Godot/just_no_reason/player/player.gd).
2. **Order of Initialization:**
   * In [`game.gd`](file:///home/brey/Godot/just_no_reason/game.gd), call `load_hud(game_hud)` **before** `load_current_level()` in `_on_level_loaded()`.
3. **Container Isolation:**
   * In [`game.tscn`](file:///home/brey/Godot/just_no_reason/game.tscn), assign `game_hud = ExtResource("res://ui/ui_manager.tscn")`.
   * In [`levels/level_0/level_0.tscn`](file:///home/brey/Godot/just_no_reason/levels/level_0/level_0.tscn), delete the `UIManager` node and the `ui_manager` property on `Player`.

---

### Phase 2: Migrate Player to Root `Game` & Fix Spawn

#### Goal
Attach [`Player`](file:///home/brey/Godot/just_no_reason/player/player.tscn) to `game.tscn`, fix the undeclared variable parser error in `game.gd`, and enable `spawn_player()` to position the player dynamically across any level.

#### Architectural Decisions
1. **Declare Player Variable:**
   * Add `@export var player: CharacterBody3D` to the export variables in [`game.gd`](file:///home/brey/Godot/just_no_reason/game.gd) (resolves parser crash).
2. **Decouple `Killzone`:**
   * In [`killzone.gd`](file:///home/brey/Godot/just_no_reason/killzone/killzone.gd), delete `@export var player` and replace `if body == player:` with `if body is Player:`.
3. **Decouple Dropped Weapons (`weapons_node`):**
   * On [`levels/level.gd`](file:///home/brey/Godot/just_no_reason/levels/level.gd), add `@export var weapons_node: Node3D`.
   * In [`game.gd`](file:///home/brey/Godot/just_no_reason/game.gd) inside `_on_level_loaded()`, forward the level's weapons node:
     ```gdscript
     if current_level and current_level.weapons_node and player:
         player.weapon_manager.weapons_node = current_level.weapons_node
     ```
   * Deletes the hardcoded `NodePath("../Pickups/Weapons")` from `Player`.
4. **Move Player Node:**
   * In [`game.tscn`](file:///home/brey/Godot/just_no_reason/game.tscn), instance [`player.tscn`](file:///home/brey/Godot/just_no_reason/player/player.tscn) under `Game` and wire it to `@export var player`.
   * In [`levels/level_0/level_0.tscn`](file:///home/brey/Godot/just_no_reason/levels/level_0/level_0.tscn), delete the `Player` node.
5. **Result:**
   * When any level loads, `Game.spawn_player()` teleports the persistent player to the level's `PlayerSpawnPoint` with zero velocity. Both Level 0 and Level 1 now share the exact same player and HUD.

---

### Complete Implementation Diffs

#### 1. `globals/signal_bus.gd`
```diff
diff --git a/globals/signal_bus.gd b/globals/signal_bus.gd
--- a/globals/signal_bus.gd
+++ b/globals/signal_bus.gd
@@ -8,2 +8,7 @@ signal _message(message: String)
 signal _speech(message: String)
+
+@warning_ignore('unused_signal')
+signal weapon_manager_started(weapon: Weapon, weapon_model: WeaponModel)
+@warning_ignore('unused_signal')
+signal weapon_manager_stopped
+@warning_ignore('unused_signal')
+signal ammo_updated(weapon: Weapon)
```

#### 2. `ui/hud/ammo/ammo_ui.gd`
```diff
diff --git a/ui/hud/ammo/ammo_ui.gd b/ui/hud/ammo/ammo_ui.gd
--- a/ui/hud/ammo/ammo_ui.gd
+++ b/ui/hud/ammo/ammo_ui.gd
@@ -19,2 +19,6 @@ func _ready():
 		child.queue_free()
+
+	SignalBus.weapon_manager_started.connect(start)
+	SignalBus.weapon_manager_stopped.connect(stop)
+	SignalBus.ammo_updated.connect(update_ammo_ui)
```

#### 3. `ui/message_scroll_container.gd`
```diff
diff --git a/ui/message_scroll_container.gd b/ui/message_scroll_container.gd
--- a/ui/message_scroll_container.gd
+++ b/ui/message_scroll_container.gd
@@ -6,2 +6,3 @@
 var max_scroll_length := 0
+@onready var messages: Label = $Messages
 
@@ -17,2 +18,3 @@ func _ready():
 	max_scroll_length = scrollbar.max_value
+	SignalBus._message.connect(_on_message)
 
@@ -25,2 +27,8 @@ func handle_scrollbar_changed():
 		self.scroll_vertical = max_scroll_length
+
+func _on_message(text: String) -> void:
+	if messages.text.length() > 0:
+		messages.text += ('\n' + text)
+	else:
+		messages.text += text
```

#### 4. `player/player.gd`
```diff
diff --git a/player/player.gd b/player/player.gd
--- a/player/player.gd
+++ b/player/player.gd
@@ -21,3 +21,2 @@
 @export_group('Nodes')
-@export var ui_manager: CanvasLayer
 @export var weapon_manager: WeaponManager
@@ -35,13 +34,7 @@ func _ready():
 	weapon_manager.start_weapon_manager()
-	SignalBus._message.connect(message)
 
-	# Set weapons_node on weapon_manager so that we can handle WeaponPickups
 	if weapon_manager and weapons_node:
 		weapon_manager.weapons_node = weapons_node
-
-	# AmmoUI
-	var ui_ammo: Control = ui_manager.get_node('AmmoUI')
-	weapon_manager.weapon_manager_started.connect(ui_ammo.start)
-	weapon_manager.weapon_manager_stopped.connect(ui_ammo.stop)
-	weapon_manager.ammo_updated.connect(ui_ammo.update_ammo_ui)
+		weapon_manager.weapon_manager_started.connect(SignalBus.weapon_manager_started.emit)
+		weapon_manager.weapon_manager_stopped.connect(SignalBus.weapon_manager_stopped.emit)
+		weapon_manager.ammo_updated.connect(SignalBus.ammo_updated.emit)
@@ -95,9 +88,0 @@ func movement(delta: float):
-## SignalBus
-#
-func message(text: String):
-	var messages = ui_manager.get_node('MasterContainer/PanelContainer/MarginContainer/ScrollContainer/Messages')
-
-	if messages.text.length() > 0:
-		messages.text += ('\n' + text)  
-	else: 
-		messages.text += text
```

#### 5. `killzone/killzone.gd`
```diff
diff --git a/killzone/killzone.gd b/killzone/killzone.gd
--- a/killzone/killzone.gd
+++ b/killzone/killzone.gd
@@ -4,4 +4,2 @@
 # var
-@export var player: CharacterBody3D
-
 @onready var timer := $Timer
@@ -11,3 +9,3 @@
 func _on_body_entered(body: CharacterBody3D):
-	if body == player:
+	if body is Player:
 		SignalBus._message.emit('You killed yourself')
```

#### 6. `levels/level.gd`
```diff
diff --git a/levels/level.gd b/levels/level.gd
--- a/levels/level.gd
+++ b/levels/level.gd
@@ -5,2 +5,3 @@
 @export var player_spawn: Marker3D
+@export var weapons_node: Node3D
```

#### 7. `game.gd`
```diff
diff --git a/game.gd b/game.gd
--- a/game.gd
+++ b/game.gd
@@ -11,2 +11,3 @@
 @export var game_hud: PackedScene
+@export var player: CharacterBody3D
 
@@ -89,5 +90,7 @@ func _on_level_loaded(level_packed_scene: PackedScene) -> void:
 	if game_hud:
 		load_hud(game_hud)
 
 	var current_level = load_current_level(level_packed_scene)
+	if current_level and current_level.weapons_node and player:
+		player.weapon_manager.weapons_node = current_level.weapons_node
 	if current_level and current_level.player_spawn:
 		spawn_player(current_level.player_spawn.global_transform)
```

#### 8. `game.tscn`
```diff
diff --git a/game.tscn b/game.tscn
--- a/game.tscn
+++ b/game.tscn
@@ -3,4 +3,6 @@
 [ext_resource type="Script" uid="uid://c6f8i4763ujxe" path="res://game.gd" id="1_fc0e3"]
 [ext_resource type="PackedScene" uid="uid://beddb0322vxuw" path="res://ui/menus/main_menu/main_menu.tscn" id="1_feb5d"]
 [ext_resource type="PackedScene" uid="uid://cjplmadinv70l" path="res://ui/menus/pause_menu/pause_menu.tscn" id="2_feb5d"]
+[ext_resource type="PackedScene" uid="uid://772t21cg58vo" path="res://ui/ui_manager.tscn" id="3_uiman"]
+[ext_resource type="PackedScene" uid="uid://bs72ogkvdd7d6" path="res://player/player.tscn" id="4_player"]
 
-[node name="Game" type="Node3D" unique_id=55940079 node_paths=PackedStringArray("debug_container", "current_menu_container", "current_hud_container", "current_level_container")]
+[node name="Game" type="Node3D" unique_id=55940079 node_paths=PackedStringArray("debug_container", "current_menu_container", "current_hud_container", "current_level_container", "player")]
 script = ExtResource("1_fc0e3")
 debug_container = NodePath("Debug")
 current_menu_container = NodePath("CurrentMenu")
 current_hud_container = NodePath("CurrentHUD")
 current_level_container = NodePath("CurrentLevel")
 main_menu = ExtResource("1_feb5d")
 pause_menu = ExtResource("2_feb5d")
+game_hud = ExtResource("3_uiman")
+player = NodePath("Player")
 
+[node name="Player" parent="." unique_id=685403359 instance=ExtResource("4_player")]
```

#### 9. `levels/level_0/level_0.tscn`
```diff
diff --git a/levels/level_0/level_0.tscn b/levels/level_0/level_0.tscn
--- a/levels/level_0/level_0.tscn
+++ b/levels/level_0/level_0.tscn
@@ -4,1 +4,0 @@
-[ext_resource type="PackedScene" uid="uid://772t21cg58vo" path="res://ui/ui_manager.tscn" id="2_3slpx"]
@@ -10,1 +9,0 @@
-[ext_resource type="PackedScene" uid="uid://bs72ogkvdd7d6" path="res://player/player.tscn" id="9_s6rvk"]
@@ -164,4 +162,5 @@
-[node name="Level0" type="Node3D" unique_id=1919438153 node_paths=PackedStringArray("player_spawn")]
+[node name="Level0" type="Node3D" unique_id=1919438153 node_paths=PackedStringArray("player_spawn", "weapons_node")]
 script = ExtResource("1_v3mv3")
 player_spawn = NodePath("PlayerSpawnPoint")
+weapons_node = NodePath("Pickups/Weapons")
 metadata/_custom_type_script = "uid://dxsryej3nlkg"
 
-[node name="UIManager" parent="." unique_id=844932442 instance=ExtResource("2_3slpx")]
-
@@ -321,3 +319,2 @@
-[node name="Killzone" parent="." unique_id=35288440 node_paths=PackedStringArray("player") instance=ExtResource("8_ssg5x")]
+[node name="Killzone" parent="." unique_id=35288440 instance=ExtResource("8_ssg5x")]
 transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.5, 0)
-player = NodePath("../Player")
@@ -330,3 +327,0 @@
-[node name="Player" parent="." unique_id=685403359 node_paths=PackedStringArray("ui_manager", "weapons_node") instance=ExtResource("9_s6rvk")]
-transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.5, 0)
-ui_manager = NodePath("../UIManager")
-weapons_node = NodePath("../Pickups/Weapons")
```

---


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
