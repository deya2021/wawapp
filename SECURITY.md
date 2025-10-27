# إرشادات الأمان

## الملفات الحساسة المحمية

### ✅ محمية في .gitignore:
- `google-services.json`
- `firebase_options.dart`
- `GoogleService-Info.plist`
- `api_keys.dart`
- `.env`
- `android.keystore`

### 🔧 إعداد مفاتيح API:

1. **انسخ الملفات المثال:**
   ```bash
   cp .env.example .env
   cp apps/wawapp_client/lib/config/api_keys.dart.example apps/wawapp_client/lib/config/api_keys.dart
   ```

2. **أضف مفاتيحك الحقيقية في الملفات المنسوخة**

3. **لا ترفع أبداً:**
   - مفاتيح API الحقيقية
   - ملفات Firebase الأصلية
   - ملفات الشهادات
   - كلمات المرور

### 🚨 في حالة رفع مفتاح بالخطأ:
1. ألغِ المفتاح فوراً من Google Cloud Console
2. أنشئ مفتاح جديد
3. احذف التاريخ من Git إذا لزم الأمر

### 📝 للفريق:
- استخدم متغيرات البيئة للمفاتيح
- شارك المفاتيح بطريقة آمنة (لا عبر Git)
- راجع .gitignore قبل أي commit