

import 'dart:convert';

import 'package:app/model/Actualite.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class ListActualites extends StatefulWidget {
 final String email;
 ListActualites(this.email);

  @override
  State<ListActualites> createState() => _ListActualitesState();
}

class _ListActualitesState extends State<ListActualites> {
  late String searchString="";
  Future<List<Actualite>> getActualites() async {
    try {
      final response = await get(Uri.parse("https://firas.alwaysdata.net/api/getActualites"));
      if (response.statusCode == 200) {
        final List responseData = jsonDecode(response.body)['list']; 
        return responseData.map((data) => Actualite.fromJson(data)).toList();
      } else {
        throw Exception('Échec du chargement des actualites');
      }
    } catch (e) { 
      print('Error: $e');  
      throw Exception('Échec du chargement des actualites');
    }
  } 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Actualites "),centerTitle: true,elevation: 0, backgroundColor: Color.fromARGB(255, 4, 166, 235),),
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
                            
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16.0),
                              title: Row(
                                children: [
                                  Text(
                                    " ${snapshot.data![index].body}",
                                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                  ),
                                  
                                    
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 8.0),
                                  Text(
                                    'Créé à: ${snapshot.data![index].createdAt}',
                                    style: TextStyle(fontSize: 14.0),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    'Créé par: ${snapshot.data![index].userName}',
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
    );
  }
}