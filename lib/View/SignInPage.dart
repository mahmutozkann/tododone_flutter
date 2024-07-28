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
            const Icon(
              Icons.fact_check_rounded,
              size: 150,
            ),
            const SizedBox(
              height: 16,
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade400)),
                  fillColor: Colors.grey.shade200,
                  filled: true,
                  labelText: Email),
            ),
            const SizedBox(
              height: 16,
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade400)),
                  fillColor: Colors.grey.shade200,
                  filled: true,
                  labelText: Password),
            ),
            const SizedBox(
              height: 16,
            ),
            const ForgotPassword(),
            ValueListenableBuilder<bool>(
                valueListenable: isButtonEnabled,
                builder: (context, value, child) {
                  return GestureDetector(
                    onTap: value ? signInUser : null,
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 25),
                      decoration: BoxDecoration(
                        color: value ? Colors.black : Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          "Sign In",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  );
                }),
            const SizedBox(
              height: 16,
            ),
            const Text("Don't you have an account? Register!"),
            const SizedBox(
              height: 16,
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SignUpPage()));
              },
              child: Container(
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 25),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    "Sign Up",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
