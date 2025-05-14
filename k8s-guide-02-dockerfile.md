# Dockerfile และการ Build Image

## Dockerfile

Dockerfile ที่ใช้ในโปรเจคนี้ใช้เทคนิค multi-stage build เพื่อลดขนาดของ image สุดท้าย โดยแบ่งเป็น 2 stage:

```dockerfile
# Build stage
FROM node:20-alpine AS build

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

# Production stage
FROM node:20-alpine

WORKDIR /app

COPY --from=build /app/.output ./.output
COPY --from=build /app/package.json ./package.json

ENV HOST=0.0.0.0
ENV PORT=3000
ENV NODE_ENV=production

EXPOSE 3000

CMD ["node", ".output/server/index.mjs"]
```

### คำอธิบาย

#### Build Stage
- `FROM node:20-alpine AS build` - ใช้ Node.js 20 บน Alpine Linux เป็นฐาน และตั้งชื่อ stage นี้ว่า "build"
- `WORKDIR /app` - กำหนดโฟลเดอร์ทำงานเป็น /app
- `COPY package*.json ./` - คัดลอกไฟล์ package.json และ package-lock.json (ถ้ามี)
- `RUN npm install` - ติดตั้ง dependencies ทั้งหมด
- `COPY . .` - คัดลอกโค้ดทั้งหมดไปยัง image
- `RUN npm run build` - build แอป Nuxt

#### Production Stage
- `FROM node:20-alpine` - เริ่ม stage ใหม่โดยใช้ Node.js 20 บน Alpine Linux
- `WORKDIR /app` - กำหนดโฟลเดอร์ทำงานเป็น /app
- `COPY --from=build /app/.output ./.output` - คัดลอกเฉพาะไฟล์ที่ build แล้วจาก stage แรก
- `COPY --from=build /app/package.json ./package.json` - คัดลอก package.json จาก stage แรก
- `ENV HOST=0.0.0.0` - กำหนดให้แอปรับการเชื่อมต่อจากทุก IP
- `ENV PORT=3000` - กำหนดพอร์ตเป็น 3000
- `ENV NODE_ENV=production` - กำหนดโหมดเป็น production
- `EXPOSE 3000` - เปิดพอร์ต 3000
- `CMD ["node", ".output/server/index.mjs"]` - คำสั่งที่จะรันเมื่อ start container

## สคริปต์ Build และ Push

### build-push.ps1 (PowerShell สำหรับ Windows)

```powershell
# สคริปต์สำหรับ build และ push Docker image ไปยัง registry

# ตั้งค่าตัวแปร
$IMAGE_NAME = "nuxt-app"  # ชื่อของ Docker image
$IMAGE_TAG = "latest"  # แท็กของ Docker image (ควรใช้เวอร์ชันหรือ commit hash แทน latest ในการใช้งานจริง)
$REGISTRY = "your-registry.com"  # URL ของ registry (เปลี่ยนเป็น registry ของคุณ เช่น Docker Hub หรือ GitLab Container Registry)

# Build Docker image จาก Dockerfile ในโฟลเดอร์ปัจจุบัน
Write-Host "Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .  # คำสั่ง build image โดยใช้ชื่อและแท็กที่กำหนด

# Tag image เพื่อเตรียม push ไปยัง registry
Write-Host "Tagging image for registry: ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}  # เพิ่ม registry URL นำหน้าชื่อ image

# Push image ไปยัง registry
Write-Host "Pushing image to registry"
docker push ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}  # อัปโหลด image ไปยัง registry

Write-Host "Done!"  # แสดงข้อความเมื่อเสร็จสิ้น
```

### build-push.sh (Bash สำหรับ Linux/Mac)

```bash
#!/bin/bash

# ตั้งค่าตัวแปร
IMAGE_NAME="nuxt-app"
IMAGE_TAG="latest"
REGISTRY="your-registry.com"  # เปลี่ยนเป็น registry ของคุณ เช่น Docker Hub หรือ GitLab Container Registry

# Build Docker image
echo "Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .

# Tag image for registry
echo "Tagging image for registry: ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}

# Push to registry
echo "Pushing image to registry"
docker push ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}

echo "Done!"
```

## คำสั่ง Docker ที่ควรรู้

### การ Build Image

```bash
# Build image พื้นฐาน
docker build -t nuxt-app:latest .

# Build image โดยไม่ใช้ cache
docker build --no-cache -t nuxt-app:latest .

# Build image พร้อมกำหนด build args
docker build --build-arg NODE_ENV=production -t nuxt-app:latest .
```

### การจัดการ Image

```bash
# ดูรายการ image ทั้งหมด
docker images

# ลบ image
docker rmi nuxt-app:latest

# Tag image
docker tag nuxt-app:latest your-registry.com/nuxt-app:latest

# Push image ไปยัง registry
docker push your-registry.com/nuxt-app:latest
```

### การรัน Container

```bash
# รัน container จาก image
docker run -p 3000:3000 nuxt-app:latest

# รัน container ในโหมด detached (background)
docker run -d -p 3000:3000 nuxt-app:latest

# รัน container พร้อมกำหนด environment variables
docker run -d -p 3000:3000 -e NODE_ENV=production nuxt-app:latest
```

### การจัดการ Container

```bash
# ดูรายการ container ที่กำลังทำงาน
docker ps

# ดูรายการ container ทั้งหมด (รวมที่หยุดทำงานแล้ว)
docker ps -a

# หยุด container
docker stop <container-id>

# ลบ container
docker rm <container-id>

# ดู logs ของ container
docker logs <container-id>

# เข้าสู่ shell ของ container
docker exec -it <container-id> /bin/sh
```

## ข้อควรระวังและเทคนิค

1. **ใช้ .dockerignore** - สร้างไฟล์ .dockerignore เพื่อไม่ให้คัดลอกไฟล์ที่ไม่จำเป็น เช่น node_modules, .git
2. **ใช้ multi-stage build** - ช่วยลดขนาด image สุดท้าย
3. **ระบุ version ที่แน่นอน** - ใช้ tag ที่เฉพาะเจาะจง เช่น node:20.5.1-alpine แทน node:latest
4. **ไม่รัน container ด้วย root** - ควรสร้าง user ที่ไม่ใช่ root เพื่อความปลอดภัย
5. **ใช้ health check** - เพิ่ม HEALTHCHECK ใน Dockerfile เพื่อตรวจสอบว่า container ทำงานปกติ
6. **ตั้งค่า NODE_ENV=production** - ช่วยให้แอป Node.js ทำงานในโหมด production ซึ่งมีประสิทธิภาพสูงกว่า

ในส่วนถัดไป เราจะดูเกี่ยวกับ [Kubernetes Manifests](./k8s-guide-03-kubernetes-manifests.md)
