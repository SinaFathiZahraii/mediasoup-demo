
## Project Overview

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
## Generate Self-Signed SSL Certificates 

Generate Self-Signed SSL Certificates
Since WebRTC requires a secure context (HTTPS/WSS) to access user media (microphone and webcam), you must provide TLS certificates. 
For local or LAN testing, you can generate self-signed certificates. Run the following commands from the root of the project (mediasoup-demo/):

```
# 1. Create the certs directory if it doesn't exist 
mkdir -p app/certs
# 2. Generate the self-signed certificate and private key 
openssl req -x509 -newkey rsa:4096 -keyout app/certs/key.pem -out app/certs/cert.pem -days 365 -nodes -subj "/CN=localhost"
# 3. Open the server/config.mjs file and change the tls section exactly like this (give the paths inside the docker):
        tls: {
            cert: '/app/certs/cert.pem',
            key: '/app/certs/key.pem',
        },
# 4.Run container - adjust paths since certs are in app/certs/
docker run -d --name mediasoup-demo -p 4443:4443 -p 10000-59999:10000-59999/udp -v $(pwd)/app/certs:/app/certs:ro mediasoup-demo:v3
# 5. in browser:
https://IP_SERVER:4443 
```

## setup via Docker

```
docker build -t IMAGE_NAME:INAGE_TAG .
docker run -d --name CANTAINER_NAME -p 4443:4443 IMAGE_NAME:INAGE_TAG
```

