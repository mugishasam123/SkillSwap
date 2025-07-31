# SkillSwap

SkillSwap is a Flutter-based mobile app that connects students and professionals to exchange skills in a peer-to-peer, barter-style marketplace. Users can offer their expertise, request help in areas they want to learn, and arrange real-time skill swap sessions.

---

## 🚀 Features

- **Authentication:** Secure sign up, login, and Google Sign-In using Firebase Auth.
- **Skill Discovery:** Browse all users and their offered/wanted skills in the "All" tab.
- **Profile Management:** Create and update your profile, including skills, bio, and avatar.
- **Skill Swaps:** Request, accept, and manage skill swap sessions with other users.
- **Forum:** Participate in discussions and replies to build community knowledge.
- **Messaging:** Real-time chat for swap coordination.
- **State Management:** Robust BLoC pattern for predictable, testable state.
- **Persistence:** User preferences (e.g., theme) stored with SharedPreferences.
- **Responsive UI:** Adapts to device orientation and input methods.
- **Validation:** User-friendly error handling and form validation.
- **Firebase Integration:** All data is stored and synced in real-time with Firestore.

---

## 🏗️ Architecture

- **Clean Architecture:**  
  - UI Layer (Pages, Widgets)
  - BLoC (Business Logic)
  - Repository (Data abstraction)
  - Data Source (Firebase, SharedPreferences)
- **Entity-Relationship Diagram (ERD):**
  - Users, Swaps, Discussions, Replies, Chats, Messages

---

## 📱 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- A Firebase project with Firestore and Authentication enabled

### Installation

1. **Clone the repository:**
   ```sh
   git clone https://github.com/mugishasam123/SkillSwap.git
   cd SkillSwap
   ```

2. **Install dependencies:**
   ```sh
   flutter pub get
   ```

3. **Configure Firebase:**
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) to the respective folders.
   - Update `firebase_options.dart` if needed.

4. **Run the app:**
   ```sh
   flutter run
   ```

---

## 🧪 Testing

- **Widget Tests:**
  ```sh
  flutter test
  ```
- **Integration Tests:**  
  (Set up with [integration_test](https://docs.flutter.dev/testing/integration-tests) for full end-to-end coverage.)

---

## 📦 Folder Structure

```
lib/
  app.dart
  main.dart
  core/
    services/
    theme/
    widgets/
  features/
    auth/
    forum/
    home/
    messages/
    onboarding/
    profile/
    swap/
  screens/
assets/
  fonts/
  images/
test/
```

---

## 🛠️ Contributing

1. Fork the repo
2. Create your feature branch (`git checkout -b feature/YourFeature`)
3. Commit your changes (`git commit -m 'Add some feature'`)
4. Push to the branch (`git push origin feature/YourFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License.

---

## 🙏 Acknowledgements

- Flutter & Dart teams
- Firebase
- Aaron Izang
- God'sfavour Chukwudi
- All contributors and testers

---

## 📱 Download

https://github.com/mugishasam123/SkillSwap/releases/download/v1.2/app-release.apk
