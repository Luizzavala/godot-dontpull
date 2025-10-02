## TestCameraCenter verifica que la cámara se mantenga centrada tras cambios de viewport.
extends Node

const LevelScene: PackedScene = preload("res://scenes/core/Level.tscn")
const Consts = preload("res://scripts/utils/constants.gd")
const GameHelpers = preload("res://scripts/utils/helpers.gd")

func run_tests() -> Array:
    return [
        await _test_camera_repositions_on_resize(),
        await _test_camera_zoom_matches_helper(),
        await _test_entities_follow_offset(),
    ]

func _test_camera_repositions_on_resize() -> Dictionary:
    var previous_bounds: Rect2i = GameHelpers.get_map_bounds()
    var previous_offset: Vector2 = GameHelpers.get_map_offset()
    var level: Level = LevelScene.instantiate()
    add_child(level)
    await get_tree().process_frame
    var viewport: Viewport = level.get_viewport()
    var original_size: Vector2i = viewport.size
    viewport.size = Vector2i(960, 720)
    await get_tree().process_frame
    await get_tree().process_frame
    var bounds: Rect2i = GameHelpers.get_map_bounds()
    var grid_pixel_size: Vector2 = Vector2(bounds.size) * Consts.TILE_SIZE
    var offset: Vector2 = GameHelpers.get_map_offset()
    var camera: Camera2D = level.get_node("%Camera2D")
    var expected_position: Vector2 = offset + grid_pixel_size * 0.5
    var passed := camera.position.is_equal_approx(expected_position)
    viewport.size = original_size
    await get_tree().process_frame
    level.queue_free()
    await get_tree().process_frame
    GameHelpers.set_map_bounds(previous_bounds)
    GameHelpers.set_map_offset(previous_offset)
    return {
        "name": "La cámara permanece centrada tras redimensionar el viewport",
        "passed": passed,
    }

func _test_camera_zoom_matches_helper() -> Dictionary:
    var previous_bounds: Rect2i = GameHelpers.get_map_bounds()
    var previous_offset: Vector2 = GameHelpers.get_map_offset()
    var level: Level = LevelScene.instantiate()
    add_child(level)
    await get_tree().process_frame
    var viewport: Viewport = level.get_viewport()
    var original_size: Vector2i = viewport.size
    viewport.size = Vector2i(1280, 960)
    await get_tree().process_frame
    await get_tree().process_frame
    var bounds: Rect2i = GameHelpers.get_map_bounds()
    var viewport_size: Vector2 = level.get_viewport_rect().size
    var expected_zoom: Vector2 = GameHelpers.calculate_zoom_to_fit(bounds.size, viewport_size)
    var camera: Camera2D = level.get_node("%Camera2D")
    var passed := camera.zoom.is_equal_approx(expected_zoom)
    viewport.size = original_size
    await get_tree().process_frame
    level.queue_free()
    await get_tree().process_frame
    GameHelpers.set_map_bounds(previous_bounds)
    GameHelpers.set_map_offset(previous_offset)
    return {
        "name": "El zoom de la cámara coincide con el cálculo de GameHelpers",
        "passed": passed,
    }

func _test_entities_follow_offset() -> Dictionary:
    var previous_bounds: Rect2i = GameHelpers.get_map_bounds()
    var previous_offset: Vector2 = GameHelpers.get_map_offset()
    var level: Level = LevelScene.instantiate()
    add_child(level)
    await get_tree().process_frame
    var viewport: Viewport = level.get_viewport()
    var original_size: Vector2i = viewport.size
    viewport.size = Vector2i(960, 720)
    await get_tree().process_frame
    await get_tree().process_frame
    var player: Player = level.get_node("%Player")
    var player_grid: Vector2i = GameHelpers.world_to_grid(player.global_position)
    var expected_player_position: Vector2 = GameHelpers.grid_to_world(player_grid)
    var passed := player.global_position.is_equal_approx(expected_player_position)
    var block: Block = level.get_node_or_null("%Block")
    if block != null:
        var block_grid: Vector2i = GameHelpers.world_to_grid(block.global_position)
        var expected_block_position: Vector2 = GameHelpers.grid_to_world(block_grid)
        passed = passed and block.global_position.is_equal_approx(expected_block_position)
    var power_up: PowerUp = level.get_node_or_null("%PowerUp")
    if power_up != null:
        var power_up_grid: Vector2i = GameHelpers.world_to_grid(power_up.global_position)
        var expected_power_up_position: Vector2 = GameHelpers.grid_to_world(power_up_grid)
        passed = passed and power_up.global_position.is_equal_approx(expected_power_up_position)
    viewport.size = original_size
    await get_tree().process_frame
    level.queue_free()
    await get_tree().process_frame
    GameHelpers.set_map_bounds(previous_bounds)
    GameHelpers.set_map_offset(previous_offset)
    return {
        "name": "Las entidades mantienen alineación con el grid tras recalcular el offset",
        "passed": passed,
    }
