---
description: Aplicar al diseñar, crear o revisar componentes React/React Native. Cubre variantes, patrones de composición, estados UI, memoización y estructura interna de archivos.
---

# Componentes — Estándares Frontend

## 1. Variantes con prop `variant`

Cuando un componente tiene múltiples apariencias, una prop `variant` como union type es más limpia que múltiples booleanos. Los booleanos generan combinaciones inválidas y la interfaz se vuelve ambigua.

```tsx
// ❌ combinaciones que explotan: isPrimary + isDanger = ¿qué gana?
interface ButtonProps {
  isPrimary?: boolean
  isDanger?: boolean
  isOutline?: boolean
}

// ✅ una sola variante activa a la vez, autocompletado claro
type ButtonVariant = 'primary' | 'secondary' | 'danger' | 'ghost'

interface ButtonProps {
  variant?: ButtonVariant
  children: React.ReactNode
  onClick?: () => void
}
```

---

## 2. Patrones de composición

### Compound components

Útil cuando un componente tiene partes relacionadas que comparten estado implícito. Cada parte es un sub-componente con nombre explícito, eliminando prop drilling sin necesidad de un Context externo.

```tsx
// Uso limpio desde el consumidor
<Select value={value} onChange={setValue}>
  <Select.Option value="react">React</Select.Option>
  <Select.Option value="vue">Vue</Select.Option>
</Select>

// Implementación
const SelectContext = createContext<SelectContextType | null>(null)

const Select = ({ value, onChange, children }: SelectProps) => (
  <SelectContext.Provider value={{ value, onChange }}>
    <div className="select">{children}</div>
  </SelectContext.Provider>
)

const Option = ({ value, children }: OptionProps) => {
  const ctx = useContext(SelectContext)
  return (
    <div
      className={ctx?.value === value ? 'option selected' : 'option'}
      onClick={() => ctx?.onChange(value)}
    >
      {children}
    </div>
  )
}

Select.Option = Option
export default Select
```

Úsalo cuando las partes no tienen sentido por separado y quieres una API de consumo expresiva.

---

### Render props / children como función

Útil cuando el componente padre necesita exponer datos o comportamiento al contenido que renderiza, sin acoplarse a cómo se renderiza.

```tsx
const DataList = <T,>({ items, children }: DataListProps<T>) => (
  <ul>
    {items.map((item, index) => (
      <li key={index}>{children(item)}</li>
    ))}
  </ul>
)

// El consumidor controla el render de cada ítem
<DataList items={products}>
  {product => <ProductCard name={product.name} price={product.price} />}
</DataList>
```

Úsalo cuando necesitas compartir lógica de iteración o estado sin decidir cómo se pinta el resultado.

---

## 3. Estados UI obligatorios

Todo componente que depende de datos asincrónicos debe manejar explícitamente cuatro estados. Omitir alguno genera pantallas en blanco o errores sin feedback al usuario.

| Estado | Cuándo ocurre | Qué mostrar |
|---|---|---|
| **Loading** | La petición está en curso | Skeleton o spinner |
| **Error** | La petición falló | Mensaje + acción de reintento si aplica |
| **Empty** | Respuesta exitosa pero sin datos | Mensaje descriptivo + acción sugerida |
| **Success** | Hay datos | El contenido normal |

```tsx
// ❌ solo maneja el caso exitoso
const ProductList = () => {
  const { data } = useProducts()
  return <List items={data} />
}

// ✅ los cuatro estados cubiertos
const ProductList = () => {
  const { data: products, isLoading, isError } = useProducts()

  if (isLoading) return <ProductListSkeleton />
  if (isError) return <ErrorMessage message="No se pudieron cargar los productos" />
  if (!products.length) return <EmptyState message="Aún no hay productos disponibles" />

  return <List items={products} />
}
```

Define componentes genéricos para estos estados en `shared/components/molecules` para no reinventarlos en cada pantalla:

