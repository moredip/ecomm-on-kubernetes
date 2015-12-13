#!/bin/bash
set -e -u

if [ $# -eq 0 ]
  then
    echo "No namespace specified"
		exit 1
fi

namespace=$1

echo "creating namespace ${namespace}..."

( cat << EOF
---
kind: Namespace
apiVersion: v1
metadata:
  name: ${namespace}
  labels:
    name: ${namespace}
    environmentType: disposable
EOF
) | kubectl create --alsologtostderr -f -


echo 'creating resources...'
kubectl create --namespace="${namespace}" --alsologtostderr -f resources/

kubectl create --namespace="${namespace}" --alsologtostderr -f jobs/pricing-db-migrate.yaml



#kubectl delete --namespace="${namespace}" -f resources/web-app.yaml
#kubectl create --namespace="${namespace}" --alsologtostderr -f resources/web-app.yaml


# can take a few mins for an external loadbalancer IP to be assigned to our service
echo -n 'checking for external ip...'
count=0
external_ip=""
while [ "$count" -lt 60 -a -z "$external_ip" ]; do
	external_ip=$(kubectl get --namespace="${namespace}" svc/web-app -o template --template '{{with .status.loadBalancer.ingress}}{{(index . 0).ip}}{{end}}')
  let count=count+1
  sleep 5
	echo -n '.'
done

echo ' all done!'

echo "namespace: ${namespace}"
echo "external_ip: ${external_ip}"
