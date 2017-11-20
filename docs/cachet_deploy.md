### Cachet deployment using a Docker image

Deployment is driven by the `cachet_deploy_docker.sh` script in this repo.
This implementation uses the docker image from https://github.com/CachetHQ/Docker, forked with modifications at https://github.com/thehungrysmurf/Docker

These modifications to the original docker image were needed for this CI process:

- change docker-compose.yml version from 3 to 3.4 (version 3 is incompatible with the docker engine version available from the standard apt repo)
- simplify composer installation (original method produced PHP errors which were time consuming to diagnose)
- change forwarded port docker->localhost from 80 to 7999 (80 is in use by Jenkins service)

Deployment involves the following steps:

- build docker image for Cachet (the image from Docker repo is configured to use the add-on postgres image)
- start docker containers to obtain an app key
- collect app key from output and configure the value in docker-compose.yml
- restart docker containers (Cachet + Postgres)
- poll for Cachet container to have "Up" status (query every 10 sec for 2 minutes, time out)

At present deployment is considered complete and correct when these checks pass:

- API check: issue a request to API ping endpoint, verify response
- Site check: verify the status code of `/setup` is 200

If deployment steps complete correctly, the docker containers are stopped and removed along with images. This is accomplished by a post-build Jenkins step. If deployment does not complete correctly, the cleanup step does not run. The docker containers and images are preserved for examination.

#### Future work
- If time allowed, more rigorous checks to verify the integrity of deployment would be added. For example, I would seed the application and/or automate the setup step so that I can send more complex API requests regarding incidents and metrics.
- End to end tests should run to validate the integrity of deployment.
- The current implementation only deploys Cachet with Postgres, but all the supported databases should be deployed. The Cachet Docker repo already includes a docker-compose file that uses MySql that I can use. I would have to create one that uses SQLite.

