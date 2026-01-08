import 'package:flutter/material.dart';

class SavedPage extends StatelessWidget {
  const SavedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: const Center(
        child: Text(
          'Saved Requests Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}