# Use lightweight Python image
FROM python:3.9-slim

# Set work directory
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . /app

# Expose port
EXPOSE 10000

# Run the app
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "10000"]
