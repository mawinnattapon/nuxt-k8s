# การแก้ไขปัญหา

การ deploy แอป Nuxt บน Kubernetes อาจพบปัญหาต่างๆ ได้ คู่มือนี้จะช่วยให้คุณแก้ไขปัญหาที่พบบ่อยได้อย่างมีประสิทธิภาพ

## ปัญหาที่พบบ่อยและวิธีแก้ไข

### 1. Pod ไม่ start หรือ crash

#### สาเหตุที่เป็นไปได้:
- Image ไม่ถูกต้องหรือไม่มีอยู่
- ทรัพยากรไม่เพียงพอ
- มีข้อผิดพลาดในแอป
- ConfigMap หรือ Secret ไม่ถูกต้อง

#### วิธีตรวจสอบ:
```bash
# ดูสถานะของ Pod
kubectl get pods

# ดูรายละเอียดของ Pod
kubectl describe pod <pod-name>

# ดู logs ของ Pod
kubectl logs <pod-name>
```

#### วิธีแก้ไข:
- ตรวจสอบว่า image มีอยู่จริง: `docker images`
- ตรวจสอบทรัพยากรที่ใช้: `kubectl describe node <node-name>`
- แก้ไขข้อผิดพลาดในแอป: ตรวจสอบ logs และแก้ไขโค้ด
- ตรวจสอบ ConfigMap และ Secret: `kubectl describe configmap/secret <name>`

### 2. Service ไม่ทำงาน

#### สาเหตุที่เป็นไปได้:
- selector ไม่ตรงกับ labels ของ Pod
- Pod ไม่ทำงาน
- พอร์ตไม่ถูกต้อง

#### วิธีตรวจสอบ:
```bash
# ดู endpoints ของ Service
kubectl get endpoints <service-name>

# ดู labels ของ Pod
kubectl get pods --show-labels

# ดูรายละเอียดของ Service
kubectl describe service <service-name>
```

#### วิธีแก้ไข:
- ตรวจสอบว่า selector ตรงกับ labels ของ Pod
- ตรวจสอบว่า Pod ทำงานปกติ
- ตรวจสอบว่าพอร์ตถูกต้อง

### 3. Ingress ไม่ทำงาน

#### สาเหตุที่เป็นไปได้:
- Ingress Controller ไม่ได้ติดตั้ง
- ingressClassName ไม่ถูกต้อง
- host ไม่ถูกต้อง
- Service ไม่ทำงาน
- ไม่ได้เพิ่ม host ในไฟล์ hosts

#### วิธีตรวจสอบ:
```bash
# ตรวจสอบว่า Ingress Controller ทำงานหรือไม่
kubectl get pods -n ingress-nginx

# ดู logs ของ Ingress Controller
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller

# ดูรายละเอียดของ Ingress
kubectl describe ingress <ingress-name>
```

#### วิธีแก้ไข:
- ติดตั้ง Ingress Controller: `kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml`
- เพิ่ม ingressClassName: `ingressClassName: nginx`
- ตรวจสอบว่า host ถูกต้อง
- ตรวจสอบว่า Service ทำงานปกติ
- เพิ่ม host ในไฟล์ hosts: `127.0.0.1 nuxt-app.localhost`

### 4. ปัญหาการเข้าถึงแอป

#### สาเหตุที่เป็นไปได้:
- แอปไม่ทำงานบนพอร์ตที่กำหนด
- readinessProbe หรือ livenessProbe ไม่ผ่าน
- ไฟร์วอลล์หรือ security group ปิดกั้น

#### วิธีตรวจสอบ:
```bash
# ทดสอบการเชื่อมต่อโดยตรงกับ Pod
kubectl port-forward <pod-name> 3000:3000

# ตรวจสอบ logs ของ Pod
kubectl logs <pod-name>

# ตรวจสอบสถานะของ Pod
kubectl describe pod <pod-name>
```

#### วิธีแก้ไข:
- ตรวจสอบว่าแอปทำงานบนพอร์ตที่ถูกต้อง
- ปรับแต่ง readinessProbe และ livenessProbe
- ตรวจสอบไฟร์วอลล์หรือ security group

### 5. ปัญหาการ Scale

#### สาเหตุที่เป็นไปได้:
- ทรัพยากรไม่เพียงพอ
- HPA ไม่ทำงาน
- metrics-server ไม่ได้ติดตั้ง

#### วิธีตรวจสอบ:
```bash
# ตรวจสอบสถานะของ HPA
kubectl get hpa

# ดูรายละเอียดของ HPA
kubectl describe hpa <hpa-name>

# ตรวจสอบว่า metrics-server ทำงานหรือไม่
kubectl get pods -n kube-system | grep metrics-server
```

#### วิธีแก้ไข:
- เพิ่มทรัพยากรให้กับ node
- ตรวจสอบการตั้งค่า HPA
- ติดตั้ง metrics-server: `kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml`

