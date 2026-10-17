extends Control
signal move_changed(v: Vector2)
var base_pos: Vector2
var thumb_pos: Vector2
var active: bool = false
var touch_index: int = -1
func _ready() -> void: mouse_filter = Control.MOUSE_FILTER_PASS
func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and touch_index == -1:
			touch_index = event.index
			active = true
			base_pos = event.position
			thumb_pos = base_pos
			queue_redraw()
		elif not event.pressed and event.index == touch_index:
			touch_index = -1
			active = false
			move_changed.emit(Vector2.ZERO)
			queue_redraw()
	elif event is InputEventScreenDrag and event.index == touch_index and active:
		var d := event.position - base_pos
		var r := GameConfig.JOYSTICK_RADIUS_PX
		if d.length() > r: d = d.normalized() * r
		thumb_pos = base_pos + d
		var v := d / r
		if v.length() < GameConfig.JOYSTICK_DEADZONE: v = Vector2.ZERO
		move_changed.emit(v)
		queue_redraw()
func _draw() -> void:
	if not active: return
	var r := GameConfig.JOYSTICK_RADIUS_PX
	draw_circle(base_pos, r, Color(1, 1, 1, 0.12))
	draw_arc(base_pos, r, 0, TAU, 48, Color(1, 1, 1, 0.35), 2.0)
	draw_circle(thumb_pos, r * 0.35, Color(1, 1, 1, 0.45))
