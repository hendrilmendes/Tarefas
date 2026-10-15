import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  String title;
  bool completed;
  String? id;
  final DateTime? dateTime;
  final int priority;
  final String? project;
  final List<String> subtasks;
  final DateTime? createdAt;

  Task({
    required this.title,
    this.id,
    this.dateTime,
    this.completed = false,
    this.priority = 4,
    this.project,
    this.subtasks = const [],
    this.createdAt,
  });

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'completed': completed,
      'dateTime': dateTime,
      'priority': priority,
      if (project != null && project!.isNotEmpty) 'project': project,
      if (subtasks.isNotEmpty) 'subtasks': subtasks,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  static Task fromMap(Map<String, dynamic> map, String id) {
    return Task(
      title: map['title'] ?? '',
      completed: map['completed'] ?? false,
      dateTime: _parseDateTime(map['dateTime']),
      id: id,
      priority: (map['priority'] is int)
          ? (map['priority'] as int).clamp(1, 4)
          : 4,
      project: map['project'] as String?,
      subtasks: (map['subtasks'] is List)
          ? List<String>.from(map['subtasks'] as List)
          : const [],
      createdAt: _parseDateTime(map['createdAt']),
    );
  }

  static Task fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Task.fromMap(data, doc.id);
  }

  bool get isOverdue {
    if (completed || dateTime == null) return false;
    return dateTime!.isBefore(DateTime.now());
  }

  bool get isToday {
    if (dateTime == null) return false;
    final now = DateTime.now();
    return dateTime!.year == now.year &&
        dateTime!.month == now.month &&
        dateTime!.day == now.day;
  }

  Future<void> save() async {
    final docRef = tasksCollection.doc(id);
    if (id == null) {
      final newDoc = await tasksCollection.add(toMap());
      id = newDoc.id;
    } else {
      await docRef.set(toMap());
    }
  }

  Future<void> update() async {
    if (id != null) {
      await tasksCollection.doc(id).update(toMap());
    }
  }

  Future<void> delete() async {
    if (id != null) {
      await tasksCollection.doc(id).delete();
    }
  }
}

final CollectionReference tasksCollection = FirebaseFirestore.instance
    .collection('tasks');
