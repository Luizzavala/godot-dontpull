## TestMapLimits garantiza que jugador, bloques y enemigos respeten los bordes del mapa.
extends Node

const PlayerScene: PackedScene = preload("res://scenes/entities/Player.tscn")
const BlockScene: PackedScene = preload("res://scenes/entities/Block.tscn")
const EnemyScene: PackedScene = preload("res://scenes/entities/Enemy.tscn")
const Enums = preload("res://scripts/utils/enums.gd")
const GameHelpers = preload("res://scripts/utils/helpers.gd")

func run_tests() -> Array:
    """Ejecuta todas las verificaciones relacionadas con los límites del mapa."""
    return [
        _test_player_cannot_exit_bounds(),
        _test_block_cannot_slide_outside_bounds(),
        _test_enemy_respects_bounds(),
    ]

func _test_player_cannot_exit_bounds() -> Dictionary:
    var previous_bounds: Rect2i = GameHelpers.get_map_bounds()
    var bounds := Rect2i(Vector2i.ZERO, Vector2i(2, 2))
    GameHelpers.set_map_bounds(bounds)
    var player: Player = PlayerScene.instantiate()
    add_child(player)
    var start_grid := Vector2i.ZERO
    var start_world: Vector2 = GameHelpers.grid_to_world(start_grid)
    player.global_position = start_world
    player.target_position = start_world
    player.state = Enums.PlayerState.IDLE
    player._try_start_move(Vector2i.LEFT)
    var result := {
        "name": "El jugador no puede abandonar el grid por la izquierda",
        "passed": player.target_position.is_equal_approx(start_world)
            and player.state == Enums.PlayerState.IDLE,
    }
    player.queue_free()
    GameHelpers.set_map_bounds(previous_bounds)
    return result

func _test_block_cannot_slide_outside_bounds() -> Dictionary:
    var previous_bounds: Rect2i = GameHelpers.get_map_bounds()
    var bounds := Rect2i(Vector2i.ZERO, Vector2i(2, 2))
    GameHelpers.set_map_bounds(bounds)
    var block: Block = BlockScene.instantiate()
    add_child(block)
    var start_grid := Vector2i(1, 0)
    var start_world: Vector2 = GameHelpers.grid_to_world(start_grid)
    block.global_position = start_world
    block.target_position = start_world
    var slide_started := block.request_slide(Vector2i.RIGHT)
    var result := {
        "name": "El bloque no se desliza fuera de los límites",
        "passed": not slide_started
            and block.target_position.is_equal_approx(start_world),
    }
    block.queue_free()
    GameHelpers.set_map_bounds(previous_bounds)
    return result

func _test_enemy_respects_bounds() -> Dictionary:
    var previous_bounds: Rect2i = GameHelpers.get_map_bounds()
    var bounds := Rect2i(Vector2i.ZERO, Vector2i(2, 2))
    GameHelpers.set_map_bounds(bounds)
    var enemy: Enemy = EnemyScene.instantiate()
    add_child(enemy)
    var start_grid := Vector2i(1, 1)
    var start_world: Vector2 = GameHelpers.grid_to_world(start_grid)
    enemy.global_position = start_world
    enemy.target_position = start_world
    var step_allowed := enemy._attempt_step(Vector2i.RIGHT)
    var result := {
        "name": "El enemigo evita avanzar fuera del mapa",
        "passed": not step_allowed
            and enemy.target_position.is_equal_approx(start_world),
    }
    enemy.queue_free()
    GameHelpers.set_map_bounds(previous_bounds)
    return result
