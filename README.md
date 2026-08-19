# BUGS
- Gravity when falling off (not jumping) seems borked
- Unarmed AimWalk into Armed... need to reset that fov. More broadly, we should _exit() the Unarmed/ArmedStateMachine's current_state before stopping it and starting the other.
- Check Armed Walk into Unarmed Walk back into Armed Walk... animation is fucked 
- Falling while zoomed (unarmed) is bugged
- With quasar weapon aim then reload then unaim... bugged
- Switch between armed and unarmed while jumping / vertical velocity... lol
- Big AssaultRifle ammo pickup seemingly works forever if not used up all in one go?
- Current weapon not preserved between equip/unequip eg it will not keep the last weapon used
- Sometimes play walking animation when in unarmed idle after switching from armed

# TODO
- AimFall when aiming while in Jump, Fall, SprintJump, SprintFall
- Interaction system should be proximity based (i.e. the closest interaction the player is facing), not a pure FIFO stack like it is now
- https://www.youtube.com/watch?v=FvFx1R3p-aw
- What happens if use Quasar ammo with Assault Rifle? Or vice versa and etc?... and enforce so that we can't do this...
- 'Hitbox' might want to become 'Hurtbox'

# FYI
- Character models are Quaternius Ultimate Modular Men
- https://www.youtube.com/watch?v=1WJCHkHFRRA&list=PLhnGgh9GDmn6Cf4_ut7I0VJNHh9Vbfkjv and the following episodes for when you want to add another weapon and all related code
- Make weapons' internal ammo UNIQUE at least, you don't need to bother with doing it for AmmoPickups... not 100% sure why... I think it's because we duplicate an AmmoPickup's internal ammo resource in code when taking



"As a recommendation, you can create a separate state machine to control the action in the upper body. That will avoid you having to do x100 crossovers of actions. E.g. instead of having: idle, idle-aim, walk, walk-aim, run, run-aim you'll have: state_machine -> idle, walk, run and action_state_machine -> aim.

The action state_machine can controll the top part of the body and the other the actual movement action.
1
Reply
@yukku121
3 weeks ago
Otherwise for each action the player can do: grab, eat, talk,... you'll need to have x2/3 states in the state machine to match with idle, walk,..."



# CONSIDER BELOW REFACTOR
### 5. State Machine Async Safety
**Files:** [state.gd](file:///home/brey/Godot/just_no_reason/state_machine/state.gd), [state_machine.gd](file:///home/brey/Godot/just_no_reason/state_machine/state_machine.gd), [idle.gd](file:///home/brey/Godot/just_no_reason/player/state_machine/states/unarmed/idle.gd), [walk.gd](file:///home/brey/Godot/just_no_reason/player/state_machine/states/unarmed/walk.gd), [sprint.gd](file:///home/brey/Godot/just_no_reason/player/state_machine/states/unarmed/sprint.gd)

#### Proposed Implementation

##### 1. Track State Activation in `state.gd`:
```gdscript
var is_active := false
```

##### 2. Manage Activation in `state_machine.gd`:
```gdscript
func transition(state, new_state_name):
	# ...
	if current_state:
		current_state._exit()
		current_state.is_active = false
		current_state.previous_state = null
	# ...
	new_state.previous_state = current_state
	new_state.is_active = true
	new_state._enter()
	current_state = new_state
```

##### 3. Check State Validity on Resume (`idle.gd` / `walk.gd` / `sprint.gd`):
```gdscript
func _enter():
	if previous_state_in(land_after_these_states):
		_animation_state_changed.emit('land')
		await animation_finished()
		if not is_active:
			return # Intercept thread and exit early

	super._enter()
```
*Note: Deletes the hacky `handle_animation_state_changed_signal()` logic entirely. Checking `is_active` after an await prevents callbacks from firing in exited states (which can lead to visual bugs like the landing animation overriding subsequent states).*



SHOUTOUT TO CHAFF GAMES
