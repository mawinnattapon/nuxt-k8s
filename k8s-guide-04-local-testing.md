# การทดสอบบน Docker Desktop

การทดสอบ Kubernetes บนเครื่องท้องถิ่นสามารถทำได้ง่ายๆ ด้วย Docker Desktop ซึ่งมี Kubernetes ในตัว ในส่วนนี้จะอธิบายวิธีการตั้งค่าและทดสอบแอป Nuxt บน Docker Desktop

## การเตรียมพร้อม Docker Desktop

### 1. เปิดใช้งาน Kubernetes บน Docker Desktop

1. เปิด Docker Desktop
2. คลิกที่ Settings (เฟือง) > Kubernetes
3. เลือก "Enable Kubernetes" แล้วคลิก "Apply & Restart"
4. รอสักครู่ให้ Kubernetes พร้อมใช้งาน (สถานะจะเปลี่ยนเป็นสีเขียว)

### 2. ติดตั้ง NGINX Ingress Controller

NGINX Ingress Controller เป็นส่วนสำคัญที่จะช่วยให้สามารถเข้าถึงแอปผ่าน URL ได้ สามารถติดตั้งได้ด้วยสคริปต์ `setup-ingress.ps1` หรือคำสั่งโดยตรง

#### วิธีที่ 1: ใช้สคริปต์ setup-ingress.ps1

```powershell
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
```

#### วิธีที่ 2: ใช้คำสั่ง kubectl โดยตรง

```powershell
# ติดตั้ง NGINX Ingress Controller ด้วย kubectl
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml
```

### 3. เพิ่ม host ในไฟล์ hosts

เพื่อให้สามารถเข้าถึงแอปผ่าน URL `nuxt-app.localhost` ได้ ต้องเพิ่มรายการในไฟล์ hosts ของระบบ สามารถทำได้ด้วยสคริปต์ `update-hosts.ps1` หรือคำสั่งโดยตรง

#### วิธีที่ 1: ใช้สคริปต์ update-hosts.ps1

```powershell
# สคริปต์สำหรับเพิ่ม nuxt-app.localhost ในไฟล์ hosts
# ต้องรันด้วยสิทธิ์ Administrator

$hostsFile = "C:\Windows\System32\drivers\etc\hosts"
$hostEntry = "127.0.0.1 nuxt-app.localhost"

# ตรวจสอบว่ามีรายการนี้ในไฟล์ hosts แล้วหรือไม่
$hostsContent = Get-Content -Path $hostsFile
$entryExists = $hostsContent | Where-Object { $_ -eq $hostEntry }

if (-not $entryExists) {
    Write-Host "กำลังเพิ่ม '$hostEntry' ในไฟล์ hosts..."
    
    try {
        Add-Content -Path $hostsFile -Value "`n$hostEntry" -ErrorAction Stop
        Write-Host "เพิ่มรายการในไฟล์ hosts สำเร็จ" -ForegroundColor Green
    }
    catch {
        Write-Host "เกิดข้อผิดพลาด: $_" -ForegroundColor Red
        Write-Host "กรุณารันสคริปต์นี้ด้วยสิทธิ์ Administrator" -ForegroundColor Yellow
    }
}
else {
    Write-Host "รายการ '$hostEntry' มีอยู่ในไฟล์ hosts แล้ว" -ForegroundColor Green
}

