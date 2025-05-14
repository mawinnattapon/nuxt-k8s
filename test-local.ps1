# สคริปต์สำหรับทดสอบ Kubernetes บน Docker Desktop

# ตรวจสอบว่า Docker Desktop และ Kubernetes พร้อมใช้งาน
Write-Host "กำลังตรวจสอบสถานะของ Kubernetes..."
$k8sStatus = kubectl cluster-info
if ($LASTEXITCODE -ne 0) {
    Write-Host "ไม่พบ Kubernetes ที่ทำงานอยู่ กรุณาเปิดใช้งาน Kubernetes ใน Docker Desktop ก่อน" -ForegroundColor Red
    exit 1
}
Write-Host "Kubernetes พร้อมใช้งาน" -ForegroundColor Green

# Build Docker image
Write-Host "กำลัง build Docker image..."
docker build -t nuxt-app:latest -f Dockerfile .
if ($LASTEXITCODE -ne 0) {
    Write-Host "เกิดข้อผิดพลาดในการ build Docker image" -ForegroundColor Red
    exit 1
}
Write-Host "Build Docker image สำเร็จ" -ForegroundColor Green

# ตรวจสอบว่ามีโฟลเดอร์ k8s หรือไม่
if (-not (Test-Path -Path "k8s")) {
    Write-Host "ไม่พบโฟลเดอร์ k8s" -ForegroundColor Red
    exit 1
}

# Deploy ไปยัง Kubernetes
Write-Host "กำลัง deploy ไปยัง Kubernetes..."
Set-Location -Path "k8s"
kubectl apply -k .
if ($LASTEXITCODE -ne 0) {
    Write-Host "เกิดข้อผิดพลาดในการ deploy" -ForegroundColor Red
    exit 1
}
Write-Host "Deploy สำเร็จ" -ForegroundColor Green

# แสดงสถานะของ Pod
Write-Host "กำลังตรวจสอบสถานะของ Pod..."
kubectl get pods -l app=nuxt-app -w
