# --- ETAPE 1 : LA CUISINE (Builder) ---
FROM python:3.10-slim AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y build-essential

COPY requirements.txt .

RUN pip install --user --no-cache-dir -r requirements.txt

# --- ETAPE 2 : LA VITRINE (Production) ---
FROM python:3.10-slim

WORKDIR /app

RUN useradd -m appuser

COPY --from=builder /root/.local /home/appuser/.local

COPY app.py .

RUN chown -R appuser:appuser /app

USER appuser

ENV PATH=/home/appuser/.local/bin:$PATH

EXPOSE 5000

CMD ["python", "app.py"]
