# BUGS
- Unarmed AimWalk into Armed... need to reset that fov. More broadly, we should _exit() the Unarmed/ArmedStateMachine's current_state before stopping it and starting the other.
- Check Armed Walk into Unarmed Walk back into Armed Walk... animation is fucked 
- Falling while zoomed (unarmed) is bugged
- Switch between armed and unarmed while jumping / vertical velocity... lol
- Sometimes play walking animation when in unarmed idle after switching from armed

# TODO
- AimFall when aiming while in Jump, Fall, SprintJump, SprintFall
- Interaction system should be proximity based (i.e. the closest interaction the player is facing), not a pure FIFO stack like it is now
- https://www.youtube.com/watch?v=FvFx1R3p-aw
- We want to be able to pick up ammo always, not just when that weapon is equipped? This probably involves a fully-fledged inventory system already...

# FYI
- Character models are Quaternius Ultimate Modular Men
- https://www.youtube.com/watch?v=1WJCHkHFRRA&list=PLhnGgh9GDmn6Cf4_ut7I0VJNHh9Vbfkjv and the following episodes for when you want to add another weapon and all related code
- Although adding different weapons' ammo to another's is impossible in game currently (ie pickups), keep in mind that we don't have specific guards against it if we did indeed set it in editor, eg quasar having AssaultRifleAmmo



"As a recommendation, you can create a separate state machine to control the action in the upper body. That will avoid you having to do x100 crossovers of actions. E.g. instead of having: idle, idle-aim, walk, walk-aim, run, run-aim you'll have: state_machine -> idle, walk, run and action_state_machine -> aim.

The action state_machine can controll the top part of the body and the other the actual movement action.
1
Reply
@yukku121
3 weeks ago
Otherwise for each action the player can do: grab, eat, talk,... you'll need to have x2/3 states in the state machine to match with idle, walk,..."



# STATE MACHINE & LANDING ANIMATION REFACTOR

### The Problem: Ghost Coroutines in `_enter()`
Currently, landing animations in `idle.gd`, `walk.gd`, and `sprint.gd` call `await animation_finished()` inside `_enter()`. 
When the player immediately moves upon landing, the state machine transitions to `walk`, but the suspended `_enter()` in `idle` wakes up once the landing animation finishes and executes `super._enter()`, snapping the player back into the `idle` animation while walking.

**Current Workaround:** `handle_animation_state_changed_signal()` dynamically connects and disconnects signals on every `_enter()` and `_exit()`. It functions, but spreads fragile signal-juggling across 6 separate state scripts.

---

### Solutions for Future Refactor

#### Option 1: AnimationTree `OneShot` Node (Recommended — Idiomatic Godot)
Treat landing as an animation-layer concern rather than a state-machine concern:
1. In `AnimationTree`, add a `OneShot` blend node for `land` over the locomotion blend tree.
2. When touching down from `jump`/`fall`, fire `OneShot.ONE_SHOT_REQUEST_FIRE` on the animated model.
3. Locomotion states (`idle`, `walk`, `sprint`) remain 100% synchronous with zero `await`.
4. Completely deletes `handle_animation_state_changed_signal()`, `animation_finished()`, and all dynamic signal connects/disconnects.

#### Option 2: Dedicated `Land` State (Best if landing freezes movement)
If hard landings are meant to briefly lock player movement:
* Make `Land` its own discrete state in the state machine (`Fall` -> `Land` -> `Idle`/`Walk`).
* Input is ignored while in `Land`, keeping all state transitions synchronous without coroutines inside `_enter()`.

#### Option 3: `is_active` Guard (Quick patch if keeping `await`)
If keeping `await` in `_enter()`:
1. Add `var is_active := false` to `state.gd`, set to `true` on entry and `false` on `_exit()`.
2. After `await animation_finished()`, check: `if not is_active: return`.
3. Much cleaner than the current connect/disconnect hack, but still leaves asynchronous coroutines inside a synchronous state machine.



SHOUTOUT TO CHAFF GAMES
