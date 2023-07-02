import 'dart:math';

import 'package:my_groovy_recipes/services/auth/auth_exceptions.dart';
import 'package:my_groovy_recipes/services/auth/auth_provider.dart';
import 'package:my_groovy_recipes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group("Moch Authentication", () {
    final provider = MockAuthProvider();
    test("Should not be initialized at the beginning", () {
      expect(provider.isInitialized, false);
    });

    test("Cannot log out if not initialized", () {
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });

    test("Should be able to be initialized", () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test("User should be null after initialization", () {
      expect(provider.currentUser, null);
    });

    test("Should be able to initialize in less than 2 seconds", () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    }, timeout: const Timeout(Duration(seconds: 2)));

    test("Create user should delegate to login", () async {
      final badEmailUser = provider.createUser(
        email: "notrxistinguser@email.com",
        password: "password",
      );

      expect(badEmailUser,
          throwsA(const TypeMatcher<UserNotFoundAuthException>()));

      final badPasswordUser = provider.createUser(
        email: "someone@gmail.com",
        password: "foobar",
      );

      expect(badPasswordUser,
          throwsA(const TypeMatcher<WrongPasswordAuthException>()));

      final user = await provider.createUser(
        email: "aaa",
        password: "wrong",
      );

      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    test("Logged in user be able to get verified", () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test("Should be able to log out and log in again", () async {
      await provider.logOut();
      await provider.logIn(email: "email", password: "password");
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  var _isInitialized = false;
  AuthUser? _user;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    // check if initialized
    if (!isInitialized) throw NotInitializedException();

    // fake 1 second wait
    await Future.delayed(const Duration(seconds: 1));
    return logIn(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    // fake 1 second wait
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    // check if initialized
    if (!isInitialized) throw NotInitializedException();
    if (email == "notregisteredemail@gmail.com")
      throw UserNotFoundAuthException();
    if (password == "wrongpassword") throw WrongPasswordAuthException();
    const user =
        AuthUser(isEmailVerified: false, email: "foobar@gmail.com", id: "myid");
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();

    // fake 1 second wait
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser =
        AuthUser(isEmailVerified: true, email: "foobar@gmail.com", id: "myid");
    _user = newUser;
    throw UnimplementedError();
  }
}
