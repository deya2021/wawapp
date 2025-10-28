# ============================================================
# WawApp Client - Fetch Latest Version & Rebuild
# ============================================================

# 1️⃣ انتقل إلى مجلد المشروع الجذري
cd "C:\Users\deye\Documents\wawapp"

# إذا كان المشروع يحتوي مجلد root فاستخدمه، وإلا استعمل المجلد الحالي
if (Test-Path ".\root\.git") {
  cd ".\root"
}

# 2️⃣ جلب آخر التحديثات من GitHub
git fetch --all --prune
git checkout -B main origin/main
git pull --rebase origin main

# 3️⃣ صيانة سريعة للتطبيق (client)
if (Test-Path ".\apps\wawapp_client") {
  cd ".\apps\wawapp_client"
}

flutter clean
flutter pub get
dart format .
flutter analyze

# 4️⃣ تشغيل التطبيق للتأكد من نجاح التحديث
flutter run