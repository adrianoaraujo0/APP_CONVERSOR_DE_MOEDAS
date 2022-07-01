import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'dart:convert';

const request =
    'https://economia.awesomeapi.com.br/last/USD-BRL,EUR-BRL,BTC-BRL';

void main() async {
  runApp(
    MaterialApp(
      home: Home(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        ),
      ),
    ),
  );
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController realController = TextEditingController();
  final TextEditingController dolarController = TextEditingController();
  final TextEditingController euroController = TextEditingController();

  double dolar = 0;
  double euro = 0;

  void clearAll() {
    realController.clear();
    dolarController.clear();
    euroController.clear();
  }

  void realOnchanged(String text) {
    if (text.isEmpty) {
      clearAll();
      return;
    } else {
      double real = double.parse(text);
      dolarController.text = (real / dolar).toStringAsFixed(2);
      euroController.text = (real / euro).toStringAsFixed(2);
    }
  }

  void dolarOnchanged(String text) {
    if (text.isEmpty) {
      clearAll();
      return;
    } else {
      double dolar = double.parse(text);
      realController.text = (dolar * this.dolar).toStringAsFixed(2);
      euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
    }
  }

  void euroOnchanged(String text) {
    if (text.isEmpty) {
      clearAll();
      return;
    } else {
      double dolar = double.parse(text);
      realController.text = (euro * this.euro).toStringAsFixed(2);
      dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(" \$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map?>(
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Carregando dados...",
                  style: TextStyle(color: Colors.amber, fontSize: 35),
                ),
              );
            default:
              if (snapshot.hasError) {
                Center(
                  child: Text("Erro ao carregar dados"),
                );
              } else {
                dolar = double.parse(snapshot.data!["USDBRL"]["high"]);
                euro = double.parse(snapshot.data!["EURBRL"]["high"]);

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      Icon(Icons.monetization_on,
                          size: 150.00, color: Colors.amber),
                      BuildTextField(
                          "Reais", "R\$", realController, realOnchanged),
                      Divider(),
                      BuildTextField(
                          "Dólares", "US\$", dolarController, dolarOnchanged),
                      Divider(),
                      BuildTextField(
                          "Euros", "€", euroController, euroOnchanged)
                    ],
                  ),
                );
              }
              return Container(
                color: Colors.white,
              );
          }
        },
        future: getData(),
      ),
    );
  }
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(request));
  return jsonDecode(response.body);
}

Widget BuildTextField(String label, String prefix,
    TextEditingController controller, Function(String) f) {
  return TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    onChanged: f,
    style: TextStyle(
      color: Colors.amber,
      fontSize: 20,
    ),
    decoration: InputDecoration(
      border: OutlineInputBorder(),
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      prefixText: "$prefix ",
      prefixStyle: TextStyle(color: Colors.amber, fontSize: 20),
    ),
  );
}
