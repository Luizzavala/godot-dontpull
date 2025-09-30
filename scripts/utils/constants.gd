extends Object
class_name GameConstants

## Centraliza valores constantes compartidos en el proyecto.
const TILE_SIZE := 64.0
const GRID_SIZE := Vector2i(5, 5)
const PLAYER_STEP_TIME := 0.15
const ENEMY_STEP_TIME := 0.35
const PLAYER_START_LIVES := 3
const SCORE_PER_STEP := 1
const LEVEL_SCENE_PATH := "res://scenes/core/Level.tscn"
const MAIN_MENU_SCENE_PATH := "res://scenes/core/MainMenu.tscn"

## Recordatorio: los sprites se suministran externamente y deben copiarse junto a
## los archivos de texto con el mismo nombre.
