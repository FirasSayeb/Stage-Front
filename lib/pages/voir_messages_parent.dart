
import 'dart:convert';
import 'package:app/pages/ajouter_message.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';

class VoirMessagesP extends StatefulWidget {
  final String email;
  VoirMessagesP(this.email);

  @override
  State<VoirMessagesP> createState() => _VoirNotificationsState();
}

class _VoirNotificationsState extends State<VoirMessagesP> {
   Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final response = await get(Uri.parse("https://firas.alwaysdata.net/api/getNoti/${widget.email}"));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body)['list'];
        final List<Map<String, dynamic>> eleves = List<Map<String, dynamic>>.from(responseData);
        return eleves;
      } else {
        throw Exception('Échec du chargement des notifications');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Échec du chargement des notifications');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('consulter messages'),
         backgroundColor: Color.fromARGB(255, 4, 166, 235),
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
                                        leading: SizedBox(
                                          width: MediaQuery.of(context).size.width * 0.4,
                                          height: MediaQuery.of(context).size.width * 0.4, 
                                          child: Lottie.asset(
                                            'assets/mess.json',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                          
                          title: Column(
                            children: [
                              Text("message  : ${snapshot.data![index]["body"]}",
                                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                              ),
                               Text("Envoyer Par  : ${snapshot.data![index]["sender_name"]}",
                                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                              ),
                              
                            ],
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
      floatingActionButton: FloatingActionButton(onPressed: () {
         Navigator.push(context, MaterialPageRoute(builder: (context) => AjouterMessage(widget.email)));
      },child: Icon(Icons.add),
      ),
    );
  }
}