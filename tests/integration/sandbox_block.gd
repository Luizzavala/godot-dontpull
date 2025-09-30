## SandboxBlock valida la transición Static -> Sliding del bloque.
extends Node2D

@onready var block: Block = %Block

func _ready() -> void:
    """Dispara un deslizamiento inicial al cargar la escena."""
    call_deferred("_trigger_slide")

func _trigger_slide() -> void:
    """Solicita el movimiento del bloque hacia la derecha."""
    block.request_slide(Vector2i.RIGHT)
