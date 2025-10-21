# WawApp Monorepo

## Structure
```
root/
├── apps/
│   ├── wawapp_client/     # Flutter client app
│   └── wawapp_driver/     # Flutter driver app
├── functions/             # Firebase Cloud Functions v2 (Node 18+)
├── admin_web/            # Next.js/React admin panel
└── docs/                 # Documentation
```

## Development

### Prerequisites
- Flutter 3.35.5+
- Node.js 18+
- JDK 17
- Android Studio with AGP 8.7.0+

### Scripts
```bash
# Flutter apps
cd apps/wawapp_client && flutter run
cd apps/wawapp_driver && flutter run

# Firebase functions
cd functions && npm run serve

# Admin web
cd admin_web && npm run dev
```

### Setup
1. Install Flutter dependencies: `flutter pub get` in each app
2. Install Node dependencies: `npm install` in functions/admin_web
3. Configure Firebase project
4. Set up Android/iOS development environment