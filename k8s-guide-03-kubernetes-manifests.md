# Kubernetes Manifests

ในส่วนนี้จะอธิบายไฟล์ Kubernetes manifests ทั้งหมดที่ใช้ในโปรเจคนี้ ซึ่งอยู่ในโฟลเดอร์ `k8s/`

## 1. deployment.yaml

ไฟล์นี้กำหนดวิธีการ deploy แอปพลิเคชัน Nuxt บน Kubernetes

```yaml
apiVersion: apps/v1  # เวอร์ชันของ API ที่ใช้ (apps/v1 เป็นเวอร์ชันมาตรฐานสำหรับ Deployment)
kind: Deployment  # ประเภทของทรัพยากร Kubernetes (Deployment คือการกำหนดวิธีการ deploy แอป)
metadata:  # ข้อมูลเมตาดาต้าของ Deployment
  name: nuxt-app  # ชื่อของ Deployment ใช้อ้างอิงใน kubectl และ dashboard
  labels:  # ป้ายกำกับสำหรับการค้นหาและจัดกลุ่ม
    app: nuxt-app  # ป้ายกำกับ app ใช้เชื่อมโยงกับ Service ผ่าน selector
spec:  # รายละเอียดของ Deployment
  replicas: 2  # จำนวน Pod ที่ต้องการให้รันพร้อมกัน (2 = รัน 2 instance เพื่อ high availability)
  selector:  # ตัวเลือกที่ใช้ระบุว่า Pod ไหนอยู่ภายใต้ Deployment นี้
    matchLabels:  # จับคู่ Pod ที่มีป้ายกำกับตรงกับที่ระบุ
      app: nuxt-app  # ต้องตรงกับ labels ใน template.metadata.labels
  template:  # เทมเพลตสำหรับสร้าง Pod
    metadata:  # ข้อมูลเมตาดาต้าของ Pod
      labels:  # ป้ายกำกับของ Pod
        app: nuxt-app  # ป้ายกำกับนี้ต้องตรงกับ selector.matchLabels ข้างบน
    spec:  # รายละเอียดของ Pod
      containers:  # รายการของคอนเทนเนอร์ที่จะรันใน Pod
      - name: nuxt-app  # ชื่อของคอนเทนเนอร์
        image: nuxt-app:latest  # ใช้ local image สำหรับทดสอบบน Docker Desktop
        imagePullPolicy: IfNotPresent  # นโยบายการดึง image (IfNotPresent = ใช้ local ถ้ามี, ไม่ดึงใหม่)
        ports:  # พอร์ตที่เปิดให้ใช้งาน
        - containerPort: 3000  # พอร์ตที่แอปฟังอยู่ในคอนเทนเนอร์ (Nuxt รันบนพอร์ต 3000)
        resources:  # การจัดสรรทรัพยากร
          limits:  # ขีดจำกัดสูงสุดของทรัพยากรที่ใช้ได้
            cpu: "500m"  # 500 milli-cores = 0.5 CPU core
            memory: "512Mi"  # 512 MiB RAM
          requests:  # ทรัพยากรขั้นต่ำที่ต้องการ
            cpu: "200m"  # 200 milli-cores = 0.2 CPU core
            memory: "256Mi"  # 256 MiB RAM
        readinessProbe:  # การตรวจสอบว่า Pod พร้อมรับ traffic หรือยัง
          httpGet:  # ตรวจสอบโดยส่ง HTTP GET request
            path: /  # ไปที่ path / (หน้าหลัก)
            port: 3000  # บนพอร์ต 3000
          initialDelaySeconds: 10  # รอ 10 วินาทีหลังจากเริ่ม container ก่อนเริ่มตรวจสอบ
          periodSeconds: 5  # ตรวจสอบทุก 5 วินาที
        livenessProbe:  # การตรวจสอบว่า Pod ยังทำงานอยู่หรือไม่
          httpGet:  # ตรวจสอบโดยส่ง HTTP GET request
            path: /  # ไปที่ path / (หน้าหลัก)
            port: 3000  # บนพอร์ต 3000
          initialDelaySeconds: 15  # รอ 15 วินาทีหลังจากเริ่ม container ก่อนเริ่มตรวจสอบ
          periodSeconds: 10  # ตรวจสอบทุก 10 วินาที
```

