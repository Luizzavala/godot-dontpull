extends Node2D

## Escena sandbox para validar la transición Static -> Sliding del bloque.

@onready var block: Block = %Block

func _ready() -> void:
    """Dispara un deslizamiento inicial al cargar la escena."""
    call_deferred("_trigger_slide")

func _trigger_slide() -> void:
    """Solicita el movimiento del bloque hacia la derecha."""
    block.request_slide(Vector2i(1, 0))
