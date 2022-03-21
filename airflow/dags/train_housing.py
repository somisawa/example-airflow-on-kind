import logging
import os

from datetime import datetime

import pendulum

from airflow import DAG
from airflow.configuration import conf
from airflow.decorators import dag, task
from airflow.example_dags.libs.helper import print_stuff


worker_container_repository = conf.get(
    'kubernetes', 'worker_container_repository')
worker_container_tag = conf.get('kubernetes', 'worker_container_tag')

try:
    from kubernetes.client import models as k8s
except ImportError:
    log.warning(
        "The example_kubernetes_executor example DAG requires the kubernetes provider."
        " Please install it with: pip install apache-airflow[cncf.kubernetes]"
    )
    k8s = None

if k8s:
    @dag(schedule_interval='@once', start_date=datetime(2021, 12, 1), catchup=False)
    def taskflow():

        @task(task_id='prepare')
        def prepare_data():
            import sys
            sys.path.append("/opt/airflow/app")
            from housing import data_prepare, preprocessing, train

            data = data_prepare(0.33)
            return data

        @task(task_id='preprocess')
        def process_data(data):
            import sys
            sys.path.append("/opt/airflow/app")
            from housing import data_prepare, preprocessing, train

            Xs = preprocessing(*data[:2])
            return Xs + data[2:]

        @task(task_id='train')
        def training(data):
            import sys
            sys.path.append("/opt/airflow/app")
            from housing import data_prepare, preprocessing, train

            train(data, "./app/experiments/sample", "./app/results/sample")

        training(process_data(prepare_data()))

dag = taskflow()
