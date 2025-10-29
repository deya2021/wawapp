#requires -Version 5
param(
  [string]$ProjectPath = ".\apps\wawapp_client"
)
$ErrorActionPreference = "Stop"
$OUT = Join-Path $ProjectPath "doctor_report.txt"
New-Item -Force -ItemType Directory (Join-Path $ProjectPath "tools") | Out-Null
"=== WawApp Doctor (Windows) ===" | Out-File $OUT
function Run($cmd){ "`n> $cmd" | Tee-Object -FilePath $OUT -Append; iex $cmd 2>&1 | Tee-Object -FilePath $OUT -Append }
Push-Location $ProjectPath
Run 'flutter --version'
Run 'dart --version'
Run 'java -version'
Run 'gradle -v'
Run 'flutter doctor -v'
Run 'flutter pub deps --style=compact'
Run 'flutter analyze'
"== Android/Gradle Snapshot ==" | Tee-Object -FilePath $OUT -Append
Get-Content .\android\build.gradle -Raw | Tee-Object -FilePath $OUT -Append
Get-Content .\android\app\build.gradle -Raw | Tee-Object -FilePath $OUT -Append
(Get-Content .\android\gradle\wrapper\gradle-wrapper.properties -Raw) | Tee-Object -FilePath $OUT -Append
"== Firebase Files ==" | Tee-Object -FilePath $OUT -Append
Get-ChildItem -Recurse -Path android -Filter "google-services.json" | % { $_.FullName } | Tee-Object -FilePath $OUT -Append
"== AndroidManifest check ==" | Tee-Object -FilePath $OUT -Append
Select-String -Path ".\android\app\src\main\AndroidManifest.xml" -Pattern "ACCESS_FINE_LOCATION|ACCESS_COARSE_LOCATION|com.google.android.geo.API_KEY" -AllMatches | % { $_.Line } | Tee-Object -FilePath $OUT -Append
"== API keys duplication check ==" | Tee-Object -FilePath $OUT -Append
Select-String -Path ".\android\app\src\main\res\values\*.xml" -Pattern "google_maps_api_key" -AllMatches | % { $_.Path } | Sort-Object -Unique | Tee-Object -FilePath $OUT -Append
"== GoogleMap widget scan ==" | Tee-Object -FilePath $OUT -Append
Select-String -Path ".\lib\**\*.dart" -Pattern "GoogleMap|initialCameraPosition|onMapCreated|myLocationEnabled" -AllMatches | % { "$($_.Path): $($_.Line.Trim())" } | Tee-Object -FilePath $OUT -Append
"== Geolocator scan ==" | Tee-Object -FilePath $OUT -Append
Select-String -Path ".\lib\**\*.dart" -Pattern "Geolocator|openLocationSettings|openAppSettings|requestPermission" -AllMatches | % { "$($_.Path): $($_.Line.Trim())" } | Tee-Object -FilePath $OUT -Append
Run 'flutter clean'
Run 'flutter build apk --debug --no-shrink'
Pop-Location
"`n=== END ===" | Tee-Object -FilePath $OUT -Append
Write-Host "Report written to $OUT"