import 'dart:convert';
import 'dart:io';

import 'package:app/model/Actualite.dart';
import 'package:app/pages/moifier_actualite.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Admin extends StatefulWidget {
  final String email;
  Admin(this.email);

  @override
  _AdminState createState() => _AdminState();
}



class _AdminState extends State<Admin> {
  late String searchString = '';

  Future<List<Actualite>> getActualites() async {
    try {
      final response =
          await http.get(Uri.parse("https://firas.alwaysdata.net/api/getActualites"));
      if (response.statusCode == 200) {
        final List responseData = jsonDecode(response.body)['list'];
        print(responseData[0]['file_path']);
        return responseData.map((data) => Actualite.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load actualites');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load actualites');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Welcome ${widget.email}'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: const Color.fromARGB(160, 0, 54, 99),
        ),
        body: Column(
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  searchString = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Rechercher...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      searchString = '';
                    });
                  },
                ),
              ),
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01)),
            Expanded(
              child: FutureBuilder<List<Actualite>>(
                future: getActualites(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        if (searchString.isEmpty ||
                            snapshot.data![index].userName.toLowerCase().contains(searchString)
                            || snapshot.data![index].body.toLowerCase().contains(searchString)||
                                snapshot.data![index].createdAt.toLowerCase().contains(searchString)
                            ) {
                          String? filePath = snapshot.data![index].filePath;
                          String fileName = filePath != null ? filePath.split('/').last : '';
                          return Card(
                            elevation: 4,
                            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16.0),
                              title: Row(
                                children: [
                                  Text(
                                    "Nom : ${snapshot.data![index].body}",
                                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                  ),
                                  Padding(padding: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.45)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      PopupMenuButton<String>(
                                        itemBuilder: (BuildContext context) => [
                                          PopupMenuItem<String>(
                                            value: 'modify',
                                            child: Text('Modifier'),
                                          ),
                                          PopupMenuItem<String>(
                                            value: 'delete',
                                            child: Text('Supprimer', style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                        onSelected: (String value) async {
                                          if (value == 'modify') {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ModierActualite(
                                                  snapshot.data![index].id,
                                                  widget.email,
                                                ),
                                              ),
                                            );
                                          } else if (value == 'delete') {
                                            bool confirmDelete = await showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text("Confirmation"),
                                                  content: Text("Etes-vous sûr que vous voulez supprimer?"),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop(false);
                                                      },
                                                      child: Text("Non"),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop(true);
                                                      },
                                                      child: Text("Oui"),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );

                                            if (confirmDelete == true) {
                                              print(snapshot.data![index].id);
                                              deleteActualite(snapshot.data![index].id);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => Admin(widget.email)),
                                              ).then((_) => setState(() {}));
                                            }
                                          }
                                        },
                                        icon: Icon(Icons.more_vert),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 8.0),
                                  Text(
                                    'Created At: ${snapshot.data![index].createdAt}',
                                    style: TextStyle(fontSize: 14.0),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    'Created By: ${snapshot.data![index].userName}',
                                    style: TextStyle(fontSize: 14.0),
                                  ),
                                  Image.network(
                                    "https://firas.alwaysdata.net/storage/$fileName",
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height * 0.3,
                                    fit: BoxFit.cover,
                                  )
                                ],
                              ),
                            ),
                          );
                        } else {
                          return Container();
                        }
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

  void deleteActualite(int actualiteId) async {
    final url = Uri.parse("https://firas.alwaysdata.net/api/deleteActualite/$actualiteId");

    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        print("success");
      } else {
        print("failed");
      }
    } catch (e) {
      print('Error deleting actualite: $e');
    }
  }
}