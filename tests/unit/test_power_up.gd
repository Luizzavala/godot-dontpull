## TestPowerUp valida la recogida de ítems de bonus y su integración con el GameManager.
extends Node

const PowerUpScene: PackedScene = preload("res://scenes/entities/PowerUp.tscn")
const Consts = preload("res://scripts/utils/constants.gd")

func run_tests() -> Array:
    """Ejecuta los casos unitarios de los power-ups."""
    return [
        _test_collect_emits_signal_and_score(),
        _test_collect_uses_custom_score(),
    ]

func _test_collect_emits_signal_and_score() -> Dictionary:
    var tracker := _connect_score_tracker()
    var score_events := tracker["events"]
    var score_callable: Callable = tracker["callable"]
    var before_score: int = score_events["value"]
    var signal_tracker := {"value": 0}
    var power_up: PowerUp = PowerUpScene.instantiate()
    add_child(power_up)
    power_up.power_up_type = StringName("fruit")
    power_up.collected.connect(func(_item: PowerUp, amount: int) -> void: signal_tracker["value"] = amount)
    power_up.collect()
    var awarded: int = signal_tracker["value"]
    var after_score: int = score_events["value"]
    var expected: int = int(Consts.POWER_UP_SCORES["fruit"])
    GameManager.add_score(-awarded)
    GameManager.score_changed.disconnect(score_callable)
    if is_instance_valid(power_up):
        power_up.queue_free()
    return {
        "name": "El power-up de fruta suma el score y emite señal de recogida",
        "passed": awarded == expected and after_score == before_score + expected,
    }

func _test_collect_uses_custom_score() -> Dictionary:
    var tracker := _connect_score_tracker()
    var score_events := tracker["events"]
    var score_callable: Callable = tracker["callable"]
    var before_score: int = score_events["value"]
    var custom_score := 320
    var power_up: PowerUp = PowerUpScene.instantiate()
    add_child(power_up)
    power_up.power_up_type = StringName("gem")
    power_up.score_value = custom_score
    power_up.collect()
    var after_score: int = score_events["value"]
    GameManager.add_score(-custom_score)
    GameManager.score_changed.disconnect(score_callable)
    if is_instance_valid(power_up):
        power_up.queue_free()
    return {
        "name": "El power-up respeta un valor de score personalizado",
        "passed": after_score == before_score + custom_score,
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
