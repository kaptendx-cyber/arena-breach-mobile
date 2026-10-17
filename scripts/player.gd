extends CharacterBody3D
signal health_changed(hp: int)
signal ammo_changed(current: int, max_ammo: int)
signal died()
@onready var camera: Camera3D = $Camera3D
@onready var muzzle: Marker3D = $Camera3D/Muzzle
@onready var hud: CanvasLayer = get_node("../HUD")
var health: int = GameConfig.PLAYER_MAX_HEALTH
var ammo: int = GameConfig.WEAPON_MAG_SIZE
var reloading: bool = false
var fire_cooldown: float = 0.0
var pitch: float = 0.0
var move_input: Vector2 = Vector2.ZERO
var look_delta: Vector2 = Vector2.ZERO
var shoot_hold: bool = false
func _ready() -> void:
	health_changed.emit(health)
	ammo_changed.emit(ammo, GameConfig.WEAPON_MAG_SIZE)
	hud.move_changed.connect(_on_move_changed)
	hud.look_changed.connect(_on_look_changed)
	hud.shoot_pressed.connect(_on_shoot_pressed)
	hud.shoot_released.connect(_on_shoot_released)
	hud.reload_pressed.connect(_on_reload_pressed)
	hud.jump_pressed.connect(_on_jump_pressed)
func _on_move_changed(v: Vector2) -> void: move_input = v
func _on_look_changed(d: Vector2) -> void: look_delta += d
func _on_shoot_pressed() -> void: shoot_hold = true
func _on_shoot_released() -> void: shoot_hold = false
func _on_reload_pressed() -> void:
	if not reloading and ammo < GameConfig.WEAPON_MAG_SIZE: _reload()
func _on_jump_pressed() -> void:
	if is_on_floor(): velocity.y = GameConfig.PLAYER_JUMP_VELOCITY
func _physics_process(delta: float) -> void:
	if not is_on_floor(): velocity.y -= get_gravity().y * delta
	if look_delta != Vector2.ZERO:
		rotate_y(-look_delta.x * GameConfig.TOUCH_LOOK_SENSITIVITY)
		pitch = clamp(pitch - look_delta.y * GameConfig.TOUCH_LOOK_SENSITIVITY, GameConfig.PLAYER_PITCH_MIN, GameConfig.PLAYER_PITCH_MAX)
		camera.rotation.x = pitch
		look_delta = Vector2.ZERO
	var dir := (transform.basis * Vector3(move_input.x, 0, move_input.y)).normalized()
	if dir.length() > 0.01:
		velocity.x = dir.x * GameConfig.PLAYER_SPEED
		velocity.z = dir.z * GameConfig.PLAYER_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, GameConfig.PLAYER_SPEED)
		velocity.z = move_toward(velocity.z, 0, GameConfig.PLAYER_SPEED)
	move_and_slide()
	fire_cooldown = max(0.0, fire_cooldown - delta)
	if shoot_hold and fire_cooldown <= 0 and not reloading and ammo > 0: _shoot()
func _shoot() -> void:
	fire_cooldown = GameConfig.WEAPON_FIRE_RATE
	ammo -= 1
	ammo_changed.emit(ammo, GameConfig.WEAPON_MAG_SIZE)
	var bullet_scene: PackedScene = load(GameConfig.SCENE_BULLET)
	var b: Node3D = bullet_scene.instantiate()
	b.global_position = muzzle.global_position
	b.direction = -camera.global_transform.basis.z.normalized()
	b.damage = GameConfig.WEAPON_DAMAGE
	b.speed = GameConfig.WEAPON_BULLET_SPEED
	get_tree().current_scene.add_child(b)
	if ammo <= 0: _reload()
func _reload() -> void:
	reloading = true
	await get_tree().create_timer(GameConfig.WEAPON_RELOAD_TIME).timeout
	ammo = GameConfig.WEAPON_MAG_SIZE
	reloading = false
	ammo_changed.emit(ammo, GameConfig.WEAPON_MAG_SIZE)
func take_damage(amount: int) -> void:
	health -= amount
	health_changed.emit(health)
	if health <= 0:
		died.emit()
		queue_free()
