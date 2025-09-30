## TestPlayerState comprueba que la enumeración del jugador esté completa.
extends Node
const Enums = preload("res://scripts/utils/enums.gd")

func run_tests() -> Array:
    """Ejecuta las pruebas que validan la enumeración PlayerState."""
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
