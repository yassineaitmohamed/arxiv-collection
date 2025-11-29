#!/bin/bash
# Test local script - Lance un serveur web local pour tester
# By Yassine Ait Mohamed

PORT=8000

echo "=================================="
echo "🚀 arXiv Collection Pro - Local Test"
echo "=================================="
echo ""
echo "Starting local web server on port $PORT..."
echo ""
echo "Open your browser and visit:"
echo "👉 http://localhost:$PORT"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""
echo "=================================="
echo ""

# Try to open browser automatically
if command -v xdg-open > /dev/null; then
    xdg-open "http://localhost:$PORT" &
elif command -v open > /dev/null; then
    open "http://localhost:$PORT" &
fi

# Start Python HTTP server
python3 -m http.server $PORT
