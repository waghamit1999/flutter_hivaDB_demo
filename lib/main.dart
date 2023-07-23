import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:use_of_hive_database/task.dart';
import 'package:uuid/uuid.dart';

late Box<Task> tasksDatabase;
void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  tasksDatabase = await Hive.openBox<Task>('tasksDatabase');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Colors.deepOrange.shade100),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Daily Task Manager'),
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
  List<Task> tasks = [];
  bool? isChecked = false;

  @override
  void initState() {
    super.initState();
    tasks = tasksDatabase.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.startToEnd,
                  onDismissed: (_) {
                    setState(() {
                      tasks.removeAt(index);
                      tasksDatabase.deleteAt(index);
                    });
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    child: const Icon(
                      Icons.delete_outline_outlined,
                      color: Colors.white,
                    ),
                  ),
                  child: Card(
                    child: ListTile(
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      subtitle: Text(
                        task.description,
                        style: TextStyle(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      trailing: Wrap(
                        spacing: 12,
                        children: <Widget>[
                          Checkbox(
                              value: task.isCompleted,
                              onChanged: (value) {
                                isChecked = value;
                                task.isCompleted = isChecked!;
                                setState(() {
                                  tasksDatabase.putAt(index, task);
                                });
                              }),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Icon(Icons.keyboard_arrow_right),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final taskNameTEC = TextEditingController();
          final taskDescriptionTEC = TextEditingController();
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Add Task'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: taskNameTEC,
                        decoration: InputDecoration(hintText: 'Task Name'),
                      ),
                      TextField(
                        controller: taskDescriptionTEC,
                        decoration:
                            InputDecoration(hintText: 'Task Description'),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                        onPressed: Navigator.of(context).pop,
                        child: Text('Cancel')),
                    ElevatedButton(
                        onPressed: () {
                          final taskId = Uuid().v4();
                          isChecked = false;
                          final task = Task(
                              id: taskId,
                              title: taskNameTEC.text,
                              description: taskDescriptionTEC.text,
                              isCompleted: isChecked!);

                          tasks.add(task);
                          tasksDatabase.add(task);
                          Navigator.of(context).pop();
                          setState(() {});
                        },
                        child: Text('Save')),
                  ],
                );
              });
        },
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ),
    );
  }
}
