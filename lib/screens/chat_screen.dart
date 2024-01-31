import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/screens/login.dart';
import 'package:chat_app/widgets/bub_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ChatScreen extends StatelessWidget {
  ChatScreen({super.key, required this.email});
  final controller = ScrollController();
  final String email;

  TextEditingController message = TextEditingController();
  CollectionReference messages =
      FirebaseFirestore.instance.collection('messages');
  Stream<QuerySnapshot> messagesS = FirebaseFirestore.instance
      .collection('messages')
      .orderBy("time", descending: true)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    print("+++++++++++++++++++++++++++++++++++++++++++$email");
    return Scaffold(
      backgroundColor: Colors.white12,
      appBar: AppBar(
        title: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          alignment: Alignment.center,
          height: 50,
          decoration: BoxDecoration(boxShadow: const [
            BoxShadow(color: Colors.green, blurRadius: 15),
            BoxShadow(color: Colors.green, blurRadius: 15),
          ], color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat,
                color: Colors.green,
                size: 30,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                "Chat",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            alignment: Alignment.center,
            width: 50,
            height: 50,
            decoration: BoxDecoration(boxShadow: const [
              BoxShadow(color: Colors.red, blurRadius: 10),
              BoxShadow(color: Colors.red, blurRadius: 10),
            ], color: Colors.white, borderRadius: BorderRadius.circular(50)),
            child: IconButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  // ignore: use_build_context_synchronously
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Login(),
                      ),
                      (route) => false);
                },
                icon: const Icon(
                  Icons.exit_to_app,
                  size: 35,
                  color: Colors.red,
                )),
          )
        ],
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: messagesS,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            return Container(
              margin: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Expanded(
                      child: ListView.builder(
                    reverse: true,
                    controller: controller,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      if (snapshot.data!.docs[index]["id"] == email) {
                        return BubMessage(
                            message: MesssageModel.fromJson(
                                snapshot.data!.docs[index]));
                      } else {
                        return BubMessageAnother(
                            message: MesssageModel.fromJson(
                                snapshot.data!.docs[index]));
                      }
                    },
                  )),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          controller: message,
                          decoration: InputDecoration(
                              hintText: "Message",
                              hintStyle: const TextStyle(color: Colors.white30),
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue)),
                              enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5))),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        alignment: Alignment.center,
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                            boxShadow: const [
                              BoxShadow(color: Colors.blue, blurRadius: 10),
                            ],
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50)),
                        child: IconButton(
                          onPressed: () {
                            if (message.text.isNotEmpty) {
                              messages.add({
                                "message": message.text,
                                "time": DateTime.now(),
                                "id": email
                              });
                              message.text = "";
                            } else {
                              return;
                            }
                            controller.animateTo(0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeIn);
                          },
                          icon: const Icon(
                            Icons.send,
                            size: 35,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(color: Colors.teal),
            );
          }
        },
      ),
    );
  }
}
