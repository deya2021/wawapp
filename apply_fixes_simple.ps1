$ErrorActionPreference='Stop'

$clientPath = "c:\\Users\\deye\\Documents\\wawapp\\apps\\wawapp_client"
$lib = Join-Path $clientPath "lib"
$featuresDir = Join-Path $lib "features"

# Create directories
New-Item -ItemType Directory -Force -Path "$featuresDir\\home","$featuresDir\\quote","$featuresDir\\track\\models","$lib\\core\\theme","$lib\\l10n" | Out-Null

# Create home screen
$homeFile = Join-Path $featuresDir "home\\home_screen.dart"
if(-not (Test-Path $homeFile)){
@'
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Welcome to WawApp', style: TextStyle(fontSize: 24))),
    );
  }
}
'@ | Out-File $homeFile -Encoding UTF8
}

# Create quote screen
$quoteFile = Join-Path $featuresDir "quote\\quote_screen.dart"
if(-not (Test-Path $quoteFile)){
@'
import 'package:flutter/material.dart';

class QuoteScreen extends StatelessWidget {
  const QuoteScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quote')),
      body: const Center(child: Text('Quote Screen')),
    );
  }
}
'@ | Out-File $quoteFile -Encoding UTF8
}

# Create order model
$orderFile = Join-Path $featuresDir "track\\models\\order.dart"
if(-not (Test-Path $orderFile)){
@'
class Order {
  final String id;
  final String userId;
  final String status;
  final double price;
  final double distanceKm;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.userId,
    required this.status,
    required this.price,
    required this.distanceKm,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'status': status,
    'price': price,
    'distanceKm': distanceKm,
    'createdAt': createdAt.toIso8601String(),
  };
}
'@ | Out-File $orderFile -Encoding UTF8
}

# Create theme
$themeFile = Join-Path $lib "core\\theme\\app_theme.dart"
if(-not (Test-Path $themeFile)){
@'
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF0A8F4D), brightness: Brightness.light),
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF0A8F4D), brightness: Brightness.dark),
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
  );
}
'@ | Out-File $themeFile -Encoding UTF8
}

# Create ARB files
$arbAR = Join-Path $lib "l10n\\intl_ar.arb"
if(-not (Test-Path $arbAR)){
'{"@@locale": "ar", "appTitle": "WawApp Client"}' | Out-File $arbAR -Encoding UTF8
}

$arbEN = Join-Path $lib "l10n\\intl_en.arb"
if(-not (Test-Path $arbEN)){
'{"@@locale": "en", "appTitle": "WawApp Client"}' | Out-File $arbEN -Encoding UTF8
}

Write-Host "✅ Core fixes applied successfully."
Write-Host "Next steps:"
Write-Host "1) flutter clean"
Write-Host "2) flutter pub get"
Write-Host "3) flutter run -v"