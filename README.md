# BUGS
- Gravity when falling off (not jumping) seems borked
- Unarmed AimWalk into Armed... need to reset that fov. More broadly, we should _exit() the Unarmed/ArmedStateMachine's current_state before stopping it and starting the other.
- Check Armed Walk into Unarmed Walk back into Armed Walk... animation is fucked 
- Falling while zoomed (unarmed) is bugged
- With quasar weapon aim then reload then unaim... bugged

# TODO
- AimFall when aiming while in Jump, Fall, SprintJump, SprintFall
- Interaction system should be proximity based (i.e. the closest interaction the player is facing), not a pure FIFO stack like it is now
- https://www.youtube.com/watch?v=FvFx1R3p-aw

# FYI
- Character models are Quaternius Ultimate Modular Men
- https://www.youtube.com/watch?v=1WJCHkHFRRA&list=PLhnGgh9GDmn6Cf4_ut7I0VJNHh9Vbfkjv and the following episodes for when you want to add another weapon and all related code



"As a recommendation, you can create a separate state machine to control the action in the upper body. That will avoid you having to do x100 crossovers of actions. E.g. instead of having: idle, idle-aim, walk, walk-aim, run, run-aim you'll have: state_machine -> idle, walk, run and action_state_machine -> aim.

The action state_machine can controll the top part of the body and the other the actual movement action.
1
Reply
@yukku121
3 weeks ago
Otherwise for each action the player can do: grab, eat, talk,... you'll need to have x2/3 states in the state machine to match with idle, walk,..."
