import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/custom_text_field.dart';
import 'registro.dart';

/// Pantalla de acceso
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _procesarLogin() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // El widget raíz escucha Firebase y muestra MyHome automáticamente.
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_mensajeDeError(error.code))));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No fue posible iniciar sesión. Intenta nuevamente.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mensajeDeError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'El correo electronico no es valido.';
      case 'user-not-found':
        return 'No existe una cuenta con ese correo.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'too-many-requests':
        return 'Demasiados intentos. Prueba mas tarde.';
      case 'network-request-failed':
        return 'Revisa tu conexión a Internet.';
      default:
        return 'No se pudo iniciar sesion. Intentalo nuevamente.';
    }
  }

  Future<void> _abrirRegistro() async {
    await Navigator.of(context)
        .push<void>(MaterialPageRoute(builder: (_) => const RegistroPage()));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Iniciar sesión',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CustomTextField(
                              label: 'Correo electrónico',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              enabled: !_isLoading,
                              validator: (value) {
                                final email = (value ?? '').trim();
                                if (email.isEmpty || !email.contains('@')) {
                                  return 'Introduce un correo válido.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              label: 'Contraseña',
                              controller: _passwordController,
                              obscureText: true,
                              enabled: !_isLoading,
                              validator: (value) => (value ?? '').isEmpty
                                  ? 'Introduce tu contraseña.'
                                  : null,
                            ),
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed: _isLoading ? null : _procesarLogin,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Ingresar'),
                            ),
                            TextButton(
                              onPressed: _isLoading ? null : _abrirRegistro,
                              child: const Text(
                                '¿No tienes cuenta? Regístrate aquí',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
