# Eco_Warrior — Smart Waste Management & Recycling App

An offline-first, highly scalable application built for Smart Waste Management. Developed with Flutter, Riverpod, and Hive.

## Features
* **Waste Logging**: Log organic, plastic, and e-waste easily. Data stored locally.
* **Pickup Scheduling**: Automatic geolocation approximation and UI scheduling.
* **Rewards & Gamification**: Earn points for logging waste and redeem them for community deals.
* **Dashboard Analytics**: Real-time insights powered by Clean Architecture and Hive backend.
* **Beautiful UI**: Material 3 theming (Dark & Light Mode).

## Tech Stack
* **Framework**: Flutter (Dart)
* **State Management**: flutter_riverpod
* **Local Database**: Hive (Simulated Cloud Sync)
* **Routing**: Go_Router

## Running the Project
1. Clone this repository.
2. Run `flutter pub get`.
3. Run `dart run build_runner build --delete-conflicting-outputs`
4. Run `flutter run`.

## Structure
- `/lib/core` -> Theming, Routes
- `/lib/data` -> Hive Models, Setup
- `/lib/domain` -> Business constraints
- `/lib/presentation` -> Riverpod Providers & Pages
