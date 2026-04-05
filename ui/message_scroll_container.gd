extends ScrollContainer


# var
var max_scroll_length := 0

# @onready
@onready var scrollbar = get_v_scroll_bar()


### fn

## virtual
#
func _ready():
	scrollbar.changed.connect(handle_scrollbar_changed)
	max_scroll_length = scrollbar.max_value


## helper
#
func handle_scrollbar_changed():
	if max_scroll_length != scrollbar.max_value:
		max_scroll_length = scrollbar.max_value
		self.scroll_vertical = max_scroll_length
