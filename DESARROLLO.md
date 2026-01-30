# Guía de Desarrollo - Teleprompter Remote Escuela

**Manual técnico para desarrolladores y contribuidores**

---

## 🏁 Inicio Rápido

### Setup Inicial

```bash
# 1. Clonar repositorio
git clone https://github.com/rubendml/teleprompter-remote-escuela.git
cd teleprompter-remote-escuela

# 2. Instalar dependencias
npm install

# 3. Iniciar servidor de desarrollo
npm start

# 4. Abrir en navegador
# Terminal 1: Teleprompter
http://localhost:3000/teleprompter.html

# Terminal 2: Control Remoto
http://localhost:3000/remote.html
```

---

## 📁 Estructura del Código

```
teleprompter-remote-escuela/
│
├── server.js                    # Servidor WebSocket principal
│   ├── Escucha en puerto 3000
│   ├── Maneja conexiones de clientes
│   └── Retransmite mensajes (broadcast)
│
├── teleprompter.html            # Pantalla principal
│   ├── <head>: Meta, CSS
│   ├── <body>: Container, textarea, text, guide
│   └── <script>: Lógica de desplazamiento, WebSocket
│
├── remote.html                  # Control remoto
│   ├── <head>: Meta, CSS
│   ├── <body>: Controles, botones, sliders
│   └── <script>: Manejadores de eventos, envío de comandos
│
├── service-worker.js            # Worker offline
│   ├── Cache de recursos
│   └── Soporte offline
│
├── manifest.json                # Configuración PWA
│   ├── Metadata de la app
│   └── Iconos y display
│
├── package.json                 # Dependencias
│   └── ws: ^8.15.0
│
└── Imágenes
    ├── icon-192.png
    ├── icon-512.png
    └── logo-escuela.svg
```

---

## 🔧 Variables Globales Clave

### teleprompter.html

```javascript
// Estado del teleprompter
let scrollSpeed = 2;              // Píxeles por frame
let isPaused = false;             // ¿Pausado?
let isMirror = false;             // ¿Modo espejo?
let isCamera = false;             // ¿Modo cámara?
let fontSize = 64;                // Tamaño de fuente (px)
let scrollOffset = 0;             // Posición de scroll actual

// Elementos DOM
const container = document.getElementById('container');
const textElement = document.getElementById('text');
const textInput = document.querySelector('textarea');
const guideElement = document.getElementById('guide');
const speedInput = document.querySelector('input[type="number"]');

// WebSocket
let ws = null;
```

### remote.html

```javascript
// Estado del control
let currentSpeed = 1;             // Velocidad relativa (0.5-2.0)
let connected = false;            // ¿Conectado?
let lastMessageTime = 0;          // Timestamp último mensaje

// Elementos DOM
const speedSlider = document.getElementById('speedSlider');
const pauseBtn = document.getElementById('pauseBtn');
const playBtn = document.getElementById('playBtn');

// WebSocket
let ws = null;
```

---

## 📡 Protocolo WebSocket

### Estructura de Mensajes

```javascript
interface Message {
  type: string;           // Tipo de comando
  value?: any;            // Valor asociado
  timestamp?: number;     // Timestamp opcional
  clientId?: string;      // ID del cliente (futuro)
}
```

### Tipos de Mensajes

```javascript
// Velocidad
{
  type: 'speed',
  value: 1.5              // Factor: 0.5 (lento) a 2.0 (rápido)
}

// Pausa
{
  type: 'pause'
}

// Reanudar
{
  type: 'resume'
}

// Modo Espejo
{
  type: 'mirror',
  value: true
}

// Modo Cámara
{
  type: 'camera',
  value: true
}

// Limpiar/Reset
{
  type: 'reset'
}
```

---

## 🎨 Lógica de Desplazamiento

### Algoritmo Base

