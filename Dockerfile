# Estágio de build (instala dependências)
FROM python:3.11-slim as builder

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# --- Estágio final (otimizado para produção) ---
FROM python:3.11-slim

# 1. Cria um usuário não-root (segurança)
RUN adduser --disabled-password --gecos "" appuser

# 2. Copia TUDO do builder (bibliotecas + binários)
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin/gunicorn /usr/local/bin/gunicorn

# 3. Configura o ambiente
WORKDIR /app
COPY app.py .

# 4. Ajusta permissões (evita erros de acesso)
RUN chown -R appuser:appuser /app
USER appuser

# 5. Usa a porta 8080 (padrão do Render)
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"]