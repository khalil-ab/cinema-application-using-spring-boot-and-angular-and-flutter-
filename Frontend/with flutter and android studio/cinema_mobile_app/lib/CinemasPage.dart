import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'SallesPage.dart';

class CinemasPage extends StatefulWidget {
  dynamic ville;

  CinemasPage(this.ville);

  @override
  _CinemasPageState createState() => _CinemasPageState();
}

class _CinemasPageState extends State<CinemasPage> {
  List<dynamic> listCinemas;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cinemas de ${widget.ville['name']}'),
      ),
      body: Center(
        child: (this.listCinemas == null)
            ? CircularProgressIndicator()
            : ListView.builder(
                itemCount:
                    this.listCinemas == null ? 0 : this.listCinemas.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.orange,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RaisedButton(
                        color: Colors.white,
                        child: Text(this.listCinemas[index]['name']),
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(
                                  builder:(context)=>new SallesPage(this.listCinemas[index])));
                        },
                      ),
                    ),
                  );
                }),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadCinemas();
  }

  void loadCinemas() {
    String url = this.widget.ville['_links']['cinemas']['href'];
    http.get(url).then((resp) {
      setState(() {
        this.listCinemas = json.decode(resp.body)['_embedded']['cinemas'];
      });
    }).catchError((err) {
      print(err);
    });
  }
}
