
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';

class VoirEvent extends StatefulWidget {
  final String email;
  VoirEvent(this.email);

  @override
  State<VoirEvent> createState() => _VoirEventState();
}

class _VoirEventState extends State<VoirEvent> {
  int? _selectedEleveId;
  List services = [];

  Future<List<Map<String, dynamic>>> getEleves() async {
    try {
      final response = await get(Uri.parse("https://firas.alwaysdata.net/api/getFils/${widget.email}"));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body)['list'];
        final List<Map<String, dynamic>> eleves = List<Map<String, dynamic>>.from(responseData);
        return eleves;
      } else {
        throw Exception('Échec du chargement des eleves');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Échec du chargement des  eleves');
    }
  }

  Future<List<Map<String, dynamic>>> getEvents() async {
    try {
      final response = await get(Uri.parse("https://firas.alwaysdata.net/api/getEvents"));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body)['list'];
        final List<Map<String, dynamic>> services = List<Map<String, dynamic>>.from(responseData);
        return services;
      } else {
        throw Exception('Échec du chargement des  services');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Échec du chargement des  services');
    }
  }

  getServi(int id) async {
    try {
      final response = await get(Uri.parse("https://firas.alwaysdata.net/api/getEvt/$id"));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body)['list'];
        final List<Map<String, dynamic>> services = List<Map<String, dynamic>>.from(responseData);
        setState(() {
          this.services = services;
        });
      } else {
        throw Exception('Échec du chargement des services');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Échec du chargement des  services');
    } 
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des événements'),
         backgroundColor: Color.fromARGB(255, 4, 166, 235),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Sélectionner un élevé:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: getEleves(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {  
                  List<Map<String, dynamic>> eleves = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [ 
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: eleves.length,
                        itemBuilder: (context, index) {
                          final eleve = eleves[index];
                          final eleveName = eleve['name'] ?? 'Unknown';
                          return RadioListTile<int>(
                            title: Text(eleveName),
                            value: eleve['id'],
                            groupValue: _selectedEleveId,
                            onChanged: (int? value) {
                              setState(() {
                                _selectedEleveId = value;
                                getServi(_selectedEleveId!);
                              });
                            },
                          );
                        },
                      ),
                    ],
                  );
                }
              },
            ),
            SizedBox(height: 20),
            Text(
              'Events:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (_selectedEleveId != null)
            Container(
              height: 300,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: getEvents(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
} else {
return ListView.builder(
itemCount: snapshot.data!.length,
itemBuilder: (context, index) {
final event = snapshot.data![index];
final eventName = event['name'] ?? 'Unknown';
final eventId = event['id']; 
 print(services);          
bool isSubscribed = services.any((element) => element['event_id'] == eventId);
print(isSubscribed); 
                    return Card(
                       elevation: 4,
    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                      child: ListTile(
                      
                      contentPadding: EdgeInsets.all(16.0),
                      leading: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: Lottie.asset(
                          'assets/av.json',
                          fit: BoxFit.contain,
                        ),
                      ),
                        title: Text(eventName),
                        subtitle: Text("${event["price"]} ${event["date"]}"),
                        trailing: isSubscribed
                        ? Text('Déjà ajouté')
                        : ElevatedButton(
                            onPressed: () async {
                              Response response = await post(
                                Uri.parse("https://firas.alwaysdata.net/api/addEvt"),
                                body: <String, dynamic>{
                                  'eleve': _selectedEleveId.toString(),
                                  'event': eventId.toString(), 
                                },
                              );
                              if (response.statusCode == 200) {
                               getServi(_selectedEleveId!);
                              }
                            },
                            child: Text('Ajouter'),
                          ),
                      ),
                    );
                  },
                );
              }
            }, 
          ),
        ), 
      ],
    ),
  ),
);
  }
}