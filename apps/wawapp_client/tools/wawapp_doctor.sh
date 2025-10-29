#!/usr/bin/env bash
set -euo pipefail
PROJECT_PATH="${1:-./apps/wawapp_client}"
OUT="$PROJECT_PATH/doctor_report.txt"
echo "=== WawApp Doctor (Unix) ===" > "$OUT"
run(){ echo -e "\n> $*" | tee -a "$OUT"; bash -lc "$*" 2>&1 | tee -a "$OUT"; }
pushd "$PROJECT_PATH" >/dev/null
run "flutter --version"
run "dart --version"
run "java -version || true"
run "gradle -v || true"
run "flutter doctor -v"
run "flutter pub deps --style=compact"
run "flutter analyze"
echo "== Android/Gradle Snapshot ==" | tee -a "$OUT"
cat android/build.gradle >> "$OUT" || true
cat android/app/build.gradle >> "$OUT" || true
cat android/gradle/wrapper/gradle-wrapper.properties >> "$OUT" || true
echo "== Firebase Files ==" | tee -a "$OUT"
find android -name "google-services.json" -print | tee -a "$OUT"
echo "== AndroidManifest check ==" | tee -a "$OUT"
grep -E "ACCESS_FINE_LOCATION|ACCESS_COARSE_LOCATION|com.google.android.geo.API_KEY" android/app/src/main/AndroidManifest.xml | tee -a "$OUT" || true
echo "== API keys duplication check ==" | tee -a "$OUT"
grep -Rl "google_maps_api_key" android/app/src/main/res/values | tee -a "$OUT" || true
echo "== GoogleMap widget scan ==" | tee -a "$OUT"
grep -RInE "GoogleMap|initialCameraPosition|onMapCreated|myLocationEnabled" lib | tee -a "$OUT" || true
echo "== Geolocator scan ==" | tee -a "$OUT"
grep -RInE "Geolocator|openLocationSettings|openAppSettings|requestPermission" lib | tee -a "$OUT" || true
run "flutter clean"
run "flutter build apk --debug --no-shrink"
popd >/dev/null
echo -e "\n=== END ===" | tee -a "$OUT"
echo "Report written to $OUT"