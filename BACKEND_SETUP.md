# Backend Kurulum ve Çalıştırma

Bu Flutter uygulaması, NestJS backend API'si ile çalışacak şekilde yapılandırılmıştır.

## Backend Kurulumu

### 1. Backend Projesini Klonlayın
```bash
git clone <backend-repo-url>
cd tennis-court-backend
```

### 2. Bağımlılıkları Yükleyin
```bash
npm install
```

### 3. Environment Değişkenlerini Ayarlayın
`.env` dosyası oluşturun:
```env
NODE_ENV=development
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USERNAME=tennis_user
DATABASE_PASSWORD=tennis_password
DATABASE_NAME=tennis_court_db
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
PORT=3000
```

### 4. Docker ile Veritabanını Çalıştırın
```bash
docker-compose up -d postgres pgadmin
```

### 5. Backend'i Çalıştırın
```bash
# Development mode
npm run start:dev

# Production mode
npm run build
npm run start:prod
```

## API Endpoints

### Authentication
- `POST /auth/register` - Kullanıcı kaydı
- `POST /auth/login` - Kullanıcı girişi
- `GET /auth/profile` - Kullanıcı profili
- `POST /auth/logout` - Kullanıcı çıkışı
- `POST /auth/refresh` - Token yenileme

### Users
- `GET /users` - Tüm kullanıcıları listele
- `GET /users/:id` - Belirli kullanıcıyı getir
- `PUT /users/:id` - Kullanıcı profilini güncelle

## Flutter Uygulaması Konfigürasyonu

Flutter uygulaması `lib/config/app_config.dart` dosyasında backend URL'ini yapılandırır:

```dart
static const String baseUrl = 'http://localhost:3000';
```

### Farklı Ortamlar İçin

#### Development (Local)
```dart
static const String baseUrl = 'http://localhost:3000';
```

#### Production
```dart
static const String baseUrl = 'https://your-api-domain.com';
```

#### Android Emulator
```dart
static const String baseUrl = 'http://10.0.2.2:3000';
```

#### iOS Simulator
```dart
static const String baseUrl = 'http://localhost:3000';
```

## Test Etme

1. Backend'i çalıştırın
2. Flutter uygulamasını çalıştırın
3. Yeni bir kullanıcı kaydı oluşturun
4. Giriş yapın ve çıkış yapın

## Sorun Giderme

### Bağlantı Hatası
- Backend'in çalıştığından emin olun
- Port 3000'in açık olduğunu kontrol edin
- Firewall ayarlarını kontrol edin

### CORS Hatası
- Backend'de CORS ayarlarının doğru yapılandırıldığından emin olun

### Database Hatası
- PostgreSQL'in çalıştığından emin olun
- Veritabanı bağlantı bilgilerini kontrol edin
