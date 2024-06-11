FROM apache/airflow:2.8.1

COPY requirements.txt .

RUN pip install --proxy http://thegate.bog.ge:8080 --trusted-host pypi.python.org --trusted-host pypi.org --trusted-host files.pythonhosted.org  -r requirements.txt
