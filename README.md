# 🚗 EV Charger Finder

A real-time, community-driven mobile application built with Flutter that helps electric vehicle drivers locate and check the availability of nearby charging stations. This project also includes a web-based admin panel for content moderation and management.

---

## ✨ Features

### Mobile App
- **📍 Live Map View:** Displays all nearby charging stations on an interactive Google Map with custom dark/light themes.
- **🟢 Dynamic Status Markers:** See the real-time availability of chargers at a glance with color-coded icons.
- **🔍 Search & Filter:** Instantly find stations by name or filter the map to show only currently available chargers.
- **🗺️ Get Directions:** Launch the native maps app to navigate directly to a selected charging station.
- **👤 User Authentication:** Secure login and registration system powered by Firebase Authentication.
- **🚗 Profile Management:** Users can save their vehicle information.
- **🤝 Community-Driven Updates:** Users can update the availability of charging ports in real-time and submit new station locations for review.
- **❤️ Social System:** A complete friends system with user search, friend requests, and a friends list.

### Web Admin Panel
- **🔐 Secure Admin Login:** A separate login portal accessible only to users with admin privileges.
- **📝 Station Moderation:** A dashboard to review, approve, or decline new charging stations submitted by users.
- **CI/CD Pipeline:** Automated checks for code formatting and analysis using GitHub Actions to ensure code quality across the entire project.

---

## 🛠️ Technology Stack

| Category      | Technology / Service                                 |
|---------------|------------------------------------------------------|
| **Framework** | [Flutter (for Mobile & Web)](https://flutter.dev/) 3.16+ |
| **Language**  | [Dart](https://dart.dev/)                            |
| **Backend**   | [Firebase](https://firebase.google.com/)             |
| **Database**  | [Cloud Firestore](https://firebase.google.com/products/firestore) (Real-time NoSQL) |
| **Auth**      | [Firebase Authentication](https://firebase.google.com/products/auth) |
| **Mapping**   | [Google Maps Platform](https://mapsplatform.google.com/) |
| **CI/CD**     | [GitHub Actions](https://github.com/features/actions) |

---

## 🚀 Getting Started

This project contains two applications: the main mobile app and a web admin panel.

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- A code editor like [VS Code](https://code.visualstudio.com/)
- A Firebase project with Firestore and Authentication enabled.

### Installation & Setup

1.  **Clone the repo:** `git clone https://github.com/your-username/EV-Charger-Finder.git`
2.  **Navigate to the project directory:** `cd EV-Charger-Finder`
3.  **Install packages:** `flutter pub get`
4.  **Configure Firebase:** Follow the [FlutterFire CLI documentation](https://firebase.google.com/docs/flutter/setup) to connect your Firebase project. This command will configure both the Android and Web apps.
    ```sh
    flutterfire configure
    ```
5.  **Add your Google Maps API Key**
    - Open `android/app/src/main/AndroidManifest.xml` and replace the placeholder with your API key:
    ```xml
    <meta-data android:name="com.google.android.geo.API_KEY"
               android:value="YOUR_API_KEY_HERE"/>
    ```

6.  **Run the app**
    ```sh
    flutter run
    ```

7. **Run the WebAdminPanel**
    ```sh
        flutter run -d chrome --target=lib/main_web.dart
---
## 📝 Project Phases



This project was developed iteratively through the following phases:

-   **Phase 1 (Complete):** Project Foundation and Basic Map Setup
-   **Phase 2 (Complete):** Location Awareness and User Centering
-   **Phase 3 (Complete):** Displaying Mock Data (Charger Markers)
-   **Phase 4 (Complete):** Interactive UI and Dynamic Markers
-   **Phase 5 (Complete):** Backend Integration with Firebase (Read-Only)
-   **Phase 6 (Complete):** User Authentication and Profile Management
-   **Phase 7 (Complete):** Implementing Real-Time Updates
-   **Phase 8 (Complete):** Adding Auxiliary Features ("About Us" Page)
-   **Phase 10 (Complete):** Essential User-Facing Features (Directions, Search & Filtering)
-   **Phase 11 (Complete):** Social and Community Features ("Friends" System)
-   **Phase 12 (Complete):** Advanced Features (Custom Map Styles & User Submissions)
-   **Phase 9 (Incomplete):** Web-Based Admin Panel

---

## 👥 Contributors

-   [Badrul](https://github.com/jerungpyro)
-   [Muhammad Sufyan](https://github.com/pyunk)
-   [Azwar Ansori](https://github.com/AzwarAns61)
-   [Wan Muhammad Azlan](https://github.com/Lannnzzz)