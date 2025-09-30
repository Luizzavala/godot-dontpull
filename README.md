# Don’t Pull Clone (Godot 4.5)

Clon educativo del juego arcade **Don’t Pull** (Capcom, 1991, parte de *Three Wonders*), desarrollado en Godot 4.5.  
El objetivo es replicar mecánicas originales en grid, manteniendo arquitectura modular y extensible.

⚠️ **Nota:** Proyecto con fines educativos. No distribuye ni reutiliza assets originales de Capcom.

---

## 🚀 Estado del Proyecto
- [x] Documentación inicial
- [x] Setup Godot project
- [ ] Prototipo movimiento jugador
- [ ] Empuje de bloques
- [ ] IA básica de enemigos
- [ ] HUD y sistema de score
- [ ] Niveles iniciales

---

## 📂 Estructura
- `/docs` → Documentación (arquitectura, estándares, agentes).
- `/scenes` → Escenas Godot (menú, niveles, HUD).
- `/scripts` → Código GDScript/C#.
- `/assets` → Sprites y audio (placeholders).
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
