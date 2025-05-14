# การ Deploy Nuxt Application บน Kubernetes

คู่มือนี้อธิบายวิธีการ deploy Nuxt application บน Kubernetes

## ขั้นตอนการ Deploy

### 1. Build และ Push Docker Image

```powershell
# Windows
.\build-push.ps1

# หรือถ้าใช้ Linux/Mac
# ./build-push.sh
```

อย่าลืมแก้ไขค่า `REGISTRY` ในไฟล์สคริปต์ให้ตรงกับ registry ที่คุณใช้

### 2. แก้ไขไฟล์ Kubernetes Manifest

แก้ไขไฟล์ต่อไปนี้ให้ตรงกับสภาพแวดล้อมของคุณ:
- `deployment.yaml`: แก้ไข image ให้ตรงกับ image ที่คุณ push ไปยัง registry
- `ingress.yaml`: แก้ไข host ให้ตรงกับโดเมนของคุณ
- `configmap.yaml`: แก้ไขค่าคอนฟิกให้ตรงกับความต้องการของคุณ

### 3. Deploy ไปยัง Kubernetes Cluster

```bash
# ใช้ kubectl apply
kubectl apply -k .

# หรือใช้ kustomize แยก
kustomize build . | kubectl apply -f -
```

### 4. ตรวจสอบสถานะ

```bash
# ตรวจสอบ pod
kubectl get pods -l app=nuxt-app

# ตรวจสอบ service
kubectl get service nuxt-app-service

# ตรวจสอบ ingress
kubectl get ingress nuxt-app-ingress
```

## การอัปเดต Application

เมื่อต้องการอัปเดตแอปพลิเคชัน ให้ทำตามขั้นตอนต่อไปนี้:

1. แก้ไขโค้ดของคุณ
2. Build และ Push Docker image ใหม่ (อย่าลืมเปลี่ยน tag ถ้าต้องการ)
3. แก้ไข image tag ในไฟล์ `deployment.yaml`
4. Deploy อีกครั้ง:

```bash
kubectl apply -k .
```

## การใช้งานกับ Cloudflare

หากคุณใช้ Cloudflare เป็น DNS และ proxy:

1. ตั้งค่า DNS record ที่ Cloudflare ให้ชี้ไปที่ IP ของ Kubernetes Ingress Controller
2. เปิดใช้งาน proxy (เปิด cloud icon ให้เป็นสีส้ม)
3. แนะนำให้ตั้งค่า SSL/TLS เป็น Full หรือ Full (strict)

## การแก้ไขปัญหา

หากเกิดปัญหาในการ deploy:

```bash
# ดูรายละเอียด pod
kubectl describe pod <pod-name>

# ดู log ของ pod
kubectl logs <pod-name>

# ตรวจสอบ events
kubectl get events --sort-by='.lastTimestamp'
```
