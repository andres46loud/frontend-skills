# Frontend Skills — Claude Code

Colección de skills para Claude Code con estándares y lineamientos de desarrollo frontend orientados a **React**, extrapolables a **React Native**.

Cada skill define reglas, convenciones y anti-patrones para un área específica del desarrollo, de modo que Claude las aplique de forma consistente en cualquier proyecto.

---

## Skills disponibles

| Skill | Comando | Descripción |
|---|---|---|
| Nomenclatura | `/frontend:naming` | Convenciones de nombres para componentes, hooks, variables, funciones, tipos y archivos |
| Arquitectura | `/frontend:architecture` | Estructura de capas + Atomic Design, árbol de decisión para ubicar archivos |
| Código limpio | `/frontend:clean-code` | Principios SOLID aplicados a React, early returns, memoización y más |
| Linting | `/frontend:linting` | Reglas de ESLint y Prettier para proyectos Next.js y Expo con TypeScript |
| Componentes | `/frontend:components` | Variantes, compound components, estados UI, memoización y estructura de archivos |
| Seguridad | `/frontend:security` | Tokens, variables de entorno, CSRF, XSS, exploits de auth y datos sensibles |
| Commits | `/frontend:commits` | Convención Conventional Commits con tipos, scopes y ejemplos |
| Ramas | `/frontend:branching` | Modelo de ramas con `main`, `staging` y flujo de validación |
| Testing | `/frontend:testing` | Estrategia de tests, qué testear y cómo *(próximamente)* |

---

## Instalación

```bash
git clone https://github.com/andres46loud/frontend-skills
cd frontend-skills
./install.sh
```

El script te preguntará dos cosas:

**1. ¿Global o local?**
- **Global** → las skills quedan disponibles en todos tus proyectos. Solo lo haces una vez en tu máquina.
- **Local** → las skills solo están disponibles en el proyecto desde donde ejecutas el script. Útil para que todo el equipo comparta las mismas skills commiteando `.claude/` al repo.

**2. ¿Symlink o copia?**
- **Symlink** → se crea un acceso directo a este repo. Al hacer `git pull` aquí, las skills se actualizan automáticamente en todos los lugares donde las instalaste.
- **Copia** → se copian los archivos. Para actualizar hay que volver a ejecutar `./install.sh`.

---

## Uso en un proyecto real

Una vez instaladas, invoca las skills directamente en cualquier conversación con Claude Code:

```
/frontend:architecture
/frontend:naming
/frontend:clean-code
```

### Escenario global — un desarrollador, múltiples proyectos

Instalas una sola vez y las skills están disponibles en cualquier proyecto que abras:

```bash
# Instalación única en tu máquina
git clone https://github.com/andres46loud/frontend-skills ~/frontend-skills
cd ~/frontend-skills && ./install.sh
# Eliges: Global → Symlink
```

A partir de ahí, en cualquier proyecto:

```
# Arrancas un proyecto nuevo
/frontend:architecture   → Claude estructura el proyecto con capas + Atomic Design

# Vas a crear un componente
/frontend:naming         → Claude aplica las convenciones de nomenclatura

# Vas a configurar el linter
/frontend:linting        → Claude genera la config de ESLint para Next.js o Expo

# Vas a hacer un commit
/frontend:commits        → Claude recuerda la convención y el formato correcto
```

Para actualizar todas las skills de un golpe:

```bash
cd ~/frontend-skills && git pull
# Listo — el symlink hace que aplique de inmediato en todos tus proyectos
```

---

### Escenario local — equipo compartiendo las mismas skills

Instalas las skills dentro del repo del proyecto para que cualquier dev del equipo las tenga disponibles al clonar:

```bash
# Desde la raíz de tu proyecto
git clone https://github.com/andres46loud/frontend-skills /tmp/frontend-skills
cd /tmp/frontend-skills && ./install.sh
# Eliges: Local → Symlink (o Copia si no quieres dependencia externa)

# Commitea la carpeta .claude al repo del proyecto
git add .claude && git commit -m "chore: add frontend claude skills"
```

Cualquier dev que clone el proyecto puede usar las skills sin configuración extra.

---

## Instalación manual

Si descargaste el ZIP, puedes copiar los archivos sin ejecutar el script.

### Global — disponible en todos tus proyectos

```bash
cp -r commands/frontend ~/.claude/commands/frontend
```

### Local — solo en el proyecto actual

```bash
mkdir -p .claude/commands
cp -r commands/frontend .claude/commands/frontend
```

> Si quieres que los cambios futuros apliquen automáticamente, usa `ln -s` en lugar de `cp -r` (requiere tener la carpeta en una ruta fija en tu máquina).

---

## Contribuir

1. Crea un archivo `.md` en `commands/frontend/` siguiendo la estructura de los existentes.
2. Asegúrate de incluir el frontmatter con `description`.
3. Agrega la skill a la tabla de este README.
