Docker K8s 

This repository is to create a basic setup to run a node.js application using Docker and K8s

## **1. Folder Structure**  
Your project folder should look like this:  
```
dockerk8sRepo/
│── Dockerfile
│── app/
│   ├── server.js
│   ├── package.json
│── deployment.yaml
│── service.yaml
│── ingress.yaml
│── storage.yaml
│── .github/workflows/deploy.yml
│── README.md
```

## **2. Application Code (`app/server.js`)**
Create a simple **Node.js server**:

```javascript
const express = require("express");
const app = express();
const PORT = 3000;

app.get("/", (req, res) => {
  res.send("Hello from Docker & Kubernetes!");
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

### **Install Dependencies (`app/package.json`)**
```json
{
  "name": "my-node-app",
  "version": "1.0.0",
  "description": "A simple Node.js app running in Docker & Kubernetes",
  "main": "server.js",
  "dependencies": {
    "express": "^4.17.1"
  },
  "scripts": {
    "start": "node server.js"
  }
}
```

Install dependencies:  
```sh
cd app
npm install
```

---

## **3. Dockerfile**
Create a **Dockerfile** to containerize your app:

```Dockerfile
# Use official Node.js image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package.json and install dependencies
COPY app/package.json .
RUN npm install

# Copy application files
COPY app/ .

# Expose port
EXPOSE 3000

# Start the app
CMD ["npm", "start"]
```

Build & test locally:  
```sh
docker build -t my-node-app .
docker run -d -p 3000:3000 my-node-app
```
Check in the browser: **http://localhost:3000**  

Push to Docker Hub:
```sh
docker tag my-node-app <your-dockerhub-username>/my-node-app
docker push <your-dockerhub-username>/my-node-app
```

---

## **4. Kubernetes Deployment (`deployment.yaml`)**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-node-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-node-app
  template:
    metadata:
      labels:
        app: my-node-app
    spec:
      containers:
        - name: my-node-app
          image: <your-dockerhub-username>/my-node-app
          ports:
            - containerPort: 3000
```

Apply:  
```sh
kubectl apply -f deployment.yaml
```

---

## **5. Kubernetes Service (`service.yaml`)**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-node-app-service
spec:
  selector:
    app: my-node-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 3000
  type: LoadBalancer
```

Apply:  
```sh
kubectl apply -f service.yaml
```
Get service URL:  
```sh
minikube service my-node-app-service --url
```

---

## **6. Kubernetes Ingress (`ingress.yaml`)**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-node-app-ingress
spec:
  rules:
    - host: my-node-app.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: my-node-app-service
                port:
                  number: 80
```

Enable Ingress:
```sh
minikube addons enable ingress
kubectl apply -f ingress.yaml
```
Modify `/etc/hosts` (Linux/Mac) or `C:\Windows\System32\drivers\etc\hosts` (Windows):  
```
127.0.0.1 my-node-app.local
```
Now, visit: **http://my-node-app.local**

---

## **7. Persistent Storage (`storage.yaml`)**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-app-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

Modify `deployment.yaml`:
```yaml
volumes:
  - name: app-storage
    persistentVolumeClaim:
      claimName: my-app-pvc
containers:
  - name: my-node-app
    volumeMounts:
      - mountPath: "/data"
        name: app-storage
```
Apply:  
```sh
kubectl apply -f storage.yaml
```

---

## **8. CI/CD with GitHub Actions (`.github/workflows/deploy.yml`)**
```yaml
name: Deploy to Minikube

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3

      - name: Build Docker Image
        run: docker build -t my-node-app .

      - name: Push to Docker Hub
        run: |
          docker login -u ${{ secrets.DOCKER_USERNAME }} -p ${{ secrets.DOCKER_PASSWORD }}
          docker tag my-node-app <your-dockerhub-username>/my-node-app
          docker push <your-dockerhub-username>/my-node-app

      - name: Apply Kubernetes Manifests
        run: |
          kubectl apply -f deployment.yaml
          kubectl apply -f service.yaml
```

## **9. README.md for GitHub**
Create a `README.md` file:

```md
# My Node.js App on Kubernetes 🚀

This repository contains a simple **Node.js application** deployed using **Docker & Kubernetes**.

## Features
✅ Dockerized Node.js App  
✅ Kubernetes Deployment & Service  
✅ Ingress for Custom Domain  
✅ Persistent Storage  
✅ CI/CD with GitHub Actions  

## Setup Instructions

### 1️⃣ Clone the Repo
```sh
git clone https://github.com/<your-github-username>/dockerk8sRepo.git
cd dockerk8sRepo
```

### 2️⃣ Build & Push Docker Image
```sh
docker build -t my-node-app .
docker tag my-node-app <your-dockerhub-username>/my-node-app
docker push <your-dockerhub-username>/my-node-app
```

### 3️⃣ Start Minikube
```sh
minikube start
```

### 4️⃣ Deploy to Kubernetes
```sh
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml
kubectl apply -f storage.yaml
```

### 5️⃣ Access Your App
Get Service URL:
```sh
minikube service my-node-app-service --url
```
Or visit **http://my-node-app.local** (after setting up Ingress).

## CI/CD 🚀
Automatically deploys on push via **GitHub Actions**.
