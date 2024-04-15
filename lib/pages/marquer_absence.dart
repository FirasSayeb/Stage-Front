import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

class MarquerAbsence extends StatefulWidget {
  final String email;
  final String name;
  MarquerAbsence(this.email, this.name);

  @override
  State<MarquerAbsence> createState() => _MarquerAbsenceState();
}

class _MarquerAbsenceState extends State<MarquerAbsence> {
  late List<bool> absenceList;

  @override
  void initState() {
    super.initState();
    absenceList = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Marquer Absence"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color.fromARGB(160, 0, 54, 99),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getEleves(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(child: Text('No Eleves'));
          } else {
            // Initialize absenceList only once when data is available
            if (absenceList.isEmpty) {
              absenceList = List.generate(snapshot.data!.length, (index) => true);
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                final eleve = snapshot.data![index];
                return Card( 
                  elevation: 2,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: CheckboxListTile(
                    title: Text(eleve['name']),
                    value: absenceList[index],
                    onChanged: (bool? value) {
                      setState(() {
                        absenceList[index] = value!;
                        print(absenceList);
                      });
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getEleves() async {
    try {
      final response = await get(Uri.parse("https://firas.alwaysdata.net/api/getEleves/${widget.name}"));
      if (response.statusCode == 200) {
        List<dynamic> classesData = jsonDecode(response.body)['eleves'];
        List<Map<String, dynamic>> classes = List<Map<String, dynamic>>.from(classesData);
        return classes;
      } else {
        throw Exception('failed to get eleves');
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to load eleves');
    }
  }
}
