---
description: Aplicar al crear o renombrar componentes, archivos, hooks, variables, funciones o tipos en un proyecto React/React Native. Garantiza nomenclatura consistente en todo el codebase.
---

# Nomenclatura — Estándares Frontend

## Componentes

- **PascalCase** siempre, sin excepciones.
- El nombre es un **sustantivo o frase nominal** que describe qué renderiza, no qué hace.
- Sé específico: prefiere `TarjetaPerfilUsuario` o `UserProfileCard` sobre `Tarjeta2` o `NuevoBoton`.
- Evita nombres genéricos: `Card`, `Item`, `Container` son señales de alerta salvo que estén en una librería de primitivos UI.

```tsx
// ✅
UserProfileCard
ProductListItem
CheckoutSummaryPanel

// ❌
card, usercard, MiComponente, Componente1, NuevoBoton
```

---

## Archivos y carpetas

- Archivos de componentes: **PascalCase**, con el mismo nombre exacto del componente.
- Archivos no-componente (utils, hooks, servicios, constantes): **camelCase**.
- Archivos de test: mismo nombre que el archivo bajo prueba + `.test` o `.spec`.
- Carpetas: **kebab-case** para carpetas de features; **PascalCase** solo si la carpeta representa un único componente con archivos co-localizados.

```
UserProfileCard/
  UserProfileCard.tsx
  UserProfileCard.test.tsx
  useUserProfileCard.ts         ← hook co-localizado
  userProfileCard.styles.ts     ← estilos co-localizados

utils/
  formatDate.ts
  formatDate.test.ts
```

---

## Hooks

- Siempre con prefijo `use`, seguido de **PascalCase**.
- El nombre describe **qué gestiona**, no cómo: `cartHook` no `usecart`.
- Si envuelve una librería específica, inclúyela: `useFormField` (genérico) vs `useRHFField` (React Hook Form).

```tsx
// ✅
useCart
useAuthSession
useProductFilters
useInfiniteScroll

// ❌
cartHook, useGetCart, UseCart, usecart
```

---

## Funciones y manejadores de eventos

- **camelCase**, comenzando con un **verbo**.
- Implementación del manejador: prefijo `handle` → `handleSubmit`, `handleUserDelete`.
- Props que reciben manejadores: prefijo `on` → `onSubmit`, `onUserDelete`.
- Las funciones async no necesitan sufijo `Async` — el verbo ya lo implica.

```tsx
// ✅
function calcularDescuento(precio: number, tasa: number) {}
const handleFormSubmit = () => {}

<Button onPress={handleFormSubmit} />   // prop = on, implementación = handle

// ❌
function hacerCosas() {}
const submitHandler = () => {}
const asyncFetchData = async () => {}
```

---

## Variables

- **camelCase**.
- Booleanos: prefijo `is`, `has`, `can`, `should`, `was`.
- Evita nombres de una sola letra fuera de contadores de ciclos u operaciones matemáticas.
- Evita abreviaciones salvo las universalmente entendidas (`id`, `url`, `api`, `i18n`).

```tsx
// ✅
const isLoading = false
const hasPermission = true
const canEditProfile = user.role === 'admin'
const productList = []

// ❌
const loading = false      // ambiguo — ¿booleano o estado objeto?
const flag = true
const lst = []
const x = user.data
```

---

## Constantes

- **UPPER_SNAKE_CASE** para constantes a nivel de módulo.
- camelCase es aceptable para constantes con scope dentro de una función o componente.

```tsx
// ✅ nivel módulo
export const MAX_RETRY_ATTEMPTS = 3
export const API_BASE_URL = 'https://api.example.com'

// ✅ con scope
const defaultPageSize = 20
```

---

## Tipos e interfaces

- **PascalCase**, sin prefijo `I` en interfaces.
- Props de componente: sufijo `Props` → `UserProfileCardProps`.
- Respuestas de API: sufijo `Response` o `DTO`.
- Usa `type` para uniones, intersecciones y aliases. Usa `interface` para formas de objeto que puedan extenderse.

```tsx
// ✅
type UserRole = 'admin' | 'editor' | 'viewer'

interface UserProfileCardProps {
  user: User
  onEdit: (id: string) => void
}

interface GetUsersResponse {
  data: User[]
  total: number
}

// ❌
interface IUser {}
type Props = {}          // demasiado genérico
```

---

## CSS / Identificadores de estilos

- Clases CSS: **kebab-case** (`user-profile-card`, `btn-primary`).
- Objetos de estilo (React Native / CSS-in-JS): llaves en **camelCase**, objeto contenedor en **PascalCase**.

```tsx
// React Native StyleSheet
const styles = StyleSheet.create({
  container: {},
  headerTitle: {},
})

// CSS Modules
.user-profile-card {}
.user-profile-card__avatar {}
```

---

## Notas para React Native

Todas las reglas anteriores aplican igual. Adicionalmente:

- Componentes de pantalla llevan sufijo `Screen`: `HomeScreen`, `ProductDetailScreen`.
- Tipos de parámetros de navegación llevan sufijo `Params`: `HomeScreenParams`.
- Evita sufijos de plataforma en código compartido; usa extensiones `.ios.tsx` / `.android.tsx` para bifurcaciones de plataforma.
