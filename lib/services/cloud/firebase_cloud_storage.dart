import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_groovy_recipes/services/cloud/cloud_recipe.dart';
import 'package:my_groovy_recipes/services/cloud/cloud_storage_constants.dart';
import 'package:my_groovy_recipes/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final recipes = FirebaseFirestore.instance.collection("recipes");

// delete recipe from firestrore
  Future<void> deleteRecipe({required String documentId}) async {
    try {
      await recipes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteRecipeException();
    }
  }

// update recipe data in firestore
  Future<void> updateRecipe({
    required String documentId,
    required String name,
    required String description,
  }) async {
    try {
      await recipes.doc(documentId).update({
        nameFieldName: name,
        descriptionFieldName: description,
      });
    } catch (e) {
      throw CouldNotUpdateRecipeException();
    }
  }

// subscribe to changes in user's recipes in firestore
  Stream<Iterable<CloudRecipe>> allRecipes({required String ownerUserId}) =>
      recipes.snapshots().map(
            (event) => event.docs
                .map((doc) => CloudRecipe.fromSnapshot(doc))
                .where((recipe) => recipe.ownerUserId == ownerUserId),
          );

// fetch all of the user's recipes from firestore
  Future<Iterable<CloudRecipe>> getRecipes(
      {required String ownerUserId}) async {
    try {
      return await recipes
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserId,
          )
          .get()
          .then((value) => value.docs.map((doc) {
                return CloudRecipe(
                  documentId: doc.id,
                  ownerUserId: doc.data()[ownerUserIdFieldName] as String,
                  description: doc.data()[descriptionFieldName] as String,
                  name: doc.data()[nameFieldName] as String,
                );
              }));
    } catch (e) {
      throw CouldNotGetAllRecipesException();
    }
  }

  void createNewRecipe({required String ownerUserId}) async {
    await recipes.add({
      ownerUserIdFieldName: ownerUserId,
      nameFieldName: "",
      descriptionFieldName: ""
    });
  }

  // singleton pattern
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