### คำอธิบายสำคัญ

- **replicas: 2** - กำหนดให้รัน 2 instance ของแอป เพื่อความพร้อมใช้งานสูง (high availability)
- **selector และ labels** - ใช้เชื่อมโยง Deployment กับ Pod โดยใช้ label `app: nuxt-app`
- **resources** - กำหนดทรัพยากรที่ใช้ โดยขอ 0.2 CPU และ 256 MiB RAM ขั้นต่ำ และใช้สูงสุดไม่เกิน 0.5 CPU และ 512 MiB RAM
- **readinessProbe และ livenessProbe** - ตรวจสอบว่าแอปทำงานปกติหรือไม่ โดยส่ง HTTP GET request ไปที่ path / บนพอร์ต 3000

## 2. service.yaml

ไฟล์นี้กำหนดวิธีการเข้าถึง Pod ภายใน Kubernetes cluster

```yaml
apiVersion: v1  # เวอร์ชันของ API ที่ใช้ (v1 เป็นเวอร์ชันมาตรฐานสำหรับ Service)
kind: Service  # ประเภทของทรัพยากร Kubernetes (Service ใช้เพื่อเปิดให้เข้าถึง Pod ได้)
metadata:  # ข้อมูลเมตาดาต้าของ Service
  name: nuxt-app-service  # ชื่อของ Service ใช้อ้างอิงใน kubectl, dashboard และ Ingress
  labels:  # ป้ายกำกับสำหรับการค้นหาและจัดกลุ่ม
    app: nuxt-app  # ป้ายกำกับ app เพื่อระบุว่าเป็นส่วนของแอป nuxt-app
spec:  # รายละเอียดของ Service
  type: ClusterIP  # ประเภทของ Service (ClusterIP = ใช้ภายใน cluster เท่านั้น)
  ports:  # การกำหนดพอร์ต
  - port: 80  # พอร์ตที่เปิดให้บริการภายใน cluster (ใช้พอร์ต 80 เพื่อความสะดวก)
    targetPort: 3000  # พอร์ตของ Pod ที่ต้องการส่ง traffic ไปหา (ตรงกับ containerPort ใน deployment)
    protocol: TCP  # โปรโตคอลที่ใช้
    name: http  # ชื่อของพอร์ต (ใช้อ้างอิงใน Ingress)
  selector:  # ตัวเลือกที่ใช้ระบุว่า Pod ไหนที่ Service นี้จะส่ง traffic ไปให้
    app: nuxt-app  # เลือก Pod ที่มีป้ายกำกับ app=nuxt-app (ต้องตรงกับ labels ใน Pod)

---
apiVersion: v1
kind: Service
metadata:
  name: nuxt-app-nodeport
spec:
  type: NodePort
  ports:
  - name: http
    port: 80
    protocol: TCP
    targetPort: 3000
    nodePort: 31008
  selector:
    app: nuxt-app
```

### คำอธิบายสำคัญ

- **type: ClusterIP** - Service แบบ ClusterIP ใช้สำหรับการเข้าถึงภายใน cluster เท่านั้น
- **type: NodePort** - Service แบบ NodePort เปิดพอร์ตบนทุก Node ในคลัสเตอร์ (31008) ให้สามารถเข้าถึงจากภายนอกได้
- **port: 80, targetPort: 3000** - Service รับ traffic บนพอร์ต 80 และส่งต่อไปยังพอร์ต 3000 ของ Pod
- **selector: app: nuxt-app** - เลือก Pod ที่มีป้ายกำกับ app=nuxt-app เพื่อส่ง traffic ไปให้

