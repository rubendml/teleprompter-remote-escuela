#!/bin/bash
# Script para acceso rápido a la documentación
# Guarda este script en la raíz del proyecto

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║     TELEPROMPTER REMOTE ESCUELA - CENTRO DE DOCUMENTACIÓN   ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Selecciona una opción:"
echo ""
echo "  [1] 📖 README.md                - Inicio rápido"
echo "  [2] 🏗️  ARQUITECTURA.md         - Visión técnica"
echo "  [3] 🎬 PRESENTACION.md          - Exposición del proyecto"
echo "  [4] 💻 DESARROLLO.md            - Manual del desarrollador"
echo "  [5] 📚 INDICE.md                - Centro de documentación"
echo "  [6] 📊 RESUMEN_TRABAJO.md       - Resumen completo"
echo ""
echo "  [7] 🚀 Iniciar servidor         - npm start"
echo "  [8] 📦 Instalar dependencias    - npm install"
echo "  [9] 🔄 Ver estado Git           - git status"
echo "  [0] ❌ Salir"
echo ""
read -p "Selecciona (0-9): " choice

case $choice in
  1)
    echo "Abriendo README.md..."
    code README.md
    ;;
  2)
    echo "Abriendo ARQUITECTURA.md..."
    code ARQUITECTURA.md
    ;;
  3)
    echo "Abriendo PRESENTACION.md..."
    code PRESENTACION.md
    ;;
  4)
    echo "Abriendo DESARROLLO.md..."
    code DESARROLLO.md
    ;;
  5)
    echo "Abriendo INDICE.md..."
    code INDICE.md
    ;;
  6)
    echo "Abriendo RESUMEN_TRABAJO.md..."
    code RESUMEN_TRABAJO.md
    ;;
  7)
    echo "Iniciando servidor..."
    npm start
    ;;
  8)
    echo "Instalando dependencias..."
    npm install
    ;;
  9)
    echo "Estado del repositorio:"
    git status
    ;;
  0)
    echo "¡Hasta luego!"
    exit 0
    ;;
  *)
    echo "Opción no válida"
    ;;
esac
