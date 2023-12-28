import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  String title;
  bool completed;

  Task({required this.title, this.completed = false});
}

List<Task> tasks = [];
final CollectionReference tasksCollection =
      FirebaseFirestore.instance.collection('tasks');