```javascript
// En requestAnimationFrame
function animate() {
  if (!isPaused) {
    // Aumentar posición de scroll
    textElement.scrollTop += scrollSpeed;
    
    // Opcional: Resetear al final
    if (textElement.scrollTop >= textElement.scrollHeight) {
      textElement.scrollTop = 0;  // O mostrar mensaje
    }
  }
  
  requestAnimationFrame(animate);
}
```

### Manejador de Mensajes

```javascript
ws.addEventListener('message', (event) => {
  try {
    const message = JSON.parse(event.data);
    
    switch(message.type) {
      case 'speed':
        scrollSpeed = message.value;
        updateSpeedDisplay(message.value);
        break;
        
      case 'pause':
        isPaused = true;
        updateUI('paused');
        break;
        
      case 'resume':
        isPaused = false;
        updateUI('playing');
        break;
        
      case 'mirror':
        toggleMirror(message.value);
        break;
        
      case 'camera':
        toggleCamera(message.value);
        break;
        
      case 'reset':
        resetTeleprompter();
        break;
    }
  } catch(err) {
    console.error('Error parsing message:', err);
  }
});
```

---

## ⌨️ Atajos de Teclado

### teleprompter.html

```javascript
document.addEventListener('keydown', (e) => {
  switch(e.code) {
    case 'Space':
      e.preventDefault();
      isPaused = !isPaused;
      break;
      
    case 'ArrowUp':
      scrollSpeed = Math.max(0.5, scrollSpeed - 0.1);
      break;
      
    case 'ArrowDown':
      scrollSpeed = Math.min(2.0, scrollSpeed + 0.1);
      break;
      
    case 'KeyM':
      if (e.ctrlKey) toggleMirror();
      break;
      
    case 'KeyC':
      if (e.ctrlKey) toggleCamera();
      break;
  }
});
```

---

## 🎯 Funciones Principales

### teleprompter.html

```javascript
// Inicializar WebSocket
function initWebSocket() {
  const protocol = window.location.protocol === 'https:' ? 'wss' : 'ws';
  const wsUrl = `${protocol}://${window.location.host}`;
  ws = new WebSocket(wsUrl);
  
  ws.addEventListener('open', () => {
    console.log('✅ Conectado al servidor');
  });
  
  ws.addEventListener('message', handleMessage);
  
  ws.addEventListener('close', () => {
    console.warn('⚠️ Desconectado. Reintentando...');
    setTimeout(initWebSocket, 3000);  // Reconectar
  });
}

// Alternar modo espejo
function toggleMirror(value) {
  isMirror = value !== undefined ? value : !isMirror;
  textElement.classList.toggle('mirror', isMirror);
  localStorage.setItem('mirror', isMirror);
}

// Alternar modo cámara
function toggleCamera(value) {
  isCamera = value !== undefined ? value : !isCamera;
  container.classList.toggle('camera', isCamera);
  localStorage.setItem('camera', isCamera);
}

// Resetear a posición inicial
function resetTeleprompter() {
  textElement.scrollTop = 0;
  isPaused = false;
}

// Actualizar pantalla con el texto del textarea
function updateTextDisplay() {
  const text = textInput.value;
  textElement.textContent = text;
  localStorage.setItem('teleprompter-text', text);
}

// Cambiar tamaño de fuente
function setFontSize(size) {
  fontSize = size;
  textElement.style.fontSize = `${size}px`;
  localStorage.setItem('font-size', size);
}
```

### remote.html

```javascript
// Enviar comando al servidor
function sendCommand(type, value) {
  if (!ws || ws.readyState !== WebSocket.OPEN) {
    console.warn('No conectado al servidor');
    return;
  }
  
  const message = {
    type: type,
    value: value,
    timestamp: Date.now()
  };
  
  ws.send(JSON.stringify(message));
}

// Manejador de botón de pausa
document.getElementById('pauseBtn').addEventListener('click', () => {
  sendCommand('pause');
});

