#!/bin/bash
set -e

echo "🚀 Applying persistent volume configurations..."

# Apply persistent volume claims first
echo "📦 Creating persistent volume claims..."
kubectl apply -f k8s/persistent-volumes.yaml

# Apply storage classes
echo "💾 Creating storage classes..."
kubectl apply -f k8s/storage-class.yaml

# Wait for PVCs to be bound
echo "⏳ Waiting for persistent volume claims to be bound..."
kubectl wait --for=condition=Bound pvc/postgres-pvc -n betteruptime --timeout=120s
kubectl wait --for=condition=Bound pvc/redis-pvc -n betteruptime --timeout=120s

# Update deployments with persistent volumes
echo "🔄 Updating PostgreSQL deployment with persistent storage..."
kubectl apply -f k8s/postgres-deployment.yaml

echo "🔄 Updating Redis deployment with persistent storage..."
kubectl apply -f k8s/redis-deploy.yaml

# Apply backup configuration
echo "💾 Setting up automated backups..."
kubectl apply -f k8s/backup-cronjob.yaml

# Apply monitoring configuration
echo "📊 Setting up storage monitoring..."
kubectl apply -f k8s/monitoring.yaml

# Wait for deployments to be ready
echo "⏳ Waiting for deployments to be ready..."
kubectl rollout status deployment/postgres -n betteruptime --timeout=300s
kubectl rollout status deployment/redis -n betteruptime --timeout=300s

echo "✅ Persistent volumes configured successfully!"
echo ""
echo "📋 Summary:"
echo "  - PostgreSQL data: 10Gi persistent volume"
echo "  - Redis data: 5Gi persistent volume"
echo "  - Automated daily backups at 2 AM UTC"
echo "  - Backup retention: 7 days"
echo "  - Storage monitoring enabled"
echo ""
echo "🔍 Check status with:"
echo "  kubectl get pvc -n betteruptime"
echo "  kubectl get pods -n betteruptime"
echo "  kubectl describe pvc postgres-pvc -n betteruptime"