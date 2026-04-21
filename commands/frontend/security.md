---
description: Aplicar al manejar autenticación, requests HTTP, variables de entorno, datos sensibles o cualquier flujo que involucre información del usuario en proyectos React/React Native.
---

# Seguridad — Estándares Frontend

## 1. Variables de entorno

### Qué puede ir en el cliente y qué no

En Next.js, cualquier variable con prefijo `NEXT_PUBLIC_` se expone en el bundle del cliente — cualquier persona que inspeccione el código fuente puede verla.

```bash
# ✅ seguro en el cliente — son datos públicos por diseño
NEXT_PUBLIC_API_URL=https://api.example.com
NEXT_PUBLIC_MAPS_KEY=pk_live_abc123

# ❌ NUNCA con NEXT_PUBLIC_ — son secretos del servidor
NEXT_PUBLIC_DATABASE_URL=postgres://...     # expone la BD
NEXT_PUBLIC_STRIPE_SECRET_KEY=sk_live_...  # expone pagos
NEXT_PUBLIC_JWT_SECRET=supersecret         # compromete todos los tokens
```

**Regla:** si una variable es un secreto (API key privada, credencial de BD, JWT secret, webhook secret), vive solo en el servidor. El cliente no la necesita ni debe verla.

### Nunca commitear archivos `.env`

```bash
# .gitignore — siempre presente en el repo
.env
.env.local
.env.production
.env*.local
```

Usa `.env.example` sin valores reales para documentar qué variables necesita el proyecto:

```bash
# .env.example — se commitea, sin valores sensibles
NEXT_PUBLIC_API_URL=
DATABASE_URL=
JWT_SECRET=
```

---

## 2. Almacenamiento de tokens

### Web — cookies httpOnly sobre localStorage

`localStorage` es accesible desde JavaScript, lo que lo hace vulnerable a ataques XSS: si un script malicioso se ejecuta en la página, puede leer y exfiltrar el token.

| Mecanismo | Accesible por JS | Enviado automáticamente | Recomendado |
|---|---|---|---|
| `httpOnly` cookie | ❌ No | ✅ Sí | ✅ Auth tokens |
| `localStorage` | ✅ Sí | ❌ No | ❌ Auth tokens |
| `sessionStorage` | ✅ Sí | ❌ No | ❌ Auth tokens |
| Cookie sin `httpOnly` | ✅ Sí | ✅ Sí | ❌ |

```ts
// ❌ token expuesto a XSS
localStorage.setItem('access_token', token)

// ✅ el servidor setea la cookie httpOnly — JS nunca puede leerla
// Set-Cookie: token=abc123; HttpOnly; Secure; SameSite=Strict
```

Si por limitaciones técnicas debes usar `localStorage`, implementa tokens de corta duración (< 15 min) y refresh tokens en cookies httpOnly.

### React Native — SecureStore sobre AsyncStorage

`AsyncStorage` guarda datos en texto plano. Para tokens de autenticación usa `expo-secure-store`, que cifra los datos usando el keychain del dispositivo.

```ts
import * as SecureStore from 'expo-secure-store'

// ✅ cifrado en el keychain del dispositivo
await SecureStore.setItemAsync('access_token', token)
const token = await SecureStore.getItemAsync('access_token')

// ❌ texto plano, accesible si el dispositivo está rooteado
await AsyncStorage.setItem('access_token', token)
```

---

## 3. Requests HTTP

### Token en headers, nunca en la URL

Los tokens en URLs quedan expuestos en logs del servidor, historial del browser y cabeceras `Referer`.

```ts
// ❌ token expuesto en logs y historial
fetch(`https://api.example.com/users?token=${accessToken}`)

// ✅ token en el header Authorization
fetch('https://api.example.com/users', {
  headers: {
    Authorization: `Bearer ${accessToken}`,
  },
})
```

### HTTPS obligatorio

Nunca hacer requests a endpoints HTTP en producción. Los tokens y datos viajan en texto plano sobre HTTP.

```ts
// ❌
const API_URL = 'http://api.example.com'

// ✅
const API_URL = 'https://api.example.com'
```

### No loguear requests ni responses con datos sensibles

```ts
// ❌ expone tokens y datos de usuario en logs
console.log('Request:', config)
console.log('Response:', response.data)

// ✅ loguea solo lo necesario para debugging
console.warn('Request failed:', response.status, response.config.url)
```

### Interceptor de errores de autenticación

Maneja expiración de tokens de forma centralizada para no repetirlo en cada llamada.

```ts
apiClient.interceptors.response.use(
  response => response,
  async error => {
    if (error.response?.status === 401) {
      await authService.refreshToken()
      return apiClient.request(error.config)
    }
    return Promise.reject(error)
  }
)
```

---

## 4. CSRF (Cross-Site Request Forgery)

CSRF es un ataque donde un sitio malicioso engaña al browser del usuario para que haga requests autenticados a tu app sin su consentimiento.

### Cómo el frontend contribuye a la protección

El backend es el responsable principal, pero el frontend debe alinearse:

**1. Enviar el CSRF token en cada request mutante (POST, PUT, DELETE, PATCH):**

```ts
// El backend setea el token en una cookie legible por JS (no httpOnly)
const csrfToken = getCookie('csrftoken')

apiClient.defaults.headers.common['X-CSRFToken'] = csrfToken

