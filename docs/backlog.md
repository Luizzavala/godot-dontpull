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

---

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

---

## Instrucciones generales del backlog

- Cada tarea listada aquí describe **requerimientos técnicos** adicionales al checklist de `README.md`.
- Al implementar una tarea:
  - Se debe respetar el estándar de código definido en `/docs/standard_code.md`.
  - Todas las variables deben tiparse explícitamente.
  - Se deben crear tests unitarios en `/tests/unit` y sandbox en `/tests/integration`.
  - Si se añaden **nuevos estados, constantes o enumeraciones**, se deben actualizar:
    - `Consts.gd` → para valores numéricos, puntajes, velocidades, timers.
    - `enums.gd` → para definir estados adicionales en Player, Enemy, Block u otros agentes.
  - La documentación en `/docs/agents.md`, `/docs/architecture.md` y `/docs/standard_code.md` debe reflejar siempre los cambios.

## Implementación de mecánicas/gameplay originales de Don’t Pull (Capcom)

El objetivo es replicar fielmente las mecánicas del arcade original, para que el clon no solo reproduzca la estética sino también el gameplay característico.

### Requerimientos principales
- **Empuje y lanzamiento de bloques**
  - El jugador puede empujar bloques en una dirección.
  - Los bloques se mueven hasta chocar con:
    - Otro bloque.
    - Un enemigo.
    - Un borde sólido.
  - Velocidad de deslizamiento constante (definida en Consts).
  - Estado nuevo en `Block.gd`: `Launched`.
  - Animaciones del jugador al empujar/lanzar.

- **Destrucción de bloques**
  - Un bloque puede ser destruido:
    - Por acción directa del jugador (ej. empuje fuerte).
    - Por colisión con enemigo si existe condición especial.
    - Por power-up destructivo.
  - Estado nuevo en `Block.gd`: `Destroyed`.
  - Añadir efecto visual y sonido de destrucción.

- **Interacción bloques-enemigos**
  - Los bloques lanzados pueden aplastar enemigos.
  - Los bloques destruidos no deben dejar residuos colisionables.
  - Score adicional por aplastar enemigos con bloques.

- **Sistema de niveles arcade**
  - Grid más grande (ej. 13×11).
  - Bloques precolocados formando laberintos (definidos en JSON).
  - Cada nivel tiene `"name"` mostrado en HUD.
  - Niveles deben reproducir layouts inspirados en los originales.

### Cambios técnicos
- **Level.gd**
  - Soporte de grids dinámicos y más grandes.
  - Cargar `"name"` de nivel desde JSON y mostrarlo en HUD.
  - Función para colocar bloques en forma de laberinto.
- **Block.gd**
  - Nuevos estados: `Launched`, `Destroyed`.
  - Manejo de colisiones con jugador, enemigos y límites.
- **Player.gd**
  - Acción de empuje/lanzamiento.
  - Animación correspondiente.
- **HUD.gd**
  - Mostrar nombre del nivel.
  - Mantener score, timer y vidas visibles.
- **Consts.gd / enums.gd**
  - Añadir constantes y enumeraciones nuevas para soportar `Launched`, `Destroyed` y parámetros asociados.

### Tests
- /tests/unit/test_block_launch.gd → validar lanzamiento de bloques.
- /tests/unit/test_block_destroy.gd → validar destrucción de bloques.
- /tests/unit/test_enemy_collision.gd → validar aplastamiento de enemigos por bloques.
- /tests/integration/sandbox_labyrinth.tscn → nivel de prueba con laberinto y mecánicas completas.

---

## Ajuste de resolución, escalado y centrado del área jugable

Actualmente, aunque las colisiones del grid funcionan correctamente, el área jugable se renderiza como un bloque pequeño en la esquina de la pantalla, dejando gran parte de la ventana en negro.
El objetivo es que el área de juego:
1. Se centre siempre en la pantalla.
2. Se escale proporcionalmente para ocupar un área visible adecuada, sin deformarse.
3. Mantenga la proporción clásica tipo arcade (4:3) o la definida en Consts.

### Requerimientos técnicos
- **Project Settings → Display → Window**
  - Definir una resolución base fija (ej. 320×240 o 640×480).
  - `stretch/mode = 2d`.
  - `stretch/aspect = keep` (o `keep_width`/`keep_height` según diseño).
