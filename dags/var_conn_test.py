from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.models import Variable, Connection
from airflow.utils.dates import days_ago

# Define the default arguments
default_args = {
    'owner': 'airflow',
    'start_date': days_ago(1)
}

# Define the DAG
dag = DAG(
    'print_variable_and_connections',
    default_args=default_args,
    description='A simple DAG to print variable and connections',
    schedule_interval=None,
)

# Define the task to print the variable
def print_variable():
    sample_var = Variable.get("sample_var")
    print(f"Variable 'sample_var': {sample_var}")

# Define the task to print the connections
def print_connections():
    conn_uri_example = Connection.get_connection_from_secrets("conn_uri_example")
    full_conn_example = Connection.get_connection_from_secrets("full_conn_example")

    print(f"Connection 'conn_uri_example': {conn_uri_example.get_uri()}")
    print(f"Connection 'full_conn_example': {full_conn_example.get_uri()}")

# Create the PythonOperator tasks
print_variable_task = PythonOperator(
    task_id='print_variable_task',
    python_callable=print_variable,
    dag=dag,
)

print_connections_task = PythonOperator(
    task_id='print_connections_task',
    python_callable=print_connections,
    dag=dag,
)

# Set the task dependencies
print_variable_task >> print_connections_task
