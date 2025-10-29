import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

Widget authBadge() {
  final user = FirebaseAuth.instance.currentUser;
  final short = user?.uid.substring(0, 6) ?? 'none';
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.redAccent,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text('anon:$short', style: const TextStyle(color: Colors.white)),
  );
}
