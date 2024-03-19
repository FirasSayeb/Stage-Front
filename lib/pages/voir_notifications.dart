
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

class VoirNotifications extends StatefulWidget {
  final String email;
  VoirNotifications(this.email);

  @override
  State<VoirNotifications> createState() => _VoirNotificationsState();
}

class _VoirNotificationsState extends State<VoirNotifications> {
   Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final response = await get(Uri.parse("http://10.0.2.2:8000/api/getNoti/${widget.email}"));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body)['list'];
        final List<Map<String, dynamic>> eleves = List<Map<String, dynamic>>.from(responseData);
        return eleves;
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load notifications');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voir Notifications'),
      ),
      body: Container(
        child: FutureBuilder<List<Map<String,dynamic>>>( 
                future: getNotifications(),
                builder: (context, snapshot) {   
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                           
                      return Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16.0),
                          title: Text("Body  : ${snapshot.data![index]["body"]}",
                            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                          subtitle:Text( 
                           "Envoyer en : ${snapshot.data![index]["created_at"]}" , 
                            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                          ) , 
                        ),
                      );   
                      },    
                    ); 
                  }
                },
              ),
      ),
    );
  }
}