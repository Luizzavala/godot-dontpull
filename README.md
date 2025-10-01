# Don’t Pull Clone (Godot 4.5)

Clon educativo del juego arcade **Don’t Pull** (Capcom, 1991, parte de *Three Wonders*), desarrollado en Godot 4.5.
El objetivo es replicar mecánicas originales en grid, manteniendo arquitectura modular y extensible.

⚠️ **Nota:** Proyecto con fines educativos. No distribuye ni reutiliza assets originales de Capcom.

---

## 🚀 Estado del Proyecto
- [x] Documentación inicial
- [x] Setup Godot project
- [x] Prototipo movimiento jugador
- [x] Empuje de bloques
- [x] IA básica de enemigos
- [x] HUD y sistema de score
- [x] Niveles iniciales
- [x] Colisión de bloques con enemigos (enemigos aplastados)
- [x] Power-ups y sistema de bonus (frutas/ítems)
- [x] Niveles iniciales (carga desde JSON en /levels) — warnings de tipado corregidos en Level.gd
- [x] Colisión jugador/bloque: **el jugador nunca debe quedar debajo de un bloque** (bloques siempre se priorizan sobre el jugador al empujar/colisionar).
- [ ] Límites del mapa: agregar **bordes sólidos** que no puedan cruzarse (ni jugador, ni bloques, ni enemigos).
- [ ] HUD reubicado:
  - [ ] Score en la **esquina superior derecha**.
  - [ ] Vidas en el **centro inferior**.
  - [ ] Level en la **esquina superior izquierda**.
  - [ ] Timer en el **centro superior** (contando tiempo de cada nivel).
- [ ] Sistema de transición de niveles (pasar al siguiente al derrotar enemigos)
- [ ] Sistema de Game Over y reinicio
- [ ] Menú principal funcional
- [ ] Pulido visual y assets finales (sprites, audio)
- [ ] Testing y balance (sandbox + pruebas de integración)

---

## 📂 Estructura
- `/docs` → Documentación (arquitectura, estándares, agentes).
- `/scenes` → Escenas Godot (menú, niveles, HUD).
- `/scripts` → Código GDScript/C#.
- `/assets` → Sprites y audio (placeholders). Renombrar los archivos `*.png.txt` a
  `*.png` si se desea usarlos dentro de Godot y colocar los binarios correspondientes
  fuera del repositorio (ver instrucciones al final de este archivo).
- `/levels` → Definiciones JSON/TSV de niveles.
- `/tests` → Escenas de prueba y scripts unitarios.

---

## 🔧 Tecnologías
- **Engine:** Godot 4.5
- **Lenguaje:** GDScript (base), C# opcional en módulos críticos
- **Gestión:** Git (branch main/dev/feature)

---

## 📑 Documentación
- [Arquitectura](./docs/architecture.md)
- [Estándares de Código](./docs/standard_code.md)
- [Agentes del Juego](./docs/agents.md)

---

## ♻️ Recuperar assets de marcador de posición

Por política del repositorio no se versionan binarios. Cada archivo `*.png.txt`
indica el nombre del sprite que debe colocarse manualmente en el mismo
directorio para que Godot lo utilice.

El paquete `placeholder_sprites.zip` se distribuye fuera del repositorio. Para
utilizarlo, descargue el archivo proporcionado en la documentación del PR y
extraiga su contenido dentro de `assets/sprites`, sustituyendo los marcadores de
posición de texto por los binarios originales.
