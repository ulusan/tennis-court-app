# 🎾 Tenis Kortu Rezervasyon Sistemi

Modern ve kullanıcı dostu tenis kortu rezervasyon uygulaması. Flutter ile geliştirilmiş, güzel animasyonlar ve kullanıcı deneyimi odaklı tasarım.

## ✨ Özellikler

### 🎯 Ana Özellikler
- **Kullanıcı Yönetimi**: Kayıt olma, giriş yapma, profil yönetimi
- **Kort Rezervasyonu**: Gerçek zamanlı müsaitlik kontrolü ve rezervasyon
- **Rezervasyon Yönetimi**: Aktif, geçmiş ve iptal edilen rezervasyonları görüntüleme
- **Modern UI/UX**: Material Design 3 ile tasarlanmış arayüz
- **Responsive Tasarım**: Tablet ve telefon uyumlu

### 🎨 Görsel Özellikler
- **Splash Screen**: Tenis temasına uygun animasyonlu açılış ekranı
- **Uçan Raketler**: Giriş ekranında arka planda uçan raket animasyonları
- **Gradient Tasarım**: Tenis yeşili tonlarında modern gradientler
- **Smooth Animasyonlar**: 60fps performansla akıcı geçişler
- **Custom Painters**: Özel tenis kortu, raket ve top çizimleri

### 📱 Platform Desteği
- **Android**: Tam destek
- **iOS**: Tam destek
- **Web**: Tam destek
- **Windows**: Tam destek
- **macOS**: Tam destek
- **Linux**: Tam destek

## 🚀 Kurulum

### Gereksinimler
- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Android Studio / VS Code
- Git

### Adımlar

1. **Repository'yi klonlayın**
```bash
git clone https://github.com/kullaniciadi/tenis-kortu-rezervasyon.git
cd tenis-kortu-rezervasyon
```

2. **Bağımlılıkları yükleyin**
```bash
flutter pub get
```

3. **Uygulamayı çalıştırın**
```bash
flutter run
```

## 🏗️ Proje Yapısı

```
lib/
├── config/                 # Uygulama konfigürasyonu
│   └── app_config.dart
├── models/                 # Veri modelleri
│   ├── auth_models.dart
│   ├── court.dart
│   ├── court_availability.dart
│   ├── reservation.dart
│   └── user.dart
├── providers/              # State management
│   ├── auth_provider.dart
│   ├── availability_provider.dart
│   ├── court_provider.dart
│   └── reservation_provider.dart
├── screens/                # Ekranlar
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── court_availability_screen.dart
│   ├── reservation_screen.dart
│   ├── my_reservations_screen.dart
│   └── profile_screen.dart
├── services/               # API servisleri
│   ├── api_service.dart
│   ├── auth_service.dart
│   ├── court_service.dart
│   └── reservation_service.dart
├── utils/                  # Yardımcı fonksiyonlar
│   ├── date_utils.dart
│   ├── name_blur.dart
│   ├── time_slot_generator.dart
│   └── toast.dart
├── widgets/                # Özel widget'lar
│   ├── auth_guard.dart
│   ├── court_card.dart
│   ├── court_map_widget.dart
│   ├── cancellation_dialog.dart
│   ├── flying_racket.dart
│   └── tennis_loading.dart
└── main.dart              # Ana dosya
```

## 🎨 Tasarım Sistemi

### Renk Paleti
- **Primary**: `#10B981` (Tenis Yeşili)
- **Secondary**: `#059669` (Koyu Yeşil)
- **Accent**: `#047857` (Orman Yeşili)
- **Background**: `#F8FAFC` (Açık Gri)
- **Surface**: `#FFFFFF` (Beyaz)

### Tipografi
- **Headline**: 32px, FontWeight.w800
- **Title**: 24px, FontWeight.w700
- **Body**: 16px, FontWeight.w500
- **Caption**: 14px, FontWeight.w500

## 🔧 Teknolojiler

- **Flutter**: 3.0+
- **Dart**: 3.0+
- **Provider**: State management
- **HTTP**: API iletişimi
- **Shared Preferences**: Yerel veri saklama
- **Custom Painters**: Özel çizimler
- **Animations**: Smooth geçişler

## 📱 Ekran Görüntüleri

### Splash Screen
- Tenis kortu arka planı
- Animasyonlu logo ve yazılar
- Uçan tenis topu ve raket

### Giriş Ekranı
- Uçan raket animasyonları
- Modern form tasarımı
- Gradient arka plan

### Ana Sayfa
- Kort listesi
- Modern kart tasarımı
- Responsive layout

### Rezervasyon
- Gerçek zamanlı müsaitlik
- Tarih ve saat seçimi
- Kolay rezervasyon işlemi

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit yapın (`git commit -m 'Add amazing feature'`)
4. Push yapın (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

## 👨‍💻 Geliştirici

**Emre**
- GitHub: [@kullaniciadi](https://github.com/kullaniciadi)
- Email: emre@example.com

## 🙏 Teşekkürler

- Flutter ekibine harika framework için
- Material Design ekibine tasarım sistemi için
- Açık kaynak topluluğuna katkıları için

---

⭐ Bu projeyi beğendiyseniz yıldız vermeyi unutmayın!