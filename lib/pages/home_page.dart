import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/drawer.dart';
import 'package:flutter_application_1/components/helper.dart';
import 'package:flutter_application_1/components/post.dart';
import 'package:flutter_application_1/components/text_field.dart';
import 'package:flutter_application_1/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // user
  final currentUser = FirebaseAuth.instance.currentUser!;

  // text controller
  final textController = TextEditingController();

  // sign user out
  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  // post message
  void postMessage() {
    // only if the text field is not empty
    if (textController.text.isNotEmpty) {
      // store in firestore
      FirebaseFirestore.instance.collection("User Posts").add({
        "Message": textController.text,
        "UserEmail": currentUser.email,
        "Timestamps": Timestamp.now(),
        "Likes": [],
      });
    }

    // clear the text field
    setState(() {
      textController.clear();
    });
  }

  // go to profile page
  void goToProfilePage() {
    Navigator.pop(context); // close the drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),

        title: Center(
          child: const Text(
            'The Blogging App',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      drawer: MyDrawer(onProfileTap: goToProfilePage, onLogoutTap: signOut),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("User Posts")
                    .orderBy("Timestamps", descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        // get the message
                        final post = snapshot.data!.docs[index];
                        return Posts(
                          message: post['Message'],
                          user: post['UserEmail'],
                          postId: post.id,
                          likes: List<String>.from(post['Likes'] ?? []),
                          time: formateDate(post['Timestamps']),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text("Error" + snapshot.error.toString()),
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),

            // post message textfield
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                children: [
                  // text field
                  Expanded(
                    child: MyTextField(
                      controller: textController,
                      hintText: "write Something ",
                      obscureText: false,
                    ),
                  ),

                  // post button
                  IconButton(onPressed: postMessage, icon: Icon(Icons.send)),
                ],
              ),
            ),

            // logged in user details
            Text("Logged in as " + currentUser.email!),

            const SizedBox(height: 50),

            // list of blog posts
          ],
        ),
      ),
    );
  }
}
