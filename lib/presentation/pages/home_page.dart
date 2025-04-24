import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:users_auth/controllers/auth_controller.dart';
import 'package:users_auth/controllers/user_controller.dart';
import 'package:users_auth/model/user_model.dart';
import 'package:users_auth/data/repositories/user_repository.dart';

class HomePage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();

  HomePage({super.key});

  void _submitUser(UserController controller, Account account) async {
    if (_formKey.currentState!.validate()) {
      try {
        final currentUser = await account.get();
        final userId = currentUser.$id;

        final newUser = UserModel(
          id: '',
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          userId: userId,
        );

        await controller.addUser(newUser);
        _usernameController.clear();
        _emailController.clear();
        Get.snackbar('Éxito', 'Usuario agregado correctamente');
      } catch (e) {
        Get.snackbar('Error', 'Error al crear usuario: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserController>();
    final account = Get.find<UserRepository>().account;

    return Scaffold(
      appBar: AppBar(
        title: Text('Usuarios con Appwrite'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => Get.find<AuthController>().logout(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(labelText: 'Username'),
                      validator: (value) =>
                          value!.isEmpty ? 'Campo requerido' : null,
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      validator: (value) =>
                          value!.isEmpty ? 'Campo requerido' : null,
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => _submitUser(controller, account),
                      child: Text('Agregar Usuario'),
                    ),
                  ],
                ),
              ),
            ),
            if (controller.error.value.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Error: ${controller.error.value}',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: controller.users.length,
                itemBuilder: (context, index) {
                  final user = controller.users[index];

                  return ListTile(
                    title: Text(user.username),
                    subtitle: Text(user.email),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _emailController.text = user.email;
                            _usernameController.text = user.username;
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Actualizar Usuario'),
                                content: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextFormField(
                                        controller: _usernameController,
                                        decoration:
                                            InputDecoration(labelText: 'Username'),
                                        validator: (value) =>
                                            value!.isEmpty ? 'Campo requerido' : null,
                                      ),
                                      TextFormField(
                                        controller: _emailController,
                                        decoration:
                                            InputDecoration(labelText: 'Email'),
                                        validator: (value) =>
                                            value!.isEmpty ? 'Campo requerido' : null,
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        controller.updateUser(
                                          user.id,
                                          UserModel(
                                            id: user.id,
                                            username: _usernameController.text,
                                            email: _emailController.text,
                                            userId: user.userId,
                                          ),
                                        );
                                        Navigator.pop(context);
                                        _usernameController.clear();
                                        _emailController.clear();
                                      }
                                    },
                                    child: Text('Actualizar'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Confirmar eliminación'),
                                content: Text('¿Está seguro de eliminar este usuario?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      controller.deleteUser(user.id);
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: Text('Eliminar'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
