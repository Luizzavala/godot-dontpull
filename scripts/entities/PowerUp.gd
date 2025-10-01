## PowerUp gestiona la recogida de ítems de bonificación por el jugador.
extends Area2D
class_name PowerUp

signal collected(power_up: PowerUp, score_awarded: int)

const Consts = preload("res://scripts/utils/constants.gd")

@export var power_up_type: StringName = "fruit"
@export var score_value: int = 0
var target_position: Vector2 = Vector2.ZERO
var _collected: bool = false

func _ready() -> void:
    """Inicializa el power-up registrando señales y valores por defecto."""
    add_to_group("power_ups")
    body_entered.connect(_on_body_entered)
    if score_value <= 0:
        score_value = _resolve_score_from_type()

func collect() -> void:
    """Otorga la bonificación asociada si aún no fue recogido."""
    if _collected:
        return
    _collected = true
    var bonus: int = score_value if score_value > 0 else _resolve_score_from_type()
    collected.emit(self, bonus)
    var audio_manager := _get_audio_manager()
    if audio_manager:
        audio_manager.play_power_up()
    _apply_score_bonus(bonus)
    queue_free()

func _on_body_entered(body: Node) -> void:
    """Detecta al jugador y aplica la recogida automática."""
    if body is Player:
        collect()

func _resolve_score_from_type() -> int:
    """Resuelve la puntuación asociada al tipo configurado."""
    var type_key := String(power_up_type)
    if Consts.POWER_UP_SCORES.has(type_key):
        return int(Consts.POWER_UP_SCORES[type_key])
    return Consts.POWER_UP_DEFAULT_SCORE

func _apply_score_bonus(bonus: int) -> void:
    """Suma el puntaje del bonus a través del GameManager global."""
    if bonus == 0:
        return
    GameManager.add_score(bonus)

func _get_audio_manager() -> AudioManagerService:
    var tree := get_tree()
    if tree == null:
        return null
    var root := tree.root
    if root == null:
        return null
    return root.get_node_or_null("AudioManager") as AudioManagerService
