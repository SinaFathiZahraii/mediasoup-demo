
## Project Overview, Project Structure

This project mediasoup-demo is a real-time audio/video/screen sharing application built on mediasoup, a Node.js SFU library. Unlike mesh (P2P) or full MCU architectures, an SFU relays media streams between participants without the need for code conversion, which keeps CPU overhead low and allows a single server to support many participants in each room.

Key Features

Multi-person audio/video conference rooms
Screen sharing
Simultaneous streaming/SVC support for adaptive video quality
Horizontal scalability via multiple mediasoup workers (one for each CPU core)
Fully containerized, deployable to any Kubernetes cluster
Automated build → test → deploy pipeline via GitLab CI/CDGitLab CI/CD

## Project structure:

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


##  Project requirements
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

## Installation

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

## setup via Docker

```
# docker build -t IMAGE_NAME:INAGE_TAG .
# docker run -d --name CANTAINER_NAME -p 4443:4443 IMAGE_NAME:INAGE_TAG
```

