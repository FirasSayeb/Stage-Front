import 'package:flutter/material.dart';
import 'package:app/pages/Home.dart';
import 'package:app/pages/NotificationService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await NotificationService().initNotification(); 
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(),
  ));
}
