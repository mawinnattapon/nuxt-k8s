# คำสั่ง Kubernetes ที่ควรรู้

คู่มือนี้รวบรวมคำสั่ง Kubernetes ที่ใช้บ่อยและจำเป็นต้องรู้สำหรับการจัดการแอป Nuxt บน Kubernetes

## คำสั่งพื้นฐาน

### การดูข้อมูล

```bash
# ดูข้อมูลของ cluster
kubectl cluster-info

# ดูรายการ nodes
kubectl get nodes

# ดูรายการ namespaces
kubectl get namespaces
```

### การจัดการ Namespace

```bash
# สร้าง namespace
kubectl create namespace <namespace-name>

# ลบ namespace
kubectl delete namespace <namespace-name>

# ตั้งค่า namespace เริ่มต้น
kubectl config set-context --current --namespace=<namespace-name>
```

## การจัดการ Pods

### การดูข้อมูล Pods

```bash
# ดูรายการ pods ทั้งหมด
kubectl get pods

# ดูรายการ pods พร้อมรายละเอียด
kubectl get pods -o wide

# ดูรายการ pods ตาม label
kubectl get pods -l app=nuxt-app

# ดูรายละเอียดของ pod
kubectl describe pod <pod-name>
```

### การจัดการ Pods

```bash
# สร้าง pod จากไฟล์ YAML
kubectl apply -f pod.yaml

# ลบ pod
kubectl delete pod <pod-name>

# ลบ pods ตาม label
kubectl delete pods -l app=nuxt-app

# ดู logs ของ pod
kubectl logs <pod-name>

# ดู logs แบบ follow
kubectl logs -f <pod-name>

# เข้าสู่ shell ของ pod
kubectl exec -it <pod-name> -- /bin/sh

# รัน command ใน pod
kubectl exec <pod-name> -- <command>

# คัดลอกไฟล์จาก pod
kubectl cp <pod-name>:/path/to/file /local/path

# คัดลอกไฟล์ไปยัง pod
kubectl cp /local/path <pod-name>:/path/to/file

# ดูการใช้ทรัพยากรของ pods
kubectl top pods
```

## การจัดการ Deployments

### การดูข้อมูล Deployments

```bash
# ดูรายการ deployments
kubectl get deployments

# ดูรายละเอียดของ deployment
kubectl describe deployment <deployment-name>

# ดูประวัติการ rollout
kubectl rollout history deployment/<deployment-name>
```

### การจัดการ Deployments

```bash
# สร้าง deployment จากไฟล์ YAML
kubectl apply -f deployment.yaml

# ลบ deployment
kubectl delete deployment <deployment-name>

# ปรับขนาด deployment (scaling)
kubectl scale deployment <deployment-name> --replicas=<number>

# ทำ rolling update
kubectl set image deployment/<deployment-name> <container-name>=<new-image>

# ย้อนกลับไปเวอร์ชันก่อนหน้า
kubectl rollout undo deployment/<deployment-name>

# ย้อนกลับไปเวอร์ชันที่ระบุ
kubectl rollout undo deployment/<deployment-name> --to-revision=<revision-number>

# หยุด rollout
kubectl rollout pause deployment/<deployment-name>

# ทำ rollout ต่อ
kubectl rollout resume deployment/<deployment-name>

# ตรวจสอบสถานะของ rollout
kubectl rollout status deployment/<deployment-name>
```

## การจัดการ Services

### การดูข้อมูล Services

```bash
# ดูรายการ services
kubectl get services

# ดูรายละเอียดของ service
kubectl describe service <service-name>

# ดู endpoints ของ service
kubectl get endpoints <service-name>
```

### การจัดการ Services

```bash
# สร้าง service จากไฟล์ YAML
kubectl apply -f service.yaml

# ลบ service
kubectl delete service <service-name>

# เปิด port-forward ไปยัง service
kubectl port-forward service/<service-name> <local-port>:<service-port>
```

## การจัดการ Ingress

### การดูข้อมูล Ingress

```bash
# ดูรายการ ingress
kubectl get ingress

# ดูรายละเอียดของ ingress
kubectl describe ingress <ingress-name>
```

### การจัดการ Ingress

```bash
# สร้าง ingress จากไฟล์ YAML
kubectl apply -f ingress.yaml

# ลบ ingress
kubectl delete ingress <ingress-name>
```

## การจัดการ ConfigMaps และ Secrets

### ConfigMaps

```bash
# ดูรายการ configmaps
kubectl get configmaps

# ดูรายละเอียดของ configmap
kubectl describe configmap <configmap-name>

# สร้าง configmap จากไฟล์
kubectl create configmap <configmap-name> --from-file=<file-path>

# สร้าง configmap จากค่าโดยตรง
kubectl create configmap <configmap-name> --from-literal=key1=value1 --from-literal=key2=value2
```

