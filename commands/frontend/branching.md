---
description: Aplicar al crear ramas, planificar un flujo de trabajo git, o definir cómo se integran cambios en un proyecto React/React Native. Define un modelo de ramas estándar adaptable a cualquier equipo u organización.
---

# Modelo de Ramas — Estándares Frontend

## Principio base

**`main` es la fuente de la verdad y representa producción.** Todo cambio nace de `main`, debe ser validado en `staging` antes de integrarse de vuelta a `main`. Ningún cambio llega a producción sin pasar por el ambiente de validación.

---

## Ramas permanentes

| Rama | Propósito |
|---|---|
| `main` | Producción. Código estable, probado y desplegado. Es la fuente de la verdad. |
| `staging` | Pre-producción. Ambiente de validación antes de llegar a `main`. |

Estas dos ramas **nunca se eliminan** y **nunca se trabaja directamente en ellas** — solo reciben merges desde ramas de trabajo.

---

## Ramas de trabajo

Se crean desde `main`, se trabaja en ellas y se eliminan una vez integradas.

| Prefijo | Cuándo usarlo | Ejemplo |
|---|---|---|
| `feature/` | Nueva funcionalidad | `feature/user-authentication` |
| `fix/` | Corrección de bug en desarrollo | `fix/login-redirect-loop` |
| `hotfix/` | Corrección urgente en producción | `hotfix/payment-crash` |
| `refactor/` | Refactorización sin cambio de comportamiento | `refactor/checkout-component` |
| `chore/` | Mantenimiento, dependencias, configuración | `chore/upgrade-react-query` |

### Reglas de nomenclatura
- Minúsculas y guiones, sin espacios ni caracteres especiales
- Descripción corta pero específica: `feature/product-filters` no `feature/filters`
- En inglés, alineado con la convención de commits

---

## Flujo de trabajo

```
main
 │
 ├──── feature/nueva-funcionalidad
 │         │
 │         │  (desarrollo local, commits)
 │         │
 │         ▼
 │       staging  ◄── se hace merge de la rama a staging para validar
 │         │
 │         ├── ✅ validado → merge a main → se elimina la rama
 │         │
 │         └── ❌ falló → se corrige en la misma rama
 │                           │
 │                           ▼
 │                         staging  ◄── nuevo merge para re-validar
 │                           │
 │                           └── ✅ validado → merge a main → se elimina la rama
```

### Paso a paso

```bash
# 1. Siempre partir desde main actualizado
git checkout main
git pull origin main

# 2. Crear la rama de trabajo
git checkout -b feature/product-filters

# 3. Desarrollar y commitear (siguiendo la convención de commits)
git commit -m "feat(products): add filter by category and price range"

# 4. Cuando está listo para validar, hacer merge a staging
git checkout staging
git pull origin staging
git merge feature/product-filters
git push origin staging

# 5a. Si la validación es exitosa → merge a main
git checkout main
git pull origin main
git merge feature/product-filters
git push origin main

# 5b. Si la validación falla → volver a la rama, corregir y repetir desde paso 4
git checkout feature/product-filters
# ...correcciones...
git commit -m "fix(products): correct filter reset on page change"

# 6. Eliminar la rama una vez integrada a main
git branch -d feature/product-filters
git push origin --delete feature/product-filters
```

---

## Hotfix — corrección urgente en producción

Cuando hay un bug crítico en producción que no puede esperar el flujo normal:

```bash
# 1. Crear hotfix desde main (producción)
git checkout main
git pull origin main
git checkout -b hotfix/payment-crash

# 2. Corregir y commitear
git commit -m "fix(payments): prevent null reference on failed transaction"

# 3. Validar en staging
git checkout staging
git merge hotfix/payment-crash
git push origin staging

# 4. Una vez validado, merge a main
git checkout main
git merge hotfix/payment-crash
git push origin main

# 5. Eliminar la rama
git branch -d hotfix/payment-crash
git push origin --delete hotfix/payment-crash
```

---

## Pull Request para integrar a main

El paso de `staging` a `main` **siempre se hace mediante un Pull Request**, nunca con merge directo. El PR es el punto de revisión formal antes de que el código llegue a producción.

### Estructura del PR

```markdown
## ¿Qué hace este PR?
Descripción clara de los cambios introducidos y el problema que resuelven.
Una o dos líneas es suficiente si el título ya es descriptivo.

## ¿Cómo probar?
Pasos concretos para que el revisor pueda verificar el comportamiento:
1. Ir a la pantalla X
2. Hacer clic en Y
3. Verificar que Z ocurre

## Ticket asociado (opcional)
Closes #123
Relates to #456

## Screenshots (opcional)
Incluir capturas o grabaciones si hay cambios visuales.
Útil para que el revisor entienda el antes/después sin tener que correr el proyecto.
```

### Reglas del PR

- El título debe seguir la convención de commits: `feat(auth): add google login`
- El PR debe apuntar a `main` desde la rama de trabajo — no desde `staging`
- Al menos una aprobación antes de hacer merge
- El PR se cierra con **Squash and merge** para mantener el historial de `main` limpio

---

## Reglas generales

- **Nunca hacer push directo a `main` o `staging`** — siempre a través de una rama de trabajo.
- **Una rama = una funcionalidad o fix.** Ramas pequeñas son más fáciles de revisar y menos propensas a conflictos.
- **Mantener la rama actualizada con `main`** durante desarrollo largo para minimizar conflictos al integrar.
- **Eliminar las ramas** después de integrarlas — evita acumulación de ramas obsoletas.
- **`staging` puede romperse** — es el ambiente de prueba. Si algo falla ahí, se corrige en la rama antes de llegar a `main`.

```bash
# Mantener la rama actualizada con main durante desarrollo
git checkout feature/product-filters
git fetch origin
git rebase origin/main   # o git merge origin/main según preferencia del equipo
```

---

## Adaptación por equipo

Este modelo es un punto de partida. Algunos ajustes comunes según el contexto:

| Necesidad | Ajuste sugerido |
|---|---|
| Revisión de código obligatoria | Usar Pull Requests en lugar de merge directo a `main` |
| Múltiples ambientes (dev, QA, staging, prod) | Agregar ramas `develop` o `qa` entre `main` y `staging` |
| Releases versionados | Agregar ramas `release/v1.2.0` antes de llegar a `main` |
| Equipo grande con varias features en paralelo | Considerar trunk-based development con feature flags |

---

## Notas para React Native

El modelo de ramas aplica igual. Consideraciones adicionales:

- Los hotfixes en apps móviles requieren un nuevo build y proceso de revisión en App Store / Play Store — planifica tiempos más largos que en web.
- Si manejas versiones iOS y Android con comportamientos distintos, puedes usar ramas `platform/ios-fix` pero idealmente resuelto con archivos `.ios.tsx` / `.android.tsx` sin bifurcar el flujo git.
