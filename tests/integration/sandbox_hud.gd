## SandboxHUD permite visualizar la reubicación del HUD y el temporizador.
extends Node2D

func _ready() -> void:
    """Inicializa valores de ejemplo para visualizar el HUD."""
    GameManager.add_score(100)
    GameManager.set_lives(5)
    GameManager.level_started.emit("Sandbox HUD")
