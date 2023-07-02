class CloudStorageException implements Exception {
  const CloudStorageException();
}

class CouldNotCreateRecipeException extends CloudStorageException {}

class CouldNotGetAllRecipesException extends CloudStorageException {}

class CouldNotUpdateRecipeException extends CloudStorageException {}

class CouldNotDeleteRecipeException extends CloudStorageException {}
