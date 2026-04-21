---
description: Aplicar al crear un proyecto nuevo, decidir dónde colocar un archivo, refactorizar la estructura de carpetas, o definir cómo organizar componentes y capas en un proyecto React/React Native.
---

# Arquitectura — Estándares Frontend

## Principio base

**Arquitectura de capas + Atomic Design.** El código se organiza por tipo de archivo (capas horizontales) y los componentes siguen la jerarquía de Atomic Design: de los más pequeños e independientes hacia los más complejos y conectados al dominio.

---

## Atomic Design — jerarquía de componentes

```
atoms → molecules → organisms → templates → screens/pages
```

| Nivel | Qué es | Ejemplos |
|---|---|---|
| **Atoms** | Unidad mínima UI, sin dependencias de dominio | `Button`, `Input`, `Label`, `Icon`, `Avatar`, `Badge` |
| **Molecules** | Combinación de átomos con una función específica | `SearchBar`, `FormField`, `UserCard`, `Notification` |
| **Organisms** | Secciones complejas, pueden conocer el dominio | `Header`, `LoginForm`, `ProductGrid`, `Sidebar` |
| **Templates** | Estructura/layout de una pantalla sin datos reales | `DashboardLayout`, `AuthLayout`, `TwoColumnLayout` |
| **Screens / Pages** | Template + datos reales + lógica de negocio | `HomeScreen`, `LoginPage`, `ProductDetailScreen` |

**Regla de dependencias:** cada nivel solo puede importar del mismo nivel o de uno inferior. Un átomo nunca importa un organismo.

```
Screens/Pages   ← conectados a hooks, servicios y estado
    ↑
Templates       ← solo estructura, sin lógica de negocio
    ↑
Organisms       ← pueden recibir datos del dominio vía props
    ↑
Molecules       ← combinan átomos, sin conocimiento del dominio
    ↑
Atoms           ← puramente presentacionales, 100% reutilizables
```

---

## Estructura de carpetas

```
src/
├── components/
│   ├── atoms/                  ← solo componentes genéricos, sin dominio
│   │   ├── Button/
│   │   │   ├── Button.tsx
│   │   │   └── Button.test.tsx
│   │   ├── Input/
│   │   ├── Icon/
│   │   └── ...
│   ├── molecules/
│   │   ├── FormField/          ← molécula genérica
│   │   ├── SearchBar/
│   │   └── developments/       ← moléculas específicas del dominio
│   │       └── DevelopmentStatusCard/
│   └── organisms/
│       ├── Header/             ← organismo genérico
│       └── developments/       ← organismos específicos del dominio
│           └── DevelopmentFilters/
│
├── templates/              ← layouts y estructuras de página
│   ├── AuthLayout/
│   ├── DashboardLayout/
│   └── ...
│
├── screens/ (RN) | pages/ (web)
│   ├── HomeScreen/
│   │   ├── HomeScreen.tsx
│   │   └── HomeScreen.test.tsx
│   └── ...
│
├── hooks/                  ← hooks reutilizables de la app
│   ├── useDebounce.ts      ← hook genérico, sin dominio
│   ├── useMediaQuery.ts
│   └── developments/       ← hooks específicos del dominio
│       ├── useDevelopments.ts
│       └── useDevelopmentFilters.ts
│
├── services/               ← llamadas a la API, una por recurso
│   ├── userService.ts
│   ├── productService.ts
│   └── apiClient.ts
│
├── providers/              ← context providers (tema, auth, i18n)
│
├── utils/                  ← funciones puras sin dependencia de React
│
├── types/                  ← tipos e interfaces globales
│
├── constants/              ← constantes de la app
│
└── assets/                 ← imágenes, fuentes, íconos estáticos
```

---

## Dónde vive cada archivo — árbol de decisión

### Componente nuevo

