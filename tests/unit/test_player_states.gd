## TestPlayerStates valida las enumeraciones del jugador.
extends RefCounted
const Enums = preload("res://scripts/utils/enums.gd")

func test_player_states() -> bool:
    """Confirma que los estados esperados existen en la enumeración."""
    return Enums.PlayerState.has("IDLE") and Enums.PlayerState.has("MOVE")
