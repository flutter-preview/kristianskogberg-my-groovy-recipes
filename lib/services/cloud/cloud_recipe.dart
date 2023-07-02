import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_groovy_recipes/services/cloud/cloud_storage_constants.dart';

@immutable
class CloudRecipe {
  final String documentId;
  final String ownerUserId;
  final String description;
  final String name;

  const CloudRecipe({
    required this.documentId,
    required this.ownerUserId,
    required this.description,
    required this.name,
  });

  CloudRecipe.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName],
        description = snapshot.data()[descriptionFieldName] as String,
        name = snapshot.data()[nameFieldName] as String;
}
