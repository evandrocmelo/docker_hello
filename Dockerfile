FROM python:3.11-slim as builder

# Definir diretório de trabalho
WORKDIR /app

# Copiar apenas os arquivos de requisitos primeiro para aproveitar o cache de camadas
COPY requirements.txt .

# Instalar dependências em uma camada separada
RUN pip install --no-cache-dir -r requirements.txt

# Segunda etapa - imagem final
FROM python:3.11-slim

# Criar usuário não-root para executar a aplicação
RUN adduser --disabled-password --gecos "" appuser

# Definir diretório de trabalho
WORKDIR /app

# Copiar dependências da etapa de construção
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages

# Copiar o código da aplicação
COPY app.py .

# Definir propriedade dos arquivos para o usuário não-root
RUN chown -R appuser:appuser /app && \
    chmod -R 755 /app

# Mudar para o usuário não-root
USER appuser

# Definir variáveis de ambiente
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV FLASK_APP=app.py
ENV FLASK_ENV=production
ENV PORT=5000

# Expor a porta que a aplicação utilizará
EXPOSE $PORT

# Comando para iniciar a aplicação com Gunicorn (para produção)
CMD gunicorn --bind 0.0.0.0:$PORT app:app