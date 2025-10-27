import "dart:math";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter_application_1/components/button.dart";
import "package:flutter_application_1/components/text_field.dart";

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();

  // sign up user

  void signUp() async {
    //show loading circle
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // make sure password and confirm password match
    if (passwordTextController.text != confirmPasswordTextController.text) {
      // pop the loading circle
      Navigator.pop(context);
      // show error message
      displayMessage("Passwords do not match");
      return;
    }

    try {
      // create the User
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailTextController.text,
            password: passwordTextController.text,
          );

      //  after creating the user, create a new documnet in the firebase called Users
      FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email)
          .set({
            'username': emailTextController.text.split('@')[0],
            'bio': 'Empty Bio...',
          });

      //pop loading circle
      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      //  pop loading  circle
      Navigator.pop(context);

      displayMessage(e.code);
    }
  }

  // display a dialog message

  void displayMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(title: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                //logo
                const Icon(Icons.lock, size: 100),

                const SizedBox(height: 50),
                //welcome back message
                Text(
                  "Let's create an account for you!",
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),

                const SizedBox(height: 25),

                //email textfeild
                MyTextField(
                  controller: emailTextController,
                  hintText: 'Email',
                  obscureText: false,
                ),

                const SizedBox(height: 10),
                //password textfeild
                MyTextField(
                  controller: passwordTextController,
                  hintText: 'Password',
                  obscureText: true,
                ),

                const SizedBox(height: 10),
                MyTextField(
                  controller: confirmPasswordTextController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),

                const SizedBox(height: 25),

                // sign up button
                MyButton(onTap: signUp, text: 'Sign Up'),

                //go to register page
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.black),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "Login Now",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
