Contexto:
Proyecto en Godot 4.5 clonando el arcade “Don’t Pull”.
El archivo tasks.md contiene la lista de tareas en formato checklist.
El archivo backlog.md contiene la descripción detallada de los requerimientos de cada tarea (si existen).

Instrucciones para Codex:
1. Leer tasks.md → ubicar la primera tarea pendiente ([ ]).
2. Buscar en backlog.md si existe una sección con el mismo nombre de la tarea:
   - Si existe → usar esa descripción como guía de implementación.
   - Si no existe → implementar la tarea usando criterios básicos del proyecto.
3. Implementar el código en GDScript necesario para completar la tarea.
4. Crear pruebas unitarias en /tests/unit y sandbox en /tests/integration.
5. Actualizar tasks.md → marcar la tarea como completada [x].
6. Si la implementación requirió cambios de arquitectura, agentes o convenciones:
   - Actualizar agents.md, architecture.md o standard_code.md.
7. **Repetir el ciclo completo desde el paso 1**:
   - Volver a leer tasks.md.
   - Detectar la siguiente tarea pendiente.
   - Continuar hasta que no haya más tareas con [ ].

Resultado esperado:
- El proyecto progresa de forma iterativa, completando todas las tareas listadas en tasks.md en orden.
- backlog.md provee contexto extra cuando es necesario.
- Documentación y tests siempre actualizados.
- Codex no se detiene después de la primera tarea, sino hasta que todas estén marcadas como completadas.

