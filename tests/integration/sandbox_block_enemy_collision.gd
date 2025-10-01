## SandboxBlockEnemyCollision permite visualizar el aplastamiento de enemigos por bloques.
extends Node2D

const GameHelpers = preload("res://scripts/utils/helpers.gd")

@onready var block: Block = %Block
@onready var enemy: Enemy = %Enemy


func _ready() -> void:
    """Posiciona al bloque y al enemigo en tiles contiguos y dispara el deslizamiento."""
    var block_position := GameHelpers.grid_to_world(Vector2i.ZERO)
    block.global_position = block_position
    block.target_position = block_position
    var enemy_position := GameHelpers.grid_to_world(Vector2i.RIGHT)
    enemy.global_position = enemy_position
    enemy.target_position = enemy_position
    await get_tree().process_frame
    block.request_slide(Vector2i.RIGHT)
