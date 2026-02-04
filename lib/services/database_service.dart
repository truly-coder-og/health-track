import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/group_model.dart';
import '../models/workout_program.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // ==================== GROUPES ====================

  // Créer un groupe
  Future<GroupModel> createGroup({
    required String name,
    required String createdBy,
    required GroupType type,
    String? description,
  }) async {
    String inviteCode = _generateInviteCode();

    GroupModel group = GroupModel(
      id: '', // sera défini par Firestore
      name: name,
      createdBy: createdBy,
      members: [createdBy], // créateur = premier membre
      createdAt: DateTime.now(),
      type: type,
      description: description,
      inviteCode: inviteCode,
    );

    DocumentReference ref = await _firestore.collection('groups').add(group.toMap());

    // Ajouter le groupe aux groupIds de l'utilisateur
    await _firestore.collection('users').doc(createdBy).update({
      'groupIds': FieldValue.arrayUnion([ref.id]),
    });

    return group.copyWith(id: ref.id);
  }

  // Rejoindre un groupe via code d'invitation
  Future<void> joinGroup(String userId, String inviteCode) async {
    // Trouver le groupe avec ce code
    QuerySnapshot snapshot = await _firestore
        .collection('groups')
        .where('inviteCode', isEqualTo: inviteCode)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception('Code d\'invitation invalide');
    }

    String groupId = snapshot.docs.first.id;

    // Ajouter l'utilisateur au groupe
    await _firestore.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayUnion([userId]),
    });

    // Ajouter le groupe aux groupIds de l'utilisateur
    await _firestore.collection('users').doc(userId).update({
      'groupIds': FieldValue.arrayUnion([groupId]),
    });
  }

  // Récupérer les groupes d'un utilisateur
  Stream<List<GroupModel>> getUserGroups(String userId) {
    return _firestore
        .collection('groups')
        .where('members', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GroupModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Récupérer un groupe spécifique
  Future<GroupModel?> getGroup(String groupId) async {
    DocumentSnapshot doc = await _firestore.collection('groups').doc(groupId).get();
    
    if (!doc.exists) return null;

    return GroupModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  // Quitter un groupe
  Future<void> leaveGroup(String userId, String groupId) async {
    await _firestore.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayRemove([userId]),
    });

    await _firestore.collection('users').doc(userId).update({
      'groupIds': FieldValue.arrayRemove([groupId]),
    });
  }

  // ==================== WORKOUT PROGRAMS ====================

  // Créer un programme d'entraînement
  Future<WorkoutProgram> createWorkoutProgram(WorkoutProgram program) async {
    DocumentReference ref = await _firestore.collection('workoutPrograms').add(program.toMap());
    return program.copyWith(id: ref.id);
  }

  // Récupérer les programmes d'un groupe
  Stream<List<WorkoutProgram>> getGroupWorkoutPrograms(String groupId) {
    return _firestore
        .collection('workoutPrograms')
        .where('groupId', isEqualTo: groupId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WorkoutProgram.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Supprimer un programme (seulement créateur)
  Future<void> deleteWorkoutProgram(String programId) async {
    await _firestore.collection('workoutPrograms').doc(programId).delete();
  }

  // ==================== WORKOUT LOGS ====================

  // Logger une session d'entraînement
  Future<void> logWorkout(WorkoutLog log) async {
    await _firestore.collection('userWorkoutLogs').add(log.toMap());
  }

  // Récupérer l'historique d'entraînement d'un utilisateur
  Stream<List<WorkoutLog>> getUserWorkoutLogs(String userId, {int limit = 30}) {
    return _firestore
        .collection('userWorkoutLogs')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WorkoutLog.fromMap(doc.data(), doc.id))
            .toList());
  }

  // ==================== HELPERS ====================

  String _generateInviteCode() {
    // Génère un code court (6 caractères alphanumériques)
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(6, (index) => chars[DateTime.now().microsecond % chars.length]).join();
  }
}

// Extension pour copier GroupModel avec nouvel ID
extension GroupModelCopy on GroupModel {
  GroupModel copyWith({String? id}) {
    return GroupModel(
      id: id ?? this.id,
      name: name,
      createdBy: createdBy,
      members: members,
      createdAt: createdAt,
      type: type,
      description: description,
      inviteCode: inviteCode,
    );
  }
}

// Extension pour copier WorkoutProgram avec nouvel ID
extension WorkoutProgramCopy on WorkoutProgram {
  WorkoutProgram copyWith({String? id}) {
    return WorkoutProgram(
      id: id ?? this.id,
      groupId: groupId,
      createdBy: createdBy,
      name: name,
      description: description,
      exercises: exercises,
      createdAt: createdAt,
    );
  }
}