### Secrets

```bash
# ดูรายการ secrets
kubectl get secrets

# ดูรายละเอียดของ secret
kubectl describe secret <secret-name>

# สร้าง secret จากไฟล์
kubectl create secret generic <secret-name> --from-file=<file-path>

# สร้าง secret จากค่าโดยตรง
kubectl create secret generic <secret-name> --from-literal=key1=value1 --from-literal=key2=value2
```

## การใช้ Kustomize

```bash
# ดูตัวอย่าง resources ที่จะสร้าง
kubectl kustomize <directory>

# สร้าง resources
kubectl apply -k <directory>

# ลบ resources
kubectl delete -k <directory>
```

## การจัดการ Horizontal Pod Autoscaler (HPA)

```bash
# ดูรายการ HPAs
kubectl get hpa

# สร้าง HPA
kubectl autoscale deployment <deployment-name> --min=2 --max=5 --cpu-percent=80

# ลบ HPA
kubectl delete hpa <hpa-name>
```

## การตรวจสอบและแก้ไขปัญหา

```bash
# ตรวจสอบสถานะของ node
kubectl describe node <node-name>

# ตรวจสอบ events
kubectl get events

# ตรวจสอบ events แบบ sort ตามเวลา
kubectl get events --sort-by='.lastTimestamp'

# ดูการใช้ทรัพยากรของ node
kubectl top node

# ดูการใช้ทรัพยากรของ pod
kubectl top pod

# ตรวจสอบการเชื่อมต่อระหว่าง pods
kubectl exec <pod-name> -- curl -s http://<service-name>
```

## การใช้ kubectl ขั้นสูง

### Context และ Configuration

```bash
# ดูรายการ contexts
kubectl config get-contexts

# ดู context ปัจจุบัน
kubectl config current-context

# เปลี่ยน context
kubectl config use-context <context-name>

# ดูค่า config
kubectl config view
```

### การใช้ Labels และ Selectors

```bash
# ดู labels ของ resources
kubectl get pods --show-labels

# กรองด้วย label
kubectl get pods -l app=nuxt-app,environment=production

# เพิ่ม label
kubectl label pods <pod-name> key=value

# ลบ label
kubectl label pods <pod-name> key-
```

### การใช้ Annotations

```bash
# เพิ่ม annotation
kubectl annotate pods <pod-name> key=value

# ลบ annotation
kubectl annotate pods <pod-name> key-
```

### การใช้ JSONPath

```bash
# ดูเฉพาะชื่อของ pods
kubectl get pods -o jsonpath='{.items[*].metadata.name}'

# ดู IP ของ pods
kubectl get pods -o jsonpath='{.items[*].status.podIP}'
```

### การใช้ kubectl apply

```bash
# apply แบบ dry-run
kubectl apply -f <file.yaml> --dry-run=client

# apply พร้อมแสดงความแตกต่าง
kubectl apply -f <file.yaml> --server-side --force-conflicts --field-manager=kubectl-client-side-apply
```

## คำสั่งสำหรับ Nuxt บน Kubernetes

### การ Deploy Nuxt App

```bash
# Deploy ด้วย kustomize
kubectl apply -k k8s/

# ตรวจสอบสถานะของ deployment
kubectl get deployment nuxt-app

# ตรวจสอบ pods
kubectl get pods -l app=nuxt-app

# ดู logs ของ pods
kubectl logs -l app=nuxt-app
```

### การ Scale Nuxt App

```bash
# Scale แบบ manual
kubectl scale deployment nuxt-app --replicas=3

# ตั้งค่า autoscaling
kubectl autoscale deployment nuxt-app --min=2 --max=5 --cpu-percent=80
```

### การอัปเดต Nuxt App

```bash
# อัปเดต image
kubectl set image deployment/nuxt-app nuxt-app=nuxt-app:new-version

# ตรวจสอบสถานะการอัปเดต
kubectl rollout status deployment/nuxt-app

# ย้อนกลับหากมีปัญหา
kubectl rollout undo deployment/nuxt-app
```

### การเข้าถึง Nuxt App

```bash
# Port forward ไปยัง pod
kubectl port-forward $(kubectl get pod -l app=nuxt-app -o jsonpath='{.items[0].metadata.name}') 3000:3000

# Port forward ไปยัง service
kubectl port-forward service/nuxt-app-service 8080:80
```

ในส่วนถัดไป เราจะดูเกี่ยวกับ [การแก้ไขปัญหา](./k8s-guide-06-troubleshooting.md)
