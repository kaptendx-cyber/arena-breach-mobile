extends Node3D
const FLOOR_MAT := preload("res://assets/materials/floor.tres")
const WALL_MAT := preload("res://assets/materials/wall.tres")
func _ready() -> void:
	_build_floor()
	_build_walls()
	_build_obstacles()
func _make_box(size: Vector3, pos: Vector3, mat: Material) -> StaticBody3D:
	var body := StaticBody3D.new()
	var mesh := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mesh.mesh = bm
	mesh.material_override = mat
	body.add_child(mesh)
	var shape := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = size
	shape.shape = bs
	body.add_child(shape)
	body.position = pos
	add_child(body)
	return body
func _build_floor() -> void:
	var s := GameConfig.ARENA_SIZE
	_make_box(Vector3(s, 0.5, s), Vector3(0, -0.25, 0), FLOOR_MAT)
func _build_walls() -> void:
	var s := GameConfig.ARENA_SIZE
	var h := GameConfig.ARENA_WALL_HEIGHT
	var t := GameConfig.ARENA_WALL_THICKNESS
	_make_box(Vector3(s, h, t), Vector3(0, h / 2.0, s / 2.0), WALL_MAT)
	_make_box(Vector3(s, h, t), Vector3(0, h / 2.0, -s / 2.0), WALL_MAT)
	_make_box(Vector3(t, h, s), Vector3(s / 2.0, h / 2.0, 0), WALL_MAT)
	_make_box(Vector3(t, h, s), Vector3(-s / 2.0, h / 2.0, 0), WALL_MAT)
func _build_obstacles() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1337
	var s := GameConfig.ARENA_SIZE
	for i in GameConfig.OBSTACLE_COUNT:
		var x: float = rng.randf_range(-s / 2.0 + 4, s / 2.0 - 4)
		var z: float = rng.randf_range(-s / 2.0 + 4, s / 2.0 - 4)
		if Vector2(x, z).length() < 5.0: x += 8.0
		var w: float = rng.randf_range(1.5, 3.0)
		var hh: float = rng.randf_range(1.0, 3.0)
		_make_box(Vector3(w, hh, w), Vector3(x, hh / 2.0, z), WALL_MAT)
