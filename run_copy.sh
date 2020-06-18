#!/bin/bash

# at least 1 argument to be pass in
if  [ $# == 0 ]; then
    echo "run.sh needs a service module package to run"
    echo "eg: run.sh gate.service api.service"
    exit 1
fi

# Run Migrations for Postgres DB for Orders' backing service 
(
    cd orders
    PYTHONPATH=. alembic upgrade head
)
export PYTHONPATH=./gateway:./orders:./products
nameko shell --config config.yaml

