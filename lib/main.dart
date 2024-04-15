import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:app/pages/Home.dart';
import 'package:app/pages/NotificationService.dart';

void main() async { 
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid ?  
  await Firebase.initializeApp( 
    options: const FirebaseOptions(apiKey:"AIzaSyAusdpI9iXcm4N5mqiZcBysfJTYws_wMaI" , appId:"1:968028605824:android:5cdd68fdb5be3a9b3a0565" , messagingSenderId:"968028605824" , projectId:"flutterapp-91de5" )
  ):await Firebase.initializeApp(); 
  await NotificationService().initNotification();  
  runApp(const MaterialApp(   
    debugShowCheckedModeBanner: false,   
    home: Home(),      
  )); 
}
