extends Node2D

## Escena sandbox que acerca al jugador para activar el estado Chase del enemigo.

@onready var enemy: Enemy = %Enemy
@onready var player: Player = %Player

func _ready() -> void:
    """Posiciona a los agentes y provoca la persecución."""
    player.global_position = GameHelpers.grid_to_world(Vector2i(0, 2))
    player.target_position = player.global_position
    enemy.global_position = GameHelpers.grid_to_world(Vector2i(4, 2))
    enemy.target_position = enemy.global_position
    call_deferred("_move_player_into_range")

func _move_player_into_range() -> void:
    """Coloca al jugador junto al enemigo para forzar el cambio de estado."""
    player.global_position = GameHelpers.grid_to_world(Vector2i(3, 2))
    player.target_position = player.global_position
