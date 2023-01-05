import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'model/montre.dart';

Future<Montre> createMontre(String title, String price, String? image) async {
  final response = await http.post(Uri.parse("https://data.mongodb-api.com/app/data-acmdv/endpoint/data/v1/action/insertOne"), headers: {
    "Accept": "application/json",
    "Content-Type": "application/json",
    "api-key": "0u1lqzVG8qiuzB0nV5Dvflo5yWp98TUDU83TyVmHRgwfjTsM4Q0sPS7z3TeXfGOS"
  }, body: jsonEncode({
    "dataSource": "Cluster0",
    "database": "montre",
    "collection": "montre",
    "document": {
      "title": title,
      "price": price,
      "image": image
    }
  }));
  if (response.statusCode == 201) {
    return Montre.fromJson(jsonDecode(response.body));
  } else {
    log("ReponseError : ${response.body}");
    throw Exception('Failed to create montre');
  }
}

class FormWidget extends StatefulWidget {
  const FormWidget({Key? key}) : super(key: key);

  @override
  State<FormWidget> createState() => _FormWidgetState();
}

class _FormWidgetState extends State<FormWidget> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _image = TextEditingController();
  Future<Montre>? _futureMontre;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Créer une montre",
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Créer une montre"),
        ),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: (_futureMontre == null) ? buildColumn() : buildFutureBuilder(),
        ),
      )
    );
  }

  Column buildColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextField(
          controller: _title,
          decoration: const InputDecoration(hintText: "Entrez le nom de la montre"),
        ),
        TextField(
          controller: _price,
          decoration: const InputDecoration(hintText: "Entrez le prix de la montre"),
        ),
        TextField(
          controller: _image,
          decoration: const InputDecoration(hintText: "Entrez l'url d'une image de la montre"),
        ),
        ElevatedButton(
            onPressed: () => {
              setState(() {
                _futureMontre = createMontre(_title.text, _price.text, _image.text);
              })
            },
            child: const Text("Créer")
        )
      ]
    );
  }

  FutureBuilder<Montre> buildFutureBuilder() {
    return FutureBuilder<Montre>(
      future: _futureMontre,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text("${snapshot.data!.title}");
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
