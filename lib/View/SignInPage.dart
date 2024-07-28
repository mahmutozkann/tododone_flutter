import 'package:flutter/material.dart';
import 'package:todo_app/Model/authentication.dart';
import 'package:todo_app/View/ForgotPassword.dart';
import 'package:todo_app/View/HomeView.dart';
import 'package:todo_app/View/SignUpPage.dart';
import 'package:todo_app/View/snack_bar.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  final ValueNotifier<bool> isButtonEnabled = ValueNotifier(false);

  void _updateButtonState() {
    isButtonEnabled.value = _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;
  }

  void signInUser() async {
    String res = await AuthService().loginUser(email: _emailController.text, password: _passwordController.text);
    //if signIn success
    if (res == "Successfully") {
      setState(() {
        isLoading = true;
      });
      //Navigate to next page
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomeView()));
    } else {
      setState(() {
        isLoading = false;
      });
      //show error
      ShowSnackBar(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    var SignIn = "Sign In";
    var Email = "Email";
    var Password = "Password";
    _emailController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          SignIn,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 16,
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                  labelText: Email),
            ),
            const SizedBox(
              height: 16,
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                  labelText: Password),
            ),
            const SizedBox(
              height: 16,
            ),
            const ForgotPassword(),
            ValueListenableBuilder<bool>(
                valueListenable: isButtonEnabled,
                builder: (context, value, child) {
                  return ElevatedButton(onPressed: value ? signInUser : null, child: const Text("Sign In"));
                }),
            const SizedBox(
              height: 16,
            ),
            const Text("Don't you have an account? Register!"),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SignUpPage()));
                },
                child: const Text("Sign Up")),
          ],
        ),
      ),
    );
  }
}
