// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CrudHomePage extends StatefulWidget {
  const CrudHomePage({super.key});

  @override
  State<CrudHomePage> createState() => _CrudHomePageState();
}

class _CrudHomePageState extends State<CrudHomePage> {
  final TextEditingController controller = TextEditingController();
  List items = [];

  // For Flutter Web, use localhost **with IP**
  final String apiUrl = "https://backend-projects-n1ad.onrender.com/items";

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  // GET Items
  Future<void> fetchItems() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          items = jsonDecode(response.body);
        });
      }
    } catch (e) {
      debugPrint("Error fetching items: $e");
    }
  }

  // CREATE Item
  Future<void> addItem() async {
    if (controller.text.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": controller.text}),
      );

      if (response.statusCode == 200) {
        controller.clear();
        fetchItems();
      }
    } catch (e) {
      debugPrint("Error adding item: $e");
    }
  }

  // UPDATE Item
  Future<void> editItem(String id) async {
    try {
      final response = await http.put(
        Uri.parse("$apiUrl/$id"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": controller.text}),
      );

      if (response.statusCode == 200) {
        controller.clear();
        fetchItems();
      }
    } catch (e) {
      debugPrint("Error editing item: $e");
    }
  }

  // DELETE Item
  Future<void> deleteItem(String id) async {
    try {
      await http.delete(Uri.parse("$apiUrl/$id")); 
      fetchItems();
    } catch (e) {
      debugPrint("Error deleting item: $e");
    }
  }

  void showEditDialog(String id, String currentName) {
    controller.text = currentName;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Update Item"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Enter updated value"),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Save"),
            onPressed: () {
              editItem(id);
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter CRUD (Node + MongoDB)"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: "Enter item",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: addItem,
                  child: const Text("Add"),
                )
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, index) {
                  final item = items[index];
                  final id = item["_id"];
                  final name = item["name"];

                  return Card(
                    child: ListTile(
                      title: Text(name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => showEditDialog(id, name),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteItem(id),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