// Manejador de botón de play
document.getElementById('playBtn').addEventListener('click', () => {
  sendCommand('resume');
});

// Manejador de slider de velocidad
document.getElementById('speedSlider').addEventListener('input', (e) => {
  const speed = parseFloat(e.target.value);
  sendCommand('speed', speed);
  document.getElementById('speedValue').textContent = speed.toFixed(1) + 'x';
});

// Conectar al servidor
function initRemoteControl() {
  const protocol = window.location.protocol === 'https:' ? 'wss' : 'ws';
  const wsUrl = `${protocol}://${window.location.host}`;
  ws = new WebSocket(wsUrl);
  
  ws.addEventListener('open', () => {
    connected = true;
    updateConnectionStatus('Conectado');
  });
  
  ws.addEventListener('close', () => {
    connected = false;
    updateConnectionStatus('Desconectado');
  });
}
```

---

## 🗄️ Almacenamiento Local

### localStorage

```javascript
// Guardar estado del usuario
localStorage.setItem('teleprompter-text', textContent);
localStorage.setItem('font-size', fontSize);
localStorage.setItem('mirror', isMirror);
localStorage.setItem('camera', isCamera);
localStorage.setItem('last-speed', scrollSpeed);

// Recuperar al cargar
window.addEventListener('load', () => {
  const savedText = localStorage.getItem('teleprompter-text');
  const savedFontSize = localStorage.getItem('font-size');
  
  if (savedText) textInput.value = savedText;
  if (savedFontSize) setFontSize(parseInt(savedFontSize));
});
```

---

## 🔌 Server.js Detallado

```javascript
const WebSocket = require("ws");
const PORT = process.env.PORT || 3000;

// Crear servidor WebSocket
const wss = new WebSocket.Server({ port: PORT });

console.log(`🟢 WebSocket activo en puerto ${PORT}`);

// Manejar nuevas conexiones
wss.on("connection", (ws) => {
  console.log(`📱 Cliente conectado (total: ${wss.clients.size})`);
  
  // Manejar mensajes entrantes
  ws.on("message", (message) => {
    console.log(`📨 Mensaje recibido: ${message}`);
    
    // Broadcast a todos los clientes conectados
    wss.clients.forEach(client => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(message.toString());
      }
    });
  });
  
  // Manejar desconexión
  ws.on("close", () => {
    console.log(`📵 Cliente desconectado (total: ${wss.clients.size})`);
  });
  
  // Manejar errores
  ws.on("error", (error) => {
    console.error(`❌ Error WebSocket: ${error}`);
  });
});
```

---

## 🐛 Debugging

### Consola del Navegador

```javascript
// Ver logs de WebSocket
ws.addEventListener('open', () => {
  console.log('%c✅ Conectado', 'color: green; font-weight: bold;');
});

// Registrar mensajes
ws.addEventListener('message', (event) => {
  console.log('%c📨 Mensaje:', 'color: blue;', event.data);
});

// Monitorear estado
setInterval(() => {
  console.log('Estado:', {
    connected: ws && ws.readyState === WebSocket.OPEN,
    scrollSpeed: scrollSpeed,
    isPaused: isPaused,
    scrollPosition: textElement.scrollTop
  });
}, 5000);
```

### En el Servidor

```bash
# Ver logs de Node.js
node server.js

