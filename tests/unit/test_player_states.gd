extends RefCounted

## Pruebas unitarias simples para validar las enumeraciones del jugador.
const Enums = preload("res://scripts/utils/enums.gd")

func test_player_states() -> bool:
    """Confirma que los estados esperados existen en la enumeración."""
    return Enums.PlayerState.has("IDLE") and Enums.PlayerState.has("MOVE")
