from datetime import datetime
from fastapi import FastAPI
from fastapi.responses import JSONResponse
from sqlalchemy import text
from .database import engine

app = FastAPI(title="TabungKu API", version="0.1.0")

@app.get("/")
def beranda():
    return {"pesan": "Selamat datang di TabungKu API. Dokumentasi: /docs"}

@app.get("/health")
def health():
    """Memeriksa status API dan koneksi database MySQL."""
    waktu = datetime.now().isoformat(timespec="seconds")
    try:
        with engine.connect() as conn:
            versi = conn.execute(text("SELECT VERSION()")).scalar()
        return {
            "status": "ok",
            "waktu_server": waktu,
            "database": "ok",
            "mysql_version": versi,
        }
    except Exception as e:
        return JSONResponse(
            status_code=503,
            content={
                "status": "degraded",
                "waktu_server": waktu,
                "database": "error",
                "detail": str(e),
            },
        )