# Con nodemon para reload automático
npx nodemon server.js
```

---

## 📦 Dependencias

### package.json

```json
{
  "name": "teleprompter-ws",
  "version": "1.0.0",
  "description": "WebSocket server para teleprompter",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js",
    "test": "echo \"Error: no test specified\""
  },
  "dependencies": {
    "ws": "^8.15.0"
  },
  "devDependencies": {
    "nodemon": "^3.0.0"
  }
}
```

---

## 🔒 Seguridad

### Validación de Entrada

```javascript
function validateMessage(message) {
  // Verificar que sea un objeto válido
  if (typeof message !== 'object') return false;
  
  // Verificar tipo válido
  const validTypes = ['speed', 'pause', 'resume', 'mirror', 'camera', 'reset'];
  if (!validTypes.includes(message.type)) return false;
  
  // Validar valor si existe
  if (message.value !== undefined) {
    if (message.type === 'speed') {
      // Speed debe estar entre 0.5 y 2.0
      return typeof message.value === 'number' && 
             message.value >= 0.5 && 
             message.value <= 2.0;
    }
  }
  
  return true;
}
```

### Rate Limiting

```javascript
const messageFrequency = new Map();
const MAX_MESSAGES_PER_SECOND = 10;

wss.on('connection', (ws) => {
  const clientId = generateClientId();
  
  ws.on('message', (message) => {
    const now = Date.now();
    const messages = messageFrequency.get(clientId) || [];
    const recentMessages = messages.filter(t => now - t < 1000);
    
    if (recentMessages.length >= MAX_MESSAGES_PER_SECOND) {
      console.warn('Rate limit exceeded for', clientId);
      return;
    }
    
    recentMessages.push(now);
    messageFrequency.set(clientId, recentMessages);
    
    // Procesar mensaje
    handleMessage(message);
  });
});
```

---

## ✅ Testing

### Test Manual

```javascript
// 1. Verificar conexión
const ws = new WebSocket('ws://localhost:3000');
ws.onopen = () => console.log('Conectado');

// 2. Enviar mensaje de prueba
ws.send(JSON.stringify({type: 'speed', value: 1.5}));

// 3. Verificar recepción
ws.onmessage = (event) => {
  console.log('Recibido:', event.data);
};
```

### Test Automático (Futuro)

```javascript
// Propuesto: usar Jest + ws
const WebSocket = require('ws');

describe('Teleprompter WebSocket', () => {
  test('Debe conectar correctamente', (done) => {
    const ws = new WebSocket('ws://localhost:3000');
    ws.on('open', () => {
      expect(ws.readyState).toBe(WebSocket.OPEN);
      ws.close();
      done();
    });
  });
});
```

---

## 📊 Performance

### Optimizaciones Implementadas

```javascript
// 1. requestAnimationFrame en lugar de setInterval
requestAnimationFrame(animate);  // ✅ 60fps suave

// 2. Usar CSS transforms en lugar de modificar top/left
textElement.style.transform = 'translateY(0)';  // Hardware accelerated

// 3. Delegar eventos
document.addEventListener('click', (e) => {
  if (e.target.matches('.button')) {
    handleButtonClick(e.target);
  }
});

// 4. Debounce para eventos frecuentes
function debounce(fn, delay) {
  let timeoutId;
  return function(...args) {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => fn(...args), delay);
  };
}

const debouncedScroll = debounce(() => {
  updateScrollIndicator();
}, 100);
```

---

## 🚀 Compilación y Deploy

### Vercel

```bash
# 1. Instalar Vercel CLI
npm i -g vercel

# 2. Configurar (una sola vez)
vercel

# 3. Deploy
vercel --prod
```

### Railway

```bash
# 1. Instalar Railway CLI
npm i -g @railway/cli

# 2. Conectar proyecto
railway link

# 3. Deploy
railway up
```

---

## 📝 Contribuir

### Workflow

1. Fork el repositorio
2. Crear rama: `git checkout -b feature/nombre`
3. Hacer cambios
4. Commit: `git commit -m 'Agregar feature'`
5. Push: `git push origin feature/nombre`
6. PR: Abrir Pull Request

### Estilo de Código

```javascript
// ✅ BIEN: camelCase, descriptivo
function handleSpeedChange(newSpeed) {
  scrollSpeed = newSpeed;
}

// ❌ MAL: nombres cortos, poco claro
function hSC(s) {
  ss = s;
}
```

---

**Última actualización:** 29 de enero de 2026
