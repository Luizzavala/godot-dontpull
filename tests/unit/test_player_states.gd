extends RefCounted

## Pruebas unitarias simples para validar las enumeraciones del jugador.

func test_player_states() -> bool:
    """Confirma que los estados esperados existen en la enumeración."""
    return GameEnums.PlayerState.has("IDLE") and GameEnums.PlayerState.has("MOVE")
