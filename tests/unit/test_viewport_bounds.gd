## TestViewportBounds comprueba que el área visible coincide con los límites de colisión.
extends Node

const LevelScene: PackedScene = preload("res://scenes/core/Level.tscn")
const Consts = preload("res://scripts/utils/constants.gd")
const GameHelpers = preload("res://scripts/utils/helpers.gd")

func run_tests() -> Array:
    return [
        await _test_playable_area_matches_bounds(),
        await _test_letterbox_background_tracks_viewport(),
    ]

func _test_playable_area_matches_bounds() -> Dictionary:
    var previous_bounds: Rect2i = GameHelpers.get_map_bounds()
    var previous_offset: Vector2 = GameHelpers.get_map_offset()
    var level: Level = LevelScene.instantiate()
    add_child(level)
    await get_tree().process_frame
    var bounds: Rect2i = GameHelpers.get_map_bounds()
    var expected_size: Vector2 = Vector2(bounds.size) * Consts.TILE_SIZE
    var offset: Vector2 = GameHelpers.get_map_offset()
    var playable_area: ColorRect = level.get_node("%PlayableArea")
    var tile_map: TileMap = level.get_node("%GroundTileMap")
    var last_cell_center: Vector2 = GameHelpers.grid_to_world(bounds.position + bounds.size - Vector2i.ONE)
    var first_cell_center: Vector2 = GameHelpers.grid_to_world(bounds.position)
    var playable_rect := Rect2(offset, expected_size)
    var all_checks := playable_area.position.is_equal_approx(offset)
        and playable_area.size.is_equal_approx(expected_size)
        and tile_map.position.is_equal_approx(offset)
        and playable_rect.has_point(first_cell_center)
        and playable_rect.has_point(last_cell_center)
    level.queue_free()
    await get_tree().process_frame
    GameHelpers.set_map_bounds(previous_bounds)
    GameHelpers.set_map_offset(previous_offset)
    return {
        "name": "El rectángulo visible coincide con el grid definido por colisiones",
        "passed": all_checks,
    }

func _test_letterbox_background_tracks_viewport() -> Dictionary:
    var previous_bounds: Rect2i = GameHelpers.get_map_bounds()
    var previous_offset: Vector2 = GameHelpers.get_map_offset()
    var level: Level = LevelScene.instantiate()
    add_child(level)
    await get_tree().process_frame
    var viewport: Viewport = level.get_viewport()
    var original_size: Vector2i = viewport.size
    var test_size := Vector2i(960, 720)
    viewport.size = test_size
    await get_tree().process_frame
    await get_tree().process_frame
    var viewport_size: Vector2 = level.get_viewport_rect().size
    var background: ColorRect = level.get_node("%NonPlayableBackground")
    var playable_area: ColorRect = level.get_node("%PlayableArea")
    var camera: Camera2D = level.get_node("%Camera2D")
    var bounds: Rect2i = GameHelpers.get_map_bounds()
    var expected_size: Vector2 = Vector2(bounds.size) * Consts.TILE_SIZE
    var offset: Vector2 = GameHelpers.get_map_offset()
    var camera_expected_position: Vector2 = offset + expected_size * 0.5
    var checks := background.position.is_equal_approx(Vector2.ZERO)
        and background.size.is_equal_approx(viewport_size)
        and playable_area.position.is_equal_approx(offset)
        and playable_area.size.is_equal_approx(expected_size)
        and camera.position.is_equal_approx(camera_expected_position)
    viewport.size = original_size
    await get_tree().process_frame
    level.queue_free()
    await get_tree().process_frame
    GameHelpers.set_map_bounds(previous_bounds)
    GameHelpers.set_map_offset(previous_offset)
    return {
        "name": "El letterboxing cubre el viewport y la cámara permanece centrada",
        "passed": checks,
    }
