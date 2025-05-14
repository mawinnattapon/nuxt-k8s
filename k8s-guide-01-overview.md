# คู่มือการ Deploy Nuxt 3 บน Kubernetes

คู่มือนี้อธิบายวิธีการ deploy Nuxt 3 application บน Kubernetes โดยละเอียด ทั้งการตั้งค่า Docker, Kubernetes และการทดสอบบนเครื่องท้องถิ่นด้วย Docker Desktop

## สารบัญ

1. [ภาพรวม (ไฟล์นี้)](./k8s-guide-01-overview.md)
2. [Dockerfile และการ Build Image](./k8s-guide-02-dockerfile.md)
3. [Kubernetes Manifests](./k8s-guide-03-kubernetes-manifests.md)
4. [การทดสอบบน Docker Desktop](./k8s-guide-04-local-testing.md)
5. [คำสั่ง Kubernetes ที่ควรรู้](./k8s-guide-05-kubernetes-commands.md)
6. [การแก้ไขปัญหา](./k8s-guide-06-troubleshooting.md)

## โครงสร้างโปรเจค

```
app-nuxt/
├── k8s/                  # โฟลเดอร์หลักของโปรเจค
│   ├── .nuxt/            # โฟลเดอร์ที่สร้างโดย Nuxt (ไม่ต้องแก้ไข)
│   ├── .output/          # โฟลเดอร์ output ของ Nuxt (ไม่ต้องแก้ไข)
│   ├── node_modules/     # โฟลเดอร์ dependencies (ไม่ต้องแก้ไข)
│   ├── public/           # ไฟล์สาธารณะของ Nuxt
│   ├── server/           # โค้ดฝั่ง server ของ Nuxt
│   ├── k8s/              # ไฟล์ Kubernetes manifests
│   │   ├── deployment.yaml     # กำหนดการ deploy แอป
│   │   ├── service.yaml        # กำหนดการเข้าถึง Pod
│   │   ├── ingress.yaml        # กำหนดการจัดการ traffic จากภายนอก
│   │   ├── configmap.yaml      # เก็บค่าคอนฟิกของแอป
│   │   ├── kustomization.yaml  # รวมไฟล์ทั้งหมดเข้าด้วยกัน
│   │   └── README.md           # คำอธิบายการใช้งาน
│   ├── app.vue           # ไฟล์หลักของ Nuxt
│   ├── Dockerfile        # ไฟล์สำหรับ build Docker image
│   ├── build-push.ps1    # สคริปต์สำหรับ build และ push Docker image
│   ├── test-local.ps1    # สคริปต์สำหรับทดสอบบน Docker Desktop
│   ├── setup-ingress.ps1 # สคริปต์สำหรับติดตั้ง NGINX Ingress Controller
│   ├── update-hosts.ps1  # สคริปต์สำหรับเพิ่ม host ในไฟล์ hosts
│   ├── nuxt.config.ts    # ไฟล์คอนฟิก Nuxt
│   ├── package.json      # ไฟล์กำหนด dependencies
│   └── tsconfig.json     # ไฟล์คอนฟิก TypeScript
```

## ขั้นตอนการ Deploy โดยสรุป

1. **เตรียม Kubernetes Cluster**
   - บนเครื่องท้องถิ่น: เปิดใช้งาน Kubernetes บน Docker Desktop
   - บน Cloud: สร้าง Kubernetes cluster บน AWS EKS, GCP GKE, หรือ Azure AKS

2. **Build และ Push Docker Image**
   ```powershell
   # Windows
   .\build-push.ps1
   ```

3. **Deploy ไปยัง Kubernetes**
   ```bash
   kubectl apply -k k8s/
   ```

4. **ตรวจสอบสถานะ**
   ```bash
   kubectl get pods -l app=nuxt-app
   kubectl get service
   kubectl get ingress
   ```

5. **เข้าถึงแอป**
   - ผ่าน Ingress: http://nuxt-app.localhost/ (ต้องเพิ่มในไฟล์ hosts)
   - ผ่าน NodePort: http://localhost:31008/

ดูรายละเอียดเพิ่มเติมในไฟล์ถัดไป
