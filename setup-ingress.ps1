# สคริปต์สำหรับติดตั้ง NGINX Ingress Controller บน Docker Desktop

# ติดตั้ง NGINX Ingress Controller
Write-Host "กำลังติดตั้ง NGINX Ingress Controller..."

# เพิ่ม repo ของ ingress-nginx
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# ติดตั้ง ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx

# รอให้ Ingress Controller พร้อมใช้งาน
Write-Host "รอให้ Ingress Controller พร้อมใช้งาน..."
kubectl wait --namespace default --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=120s

Write-Host "NGINX Ingress Controller ติดตั้งสำเร็จ" -ForegroundColor Green

# แสดงข้อมูลเพิ่มเติม
Write-Host "คุณสามารถเข้าถึงแอปได้ที่: http://nuxt-app.localhost/"
Write-Host "อย่าลืมเพิ่ม 'nuxt-app.localhost' ในไฟล์ hosts ของคุณ (C:\Windows\System32\drivers\etc\hosts)"
Write-Host "เพิ่มบรรทัดนี้: 127.0.0.1 nuxt-app.localhost"
