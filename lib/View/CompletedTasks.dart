import 'package:flutter/material.dart';
import 'package:todo_app/Model/authentication.dart';
import 'package:todo_app/View/TaskView.dart';

class CompletedTasks extends StatefulWidget {
  const CompletedTasks({super.key});

  @override
  _CompletedTasksState createState() => _CompletedTasksState();
}

class _CompletedTasksState extends State<CompletedTasks> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  void _closeKeyboard() {
    if (_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    AuthService authService = AuthService();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              labelText: 'Search Tasks',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: _closeKeyboard,
              ),
            ),
            onChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
            onEditingComplete: _closeKeyboard,
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: authService.fetchCompletedTasks(_searchQuery),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No completed tasks found."));
              }

              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var task = snapshot.data![index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      child: Row(
                        children: [
                          Container(
                              width: 3, height: 80, color: task['isCompleted'] == true ? Colors.black : Colors.grey),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: TaskView(
                                taskId: task['taskId'],
                                title: task['title'],
                                description: task['description'],
                                time: task['time'],
                                isCompleted: task['isCompleted'],
                                authService: authService,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
