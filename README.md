## Installation
### 0.1 build for base image
At first time, 
```bash
docker build --build-arg GIT_ACCESS_TOKEN=hoge -t blood:latest .
```

### 1.1 Clone Apach Airflow
Clone airflow repo and set the location as follows.
```bash
export AIRFLOW_DIR=/path/to/airflow
```

### 1.2 deploy
```bash
cd airflow/kind
./kind_deploy.sh
kind get kubeconfig --name <cluster name> > ~/.kube/config
```