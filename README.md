# ITKannadigaru

ITKannadigaru is a simple blogging platform built with Java and Spring Boot. It allows users to register, log in, and create posts.

## Features

-   **User Authentication**: Users can register for a new account and log in.
-   **Post Management**: Authenticated users can create and delete their own posts.
-   **Public Feed**: The home page displays a feed of all posts from all users.

## Project Structure

The project follows a standard Spring Boot application structure:

-   `src/main/java`: Contains the main application source code.
    -   `com.itkannadigaru.controller`: Handles incoming web requests.
    -   `com.itkannadigaru.model`: Defines the data models (e.g., `User`, `Post`).
    -   `com.itkannadigaru.repository`: Manages data access and database operations.
    -   `com.itkannadigaru.service`: Contains the business logic.
    -   `com.itkannadigaru.security`: Configures application security.
-   `src/main/resources`: Contains application resources.
    -   `templates`: HTML templates for the user interface.
    -   `application.properties`: Configuration file for the application.
-   `Dockerfile`: Defines the Docker image for the application.

## How to Run

1.  **Build the application**:
    ```bash
    mvn clean install
    ```
2.  **Run the application**:
    ```bash
    java -jar target/itkannadigaru-webapp-1.0.0.jar
    ```
3.  **Access the application**:
    Open your web browser and go to `http://localhost:8080`.

## CI/CD Pipeline

This project is configured with a CI/CD pipeline that automates the build, test, and deployment process. The pipeline is defined in the `Jenkinsfile` and includes the following stages:

1.  **Checkout**: Checks out the latest code from the repository.
2.  **Build**: Compiles the Java code and builds the application.
3.  **Test**: Runs automated tests to ensure code quality.
4.  **Build Docker Image**: Builds a Docker image of the application.
5.  **Push Docker Image**: Pushes the Docker image to a container registry.
6.  **Deploy**: Deploys the application to a target environment.


eksctl create cluster --name canary-development  \
--region us-east-1 \
--node-type c7i-flex.large \
--nodes-min 2 \
--nodes-max 4 \ 
--zones us-east-1a,us-east-1b

eksctl utils associate-iam-oidc-provider \
  --cluster=canary-development \
  --region=us-east-1 \
  --approve

eksctl delete cluster canary-development --region us-east-1 

eksctl create iamserviceaccount \
  --cluster=canary-development \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::340350203875:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve

sed -i.bak -e 's|your-cluster-name|my-cluster|' ./v2_14_1_full.yaml

---------------------
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: canary
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/actions.weighted-routing: >
      {
        "type":"forward",
        "forwardConfig":{
          "targetGroups":[
            {
              "serviceName":"canary-service-blue",
              "servicePort":"80",
              "weight":80
            },
            {
              "serviceName":"canary-service-green",
              "servicePort":"80",
              "weight":20
            }
          ]
        }
      }
spec:
  rules:
  - host: echo.stage.mydomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: weighted-routing
            port:
              name: use-annotation

for i in $(seq 1 20); do
  curl -s -H "Host: echo.stage.mydomain.com" \
  http://k8s-foo-producti-a7d3b33be3-1507387758.us-east-1.elb.amazonaws.com \
  | grep Hostname
done