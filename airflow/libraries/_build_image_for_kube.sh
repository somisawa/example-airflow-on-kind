function build_image_for_kube::build_image_for_kubernetes() {
    cd "${AIRFLOW_SOURCES}" || exit 1
    local image_tag="latest"
    if [[ -n ${GITHUB_REGISTRY_PULL_IMAGE_TAG=} ]]; then
        image_tag="${GITHUB_REGISTRY_PULL_IMAGE_TAG}"
    fi
    echo "Building ${AIRFLOW_IMAGE_KUBERNETES}:latest from ${AIRFLOW_PROD_IMAGE}:${image_tag}"
    cd "${SCRIPT_DIR}"
    docker_v build --tag "${AIRFLOW_IMAGE_KUBERNETES}:latest" . -f - << EOF
FROM ${AIRFLOW_PROD_IMAGE}:${image_tag}

COPY airflow/dags/ \${AIRFLOW_HOME}/dags/

COPY airflow.cfg \${AIRFLOW_HOME}/

COPY airflow/kubernetes_executor/ \${AIRFLOW_HOME}/pod_templates/

COPY ./ \${AIRFLOW_HOME}/app/

ENV GUNICORN_CMD_ARGS='--preload' AIRFLOW__WEBSERVER__WORKER_REFRESH_INTERVAL=0

EOF
    echo "The ${AIRFLOW_IMAGE_KUBERNETES}:${image_tag} is prepared for test kubernetes deployment."
    cd "${AIRFLOW_SOURCES}"
}
