## TestPowerUpCollection verifica la integración de power-ups dentro de un nivel real.
extends Node

const LevelScene: PackedScene = preload("res://scenes/core/Level.tscn")
const Consts = preload("res://scripts/utils/constants.gd")
const GameHelpers = preload("res://scripts/utils/helpers.gd")

func run_tests() -> Array:
    """Ejecuta las pruebas de integración relacionadas con power-ups."""
    return [
        await _test_level_spawns_and_collects_power_up(),
    ]

func _test_level_spawns_and_collects_power_up() -> Dictionary:
    var tracker := _connect_score_tracker()
    var score_events := tracker["events"]
    var score_callable: Callable = tracker["callable"]
    var before_score: int = score_events["value"]
    var level: Level = LevelScene.instantiate()
    level.level_file = "res://levels/level_01.json"
    add_child(level)
    await get_tree().process_frame
    var power_ups_container: Node2D = level.get_node("%PowerUps")
    var spawned_count := power_ups_container.get_child_count()
    var first_power_up: PowerUp = power_ups_container.get_child(0)
    var grid_position: Vector2i = GameHelpers.world_to_grid(first_power_up.global_position)
    first_power_up.collect()
    var expected_bonus: int = int(Consts.POWER_UP_SCORES["fruit"])
    var after_score: int = score_events["value"]
    GameManager.add_score(-expected_bonus)
    GameManager.score_changed.disconnect(score_callable)
    level.queue_free()
    return {
        "name": "El nivel carga power-ups desde JSON y otorga puntos al recogerlos",
        "passed": spawned_count >= 2 and grid_position == Vector2i(3, 1) and after_score == before_score + expected_bonus,
    }

func _connect_score_tracker() -> Dictionary:
    var score_events := {"value": 0}
    var score_callable := func(value: int) -> void:
        score_events["value"] = value
    GameManager.score_changed.connect(score_callable)
    GameManager.add_score(0)
    return {
        "events": score_events,
        "callable": score_callable,
    }
