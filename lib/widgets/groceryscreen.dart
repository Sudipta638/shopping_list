import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/model/grocey_item.dart';
import 'package:shopping_list_app/widgets/newitem.dart';
import "package:http/http.dart" as http;
import 'dart:convert';

class Groceryitem extends StatefulWidget {
  const Groceryitem({super.key});

  @override
  State<Groceryitem> createState() => _GroceryItemState();
}

class _GroceryItemState extends State<Groceryitem> {
  List<GroceryItem> _items = [];
  var _isloading = true;
  String? _error;
  void _loaditems() async {
    final url = Uri.https(
        'shoppinglist-db698-default-rtdb.firebaseio.com', "shoopinglist.json");

    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          _error = "Failed to fetch data.Please try again later";
        });
      }
      if (response.body == 'null') {
        setState(() {
          _isloading = false;
        });
        return;
      }
      final Map<String, dynamic> firebasedata = json.decode(response.body);
      final List<GroceryItem> loadeditem = [];
      for (final item in firebasedata.entries) {
        final category = categories.entries
            .firstWhere((categoryitem) =>
                categoryitem.value.fruit == item.value['category'])
            .value;
        loadeditem.add(GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category));
      }
      setState(() {
        _items = loadeditem;
        _isloading = false;
      });
    } catch (error) {
      setState(() {
        _error = "Somethimg went wrong,try again later";
      });
    }
  }

  void _onadditem() async {
    final newitem = await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(builder: (ctx) => const NewItem()));
    if (newitem == null) {
      return;
    }
    setState(() {
      _items.add(newitem);
    });
    // _loaditems();
  }

  void _ondismissed(GroceryItem item) async {
    final idexitem = _items.indexOf(item);
    setState(() {
      _items.remove(item);
    });

    final url = Uri.https('shoppinglist-db698-default-rtdb.firebaseio.com',
        "shoopinglist/${item.id}.json");

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      setState(() {
        _items.insert(idexitem, item);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loaditems();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text("No items added yet"),
    );
    if (_isloading) {
      content = const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }
    if (_items.isNotEmpty) {
      content = ListView.builder(
          itemCount: _items.length,
          itemBuilder: (ctx, index) => Dismissible(
                key: ValueKey(_items[index].id),
                onDismissed: (direction) {
                  _ondismissed(_items[index]);
                },
                child: ListTile(
                  title: Text(_items[index].name),
                  leading: Container(
                      width: 24,
                      height: 24,
                      color: _items[index].category.color),
                  trailing: Text(_items[index].quantity.toString()),
                ),
              ));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Grocery"),
        actions: [
          IconButton(onPressed: _onadditem, icon: const Icon(Icons.add))
        ],
      ),
      body: content,
    );
  }
}
