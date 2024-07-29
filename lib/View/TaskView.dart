import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/Model/authentication.dart';

class TaskView extends StatelessWidget {
  final String taskId;
  final String title;
  final String description;
  final DateTime time;
  final bool isCompleted;
  final AuthService authService;

  const TaskView({
    super.key,
    required this.taskId,
    required this.title,
    required this.description,
    required this.time,
    required this.isCompleted,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    //Formatted Time
    String formattedTime = DateFormat('yyyy-MM-dd HH:mm').format(time);
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık ve Butonlar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      highlightColor: Colors.yellow,
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return AddTaskWidget(
                              taskId: taskId,
                              initialTitle: title,
                              initialDescription: description,
                              authService: authService,
                            );
                          },
                        );
                      },
                    ),
                    IconButton(
                      highlightColor: Colors.grey,
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await authService.deleteTask(taskId);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Task Description
            Text(
              description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
            const SizedBox(height: 8),

            // Task Time ve Checkbox
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedTime,
                  style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
                ),
                Checkbox(
                  value: isCompleted,
                  onChanged: (bool? value) async {
                    if (value != null) {
                      await authService.updateTaskStatus(taskId, value);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddTaskWidget extends StatelessWidget {
  final String taskId;
  final String initialTitle;
  final String initialDescription;
  final AuthService authService;

  AddTaskWidget({
    super.key,
    required this.taskId,
    required this.initialTitle,
    required this.initialDescription,
    required this.authService,
  });

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ValueNotifier<bool> isButtonEnabled = ValueNotifier(false);

  void _updateButtonState() {
    isButtonEnabled.value = _titleController.text.isNotEmpty &&
        _titleController.text != initialTitle &&
        _descriptionController.text != initialDescription;
  }

  Future<void> _updateTask(BuildContext context) async {
    String res = await authService.updateTask(
      taskId: taskId,
      title: _titleController.text,
      description: _descriptionController.text,
    );

    if (res == "Task updated successfully!") {
      Navigator.pop(context);
    } else {
      //show error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res)));
    }
  }

  @override
  Widget build(BuildContext context) {
    _titleController.text = initialTitle;
    _descriptionController.text = initialDescription;
    _titleController.addListener(_updateButtonState);
    _descriptionController.addListener(_updateButtonState);

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
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  labelText: "Task Title",
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  labelText: "Task Description",
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: isButtonEnabled,
                builder: (context, value, child) {
                  return ElevatedButton(
                    onPressed: value
                        ? () {
                            _updateTask(context);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    child: const Text(
                      "Update",
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
