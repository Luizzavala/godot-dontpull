## TestOutOfBounds verifica que el offset del mapa no permita abandonar el área jugable.
extends Node

const PlayerScene: PackedScene = preload("res://scenes/entities/Player.tscn")
const Enums = preload("res://scripts/utils/enums.gd")
const GameHelpers = preload("res://scripts/utils/helpers.gd")

func run_tests() -> Array:
    return [
        _test_world_and_grid_conversions_respect_offset(),
        _test_player_cannot_move_beyond_bounds_with_offset(),
    ]

func _test_world_and_grid_conversions_respect_offset() -> Dictionary:
    var previous_bounds: Rect2i = GameHelpers.get_map_bounds()
    var previous_offset: Vector2 = GameHelpers.get_map_offset()
    var grid_size := Vector2i(4, 3)
    GameHelpers.set_map_bounds(Rect2i(Vector2i.ZERO, grid_size))
    GameHelpers.set_map_offset(Vector2(96, 64))
    var grid_position := Vector2i(2, 1)
    var world_position := GameHelpers.grid_to_world(grid_position)
    var converted := GameHelpers.world_to_grid(world_position)
    var result := {
        "name": "La conversión grid↔world mantiene la posición con offset",
        "passed": converted == grid_position,
    }
    GameHelpers.set_map_bounds(previous_bounds)
    GameHelpers.set_map_offset(previous_offset)
    return result

func _test_player_cannot_move_beyond_bounds_with_offset() -> Dictionary:
    var previous_bounds: Rect2i = GameHelpers.get_map_bounds()
    var previous_offset: Vector2 = GameHelpers.get_map_offset()
    GameHelpers.set_map_bounds(Rect2i(Vector2i.ZERO, Vector2i(2, 2)))
    GameHelpers.set_map_offset(Vector2(128, 80))
    var player: Player = PlayerScene.instantiate()
    add_child(player)
    var start_grid := Vector2i(1, 0)
    var start_world: Vector2 = GameHelpers.grid_to_world(start_grid)
    player.global_position = start_world
    player.target_position = start_world
    player.state = Enums.PlayerState.IDLE
    player._try_start_move(Vector2i.RIGHT)
    var result := {
        "name": "El jugador no abandona el área jugable aunque el mapa tenga offset",
        "passed": player.target_position.is_equal_approx(start_world)
            and player.state == Enums.PlayerState.IDLE,
    }
    player.queue_free()
    GameHelpers.set_map_bounds(previous_bounds)
    GameHelpers.set_map_offset(previous_offset)
    return result
