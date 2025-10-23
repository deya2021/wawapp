import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/home_screen.dart';
import '../../features/quote/quote_screen.dart';
import '../../features/track/track_screen.dart';
import '../../features/track/models/order.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/quote',
        name: 'quote',
        builder: (context, state) => const QuoteScreen(),
      ),
      GoRoute(
        path: '/track',
        name: 'track',
        builder: (context, state) => TrackScreen(order: state.extra as Order?),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});
