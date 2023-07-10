import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/model/categories.dart';

import "package:http/http.dart" as http;
import 'package:shopping_list_app/model/grocey_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});
  @override
  State<StatefulWidget> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  final _formkey = GlobalKey<FormState>();
  var _enteredname = '';
  var _enteredquantity = 1;
  var _enteredcategory = categories[Categories.vegetables]!;
  var _issending = false;
  void _onsubmit() async {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();
      final url = Uri.https('shoppinglist-db698-default-rtdb.firebaseio.com',
          "shoopinglist.json");
      setState(() {
        _issending = true;
      });
      final response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            "name": _enteredname,
            "quantity": _enteredquantity,
            "category": _enteredcategory.fruit
          }));
      final Map<String, dynamic> resdata = json.decode(response.body);
      if (!context.mounted) {
        return;
      }
      Navigator.of(context).pop(GroceryItem(
          id: resdata['name'],
          name: _enteredname,
          quantity: _enteredquantity,
          category: _enteredcategory));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a new item"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
            key: _formkey,
            child: Column(
              children: [
                TextFormField(
                  maxLength: 50,
                  decoration: const InputDecoration(
                    label: Text("name"),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length <= 1 ||
                        value.trim().length > 50) {
                      return 'Name should be in 1 to 50 characters';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _enteredname = value!;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        initialValue: _enteredquantity.toString(),
                        decoration: const InputDecoration(
                          label: Text("Quantity"),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null ||
                              int.tryParse(value)! <= 0) {
                            return 'Quantity should be grater than 0';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _enteredquantity = int.parse(value!);
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                        child: DropdownButtonFormField(
                            value: _enteredcategory,
                            items: [
                              for (final category in categories.entries)
                                DropdownMenuItem(
                                  value: category.value,
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 16,
                                        width: 16,
                                        color: category.value.color,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(category.value.fruit)
                                    ],
                                  ),
                                )
                            ],
                            onChanged: (value) {
                              _enteredcategory = value!;
                            }))
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: _issending
                            ? null
                            : () {
                                _formkey.currentState!.reset();
                              },
                        child: const Text("Reset")),
                    const SizedBox(width: 6),
                    ElevatedButton(
                        onPressed: _issending ? null : _onsubmit,
                        child: _issending
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(),
                              )
                            : const Text("Submit"))
                  ],
                )
              ],
            )),
      ),
    );
  }
}
