import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';

class VoirServices extends StatefulWidget {
  final String email;
  VoirServices(this.email);

  @override
  State<VoirServices> createState() => _VoirServicesState();
}

class _VoirServicesState extends State<VoirServices> {
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
      throw Exception('Échec du chargement des eleves');
    }
  }

  Future<List<Map<String, dynamic>>> getServices() async {
    try {
      final response = await get(Uri.parse("https://firas.alwaysdata.net/api/getServices"));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body)['list'];
        final List<Map<String, dynamic>> services = List<Map<String, dynamic>>.from(responseData);
        return services;
      } else {
        throw Exception('Échec du chargement des  services');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Échec du chargement des services');
    }
  }

  getServi(int id) async {
    try {
      final response = await get(Uri.parse("https://firas.alwaysdata.net/api/getSer/$id"));
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
      throw Exception('Échec du chargement des services');
    } 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('consulter services'),
         backgroundColor: Color.fromARGB(255, 4, 166, 235),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Sélectionnez un eleve:',
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
              'Services:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (_selectedEleveId != null)
            Container(
              height: 300,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: getServices(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
} else {
return ListView.builder(
itemCount: snapshot.data!.length,
itemBuilder: (context, index) {
final service = snapshot.data![index];
final serviceName = service['name'] ?? 'Unknown';
final serviceId = service['id']; 
 print(services);          
bool isSubscribed = services.any((element) => element['service_id'] == serviceId);
print(isSubscribed);
                    return ListTile(
                      contentPadding: EdgeInsets.all(16.0),
  leading: SizedBox(
    width: MediaQuery.of(context).size.width * 0.4,
    child: Lottie.asset(
      'assets/ser.json',
      fit: BoxFit.contain,
    ),
  ),
                      title: Text(serviceName),
                      subtitle: Text("${service["price"]}"),
                      trailing: isSubscribed
    ? ElevatedButton(
        onPressed: () async {
          /*Response response = await delete(
            Uri.parse("https://firas.alwaysdata.net/api/delSer/$_selectedEleveId"),
          );
          if (response.statusCode == 200) {
            getServi(_selectedEleveId!);
          }*/
        },
        child: Text('Ajouter'), 
      )
    : ElevatedButton( 
        onPressed: () async {
          Response response = await post(
            Uri.parse("https://firas.alwaysdata.net/api/addSer"),
            body: <String, dynamic>{
              'eleve': _selectedEleveId.toString(),
              'service': serviceId.toString(), 
            },
          ); 
          if (response.statusCode == 200) {
           getServi(_selectedEleveId!);
          }
        },
        child: Text('Ajouter'),
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
  }}
