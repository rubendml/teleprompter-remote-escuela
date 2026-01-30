# Guía de Arquitectura - Teleprompter Remote Escuela

## Visión General

Teleprompter Remote Escuela es una aplicación Cliente-Servidor que utiliza WebSocket para comunicación bidireccional en tiempo real entre dos interfaces:

```
┌──────────────────┐          WebSocket           ┌──────────────────┐
│                  │◄───────────────────────────► │                  │
│  Teleprompter    │      ws://localhost:3000     │   Control Remoto │
│  (teleprompter   │◄───────────────────────────► │  (remote.html)   │
│   .html)         │      Sincronización Real     │                  │
│                  │          (JSON)              │                  │
└──────────────────┘                              └──────────────────┘
    Pantalla Principal                              Panel de Control
```

## Componentes del Sistema

### 1. Backend: Servidor WebSocket (server.js)

**Responsabilidades:**
- Gestionar conexiones de clientes
- Retransmitir mensajes entre clientes conectados
- Mantener el estado de conexión

**Flujo:**
```
Cliente conecta → Evento 'connection' → En espera de mensajes
                                    ↓
                           Evento 'message'
                                    ↓
                      Retransmitir a todos los clientes
```

**Código:**
```javascript
const WebSocket = require("ws");
const PORT = process.env.PORT || 3000;

const wss = new WebSocket.Server({ port: PORT });

wss.on("connection", (ws) => {
  ws.on("message", (message) => {
    // Broadcast a todos los clientes
    wss.clients.forEach(client => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(message.toString());
      }
    });
  });
});

console.log("🟢 WebSocket activo");
```

**Tecnologías:**
- Node.js (Runtime)
- `ws` (Librería WebSocket)

---

### 2. Frontend: Teleprompter Principal (teleprompter.html)

**Responsabilidades:**
- Mostrar el texto a desplazarse
- Controlar la velocidad de desplazamiento
- Manejar modos especiales (espejo, cámara)
- Escuchar comandos del control remoto

**Estructura HTML:**
```html
<div id="container">
  <div id="text"><!-- Texto a desplazar --></div>
  <div id="guide"><!-- Línea guía central --></div>
  <textarea><!-- Input de texto --></textarea>
  <input type="number"> <!-- Control de velocidad -->
</div>
```

**Variables de Estado:**
```javascript
let scrollSpeed = 2;        // Velocidad actual
let isPaused = false;       // Estado de pausa
let isMirror = false;       // Modo espejo
let isCamera = false;       // Modo cámara
```

**Flujo de Desplazamiento:**
```
requestAnimationFrame
        ↓
  isPaused = false?
        ├─ NO → Actualizar scrollTop
        └─ SÍ → No hacer nada
        ↓
Repetir cada frame
```

**Comunicación:**
- **Recibe:** Comandos del control remoto (velocidad, pausa, etc.)
- **Envía:** Estado actual (opcional)

**Características CSS:**
- `#text`: Tamaño 64px, padding, line-height 1.5
- `.mirror`: Transform scaleX(-1)
- `#guide`: Línea horizontal central

---

### 3. Frontend: Control Remoto (remote.html)

**Responsabilidades:**
- Proporcionar interfaz de control
- Enviar comandos al servidor
- Mostrar estado actual

**Controles:**
```
┌─────────────────────────────┐
│    CONTROL REMOTO           │
├─────────────────────────────┤
│  Velocidad: [   ] +  -      │
│  [Pausa]  [Reanudar]        │
│  [Espejo] [Cámara]          │
│  [Limpiar] [Reset]          │
└─────────────────────────────┘
```

**Flujo de Envío:**
```
Usuario hace clic en botón
        ↓
Evento 'click'
        ↓
Construir mensaje JSON
        ↓
ws.send(mensaje)
        ↓
Servidor retransmite
        ↓
Teleprompter recibe y actualiza
```

**Estructura de Mensajes:**
```javascript
{
  type: 'speed',      // 'speed', 'pause', 'resume', 'mirror', 'camera'
  value: 1.5          // Valor (si aplica)
}
```

---

### 4. Progressive Web App (PWA)

#### Manifest.json
**Propósito:** Configuración de instalación

```json
{
  "name": "Teleprompter Remote Escuela",
  "short_name": "Teleprompter",
  "description": "Control remoto para telepromter",
  "start_url": "/",
  "display": "standalone",
  "icons": [...]
}
```

#### Service Worker (service-worker.js)
**Propósito:** Funcionalidad offline

