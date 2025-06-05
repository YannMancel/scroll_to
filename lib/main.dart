import 'package:flutter/material.dart';
import 'package:scroll_to/presentation/widgets/home_page.dart';

void main() => runApp(const MyApp());

const kAppName = 'Scroll To';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: kAppName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(title: kAppName),
    );
  }
}
