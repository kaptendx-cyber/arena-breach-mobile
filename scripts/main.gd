extends Node3D
@onready var enemy_container: Node3D = $EnemyContainer
@onready var spawn_timer: Timer = $SpawnTimer
@onready var hud: CanvasLayer = $HUD
@onready var player: CharacterBody3D = $Player
var current_wave: int = 0
var enemies_alive: int = 0
var enemies_to_spawn: int = 0
var game_over: bool = false
var wave_active: bool = false
signal wave_started(wave: int)
signal wave_cleared(wave: int)
signal game_ended(won: bool)
func _ready() -> void:
	spawn_timer.wait_time = GameConfig.SPAWN_INTERVAL
	spawn_timer.timeout.connect(_on_spawn_tick)
	player.health_changed.connect(_on_player_health_changed)
	player.died.connect(_on_player_died)
	start_wave()
func start_wave() -> void:
	current_wave += 1
	if current_wave > GameConfig.WAVE_MAX:
		_end_game(true)
		return
	enemies_to_spawn = GameConfig.WAVE_BASE_COUNT + (current_wave - 1) * GameConfig.WAVE_COUNT_MULT
	enemies_alive = 0
	wave_active = true
	wave_started.emit(current_wave)
	hud.set_wave(current_wave)
	spawn_timer.start()
func _on_spawn_tick() -> void:
	if not wave_active: return
	if enemies_to_spawn <= 0:
		spawn_timer.stop()
		return
	_spawn_enemy()
	enemies_to_spawn -= 1
func _spawn_enemy() -> void:
	var enemy_scene: PackedScene = load(GameConfig.SCENE_ENEMY)
	var e: CharacterBody3D = enemy_scene.instantiate()
	var angle: float = randf() * TAU
	var r: float = GameConfig.SPAWN_RADIUS
	e.position = Vector3(cos(angle) * r, 1.0, sin(angle) * r)
	e.target = player
	e.died.connect(_on_enemy_died)
	e.health = GameConfig.ENEMY_BASE_HEALTH + (current_wave - 1) * 10
	enemy_container.add_child(e)
	enemies_alive += 1
func _on_enemy_died() -> void:
	enemies_alive -= 1
	hud.set_enemy_count(enemies_alive)
	if enemies_alive <= 0 and enemies_to_spawn <= 0 and wave_active:
		wave_active = false
		wave_cleared.emit(current_wave)
		await get_tree().create_timer(GameConfig.WAVE_INTERMISSION).timeout
		if not game_over: start_wave()
func _on_player_health_changed(new_hp: int) -> void:
	hud.set_health(new_hp)
func _on_player_died() -> void:
	_end_game(false)
func _end_game(won: bool) -> void:
	game_over = true
	wave_active = false
	spawn_timer.stop()
	game_ended.emit(won)
	hud.show_game_over(won, current_wave)
