# Don’t Pull Clone (Godot 4.5)

Clon educativo del juego arcade **Don’t Pull** (Capcom, 1991, parte de *Three Wonders*), desarrollado en Godot 4.5.
El objetivo es replicar mecánicas originales en grid, manteniendo arquitectura modular y extensible.

⚠️ **Nota:** Proyecto con fines educativos. No distribuye ni reutiliza assets originales de Capcom.

---

## 🚀 Estado del Proyecto
La lista de tareas ahora se gestiona en [tasks.md](./docs/tasks.md) bajo formato Taskmaster.

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
