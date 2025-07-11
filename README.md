![yo-offline-first drawio](https://github.com/user-attachments/assets/9c5b3fbc-32be-446d-9f0b-f949c0f12c1d)

# Flutter Notes Sync (Offline/Online with BLoC)

This Flutter project demonstrates a **note-taking app** with **offline-first** support using:

- `flutter_bloc` for state management
- `sqflite` for local storage
- REST API (built with Golang + JWT) for remote syncing
- `flutter_offline` for detecting network connectivity

Aplikasi ini menggunakan Flutter sebagai UI framework utama dan BLoC untuk manajemen state. Untuk deteksi koneksi jaringan, digunakan plugin connectivity_plus dan untuk mendukung mode offline, digunakan SQLite melalui paket sqflite. Data dicatat secara lokal, kemudian disinkronisasi ke server REST API berbasis Golang ~(Gin)~ dengan autentikasi JWT dan penyimpanan data menggunakan MySQL. Aplikasi ini mendukung sinkronisasi otomatis maupun manual saat perangkat kembali online.

---

## 🚀 Getting Started

### 1. Clone the Flutter project

```bash
git clone https://github.com/yogithesymbian/yo-simple-notes-offline-online-auto-sync.git
cd flutter_notes_sync_bloc
```

### 2. Install Flutter packages

```bash
flutter pub get
```

### 3. Run the app

```bash
flutter run
```

Make sure to have your emulator/device running.

---

## 🔐 Authentication

To obtain an access token, make a POST request to the login endpoint:

```bash
curl  -X POST \
  'https://yo-simple-notes-railways-production.up.railway.app/login' \
  --header 'Content-Type: application/json' \
  --data-raw '{
    "username": "admin",
    "password": "admin123"
}'
```

Response will contain a JWT token. **Replace this token** in:

```dart
// lib/services/note_service.dart
headers: {
  'Content-Type': 'application/json',
  'Authorization': '<PUT_YOUR_JWT_TOKEN_HERE>'
},
```

```dart
// lib/services/note_service.dart
http://192.168.43.5:8080
replace all with:
https://yo-simple-notes-railways-production.up.railway.app
```

---

## ✨ Features

- ✅ Add, update, delete notes
- ✅ Mark notes as done/undone
- ✅ Save notes locally using SQLite (offline-first)
- ✅ Sync to remote server (if online)
- ✅ Auto-sync when internet comes back online
- ✅ Manual "Sync Now" button

---

## 🛠️ Folder Structure

```
lib/
├── bloc/             # BLoC state management
├── models/           # Note model
├── services/         # NoteService (SQLite + API)
├── pages/            # UI screens (HomePage)
```

---

## 🧠 Backend (Golang)

- The backend is built with Golang, uses MySQL, and supports JWT auth
- Endpoints:

  - `POST /login`
  - `GET /notes`
  - `POST /notes`
  - `PATCH /notes/:id`
  - `DELETE /notes/:id`

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.6
  flutter_offline: ^3.0.1
  sqflite: ^2.3.2
  path_provider: ^2.1.1
  http: ^0.13.6
```

---

## 📣 Notes

- Make sure the backend server is **accessible** from your emulator/device
- If you're testing on a physical Android device, use IP (e.g. `192.168.x.x`) instead of `localhost`
- Database persistence will survive hot restart, but **not full rebuild** if you're using in-memory DB

---

## 📌 Coming Soon

- [ ] Form to add/edit notes
- [ ] Undo delete
- [ ] Search and filter notes
- [ ] prevent duplicate on refetchFromServer

![WhatsApp Image 2025-07-07 at 2 26 29 PM](https://github.com/user-attachments/assets/3ee5b12b-5ee1-4070-ba3f-8bc9d988df83)
