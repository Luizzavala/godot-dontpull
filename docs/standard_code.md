# Estándares de Código

## Lenguaje
- **Primario:** GDScript 2.0 (Godot 4.5).
- **Secundario (si aplica):** C# para módulos críticos.

## Convenciones de Nomenclatura
- Clases: `PascalCase` → `Player`, `EnemyAI`.
- Variables: `snake_case` → `current_score`, `enemy_speed`.
- Constantes: `ALL_CAPS` → `TILE_SIZE`.
- Archivos de script: mismo nombre que escena o clase.

## Organización de Carpetas
/scenes → Escenas Godot  
/scripts → Lógica en GDScript  
/assets → Sprites, audio  
/levels → JSON con layouts  
/docs → Documentación  
/tests → Scripts de prueba  

## Principios
- **1 script = 1 responsabilidad clara**.  
- Usar **FSM (Finite State Machine)** para Player/Enemy.
- Evitar lógica mágica en `_process`, preferir métodos discretos por frame (`_physics_process`).
- Comentar cada función pública.
- Logs de debug con `print_debug()` → se desactiva en release.
- Definir en el Input Map las acciones `move_up`, `move_down`, `move_left`, `move_right` junto a las `ui_*` para compatibilidad y soporte multiplataforma.

## Estilo
- Indentación: 4 espacios.  
- Máx 100 líneas por script → dividir en managers si excede.  
- No hardcodear valores → usar constantes o config JSON.  
- Usar `const` y `enum` para estados.  

## Tests
- Unitarios simples en GDScript (validar colisiones, estados).  
- Escenas sandbox para probar bloques/enemigos.  
