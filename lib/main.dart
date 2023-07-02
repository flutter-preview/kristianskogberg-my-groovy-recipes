import 'package:flutter/material.dart';
import 'package:my_groovy_recipes/constants/routes.dart';
import 'package:my_groovy_recipes/services/auth/auth_service.dart';
import 'package:my_groovy_recipes/views/login_view.dart';
import 'package:my_groovy_recipes/views/my_recipes_view.dart';
import 'package:my_groovy_recipes/views/register_view.dart';
import 'package:my_groovy_recipes/views/verify_email_view.dart';

// VIDEO KOHTA: 12:18.00

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'My Groovy Recipes',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: const HomePage(),
    routes: {
      loginRoute: (context) => const LoginView(),
      registerRoute: (context) => const RegisterView(),
      myRecipesRoute: (context) => const MyRecipesView(),
      verifyEmailRoute: (context) => const VerifyEmailView(),
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                // email is verified
                return const MyRecipesView();
              } else {
                // email is not verified
                return const VerifyEmailView();
              }
            } else {
              // there is no user, navigate to login
              return const LoginView();
            }

          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
