function build_prod::build_prod_images() {
    build_images::check_if_buildx_plugin_available
    build_images::print_build_info

    if [[ ${SKIP_BUILDING_PROD_IMAGE} == "true" ]]; then
        echo
        echo "${COLOR_YELLOW}Skip building production image. Assume the one we have is good!${COLOR_RESET}"
        echo "${COLOR_YELLOW}You must run './breeze build-image --production-image before for all python versions!${COLOR_RESET}"
        echo
        return
    fi
    local docker_prod_directive
    if [[ "${DOCKER_CACHE}" == "disabled" ]]; then
        docker_prod_directive=("--no-cache")
    elif [[ "${DOCKER_CACHE}" == "local" ]]; then
        docker_prod_directive=()
    elif [[ "${DOCKER_CACHE}" == "pulled" ]]; then
        docker_prod_directive=(
            "--cache-from=${AIRFLOW_PROD_IMAGE}:cache"
        )
    else
        echo
        echo  "${COLOR_RED}ERROR: The ${DOCKER_CACHE} cache is unknown  ${COLOR_RESET}"
        echo
        echo
        exit 1
    fi
    if [[ ${PREPARE_BUILDX_CACHE} == "true" ]]; then
        # we need to login to docker registry so that we can push cache there
        build_images::login_to_docker_registry
        # Cache for prod image contains also build stage for buildx when mode=max specified!
        docker_prod_directive+=(
            "--cache-to=type=registry,ref=${AIRFLOW_PROD_IMAGE}:cache,mode=max"
            "--push"
        )
        if [[ ${PLATFORM} =~ .*,.* ]]; then
            echo
            echo "Skip loading docker image on multi-platform build"
            echo
        else
            docker_prod_directive+=(
                "--load"
            )
        fi
    fi
    set +u
    local additional_dev_args=()
    if [[ -n "${DEV_APT_DEPS}" ]]; then
        additional_dev_args+=("--build-arg" "DEV_APT_DEPS=\"${DEV_APT_DEPS}\"")
    fi
    if [[ -n "${DEV_APT_COMMAND}" ]]; then
        additional_dev_args+=("--build-arg" "DEV_APT_COMMAND=\"${DEV_APT_COMMAND}\"")
    fi
    local additional_runtime_args=()
    if [[ -n "${RUNTIME_APT_DEPS}" ]]; then
        additional_runtime_args+=("--build-arg" "RUNTIME_APT_DEPS=\"${RUNTIME_APT_DEPS}\"")
    fi
    if [[ -n "${RUNTIME_APT_COMMAND}" ]]; then
        additional_runtime_args+=("--build-arg" "RUNTIME_APT_COMMAND=\"${RUNTIME_APT_COMMAND}\"")
    fi
    echo "${SCRIPT_DIR}"
    docker_v "${BUILD_COMMAND[@]}" \
        "${EXTRA_DOCKER_PROD_BUILD_FLAGS[@]}" \
        --pull \
        --platform "${PLATFORM}" \
        --build-arg PYTHON_BASE_IMAGE="${PYTHON_BASE_IMAGE}" \
        --build-arg INSTALL_MYSQL_CLIENT="${INSTALL_MYSQL_CLIENT}" \
        --build-arg INSTALL_MSSQL_CLIENT="${INSTALL_MSSQL_CLIENT}" \
        --build-arg INSTALL_POSTGRES_CLIENT="${INSTALL_POSTGRES_CLIENT}" \
        --build-arg ADDITIONAL_AIRFLOW_EXTRAS="${ADDITIONAL_AIRFLOW_EXTRAS}" \
        --build-arg ADDITIONAL_PYTHON_DEPS="${ADDITIONAL_PYTHON_DEPS}" \
        --build-arg INSTALL_PROVIDERS_FROM_SOURCES="${INSTALL_PROVIDERS_FROM_SOURCES}" \
        --build-arg ADDITIONAL_DEV_APT_COMMAND="${ADDITIONAL_DEV_APT_COMMAND}" \
        --build-arg ADDITIONAL_DEV_APT_DEPS="${ADDITIONAL_DEV_APT_DEPS}" \
        --build-arg ADDITIONAL_DEV_APT_ENV="${ADDITIONAL_DEV_APT_ENV}" \
        --build-arg ADDITIONAL_RUNTIME_APT_COMMAND="${ADDITIONAL_RUNTIME_APT_COMMAND}" \
        --build-arg ADDITIONAL_RUNTIME_APT_DEPS="${ADDITIONAL_RUNTIME_APT_DEPS}" \
        --build-arg ADDITIONAL_RUNTIME_APT_ENV="${ADDITIONAL_RUNTIME_APT_ENV}" \
        --build-arg AIRFLOW_PRE_CACHED_PIP_PACKAGES="${AIRFLOW_PRE_CACHED_PIP_PACKAGES}" \
        --build-arg INSTALL_FROM_PYPI="${INSTALL_FROM_PYPI}" \
        --build-arg INSTALL_FROM_DOCKER_CONTEXT_FILES="${INSTALL_FROM_DOCKER_CONTEXT_FILES}" \
        --build-arg UPGRADE_TO_NEWER_DEPENDENCIES="${UPGRADE_TO_NEWER_DEPENDENCIES}" \
        --build-arg AIRFLOW_VERSION="${AIRFLOW_VERSION}" \
        --build-arg AIRFLOW_BRANCH="${AIRFLOW_BRANCH_FOR_PYPI_PRELOADING}" \
        --build-arg AIRFLOW_EXTRAS="${AIRFLOW_EXTRAS}" \
        --build-arg BUILD_ID="${CI_BUILD_ID}" \
        --build-arg COMMIT_SHA="${COMMIT_SHA}" \
        --build-arg CONSTRAINTS_GITHUB_REPOSITORY="${CONSTRAINTS_GITHUB_REPOSITORY}" \
        --build-arg AIRFLOW_CONSTRAINTS="${AIRFLOW_CONSTRAINTS}" \
        --build-arg AIRFLOW_IMAGE_REPOSITORY="https://github.com/${GITHUB_REPOSITORY}" \
        --build-arg AIRFLOW_IMAGE_DATE_CREATED="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
        --build-arg AIRFLOW_IMAGE_README_URL="https://raw.githubusercontent.com/apache/airflow/${COMMIT_SHA}/docs/docker-stack/README.md" \
        "${additional_dev_args[@]}" \
        "${additional_runtime_args[@]}" \
        "${docker_prod_directive[@]}" \
        -t "${AIRFLOW_PROD_IMAGE}" \
        --target "main" \
        . -f Dockerfile
    set -u
    if [[ -n "${IMAGE_TAG=}" ]]; then
        echo "Tagging additionally image ${AIRFLOW_PROD_IMAGE} with ${IMAGE_TAG}"
        docker_v tag "${AIRFLOW_PROD_IMAGE}" "${IMAGE_TAG}"
    fi
}