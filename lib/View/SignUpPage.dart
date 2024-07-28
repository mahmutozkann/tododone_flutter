import 'package:flutter/material.dart';
import 'package:todo_app/Model/authentication.dart';
import 'package:todo_app/View/HomeView.dart';
import 'package:todo_app/View/snack_bar.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool isLoading = false;
  final ValueNotifier<bool> isButtonEnabled = ValueNotifier(false);

  void despose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
  }

  void _updateButtonState() {
    isButtonEnabled.value =
        _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty && _passwordController.text.length >= 8;
  }

  void signUpUser() async {
    String res = await AuthService()
        .signUpUser(email: _emailController.text, password: _passwordController.text, name: _nameController.text);
    //if signup is success, user has been created and navigate to the next screen otherwise show the error message
    if (res == "Successfully") {
      setState(() {
        isLoading = true;
      });
      //navigate to next page
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeView()));
    } else {
      setState(() {
        isLoading = false;
      });
      //show the error message
      ShowSnackBar(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    _emailController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
    var Email = "Email";
    var Password = "Password";
    var Username = "Username";
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
              controller: _nameController,
              decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade400)),
                  fillColor: Colors.grey.shade200,
                  filled: true,
                  labelText: Username),
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
            ValueListenableBuilder<bool>(
                valueListenable: isButtonEnabled,
                builder: (context, value, child) {
                  return GestureDetector(
                    onTap: value ? signUpUser : null,
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 25),
                      decoration: BoxDecoration(
                        color: value ? Colors.black : Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          "Sign Up",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
