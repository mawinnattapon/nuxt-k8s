# ติดตั้ง NGINX Ingress Controller แบบง่าย
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml

# รอให้ Ingress Controller พร้อมใช้งาน
Write-Host "รอให้ Ingress Controller พร้อมใช้งาน..."
Start-Sleep -Seconds 10

# แสดงสถานะ
kubectl get pods -n ingress-nginx
