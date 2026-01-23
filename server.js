const WebSocket = require("ws");
const PORT = process.env.PORT || 3000;

const wss = new WebSocket.Server({ port: PORT });

wss.on("connection", (ws) => {
  ws.on("message", (message) => {
    wss.clients.forEach(client => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(message.toString());
      }
    });
  });
});

console.log("🟢 WebSocket activo");
