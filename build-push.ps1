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
