extends CanvasLayer
signal move_changed(v: Vector2)
signal look_changed(d: Vector2)
signal shoot_pressed()
signal shoot_released()
signal reload_pressed()
signal jump_pressed()
@onready var hp_label: Label = $Root/Stats/VBox/HP
@onready var ammo_label: Label = $Root/Stats/VBox/Ammo
@onready var wave_label: Label = $Root/Stats/VBox/Wave
@onready var enemy_label: Label = $Root/Stats/VBox/Enemies
@onready var joystick: Control = $Root/Joystick
@onready var look_pad: Control = $Root/LookPad
@onready var fire_btn: Button = $Root/FireButton
@onready var reload_btn: Button = $Root/ReloadButton
@onready var jump_btn: Button = $Root/JumpButton
@onready var game_over_panel: Panel = $Root/GameOverPanel
@onready var game_over_label: Label = $Root/GameOverPanel/GameOverLabel
func _ready() -> void:
	game_over_panel.visible = false
	joystick.move_changed.connect(func(v): move_changed.emit(v))
	look_pad.look_changed.connect(func(d): look_changed.emit(d))
	fire_btn.button_down.connect(func(): shoot_pressed.emit())
	fire_btn.button_up.connect(func(): shoot_released.emit())
	reload_btn.pressed.connect(func(): reload_pressed.emit())
	jump_btn.pressed.connect(func(): jump_pressed.emit())
func set_health(hp: int) -> void: hp_label.text = "HP: %d" % hp
func set_ammo(current: int, max_ammo: int) -> void: ammo_label.text = "AMMO: %d / %d" % [current, max_ammo]
func set_wave(wave: int) -> void: wave_label.text = "WAVE: %d / %d" % [wave, GameConfig.WAVE_MAX]
func set_enemy_count(n: int) -> void: enemy_label.text = "ENEMIES: %d" % n
func show_game_over(won: bool, wave: int) -> void:
	game_over_panel.visible = true
	game_over_label.text = ("VICTORY — Wave %d" % wave) if won else ("GAME OVER — Reached Wave %d" % wave)
