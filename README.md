## Overview
This mock Cachet CI pipeline consists of a local Jenkins server which runs 2 tasks:

1. Build Cachet and run unit tests for a parameter-specified branch
This is performed by the `cachet-run-tests-by-branch` job.
The job is started manually and invokes the `cachet_run_tests.sh` script located in this repo.

2. Deploy Cachet in a Docker container and verify deployment integrity
This is performed by the `cachet-deploy-as-docker-image` job.
The job is started manually and invokes the `cachet_deploy_docker.sh` script in this repo.

Details about what each script accomplishes can be found in the `docs/` folder.

### Challenges
- PHPUnit 7.0 stalls midway through running the test suite. No errors are logged. It's possible the cause is a PHP memory allocation issue, but I could not get to the bottom of it in a timely fashion so I tabled the issue in favor of attending to other tasks. Running tests in parallel using Paratest resolved the issue, the entire test suite now completes.
- The official docker image from Cachet comes with a docker-compose file of version 3.0. However, this version is incompatible with the docker-engine version available from the standard apt repo for Ubuntu. I had to change the version and make a few tweaks to the docker-compose file to eliminate the errors.
- The next task I tackled was to push the Cachet docker image to a private registry on Google Cloud, as a preliminary step to extending deployment to a cluster of instances and deploying multiple versions of Cachet. I ran into problems pushing the image to the registry using the Gcloud service account associated with the Jenkins server VM. Though the Container API is enabled for the project, the service account has Owner level permissions in the project and the registry exists, the push operation is stuck in a retry loop which eventually times out. There are no errors on the command line even with debug level output enabled. There might be a problem with using a service account to push to a private registry, however the issue is undocumented. I would need more time to diagnose the problem and continue.

### Future work
If I had more time available, I would continue the task as follows.

- Create a separate (non-service) user account and grant it Owner permissions on the Gcloud project.
- Initialize gcloud on the Jenkins server authenticating as the new user account (hopefully this would resolve the permissions issue)
-  Interject an additional step in `cachet_deploy_docker.sh` after image build, to tag and push the image to the Gcloud container registry.
- To deploy a specific versions, Jenkins could check out a version tag before building the image and push the image to the registry with a name that includes the tag.
- To deploy multiple versions within the same job, the versions we build continuously could be listed in a versioned text file that Jenkins reads, and builds all the versions (tags) in the list.
- Modify the container deployment to deploy to a Kubernetes cluster instead of a local Docker image. This can be accomplished starting a cluster using Minikube or similar on the Jenkins server, and run a deployment for each image pushed to the registry by the job.

Per the project specs, a dashboard is also needed to provide insight into the health and metrics of the application. This dashboard should include, at minimum:

- Unit test pass/fail results
- Duration of deployment for latest version, delta from previous version
- API response times for a given set of requests from deployments running against different database flavors (assess database-specific bottlenecks)
- API response time degradation from previous versions for the same set of requests
- Results of throughput/performance tests for latest version (these tests don't exist yet in Cachet but could be added using Apache Benchmark for example), and delta from previous version.
