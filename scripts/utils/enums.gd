extends Object
class_name GameEnums

## Define enumeraciones utilizadas por las máquinas de estados del proyecto.
enum PlayerState { IDLE, MOVE, PUSH, DEAD }
enum EnemyState { PATROL, CHASE, DEAD }
enum BlockState { STATIC, SLIDING, DESTROYED }
enum GameState { MENU, PLAYING, GAME_OVER }
