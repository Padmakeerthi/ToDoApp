// Import MaterialApp and other widgets which we can use to quickly create a material app
import 'package:flutter/material.dart';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';

void main() => runApp(new TodoApp());

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(title: 'Todo', home: new TodoList());
  }
}

class TodoList extends StatefulWidget {
  @override
  createState() => new TodoListState();
}

class ToDoTaskInfo {
  // Name of the task
  String taskName;

  // Deadline of the task
  DateTime deadline;

  // If the task is completed
  bool isCompleted;

  // If the task is important
  bool isImportant;
}

class TodoListState extends State<TodoList> {
  List<ToDoTaskInfo> _todoTasks = [];

  // This will be called each time the + button is pressed
  void _addTodoTask(ToDoTaskInfo task) {
// Validation of the task happens on the form.
    setState(() => _todoTasks.add(task));
  }

  // Build the whole list of todo items
  Widget _buildTodoTaskList() {
    return new ListView.builder(
      itemBuilder: (context, index) {
        if (index < _todoTasks.length) {
          return _buildTodoTask(_todoTasks[index], index);
        }
      },
    );
  }

  // Build a single todo item
  Widget _buildTodoTask(ToDoTaskInfo todoTask, int index) {
    var dateFormat = DateFormat("yyyy-MM-dd");

    if (todoTask.isCompleted) {
      return new ListTile(
          leading: new Icon(Icons.check, color: Colors.green),
          title: new Text(
            todoTask.taskName,
            style: TextStyle(
                decoration: TextDecoration.lineThrough,
                fontStyle: FontStyle.italic),
          ),
          onTap: () => _promptRemoveTodoTask(index),
          trailing: Wrap(direction: Axis.horizontal, children: <Widget>[
            new FlatButton(
                onPressed: () {
                  _markAsImportantTodoTask(index);
                },
                child: new Icon(
                    todoTask.isImportant ? Icons.star : Icons.star_border)),
            new FlatButton(
                onPressed: () {
                  _removeTodoTask(index);
                },
                child: new Icon(Icons.delete))
          ]));
    }

    return new ListTile(
        leading: new Icon(Icons.access_time),
        title: new Text(todoTask.taskName,
            style: TextStyle(fontStyle: FontStyle.italic)),
        onTap: () => _promptRemoveTodoTask(index),
        trailing: Wrap(direction: Axis.horizontal, children: <Widget>[
          new Text(
              todoTask.deadline.difference(dateFormat
                          .parse(dateFormat.format(DateTime.now()))) >=
                      Duration.zero
                  ? todoTask.deadline
                          .difference(DateTime.now())
                          .inDays
                          .toString() +
                      " day to go!"
                  : "",
              style: TextStyle(color: Colors.cyan)),
          new FlatButton(
              onPressed: () {
                _markAsImportantTodoTask(index);
              },
              child: new Icon(
                  todoTask.isImportant ? Icons.star : Icons.star_border)),
          new FlatButton(
              onPressed: () {
                _removeTodoTask(index);
              },
              child: new Icon(Icons.delete))
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('My ToDo Items')),
      body: _buildTodoTaskList(),
      backgroundColor: Colors.blueGrey.shade50,
      floatingActionButton: new FloatingActionButton(
          onPressed: _pushAddTodoTaskScreen,
          // Pressing this button now opens the new screen
          tooltip: 'Add task',
          child: new Icon(Icons.add)),
    );
  }

  void _pushAddTodoTaskScreen() {
    // Push this page onto the stack
    Navigator.of(context).push(
        // MaterialPageRoute will automatically animate the screen entry, as well
        // as adding a back button to close it
        new MaterialPageRoute(builder: (context) {
      var _formKey = GlobalKey<FormState>();
      var _taskName = GlobalKey<FormFieldState>();
      var _deadline = GlobalKey<FormFieldState>();

      var format = DateFormat("yyyy-MM-dd");

      return new Scaffold(
        appBar: new AppBar(title: new Text('Add a new task')),
        body: Form(
            key: _formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                      key: _taskName,
                      decoration: InputDecoration(
                          labelText: 'Task Name', hintText: 'Name'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter the name of Task';
                        }
                        return null;
                      }),
                  DateTimeField(
                    key: _deadline,
                    decoration: InputDecoration(
                        labelText: 'Deadline for the task',
                        hintText: 'Deadline'),
                    format: format,
                    onShowPicker: (context, currentValue) {
                      return showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          initialDate: DateTime.now(),
                          lastDate: DateTime(2100));
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select the deadline';
                      }
                      return null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: RaisedButton(
                      onPressed: () {
                        // Validate will return true if the form is valid, or false if
                        // the form is invalid.
                        if (_formKey.currentState.validate()) {
                          var newTask = new ToDoTaskInfo();
                          newTask.taskName = _taskName.currentState.value;
                          newTask.deadline = _deadline.currentState.value;
                          newTask.isCompleted = false;
                          newTask.isImportant = false;

                          _addTodoTask(newTask);
                          Navigator.pop(context);
                        }
                      },
                      child: Text('Submit'),
                    ),
                  ),
                ])),
      );
    }));
  }

  // To delete a ToDo Task
  void _removeTodoTask(int index) {
    setState(() => _todoTasks.removeAt(index));
  }

  // To mark as a ToDo Task completed
  void _markCompleteTodoTask(int index) {
    _todoTasks[index].isCompleted = true;
    setState(() => _todoTasks);
  }

  // To mark as a ToDo Task important
  void _markAsImportantTodoTask(int index) {
    _todoTasks[index].isImportant = true;
    setState(() => _todoTasks);
  }

  void _promptRemoveTodoTask(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
              title: new Text(
                  'Did you complete the task "${_todoTasks[index].taskName}"?'),
              actions: <Widget>[
                new FlatButton(
                    child: new Text('NO'),
                    onPressed: () => Navigator.of(context).pop()),
                new FlatButton(
                    child: new Text('YES. I DID'),
                    onPressed: () {
                      _markCompleteTodoTask(index);
                      Navigator.of(context).pop();
                    })
              ]);
        });
  }
}
