# Google OAuth 2.0 Kurulum Rehberi

Bu rehber, tenis kortu uygulamasında Google ile giriş yapma özelliğinin nasıl kurulacağını açıklar.

## Backend Kurulumu

### 1. Google Cloud Console'da Proje Oluşturma

1. [Google Cloud Console](https://console.cloud.google.com/)'a gidin
2. Yeni bir proje oluşturun veya mevcut projeyi seçin
3. "APIs & Services" > "Credentials" bölümüne gidin
4. "Create Credentials" > "OAuth 2.0 Client IDs" seçin

### 2. OAuth 2.0 Client ID Oluşturma

#### Web Application (Backend için)
1. Application type: "Web application" seçin
2. Name: "Tennis Court Backend" girin
3. Authorized redirect URIs ekleyin:
   - `http://localhost:3000/auth/google/callback` (development)
   - `https://yourdomain.com/auth/google/callback` (production)

#### Android Application (Flutter için)
1. Application type: "Android" seçin
2. Name: "Tennis Court Android" girin
3. Package name: `com.example.personal_project` girin
4. SHA-1 certificate fingerprint ekleyin (debug için):
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

#### iOS Application (Flutter için)
1. Application type: "iOS" seçin
2. Name: "Tennis Court iOS" girin
3. Bundle ID: `com.example.personal_project` girin

### 3. Environment Variables Ayarlama

Backend projesinde `.env` dosyası oluşturun:

```env
# Google OAuth
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
GOOGLE_CALLBACK_URL=http://localhost:3000/auth/google/callback

# Diğer environment variables...
DATABASE_URL=postgresql://username:password@localhost:5432/tennis_court_db
JWT_SECRET=your-super-secret-jwt-key-here
JWT_EXPIRES_IN=7d
PORT=3000
```

## Flutter Kurulumu

### 1. Android Konfigürasyonu

1. `android/app/build.gradle` dosyasında Google Services plugin'ini ekleyin:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

2. `android/build.gradle` dosyasında Google Services classpath'ini ekleyin:
   ```gradle
   dependencies {
       classpath 'com.google.gms:google-services:4.3.15'
   }
   ```

3. Google Console'dan `google-services.json` dosyasını indirin ve `android/app/` klasörüne yerleştirin

### 2. iOS Konfigürasyonu

1. Google Console'dan `GoogleService-Info.plist` dosyasını indirin
2. Xcode'da projeyi açın
3. `GoogleService-Info.plist` dosyasını `Runner` klasörüne sürükleyin
4. "Add to target" seçeneğini işaretleyin

### 3. iOS Info.plist Güncelleme

`ios/Runner/Info.plist` dosyasında URL scheme'i güncelleyin:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>google</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

`YOUR_CLIENT_ID` kısmını gerçek client ID ile değiştirin.

## Test Etme

### 1. Backend Test

```bash
cd tennis-court-backend
npm run start:dev
```

Backend çalıştıktan sonra:
- `http://localhost:3000/api` - Swagger dokümantasyonu
- `POST /auth/google` endpoint'ini test edin

### 2. Flutter Test

```bash
cd personal_project
flutter pub get
flutter run
```

Uygulamada "Google ile Giriş Yap" butonuna tıklayarak test edin.

## Sorun Giderme

### Yaygın Hatalar

1. **"Invalid client" hatası**: Client ID ve Secret'ın doğru olduğundan emin olun
2. **"Redirect URI mismatch" hatası**: Google Console'da redirect URI'ları kontrol edin
3. **iOS'da çalışmıyor**: Bundle ID ve URL scheme'i kontrol edin
4. **Android'de çalışmıyor**: SHA-1 fingerprint'i kontrol edin

### Debug İpuçları

1. Backend'de Google OAuth log'larını kontrol edin
2. Flutter'da console log'larını takip edin
3. Google Console'da OAuth consent screen'i yapılandırın
4. Test kullanıcıları ekleyin (development modunda)

## Güvenlik Notları

1. Production'da HTTPS kullanın
2. Client Secret'ı asla frontend'de kullanmayın
3. JWT token'ları güvenli şekilde saklayın
4. OAuth consent screen'i production için doğrulayın

## API Endpoints

### Backend Google Auth Endpoints

- `POST /auth/google` - Google ile giriş/kayıt
  ```json
  {
    "googleId": "string",
    "email": "string",
    "firstName": "string",
    "lastName": "string",
    "picture": "string"
  }
  ```

### Response Format

```json
{
  "success": true,
  "message": "Google ile giriş başarılı",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "name": "User Name",
    "role": "customer",
    "profileImageUrl": "https://..."
  },
  "token": "jwt-token"
}
```

Bu kurulum tamamlandıktan sonra kullanıcılar hem geleneksel e-posta/şifre ile hem de Google hesabı ile giriş yapabilirler.
