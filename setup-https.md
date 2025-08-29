# Setting up HTTPS with cert-manager on GKE

Follow these steps to enable HTTPS for your application:

## Step 1: Install cert-manager

```bash
# Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.3/cert-manager.yaml

# Wait for cert-manager to be ready
kubectl wait --for=condition=ready pod -l app=cert-manager -n cert-manager --timeout=60s
kubectl wait --for=condition=ready pod -l app=cainjector -n cert-manager --timeout=60s
kubectl wait --for=condition=ready pod -l app=webhook -n cert-manager --timeout=60s
```

## Step 2: Update email in ClusterIssuer

Edit the `k8s/cert-manager-issuer.yaml` file and replace `your-email@example.com` with your actual email address.

## Step 3: Apply the configurations

```bash
# Apply the ClusterIssuer
kubectl apply -f k8s/cert-manager-issuer.yaml

# Update the configmap with HTTPS backend URL
kubectl apply -f k8s/configmaps.yaml

# Replace the old ingress with HTTPS-enabled version
kubectl delete -f k8s/nginx-ingress.yaml
kubectl apply -f k8s/nginx-ingress-https.yaml
```

## Step 4: Wait for certificate provisioning

```bash
# Check certificate status
kubectl get certificate -n betteruptime
kubectl describe certificate betteruptime-tls-cert -n betteruptime

# Check cert-manager logs if needed
kubectl logs -n cert-manager deployment/cert-manager
```

## Step 5: Restart frontend deployment to pick up new environment variables

```bash
kubectl rollout restart deployment/frontend -n betteruptime
```

## Step 6: Verify HTTPS is working

```bash
# Check ingress status
kubectl get ingress -n betteruptime

# Test HTTPS endpoint
curl -I https://betteruptime.abhishek97.icu
curl -I https://betteruptime.abhishek97.icu/api/health
```

## Troubleshooting

If certificates don't provision:

1. Check cert-manager logs:
```bash
kubectl logs -n cert-manager deployment/cert-manager
```

2. Check certificate challenges:
```bash
kubectl get challenges -n betteruptime
kubectl describe challenges -n betteruptime
```

3. Verify DNS is pointing to your ingress:
```bash
kubectl get ingress -n betteruptime
nslookup betteruptime.abhishek97.icu
```

4. If using staging issuer first (recommended for testing):
```bash
# Use staging issuer in cert-manager-issuer.yaml first
# Then switch to production after testing
```

## Expected Results

After successful setup:
- ✅ Frontend accessible at https://betteruptime.abhishek97.icu
- ✅ API accessible at https://betteruptime.abhishek97.icu/api/*
- ✅ Automatic HTTP to HTTPS redirect
- ✅ Valid SSL certificate from Let's Encrypt
- ✅ No more mixed content errors