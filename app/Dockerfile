FROM python:3.12-slim

WORKDIR /app

# Install dependencies first for better Docker layer caching
COPY requirements.txt ./

RUN pip install --no-cache-dir -r requirements.txt

# Create a non-root user
RUN useradd --create-home appuser

# Copy application code after dependencies
COPY app.py ./

# Give the non-root user ownership of the application directory
RUN chown -R appuser:appuser /app

USER appuser

EXPOSE 8080

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"]