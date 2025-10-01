## SandboxPlayerBlock simula un empuje del bloque mientras el jugador intenta avanzar.
extends Node2D

const Enums = preload("res://scripts/utils/enums.gd")

@onready var block: Block = %Block
@onready var player: Player = %Player

func _ready() -> void:
    """Inicia la interacción jugador/bloque al cargar el sandbox."""
    call_deferred("_simulate_push")

func _simulate_push() -> void:
    """Solicita el movimiento del bloque y la intención de avance del jugador."""
    block.request_slide(Vector2i.RIGHT)
    player.state = Enums.PlayerState.IDLE
    player.target_position = player.global_position
    player._try_start_move(Vector2i.RIGHT)
