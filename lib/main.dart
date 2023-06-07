import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testefluter1/models/item.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'APP',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  List<Item> items = [];
  HomePage() {
    // items.add(Item(title: "Valdir", done: false));
    // items.add(Item(title: "Franklin", done: true));
    // items.add(Item(title: "Vitinho", done: false));
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    var newTaskCtrl = TextEditingController(); //controla o texto inserido
    Future save() async {
      var prefs = await SharedPreferences.getInstance();
      await prefs.setString('data', jsonEncode(widget.items));
    }

    void add() {
      if (newTaskCtrl.text.isEmpty) {
        return;
      } // verificação
      setState(() {
        widget.items.add(
          Item(
            title: newTaskCtrl.text,
            done: false,
          ),
        );
        newTaskCtrl.clear();
        save();
      }); //adiciona novo item
    }

    void remove(int index) {
      setState(() {
        widget.items.removeAt(index);
        save();
      });
    }

    Future load() async {
      var prefs = await SharedPreferences.getInstance();
      dynamic data = prefs.getString('data');

      if (data != null) {
        Iterable decoded = jsonDecode(data);
        List<Item> result = decoded.map((e) => Item.fromJson(e)).toList();
        setState(() {
          widget.items = result;
        });
      }
    }

    _HomePageState() {
      load();
    }

    return Scaffold(
      appBar: AppBar(
        // leading: Text("Novo item:"),
        title: TextFormField(
          controller: newTaskCtrl,
          keyboardType:
              TextInputType.text, //.email .phone mostra o teclado que preferir
          style: const TextStyle(color: Colors.yellow), //cor do teclado
          decoration: const InputDecoration(
            labelText: "Novo Item",
            labelStyle: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        //actions: const <Widget>[
        //Icon(Icons.plus_one),
        //],
      ),
      body: Container(
        child: Center(
          child: ListView.builder(
            itemCount: widget.items.length,
            itemBuilder: (BuildContext ctxt, int index) {
              final item = widget.items[index];
              return Dismissible(
                child: CheckboxListTile(
                  title: Text(item.title.toString()),
                  value: item.done,
                  onChanged: (value) {
                    setState(() {
                      item.done = value;
                      save();
                    }); // muda estado do item e não pode ser chamado em funções StatefulWidget
                  },
                ),
                key: Key(item.title.toString()),
                background: Container(
                  color: Colors.red.withOpacity(0.2),
                  child: Text("Vai de bote!"),
                ),
                onDismissed: (direction) {
                  remove(index);
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: add, //chama função que esta em _HomePageState
        child: Icon(Icons.add),
        backgroundColor: Colors.pink,
      ),
    );
  }
}
