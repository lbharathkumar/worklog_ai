import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WorkLog AI'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to WorkLog AI'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Logic for starting a project will go here
              },
              child: Text('Start Project'),
            ),
          ],
        ),
      ),
    );
  }
}