```
shared/components/molecules/
├── ErrorMessage/
└── EmptyState/        ← recibe icon, message y una acción opcional
```

---

## 4. Memoización

La memoización tiene un costo real: memoria y complejidad de lectura. Úsala solo cuando hay un problema de rendimiento medible, no de forma preventiva.

### `React.memo` — evita re-renders del componente

```tsx
// ✅ tiene sentido: ítem de lista larga con render costoso
const ProductCard = React.memo(({ name, price, imageUrl }: ProductCardProps) => (
  <div className="product-card">
    <img src={imageUrl} alt={name} />
    <p>{name}</p>
    <span>{price}</span>
  </div>
))

// ❌ no tiene sentido: componente simple que casi siempre recibe props nuevas
const Title = React.memo(({ text }: { text: string }) => <h1>{text}</h1>)
```

### `useMemo` — memoriza el resultado de un cálculo

```tsx
// ✅ tiene sentido: filtrado y ordenamiento de lista grande
const filteredProducts = useMemo(
  () => products.filter(p => p.category === activeCategory).sort(byPrice),
  [products, activeCategory]
)

// ❌ no tiene sentido: operación trivial
const fullName = useMemo(
  () => `${user.firstName} ${user.lastName}`,
  [user]
)
// mejor:
const fullName = `${user.firstName} ${user.lastName}`
```

### `useCallback` — memoriza una función

Solo útil cuando la función se pasa como prop a un componente memoizado, o es dependencia de un `useEffect`.

```tsx
// ✅ tiene sentido: se pasa a un componente con React.memo
const handleDelete = useCallback((id: string) => {
  deleteProduct(id)
}, [deleteProduct])

<ProductCard onDelete={handleDelete} />

// ❌ no tiene sentido: no se pasa a ningún hijo memoizado
const handleToggle = useCallback(() => setIsOpen(prev => !prev), [])
```

**Regla práctica:** escribe sin memoización. Si el profiler de React DevTools muestra un problema real, memoiza el punto exacto.

---

## 5. Estructura interna de un archivo

Todo archivo de componente sigue el mismo orden para que cualquier persona del equipo pueda orientarse sin leer el archivo completo.

```tsx
// 1. Imports externos
import { useState, useCallback } from 'react'

// 2. Imports internos
import { Button } from '@/shared/components/atoms/Button'
import { useProductFilters } from '@/hooks/developments/useProductFilters'
import type { Product } from '@/types'

// 3. Tipos del componente
interface ProductCardProps {
  product: Product
  onAddToCart: (id: string) => void
}

// 4. Constantes locales
const MAX_DESCRIPTION_LENGTH = 120

// 5. Componente
const ProductCard = ({ product, onAddToCart }: ProductCardProps) => {
  // a. Estado local
  const [isExpanded, setIsExpanded] = useState(false)

  // b. Hooks
  const { activeFilters } = useProductFilters()

  // c. Derivaciones (valores calculados, no estado)
  const shortDescription = product.description.slice(0, MAX_DESCRIPTION_LENGTH)

  // d. Handlers
  const handleAddToCart = useCallback(() => {
    onAddToCart(product.id)
  }, [product.id, onAddToCart])

  // e. Render
  return (
    <div className="product-card">
      <h3>{product.name}</h3>
      <p>{isExpanded ? product.description : shortDescription}</p>
      <Button variant="primary" onClick={handleAddToCart}>
        Agregar al carrito
      </Button>
    </div>
  )
}

// 6. Export
export default ProductCard
```

**Handlers siempre antes del return**, nunca definidos inline en el JSX salvo que sean de una sola expresión trivial.

---

## Notas para React Native

- Los estados de loading usan `ActivityIndicator` en lugar de spinners web.
- Compound components y render props funcionan exactamente igual.
- `React.memo` aplica con los mismos criterios — no memoizar preventivamente.
