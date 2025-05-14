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
