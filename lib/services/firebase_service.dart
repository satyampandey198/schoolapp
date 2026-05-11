import 'package:cloud_firestore/cloud_firestore.dart';

/// Central decoupled service to manage all Cloud Firestore database interactions
class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch the latest announcements stream from the database
  Stream<QuerySnapshot> getAnnouncementsStream() {
    return _firestore
        .collection('announcements')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Fetch homework for a specific user or class
  Stream<QuerySnapshot> getHomeworkStream(String classId) {
    return _firestore
        .collection('homework')
        .where('classId', isEqualTo: classId)
        // Note: You may need a composite index in Firebase for this specific query
        .orderBy('dueDate', descending: false) 
        .snapshots();
  }
  
  // Future methods like publishAnnouncement or markHomeworkComplete can go here
}
