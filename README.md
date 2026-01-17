# 🧠 Brain Boost V2

**App di Riabilitazione Cognitiva Professionale**

[![Flutter](https://img.shields.io/badge/Flutter-3.35.4-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9.2-0175C2?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-Proprietary-red.svg)](LICENSE)

---

## 📋 Panoramica

**Brain Boost V2** è un'applicazione professionale di riabilitazione cognitiva progettata per anziani e pazienti con deficit cognitivi. L'app offre 7 giochi scientificamente validati per allenare memoria, attenzione, velocità di elaborazione e altre funzioni cognitive.

### ✨ Caratteristiche Principali

- 🎮 **7 Giochi Cognitivi Ottimizzati**
  - Memory Match (Memoria)
  - Stroop Test (Attenzione Selettiva)
  - Reaction Time (Velocità di Reazione)
  - Number Sequence (Memoria di Lavoro)
  - Pattern Recognition (Ragionamento)
  - Spatial Memory (Memoria Spaziale)
  - Word Association (Linguaggio)

- 📊 **Sistema Statistiche Avanzato**
  - Brain Boost Score (0-1000)
  - Tracking progressi 7 giorni
  - Grafici performance dettagliati
  - Sistema livelli e XP

- 🔄 **Database Multi-Dispositivo**
  - Hive local storage (veloce, offline-first)
  - Firebase Firestore sync (cloud backup)
  - Utilizzo su più dispositivi simultaneamente
  - Conservazione storico allenamenti completo

- 🎨 **UI Professionale**
  - Material Design 3
  - Accessibile per anziani
  - Responsive su tutti i dispositivi
  - Performance 60fps costanti

---

## 🚀 Demo Live

**Preview Web**: [https://brain-boost-v2.pages.dev](https://brain-boost-v2.pages.dev) *(coming soon)*

---

## 📱 Piattaforme Supportate

| Piattaforma | Stato | Note |
|-------------|-------|------|
| 🌐 **Web** | ✅ Production Ready | Ottimizzato per Chrome, Firefox, Safari, Edge |
| 🤖 **Android** | ✅ APK Ready | Minimo API 21 (Android 5.0+) |
| 🍎 **iOS** | 🚧 In Development | Richiede configurazione Firebase iOS |
| 💻 **Desktop** | ⏳ Planned | Windows, macOS, Linux |

---

## 🛠️ Tech Stack

### Frontend
- **Flutter** 3.35.4 - UI Framework
- **Dart** 3.9.2 - Programming Language
- **Provider** 6.1.5+1 - State Management
- **Material Design 3** - Design System

### Backend & Storage
- **Firebase Auth** 5.3.1 - Autenticazione utenti
- **Cloud Firestore** 5.4.3 - Database cloud
- **Hive** 2.2.3 - Local storage
- **Hive Flutter** 1.1.0 - Flutter integration

### UI & Charts
- **FL Chart** 0.70.1 - Grafici statistiche
- **Intl** 0.20.2 - Internazionalizzazione

### Export & Notifications
- **PDF** 3.11.1 - Export report PDF
- **CSV** 6.0.0 - Export dati
- **Flutter Local Notifications** 17.2.3 - Promemoria

---

## 📦 Installazione

### Prerequisiti

- Flutter SDK 3.35.4+
- Dart SDK 3.9.2+
- Android Studio / Xcode (per mobile)
- Firebase CLI (opzionale)

### Setup Progetto

```bash
# Clone repository
git clone https://github.com/medicagbsrl-ux/brain-boost-v2.git
cd brain-boost-v2

# Installa dipendenze
flutter pub get

# Verifica environment
flutter doctor -v

# Run su Web (development)
flutter run -d chrome

# Build per production
flutter build web --release
flutter build apk --release
```

---

## 🔧 Configurazione Firebase

### 1. Configurazione Android

Il file `google-services.json` è già configurato per il progetto Firebase `brain-boost-8821a`.

**Percorso**: `android/app/google-services.json`

### 2. Configurazione Web

Il file `firebase_options.dart` contiene le configurazioni per tutte le piattaforme.

**Percorso**: `lib/firebase_options.dart`

### 3. Regole Firestore

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Sessions collection
    match /sessions/{sessionId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## 🎮 Giochi Implementati

### 1. 🃏 Memory Match - Trova le Coppie
**Dominio Cognitivo**: Memoria  
**Livelli**: 1-10 (da 2x2 a 4x4 carte)  
**Metrica**: Precisione, tempo, tentativi

### 2. 🎨 Stroop Test - Attenzione Selettiva
**Dominio Cognitivo**: Attenzione  
**Livelli**: 1-10 (da 10 a 30 trial)  
**Metrica**: Tempo di reazione, precisione

### 3. ⚡ Reaction Time - Velocità di Reazione
**Dominio Cognitivo**: Velocità  
**Livelli**: 1-10  
**Metrica**: Tempo medio reazione (ms)

### 4. 🔢 Number Sequence - Memoria di Lavoro
**Dominio Cognitivo**: Memoria di Lavoro  
**Livelli**: 1-10 (da 3 a 12 cifre)  
**Metrica**: Sequenze corrette, precisione

### 5. 🧩 Pattern Recognition - Riconoscimento Pattern
**Dominio Cognitivo**: Ragionamento  
**Livelli**: 1-10  
**Metrica**: Pattern corretti, tempo

### 6. 📍 Spatial Memory - Memoria Spaziale
**Dominio Cognitivo**: Memoria Spaziale  
**Livelli**: 1-10 (da 3x3 a 6x6 grid)  
**Metrica**: Posizioni corrette, sequenze

### 7. 💬 Word Association - Associazioni di Parole
**Dominio Cognitivo**: Linguaggio  
**Livelli**: 1-10  
**Metrica**: Associazioni corrette, tempo

---

## 📊 Sistema Punteggi

### Brain Boost Score (0-1000)

Il punteggio complessivo viene calcolato in base alle performance in tutti i domini cognitivi:

```dart
Brain Boost Score = 
  (Memory × 0.25) + 
  (Attention × 0.20) + 
  (Executive × 0.20) + 
  (Speed × 0.15) + 
  (Language × 0.10) + 
  (Spatial × 0.10)
```

### Sistema Livelli

- **Livello 1-5**: Principiante (0-500 punti)
- **Livello 6-10**: Intermedio (500-1500 punti)
- **Livello 11-20**: Avanzato (1500-3000 punti)
- **Livello 21+**: Esperto (3000+ punti)

---

## 🏗️ Architettura

```
lib/
├── main.dart                 # Entry point
├── firebase_options.dart     # Firebase config
├── models/                   # Data models
│   ├── user_profile.dart
│   ├── session_history.dart
│   ├── assessment_result.dart
│   └── scheduled_session.dart
├── screens/                  # UI screens
│   ├── simple_login_screen.dart
│   ├── home_screen.dart
│   ├── profile_screen.dart
│   ├── progress_screen.dart
│   ├── calendar_screen.dart
│   └── ...
├── games/                    # Game modules
│   ├── memory_match/
│   ├── stroop_test/
│   ├── reaction_time/
│   ├── number_sequence/
│   ├── pattern_recognition/
│   ├── spatial_memory/
│   └── word_association/
├── services/                 # Business logic
│   ├── local_storage_service.dart
│   ├── firebase_sync_service.dart
│   ├── notification_service.dart
│   └── report_export_service.dart
├── providers/                # State management
│   └── user_profile_provider.dart
├── widgets/                  # Reusable widgets
│   ├── celebration_animation.dart
│   └── advanced_progress_charts.dart
└── themes/                   # App theming
    └── app_themes.dart
```

---

## 🔐 Privacy & Sicurezza

- ✅ **GDPR Compliant** - Dati utente criptati
- ✅ **Firebase Auth** - Autenticazione sicura
- ✅ **Local Storage** - PIN hashing SHA-256
- ✅ **Cloud Sync** - Firestore security rules
- ✅ **No Analytics Invasive** - Solo metriche anonime

---

## 🎯 Roadmap

### ✅ Fase 1: Foundation (COMPLETATA)
- [x] 7 giochi cognitivi responsive
- [x] Database multi-dispositivo
- [x] UI Material Design 3
- [x] Sistema statistiche e progressi
- [x] Deploy web production ready

### 🚧 Fase 2: Features Cliniche (In Sviluppo)
- [ ] Assessment cognitivo iniziale (MMSE-like)
- [ ] Report PDF professionali per medici
- [ ] Dashboard caregiver/medico
- [ ] Training adattivo basato su AI
- [ ] Sistema notifiche intelligente

### ⏳ Fase 3: Compliance & Validazione
- [ ] Certificazione dispositivo medico
- [ ] Pilot study con risultati scientifici
- [ ] Integrazione con piattaforma eCura
- [ ] Deploy su Google Play Store
- [ ] Deploy su Apple App Store

---

## 👥 Target Utenti

### Primari
- 👴 Anziani con declino cognitivo lieve
- 🧠 Pazienti con MCI (Mild Cognitive Impairment)
- 💪 Pazienti post-stroke o trauma cranico
- 👨‍⚕️ Centri di riabilitazione neurologica

### Secondari
- 👨‍👩‍👧 Caregiver familiari
- 🏥 Medici neurologi e geriatri
- 🏛️ RSA e case di riposo
- 📱 Utenti eCura (www.ecura.it)

---

## 🤝 Contributi

Questo è un progetto proprietario di **MedicaGB S.r.l.**

Per informazioni su licenze commerciali o partnership:
- 📧 Email: medicagbsrl@gmail.com
- 🌐 Website: www.ecura.it

---

## 📄 Licenza

Copyright © 2025 MedicaGB S.r.l. Tutti i diritti riservati.

Questo software è proprietario e confidenziale. Non è consentito l'uso, la copia, la modifica o la distribuzione senza autorizzazione esplicita scritta di MedicaGB S.r.l.

---

## 🙏 Riconoscimenti

- **Flutter Team** - Framework eccezionale
- **Firebase Team** - Backend affidabile
- **Material Design** - Design system professionale
- **Open Source Community** - Librerie e strumenti

---

## 📞 Supporto

Per supporto tecnico o domande:
- 📧 Email: medicagbsrl@gmail.com
- 🐛 Issues: [GitHub Issues](https://github.com/medicagbsrl-ux/brain-boost-v2/issues)

---

**Sviluppato con ❤️ da MedicaGB S.r.l. per migliorare la qualità di vita degli anziani**

---

*Versione: 2.0.0 | Data: Gennaio 2025 | Stato: Production Ready*
