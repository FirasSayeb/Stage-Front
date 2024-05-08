import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app/model/Actualite.dart';
import 'package:open_file/open_file.dart';


class Detail extends StatefulWidget {
  final int id;
  Detail(this.id);

  @override
  _DetailState createState() => _DetailState();  
}

class _DetailState extends State<Detail> {
  Future<List<Actualite>> getActualite() async {
  try {
    final response = await http.get(Uri.parse("https://firas.alwaysdata.net/api/getActualite/${widget.id}"));
    if (response.statusCode == 200) {
      final List responseData = jsonDecode(response.body)['actualite'];
      return responseData.map((data) => Actualite.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load actualite');
    }
  } catch (e) {  
    print('Error: $e');  
    throw Exception('Failed to load actualite');  
  }
} 


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Detail"),
          centerTitle: true,
          elevation: 0,
           backgroundColor: Color.fromARGB(255, 4, 166, 235),
        ),
        body: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Actualite>>(
  future: getActualite(),
  builder: (context, snapshot) {  
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    } else {
      return ListView.builder(
        itemCount: snapshot.data!.length,
        itemBuilder: (context, index) {
          final actualite = snapshot.data![index];
          String? filePath = actualite.filePath;
          String fileName = filePath != null ? filePath.split('/').last : '';
          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              contentPadding: EdgeInsets.all(16.0),
              title: Text(
                actualite.body,
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.0),
                  Text(
                    'Created At: ${actualite.createdAt}',
                    style: TextStyle(fontSize: 14.0),
                  ),
                  SizedBox(height: 4.0),  
                  Text(
                    'Created By: ${actualite.userName}',
                    style: TextStyle(fontSize: 14.0),
                  ),
                  SizedBox(height: 8.0),
                  ListTile(
                    title: Text(
                      'File: $fileName',
                      style: TextStyle(fontSize: 14.0),
                    ),
                    onTap: () {
                       _launchURL(snapshot.data![index].filePath);
                    },
                  ),
                  SizedBox(height: 8.0),
                ],
              ),
              onTap: () { 
                // Handle onTap event if needed
              },
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
_launchURL(String? filePath) async {
  if (filePath != null) {
    try { 
      await OpenFile.open(filePath);
      print(filePath); 
    } catch (e) {
      
      print('Error opening file: $e');
    }
  } else {
    print('File path is null'); 
  }
}




