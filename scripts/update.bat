#!/bin/bash
docker-compose run --rm liquibase update

#!/bin/bash
docker-compose run --rm liquibase validate