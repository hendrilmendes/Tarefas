import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  String title;
  bool completed;
  final String id;
  final DateTime? dateTime;

  Task(
      {required this.title,
      required this.id,
      this.dateTime,
      this.completed = false,
      DateTime? dueDate});
}

List<Task> tasks = [];
final CollectionReference tasksCollection =
    FirebaseFirestore.instance.collection('tasks');
