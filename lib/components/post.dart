import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/comment.dart';
import 'package:flutter_application_1/components/comment_button.dart';
import 'package:flutter_application_1/components/delete_button.dart';
import 'package:flutter_application_1/components/helper.dart';
import 'package:flutter_application_1/components/like_button.dart';

class Posts extends StatefulWidget {
  final String message;
  final String user;
  final String time;
  final String postId;
  final List<String> likes;

  const Posts({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
    required this.time,
  });

  @override
  State<Posts> createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  //user
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;

  // comment text cntroller

  final _commentTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  // toggle like
  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    // access the document in Firebase
    DocumentReference postRef = FirebaseFirestore.instance
        .collection("User Posts")
        .doc(widget.postId);

    if (isLiked) {
      // add the users email to the likes field
      postRef.update({
        "Likes": FieldValue.arrayUnion([currentUser.email]),
      });
    } else {
      // remove the users email from the likes field
      postRef.update({
        "Likes": FieldValue.arrayRemove([currentUser.email]),
      });
    }
  }

  // add a comment
  void addComment(String commentText) {
    FirebaseFirestore.instance
        .collection("User Posts")
        .doc(widget.postId)
        .collection("Comments")
        .add({
          "CommentText": commentText,
          "UserEmail": currentUser.email,
          "Timestamp": Timestamp.now(),
        });
  }

  // show dialog to add comment
  void showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Comment'),
        content: TextField(
          controller: _commentTextController,
          decoration: const InputDecoration(hintText: 'Enter your comment'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _commentTextController.clear();
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              addComment(_commentTextController.text);
              Navigator.pop(context);
              _commentTextController.clear();
            },
            child: Text("Post"),
          ),
        ],
      ),
    );
  }

  // delete a post
  void deletePost() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Post"),
        content: const Text("Are you sure you want to delete this post?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              // first delete all comments from the firbase
              // if we only delete the post document, the comments will still remain in firestore
              final commentDocs = await FirebaseFirestore.instance
                  .collection("User Posts")
                  .doc(widget.postId)
                  .collection("Comments")
                  .get();

              for (var doc in commentDocs.docs) {
                await FirebaseFirestore.instance
                    .collection("User Posts")
                    .doc(widget.postId)
                    .collection("Comments")
                    .doc(doc.id)
                    .delete();
              }

              // then delete the post

              FirebaseFirestore.instance
                  .collection("User Posts")
                  .doc(widget.postId)
                  .delete()
                  .then((value) => print("Post Deleted Successfully"))
                  .catchError(
                    (error) => print("Failed to delete post: $error"),
                  );

              // close the dialog
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // posts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // aligns text left
                  children: [
                    Text(widget.message),

                    const SizedBox(height: 5),

                    // user
                    Row(
                      children: [
                        Text(
                          widget.user,
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        Text(" . ", style: TextStyle(color: Colors.grey[400])),
                        Text(
                          widget.time,
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // delete button
              if (widget.user == currentUser.email)
                DeleteButton(onTap: deletePost),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // like
              Column(
                // liked button
                children: [
                  LikeButton(isLiked: isLiked, onTap: toggleLike),
                  const SizedBox(height: 5),
                  // like count
                  Text(
                    widget.likes.length.toString(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              // comment
              Column(
                children: [
                  CommentButton(onTap: showCommentDialog),
                  const SizedBox(height: 5),
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("User Posts")
                        .doc(widget.postId)
                        .collection("Comments")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Text('0', style: TextStyle(color: Colors.grey));
                      }
                      final commentCount = snapshot.data!.docs.length;
                      return Text(
                        commentCount.toString(),
                        style: TextStyle(color: Colors.grey),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // comment under post
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("User Posts")
                .doc(widget.postId)
                .collection("Comments")
                .orderBy("Timestamp", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: snapshot.data!.docs.map((doc) {
                  final commentData = doc.data() as Map<String, dynamic>;
                  return Comment(
                    text: commentData["CommentText"],
                    user: commentData["UserEmail"],
                    time: formateDate(commentData["Timestamp"]),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