- **Camera2D en Level**
  - Añadir nodo `Camera2D` como hijo de Level.
  - `current = true`.
  - Ajustar `zoom` dinámicamente según tamaño del grid (`grid_size * TILE_SIZE`) y el viewport.
  - Asegurar que el área jugable quede centrada en pantalla.
- **Centrado del HUD**
  - Verificar que HUD se alinee al viewport, no al tamaño del grid, para que mantenga posiciones correctas tras el escalado.

### Cambios en el código
- En `Level.gd`: calcular tamaño total del mapa y aplicar zoom a la cámara para que se ajuste.
- En `HUD.gd`: usar `anchor` y `margin` relativos al viewport para que score, timer, level y vidas no se desplacen con el zoom.

### Tests
- /tests/unit/test_camera_center.gd → validar que el área jugable queda centrada en pantalla tras cargar un nivel.
- /tests/unit/test_aspect_ratio.gd → validar que el escalado respeta la relación de aspecto definida.
- /tests/integration/sandbox_scaling.tscn → cargar varios niveles con distintos grid_size y comprobar visualmente que ocupan un área proporcional de la pantalla, siempre centrados.

---

## Sistema de puntuación arcade y tabla de récords (High Score)
- Implementar un sistema de high scores persistente:
  - Guardar score máximo entre partidas (ej. en user://scores.json).
  - Tabla de 5–10 mejores puntuaciones.
  - Permitir ingresar iniciales al terminar una partida (3 letras estilo arcade).
- Mostrar la high score en HUD y en menú principal.
- Tests:
  - /tests/unit/test_high_score.gd → validar que las puntuaciones se guardan/ordenan correctamente.
  - /tests/integration/sandbox_high_score.tscn → escenario de prueba de tabla de récords.

---

## Hooks de música y efectos de sonido (dummy)
- Añadir nodos `AudioStreamPlayer` para:
  - BGM (loop).
  - Empuje/lanzamiento de bloque.
  - Destrucción de bloque.
  - Aplastamiento de enemigo.
  - Recolección de power-up.
  - Game Over.
- Los streams se inicializan como `null` (o con placeholders vacíos) hasta integrar audios binarios.
- Tests:
  - /tests/unit/test_audio_hooks.gd → validar que cada acción dispara el `play()` correspondiente.
  - /tests/integration/sandbox_audio_hooks.tscn → comprobar que los players se invocan.

---

## Animaciones retro (dummy)
- Configurar nodos `AnimatedSprite2D` o `AnimationPlayer`:
  - Jugador (idle, walk, push, dead).
  - Enemigos (idle, move, dead).
  - Bloques (sliding, destroyed).
- Las animaciones pueden usar frames de placeholder (ej. un cuadrado de colores distintos).
- FSM debe cambiar de animación al cambiar de estado.
- Tests:
  - /tests/unit/test_animation_state_machine.gd → validar que el cambio de estado dispara la animación correcta.
  - /tests/integration/sandbox_animation_hooks.tscn → probar animaciones dummy.

---

## Pantalla de introducción / attract mode
- Crear escena de introducción tipo arcade:
  - Logo + créditos (dummy).
  - Demo automática (IA controlando jugador en un nivel).
  - Loop hasta que el jugador presione Start.
- Tests:
  - /tests/unit/test_attract_cycle.gd → validar loop y transición al menú.
  - /tests/integration/sandbox_attract.tscn → demo básica.

---

## Balance y dificultad progresiva
- Incrementar dificultad gradualmente:
  - Velocidad de enemigos aumenta por nivel.
  - Tiempo disponible por nivel disminuye.
  - Niveles más avanzados con layouts más cerrados.
- Constantes de dificultad en Consts.gd.
- Tests:
  - /tests/unit/test_difficulty_curve.gd → validar incremento progresivo de parámetros.
  - /tests/integration/sandbox_difficulty.tscn → partida de varios niveles en secuencia.

---

## Export estilo arcade
- Configurar el proyecto para exportar builds con:
  - Resolución fija (ej. 640×480, fullscreen).
  - Input configurable (teclado, gamepad, arcade stick).
  - Sin UI extra de depuración.
- Tests:
  - /tests/integration/sandbox_export.tscn → validar input y fullscreen en exportación.

---
