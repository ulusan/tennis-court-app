# Google Client ID Alma ve Kurulum Rehberi

Bu rehber, Google Cloud Console'dan Client ID almanız ve projelerinizde kullanmanız için adım adım talimatlar içerir.

## 1. Google Cloud Console'da Proje Oluşturma

### Adım 1: Google Cloud Console'a Giriş
1. [Google Cloud Console](https://console.cloud.google.com/) adresine gidin
2. Google hesabınızla giriş yapın
3. Eğer daha önce proje oluşturmadıysanız, "Select a project" ekranında "NEW PROJECT" butonuna tıklayın

### Adım 2: Yeni Proje Oluşturma
1. **Project name**: "Tennis Court App" yazın
2. **Organization**: Kendi organizasyonunuzu seçin (eğer varsa)
3. **Location**: Uygun konumu seçin
4. **CREATE** butonuna tıklayın
5. Proje oluşturulana kadar bekleyin (1-2 dakika)

## 2. Google APIs & Services Ayarları

### Adım 1: APIs & Services'e Gitme
1. Sol menüden **"APIs & Services"** seçin
2. **"Overview"** sayfasına gidin

### Adım 2: OAuth Consent Screen Ayarlama
1. **"OAuth consent screen"** sekmesine tıklayın
2. **"External"** seçeneğini seçin (geliştirme için)
3. **"CREATE"** butonuna tıklayın

#### OAuth Consent Screen Bilgileri:
```
App name: Tennis Court Reservation
User support email: your-email@gmail.com
Developer contact information: your-email@gmail.com
``` 

4. **"SAVE AND CONTINUE"** butonuna tıklayın
5. **"Scopes"** sayfasında **"ADD OR REMOVE SCOPES"** butonuna tıklayın
6. Aşağıdaki scope'ları ekleyin:
   - `../auth/userinfo.email`
   - `../auth/userinfo.profile`
   - `openid`
7. **"UPDATE"** butonuna tıklayın
8. **"SAVE AND CONTINUE"** butonuna tıklayın
9. **"Test users"** sayfasında kendi e-posta adresinizi ekleyin
10. **"SAVE AND CONTINUE"** butonuna tıklayın

## 3. OAuth 2.0 Client ID Oluşturma

### Adım 1: Credentials Sayfasına Gitme
1. **"APIs & Services"** > **"Credentials"** sekmesine gidin
2. **"+ CREATE CREDENTIALS"** butonuna tıklayın
3. **"OAuth 2.0 Client IDs"** seçin

### Adım 2: Web Application Client ID (Backend için)
1. **Application type**: **"Web application"** seçin
2. **Name**: "Tennis Court Backend" yazın
3. **Authorized redirect URIs** bölümüne şunları ekleyin:
   ```
   http://localhost:3000/auth/google/callback
   http://localhost:3000/auth/google/callback
   ```
4. **"CREATE"** butonuna tıklayın
5. **Client ID** ve **Client Secret**'ı kopyalayın ve güvenli bir yere kaydedin

### Adım 3: Android Client ID (Flutter için)
1. **"+ CREATE CREDENTIALS"** > **"OAuth 2.0 Client IDs"** seçin
2. **Application type**: **"Android"** seçin
3. **Name**: "Tennis Court Android" yazın
4. **Package name**: `com.example.personal_project` yazın
5. **SHA-1 certificate fingerprint** için:
   
   **Windows için:**
   ```bash
   keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
   ```
   
   **Mac/Linux için:**
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
   
   Çıktıdan SHA-1 değerini kopyalayın ve bu alana yapıştırın
6. **"CREATE"** butonuna tıklayın

### Adım 4: iOS Client ID (Flutter için)
1. **"+ CREATE CREDENTIALS"** > **"OAuth 2.0 Client IDs"** seçin
2. **Application type**: **"iOS"** seçin
3. **Name**: "Tennis Court iOS" yazın
4. **Bundle ID**: `com.example.personal_project` yazın
5. **"CREATE"** butonuna tıklayın

## 4. Backend Konfigürasyonu

### Adım 1: Environment Variables Dosyası Oluşturma
Backend projesinde `.env` dosyası oluşturun:

```env
# Database
DATABASE_URL=postgresql://username:password@localhost:5432/tennis_court_db

# JWT
JWT_SECRET=your-super-secret-jwt-key-here-make-it-long-and-random
JWT_EXPIRES_IN=7d

# Google OAuth (Web Application Client ID'den alınacak)
GOOGLE_CLIENT_ID=your-web-client-id-here.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-web-client-secret-here
GOOGLE_CALLBACK_URL=http://localhost:3000/auth/google/callback

# Server
PORT=3000
NODE_ENV=development
```

### Adım 2: Backend Test
```bash
cd tennis-court-backend
npm install
npm run start:dev
```

## 5. Flutter Konfigürasyonu

### Adım 1: Android Konfigürasyonu

1. **google-services.json dosyası indirme:**
   - Google Cloud Console > APIs & Services > Credentials
   - Android Client ID'nin yanındaki **download** butonuna tıklayın
   - İndirilen `google-services.json` dosyasını `android/app/` klasörüne kopyalayın

2. **android/build.gradle güncelleme:**
   ```gradle
   buildscript {
       dependencies {
           classpath 'com.google.gms:google-services:4.3.15'
       }
   }
   ```

3. **android/app/build.gradle güncelleme:**
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

### Adım 2: iOS Konfigürasyonu

1. **GoogleService-Info.plist dosyası indirme:**
   - Google Cloud Console > APIs & Services > Credentials
   - iOS Client ID'nin yanındaki **download** butonuna tıklayın
   - İndirilen `GoogleService-Info.plist` dosyasını `ios/Runner/` klasörüne kopyalayın

2. **ios/Runner/Info.plist güncelleme:**
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleURLName</key>
           <string>google</string>
           <key>CFBundleURLSchemes</key>
           <array>
               <string>com.googleusercontent.apps.YOUR_ANDROID_CLIENT_ID</string>
           </array>
       </dict>
   </array>
   ```

   `YOUR_ANDROID_CLIENT_ID` kısmını Android Client ID ile değiştirin.

## 6. Test Etme

### Backend Test:
```bash
# Backend'i başlatın
npm run start:dev

# Swagger'da test edin
http://localhost:3000/api
```

### Flutter Test:
```bash
# Flutter uygulamasını başlatın
flutter pub get
flutter run

# Google ile giriş butonuna tıklayın
```

## 7. Yaygın Hatalar ve Çözümleri

### "Invalid client" Hatası:
- Client ID ve Secret'ın doğru kopyalandığından emin olun
- .env dosyasında boşluk olmadığından emin olun

### "Redirect URI mismatch" Hatası:
- Google Console'da redirect URI'ları kontrol edin
- Tam URL'yi kullandığınızdan emin olun

### "Package name mismatch" Hatası (Android):
- android/app/build.gradle'daki applicationId'yi kontrol edin
- Google Console'daki package name ile eşleştiğinden emin olun

### "Bundle ID mismatch" Hatası (iOS):
- iOS projesindeki Bundle ID'yi kontrol edin
- Google Console'daki Bundle ID ile eşleştiğinden emin olun

## 8. Production için Ek Ayarlar

### OAuth Consent Screen Verification:
1. Google Cloud Console > APIs & Services > OAuth consent screen
2. **"Publish app"** butonuna tıklayın
3. Google'ın onay sürecini bekleyin (1-7 gün)

### HTTPS Kullanımı:
- Production'da HTTPS kullanın
- Redirect URI'ları HTTPS ile güncelleyin

### Domain Verification:
- Production domain'inizi Google Console'da verify edin

Bu adımları takip ettikten sonra Google ile giriş özelliği tamamen çalışır hale gelecektir! 🎾✨
