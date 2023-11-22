# LiFi Code Challenge

Directory structure

```
├── Dockerfile          # Dockerfile
├── README.md
├── compose.yaml        # docker-compose
├── config              # Terraform configuration
│   ├── infra
│   ├── modules
│   └── prod
├── package-lock.json
├── package.json        # Scripts and deps
├── spec                # Tests
│   ├── persistence
│   └── routes
└── src
    ├── cache
    ├── index.js        # Entrypoint of application
    ├── persistence
    └── routes
```

# Getting Started

```
>>> docker-compose up --build
>>> curl -XPOST http://localhost:3000/items -d '{"name": "first"}'
>>> curl -XGET http://localhost:3000/items # twice
```

Check the docker logs to see that the get request is cached.

# Components

## 1. Application

Simplest possible application that implements a REST server with `GET /status`, `GET /items`, and `POST /items` endpoints.
Tests are also implemented, using a local sqlite DB and a `Map` as a cache.

Local development enabled by docker and docker-compose, which run Redis and Postgres instances.

Tech stack:

-   Node.js
-   Express
-   Redis
-   pg (postgres)
-   Jest

No ORM is used for simplicity. Typescript was also not used, again for simplicity

## 2. Infrastructure

The main tenant here has been simplicity and code re-usability, and leaving the infra open to extension.

Tech stack:

-   Terraform
-   AWS (ECS, ElasticCache, RDS, VPC, Load Balancer, etc.)
-   GHA for CICD

The infrastructure is defined in Terraform, and is deployed to AWS using Github Actions. The infrastructure is defined in the `config` directory, and is split into 3 parts:

-   `config/modules` - reusable modules that can be used to create infrastructure
-   `config/infra` - the infrastructure needed for all enviornments (ecr repos, IAM roles, )
-   `config/prod` - the infrastructure needed for the production environment (ECS, RDS, etc.)

If new environments are needed, they can reference the `modules` and simply just use the same codebase as `prod`, with different variable

## 2.1 Deployment

All deployments are handled by CICD.

Steps:

1. First, we build and test the code, using node only
2. Subsequently, shared resources (ECR repo, IAM roles) are created by the `terraform-infra` CI step.
3. Then, the docker image is built and pushed to ECR by the `build-and-push-image` CI step.
4. Finally, the service is deployed to ECS by the `terraform-services` CI step, using the referenced image

## 2.2 Secrets and variables

-   Secrets are managed simply by setting them in the CI environment variables, and injected into the application via terraform variables
-   Other variables (e.g. the docker image tag) is set by using the git commit hash, which is injected into the CI environment variables by default

## 3. Optionals

-   CW Logs are used
-   Redis is used for caching responses
-   Prometheus wasn't implemented in the interest of time
