# 🚗 EV Charger Finder



A full-stack, real-time, community-driven mobile application built with Flutter that helps electric vehicle drivers locate and check the availability of nearby charging stations. This project also includes a comprehensive web-based admin panel for complete application management.

---

## ✨ Features

### 📱 Mobile Application (for Users)
- **Live Map & Theming:** Displays all nearby charging stations on an interactive Google Map with custom, theme-aware dark and light styles.
- **Real-Time Status:** View charger availability at a glance with dynamic, color-coded markers that update in real-time for all users.
- **Advanced Search & Filtering:** Instantly find stations by name and filter the map to show only currently available chargers.
- **Turn-by-Turn Directions:** Integrates with the phone's native maps app to provide navigation directly to a selected charging station.
- **User-Generated Content:**
  - **Station Submissions:** Users can submit new, unlisted charging stations for admin approval.
  - **Reviews & Ratings:** Leave a star rating and a text comment for any station, helping other users make informed decisions.
- **User Authentication & Profiles:** Secure login/registration system powered by Firebase Authentication. Users can manage their profile and vehicle information.
- **Social System:** A complete friends system with user search, friend requests, a friends list, and the ability to remove friends.

### 🌐 Web Admin Panel (for Administrators)
- **Secure Admin Portal:** A separate web application with a login screen that only grants access to users with admin privileges.
- **Station Moderation Queue:** A dashboard to review, approve, or decline new charging stations submitted by users. Approved stations instantly appear on the mobile app map.
- **Full CRUD Management:**
  - **Stations:** Create, read, update, and delete live charging station data directly.
  - **Users:** View all registered users, manage their profiles, and grant/revoke admin privileges or disable accounts.
  - **Reviews:** View a centralized list of all reviews across all stations and delete inappropriate or spam content.

### ⚙️ Development & CI/CD
- **Automated Workflow:** A GitHub Actions pipeline automatically checks code formatting, runs static analysis, and builds the Android app on every push and pull request to the `main` branch.

---

## 📸 Screenshots

| Login Screen | Map View (Dark) | Station Details |
| :---: | :---: | :---: |
| |  |  |

| Profile Screen | Friends System | Web Admin Panel |
| :---: | :---: | :---: |
|  |  |  |


---

## 🛠️ Technology Stack

| Category      | Technology / Service                                 |
|---------------|------------------------------------------------------|
| **Framework** | [Flutter (for Mobile & Web)](https://flutter.dev/)   |
| **Language**  | [Dart](https://dart.dev/)                            |
| **Backend**   | [Firebase](https://firebase.google.com/)             |
| **Database**  | [Cloud Firestore](https://firebase.google.com/products/firestore) |
| **Auth**      | [Firebase Authentication](https://firebase.google.com/products/auth) |
| **Mapping**   | [Google Maps Platform](https://mapsplatform.google.com/) |
| **CI/CD**     | [GitHub Actions](https://github.com/features/actions) |

---

## 🚀 Getting Started

This project contains two applications: the main mobile app and a web admin panel.

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (Version 3.16+)
- A code editor like [VS Code](https://code.visualstudio.com/)
- A Firebase project with Firestore and Authentication enabled.

### Installation & Setup

1.  **Clone the repo:**
    ```sh
    git clone https://github.com/your-username/EV-Charger-Finder.git
    ```

2.  **Navigate to the project directory:**
    ```sh
    cd EV-Charger-Finder
    ```

3.  **Install packages:**
    ```sh
    flutter pub get
    ```

4.  **Configure Firebase:**
    - Follow the [FlutterFire CLI documentation](https://firebase.google.com/docs/flutter/setup) to connect your Firebase project. This command will configure both the Android and Web apps.
    ```sh
    flutterfire configure
    ```

5.  **Set Up Admin User:**
    - In your Firestore `users` collection, find the user document for the account you want to be an admin.
    - Add a new field: `isAdmin` (Type: `boolean`) and set its value to `true`.

6.  **Add your Google Maps API Key:**
    - Open `android/app/src/main/AndroidManifest.xml` and replace the placeholder with your API key.

7.  **Run the Mobile App**
    This will use the default `lib/main.dart` entry point.
    ```sh
    flutter run

8. **Run the WebAdminPanel**
    ```sh
    flutter run -d chrome --target=lib/main_web.dart

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
-   **Phase 9 (Complete):** Web-Based Admin Panel (including Station/User/Review Management)
-   **Phase 10 (Complete):** Essential User-Facing Features (Directions, Search & Filtering)
-   **Phase 11 (Complete):** Social and Community Features ("Friends" System)
-   **Phase 12 (Complete):** Advanced Features (Custom Map Styles & User Submissions)

---

## 👥 Contributors

-   [Badrul](https://github.com/jerungpyro)
-   [Muhammad Sufyan](https://github.com/pyunk)
-   [Azwar Ansori](https://github.com/AzwarAns61)
-   [Wan Muhammad Azlan](https://github.com/Lannnzzz)