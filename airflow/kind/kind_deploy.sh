#!/usr/bin/env bash
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.


export SKIP_BUILDING_PROD_IMAGE="true"

. "$( dirname "${BASH_SOURCE[0]}" )/../libraries/_build_image_for_kube.sh"
. "$( dirname "${BASH_SOURCE[0]}" )/../libraries/_build_prod.sh"

SCRIPT_DIR="$(cd $(dirname "${BASH_SOURCE[0]}")/../..; pwd)"
export SCRIPT_DIR
readonly SCRIPT_DIR

AIRFLOW_VERSION="v2.2.4"
export AIRFLOW_VERSION


. "${AIRFLOW_DIR}/scripts/ci/libraries/_script_init.sh"

traps::add_trap "kind::dump_kind_logs" EXIT HUP INT TERM

kind::make_sure_kubernetes_tools_are_installed
kind::get_kind_cluster_name
kind::perform_kind_cluster_operation "start"
build_images::prepare_prod_build
build_prod::build_prod_images
build_image_for_kube::build_image_for_kubernetes
kind::load_image_to_kind_cluster
kind::deploy_airflow_with_helm
kind::deploy_test_kubernetes_resources
kind::wait_for_webserver_healthy
