cd "$PSScriptRoot\..\apps\wawapp_client"
$env:PATH += ";$([Environment]::GetFolderPath('UserProfile'))\.pub-cache\bin"
dart pub global activate flutterfire_cli
$gradle = Get-Content "android\app\build.gradle" -Raw
if ($gradle -match 'applicationId\s+"([^"]+)"') { $APP_ID = $Matches[1] } else { Write-Host "No applicationId"; exit 1 }
flutterfire configure --project=wawapp-952d6 --platforms=android --android-package-name="$APP_ID" --out="lib/firebase_options.dart" --yes
flutter pub get
dart format .
flutter analyze
Write-Host "✅ Firebase configured and firebase_options.dart generated"