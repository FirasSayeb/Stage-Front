

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
  Future<List<Actualite>> getActualites() async {
    try {
      final response = await get(Uri.parse("http://192.168.1.11:80/api/getActualites"));
      if (response.statusCode == 200) {
        final List responseData = jsonDecode(response.body)['list']; 
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
    return Scaffold(
      appBar: AppBar(title: const Text("Actualites "),centerTitle: true,elevation: 0,backgroundColor: Color.fromARGB(160,0,54,99),),
      body: Container(
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
                           String? filePath = snapshot.data![index].filePath;
                          String fileName = filePath != null ? filePath.split('/').last : '';
                      return Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16.0),
                          title: Text( 
                            snapshot.data![index].body,
                            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
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
                              ),SizedBox(height: 8.0), 
                              Text(
                                'File: $fileName',
                                style: TextStyle(fontSize: 14.0),
                              ),SizedBox(height: 8.0),
                             
                            ],
                          ), 
                          onTap: () {
                            
                          },
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