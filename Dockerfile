FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Dentro del contenedor la app tiene que escuchar en todas las interfaces para que
# el proxy de Coolify llegue a ella. La app NO tiene login: protege el acceso desde
# Coolify (basic auth) y sirve siempre por HTTPS.
ENV PATRIMONIO_HOST=0.0.0.0 \
    PATRIMONIO_PUERTO=8765 \
    PATRIMONIO_DATOS=/data \
    PATRIMONIO_NO_ABRIR=1

# Monta aquí un volumen persistente: contiene cartera.json y las copias de seguridad.
VOLUME /data
EXPOSE 8765

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
  CMD python -c "import urllib.request,sys; sys.exit(0 if urllib.request.urlopen('http://127.0.0.1:8765/api/ping', timeout=4).status==200 else 1)"

CMD ["python", "-m", "app"]
