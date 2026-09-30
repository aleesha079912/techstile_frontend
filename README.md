# TECHstile - Textile & Factory Management Mobile App

---

## ⚡ Getting Started

### Prerequisites
Make sure you have the following installed on your machine:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.9.2`)
- [Android Studio](https://developer.android.com/studio) / Xcode (for iOS)
- [VS Code](https://code.visualstudio.com/) with Flutter & Dart extensions
- Connected physical device or running Android/iOS Emulator

### Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/techstile_frontend.git
   cd techstile_frontend
   ```

2. **Install Flutter packages:**
   ```bash
   flutter pub get
   ```

3. **Configure Backend API Base URL:**
   Open `lib/core/services/auth_service.dart` and verify or update the backend endpoint:
   ```dart
   static const String baseUrl = "http://techstile.sandbox.pk/api"; // or your local API IP
   ```

4. **Run the App:**
   ```bash
   flutter run
   ```

---

## 📦 Build Instructions

### Android APK
```bash
flutter build apk --release
```
Output location: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (Play Store)
```bash
flutter build appbundle --release
```

### iOS (macOS required)
```bash
flutter build ipa --release
```

---

## 🔒 Authentication & Roles

The app automatically routes users after login based on their verified role:

- **`owner` / `admin`** ➔ Navigates to **Owner Dashboard**
- **`manager`** ➔ Navigates to **Manager Dashboard**
- **`employee` / `operator`** ➔ Navigates to **Employee Dashboard**

---

## 🤝 Contributing

1. Fork the project.
2. Create your feature branch (`git checkout -b feature/NewFeature`).
3. Commit your changes (`git checkout -b feature/NewFeature`).
4. Push to the branch (`git push origin feature/NewFeature`).
5. Open a Pull Request.

---

## 📄 License

This project is proprietary and confidential. Unauthorized copying, distribution, or modification is strictly prohibited.

