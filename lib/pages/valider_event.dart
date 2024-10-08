
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

class ValiderEvent extends StatefulWidget {
  final String email;
  ValiderEvent(this.email);

  @override
  State<ValiderEvent> createState() => _ValiderEventState();
}

class _ValiderEventState extends State<ValiderEvent> {
  Future<List<Map<String, dynamic>>>getevent() async {
    try {
      final response = await get(Uri.parse("https://firas.alwaysdata.net/api/getEvt"));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body)['list'];
        final List<Map<String, dynamic>> services = List<Map<String, dynamic>>.from(responseData);
        return services;
      } else {
        throw Exception('Échec du chargement des événements');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Échec du chargement des événements');
    } 
  }
  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        title: const Text("Valider événements "),
        centerTitle: true,
        elevation: 0,
         backgroundColor: Color.fromARGB(255, 4, 166, 235),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
               FutureBuilder<List<Map<String, dynamic>>>(
                future: getevent(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 4,
                            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                            child: ListTile(
                              title: Row(
                                children: [
                                  Text("Nom d'Eleve : "+
                                    snapshot.data![index]['eleve_name'] 
                                    ,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4),
                                  Text("Nom de l'événement : "+
                                snapshot.data![index]['event_name'] 
                                ,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),

                                  SizedBox(height: 8),Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      
                                      ElevatedButton(
                                        onPressed: () {
                                          deleteEvent(snapshot.data![index]['id']);
                                          Navigator.push(
                                            context, 
                                            MaterialPageRoute(
                                              builder: (context) => ValiderEvent(widget.email),
                                            ),
                                          ).then((_) => setState(() {}));
                                        },
                                        child: Text('Supprimer'),
                                        style: ButtonStyle(
                                          backgroundColor: MaterialStatePropertyAll(Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ));
  }
  deleteEvent(int id) async {
  try {
    final response = await delete(Uri.parse("https://firas.alwaysdata.net/api/delEv/$id"));
    if (response.statusCode == 200) {
      print('Success: Service deleted');
    } else { 
      throw Exception('Failed to delete service');
    }
  } catch (e) {
    print('Error: $e');
    throw Exception('Failed to delete service');
  }
}
}