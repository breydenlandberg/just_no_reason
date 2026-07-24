class_name InputManager

# static var
static var freefly := 'freefly'
static var forward := 'up'
static var back := 'down'
static var left := 'left'
static var right := 'right'
static var jump := 'jump'
static var aim := 'aim'
static var sprint := 'sprint'
static var crouch := 'crouch'
static var interact := 'interact'
static var swap_camera_alignment := 'swap_camera_alignment'
static var attack_basic := 'attack_basic'
static var equip_unequip := 'equip_unequip'
static var shoot := 'shoot'
static var reload_input := 'reload' # the name reload is defined in the base Script class... leading to shadowing and downstream errors... make it reload_input instead
static var change_weapon := 'change_weapon'