### 6. ปัญหาการอัปเดตแอป

#### สาเหตุที่เป็นไปได้:
- Image ใหม่ไม่ถูกต้อง
- imagePullPolicy ไม่ถูกต้อง
- ข้อผิดพลาดในแอปเวอร์ชันใหม่

#### วิธีตรวจสอบ:
```bash
# ตรวจสอบสถานะของ rollout
kubectl rollout status deployment/<deployment-name>

# ดูประวัติการ rollout
kubectl rollout history deployment/<deployment-name>

# ดูรายละเอียดของ revision
kubectl rollout history deployment/<deployment-name> --revision=<revision-number>
```

#### วิธีแก้ไข:
- ตรวจสอบว่า image ใหม่ถูกต้อง
- ตั้งค่า imagePullPolicy: Always เพื่อให้ดึง image ใหม่เสมอ
- ย้อนกลับไปเวอร์ชันก่อนหน้า: `kubectl rollout undo deployment/<deployment-name>`

## เทคนิคการแก้ไขปัญหาขั้นสูง

### 1. การใช้ Debug Container

```bash
# เพิ่ม debug container เข้าไปใน Pod ที่มีปัญหา
kubectl debug -it <pod-name> --image=busybox --target=<container-name>
```

### 2. การใช้ Network Policy

ถ้ามีปัญหาเกี่ยวกับการเชื่อมต่อระหว่าง Pods ให้ตรวจสอบ Network Policy:

```bash
# ดูรายการ Network Policy
kubectl get networkpolicy

# ดูรายละเอียดของ Network Policy
kubectl describe networkpolicy <policy-name>
```

### 3. การตรวจสอบ DNS

ถ้ามีปัญหาเกี่ยวกับ DNS:

```bash
# รัน Pod สำหรับทดสอบ DNS
kubectl run dnsutils --image=k8s.gcr.io/e2e-test-images/jessie-dnsutils:1.3 -- sleep 3600

# ทดสอบ DNS lookup
kubectl exec -it dnsutils -- nslookup <service-name>
```

### 4. การตรวจสอบ Storage

ถ้ามีปัญหาเกี่ยวกับ Persistent Volume:

```bash
# ดูรายการ PV และ PVC
kubectl get pv,pvc

# ดูรายละเอียดของ PV
kubectl describe pv <pv-name>

# ดูรายละเอียดของ PVC
kubectl describe pvc <pvc-name>
```

### 5. การตรวจสอบ RBAC

ถ้ามีปัญหาเกี่ยวกับสิทธิ์:

```bash
# ตรวจสอบว่า ServiceAccount มีสิทธิ์ที่จำเป็นหรือไม่
kubectl auth can-i <verb> <resource> --as=system:serviceaccount:<namespace>:<serviceaccount>
```

## ปัญหาเฉพาะของ Nuxt บน Kubernetes

### 1. Server-Side Rendering (SSR) ไม่ทำงาน

#### สาเหตุที่เป็นไปได้:
- ค่าคอนฟิก `ssr` ไม่ถูกต้อง
- ไม่มีการตั้งค่า `HOST` และ `PORT` ที่ถูกต้อง

#### วิธีแก้ไข:
- ตรวจสอบไฟล์ `nuxt.config.ts` ว่ามีการตั้งค่า `ssr: true`
- ตั้งค่า environment variables ใน Deployment:
  ```yaml
  env:
  - name: HOST
    value: "0.0.0.0"
  - name: PORT
    value: "3000"
  ```

### 2. Static Assets ไม่ทำงาน

#### สาเหตุที่เป็นไปได้:
- ไม่ได้ตั้งค่า `baseURL` ที่ถูกต้อง
- Ingress ไม่ได้ตั้งค่าให้จัดการ static assets

#### วิธีแก้ไข:
- ตั้งค่า `app.baseURL` ในไฟล์ `nuxt.config.ts`
- ตรวจสอบการตั้งค่า Ingress

### 3. API Calls ไม่ทำงาน

#### สาเหตุที่เป็นไปได้:
- CORS ไม่ได้ตั้งค่า
- API_BASE_URL ไม่ถูกต้อง
- Service ของ API ไม่ทำงาน

#### วิธีแก้ไข:
- ตั้งค่า CORS ใน API
- ตรวจสอบ API_BASE_URL ใน ConfigMap
- ตรวจสอบ Service ของ API

## ตัวอย่างการแก้ไขปัญหาจริง

### กรณีศึกษา 1: Ingress ไม่ทำงาน (404 Not Found)

**ปัญหา**: เข้า URL http://nuxt-app.localhost/ แล้วได้ 404 Not Found จาก nginx

**การแก้ไข**:
1. ตรวจสอบ logs ของ Ingress Controller:
   ```bash
   kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller
   ```

