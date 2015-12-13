#!/bin/bash
set -e -u

if [ $# -eq 0 ]
  then
    echo "No namespace specified"
		exit 1
fi

namespace=$1

echo "destroying namespace ${namespace}..."

kubectl delete namespace/${namespace}
