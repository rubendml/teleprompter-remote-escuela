# Teleprompter Remote Escuela

**Aplicación web progresiva (PWA) para telepronter remoto en entornos educativos**

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Node.js](https://img.shields.io/badge/node.js-14%2B-brightgreen)

## 📋 Descripción

Teleprompter Remote Escuela es una aplicación web moderna que permite:

- 📱 **Control remoto**: Controlar el flujo de texto desde un dispositivo móvil
- 🎥 **Modo cámara**: Optimizado para presentaciones y grabaciones de video
- 🪞 **Modo espejo**: Visualización invertida para reflejos en espejos
- 📡 **Sincronización en tiempo real**: Comunicación WebSocket entre dispositivos
- 🌐 **Progressive Web App**: Funciona offline y es instalable
- 🎨 **Interfaz limpia**: Diseñada para usar con ropa oscura

## 🚀 Características Principales

### 1. Pantalla Principal (Teleprompter)
- Texto de gran tamaño (64px) para legibilidad a distancia
- Fondo negro con texto claro para reducir fatiga ocular
- Línea guía central para mantener posición correcta
- Soporte para velocidad de desplazamiento ajustable
- Espejo integrado (efecto scaleX)

### 2. Control Remoto
- Interfaz intuitiva de controles
- Conexión WebSocket en tiempo real
- Control de velocidad de desplazamiento
- Botones para pausar/reanudar

### 3. Progressive Web App
- Instalable en cualquier dispositivo
- Funciona sin conexión a internet
- Service Worker para caché automático

## 📁 Estructura del Proyecto

```
teleprompter-remote-escuela/
├── server.js              # Servidor WebSocket (Node.js)
├── package.json           # Dependencias del proyecto
├── teleprompter.html      # Pantalla principal del telepromter
├── remote.html            # Panel de control remoto
├── manifest.json          # Configuración PWA
├── service-worker.js      # Service Worker para funcionalidad offline
├── logo-escuela.svg       # Logo de la aplicación
├── icon-192.png           # Icono PWA (192x192)
├── icon-512.png           # Icono PWA (512x512)
└── README.md             # Este archivo
```

## 🔧 Tecnologías Utilizadas

- **Backend**: Node.js + WebSocket (`ws`)
- **Frontend**: HTML5, CSS3, JavaScript Vanilla
- **Comunicación**: WebSocket para sincronización en tiempo real
- **PWA**: Service Worker, Manifest.json

## 📦 Instalación

### Requisitos Previos
- Node.js v14 o superior
- npm o yarn
- Navegador moderno (Chrome, Firefox, Safari, Edge)

### Pasos de Instalación

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/rubendml/teleprompter-remote-escuela.git
   cd teleprompter-remote-escuela
   ```

2. **Instalar dependencias**
   ```bash
   npm install
   ```

3. **Iniciar el servidor WebSocket**
   ```bash
   npm start
   ```
   El servidor estará disponible en `http://localhost:3000`

## 🎯 Uso

### Acceso a la Aplicación

1. **Desde la computadora (Pantalla del Teleprompter)**
   - Abre `http://localhost:3000/teleprompter.html` en un navegador
   - Esta será la pantalla visible que el presentador leerá

2. **Desde el dispositivo móvil (Control Remoto)**
   - Abre `http://localhost:3000/remote.html` en otro navegador/dispositivo
   - Usa los controles para ajustar el flujo del texto

### Flujo de Operación

1. **Prepare el texto**: Pegue el texto en la pantalla del teleprompter
2. **Inicie la presentación**: Presione el botón de inicio en el control remoto
3. **Ajuste la velocidad**: Use el control remoto para aumentar/disminuir velocidad
4. **Pausa si es necesario**: El botón de pausa congela el desplazamiento

## ⌨️ Controles y Atajos

### En la Pantalla Principal
- **Barra espaciadora**: Pausa/Reanuda
- **Flecha arriba**: Disminuir velocidad
- **Flecha abajo**: Aumentar velocidad
- **Ctrl + M**: Activar modo espejo
- **Ctrl + C**: Modo cámara

### En el Control Remoto
- **Botones de velocidad**: Ajustar velocidad de desplazamiento
- **Pausa/Reanudar**: Control de flujo
- **Reset**: Volver al principio

## 🎨 Características de Diseño

### Color y Contraste
- Fondo negro para no distraer
- Texto blanco (RGB: 245, 245, 245) para máximo contraste
- Línea guía en blanco con transparencia para referencia

### Tipografía
- Fuente: Arial/Helvetica para legibilidad
- Tamaño: 64px para lectura confortable a distancia
- Alto entre líneas: 1.5 para separación clara

### Modos Especiales
- **Modo Espejo**: Invierte horizontalmente el texto (útil con espejos)
- **Modo Cámara**: Optimizado para grabaciones de video

## 🔌 API WebSocket

### Conexión
```javascript
const ws = new WebSocket('ws://localhost:3000');
```

### Mensajes

**Enviar comando de velocidad:**
```javascript
ws.send(JSON.stringify({
  type: 'speed',
  value: 1.0  // Rango: 0.5 a 2.0
}));
```

**Enviar comando de pausa:**
```javascript
ws.send(JSON.stringify({
  type: 'pause'
}));
```

**Enviar comando de reanudación:**
```javascript
ws.send(JSON.stringify({
  type: 'resume'
}));
```

## 🚀 Despliegue

### Opción 1: Vercel (Recomendado)
```bash
npm install -g vercel
vercel
```

### Opción 2: Heroku
```bash
heroku create nombre-app
git push heroku main
```

### Opción 3: Railway, Render u otro servicio
Cualquier plataforma que soporte Node.js funcionará.

## 🐛 Troubleshooting

### El control remoto no se conecta
- Verificar que el servidor WebSocket esté corriendo
- Confirmar que ambos dispositivos estén en la misma red
- Revisar la consola del navegador para errores

### El texto desaparece después de desplazar
- Limpiar el caché del navegador
- Actualizar la página (Ctrl+R)
- Verificar que el JavaScript esté habilitado

### PWA no se instala
- Usar HTTPS en producción (requerido para PWA)
- Asegurar que manifest.json sea accesible
- Esperar a que el navegador muestre el prompt de instalación

## 📱 Instalación como PWA

### Chrome/Edge/Brave
1. Abre la aplicación en el navegador
2. Haz clic en el icono de instalación (esquina superior derecha)
3. Selecciona "Instalar"

### iOS Safari
1. Abre la aplicación
2. Toca el icono de compartir
3. Selecciona "Añadir a pantalla de inicio"

## 🤝 Contribuir

Las contribuciones son bienvenidas. Para cambios importantes:

1. Fork el repositorio
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver [LICENSE](LICENSE) para más detalles.

## ✨ Casos de Uso

- 📚 Presentaciones educativas
- 🎥 Grabación de video educativo
- 🎤 Discursos y conferencias
- 📺 Transmisiones en vivo
- 🎬 Producción de contenido

## 🔗 Enlaces Útiles

- [GitHub](https://github.com/rubendml/teleprompter-remote-escuela)
- [WebSocket API](https://developer.mozilla.org/es/docs/Web/API/WebSocket)
- [Progressive Web Apps](https://developer.mozilla.org/es/docs/Web/Progressive_web_apps)

## 📞 Soporte

Para reportar problemas o sugerencias, abre un [issue en GitHub](https://github.com/rubendml/teleprompter-remote-escuela/issues).

---

**Desarrollado con ❤️ para el entorno educativo**
