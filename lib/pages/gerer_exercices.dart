
import 'dart:convert';

import 'package:app/pages/AjouterExercice.dart';
import 'package:app/pages/ModExercice.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class GererExercices extends StatefulWidget {
  final String email;
  final String? name;
  GererExercices(this.email,this.name);

  @override
  State<GererExercices> createState() => _GererExercicesState();
}

class _GererExercicesState extends State<GererExercices> {

  Future<List<Map<String, dynamic>>> getExercices() async { 
  try {
    final response = await get(Uri.parse("http://10.0.2.2:8000/api/getExercices/${widget.name}"));
    if (response.statusCode == 200) {
      final dynamic responseData = jsonDecode(response.body.toString())['list'];
      if (responseData != null) { 
        final List<Map<String, dynamic>> parentList =
            (responseData as List<dynamic>).map((data) => data as Map<String, dynamic>).toList();
        return parentList; 
      } else {
        throw Exception('Response data is null');
      }  
    } else {  
      throw Exception('Failed to load exercices');
    }  
  } catch (e) { 
    print('Error: $e');
    throw Exception('Failed to load exercices');
  }
}
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar( 
        title: const Text("Gerer Exercices "),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color.fromARGB(160, 0, 54, 99),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Padding(padding: EdgeInsets.all(10)),
              GestureDetector(
                child: Text('Ajouter Exercice'),
                onTap: () { 
                  print('ajouter Exercice');  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AjouterExercice(widget.email,widget.name),
                    ),
                  );
                },
              ),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: getExercices(),
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
                              title: Text("Name : "+
                                snapshot.data![index]['name'] 
                                ,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 8),
                                  Text("Description : "+
                                snapshot.data![index]['description'] 
                                ,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                                 
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton( 
                                        onPressed: () {
                                          Navigator.push(  
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ModExercice(snapshot.data![index]['name']),
                                            ),
                                          ).then((_) => setState(() {}));
                                        }, 
                                        child: Text('Modifier'),
                                      ), 
                                      ElevatedButton(
                                        onPressed: () { 
                                          deleteExercice(snapshot.data![index]['name']);
                                          Navigator.push(
                                            context, 
                                            MaterialPageRoute(
                                              builder: (context) => GererExercices(widget.email,null),
                                            ),
                                          ); 
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
      ),
    );
  }
  deleteExercice(String name) async {
  try {
    final response = await delete(Uri.parse("http://10.0.2.2:8000/api/deleteExercice/$name"));
    if (response.statusCode == 200) {
      print('Success: Exercice deleted'); 
    } else { 
      throw Exception('Failed to delete exercice');
    }
  } catch (e) {
    print('Error: $e');
    throw Exception('Failed to delete exercice');
  }
}
}