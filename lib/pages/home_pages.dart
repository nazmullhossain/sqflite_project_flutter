import 'package:flutter/material.dart';

import '../helper/sqlf_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _journals = [];
  bool isLoading = true;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _refreshJounals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      isLoading = false;
    });
  }

  Future<void> _addItem() async {
    await SQLHelper.createItem(
        _titleController.text, _descriptionController.text);
    _refreshJounals();
    print("last ${_journals.length}");
  }


  Future <void>_update(int id)async{
    await SQLHelper.updateItem(id, _descriptionController.text, _titleController.text);
    _refreshJounals();
  }
void _deleteItem(int id)async{
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sucessfully delete")));
    _refreshJounals();
}
  

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshJounals();
    print("number of items ${_journals.length}");
  }

  void _showForm(int? id) async {
    if (id != null) {
      final existingJournal =
          _journals.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['title'];
      _descriptionController.text = existingJournal['description'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        builder: (context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                  top: 15,
                  left: 15,
                  right: 15,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 120),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(hintText: "title"),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(hintText: "description"),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (id == null) {
                          await _addItem();
                        }
                        if (id != null) {
                          await _update(id);
                        }
                        _titleController.text = "";
                        _descriptionController.text = "";
                        Navigator.of(context).pop();
                      },
                      child: Text(id == null ? "create New" : "update"))
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SQL"),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.builder(
          itemCount: _journals.length,
          itemBuilder: (context, index) {
            return Card(
              color: Colors.orange[200],
              margin: EdgeInsets.all(15),
              child: ListTile(
                title: Text(_journals[index]['title']),
                subtitle: Text(_journals[index]['description']),
              
              trailing: SizedBox(
                width: 100,
                child: Row(
                  children: [
                    IconButton(onPressed: (){
                   _showForm(_journals[index]['id']);
                    },
                        icon: Icon(Icons.edit)),
                    IconButton(onPressed: (){
                      _deleteItem(_journals[index]['id']);
                    },
                        icon: Icon(Icons.delete)),
                  ],
                ),
              ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showForm(null);
        },
        child: Icon(Icons.plus_one),
      ),
    );
  }
}
