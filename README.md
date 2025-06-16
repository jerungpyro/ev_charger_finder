# 🚗 EV Charger Finder

 
<!-- TODO: Replace with a GIF of your app in action. You can use a tool like ScreenToGif -->

A real-time, community-driven mobile application built with Flutter that helps electric vehicle drivers locate and check the availability of nearby charging stations.

---

## ✨ Features

- **📍 Live Map View:** Displays all nearby charging stations on an interactive Google Map.
- **🟢 Dynamic Status Markers:** See the real-time availability of chargers at a glance with color-coded icons (Green: Available, Orange: In Use, Red: Out of Order).
- **👤 User Authentication:** Secure login and registration system powered by Firebase Authentication.
- **🚗 Profile Management:** Users can save their vehicle information (model and registration number).
- **🤝 Community-Driven Updates:** Users can update the availability of charging ports in real-time, keeping the data fresh and reliable.
- **ℹ️ Detailed Information:** Tap on any station to view its address, provider, and a detailed breakdown of port availability.
- **CI/CD Pipeline:** Automated checks for code formatting and analysis using GitHub Actions to ensure code quality.

---

## 🛠️ Technology Stack

| Category      | Technology / Service                                 |
|---------------|------------------------------------------------------|
| **Framework** | [Flutter](https://flutter.dev/) 3.16+                |
| **Language**  | [Dart](https://dart.dev/)                            |
| **Backend**   | [Firebase](https://firebase.google.com/)             |
| **Database**  | [Cloud Firestore](https://firebase.google.com/products/firestore) (Real-time NoSQL) |
| **Auth**      | [Firebase Authentication](https://firebase.google.com/products/auth) |
| **Mapping**   | [Google Maps Platform](https://mapsplatform.google.com/) |
| **CI/CD**     | [GitHub Actions](https://github.com/features/actions) |

---

## 🚀 Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- A code editor like [VS Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio)
- A Firebase project with Firestore and Authentication enabled.

### Installation

1.  **Clone the repo**
    ```sh
    git clone https://github.com/your-username/EV-Charger-Finder.git
    ```

2.  **Navigate to the project directory**
    ```sh
    cd EV-Charger-Finder
    ```

3.  **Install packages**
    ```sh
    flutter pub get
    ```

4.  **Configure Firebase**
    - Follow the [FlutterFire CLI documentation](https://firebase.google.com/docs/flutter/setup) to connect your own Firebase project. This will generate a `firebase_options.dart` file.
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
-   **Phase 9 (Incomplete):** Web-Based Admin Panel
-   ... and more to come!

---

## 👥 Contributors

-   [Badrul](https://github.com/jerungpyro)
-   [Sufyan](https://github.com/pyunk)
-   [Azwar Ansori](https://github.com/AzwarAns61)
-   [Teammate 2's Name](https://github.com/teammate2-username)