// O por request individual
fetch('/api/users', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'X-CSRFToken': csrfToken,
  },
  body: JSON.stringify(data),
})
```

**2. Si el backend usa cookies `SameSite=Strict` o `SameSite=Lax`, el CSRF está cubierto a nivel de browser** — los requests cross-site no incluirán la cookie automáticamente.

**3. Nunca deshabilites CORS en desarrollo con `*` y lo olvides en producción:**

```ts
// ❌ en producción esto permite requests desde cualquier origen
Access-Control-Allow-Origin: *

// ✅ lista blanca de orígenes permitidos
Access-Control-Allow-Origin: https://tuapp.com
```

---

## 5. Exploits de autenticación

### Mensajes de error genéricos en login

Los mensajes específicos permiten enumerar si un email existe en el sistema, facilitando ataques dirigidos.

```tsx
// ❌ revela si el email existe
if (!user) return 'No existe una cuenta con ese email'
if (!passwordMatch) return 'Contraseña incorrecta'

// ✅ mensaje genérico — no da información al atacante
return 'Email o contraseña incorrectos'
```

### No persistir contraseñas ni datos sensibles de sesión

```ts
// ❌ nunca
localStorage.setItem('password', password)
localStorage.setItem('user', JSON.stringify({ ...user, password }))

// ✅ solo persistir lo necesario para la sesión
localStorage.setItem('user_id', user.id)
// mejor aún: dejar que el servidor maneje la sesión vía cookie httpOnly
```

### Limpiar estado de autenticación al cerrar sesión

El logout debe limpiar todo: tokens, estado en memoria, cache de React Query, y redirigir.

```ts
const logout = async () => {
  await authService.logout()          // invalida el token en el servidor
  queryClient.clear()                 // limpia cache de React Query
  clearAuthStorage()                  // limpia cualquier dato local
  router.replace('/login')            // redirige y borra el historial
}
```

### Proteger rutas del cliente

Aunque la protección real de datos es responsabilidad del backend, el cliente debe proteger rutas para evitar que usuarios no autenticados vean UI sensible.

```tsx
// Next.js — middleware de protección de rutas
export const middleware = (request: NextRequest) => {
  const token = request.cookies.get('session')

  if (!token && !request.nextUrl.pathname.startsWith('/login')) {
    return NextResponse.redirect(new URL('/login', request.url))
  }
}

export const config = {
  matcher: ['/dashboard/:path*', '/profile/:path*'],
}
```

---

## 6. Prevención de XSS

XSS (Cross-Site Scripting) ocurre cuando se ejecuta código malicioso en el contexto de tu app, generalmente por renderizar input del usuario sin sanitizar.

### Evitar `dangerouslySetInnerHTML`

React escapa el HTML por defecto. `dangerouslySetInnerHTML` desactiva esa protección.

```tsx
// ❌ ejecuta cualquier script en el HTML del usuario
<div dangerouslySetInnerHTML={{ __html: userContent }} />

// ✅ si necesitas renderizar HTML del usuario, sanitiza primero
import DOMPurify from 'dompurify'

<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(userContent) }} />

// ✅ mejor aún: renderiza como texto plano si no necesitas HTML
<p>{userContent}</p>
```

### Nunca usar `eval()` ni similares

```ts
// ❌
eval(userInput)
new Function(userInput)()
setTimeout(userInput, 0)   // cuando userInput es un string
```

### Validar y sanitizar input antes de enviarlo al servidor

La validación del cliente no reemplaza la del servidor, pero previene envío de datos malformados.

```ts
// ✅ validación con zod antes de enviar
const schema = z.object({
  name: z.string().min(1).max(100),
  email: z.string().email(),
})

const result = schema.safeParse(formData)
if (!result.success) return showErrors(result.error)

await userService.update(result.data)
```

---

## 7. Datos sensibles en código

### No hardcodear credenciales

```ts
// ❌ credenciales en código fuente — quedan en el historial de git
const apiKey = 'sk_live_abc123xyz'
const dbPassword = 'P@ssw0rd!'

// ✅ siempre desde variables de entorno
const apiKey = process.env.API_SECRET_KEY
```

### No loguear datos sensibles

```ts
// ❌
console.log('Usuario autenticado:', user)           // expone email, roles, etc.
console.log('Token:', accessToken)
console.log('Form data:', { email, password })

// ✅ loguea solo identificadores no sensibles
console.log('Usuario autenticado, id:', user.id)
```

### No incluir datos sensibles en mensajes de error al cliente

```ts
// ❌ el cliente recibe detalles del stack o de la BD
catch (error) {
  return res.status(500).json({ error: error.message })
  // ej: "column 'password_hash' does not exist in table 'users'"
}

// ✅ mensaje genérico al cliente, detalle solo en logs del servidor
catch (error) {
  logger.error(error)
  return res.status(500).json({ error: 'Error interno del servidor' })
}
```

---

## Notas para React Native

- Usa `expo-secure-store` para cualquier dato sensible; `AsyncStorage` solo para datos no sensibles (preferencias, tema, idioma).
- Valida los deep links antes de procesarlos — un link malicioso puede intentar ejecutar acciones autenticadas.
- No incluyas API keys privadas en el bundle de la app — son extraíbles con herramientas de análisis de APK/IPA. Usa un backend intermediario (BFF) si necesitas llamar APIs con secretos.
- En apps de producción, evalúa certificate pinning para prevenir ataques de man-in-the-middle en redes comprometidas.
