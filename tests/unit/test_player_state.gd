extends Node

## Pruebas unitarias simples para validar las enumeraciones del jugador.
const Enums = preload("res://scripts/utils/enums.gd")

func run_tests() -> Array:
    return [
        _test_player_states_exist(),
    ]


func _test_player_states_exist() -> Dictionary:
    var states := Enums.PlayerState.values()
    var expected := [Enums.PlayerState.IDLE, Enums.PlayerState.MOVE, Enums.PlayerState.PUSH, Enums.PlayerState.DEAD]
    return {
        "name": "Enums.PlayerState expone todos los estados requeridos",
        "passed": states == expected,
    }
