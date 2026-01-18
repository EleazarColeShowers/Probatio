import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/collection_model.dart';

abstract class CollectionLocalDataSource {
  Future<void> createCollection(CollectionModel collection);
  Future<List<CollectionModel>> getCollections();
  Future<void> updateCollection(CollectionModel collection);
  Future<void> deleteCollection(String collectionId);
}

class CollectionLocalDataSourceImpl implements CollectionLocalDataSource {
  static const String boxName = 'collections';

  Box<Map>? _box;

  Future<Box<Map>> get box async {
    _box ??= await Hive.openBox<Map>(boxName);
    return _box!;
  }

  @override
  Future<void> createCollection(CollectionModel collection) async {
    try {
      final collectionBox = await box;
      final id = collection.id ?? DateTime.now().millisecondsSinceEpoch.toString();

      final collectionWithId = collection.copyWith(
        id: id,
        createdAt: collection.createdAt ?? DateTime.now(),
      );

      await collectionBox.put(id, collectionWithId.toJson());
    } catch (e) {
      throw CacheException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<List<CollectionModel>> getCollections() async {
    try {
      final collectionBox = await box;
      final collections = <CollectionModel>[];

      for (var item in collectionBox.values) {
        collections.add(CollectionModel.fromJson(Map<String, dynamic>.from(item)));
      }

      collections.sort((a, b) =>
          (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now())
      );

      return collections;
    } catch (e) {
      throw CacheException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<void> updateCollection(CollectionModel collection) async {
    try {
      if (collection.id == null) {
        throw CacheException(
          message: 'Cannot update collection without ID',
          statusCode: 400,
        );
      }
      final collectionBox = await box;
      await collectionBox.put(collection.id, collection.toJson());
    } catch (e) {
      throw CacheException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<void> deleteCollection(String collectionId) async {
    try {
      final collectionBox = await box;
      await collectionBox.delete(collectionId);
    } catch (e) {
      throw CacheException(message: e.toString(), statusCode: 500);
    }
  }
}
