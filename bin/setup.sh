#!/bin/bash
docker-compose run device-service bundle
docker-compose run device-service ./cli db_migrate
cd ../device-service/docs && mkdocs build # build api doc