## 3. ingress.yaml

ไฟล์นี้กำหนดวิธีการจัดการ traffic จากภายนอก cluster

```yaml
apiVersion: networking.k8s.io/v1  # เวอร์ชันของ API ที่ใช้ (networking.k8s.io/v1 เป็นเวอร์ชันมาตรฐานสำหรับ Ingress)
kind: Ingress  # ประเภทของทรัพยากร Kubernetes (Ingress ใช้จัดการ HTTP traffic จากภายนอก)
metadata:  # ข้อมูลเมตาดาต้าของ Ingress
  name: nuxt-app-ingress  # ชื่อของ Ingress ใช้อ้างอิงใน kubectl และ dashboard
  annotations:  # การกำหนดค่าพิเศษสำหรับ Ingress Controller
    nginx.ingress.kubernetes.io/rewrite-target: /  # เปลี่ยน path ที่เข้ามาเป็น / ก่อนส่งไปยัง service
    # ถ้าใช้ Cloudflare ควรเพิ่ม annotation นี้
    # nginx.ingress.kubernetes.io/ssl-redirect: "true"  # บังคับให้ใช้ HTTPS เท่านั้น
spec:  # รายละเอียดของ Ingress
  ingressClassName: nginx  # ระบุ IngressClass ที่จะใช้ (ต้องตรงกับ Ingress Controller ที่ติดตั้ง)
  rules:  # กฎการจัดการ traffic
  - host: nuxt-app.localhost  # โดเมนที่ใช้เข้าถึงแอป (ใช้ .localhost สำหรับทดสอบบนเครื่องท้องถิ่น)
    http:  # การจัดการ HTTP traffic
      paths:  # การกำหนด path ที่จะจัดการ
      - path: /  # path ที่จะจัดการ (ในที่นี้คือ root path /)
        pathType: Prefix  # ประเภทของ path (Prefix = จับทุก path ที่ขึ้นต้นด้วย /)
        backend:  # บริการที่จะส่ง traffic ไปให้
          service:  # กำหนด service ที่จะส่ง traffic ไปให้
            name: nuxt-app-service  # ชื่อของ service (ต้องตรงกับชื่อในไฟล์ service.yaml)
            port:  # พอร์ตที่จะส่ง traffic ไป
              number: 80  # หมายเลขพอร์ต (ต้องตรงกับ port ในไฟล์ service.yaml)
```

### คำอธิบายสำคัญ

- **ingressClassName: nginx** - ระบุว่าใช้ NGINX Ingress Controller
- **host: nuxt-app.localhost** - กำหนดโดเมนที่ใช้เข้าถึงแอป (ต้องเพิ่มในไฟล์ hosts)
- **path: /, pathType: Prefix** - จับทุก request ที่เริ่มต้นด้วย /
- **backend: service: name: nuxt-app-service, port: number: 80** - ส่ง traffic ไปยัง Service ชื่อ nuxt-app-service ที่พอร์ต 80

## 4. configmap.yaml

ไฟล์นี้ใช้เก็บค่าคอนฟิกของแอปที่ไม่ใช่ข้อมูลลับ

```yaml
apiVersion: v1  # เวอร์ชันของ API ที่ใช้ (v1 เป็นเวอร์ชันมาตรฐานสำหรับ ConfigMap)
kind: ConfigMap  # ประเภทของทรัพยากร Kubernetes (ConfigMap ใช้เก็บค่าคอนฟิกที่ไม่ใช่ข้อมูลลับ)
metadata:  # ข้อมูลเมตาดาต้าของ ConfigMap
  name: nuxt-app-config  # ชื่อของ ConfigMap ใช้อ้างอิงใน Pod
data:  # ข้อมูลที่จะเก็บใน ConfigMap
  NODE_ENV: "production"  # กำหนดสภาพแวดล้อมเป็น production
  API_BASE_URL: "https://api.example.com"  # URL ของ API ที่แอปจะเชื่อมต่อด้วย (เปลี่ยนเป็น URL ของ API ที่คุณใช้)
  # เพิ่มค่าคอนฟิกอื่นๆ ที่ต้องการตรงนี้
  # ตัวอย่างเช่น:
  # APP_TITLE: "HR Management System"
  # FEATURE_FLAGS: "{\"enableNewUI\": true, \"enableNotifications\": true}"
```

