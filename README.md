# Origin CMMS

Origin CMMS is a comprehensive Computerized Maintenance Management System built on Atlas CMMS, customized and enhanced for production use.

## Features

- **Asset Management**: Track and manage all your assets with detailed information
- **Work Order Management**: Create, assign, and track work orders efficiently
- **Preventive Maintenance**: Schedule and manage preventive maintenance tasks
- **Inventory Management**: Manage parts, vendors, and purchase orders
- **Location Management**: Organize assets by location with hierarchical structure
- **Team Management**: Manage users, teams, and roles with granular permissions
- **Analytics & Reporting**: Comprehensive analytics for assets, work orders, and more
- **Mobile App**: React Native mobile application for on-the-go access
- **Multi-language Support**: Available in 10 languages (English, Arabic, French, German, Spanish, Italian, Polish, Portuguese, Swedish, Turkish)

## Technology Stack

### Backend
- **Framework**: Spring Boot 2.6.7
- **Database**: PostgreSQL
- **Storage**: MinIO / GCP Cloud Storage
- **Authentication**: JWT
- **API Documentation**: Swagger/OpenAPI

### Frontend
- **Framework**: React 18 with TypeScript
- **UI Library**: Material-UI (MUI)
- **State Management**: Redux Toolkit
- **Form Handling**: Formik + Yup
- **Routing**: React Router v6

### Mobile
- **Framework**: React Native with Expo
- **UI Library**: React Native Paper
- **State Management**: Redux Toolkit

## Quick Start

### Prerequisites
- Java 8 or higher
- Node.js 16 or higher
- PostgreSQL 12 or higher
- MinIO (for local development)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/YOUR_USERNAME/origin.cmms.git
cd origin.cmms
```

2. Set up environment variables:
```bash
cd cmms
cp .env.example .env
# Edit .env with your configuration
```

3. Start the services:
```bash
./start.sh
```

The application will be available at:
- Frontend: http://localhost:3000
- Backend API: http://localhost:8080
- MinIO Console: http://localhost:9001

## Customizations

This version includes the following customizations from the original Atlas CMMS:

- Custom branding (Powered by origin.app)
- Removed license restrictions
- Enhanced file upload limits (20MB)
- Custom logo support
- Cover image support for company profiles
- Removed documentation links
- Streamlined UI

## License

This project is based on Atlas CMMS and includes custom modifications.

## Support

For support and questions, please contact: zakee.tahawi@elkhawaga.com

---

**Powered by origin.app**

