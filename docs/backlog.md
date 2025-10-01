# 📌 Backlog de requerimientos técnicos

## Power-ups y sistema de bonus (frutas/ítems)
- Implementar ítems coleccionables (frutas, estrellas u otros).
- Deben aparecer en posiciones predefinidas del nivel (desde JSON en /levels).
- Al recolectar un power-up:
  - Incrementar score con `Consts.POWERUP_SCORE`.
  - Opcional: otorgar bonus temporal (ej. velocidad o invulnerabilidad).
- Tests:
  - /tests/unit/test_powerups.gd → validar que el power-up incrementa score.
  - /tests/integration/sandbox_powerups.tscn → escena con jugador y power-up.

---

## Colisión jugador/bloque
- El jugador nunca debe quedar debajo de un bloque.
- Al empujar un bloque, siempre debe tener prioridad el bloque sobre el jugador.
- Si ocurre colisión, el jugador debe quedar bloqueado detrás del bloque.
- Tests:
  - /tests/unit/test_player_block_collision.gd → validar que el jugador no se superpone al bloque.
  - /tests/integration/sandbox_player_block.tscn → escenario con bloque y jugador.

---

## Límites del mapa
- El mapa debe tener **bordes sólidos** que no puedan cruzarse:
  - Jugador.
  - Bloques.
  - Enemigos.
- Implementar paredes invisibles o usar un `TileMap` con colisiones sólidas en los bordes.
- Tests:
  - /tests/unit/test_map_limits.gd → validar que jugador y bloques no atraviesen límites.
  - /tests/integration/sandbox_map_limits.tscn → grid pequeño con paredes.

---

## HUD reubicado
- Reorganizar HUD de forma horizontal:
  - Score en esquina superior derecha.
  - Vidas en el centro inferior.
  - Level en esquina superior izquierda.
  - Timer en el centro superior (contador decreciente de tiempo por nivel).
- Tests:
  - /tests/unit/test_hud_layout.gd → validar posiciones de labels en HUD.
  - /tests/integration/sandbox_hud.tscn → escena de HUD aislada.

---

## Sistema de transición de niveles
- Cuando todos los enemigos de un nivel son derrotados:
  - Mostrar animación o mensaje “Level Clear”.
  - Cargar el siguiente nivel desde JSON en /levels.
- Tests:
  - /tests/unit/test_level_transition.gd → validar paso de nivel al derrotar enemigos.
  - /tests/integration/sandbox_level_transition.tscn → escenario con 1 enemigo.

---

## Sistema de Game Over y reinicio
- Cuando las vidas del jugador lleguen a 0:
  - Mostrar pantalla de Game Over.
  - Opción de reiniciar partida desde nivel 1.
- Tests:
  - /tests/unit/test_game_over.gd → validar que al llegar a 0 vidas se dispara evento de Game Over.
  - /tests/integration/sandbox_game_over.tscn → partida simulada.

---

## Menú principal funcional
- Crear escena MainMenu.tscn con:
  - Botón “Start Game”.
  - Botón “Quit”.
  - Opcional: opciones de configuración.
- Tests:
  - /tests/unit/test_menu_navigation.gd → validar que los botones disparan acciones correctas.
  - /tests/integration/sandbox_menu.tscn → cargar menú.

---

## Pulido visual y assets finales
- Sustituir placeholders por sprites finales (jugador, enemigos, bloques, power-ups).
- Añadir efectos de sonido y música.
- Aplicar animaciones básicas (idle, push, walk).
- No requiere tests unitarios, solo sandbox visual: /tests/integration/sandbox_visuals.tscn.

---

## Testing y balance
- Crear pruebas de integración para escenarios completos.
- Ajustar valores de velocidad, timers y puntajes.
- Validar comportamiento en distintos tamaños de grid.
- Tests:
  - /tests/unit/test_balance_values.gd → validar constantes dentro de rango esperado.
  - /tests/integration/sandbox_full_game.tscn → simulación completa.

## Mapas centrados y área de no tránsito diferenciada

- Los mapas actuales (ejemplo Orchard-01) son más pequeños que los originales de *Don’t Pull*.
- El área de juego debe quedar **centrada en pantalla**, no alineada a la izquierda.
- El espacio fuera del área jugable (área de no tránsito) debe renderizarse con un **color distinto** al fondo, para marcar claramente los límites.
- Requisitos técnicos:
  - El `TileMap` debe calcular un offset inicial para centrar el grid dentro del viewport (usar Consts.GRID_WIDTH y Consts.GRID_HEIGHT).
  - Crear un `ColorRect` o capa de fondo diferenciada para la zona no transitable.
  - Asegurar que jugador, bloques y enemigos **solo se muevan dentro del área jugable**.
- Tests:
  - /tests/unit/test_map_centering.gd → validar que el offset del mapa centra el grid en pantalla.
  - /tests/unit/test_out_of_bounds.gd → validar que jugador/bloques no pueden moverse fuera del área jugable.
  - /tests/integration/sandbox_centered_map.tscn → cargar un nivel pequeño y comprobar que aparece centrado con fondo diferenciado.

---

## Migraciones

- NOTIFICATION_RESIZED (Godot 3.x) → reemplazado por signal `size_changed` en Godot 4.x.

## Implementación de niveles originales de Don’t Pull (Capcom)

- Los niveles deben reflejar el diseño del arcade original:
  - Dimensiones más grandes que el prototipo actual (ej. grid 13×11 o 15×13, ajustable según cada nivel).
  - Posicionamiento de bloques formando laberintos o caminos estrechos.
  - Inclusión de enemigos y power-ups en posiciones predeterminadas.
- Mostrar en el HUD el nombre del nivel (ejemplo: “Orchard-01”).
- Extender el formato JSON de niveles:
  - `"name"`: nombre del nivel (visible en HUD).
  - `"grid_size"`: dimensiones exactas del nivel.
  - `"blocks"`: lista de coordenadas para el layout del laberinto.
  - `"player"` y `"enemies"`: posiciones iniciales.
  - `"power_ups"`: ítems con tipo y posición.
- Nuevas mecánicas de bloques:
  - **Lanzamiento:** el jugador puede empujar un bloque hasta que recorra toda la línea o choque con otro bloque, pared o enemigo.
  - **Destrucción:** implementar acción para destruir un bloque (ej. tras empuje especial o power-up).
  - Animaciones asociadas (empuje, ruptura).
- Tests:
  - /tests/unit/test_level_loader.gd → validar carga correcta de laberintos desde JSON.
  - /tests/unit/test_block_launch.gd → validar que los bloques lanzados se mueven hasta chocar con algo.
  - /tests/unit/test_block_destroy.gd → validar destrucción de bloques.
  - /tests/integration/sandbox_labyrinth.tscn → probar un nivel con laberinto cargado.