# แสดงเนื้อหาของไฟล์ hosts
Write-Host "`nเนื้อหาของไฟล์ hosts ปัจจุบัน:"
Get-Content -Path $hostsFile
```

#### วิธีที่ 2: ใช้คำสั่ง PowerShell โดยตรง

```powershell
# ต้องรันด้วยสิทธิ์ Administrator
Add-Content -Path "C:\Windows\System32\drivers\etc\hosts" -Value "`n127.0.0.1 nuxt-app.localhost" -Force
```

## การ Build และ Deploy

### 1. Build Docker Image

ก่อนที่จะ deploy แอปบน Kubernetes ต้อง build Docker image ก่อน

```powershell
# Build Docker image
docker build -t nuxt-app:latest -f Dockerfile .
```

### 2. Deploy ไปยัง Kubernetes

หลังจาก build image แล้ว สามารถ deploy ไปยัง Kubernetes ได้ด้วยคำสั่ง `kubectl apply`

```powershell
# Deploy ไปยัง Kubernetes
kubectl apply -k k8s/
```

### 3. ตรวจสอบสถานะ

หลังจาก deploy แล้ว ควรตรวจสอบสถานะของ Pod, Service และ Ingress

```powershell
# ตรวจสอบ Pod
kubectl get pods -l app=nuxt-app

# ตรวจสอบ Service
kubectl get service

# ตรวจสอบ Ingress
kubectl get ingress
```

### 4. เข้าถึงแอป

เมื่อทุกอย่างพร้อมใช้งานแล้ว สามารถเข้าถึงแอปได้ 2 วิธี:

1. **ผ่าน Ingress**: เปิดเบราว์เซอร์แล้วเข้า URL http://nuxt-app.localhost/
2. **ผ่าน NodePort**: เปิดเบราว์เซอร์แล้วเข้า URL http://localhost:31008/

## สคริปต์ test-local.ps1

สคริปต์นี้รวมขั้นตอนทั้งหมดไว้ในที่เดียว ทั้ง build image และ deploy ไปยัง Kubernetes

```powershell
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
```

## การแก้ไขปัญหาเบื้องต้น

### 1. ปัญหา Ingress ไม่ทำงาน

ถ้า Ingress ไม่ทำงาน (เข้า URL http://nuxt-app.localhost/ แล้วได้ 404) ให้ตรวจสอบ:

1. **ตรวจสอบว่า Ingress Controller ทำงานหรือไม่**:
   ```powershell
   kubectl get pods -n ingress-nginx
   ```

2. **ตรวจสอบ logs ของ Ingress Controller**:
   ```powershell
   kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller
   ```

3. **ตรวจสอบรายละเอียดของ Ingress**:
   ```powershell
   kubectl describe ingress nuxt-app-ingress
   ```

4. **แก้ไขไฟล์ ingress.yaml ให้มี ingressClassName**:
   ```yaml
   spec:
     ingressClassName: nginx
     rules:
     ...
   ```

### 2. ปัญหา Pod ไม่ start

ถ้า Pod ไม่ start ให้ตรวจสอบ:

1. **ตรวจสอบสถานะของ Pod**:
   ```powershell
   kubectl describe pod <pod-name>
   ```

2. **ดู logs ของ Pod**:
   ```powershell
   kubectl logs <pod-name>
   ```

3. **ตรวจสอบว่า image มีอยู่จริง**:
   ```powershell
   docker images | grep nuxt-app
   ```

### 3. ปัญหา Service ไม่ทำงาน

ถ้า Service ไม่ทำงาน ให้ตรวจสอบ:

1. **ตรวจสอบ endpoints ของ Service**:
   ```powershell
   kubectl get endpoints nuxt-app-service
   ```

2. **ตรวจสอบว่า selector ตรงกับ labels ของ Pod**:
   ```powershell
   kubectl get pods --show-labels
   ```

### 4. ทดสอบการเชื่อมต่อโดยตรงกับ Pod

ใช้ port-forward เพื่อทดสอบการเชื่อมต่อโดยตรงกับ Pod:

```powershell
# หา pod name ก่อน
kubectl get pods -l app=nuxt-app

# แล้ว port-forward ไปยัง pod นั้น (แทนที่ <pod-name> ด้วยชื่อจริง)
kubectl port-forward <pod-name> 3000:3000
```

แล้วเข้า http://localhost:3000/ เพื่อทดสอบแอปโดยตรง

ในส่วนถัดไป เราจะดูเกี่ยวกับ [คำสั่ง Kubernetes ที่ควรรู้](./k8s-guide-05-kubernetes-commands.md)
