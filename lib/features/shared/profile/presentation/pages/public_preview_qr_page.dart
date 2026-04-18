import 'package:flutter/material.dart';
import 'package:q_link/core/state/app_state.dart';

class PublicPreviewQrPage extends StatelessWidget {
  final ProfileData profile;

  const PublicPreviewQrPage({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131B32), // Dark blue background
      body: const Center(
        child: Text('Public Preview QR Page', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
