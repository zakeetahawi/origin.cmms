# Origin CMMS - Local Setup Guide (Without Docker)

## المتطلبات الأساسية | Prerequisites

تأكد من تثبيت البرامج التالية:
- **Java 8** أو أعلى
- **Node.js 14** أو أعلى
- **PostgreSQL 12** أو أعلى
- **Git**

## الإعداد السريع | Quick Setup

### 1. تكوين البيئة | Environment Configuration

```bash
# نسخ ملف البيئة
cp .env.example .env

# تحرير الملف وتعديل الإعدادات الضرورية
nano .env
```

الإعدادات المهمة في `.env`:
- `POSTGRES_USER`: اسم مستخدم قاعدة البيانات
- `POSTGRES_PWD`: كلمة مرور قاعدة البيانات
- `JWT_SECRET_KEY`: مفتاح سري عشوائي للـ JWT
- `PUBLIC_API_URL`: عنوان URL للـ Backend (افتراضي: http://localhost:8080)
- `PUBLIC_FRONT_URL`: عنوان URL للـ Frontend (افتراضي: http://localhost:3000)

### 2. إعداد قاعدة البيانات | Database Setup

```bash
cd scripts
./setup-db.sh
```

### 3. تشغيل المشروع | Start the Project

#### الطريقة السهلة (قائمة تفاعلية):
```bash
cd scripts
./start-all.sh
```

اختر من القائمة:
- **1**: إعداد قاعدة البيانات (مرة واحدة فقط)
- **2**: تشغيل Backend فقط
- **3**: تشغيل Frontend فقط
- **4**: تشغيل كل شيء (Backend + Frontend)
- **5**: تشغيل مع MinIO للتخزين المحلي
- **6**: إيقاف جميع الخدمات
- **7**: فحص حالة الخدمات

#### أو تشغيل الخدمات منفردة:

**Backend:**
```bash
cd scripts
./run-backend.sh
```

**Frontend (في terminal آخر):**
```bash
cd scripts
./run-frontend.sh
```

### 4. الوصول للتطبيق | Access the Application

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8080
- **API Documentation**: http://localhost:8080/swagger-ui/
- **MinIO Console** (إذا مفعل): http://localhost:9001

### 5. إيقاف الخدمات | Stop Services

```bash
cd scripts
./stop-all.sh
```

## الأوامر المفيدة | Useful Commands

### Backend (Java/Spring Boot)

```bash
# تشغيل في وضع التطوير
cd api
./mvnw spring-boot:run

# بناء المشروع
./mvnw clean package

# تشغيل الاختبارات
./mvnw test
```

### Frontend (React)

```bash
# تثبيت الحزم
cd frontend
npm install

# تشغيل في وضع التطوير
npm start

# بناء للإنتاج
npm run build

# تشغيل الاختبارات
npm test
```

## حل المشاكل | Troubleshooting

### مشكلة الاتصال بقاعدة البيانات

```bash
# التحقق من PostgreSQL
sudo systemctl status postgresql

# إعادة تشغيل PostgreSQL
sudo systemctl restart postgresql

# اختبار الاتصال
psql -h localhost -U rootUser -d origin
```

### المنافذ مستخدمة بالفعل

```bash
# إيجاد العملية على منفذ معين
lsof -i :8080
lsof -i :3000

# إيقاف العملية
kill -9 <PID>
```

### مشاكل Maven

```bash
# حذف الملفات المؤقتة وإعادة البناء
cd api
rm -rf target
./mvnw clean install
```

### مشاكل Node/NPM

```bash
# حذف node_modules وإعادة التثبيت
cd frontend
rm -rf node_modules package-lock.json
npm install
```

## ملاحظات إضافية | Additional Notes

### استخدام MinIO للتخزين المحلي

إذا كنت تريد استخدام MinIO بدلاً من Google Cloud Storage:

1. تعديل `.env`:
```bash
STORAGE_TYPE=MINIO
MINIO_USER=minio
MINIO_PASSWORD=minio123
```

2. MinIO سيعمل تلقائياً عند اختيار الخيار 5 في `start-all.sh`

### تفعيل الإشعارات بالبريد الإلكتروني

تعديل `.env`:
```bash
ENABLE_EMAIL_NOTIFICATIONS=true
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PWD=your-app-password
```

### الوصول لسجلات التطبيق | Application Logs

```bash
# Backend logs
tail -f backend.log

# MinIO logs
tail -f minio.log

# Frontend logs (تظهر في terminal)
```

## البنية التقنية | Technology Stack

- **Backend**: Spring Boot 2.6.7, Java 8, PostgreSQL
- **Frontend**: React 17, Material-UI 5, TypeScript
- **Storage**: MinIO / Google Cloud Storage
- **Database Migrations**: Liquibase
- **Build Tools**: Maven (Backend), NPM (Frontend)

## المساعدة | Help

في حالة وجود مشاكل:
1. تأكد من تثبيت جميع المتطلبات
2. راجع ملف `.env` والتأكد من صحة الإعدادات
3. تحقق من السجلات (logs) للحصول على تفاصيل الأخطاء
4. أعد تشغيل جميع الخدمات باستخدام `./stop-all.sh` ثم `./start-all.sh`
