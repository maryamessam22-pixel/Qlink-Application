import 'package:flutter/material.dart';

class AddProfileIdentityPage extends StatefulWidget {
  const AddProfileIdentityPage({super.key});

  @override
  State<AddProfileIdentityPage> createState() => _AddProfileIdentityPageState();
}

class _AddProfileIdentityPageState extends State<AddProfileIdentityPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Text('Add Profile Identity Page')),
    );
  }
}
