import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appwrite/appwrite.dart';

import 'package:users_auth/core/config/app_config.dart';
import 'package:users_auth/data/repositories/auth_repository.dart';
import 'package:users_auth/controllers/auth_controller.dart';
import 'package:users_auth/controllers/user_controller.dart';
import 'package:users_auth/data/repositories/user_repository.dart';
import 'package:users_auth/presentation/pages/splash_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuración del cliente Appwrite
  final client = AppwriteConfig.initClient();
  final databases = Databases(client);
  final account = Account(client);

  // Inyección de dependencias de la base de datos
  Get.put(UserRepository(databases, account));
  Get.put(UserController(repository: Get.find<UserRepository>()));

  // Inyección de dependencias para la autenticación
  Get.put(AuthRepository(account));
  Get.put(AuthController(Get.find<AuthRepository>()));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Appwrite Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: false,
      ),
      home: const SplashPage(),
    );
  }
}
