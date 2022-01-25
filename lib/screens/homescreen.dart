import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login_page/config/config.dart';
import 'loginscreen.dart';
import 'package:firebase_storage/firebase_storage.dart';

enum MenuOption { Add, Remove }

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _taskTxtController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  User user;
  FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    getUid();
    super.initState();
  }

  void getUid() async {
    User u = await _auth.currentUser;
    setState(() {
      user = u;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Task App"),
          actions: [
            PopupMenuButton(
              onSelected: (MenuOption selectedValue) {
                if (selectedValue == MenuOption.Add) {
                  _showAddTaskDiaglog();
                } else {}
              },
              icon: Icon(Icons.more_vert),
              itemBuilder: (_) => [
                PopupMenuItem(child: Text("Add Task"), value: MenuOption.Add),
                PopupMenuItem(
                    child: Text("Remove Task"), value: MenuOption.Remove),
              ],
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showAddTaskDiaglog();
          },
          child: Icon(
            Icons.add,
            color: Colors.black,
          ),
          elevation: 4,
          backgroundColor: primaryColor,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              IconButton(icon: Icon(Icons.menu), onPressed: () {}),
              IconButton(
                  icon: Icon(Icons.person_outline),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  })
            ],
          ),
        ),
        body: Container(
          margin: EdgeInsets.only(top: 100),
          child: StreamBuilder(
              stream: _db
                  .collection("users")
                  .doc(user.uid)
                  .collection("tasks")
                  .orderBy("date", descending: true)
                  .snapshots(),
              builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data.docs.isNotEmpty) {
                  } else {
                    return Container(
                      child: Center(
                          child:
                              Image(image: AssetImage("assets/no_task.png"))),
                    );
                  }
                  return ListView(
                    children: snapshot.data.docs.map((snap) {
                      return ListTile(
                        title: Text(snap.data()["task"]),
                        onTap: () {},
                        trailing: IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              _db
                                  .collection("users")
                                  .doc(user.uid)
                                  .collection("tasks")
                                  .doc(snap.id)
                                  .delete();
                            }),
                        leading: Radio(
                          value: true,
                          groupValue: true,
                        ),
                      );
                    }).toList(),
                  );
                }
              }),
        ));
  }

  void _showAddTaskDiaglog() {
    showDialog(
        context: context,
        builder: (ctx) {
          return SimpleDialog(
            title: Text("Add Task"),
            children: [
              Container(
                margin: EdgeInsets.all(10),
                child: TextField(
                  controller: _taskTxtController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Write your Task Here",
                      labelText: "Task Name"),
                ),
              ),
              Container(
                  margin: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("Cancel")),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: primaryColor,
                        ),
                        child: Text("Add"),
                        onPressed: () async {
                          String task = _taskTxtController.text.trim();
                          final User user =
                              await FirebaseAuth.instance.currentUser;
                          _db
                              .collection("users")
                              .doc(user.uid)
                              .collection("tasks")
                              .add({
                            "task": task,
                            "date": DateTime.now(),
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  )),
            ],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          );
        });
  }
}
