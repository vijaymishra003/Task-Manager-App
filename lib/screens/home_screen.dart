import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mode/task.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home-screen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _taskController;
  List<Task>? _tasks;
  List<bool>? _tasksDone;

  void saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Task t = Task.fromString(_taskController.text);
    String? tasks = prefs.getString('task');

    List<dynamic> list =
        tasks != null ? json.decode(tasks) as List<dynamic> : [];
    // print(list);
    list.add(json.encode(t.getMap()));
    prefs.setString('task', json.encode(list));
    _taskController.text = '';
    Navigator.of(context).pop();

    _getTasks();
  }

  void _getTasks() async {
    _tasks = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tasks = prefs.getString('task');
    List<dynamic> list =
        tasks != null ? json.decode(tasks) as List<dynamic> : [];
    for (dynamic d in list) {
      _tasks?.add(Task.fromMap(json.decode(d)));
    }

    // print(_tasks);

    _tasksDone = List.generate(_tasks!.length, (index) => false);
    setState(() {});
  }

  void updatePendingtasksLists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Task> pendingList = [];
    for (var i = 0; i < _tasks!.length; i++) {
      if (!_tasksDone![i]) pendingList.add(_tasks![i]);
    }

    var pendingListencoded = List.generate(
      pendingList.length,
      (i) => json.encode(
        pendingList[i].getMap(),
      ),
    );

    prefs.setString(
      'task',
      json.encode(pendingListencoded),
    );

    _getTasks();
  }

  @override
  void initState() {
    super.initState();
    _taskController = TextEditingController();
    _getTasks();
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Task Manager',
          style: GoogleFonts.montserrat(),
        ),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            onPressed: () => updatePendingtasksLists(),
            icon: const Icon(Icons.save),
          ),
          IconButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString('task', json.encode([]));
              _getTasks();
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: (_tasks!.isEmpty)
          ? Center(
              child: Text(
                '''Tasks aren't added yet!''',
                style: GoogleFonts.montserrat(),
              ),
            )
          : Column(
              children: _tasks!
                  .map(
                    (e) => Container(
                      height: 70.0,
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 4.0,
                      ),
                      padding: const EdgeInsets.only(
                        left: 10.0,
                      ),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          border: Border.all(
                            color: Colors.orange,
                            width: 0.5,
                          )),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            e.task as String,
                            style: GoogleFonts.montserrat(),
                          ),
                          Checkbox(
                            value: _tasksDone![_tasks!.indexOf(e)],
                            key: GlobalKey(),
                            onChanged: (val) {
                              setState(
                                () {
                                  _tasksDone![_tasks!.indexOf(e)] = val as bool;
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) => Container(
            height: MediaQuery.of(context).size.height * 0.82,
            color: Colors.orange.shade200,
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add Task',
                      style: GoogleFonts.montserrat(
                          color: const Color.fromARGB(255, 121, 73, 1),
                          fontSize: 20.0),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(thickness: 1.2),
                const SizedBox(height: 20.0),
                TextField(
                  controller: _taskController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: const BorderSide(color: Colors.orange),
                    ),
                    fillColor: const Color.fromARGB(255, 252, 238, 213),
                    filled: true,
                    hintText: "Enter the Task",
                    hintStyle: GoogleFonts.montserrat(),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      Container(
                        width: (MediaQuery.of(context).size.width / 2) - 20,
                        child: ElevatedButton(
                          onPressed: () => _taskController.text = '',
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: Text(
                            'Reset',
                            style: GoogleFonts.montserrat(),
                          ),
                        ),
                      ),
                      Container(
                        width: (MediaQuery.of(context).size.width / 2) - 20,
                        child: ElevatedButton(
                          onPressed: () => saveData(),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange),
                          child: Text(
                            'Add',
                            style: GoogleFonts.montserrat(),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        backgroundColor: Colors.orange,
        child: const Icon(
          Icons.add,
          color: Color.fromARGB(255, 248, 228, 197),
        ),
      ),
    );
  }
}
