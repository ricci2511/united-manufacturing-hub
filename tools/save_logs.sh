#!/usr/bin/env bash
# Copyright 2023 UMH Systems GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Get directory from arguments
dir=$1

# Create dir and cd into it
mkdir -p "$dir"
cd "$dir" || exit

# Get all deployments
deployments=$(kubectl get deployments -n united-manufacturing-hub -o name)
# Get all statefulsets
statefulsets=$(kubectl get statefulsets -n united-manufacturing-hub -o name)
# Get all jobs
jobs=$(kubectl get jobs -n united-manufacturing-hub -o name)

# Get logs for all deployments
for deployment in $deployments; do
    log="${deployment##*/}"
    log="${log//*united-manufacturing-hub-}"
    kubectl logs "$deployment" -n united-manufacturing-hub --all-containers --prefix > deployment-"$log".log || true
done

# Get logs for all statefulsets
for statefulset in $statefulsets; do
    log="${statefulset##*/}"
    log="${log//*united-manufacturing-hub-}"
    kubectl logs "$statefulset" -n united-manufacturing-hub --all-containers --prefix > statefulset-"$log".log || true
done

# Get logs for all jobs
for job in $jobs; do
    log="${job##*/}"
    log="${log//*united-manufacturing-hub-}"
    kubectl logs "$job" -n united-manufacturing-hub --all-containers --prefix > job-"$log".log || true
done

# Get all pods and services
kubectl get po,svc -n united-manufacturing-hub > kubectl_pods_and_services.log

# Get all events
kubectl get events -n united-manufacturing-hub > kubectl_events.log

# Describe all pods
kubectl describe po -n united-manufacturing-hub > kubectl_describe_pods.log

# Describe all services
kubectl describe svc -n united-manufacturing-hub > kubectl_describe_services.log

# Helm status
helm status united-manufacturing-hub -n united-manufacturing-hub > helm_status.log

# cd back to original directory
cd - || exit
