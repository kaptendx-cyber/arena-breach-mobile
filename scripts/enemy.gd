extends CharacterBody3D
signal died()
@onready var nav: NavigationAgent3D = $NavigationAgent3D
var target: CharacterBody3D = null
var health: int = GameConfig.ENEMY_BASE_HEALTH
var attack_cooldown: float = 0.0
var dead: bool = false
func _ready() -> void:
	nav.path_desired_distance = 0.5
	nav.target_desired_distance = 1.5
	nav.path_height_offset = 0.5
func _physics_process(delta: float) -> void:
	if dead or target == null or not is_instance_valid(target): return
	if not is_on_floor(): velocity.y -= get_gravity().y * delta
	attack_cooldown = max(0.0, attack_cooldown - delta)
	var to_target := target.global_position - global_position
	var dist := to_target.length()
	if dist <= GameConfig.ENEMY_ATTACK_RANGE:
		velocity.x = 0
		velocity.z = 0
		if attack_cooldown <= 0.0:
			target.take_damage(GameConfig.ENEMY_DAMAGE)
			attack_cooldown = GameConfig.ENEMY_ATTACK_COOLDOWN
	else:
		nav.target_position = target.global_position
		var next := nav.get_next_path_position()
		var dir := (next - global_position).normalized()
		velocity.x = dir.x * GameConfig.ENEMY_SPEED
		velocity.z = dir.z * GameConfig.ENEMY_SPEED
		if dir.length() > 0.01:
			look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP)
	move_and_slide()
func take_damage(amount: int) -> void:
	if dead: return
	health -= amount
	if health <= 0: _die()
func _die() -> void:
	dead = true
	died.emit()
	queue_free()
