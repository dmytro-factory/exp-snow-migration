FROM python:3.11-slim

WORKDIR /app

COPY 04-dashboard-migration/requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY 04-dashboard-migration/streamlit_app.py ./streamlit_app.py

EXPOSE 3201

CMD ["streamlit", "run", "streamlit_app.py", "--server.address", "0.0.0.0", "--server.port", "3201", "--server.headless", "true"]
