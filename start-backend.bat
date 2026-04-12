@echo off
cd /d "%~dp0backend"
echo Starting Freight Optimizer API on http://localhost:8000
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
pause
