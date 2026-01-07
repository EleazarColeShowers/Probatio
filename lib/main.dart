import 'package:flutter/material.dart';
import 'shared/widgets/custombutton.dart';
import 'shared/widgets/customappbar.dart';
import 'shared/widgets/tabtext.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Probatio',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'API Client'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: CustomAppBar(
      title: widget.title,
    ),
    body: Column(
      children: [
        // 👇 your clickable words row
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TabText(text: 'Request', onTap: () {}),
              TabText(text: 'Saved', onTap: () {}),
              TabText(text: 'Collections', onTap: () {}),
            ],
          ),
        ),

        // rest of your screen
        Expanded(
          child: Center(
            child: CustomButton(
              text: 'Press Me',
              onPressed: _incrementCounter,
            ),
          ),
        ),
      ],
    ),
  );
}
}