2. พบข้อความ: "Ignoring ingress because of error while validating ingress class" ingress="default/nuxt-app-ingress" error="ingress does not contain a valid IngressClass"

3. แก้ไขไฟล์ ingress.yaml เพื่อเพิ่ม ingressClassName:
   ```yaml
   spec:
     ingressClassName: nginx
     rules:
     ...
   ```

4. Apply การเปลี่ยนแปลง:
   ```bash
   kubectl apply -k k8s/
   ```

5. ตรวจสอบอีกครั้ง:
   ```bash
   kubectl get ingress
   ```

### กรณีศึกษา 2: Pod ไม่ start

**ปัญหา**: Pod ติดอยู่ในสถานะ `ImagePullBackOff`

**การแก้ไข**:
1. ตรวจสอบรายละเอียดของ Pod:
   ```bash
   kubectl describe pod <pod-name>
   ```

2. พบข้อความ: "Failed to pull image 'nuxt-app:latest': rpc error: code = Unknown desc = Error response from daemon: pull access denied for nuxt-app, repository does not exist or may require 'docker login'"

3. แก้ไขไฟล์ deployment.yaml เพื่อใช้ local image และตั้งค่า imagePullPolicy:
   ```yaml
   image: nuxt-app:latest
   imagePullPolicy: IfNotPresent
   ```

4. Build image ใหม่:
   ```bash
   docker build -t nuxt-app:latest -f Dockerfile .
   ```

5. Apply การเปลี่ยนแปลง:
   ```bash
   kubectl apply -k k8s/
   ```

6. ตรวจสอบอีกครั้ง:
   ```bash
   kubectl get pods
   ```

### กรณีศึกษา 3: แอปไม่ทำงานบนพอร์ตที่กำหนด

**ปัญหา**: แอปไม่ตอบสนองเมื่อเข้าถึงผ่าน Service

**การแก้ไข**:
1. ตรวจสอบ logs ของ Pod:
   ```bash
   kubectl logs <pod-name>
   ```

2. พบว่าแอปกำลังทำงานบนพอร์ต 8080 แทนที่จะเป็น 3000

3. แก้ไขไฟล์ Dockerfile เพื่อตั้งค่า PORT:
   ```dockerfile
   ENV PORT=3000
   ```

4. หรือแก้ไขไฟล์ deployment.yaml เพื่อตั้งค่า containerPort:
   ```yaml
   ports:
   - containerPort: 8080
   ```

5. แก้ไขไฟล์ service.yaml เพื่อตั้งค่า targetPort:
   ```yaml
   targetPort: 8080
   ```

6. Build image ใหม่และ apply การเปลี่ยนแปลง

## ข้อแนะนำเพื่อป้องกันปัญหา

1. **ใช้ Health Checks**: ตั้งค่า readinessProbe และ livenessProbe ให้เหมาะสม
2. **ตั้งค่า Resource Limits**: กำหนด requests และ limits ให้เหมาะสม
3. **ใช้ Version ที่แน่นอน**: ระบุ tag ที่เฉพาะเจาะจงสำหรับ image แทนการใช้ latest
4. **ทดสอบบนเครื่องท้องถิ่นก่อน**: ใช้ Docker Desktop หรือ Minikube เพื่อทดสอบก่อน deploy จริง
5. **ใช้ ConfigMap และ Secret**: แยกค่าคอนฟิกออกจากโค้ด
6. **ทำ CI/CD**: ใช้ GitLab CI/CD หรือ GitHub Actions เพื่อทดสอบและ deploy อัตโนมัติ
7. **ใช้ Helm Chart**: ใช้ Helm เพื่อจัดการการ deploy ที่ซับซ้อน
8. **ทำ Monitoring**: ติดตั้ง Prometheus และ Grafana เพื่อเฝ้าดูระบบ

## สรุป

การแก้ไขปัญหาใน Kubernetes ต้องอาศัยความเข้าใจในสถาปัตยกรรมและการทำงานของระบบ เครื่องมือสำคัญที่ช่วยในการแก้ไขปัญหาคือ `kubectl describe` และ `kubectl logs` ซึ่งจะให้ข้อมูลที่เป็นประโยชน์ในการวิเคราะห์ปัญหา

เมื่อพบปัญหา ให้ทำตามขั้นตอนต่อไปนี้:
1. ระบุว่าปัญหาเกิดที่ส่วนไหน (Pod, Service, Ingress, ฯลฯ)
2. ตรวจสอบสถานะและ logs
3. วิเคราะห์สาเหตุของปัญหา
4. แก้ไขปัญหาและทดสอบอีกครั้ง

ด้วยความเข้าใจที่ดีและเครื่องมือที่เหมาะสม คุณจะสามารถแก้ไขปัญหาที่เกิดขึ้นกับ Nuxt บน Kubernetes ได้อย่างมีประสิทธิภาพ
