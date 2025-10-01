## TestPlayerBlockCollision verifica que el jugador no se superpone con un bloque en movimiento.
extends Node

const BlockScene: PackedScene = preload("res://scenes/entities/Block.tscn")
const PlayerScene: PackedScene = preload("res://scenes/entities/Player.tscn")
const Enums = preload("res://scripts/utils/enums.gd")
const GameHelpers = preload("res://scripts/utils/helpers.gd")

func run_tests() -> Array:
    """Ejecuta las validaciones de colisión jugador/bloque."""
    return [
        _test_player_stays_behind_sliding_block(),
    ]

func _test_player_stays_behind_sliding_block() -> Dictionary:
    var block: Block = BlockScene.instantiate()
    var player: Player = PlayerScene.instantiate()
    add_child(block)
    add_child(player)
    var block_grid := Vector2i.ZERO
    var player_grid := Vector2i(-1, 0)
    var block_start: Vector2 = GameHelpers.grid_to_world(block_grid)
    var player_start: Vector2 = GameHelpers.grid_to_world(player_grid)
    block.global_position = block_start
    block.target_position = block_start
    player.global_position = player_start
    player.target_position = player_start
    player.state = Enums.PlayerState.IDLE
    var slide_started: bool = block.request_slide(Vector2i.RIGHT)
    player._try_start_move(Vector2i.RIGHT)
    var player_grid_after := GameHelpers.world_to_grid(player.target_position)
    var block_grid_target := GameHelpers.world_to_grid(block.target_position)
    var result := {
        "name": "El jugador no avanza a la casilla ocupada por un bloque deslizándose",
        "passed": slide_started
            and player.state == Enums.PlayerState.IDLE
            and player_grid_after != block_grid_target,
    }
    block.queue_free()
    player.queue_free()
    return result
