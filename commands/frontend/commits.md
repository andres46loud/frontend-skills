---
description: Aplicar al escribir mensajes de commit en cualquier proyecto React/React Native. Establece el estándar Conventional Commits para un historial de git consistente, legible y compatible con automatizaciones.
---

# Convención de Commits — Estándares Frontend

## Estándar: Conventional Commits

Todos los commits siguen la especificación [Conventional Commits](https://www.conventionalcommits.org/). Esto permite generación automática de changelogs, versionado semántico e historial de git legible de un vistazo.

---

## Estructura

```
<tipo>[scope opcional]: <descripción corta>

[cuerpo opcional]

[footer(s) opcional(es)]
```

### Reglas para la descripción corta
- Minúsculas, sin punto al final
- Modo imperativo: "add feature" no "added feature" ni "adds feature"
- Máximo 72 caracteres
- En inglés

```bash
# ✅
feat(auth): add google oauth login

# ❌
feat(auth): Added Google OAuth Login.
feat(auth): adding google oauth
```

---

## Tipos

| Tipo | Cuándo usarlo |
|---|---|
| `feat` | Una nueva funcionalidad visible para el usuario |
| `fix` | Corrección de un bug |
| `refactor` | Cambio de código que no corrige un bug ni agrega funcionalidad |
| `style` | Formateo, espacios, punto y coma — sin cambio de lógica |
| `perf` | Mejora de rendimiento |
| `test` | Agregar o corregir tests |
| `docs` | Cambios solo en documentación |
| `build` | Cambios en el sistema de build, dependencias o tooling (webpack, eslint, package.json) |
| `ci` | Cambios en configuración de CI/CD |
| `chore` | Tareas de mantenimiento que no afectan src ni tests (actualizar .gitignore, scripts) |
| `revert` | Revierte un commit anterior |

---

## Scope

Opcional. Describe el área del codebase afectada. Mantenlo corto y consistente en todo el equipo.

```bash
feat(auth): add token refresh logic
fix(checkout): prevent double submission on slow connections
refactor(user-profile): extract avatar logic into hook
build(deps): upgrade react-query to v5
```

Scopes sugeridos por área del proyecto:

```
auth          → autenticación y autorización
ui            → componentes UI compartidos
navigation    → routing y navegación
api           → capa de servicios y llamadas API
hooks         → hooks personalizados
forms         → lógica de formularios y validación
payments      → flujos de pago
notifications → notificaciones push o in-app
```

---

## Breaking changes

Agrega `!` después del tipo/scope y explica en el footer con `BREAKING CHANGE:`.

```bash
feat(api)!: remove deprecated v1 endpoints

BREAKING CHANGE: /api/v1/users and /api/v1/products have been removed.
Migrate to /api/v2 equivalents before upgrading.
```

---

## Cuerpo del commit

Usa el cuerpo para explicar el **por qué**, no el qué. El diff ya muestra qué cambió.

```bash
fix(auth): handle expired token on app resume

The token expiration was not being checked when the app came back
from background. Users were getting 401 errors on the first request
after resuming instead of being transparently re-authenticated.
```

---

## Ejemplos

```bash
# Nueva funcionalidad
feat(cart): add quantity selector to product card

# Bug fix con scope
fix(navigation): resolve back button crash on android

# Refactor
refactor(checkout): extract payment form into separate component

# Solo formateo
style: fix indentation in UserProfileCard

# Actualización de dependencia
build(deps): upgrade expo-secure-store to 13.0.1

# Test
test(auth): add unit tests for useAuthSession hook

# Mantenimiento
chore: add .env.example with required variables

# Breaking change
feat(auth)!: replace jwt with session cookies

BREAKING CHANGE: token-based auth has been removed.
All clients must handle session cookies. localStorage token
storage is no longer supported.

# Revert
revert: feat(cart): add quantity selector to product card

Reverts commit a1b2c3d. The feature caused a regression in
the order summary total calculation.
```

---

## Anti-patrones

```bash
# ❌ demasiado vago
fix: bug fix
chore: changes
feat: stuff

# ❌ múltiples cambios no relacionados en un commit — sepáralos
feat: add login + fix navbar + update dependencies

# ❌ tiempo verbal incorrecto
feat(auth): added login screen
fix(cart): fixing total calculation

# ❌ tipo o descripción en mayúsculas
Feat(auth): Add login screen
FEAT: add login screen

# ❌ sin tipo
add login screen
updated readme
```

---

## Tamaño del commit

Un commit = un cambio lógico. Si necesitas "and" para describir tu commit, probablemente deberían ser dos commits.

```bash
# ❌ dos cambios no relacionados
feat(auth): add login screen and fix typo in header

# ✅ separados
feat(auth): add login screen
fix(header): correct spelling in navigation title
```

---

## Git hooks (opcional)

Si el equipo quiere **aplicar la convención automáticamente**, `commitlint` + `husky` pueden rechazar cualquier commit que no cumpla el estándar antes de que quede registrado en el historial — sin depender de revisiones de código para detectarlo.

- **husky** instala git hooks: scripts que se ejecutan automáticamente en eventos específicos de git (`commit`, `push`, etc.)
- **commitlint** valida el formato del mensaje contra las reglas de Conventional Commits
- Juntos interceptan cada `git commit` y lo abortan inmediatamente si el mensaje no cumple la convención, mostrándole el error al desarrollador

Esto no es obligatorio — la convención funciona perfectamente con disciplina y acuerdo del equipo. Los hooks agregan una red de seguridad útil para equipos grandes o cuando la consistencia es crítica.

```bash
npm install --save-dev @commitlint/cli @commitlint/config-conventional husky
```

```js
// commitlint.config.js
module.exports = {
  extends: ['@commitlint/config-conventional'],
}
```

```bash
# .husky/commit-msg — se ejecuta automáticamente en cada git commit
npx --no -- commitlint --edit $1
```
