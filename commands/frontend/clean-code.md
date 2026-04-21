---
description: Aplicar al escribir, revisar o refactorizar cualquier componente, hook o función en un proyecto React/React Native. Define los principios de calidad de código que todo el equipo debe seguir.
---

# Código Limpio — Estándares Frontend

## Principio base

**El código se lee muchas más veces de las que se escribe.** Cada decisión de estilo debe favorecer la legibilidad y el mantenimiento por encima de la brevedad o la cleverness.

---

## Principios SOLID en React

### S — Responsabilidad única *(Single Responsibility)*

Un componente, hook o función hace **una sola cosa**.

- Un componente que fetcha datos, gestiona estado complejo y renderiza UI detallada está haciendo demasiado.
- Separa en: lógica (hook) + presentación (componente).
- Si necesitas un comentario para explicar qué hace una sección, probablemente debería ser una función separada.

```tsx
// ❌ componente haciendo demasiado
function ProductPage({ id }: { id: string }) {
  const [product, setProduct] = useState(null)
  const [reviews, setReviews] = useState([])
  useEffect(() => { /* fetch product */ }, [id])
  useEffect(() => { /* fetch reviews */ }, [id])
  // ...100 líneas de render
}

// ✅
function ProductPage({ id }: { id: string }) {
  const { product } = useProduct(id)
  const { reviews } = useProductReviews(id)
  return <ProductLayout product={product} reviews={reviews} />
}
```

---

### O — Abierto/Cerrado *(Open/Closed)*

Un componente debe estar **abierto para extensión, cerrado para modificación**. Añade comportamiento nuevo sin tocar el componente existente.

La herramienta principal en React para esto es la **composición**: props como `children`, `renderHeader`, `renderItem`, o variantes por prop en lugar de condicionales internos que crecen indefinidamente.

```tsx
// ❌ cada nueva variante requiere modificar el componente
function Alert({ type }: { type: 'success' | 'error' | 'warning' | 'info' }) {
  if (type === 'success') return <div className="alert-success">...</div>
  if (type === 'error') return <div className="alert-error">...</div>
  // hay que tocar esto cada vez que se añade un tipo nuevo
}

// ✅ extensible sin modificar
interface AlertProps {
  icon: React.ReactNode
  className: string
  children: React.ReactNode
}

function Alert({ icon, className, children }: AlertProps) {
  return (
    <div className={`alert ${className}`}>
      {icon}
      {children}
    </div>
  )
}

// Se extiende creando variantes, no modificando Alert
function SuccessAlert({ children }: { children: React.ReactNode }) {
  return <Alert icon={<CheckIcon />} className="alert-success">{children}</Alert>
}
```

---

### L — Sustitución de Liskov *(Liskov Substitution)*

Un componente que extiende o envuelve a otro debe poder **usarse en su lugar sin romper nada**. Si creas un `PrimaryButton` basado en `Button`, debe aceptar todas las props de `Button` y comportarse igual salvo las diferencias intencionales.

```tsx
// ❌ PrimaryButton rompe el contrato de Button al omitir props
function PrimaryButton({ label }: { label: string }) {
  return <button className="btn-primary">{label}</button>
  // perdió onClick, disabled, type, y todo lo demás
}

// ✅ extiende sin romper
interface PrimaryButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  label: string
}

function PrimaryButton({ label, className, ...rest }: PrimaryButtonProps) {
  return (
    <button className={`btn-primary ${className ?? ''}`} {...rest}>
      {label}
    </button>
  )
}
```

Aplica igual a hooks: un `useAdminUser` que extiende `useUser` debe retornar al menos lo mismo que `useUser` más lo adicional, nunca menos.

---

### I — Segregación de interfaces *(Interface Segregation)*

No obligues a un componente a depender de props que no usa. **Interfaces pequeñas y específicas** sobre una grande y genérica.

```tsx
// ❌ el componente recibe todo el objeto User aunque solo use dos campos
interface UserCardProps {
  user: User   // User tiene 20+ campos
}

function UserCard({ user }: UserCardProps) {
  return <p>{user.name} — {user.email}</p>
  // solo usa name y email, pero está acoplado a toda la forma de User
}

// ✅ pide solo lo que necesita
interface UserCardProps {
  name: string
  email: string
}

function UserCard({ name, email }: UserCardProps) {
  return <p>{name} — {email}</p>
}
```

Beneficio adicional: el componente se vuelve más fácil de testear y reutilizar con cualquier fuente de datos, no solo con objetos `User`.

---


## Tamaño de componentes y funciones

- Un componente debería caber en pantalla sin scroll (≈ 80–100 líneas de JSX).
- Una función no debería superar 30–40 líneas. Si supera ese límite, busca qué extraer.
- Si el JSX de un componente tiene más de 3 niveles de anidamiento, es momento de extraer sub-componentes.

---

## Retornos tempranos (early returns)

Elimina el anidamiento con retornos tempranos. Reduce la carga cognitiva.

