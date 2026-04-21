---
description: Aplicar al configurar ESLint y Prettier en un proyecto React/React Native nuevo, o al revisar y estandarizar la configuración de uno existente.
---

# Linting y Formateo — Estándares Frontend

## Base de configuración

Se usa **Airbnb** como conjunto de reglas base, sobre el cual se aplican ajustes específicos del equipo. Airbnb ya cubre la mayoría de buenas prácticas de JS/React; las reglas que se documentan aquí son las que se sobreescriben o agregan explícitamente.

---

## Reglas del equipo

### 1. Export default cuando el archivo exporta una sola cosa

Un archivo con una sola exportación debe usar `export default`. Los named exports se reservan para archivos con múltiples exportaciones (utils, tipos, constantes).

```ts
// ✅ archivo con un solo export
const UserCard = () => { ... }
export default UserCard

// ✅ archivo con múltiples exports — named exports
export const formatDate = () => { ... }
export const formatCurrency = () => { ... }

// ❌ named export en archivo de un solo componente
export const UserCard = () => { ... }
```

```json
"import/prefer-default-export": "error"
```

---

### 2. Funciones de flecha para componentes y funciones

Todos los componentes y funciones se declaran con **arrow functions**. Se evitan las declaraciones con `function` keyword para mantener consistencia en el codebase.

```tsx
// ✅
const UserCard = () => {
  return <div />
}

const calcularDescuento = (precio: number, tasa: number) => {
  return precio * tasa
}

// ❌
function UserCard() {
  return <div />
}
```

```json
"react/function-component-definition": [
  "error",
  { "namedComponents": "arrow-function", "unnamedComponents": "arrow-function" }
],
"func-style": ["error", "expression"]
```

---

### 3. Retorno implícito en arrow functions de una sola expresión

Cuando una arrow function solo retorna una expresión, se omite el `return` explícito y se usan paréntesis. Reduce ruido visual.

```tsx
// ✅ retorno implícito
const double = (n: number) => n * 2

const UserList = ({ users }: UserListProps) => (
  <ul>
    {users.map(user => (
      <li key={user.id}>{user.name}</li>
    ))}
  </ul>
)

// ❌ return explícito innecesario
const double = (n: number) => { return n * 2 }
```

```json
"arrow-body-style": ["error", "as-needed"]
```

---

### 4. Sin spread de props en JSX

El spread de props (`{...props}`) oculta qué valores se están pasando al componente, dificulta el rastreo en revisiones de código y puede generar props inesperadas.

```tsx
// ✅ props explícitas
const Button = ({ label, onClick, disabled }: ButtonProps) => (
  <button onClick={onClick} disabled={disabled}>{label}</button>
)

// ❌ spread pierde trazabilidad
const Button = (props: ButtonProps) => <button {...props} />
```

```json
"react/jsx-props-no-spreading": "error"
```

---

### 5. Longitud máxima de línea: 100 caracteres

Mejora la legibilidad en editores con paneles divididos y en revisiones de código.

```json
"max-len": ["error", { "code": 100, "ignoreUrls": true, "ignoreStrings": true }]
```

---

## Reglas complementarias

### TypeScript

```json
"@typescript-eslint/no-unused-vars": ["error", { "argsIgnorePattern": "^_" }],
"@typescript-eslint/no-explicit-any": "error",
"@typescript-eslint/consistent-type-imports": ["error", { "prefer": "type-imports" }]
```

- `no-explicit-any`: prohíbe el uso de `any`. Si el tipo es desconocido, usar `unknown`.
- `consistent-type-imports`: obliga a importar tipos con `import type { Foo }` para separar imports de valor e imports de tipo.

---

### React y hooks

```json
"react-hooks/rules-of-hooks": "error",
"react-hooks/exhaustive-deps": "warn",
"react/self-closing-comp": "error",
"react/jsx-sort-props": ["warn", { "callbacksLast": true, "shorthandFirst": true }]
```

- `rules-of-hooks`: previene hooks dentro de condicionales o loops.
- `exhaustive-deps`: advierte cuando faltan dependencias en `useEffect` o `useCallback`.
- `self-closing-comp`: obliga a cerrar etiquetas sin hijos en una sola tag (`<Icon />` en vez de `<Icon></Icon>`).
- `jsx-sort-props`: ordena las props — primero las shorthand, al final los callbacks (`on...`).

---

### Calidad general

```json
"prefer-const": "error",
"no-console": ["warn", { "allow": ["warn", "error"] }],
"no-nested-ternary": "error",
"import/order": [
  "error",
  {
    "groups": ["builtin", "external", "internal", "parent", "sibling", "index"],
    "newlines-between": "always",
    "alphabetize": { "order": "asc" }
  }
]
```

- `prefer-const`: usar `const` por defecto, `let` solo cuando la variable se reasigna.
- `no-console`: permite `console.warn` y `console.error` para logging legítimo, prohíbe `console.log` en producción.
- `no-nested-ternary`: prohíbe ternarios anidados (ver también principios de clean-code).
- `import/order`: ordena los imports en grupos con línea en blanco entre ellos — primero built-ins, luego externos, luego internos.

