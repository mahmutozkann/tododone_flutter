import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  //for storing data in cloud firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //for authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //get current user uid
  String? get currentUserId => _auth.currentUser?.uid;

  //for signup screen
  Future<String> signUpUser({required String email, required String password, required String name}) async {
    String res = "Some error Occured";
    try {
      if (email.isNotEmpty || password.isNotEmpty || name.isNotEmpty) {
        //for register user in firebase auth with email and password
        UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        //for adding user to our cloud firestore
        await _firestore.collection("users").doc(credential.user!.uid).set({
          'name': name,
          "email": email,
          'uid': credential.user!.uid,
          //we cant store user password in our cloud firestore
        });
        res = "Successfully";
      }
    } catch (e) {
      return e.toString();
    }
    return res;
  }

  //for signin screen
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error Occured";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        //login user email and password
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        res = "Successfully";
      } else {
        res = "Please enter all the field!";
      }
    } catch (e) {
      return e.toString();
    }
    return res;
  }

  //For signOut
  Future<void> signOut() async {
    await _auth.signOut();
  }

  //For adding a task
  Future<String> addTask({
    required String title,
    required String description,
    required DateTime time,
  }) async {
    String res = "Some error Occured";
    try {
      //Get the current user
      User? user = _auth.currentUser;
      if (user != null) {
        //for adding task to the user's task collection
        await _firestore.collection("users").doc(user.uid).collection("tasks").add({
          'title': title,
          'description': description,
          'time': time,
          'isCompleted': false,
        });
        res = "Task added successfully!";
      } else {
        res = "No user is signed in";
      }
    } catch (e) {
      return e.toString();
    }
    return res;
  }

  //For fetching completed Tasks
  Stream<List<Map<String, dynamic>>> fetchCompletedTasks(String query) {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    Query firestoreQuery = _firestore
        .collection("users")
        .doc(userId)
        .collection("tasks")
        .where('isCompleted', isEqualTo: true)
        .orderBy('time', descending: true);

    if (query.isNotEmpty) {
      firestoreQuery = firestoreQuery.where('title', isEqualTo: query);
    }

    return firestoreQuery.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'taskId': doc.id,
          'title': doc['title'],
          'description': doc['description'],
          'time': doc['time'].toDate(),
          'isCompleted': doc['isCompleted']
        };
      }).toList();
    });
  }

  //For fetching not completed tasks
  Stream<List<Map<String, dynamic>>> fetchNotCompletedTasks(String query) {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    Query firestoreQuery = _firestore
        .collection("users")
        .doc(userId)
        .collection("tasks")
        .where('isCompleted', isEqualTo: false)
        .orderBy('time', descending: true);

    if (query.isNotEmpty) {
      firestoreQuery = firestoreQuery.where('title', isEqualTo: query);
    }

    return firestoreQuery.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'taskId': doc.id,
          'title': doc['title'],
          'description': doc['description'],
          'time': doc['time'].toDate(),
          'isCompleted': doc['isCompleted']
        };
      }).toList();
    });
  }

  //For updating task status
  Future<void> updateTaskStatus(String taskId, bool isCompleted) async {
    try {
      String uid = _auth.currentUser!.uid;
      await _firestore.collection('users').doc(uid).collection('tasks').doc(taskId).update({
        'isCompleted': isCompleted,
      });
    } catch (e) {
      print('Error updating task status: $e');
    }
  }

  //For deleting tasks
  Future<void> deleteTask(String taskId) async {
    try {
      String uid = _auth.currentUser!.uid;
      await _firestore.collection('users').doc(uid).collection('tasks').doc(taskId).delete();
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  //For editing tasks
  Future<String> updateTask({
    required String taskId,
    required String title,
    required String description,
  }) async {
    String res = "Some error Occured";
    try {
      String uid = _auth.currentUser!.uid;
      await _firestore.collection('users').doc(uid).collection('tasks').doc(taskId).update({
        'title': title,
        'description': description,
      });
      print("Task updated!");
      res = "Task updated successfully!";
    } catch (e) {
      print("Error: $e");
      return e.toString();
    }
    return res;
  }

  //For users information
  Future<Map<String, String>> fetchUserDetails() async {
    try {
      String uid = _auth.currentUser!.uid;
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      return {
        'name': userData['name'],
        'email': userData['email'],
      };
    } catch (e) {
      print('error fetching user details: $e');
      return {};
    }
  }

  //For totalTask : Progress Bar
  Future<Map<String, int>> fetchTaskStats() async {
    try {
      String uid = _auth.currentUser!.uid;
      QuerySnapshot completedSnapshot =
          await _firestore.collection('users').doc(uid).collection('tasks').where('isCompleted', isEqualTo: true).get();
      QuerySnapshot totalSnapshot = await _firestore.collection('users').doc(uid).collection('tasks').get();

      return {
        'completedTasks': completedSnapshot.docs.length,
        'totalTasks': totalSnapshot.docs.length,
      };
    } catch (e) {
      print('Error fetching task stats: $e');
      return {};
    }
  }
}
