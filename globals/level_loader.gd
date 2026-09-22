extends Node


# signal
signal progress_changed(progress: float)
signal scene_loaded(loaded_scene: PackedScene)
signal load_finished
signal load_failed(_scene_path: String)


# var
var loading_screen: PackedScene = preload('uid://dbg4oeiysyv5n')
var current_loading_screen: CanvasLayer
var loaded_resource: PackedScene
var scene_path: String
var progress: Array = []
var use_sub_threads := true
var is_loading := false


### fn

## virtual
#
func _ready():
	set_process(false)

func _process(_delta: float):
	var load_status = ResourceLoader.load_threaded_get_status(scene_path, progress)
	progress_changed.emit(progress.front())

	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			printerr('Something went wrong trying to load scene: ', scene_path)
			is_loading = false
			set_process(false)

			if is_instance_valid(current_loading_screen):
				current_loading_screen.queue_free()
			load_failed.emit(scene_path)
		ResourceLoader.THREAD_LOAD_LOADED:
			loaded_resource = ResourceLoader.load_threaded_get(scene_path)
			scene_loaded.emit(loaded_resource)
			load_finished.emit()

			is_loading = false
			set_process(false)


## helper
#
func load_scene(_scene_path: String) -> void:
	if is_loading:
		return

	is_loading = true
	scene_path = _scene_path

	var new_loading_screen = loading_screen.instantiate()
	current_loading_screen = new_loading_screen
	add_child(new_loading_screen)
	progress_changed.connect(new_loading_screen._on_progress_changed)
	load_finished.connect(new_loading_screen._on_load_finished, CONNECT_ONE_SHOT)

	await new_loading_screen.loading_screen_ready

	start_load()

func start_load() -> void:
	var error: Error = ResourceLoader.load_threaded_request(scene_path, '', use_sub_threads)
	if not error:
		set_process(true)
	else:
		printerr('Failed to start threaded load: ', error)
		is_loading = false
		if is_instance_valid(current_loading_screen):
			current_loading_screen.queue_free()
		load_failed.emit(scene_path)