### คำอธิบายสำคัญ

- **name: nuxt-app-config** - ชื่อของ ConfigMap ที่จะใช้อ้างอิงใน Pod
- **data** - ข้อมูลที่จะเก็บใน ConfigMap ในรูปแบบ key-value
- **NODE_ENV: "production"** - กำหนดสภาพแวดล้อมเป็น production
- **API_BASE_URL: "https://api.example.com"** - URL ของ API ที่แอปจะเชื่อมต่อด้วย

## 5. kustomization.yaml

ไฟล์นี้ใช้รวมไฟล์ Kubernetes ทั้งหมดเข้าด้วยกัน

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1  # เวอร์ชันของ API ที่ใช้ (kustomize.config.k8s.io/v1beta1 เป็นเวอร์ชันมาตรฐานสำหรับ Kustomization)
kind: Kustomization  # ประเภทของทรัพยากร (Kustomization ใช้รวมไฟล์ Kubernetes ทั้งหมดเข้าด้วยกัน)

resources:  # รายการไฟล์ทรัพยากรที่จะรวมเข้าด้วยกัน
  - deployment.yaml  # ไฟล์ Deployment ที่กำหนดวิธีการ deploy แอป
  - service.yaml  # ไฟล์ Service ที่กำหนดการเข้าถึง Pod
  - ingress.yaml  # ไฟล์ Ingress ที่กำหนดการจัดการ traffic จากภายนอก
  - configmap.yaml  # ไฟล์ ConfigMap ที่กำหนดค่าคอนฟิกของแอป

commonLabels:  # ป้ายกำกับที่จะเพิ่มให้กับทุกทรัพยากร
  app: nuxt-app  # ป้ายกำกับ app เพื่อระบุว่าเป็นส่วนของแอป nuxt-app
  environment: production  # ป้ายกำกับ environment เพื่อระบุว่าเป็น production environment
```

### คำอธิบายสำคัญ

- **resources** - รายการไฟล์ทรัพยากรที่จะรวมเข้าด้วยกัน
- **commonLabels** - ป้ายกำกับที่จะเพิ่มให้กับทุกทรัพยากร

## การใช้งาน Secret (ถ้าจำเป็น)

ถ้าแอปของคุณต้องการข้อมูลที่เป็นความลับ เช่น API key หรือรหัสผ่าน ควรใช้ Secret แทน ConfigMap

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: nuxt-app-secrets
type: Opaque
data:
  API_KEY: <base64-encoded-api-key>
  DATABASE_PASSWORD: <base64-encoded-password>
```

### การสร้าง Secret

```bash
# แปลงข้อมูลเป็น base64
echo -n 'my-api-key' | base64

# สร้าง Secret จากไฟล์
kubectl create secret generic nuxt-app-secrets --from-file=./secrets.txt

# สร้าง Secret จากค่าโดยตรง
kubectl create secret generic nuxt-app-secrets --from-literal=API_KEY=my-api-key --from-literal=DATABASE_PASSWORD=my-password
```

### การใช้ Secret ใน Pod

```yaml
spec:
  containers:
  - name: nuxt-app
    image: nuxt-app:latest
    env:
    - name: API_KEY
      valueFrom:
        secretKeyRef:
          name: nuxt-app-secrets
          key: API_KEY
```

ในส่วนถัดไป เราจะดูเกี่ยวกับ [การทดสอบบน Docker Desktop](./k8s-guide-04-local-testing.md)
