import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  String title;
  bool completed;
  String? id;
  final DateTime? dateTime;

  Task({required this.title, this.id, this.dateTime, this.completed = false});

  // Converte o objeto Task para um Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'completed': completed,
      'dateTime': dateTime?.millisecondsSinceEpoch,
    };
  }

  // Converte um Map para uma instância de Task
  static Task fromMap(Map<String, dynamic> map, String id) {
    return Task(
      title: map['title'] ?? '',
      completed: map['completed'] ?? false,
      dateTime: map['dateTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dateTime'])
          : null,
      id: id,
    );
  }

  // Salva a tarefa no Firestore e define o ID gerado automaticamente
  Future<void> save() async {
    final docRef = tasksCollection.doc(id);
    if (id == null) {
      final newDoc = await tasksCollection.add(toMap());
      id = newDoc.id;
    } else {
      await docRef.set(toMap());
    }
  }

  // Atualiza a tarefa no Firestore
  Future<void> update() async {
    if (id != null) {
      await tasksCollection.doc(id).update(toMap());
    }
  }

  // Exclui a tarefa do Firestore
  Future<void> delete() async {
    if (id != null) {
      await tasksCollection.doc(id).delete();
    }
  }
}

// Referência à coleção de tarefas no Firestore
final CollectionReference tasksCollection = FirebaseFirestore.instance
    .collection('tasks');
