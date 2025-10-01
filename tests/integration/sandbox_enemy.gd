## SandboxEnemy prepara un escenario para activar el estado Chase del enemigo.
extends Node2D

const Consts = preload("res://scripts/utils/constants.gd")

@onready var enemy: Enemy = %Enemy
@onready var player: Player = %Player

func _ready() -> void:
    """Posiciona a los agentes y provoca la persecución."""
    player.global_position = GameHelpers.grid_to_world(Consts.PLAYER_START)
    player.target_position = player.global_position
    enemy.global_position = GameHelpers.grid_to_world(Consts.ENEMY_START)
    enemy.target_position = enemy.global_position
    call_deferred("_move_player_into_range")

func _move_player_into_range() -> void:
    """Coloca al jugador junto al enemigo para forzar el cambio de estado."""
    var approach_cell: Vector2i = Consts.ENEMY_START + Vector2i.LEFT
    player.global_position = GameHelpers.grid_to_world(approach_cell)
    player.target_position = player.global_position
