# Debug Steps for 503 Service Temporarily Unavailable

Let's debug this step by step to identify what's causing the 503 error.

## Step 1: Check if cert-manager is working
```bash
# Check cert-manager pods
kubectl get pods -n cert-manager

# Check certificate status
kubectl get certificate -n betteruptime
kubectl describe certificate betteruptime-tls-cert -n betteruptime
```

## Step 2: Check ingress status
```bash
# Check ingress controllers
kubectl get ingress -n betteruptime

# Describe ingress to see any errors
kubectl describe ingress betteruptime-frontend-ingress -n betteruptime
kubectl describe ingress betteruptime-api-ingress -n betteruptime
```

## Step 3: Check if services are running
```bash
# Check all pods in your namespace
kubectl get pods -n betteruptime

# Check services
kubectl get svc -n betteruptime

# Check if API is healthy
kubectl logs deployment/api -n betteruptime --tail=50
```

## Step 4: Check nginx ingress controller logs
```bash
# Find nginx ingress controller pods
kubectl get pods -n ingress-nginx

# Check logs for errors
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller --tail=100
```

## Step 5: Test internal connectivity
```bash
# Test if API service is reachable internally
kubectl run test-pod --image=curlimages/curl -i --tty --rm -- sh

# Inside the test pod, run:
curl http://api.betteruptime.svc.cluster.local:3001/health
curl http://frontend.betteruptime.svc.cluster.local:80
```

## Common Issues and Fixes:

### Issue 1: Services not ready
If pods are not running, check:
```bash
kubectl describe pod <pod-name> -n betteruptime
```

### Issue 2: Wrong service ports
Check if service ports match container ports:
```bash
kubectl get svc -n betteruptime -o yaml
```

### Issue 3: Ingress controller not installed
Install nginx ingress controller:
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml
```

### Issue 4: DNS not propagated
Check if DNS points to your load balancer:
```bash
nslookup betteruptime.abhishek97.icu
kubectl get ingress -n betteruptime
```