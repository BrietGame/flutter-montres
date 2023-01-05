import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:montres/addMontre.dart';

import 'model/montre.dart';

void main() {
  runApp(const MyApp());
}

FutureOr<List<Montre>> parseMontre(String message) {
  Map<String, dynamic> map = json.decode(message);
  log("Map : $map");
  List<dynamic> data = map["documents"];
  log("Data : $data");
  log("Data 0 : ${data[0]}");

  List<Montre> montres = [];
  for (var item in data) {
    montres.add(Montre.fromJson(item));
  }
  return montres;

}

Future<List<Montre>> fetchAllMontre() async {
  final response = await http.post(Uri.parse("https://data.mongodb-api.com/app/data-acmdv/endpoint/data/v1/action/find"), headers: {
    "Accept": "application/json",
    "Content-Type": "application/json",
    "api-key": "0u1lqzVG8qiuzB0nV5Dvflo5yWp98TUDU83TyVmHRgwfjTsM4Q0sPS7z3TeXfGOS"
  }, body: jsonEncode({
    "dataSource": "Cluster0",
    "database": "montre",
    "collection": "montre"
  }));
  log("Test AFK: ${response.body}");
  if (response.statusCode == 200) {
    return compute(parseMontre, response.body);
  } else {
    throw Exception('Failed to load album');
  }
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const MyHomePage(title: 'Montres'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Montre>> futureAllMontre;


  @override
  void initState() {
    super.initState();
    futureAllMontre = fetchAllMontre();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: cardsMontre(),
      ),
      floatingActionButton: Wrap(
        children: [
          Container(
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  futureAllMontre = fetchAllMontre();
                });
              },
              tooltip: 'Refresh',
              backgroundColor: Colors.blue,
              child: const Icon(Icons.refresh),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 10),
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FormWidget()));
              },
              tooltip: 'Add',
              child: const Icon(Icons.add,),
            ),
          ),
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget cardsMontre() {
    return FutureBuilder<List<Montre>>(
      future: futureAllMontre,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailMontre(montre: snapshot.data![index]),
                    ),
                  );
                },
                child: Card(
                  child: Column(
                    children: [
                      Column(
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    '${snapshot.data![index].image}',
                                    height: 150,
                                    width: 150,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                    child: Text(
                                      '${snapshot.data![index].price} €',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                )
                              ],
                            )
                          ]
                      ),
                      Text(snapshot.data![index].title!)
                    ],
                  ),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        // By default, show a loading spinner.
        return const CircularProgressIndicator();
      },
    );
  }
}

class DetailMontre extends StatefulWidget {
  const DetailMontre({required this.montre, Key? key}) : super(key: key);

  final Montre montre;

  @override
  State<DetailMontre> createState() => _DetailMontreState();
}

class _DetailMontreState extends State<DetailMontre> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Détails : ${widget.montre.title!}"),
      ),
      body: Center(
        child: Column(
            children: [
              AspectRatio(
                aspectRatio: 16/9,
                child: Image.network(
                  '${widget.montre.image}',
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 5),
                child: Text(widget.montre.title!, style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),),
              ),
              Text('${widget.montre.price} €', style: const TextStyle(
                fontSize: 15,
                fontStyle: FontStyle.italic,
              ),),
            ]
        ),
      )
    );
  }
}


