extends Area3D
var direction: Vector3 = Vector3.FORWARD
var speed: float = 60.0
var damage: int = 25
var life: float = 2.0
func _ready() -> void:
	body_entered.connect(_on_body_entered)
func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	life -= delta
	if life <= 0: queue_free()
func _on_body_entered(body: Node3D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
