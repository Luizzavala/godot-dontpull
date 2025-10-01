## TestBlockLaunch valida el lanzamiento prolongado de bloques hasta encontrar obstáculos.
extends Node

const BlockScene: PackedScene = preload("res://scenes/entities/Block.tscn")
const GameHelpers = preload("res://scripts/utils/helpers.gd")

func run_tests() -> Array:
    """Ejecuta los casos para el lanzamiento de bloques."""
    return [
        _test_block_travels_until_wall(),
        _test_block_stops_before_other_block(),
    ]


func _test_block_travels_until_wall() -> Dictionary:
    var previous_bounds := GameHelpers.get_map_bounds()
    GameHelpers.set_map_bounds(Rect2i(Vector2i.ZERO, Vector2i(13, 11)))
    var block: Block = BlockScene.instantiate()
    add_child(block)
    var start_grid := Vector2i(1, 5)
    var start_world := GameHelpers.grid_to_world(start_grid)
    block.global_position = start_world
    block.target_position = start_world
    var launched := block.request_slide(Vector2i.RIGHT)
    var final_grid := GameHelpers.world_to_grid(block.target_position)
    var expected_x := GameHelpers.get_map_bounds().size.x - 1
    var result := {
        "name": "El bloque avanza hasta la pared más cercana",
        "passed": launched and final_grid == Vector2i(expected_x, start_grid.y),
    }
    block.queue_free()
    GameHelpers.set_map_bounds(previous_bounds)
    return result


func _test_block_stops_before_other_block() -> Dictionary:
    var previous_bounds := GameHelpers.get_map_bounds()
    GameHelpers.set_map_bounds(Rect2i(Vector2i.ZERO, Vector2i(10, 7)))
    var launcher: Block = BlockScene.instantiate()
    var stopper: Block = BlockScene.instantiate()
    add_child(launcher)
    add_child(stopper)
    var launcher_grid := Vector2i(1, 3)
    var stopper_grid := Vector2i(5, 3)
    launcher.global_position = GameHelpers.grid_to_world(launcher_grid)
    launcher.target_position = launcher.global_position
    stopper.global_position = GameHelpers.grid_to_world(stopper_grid)
    stopper.target_position = stopper.global_position
    var launched := launcher.request_slide(Vector2i.RIGHT)
    var final_grid := GameHelpers.world_to_grid(launcher.target_position)
    var expected_grid := Vector2i(stopper_grid.x - 1, stopper_grid.y)
    var result := {
        "name": "El bloque se detiene antes de otro bloque",
        "passed": launched and final_grid == expected_grid,
    }
    launcher.queue_free()
    stopper.queue_free()
    GameHelpers.set_map_bounds(previous_bounds)
    return result