```javascript
self.addEventListener('install', event => {
  // Caché de recursos estáticos
});

self.addEventListener('fetch', event => {
  // Servir desde caché si offline
});
```

---

## Flujo de Datos Completo

### Caso: Usuario aumenta velocidad desde control remoto

```
1. Usuario hace clic en "+ Velocidad" en remote.html
   │
2. Evento click → Calcular nueva velocidad
   │
3. Crear mensaje: { type: 'speed', value: 2.5 }
   │
4. ws.send(mensaje) → Enviar al servidor
   │
5. Servidor recibe mensaje en event 'message'
   │
6. Retransmitir a todos los clientes (broadcast)
   │
7. teleprompter.html event 'message' → Recibe mensaje
   │
8. Procesar: scrollSpeed = 2.5
   │
9. En requestAnimationFrame: scrollTop += scrollSpeed
   │
10. Texto se desplaza más rápido ✓
```

---

## Protocolos de Comunicación

### WebSocket

**Conexión:**
```javascript
const ws = new WebSocket('ws://localhost:3000');
```

**Estados:**
- `0` (CONNECTING): Conectando
- `1` (OPEN): Conectado
- `2` (CLOSING): Cerrando
- `3` (CLOSED): Cerrado

**Eventos:**
```javascript
ws.addEventListener('open', () => {});      // Conectado
ws.addEventListener('message', (evt) => {});// Mensaje recibido
ws.addEventListener('close', () => {});     // Desconectado
ws.addEventListener('error', (err) => {});  // Error
```

---

## Estructuras de Datos

### Mensaje de Control
```javascript
interface ControlMessage {
  type: 'speed' | 'pause' | 'resume' | 'mirror' | 'camera' | 'text';
  value?: number | string | boolean;
  timestamp?: number;
}
```

### Estado del Teleprompter
```javascript
interface TeleprompterState {
  scrollSpeed: number;        // 0.5 - 2.0
  isPaused: boolean;
  isMirror: boolean;
  isCamera: boolean;
  fontSize: number;           // px
  text: string;
  scrollPosition: number;     // px
}
```

---

## Diagramas UML

### Secuencia: Control de Velocidad

```
Remote          Server          Teleprompter
  │              │                   │
  ├─ click ─────►│                   │
  │              │                   │
  │              ├─ broadcast ──────►│
  │              │                   │
  │              │        update scrollSpeed
  │              │                   │
  │◄─ feedback ──┤◄─ state change ───┤
  │              │                   │
```

---

## Escalabilidad

### Mejoras Futuras

1. **Autenticación:**
   - Login para vincular control remoto con teleprompter
   - Prevenir acceso no autorizado

2. **Base de Datos:**
   - Guardar scripts
   - Historial de presentaciones
   - Perfiles de usuario

3. **Características Avanzadas:**
   - Múltiples usuarios simultáneamente
   - Chat entre control y pantalla
   - Timer/cronómetro
   - Indicador de tiempo restante

4. **Mejoras UI:**
   - Panel de estadísticas
   - Historial de comandos
   - Temas personalizados

---

## Performance

### Optimizaciones Implementadas

1. **requestAnimationFrame:** Para suave desplazamiento
2. **Minimizar reflows:** Usar transform en lugar de top/left
3. **Event delegation:** Manejo eficiente de eventos
4. **Service Worker:** Caché inteligente

### Consideraciones

- Máximo de ~100 clientes simultáneamente recomendado
- Latencia WebSocket típica: < 100ms
- Consumo de memoria: ~20MB por cliente

---

## Seguridad

### Consideraciones Actuales

⚠️ **Advertencia:** Para uso educativo/local solamente

- Sin autenticación actualmente
- Comunicación en WebSocket sin cifrar
- Acceso sin restricciones a la red local

### Recomendaciones para Producción

1. Usar WSS (WebSocket Secure)
2. Implementar autenticación JWT
3. Validar entrada de datos
4. Rate limiting
5. CORS configurado

---

## Deployment

### Desarrollo Local
```bash
npm install
npm start
# Acceder a http://localhost:3000
```

### Producción (Vercel/Railway)
```bash
git push origin main
# Auto-deploying...
# Acceder a https://teleprompter-escuela.app
```

---

## Archivos Clave

| Archivo | Líneas | Propósito |
|---------|--------|-----------|
| server.js | 15 | WebSocket server |
| teleprompter.html | 150+ | Pantalla principal |
| remote.html | 100+ | Control remoto |
| service-worker.js | 20+ | Funcionalidad offline |
| manifest.json | 20 | Configuración PWA |

---

**Última actualización:** 29 de enero de 2026
