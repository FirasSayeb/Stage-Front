import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:app/pages/Home.dart';
import 'package:app/pages/NotificationService.dart';

void main() async { 
  WidgetsFlutterBinding.ensureInitialized();
 // Platform.isAndroid ?        
  await Firebase.initializeApp( 
    options: const FirebaseOptions(apiKey:"" , appId:"" , messagingSenderId:"" , projectId:"" )
  );  
  //:await Firebase.initializeApp(); 
 // await NotificationService().initNotification();    
  runApp(const MaterialApp(   
    debugShowCheckedModeBanner: false,    
    home: Home(),        
  ));  
}
   