---

## Configuración de Prettier

Prettier maneja el formateo visual; ESLint maneja la calidad del código. No deben solaparse.

```json
// .prettierrc
{
  "semi": false,
  "singleQuote": true,
  "trailingComma": "all",
  "printWidth": 100,
  "tabWidth": 2,
  "arrowParens": "avoid"
}
```

- `semi: false`: sin punto y coma.
- `singleQuote: true`: comillas simples.
- `trailingComma: "all"`: coma final en objetos, arrays y parámetros de función.
- `arrowParens: "avoid"`: sin paréntesis en arrow functions de un solo parámetro (`x => x * 2`).

Instala `eslint-config-prettier` para desactivar las reglas de ESLint que entren en conflicto con Prettier.

---

## Configuraciones base

Todos los proyectos usan TypeScript. La diferencia entre plataformas es el plugin de framework (`@next/next` para Next.js, `@react-native-community` para Expo).

Las reglas del equipo definidas en este archivo son las mismas en ambos casos.

---

### Next.js + TypeScript

```json
{
  "plugins": ["react", "react-hooks", "@next/next", "@typescript-eslint", "import"],
  "extends": [
    "airbnb",
    "plugin:@typescript-eslint/eslint-recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:@next/next/recommended",
    "prettier"
  ],
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "project": "./tsconfig.json"
  },
  "settings": {
    "import/resolver": {
      "typescript": {}
    }
  },
  "rules": {
    "import/prefer-default-export": "error",
    "react/function-component-definition": [
      "error",
      { "namedComponents": "arrow-function", "unnamedComponents": "arrow-function" }
    ],
    "func-style": ["error", "expression"],
    "arrow-body-style": ["error", "as-needed"],
    "react/jsx-props-no-spreading": "error",
    "max-len": ["error", { "code": 100, "ignoreUrls": true, "ignoreStrings": true }],
    "no-unused-vars": "off",
    "@typescript-eslint/no-unused-vars": ["error", { "argsIgnorePattern": "^_" }],
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/consistent-type-imports": ["error", { "prefer": "type-imports" }],
    "react/prop-types": "off",
    "react/require-default-props": "off",
    "react/self-closing-comp": "error",
    "react/react-in-jsx-scope": "off",
    "react-hooks/rules-of-hooks": "error",
    "react-hooks/exhaustive-deps": "warn",
    "prefer-const": "error",
    "no-console": ["warn", { "allow": ["warn", "error"] }],
    "no-nested-ternary": "error",
    "import/extensions": ["error", "ignorePackages", {
      "ts": "never",
      "tsx": "never"
    }],
    "import/order": [
      "error",
      {
        "groups": ["builtin", "external", "internal", "parent", "sibling", "index"],
        "newlines-between": "always",
        "alphabetize": { "order": "asc" }
      }
    ]
  }
}
```

> Requiere el paquete `eslint-import-resolver-typescript` para que `settings.import/resolver` funcione con paths de TypeScript.

---

### Expo (React Native) + TypeScript

```json
{
  "plugins": ["react", "react-hooks", "@typescript-eslint", "import"],
  "extends": [
    "airbnb",
    "plugin:@typescript-eslint/eslint-recommended",
    "plugin:@typescript-eslint/recommended",
    "prettier"
  ],
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "project": "./tsconfig.json"
  },
  "settings": {
    "import/resolver": {
      "typescript": {}
    }
  },
  "rules": {
    "import/prefer-default-export": "error",
    "react/function-component-definition": [
      "error",
      { "namedComponents": "arrow-function", "unnamedComponents": "arrow-function" }
    ],
    "func-style": ["error", "expression"],
    "arrow-body-style": ["error", "as-needed"],
    "react/jsx-props-no-spreading": "error",
    "max-len": ["error", { "code": 100, "ignoreUrls": true, "ignoreStrings": true }],
    "no-unused-vars": "off",
    "@typescript-eslint/no-unused-vars": ["error", { "argsIgnorePattern": "^_" }],
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/consistent-type-imports": ["error", { "prefer": "type-imports" }],
    "react/prop-types": "off",
    "react/require-default-props": "off",
    "react/self-closing-comp": "error",
    "react/react-in-jsx-scope": "off",
    "react-hooks/rules-of-hooks": "error",
    "react-hooks/exhaustive-deps": "warn",
    "prefer-const": "error",
    "no-console": ["warn", { "allow": ["warn", "error"] }],
    "no-nested-ternary": "error",
    "import/extensions": ["error", "ignorePackages", {
      "ts": "never",
      "tsx": "never"
    }],
    "import/order": [
      "error",
      {
        "groups": ["builtin", "external", "internal", "parent", "sibling", "index"],
        "newlines-between": "always",
        "alphabetize": { "order": "asc" }
      }
    ]
  }
}
```
