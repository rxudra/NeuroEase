import 'package:cloud_firestore/cloud_firestore.dart';

import '../repositories/generic_repository.dart';

typedef FromMap<T> = T Function(Map<String, dynamic> m);

class FirestoreGenericRepository<T> implements GenericRepository<T> {
  FirestoreGenericRepository({
    required this.path,
    required this.fromMap,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final String path;
  final FromMap<T> fromMap;
  final FirebaseFirestore _firestore;

  @override
  Future<void> delete(String id) async {
    await _firestore.collection(path).doc(id).delete();
  }

  @override
  Future<List<T>> getAll() async {
    final snap = await _firestore.collection(path).get();
    return snap.docs.map((d) => fromMap({...d.data(), 'id': d.id})).toList();
  }

  @override
  Future<T?> getById(String id) async {
    final d = await _firestore.collection(path).doc(id).get();
    if (!d.exists) return null;
    return fromMap({...d.data() ?? {}, 'id': d.id});
  }

  @override
  Future<void> save(T item) async {
    // This generic implementation cannot serialize T; caller should implement concrete save
    throw UnimplementedError('Use concrete repository for saving');
  }
}
