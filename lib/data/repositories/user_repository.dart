import 'package:appwrite/appwrite.dart';
import 'package:users_auth/core/constants/appwrite_constants.dart';
import 'package:users_auth/model/user_model.dart';

class UserRepository {
  final Databases databases;
  final Account account;

  UserRepository(this.databases, this.account);

  Future<UserModel> createUser(UserModel user) async {
    try {
      // Obtener el userId autenticado
      final currentUser = await account.get();
      final userId = currentUser.$id;

      // Crear nuevo UserModel con el userId incluido
      final userWithId = UserModel(
        id: '',
        username: user.username,
        email: user.email,
        userId: userId,
      );

      final response = await databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.collectionId,
        documentId: ID.unique(),
        data: userWithId.toJson(),
      );

      return UserModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserModel>> getUsers() async {
    try {
      final currentUser = await account.get();
      final userId = currentUser.$id;

      final response = await databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.collectionId,
        queries: [
          Query.equal('userId', userId),
        ],
      );

      return response.documents
          .map((doc) => UserModel.fromJson(doc.data))
          .toList();
    } catch (e) {
      rethrow;
    }
  }


  Future<void> deleteUser(String userId) async {
    try {
      await databases.deleteDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.collectionId,
        documentId: userId,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> updateUser(String userId, UserModel user) async {
    try {
      final response = await databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.collectionId,
        documentId: userId,
        data: user.toJson(),
      );

      return UserModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
