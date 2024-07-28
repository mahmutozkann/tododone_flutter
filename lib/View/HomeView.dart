import 'package:flutter/material.dart';
import 'package:todo_app/Model/authentication.dart';
import 'package:todo_app/View/CompletedTasks.dart';
import 'package:todo_app/View/NotCompletedTasks.dart';
import 'package:todo_app/View/ProgressBar.dart';
import 'package:todo_app/View/SignInPage.dart';
import 'package:todo_app/View/snack_bar.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    const appBarTitle = "ToDoDone";
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () async {
              await AuthService().signOut();
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const SignInPage()));
            },
            icon: const Icon(Icons.logout),
            color: Colors.white,
          ),
          title: const Text(
            appBarTitle,
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          backgroundColor: Colors.black87,
          actions: [
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return AddNewTaskWidget();
                    });
              },
              icon: const Icon(Icons.add_circle),
              color: Colors.white,
            )
          ],
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25))),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: TabBar(
              isScrollable: true,
              tabs: [
                Tab(
                  child: Text(
                    "Completed Tasks",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Tab(
                  child: Text("Progress Bar", overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white)),
                ),
                Tab(
                  child: Text("Not Completed Tasks",
                      overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          ),
        ),
        body: const TabBarView(
          children: [CompletedTasks(), ProgressBar(), NotCompletedTasks()],
        ),
      ),
    );
  }
}

class AddNewTaskWidget extends StatelessWidget {
  AddNewTaskWidget({
    super.key,
  });

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ValueNotifier<bool> isButtonEnabled = ValueNotifier(false);

  void _updateButtonState() {
    isButtonEnabled.value = _titleController.text.isNotEmpty;
  }

  Future<void> _addTask(BuildContext context) async {
    AuthService authService = AuthService();
    String res = await authService.addTask(
        title: _titleController.text, description: _descriptionController.text, time: DateTime.now());

    if (res == "Task added successfully!") {
      Navigator.pop(context);
    } else {
      //show error
      ShowSnackBar(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    var taskTitle = "Task Title";
    var taskDescription = "Task Description";
    _titleController.addListener(_updateButtonState);

    return SizedBox(
      height: 300,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                    labelText: taskTitle),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                    labelText: taskDescription),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: isButtonEnabled,
                builder: (context, value, child) {
                  return ElevatedButton(
                    onPressed: value
                        ? () {
                            _addTask(context);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    child: const Text(
                      "Add",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