```
¿Es la unidad mínima UI y no depende de ningún otro componente?
├── Sí → atoms/
│         ¿Tiene lógica o visual específica de un dominio?
│         ├── Sí → No es un átomo real. Reclasifica como molecule o organism.
│         └── No → atoms/NombreComponente/  ✅
│
├── No → ¿Combina átomos para una función concreta?
│         ├── Sí → molecules/
│         │         ¿Es reutilizable en cualquier dominio?
│         │         ├── Sí → molecules/NombreComponente/  ✅
│         │         └── No → molecules/[dominio]/NombreComponente/  ✅
│         │
│         └── No → ¿Es una sección compleja que puede conocer datos del dominio?
│                   ├── Sí → organisms/
│                   │         ¿Es reutilizable en cualquier dominio?
│                   │         ├── Sí → organisms/NombreComponente/  ✅
│                   │         └── No → organisms/[dominio]/NombreComponente/  ✅
│                   │
│                   └── No → ¿Define la estructura de una pantalla sin datos?
│                             ├── Sí → templates/NombreLayout/  ✅
│                             └── No → screens/ o pages/  ✅
```

**Regla clave para atoms:** si un componente pertenece a un dominio específico (developments, auth, payments...), casi siempre es una molecule u organism. Los átomos son siempre genéricos: `Button`, `Input`, `Badge`, `Icon`. Si sientes la necesidad de crear `atoms/developments/`, detente y reclasifica.

---

### Hook nuevo

```
¿Lo usa solo un componente?
├── Sí → Co-localiza junto al componente
│         components/organisms/developments/DevelopmentFilters/
│         ├── DevelopmentFilters.tsx
│         └── useDevelopmentFilters.ts  ✅
│
└── No → ¿Es genérico y reutilizable en cualquier dominio?
          ├── Sí → hooks/useNombre.ts  ✅
          └── No → hooks/[dominio]/useNombre.ts  ✅
```

---

## Capa de servicios / API

- Las llamadas a la API viven en `services/`, nunca en componentes ni hooks.
- Un archivo por recurso: `userService.ts`, `productService.ts`.
- Los servicios retornan datos tipados, nunca respuestas crudas.
- Los hooks de React Query / SWR envuelven servicios — no los reemplazan.

```ts
// ✅ services/userService.ts
export async function getUser(id: string): Promise<User> {
  const res = await apiClient.get(`/users/${id}`)
  return res.data
}

// ✅ hooks/useUser.ts
export function useUser(id: string) {
  return useQuery({ queryKey: ['user', id], queryFn: () => getUser(id) })
}

// ✅ screens/UserProfileScreen.tsx — solo orquesta
function UserProfileScreen({ id }: { id: string }) {
  const { data: user, isLoading } = useUser(id)
  if (isLoading) return <Spinner />
  return <UserProfileOrganism user={user} />
}
```

---

## Reglas de ubicación del estado

| Tipo de estado | Dónde vive |
|---|---|
| Estado UI local (abierto/cerrado, tab activa) | `useState` en el componente |
| Estado UI compartido entre componentes cercanos | Elevar al ancestro común más cercano |
| Estado servidor / async | React Query o SWR |
| Estado global de la app (auth, tema, idioma) | Context provider en `providers/` |
| Estado en URL (filtros, paginación) | URL params / search params |

La lógica de negocio vive en `screens/pages` y hooks — nunca en atoms, molecules ni templates.

---

## Anti-patrones

- **Átomo que importa un organismo**: rompe la jerarquía y genera dependencias circulares.
- **Screen con JSX extenso**: un screen solo debe orquestar — si tiene más de ~40 líneas de JSX, extrae organismos.
- **Lógica de negocio en templates o molecules**: los templates son estructura, las molecules son UI — ninguno de los dos debe saber de la API o del estado global.
- **Hook global para lógica de un solo componente**: co-localiza en lugar de contaminar `hooks/`.
- **Organism que llama directamente a la API**: los organismos reciben datos por props; los screens y hooks son quienes fetchen.

---

## Notas para React Native

La estructura es idéntica. Diferencias puntuales:

- `screens/` en lugar de `pages/`.
- Agrega `navigation/` dentro de `src/` para los stacks y tabs de React Navigation.
- Los tipos de parámetros de navegación se co-localizan con el archivo del navigator.
- Los archivos específicos de plataforma usan extensiones `.ios.tsx` / `.android.tsx`; el código compartido no lleva sufijo.
- Los `StyleSheet.create` se definen fuera del componente para evitar recreación en cada render.

```
src/
├── components/         ← atoms / molecules / organisms (igual que web)
├── templates/
├── screens/
├── navigation/         ← stacks, tabs, tipos de params
├── hooks/
├── services/
├── providers/
├── utils/
├── types/
├── constants/
└── assets/
```
