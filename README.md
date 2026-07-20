
**1. Project Overview, Project Structure**

This project mediasoup-demo is a real-time audio/video/screen sharing application built on mediasoup, a Node.js SFU library. Unlike mesh (P2P) or full MCU architectures, an SFU relays media streams between participants without the need for code conversion, which keeps CPU overhead low and allows a single server to support many participants in each room.

Key Features

Multi-person audio/video conference rooms
Screen sharing
Simultaneous streaming/SVC support for adaptive video quality
Horizontal scalability via multiple mediasoup workers (one for each CPU core)
Fully containerized, deployable to any Kubernetes cluster
Automated build → test → deploy pipeline via GitLab CI/CDGitLab CI/CD

## 2.Project structure:

```
mediasoup-demo/
├── app/                      
├── server/                   
│   ├── lib/
│   ├── config.js
│   └── server.js
├── docker/
│   ├── Dockerfile
|
├── k8s/
│   ├── deployment.yaml
│   ├── service.yaml
│   
├── .gitlab-ci.yml
├── .env.example
└── README.md
```


## 3. Project requirements
This section is different from the Dependency section.
```
#Required tools: 
- Docker >= 27 
- Node.js >=22 
- npm >=9.x
- Python >=3.7
- Kubernetes cluster foe deploy
- GitLab Runner
```

## 4. Deploy and test the project locally:

```
# 1. Clone
cd mediasoup-demo

# 2. Configure environment
cp .env.example .env

# 3. Install dependencies (root, server, and client if separated)
npm install
cd server && npm install && cd ..
cd app && npm install && cd ..

# 4. Run the signaling server (dev mode)
cd server && npm run dev

# 5. Run the client (separate terminal)
cd app && npm run dev
```

## 5. Docker

#### Dockerfile (multi-stage)

In this section, the Dockerfile is divided into two stages to create the smallest image size and remove unnecessary layers.

```
FROM node:22-bookworm AS builder

RUN apt-get update && \
    apt-get install -y \
        python3 \
        python3-pip \
        build-essential \
        gcc \
        g++ \
        make \
        git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY . .

WORKDIR /build/app
RUN npm ci --legacy-peer-deps

WORKDIR /build/server
RUN npm ci

WORKDIR /build/app
RUN npm run build


# Runtime
#==================
FROM node:22-bookworm-slim

WORKDIR /app

COPY --from=builder /build/server .

COPY --from=builder /build/app/dist ./public

ENV NODE_ENV=production

EXPOSE 4443

CMD ["./bin/mediasoup-demo-server"]
```

#### Build & run

```
docker build -t mediasoup-demo:v1 .
docker ps
docker run -d --name test -p 4443:4443 mediasoup-demo:v1
```

## 6. Kubernetes Deployment

It consists of two files, one for Deployment, which is used to run the application and ensure that it is always up with features such as replica, etc., and the other for the service and how it is published outside the cluster:

  Deployment.yml
  ```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mediasoup-demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: mediasoup-demo
  template:
    metadata:
      labels:
        app: mediasoup-demo
    spec:
      containers:
      - name: mediasoup-demo
        image: sinafathi/mediasoup-demo:v1
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 4443
        resources:
          requests:
            cpu: "2"
            memory: "2Gi"
          limits:
            cpu: "4"
            memory: "4Gi"

  ```

service.yml
```
apiVersion: v1
kind: Service
metadata:
  name: mediasoup-demo-svc
spec:
  type: LoadBalancer
  selector:
    app: mediasoup-demo
  ports:
    - port: 4443
      targetPort: 4443

```



## 7. GitLab CI/CD Pipeline

Writing a .gitlab-ci.yml file to automate 3 important steps that can be crucial in speeding up the team:

gitlab-ci.yml
```
stages:
  - build
  - test
  - deploy

variables:
  IMAGE_TAG: $CI_COMMIT_SHA

default:
  tags:
    - runner-tag  

build:
  stage: build
  script:
    - docker build -t sinafathi/mediasoup:$IMAGE_TAG .

test:
  stage: test
  image: node:22
  script:
    - cd server
    - npm ci --omit=dev
    - cd ../app
    - npm ci --legacy-peer-deps
    - npm run lint || true 
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"

deploy:
  stage: deploy
  image: bitnami/kubectl:latest
  script:
    - mkdir -p ~/.kube
    - echo "$KUBE_CONFIG" | base64 -d > ~/.kube/config
    - chmod 600 ~/.kube/config
    - sed -i "s|sinafathi/mediasoup-demo:v1|$IMAGE_TAG|g" k8s/deployment.yaml
    - kubectl apply -f k8s/
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
```

