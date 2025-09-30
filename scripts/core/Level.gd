extends Node2D
class_name Level

##
# Level monta un escenario mínimo de prueba con grid 5x5, jugador, enemigo y
# bloque empujable.
##

const GRID_SIZE := Vector2i(5, 5)

@onready var tile_map: TileMap = $TileMap
@onready var game_manager: GameManager = $GameManager
@onready var player_scene: Player = $Player
@onready var enemy_scene: Enemy = $Enemy
@onready var block_scene: Block = $Block
@onready var hud: HUD = $HUD

func _ready() -> void:
    _setup_tile_map()
    game_manager.setup_level(GRID_SIZE, tile_map, hud)
    _configure_actors()
    game_manager.start_level()

func _setup_tile_map() -> void:
    var tile_set := TileSet.new()
    var atlas := TileSetAtlasSource.new()
    var image := Image.create(64, 64, false, Image.FORMAT_RGBA8)
    image.fill(Color(0.1, 0.12, 0.16, 1.0))
    var texture := ImageTexture.create_from_image(image)
    atlas.texture = texture
    atlas.texture_region_size = Vector2i(64, 64)
    atlas.create_tile(Vector2i.ZERO)
    tile_set.add_source(0, atlas)
    tile_map.tile_set = tile_set
    tile_map.rendering_quadrant_size = 16
    for x in range(GRID_SIZE.x):
        for y in range(GRID_SIZE.y):
            tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i.ZERO)

func _configure_actors() -> void:
    var player_cell := Vector2i(1, 1)
    var enemy_cell := Vector2i(3, 3)
    var block_cell := Vector2i(2, 2)

    player_scene.configure(game_manager, player_cell)
    enemy_scene.configure(game_manager, enemy_cell)
    block_scene.configure(game_manager, block_cell)

    game_manager.register_player(player_scene, player_cell)
    game_manager.register_enemy(enemy_scene, enemy_cell)
    game_manager.register_block(block_scene, block_cell)
