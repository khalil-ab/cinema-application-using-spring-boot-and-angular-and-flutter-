import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'GlobalVariable.dart';

class SallesPage extends StatefulWidget {
  dynamic cinema;

  SallesPage(this.cinema);

  @override
  _SallesPageState createState() => _SallesPageState();
}

class _SallesPageState extends State<SallesPage> {
  List<dynamic> listSalles;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Salles du cinema ${widget.cinema['name']}'),
      ),
      body: Center(
        child: (this.listSalles == null)
            ? CircularProgressIndicator()
            : ListView.builder(
                itemCount: this.listSalles == null ? 0 : this.listSalles.length,
                itemBuilder: (context, index) {
                  return Card(
                      color: Colors.white,
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: RaisedButton(
                                color: Colors.deepOrange,
                                child: Text(this.listSalles[index]['name'],
                                    style: TextStyle(color: Colors.white)),
                                onPressed: () {
                                  loadProjection(this.listSalles[index]);
                                },
                              ),
                            ),
                          ),
                          if (this.listSalles[index]['projections'] != null)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Image.network(
                                      GlobalData.host +
                                          "/imageFilm/${this.listSalles[index]['currentProjection']['film']['id']}",
                                      width: 150),
                                  Column(
                                    children: [
                                      ...(this.listSalles[index]['projections']
                                              as List<dynamic>)
                                          .map((projection) {
                                        return RaisedButton(
                                          color: (this.listSalles[index]
                                                          ['currentProjection']
                                                      ['id'] ==
                                                  projection['id'])
                                              ? Colors.deepOrange
                                              : Colors.green,
                                          child: Text(
                                              "${projection['seance']['heureDebut']} (${projection['film']['duree']},Prix=${projection['prix']})",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12)),
                                          onPressed: () {
                                            loadTickets(projection,
                                                this.listSalles[index]);
                                          },
                                        );
                                      })
                                    ],
                                  )
                                ],
                              ),
                            ),
                          if (this.listSalles[index]['currentProjection'] !=
                                  null &&
                              this.listSalles[index]['currentProjection']
                                      ['listTickets'] !=
                                  null &&
                              this
                                      .listSalles[index]['currentProjection']
                                          ['listTickets']
                                      .length >
                                  0)
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                        "Nombre de place Dispo:${this.listSalles[index]['currentProjection']['nombrePlaceDisponibles']}")
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.fromLTRB(6, 2, 6, 3),
                                  child: TextField(
                                    decoration:
                                        InputDecoration(hintText: 'Your Name'),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.fromLTRB(6, 2, 6, 3),
                                  child: TextField(
                                    decoration: InputDecoration(
                                        hintText: 'Code Payement'),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.fromLTRB(6, 2, 6, 3),
                                  child: TextField(
                                    decoration: InputDecoration(
                                        hintText: 'Nombre de tickets'),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  child: RaisedButton(
                                    color: Colors.deepOrange,
                                    child: Text("Reserver les places",
                                        style: TextStyle(color: Colors.white)),
                                    onPressed: () {},
                                  ),
                                ),
                                Wrap(
                                  children: [
                                    ...this
                                        .listSalles[index]['currentProjection']
                                            ['listTickets']
                                        .map((ticket) {
                                      if (ticket['reserve'] == false)
                                        return Container(
                                          width: 50,
                                          padding: EdgeInsets.all(2),
                                          child: RaisedButton(
                                            color: Colors.green,
                                            child: Text(
                                                "${ticket['place']['numero']}",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12)),
                                            onPressed: () {},
                                          ),
                                        );
                                      else
                                        return Container();
                                    })
                                  ],
                                )
                              ],
                            )
                        ],
                      ));
                }),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadSalles();
  }

  void loadSalles() {
    String url = this.widget.cinema['_links']['salles']['href'];
    http.get(url).then((resp) {
      setState(() {
        this.listSalles = json.decode(resp.body)['_embedded']['salles'];
      });
    }).catchError((err) {
      print(err);
    });
  }

  void loadProjection(salle) {
    String url1 =
        GlobalData.host + "/salles/${salle['id']}/projections?projection=p1";
    String url2 = salle['_links']['projections']['href']
        .toString()
        .replaceAll("{?projection}", "?projection=p1");
    print(url1);
    print(url2);
    http.get(url2).then((resp) {
      setState(() {
        salle['projections'] =
            json.decode(resp.body)['_embedded']['projections'];
        salle['currentProjection'] = salle['projections'][0];
        salle['currentProjection']['listTickets'] = [];

        //print(salle['projections']);
      });
    }).catchError((err) {
      print(err);
    });
  }

  void loadTickets(projection, salle) {
    //String url="http://192.168.1.3:8082/projections/1/tickets?projection=ticketProj";
    String url = projection['_links']['tickets']['href']
        .toString()
        .replaceAll("{?projection}", "?projection=ticketProj");
    http.get(url).then((resp) {
      setState(() {
        projection['listTickets'] =
            json.decode(resp.body)['_embedded']['tickets'];
        salle['currentProjection'] = projection;
        projection['nombrePlacesDisponibles'] =
            nombrePlaceDisponibles(projection);
      });
    }).catchError((err) {
      print(err);
    });
  }

  nombrePlaceDisponibles(projection) {
    int nombre = 0;
    for (int i = 0; projection['tickets'].length; i++) {
      if (projection['tickets'][i]['reserve'] == false) ++nombre;
    }
    return nombre;
  }
}
