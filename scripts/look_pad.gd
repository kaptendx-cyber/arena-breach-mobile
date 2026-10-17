extends Control
signal look_changed(d: Vector2)
var touch_index: int = -1
var last_pos: Vector2
func _ready() -> void: mouse_filter = Control.MOUSE_FILTER_PASS
func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and touch_index == -1:
			touch_index = event.index
			last_pos = event.position
		elif not event.pressed and event.index == touch_index:
			touch_index = -1
	elif event is InputEventScreenDrag and event.index == touch_index:
		var d := event.position - last_pos
		last_pos = event.position
		look_changed.emit(d)
