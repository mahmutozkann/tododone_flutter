import 'package:flutter/material.dart';
import 'package:todo_app/Model/authentication.dart';

class ProgressBar extends StatefulWidget {
  const ProgressBar({super.key});

  @override
  _ProgressBarState createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar> {
  late Future<Map<String, String>> userDetailsFuture;
  late Future<Map<String, int>> taskStatsFuture;
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    userDetailsFuture = authService.fetchUserDetails();
    taskStatsFuture = authService.fetchTaskStats();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<Map<String, String>>(
        future: userDetailsFuture,
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (userSnapshot.hasError) {
            return const Text('Error fetching user details');
          }

          String userName = userSnapshot.data?['name'] ?? 'No name';
          String userEmail = userSnapshot.data?['email'] ?? 'No email';

          return FutureBuilder<Map<String, int>>(
            future: taskStatsFuture,
            builder: (context, taskSnapshot) {
              if (taskSnapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (taskSnapshot.hasError) {
                return const Text('Error fetching task stats');
              }

              int totalTasks = taskSnapshot.data?['totalTasks'] ?? 0;
              int completedTasks = taskSnapshot.data?['completedTasks'] ?? 0;
              double completionPercentage = totalTasks > 0 ? (completedTasks / totalTasks) : 0.0;

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.blue,
                          child: Text(
                            userName[0].toUpperCase(),
                            style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                            ),
                            Text(
                              userEmail,
                              style: const TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Total Tasks: $totalTasks',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Completed Tasks: $completedTasks',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
                        ),
                        const SizedBox(height: 32.0),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 220.0,
                              height: 220.0,
                              child: CircularProgressIndicator(
                                strokeCap: StrokeCap.round,
                                value: completionPercentage,
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                                strokeWidth: 20.0,
                                backgroundColor: Colors.green[100],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${(completionPercentage * 100).toStringAsFixed(1)}%',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Completed',
                                  style: TextStyle(fontSize: 18, color: Colors.green[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
