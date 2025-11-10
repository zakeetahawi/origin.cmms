# Atlas CMMS - Quick Start Guide

## البدء السريع | Quick Start

### الطريقة الأسهل (من المجلد الرئيسي):

```bash
cd /home/zakee/atlas/cmms

# لتشغيل المشروع:
./start.sh

# لإيقاف المشروع:
./stop.sh
```

### استخدام السكريبتات المتقدمة:

```bash
cd /home/zakee/atlas/cmms/scripts

# قائمة تفاعلية:
./start-all.sh

# فحص الإعدادات:
./test-setup.sh
```

## URLs

بعد التشغيل، يمكنك الوصول إلى:

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8080
- **API Documentation**: http://localhost:8080/swagger-ui/

## معلومات تسجيل الدخول الافتراضية

تحقق من قاعدة البيانات للحصول على بيانات المستخدمين الموجودين:

```sql
PGPASSWORD=5525 psql -h localhost -U rootuser -d atlas -c "SELECT email, role FROM users LIMIT 5;"
```

## المشاكل الشائعة وحلولها

### 1. PostgreSQL غير متصل
```bash
sudo systemctl start postgresql
```

### 2. المنفذ مستخدم بالفعل
```bash
# إيقاف الخدمة على المنفذ
./stop.sh
```

### 3. فشل تثبيت الحزم
```bash
# للـ Backend:
cd api && ./mvnw clean install -DskipTests

# للـ Frontend:
cd frontend && rm -rf node_modules && npm install
```

## ملاحظات

- قاعدة البيانات: PostgreSQL على المنفذ 5432
- المستخدم: rootuser
- كلمة المرور: 5525
- اسم قاعدة البيانات: atlas
- نوع التخزين: LOCAL (بدون MinIO)

## بنية المشروع

```
cmms/
├── api/           # Backend (Spring Boot)
├── frontend/      # Frontend (React)
├── scripts/       # سكريبتات متقدمة
├── start.sh       # تشغيل سريع
├── stop.sh        # إيقاف سريع
└── .env           # ملف الإعدادات
```
