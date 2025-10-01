extends Node

const BlockScene: PackedScene = preload("res://scenes/entities/Block.tscn")
const PowerUpScene: PackedScene = preload("res://scenes/entities/PowerUp.tscn")
const GameHelpers = preload("res://scripts/utils/helpers.gd")

class MockAudioStreamPlayer:
    extends AudioStreamPlayer
    var play_count := 0
    var stop_count := 0

    func play(from_position: float = 0.0) -> void:
        play_count += 1

    func stop() -> void:
        stop_count += 1

func run_tests() -> Array:
    return [
        _test_bgm_triggers_on_level_start(),
        _test_block_launch_triggers_audio(),
        _test_block_destroy_triggers_audio(),
        _test_enemy_crush_triggers_audio(),
        _test_power_up_collect_triggers_audio(),
        _test_game_over_triggers_audio(),
    ]

func _test_bgm_triggers_on_level_start() -> Dictionary:
    var player := _override_player(AudioManager.EVENT_BGM)
    GameManager.start_level("Audio Hook Stage", "")
    return {
        "name": "El inicio de nivel dispara el BGM",
        "passed": player.play_count == 1,
    }

func _test_block_launch_triggers_audio() -> Dictionary:
    var player := _override_player(AudioManager.EVENT_BLOCK_LAUNCH)
    var previous_bounds := GameHelpers.get_map_bounds()
    GameHelpers.set_map_bounds(Rect2i(Vector2i.ZERO, Vector2i(5, 5)))
    var block: Block = BlockScene.instantiate()
    add_child(block)
    var start_grid := Vector2i(1, 2)
    block.global_position = GameHelpers.grid_to_world(start_grid)
    block.target_position = block.global_position
    var launched := block.request_slide(Vector2i.RIGHT)
    var result := {
        "name": "El lanzamiento de bloques reproduce audio",
        "passed": launched and player.play_count == 1,
    }
    block.queue_free()
    GameHelpers.set_map_bounds(previous_bounds)
    return result

func _test_block_destroy_triggers_audio() -> Dictionary:
    var player := _override_player(AudioManager.EVENT_BLOCK_DESTROY)
    var block: Block = BlockScene.instantiate()
    add_child(block)
    block.global_position = Vector2.ZERO
    block.target_position = block.global_position
    block.destroy_block()
    var result := {
        "name": "La destrucción de bloques reproduce audio",
        "passed": player.play_count == 1,
    }
    block.queue_free()
    return result

func _test_enemy_crush_triggers_audio() -> Dictionary:
    var player := _override_player(AudioManager.EVENT_ENEMY_CRUSH)
    var enemy := Enemy.new()
    GameManager.on_enemy_defeated(enemy)
    var result := {
        "name": "Aplastar enemigos reproduce audio",
        "passed": player.play_count == 1,
    }
    return result

func _test_power_up_collect_triggers_audio() -> Dictionary:
    var player := _override_player(AudioManager.EVENT_POWER_UP)
    var power_up: PowerUp = PowerUpScene.instantiate()
    add_child(power_up)
    power_up.collect()
    var result := {
        "name": "Recoger power-up reproduce audio",
        "passed": player.play_count == 1,
    }
    power_up.queue_free()
    return result

func _test_game_over_triggers_audio() -> Dictionary:
    var player := _override_player(AudioManager.EVENT_GAME_OVER)
    var previous_lives := GameManager.get("_lives")
    var previous_game_over := GameManager.get("_is_game_over")
    GameManager.set_lives(0)
    var result := {
        "name": "Game Over reproduce audio",
        "passed": player.play_count == 1,
    }
    GameManager.set("_lives", previous_lives)
    GameManager.set("_is_game_over", previous_game_over)
    if previous_lives > 0:
        GameManager.set_lives(previous_lives)
    return result

func _override_player(event_name: StringName) -> MockAudioStreamPlayer:
    var mock := MockAudioStreamPlayer.new()
    AudioManager.set_player_override(event_name, mock)
    return mock
