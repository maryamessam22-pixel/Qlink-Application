import 'package:flutter/material.dart';
import 'package:q_link/features/home/presentation/pages/home_page.dart'; // For VideoLogoWidget

class AddProfileIdentityPage extends StatefulWidget {
  const AddProfileIdentityPage({super.key});

  @override
  State<AddProfileIdentityPage> createState() => _AddProfileIdentityPageState();
}

class _AddProfileIdentityPageState extends State<AddProfileIdentityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Custom App Bar Header (Same as HomePage)
              Row(
                children: [
                  const VideoLogoWidget(),
                  const SizedBox(width: 8),
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.transparent,
                    backgroundImage: AssetImage('assets/images/mypic.png'),
                  ),
                  const Spacer(),
                  const Icon(Icons.language, color: Color(0xFF1E3A8A), size: 28),
                  const SizedBox(width: 16),
                  Stack(
                    children: [
                      const Icon(Icons.notifications_none, color: Color(0xFF1E3A8A), size: 28),
                      Positioned(
                        right: 2,
                        top: 2,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Cancel Button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(
                  children: [
                    Icon(Icons.arrow_back, color: Colors.grey.shade500, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              const Text(
                'Generate Patient Profile',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E3A8A), // Dark blue
                ),
              ),
              const SizedBox(height: 16),
              
              // Progress Bar
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A8A),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Step 1 of 3: Identity',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              const Divider(color: Color(0xFFE5E7EB), thickness: 1),
              const SizedBox(height: 24),
              
              _buildLabelAndTextField('Patient\'s Full Name', 'e.g., Mohamed Saber'),
              const SizedBox(height: 16),
              
              _buildLabelAndTextField('Relationship to You', 'e.g., Grandfather'),
              const SizedBox(height: 16),
              
              _buildLabelAndTextField('Birth Year', 'e.g., 1945'),
              const SizedBox(height: 16),
              
              _buildLabelAndTextField('EMERGENCY CONTACT * (Primary Guardian Phone)', 'e.g., 01119988299'),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabelAndTextField(String label, String hintText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E3A8A), // Dark blue
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
            ),
          ),
        ),
      ],
    );
  }
}
