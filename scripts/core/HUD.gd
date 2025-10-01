## HUD gestiona la visualización del score, vidas, nivel y temporizador del nivel.
extends CanvasLayer
class_name HUD

signal score_updated(new_score: int)
signal lives_updated(new_lives: int)

@onready var score_label: Label = %ScoreValue
@onready var lives_label: Label = %LivesValue
@onready var level_label: Label = %LevelValue
@onready var timer_label: Label = %TimerLabel
@onready var message_label: Label = %LevelMessage
@onready var high_score_label: Label = %HighScoreValue
@onready var high_score_panel: Panel = %HighScorePanel
@onready var initials_input: LineEdit = %InitialsInput
@onready var submit_initials_button: Button = %SubmitInitialsButton

var _is_timer_running := false
var _elapsed_time := 0.0
var _initials_submitted := false


func _ready() -> void:
    """Conecta el HUD al GameManager y muestra valores iniciales."""
    set_process(true)
    timer_label.text = _format_time(0.0)
    _hide_level_message()
    GameManager.score_changed.connect(_on_score_changed)
    GameManager.lives_changed.connect(_on_lives_changed)
    GameManager.level_started.connect(_on_level_started)
    GameManager.level_cleared.connect(_on_level_cleared)
    GameManager.game_over.connect(_on_game_over)
    GameManager.high_score_changed.connect(_on_high_score_changed)
    GameManager.register_hud(self)
    high_score_label.text = str(GameManager.get_high_score())
    high_score_panel.visible = false
    initials_input.text_changed.connect(_on_initials_text_changed)
    initials_input.text_submitted.connect(_on_initials_submitted)
    submit_initials_button.pressed.connect(_on_submit_initials_pressed)


func _process(delta: float) -> void:
    """Actualiza el temporizador cuando el nivel está activo."""
    if not _is_timer_running:
        return

    _elapsed_time += delta
    timer_label.text = _format_time(_elapsed_time)


func _on_score_changed(value: int) -> void:
    """Actualiza el label de score cuando cambia el valor."""
    score_label.text = str(value)
    emit_signal("score_updated", value)


func _on_lives_changed(value: int) -> void:
    """Actualiza el label de vidas cuando cambia el valor."""
    lives_label.text = str(value)
    emit_signal("lives_updated", value)


func _on_level_started(level_name: String) -> void:
    """Muestra el nombre del nivel activo y reinicia el temporizador."""
    level_label.text = level_name
    _elapsed_time = 0.0
    timer_label.text = _format_time(_elapsed_time)
    _is_timer_running = true
    _hide_level_message()


func _on_level_cleared(_level_name: String) -> void:
    """Muestra un mensaje temporal cuando el nivel ha sido completado."""
    _show_level_message("LEVEL CLEAR!")


func _on_game_over() -> void:
    """Detiene el temporizador cuando el juego termina."""
    _is_timer_running = false
    _show_level_message("GAME OVER")
    _show_high_score_entry()


func _on_high_score_changed(value: int) -> void:
    """Actualiza el label del high score."""
    high_score_label.text = str(value)


func _format_time(time_seconds: float) -> String:
    """Convierte segundos en formato MM:SS."""
    var total_seconds: int = int(time_seconds)
    var minutes := total_seconds / 60
    var seconds := total_seconds % 60
    return "%02d:%02d" % [minutes, seconds]


func _show_level_message(text: String) -> void:
    message_label.text = text
    message_label.visible = true


func _hide_level_message() -> void:
    message_label.visible = false


func _show_high_score_entry() -> void:
    high_score_panel.visible = true
    _initials_submitted = false
    initials_input.editable = true
    submit_initials_button.disabled = false
    initials_input.text = ""
    await get_tree().process_frame
    initials_input.grab_focus()


func _on_initials_text_changed(new_text: String) -> void:
    var sanitized := new_text.strip_edges().to_upper()
    if sanitized.length() > 3:
        sanitized = sanitized.substr(0, 3)
    if sanitized != initials_input.text:
        initials_input.text = sanitized
        initials_input.caret_column = sanitized.length()


func _on_initials_submitted(_text: String) -> void:
    _submit_initials()


func _on_submit_initials_pressed() -> void:
    _submit_initials()


func _submit_initials() -> void:
    if _initials_submitted:
        return
    _initials_submitted = true
    initials_input.editable = false
    submit_initials_button.disabled = true
    GameManager.submit_final_score(initials_input.text)
