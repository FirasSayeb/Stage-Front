import 'dart:convert';
import 'package:app/pages/gerer_services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class ModService extends StatefulWidget {
  final String name;
  final String email;
  ModService(this.email,this.name);

  @override
  State<ModService> createState() => _ModServiceState();
}

class _ModServiceState extends State<ModService> {
  final fkey = GlobalKey<FormState>();
  late String name = '';
  double? price;
  late String description='';
  late Future<Map<String, dynamic>> _serviceFuture;

  @override
  void initState() {
    super.initState();
    _serviceFuture = getService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier Service'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 4, 166, 235),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Form(
              key: fkey,
              child: FutureBuilder<Map<String, dynamic>>(
                future: _serviceFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final classe = snapshot.data as Map<String, dynamic>?;

                    if (classe == null) {
                      return Center(child: Text('Service introuvable'));
                    }

                    return Column(
                      children: [
                        Container(
  height: 300,
  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
  decoration: BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.5),
        spreadRadius: 2,
        blurRadius: 4,
        offset: Offset(0, 3), 
      ),
    ],
    borderRadius: BorderRadius.circular(8),
    color: Colors.white,
  ),
  child: Padding(
    padding: EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          initialValue: classe['name'] ?? '',
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          onChanged: (value) {
            setState(() {
              name = value;
            });
          },
          decoration: InputDecoration(
            labelText: 'Nom :',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'champs obligatoire';
            }
            return null;
          },
        ),
        SizedBox(height: 8.0),
        TextFormField(
          keyboardType: TextInputType.number,
          initialValue: classe['price'] != null ? classe['price'].toString() : '',
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          onChanged: (value) {
            setState(() {
              price = double.tryParse(value) ?? 0.0;
            });
          },
          decoration: InputDecoration(
            labelText: 'Prix : ',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'champs obligatoire';
            }
            return null;
          },
        ),
 SizedBox(height: 8.0),
        TextFormField(
          initialValue: classe['description'] ?? '',
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          onChanged: (value) {
            setState(() {
              description = value;
            });
          },
          decoration: InputDecoration(
            labelText: 'description :',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'champs obligatoire';
            }
            return null;
          },
        ),
      ],
    ),
  ),
),

                        ElevatedButton(
                          onPressed: () async {
                            if (fkey.currentState!.validate()) {
                              fkey.currentState!.save();
                              final response = await put(
                                Uri.parse("https://firas.alwaysdata.net/api/updateService/${widget.name}"),
                                body: <String, dynamic>{
                                  'name': name.isNotEmpty ? name : classe['name'],
                                  'price': price != null ? price.toString() : classe['price'].toString(),
                                  'description': description.isNotEmpty ? description : classe['description'],
                                },
                              );
                              if (response.statusCode == 200) {
                               Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GererServices(widget.email),
            ),
          ).then((_) => setState(() {}));
                              }
                            }
                          },
                          child: Text('Valider'),
                        ),
                      ],
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

  Future<Map<String, dynamic>> getService() async {
    try {
      final response =
          await get(Uri.parse("https://firas.alwaysdata.net/api/getService/${widget.name}"));
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['service'];
      } else {
        throw Exception('Échec du chargement de service');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Échec du chargement de service');
    }
  }
}
