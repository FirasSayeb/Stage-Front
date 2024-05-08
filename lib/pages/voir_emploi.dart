import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:open_file/open_file.dart';

class VoirEmploi extends StatefulWidget {
  String email;
   VoirEmploi(this.email);

  @override
  State<VoirEmploi> createState() => _VoirEmploiState();
}

class _VoirEmploiState extends State<VoirEmploi> {
  int? _selectedEleveId;

  Future<Map<String, dynamic>> getEmlpois(int id) async {
    try {
      final response = await get(Uri.parse("https://firas.alwaysdata.net/api/getEmlpois/$id"));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final  notes = responseData['list'];
       
        return notes; 
      } else {
        throw Exception('Échec du chargement des classes');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Échec du chargement des classes');
    }
  }
  
  Future<List<Map<String, dynamic>>> getEleves() async {
    try {
      final response = await get(Uri.parse("https://firas.alwaysdata.net/api/getFils/${widget.email}"));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body)['list'];
        final List<Map<String, dynamic>> eleves = List<Map<String, dynamic>>.from(responseData);
        return eleves;
      } else {
        throw Exception('Échec du chargement des  eleves');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Échec du chargement des eleves');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('consulter emploi'),
         backgroundColor: Color.fromARGB(255, 4, 166, 235),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Sélectionnez un  eleve:',
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
            if (_selectedEleveId != null)
              Padding(
                padding: const EdgeInsets.all(20),
                child: FutureBuilder(
                  future: getEmlpois(_selectedEleveId!),
                  builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: GridView.builder(
                          itemCount: 1,
                          itemBuilder: (context, index) {
                            String? filePath = snapshot.data!['emploi']; 
                            String? fpath = snapshot.data!['examens']; 
                            List<String> pathParts = filePath!.split('/');
                            List<String> pathPart = fpath!.split('/');
                            String fileNameWithExtension = pathParts.last;
                            String fileName2WithExtension = pathPart.last;
                            return Card(
                              elevation: 4,
                              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                              child: GestureDetector( 
                                onTap: () { 
                                  String filePath = snapshot.data![0]['emploi'];
                                  OpenFile.open(filePath);
                                },
                                child: ListTile( 
                                  title: Text( 
                                    "${snapshot.data!['name']}\n ",
                                  ), 
                                  subtitle: Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8.0),
                                            child: Image.network(
                                              "https://firas.alwaysdata.net/storage/$fileNameWithExtension",
                                              width: double.infinity,
                                              height: MediaQuery.of(context).size.height * 0.3,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8.0),
                                            child: Image.network(
                                              "https://firas.alwaysdata.net/storage/$fileName2WithExtension",
                                              width: double.infinity,
                                              height: MediaQuery.of(context).size.height * 0.3,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }, 
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1),
                        ),
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
