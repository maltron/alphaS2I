DOCKER_IMAGE="/alpha/alpha-test:latest"
DOCKER_REGISTRY_IP=$(oc get service/docker-registry --output jsonpath="{.spec.clusterIP}" --namespace default)
DOCKER_REGISTRY_PORT=$(oc get service/docker-registry --output jsonpath="{.spec.ports.*.port}" --namespace default)
DOCKER_REGISTRY=${DOCKER_REGISTRY_IP}:${DOCKER_REGISTRY_PORT}
oc login --username=uploader --password=maltron --insecure-skip-tls-verify --server=https://openshift.example.com:8443
TOKEN=$(oc whoami --token=true)
oc login --username=system:admin --insecure-skip-tls-verify --server=https://openshift.example.com:8443
docker rmi ${DOCKER_REGISTRY}${DOCKER_IMAGE}
docker build --no-cache --rm=true --force-rm --tag ${DOCKER_REGISTRY}${DOCKER_IMAGE} .
docker login -u uploader -e mailto:uploader@abc.com -p ${TOKEN} ${DOCKER_REGISTRY} 
docker push ${DOCKER_REGISTRY}${DOCKER_IMAGE}
