# 🚀 Hızlı Google OAuth Kurulum Rehberi

## ⚡ 5 Dakikada Google Client ID Alma

### 1️⃣ Google Cloud Console'a Git
```
https://console.cloud.google.com/
```

### 2️⃣ Yeni Proje Oluştur
- **Project name**: `Tennis Court App`
- **CREATE** butonuna tıkla

### 3️⃣ OAuth Consent Screen Ayarla
- **APIs & Services** > **OAuth consent screen**
- **External** seç
- **App name**: `Tennis Court`
- **User support email**: Kendi email'in
- **SAVE AND CONTINUE** (3 kez)

### 4️⃣ Client ID Oluştur

#### Backend için (Web Application):
- **Credentials** > **+ CREATE CREDENTIALS** > **OAuth 2.0 Client IDs**
- **Application type**: `Web application`
- **Name**: `Backend`
- **Authorized redirect URIs**: 
  ```
  http://localhost:3000/auth/google/callback
  ```
- **CREATE** → Client ID ve Secret'ı kopyala

#### Flutter için (Android):
- **+ CREATE CREDENTIALS** > **OAuth 2.0 Client IDs**
- **Application type**: `Android`
- **Name**: `Flutter Android`
- **Package name**: `com.example.personal_project`
- **SHA-1 fingerprint**: Aşağıdaki komutu çalıştır:

```bash
# Windows
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android

# Mac/Linux
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

- SHA-1 değerini kopyala ve yapıştır
- **CREATE** → Client ID'yi kopyala

### 5️⃣ Dosyaları Güncelle

#### Backend (.env dosyası):
```env
GOOGLE_CLIENT_ID=your-web-client-id-here.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-web-client-secret-here
GOOGLE_CALLBACK_URL=http://localhost:3000/auth/google/callback
```

#### Flutter iOS (ios/Runner/Info.plist):
```xml
<key>CFBundleURLSchemes</key>
<array>
    <string>com.googleusercontent.apps.YOUR_ANDROID_CLIENT_ID</string>
</array>
```

### 6️⃣ Test Et
```bash
# Backend
cd tennis-court-backend
npm run start:dev

# Flutter
flutter pub get
flutter run
```

## 🎯 Önemli Notlar

- **Client ID'leri güvenli tutun**
- **Test kullanıcısı olarak kendi email'ini ekle**
- **SHA-1 fingerprint'i doğru al**
- **Package name'ler eşleşmeli**

## 🆘 Hızlı Çözümler

### "Invalid client" hatası:
- Client ID'yi yeniden kopyala
- .env dosyasında boşluk yok mu kontrol et

### "Redirect URI mismatch":
- Google Console'da tam URL'yi kullan
- `http://localhost:3000/auth/google/callback`

### "Package name mismatch":
- `android/app/build.gradle`'da `applicationId` kontrol et
- Google Console'daki ile aynı olmalı

Bu adımları takip edersen 5 dakikada Google OAuth'u çalıştırabilirsin! 🎾
