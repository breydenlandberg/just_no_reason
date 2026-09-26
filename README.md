# BUGS
- Relatively trivial, but bullets despawn when game is paused

# TODO
- Just make a custom Scaffolding CSGCombiner3D / etc so you don't have Material Override on all of them
- MarginContainer inside AmmoUI (to give margin/padding between the Ammo Graphics, etc)?
- Explicitly return void?
- Underscoring _functions is not ONLY for virtual functions, but for "private" / "internal" functions that function as signal callbacks. While invoked by different entities (virtual invoked by C++ engine loop, signal callbacks invokved by signal emitter), philosophically, both are because of Inversion of Control. Reflect this throughout the project, and also consider how it relates to our "helper" functions.
- Unify player assets and root level assets folders
- Interaction system should be proximity based (i.e. the closest interaction the player is facing), not a pure FIFO stack like it is now
- https://www.youtube.com/watch?v=FvFx1R3p-aw
- We want to be able to pick up ammo always, not just when that weapon is equipped? This probably involves a fully-fledged inventory system already...
- Also we might like to automatically pick up a more full ammo magazine if we have one that is nearly empty...

# FYI
- Character models are Quaternius Ultimate Modular Men
- https://www.youtube.com/watch?v=1WJCHkHFRRA&list=PLhnGgh9GDmn6Cf4_ut7I0VJNHh9Vbfkjv and the following episodes for when you want to add another weapon and all related code
- Although adding different weapons' ammo to another's is impossible in game currently (ie pickups), keep in mind that we don't have specific guards against it if we did indeed set it in editor, eg quasar having AssaultRifleAmmo
