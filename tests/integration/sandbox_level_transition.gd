## SandboxLevelTransition muestra el flujo de cambio de nivel al eliminar al último enemigo.
extends Node2D

@onready var level: Level = %Level

func _ready() -> void:
    """Derrota al único enemigo tras un breve retraso para observar la transición."""
    _clear_late()


func _clear_late() -> void:
    await get_tree().create_timer(1.0).timeout
    for enemy: Node in get_tree().get_nodes_in_group("enemies"):
        if enemy.has_method("set_dead_state"):
            enemy.set_dead_state()