```tsx
// ❌ anidamiento innecesario
function UserGreeting({ user }: { user: User | null }) {
  if (user) {
    if (user.isActive) {
      return <p>Hola, {user.name}</p>
    } else {
      return <p>Cuenta inactiva</p>
    }
  } else {
    return <p>No autenticado</p>
  }
}

// ✅
function UserGreeting({ user }: { user: User | null }) {
  if (!user) return <p>No autenticado</p>
  if (!user.isActive) return <p>Cuenta inactiva</p>
  return <p>Hola, {user.name}</p>
}
```

---

## Props

- Define siempre la interfaz de props explícitamente con `interface ComponentNameProps`.
- No uses `React.FC` — declara la función directamente y tipea las props.
- Desestructura las props en la firma de la función.
- Evita pasar props booleanas como `={true}` — basta con el nombre de la prop.
- No más de 5–6 props por componente. Si necesitas más, evalúa si el componente está haciendo demasiado o si conviene agrupar props en un objeto.

```tsx
// ❌
const Button: React.FC<{ label: string; disabled: boolean; onClick: () => void }> = (props) => {
  return <button disabled={props.disabled === true} onClick={props.onClick}>{props.label}</button>
}

// ✅
interface ButtonProps {
  label: string
  disabled?: boolean
  onClick: () => void
}

function Button({ label, disabled, onClick }: ButtonProps) {
  return <button disabled={disabled} onClick={onClick}>{label}</button>
}

<Button label="Guardar" disabled onClick={handleSave} />
```

---

## Evitar prop drilling

Si pasas una prop a través de 3 o más niveles de componentes que no la usan directamente, es una señal de alerta. Opciones:

1. Composición con `children` o render props.
2. Context para estado verdaderamente global o semi-global.
3. Co-localizar el estado más cerca de donde se usa.

```tsx
// ❌ drilling a través de 3 niveles
<Page user={user}>
  <Layout user={user}>
    <Header user={user}>
      <Avatar user={user} />
    </Header>
  </Layout>
</Page>

// ✅ composición
<Page>
  <Layout>
    <Header>
      <Avatar user={user} />
    </Header>
  </Layout>
</Page>
```

---

## Ternarios y lógica condicional

- Un ternario anidado dentro de otro es un anti-patrón. Extrae en una variable o función.
- Para renderizado condicional complejo, extrae en un sub-componente o en una función de render.

```tsx
// ❌
const label = isAdmin ? (isPremium ? 'Admin Premium' : 'Admin') : (isPremium ? 'Premium' : 'Usuario')

// ✅
function getUserLabel(isAdmin: boolean, isPremium: boolean): string {
  if (isAdmin && isPremium) return 'Admin Premium'
  if (isAdmin) return 'Admin'
  if (isPremium) return 'Premium'
  return 'Usuario'
}
```

---

## Sin números o strings mágicos

Los valores literales en el código deben tener un nombre que explique su significado.

```tsx
// ❌
if (user.role === 3) { ... }
setTimeout(callback, 86400000)

// ✅
const ROLE_ADMIN = 3
const ONE_DAY_MS = 86_400_000

if (user.role === ROLE_ADMIN) { ... }
setTimeout(callback, ONE_DAY_MS)
```

---

## Funciones puras y efectos secundarios

- Prefiere funciones puras: mismo input → mismo output, sin efectos secundarios.
- Los efectos secundarios (fetch, timers, subscripciones) van en `useEffect` o en event handlers — nunca durante el render.
- No mutes el estado directamente; siempre retorna nuevos valores.

```tsx
// ❌ mutación directa
const addItem = (list: Item[], item: Item) => {
  list.push(item)   // muta el array original
  return list
}

// ✅ función pura
const addItem = (list: Item[], item: Item): Item[] => [...list, item]
```

---

## Comentarios

Los comentarios explican el **por qué**, no el qué. El código bien nombrado ya explica el qué.

```tsx
// ❌ explica lo obvio
// incrementa el contador en 1
setCount(count + 1)

// ✅ explica una restricción no obvia
// La API de pagos requiere un delay mínimo de 500ms entre reintentos
await delay(500)
retryPayment()
```

---

## Extracción de lógica a hooks

Toda lógica con estado o efectos secundarios que no sea trivial debe vivir en un hook personalizado, no en el cuerpo del componente.

```tsx
// ❌ lógica mezclada con el render
function ProductList() {
  const [products, setProducts] = useState([])
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState(null)

  useEffect(() => {
    setIsLoading(true)
    fetchProducts()
      .then(setProducts)
      .catch(setError)
      .finally(() => setIsLoading(false))
  }, [])

  return isLoading ? <Spinner /> : <List items={products} />
}

// ✅ lógica en hook
function ProductList() {
  const { products, isLoading, error } = useProducts()
  if (isLoading) return <Spinner />
  if (error) return <ErrorMessage error={error} />
  return <List items={products} />
}
```

---

## Notas para React Native

Todos los principios anteriores aplican. Adicionalmente:

- Evita lógica de negocio en componentes de pantalla (`Screen`) — delega a hooks o servicios.
- Los `StyleSheet.create` deben definirse fuera del componente para evitar recreación en cada render.
- Evita estilos inline salvo para valores verdaderamente dinámicos.
