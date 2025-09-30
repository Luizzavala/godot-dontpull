extends Object
class_name GameHelpers

## Proporciona utilidades compartidas para coordenadas y búsqueda de nodos.
static func grid_to_world(grid_position: Vector2i) -> Vector2:
    """Convierte una posición de grid a coordenadas globales."""
    return Vector2(grid_position) * GameConstants.TILE_SIZE + Vector2.ONE * (GameConstants.TILE_SIZE * 0.5)


static func world_to_grid(world_position: Vector2) -> Vector2i:
    """Convierte una posición global a coordenadas del grid."""
    var adjusted := world_position - Vector2.ONE * (GameConstants.TILE_SIZE * 0.5)
    return Vector2i(round(adjusted.x / GameConstants.TILE_SIZE), round(adjusted.y / GameConstants.TILE_SIZE))


static func find_node_at_position(group_name: StringName, world_position: Vector2) -> Node:
    """Devuelve el primer nodo del grupo indicado que coincida con la posición global proporcionada."""
    for node in get_tree().get_nodes_in_group(group_name):
        if not node is Node2D:
            continue
        if (node as Node2D).global_position.distance_to(world_position) < 1.0:
            return node
    return null


static func get_tree() -> SceneTree:
    """Permite acceder al árbol de escenas desde un contexto estático."""
    return Engine.get_main_loop() as SceneTree
