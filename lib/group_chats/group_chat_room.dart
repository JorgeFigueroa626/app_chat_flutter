// ignore_for_file: sized_box_for_whitespace

import 'package:app_chat/group_chats/group_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupChatRoom extends StatelessWidget {
  final String groupChatId, groupName;
  GroupChatRoom({required this.groupName, required this.groupChatId, Key? key})
      : super(key: key);
  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> chatData = {
        "sendBy": _auth.currentUser!.displayName,
        "message": _message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      _message.clear();

      await _firestore
          .collection('groups')
          .doc(groupChatId)
          .collection('chats')
          .add(chatData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Group Name"),
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>  GroupInfo(
                        groupName: groupName,
                        groupId: groupChatId,
                      ),
                    ),
                  ),
              tooltip: "Info Group",
              icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: size.height / 1.27,
              width: size.width,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('groups')
                    .doc(groupChatId)
                    .collection('chats')
                    .orderBy('time')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> chatMap =
                            snapshot.data!.docs[index].data()
                                as Map<String, dynamic>;
                        return messageTile(size, chatMap);
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            Container(
              height: size.height / 10,
              width: size.width,
              alignment: Alignment.center,
              child: Container(
                height: size.height / 12,
                width: size.width / 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: size.height / 15,
                      width: size.width / 1.16,
                      child: TextField(
                        controller: _message,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () => {},
                              icon: const Icon(
                                Icons.photo,
                                size: 30,
                                color: Colors.grey,
                              ),
                            ),
                            //hintStyle: const TextStyle(color: Colors.black),
                            hintText: "Send Message",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            )),
                      ),
                    ),
                    SizedBox(
                      width: size.width / 130,
                    ),
                    Container(
                      height: size.height / 15,
                      width: size.width / 11,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: IconButton(
                          icon: const Icon(
                            Icons.send,
                            size: 30,
                            color: Colors.white,
                          ),
                          onPressed: onSendMessage),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget messageTile(Size size, Map<String, dynamic> chatMap) {
    return Builder(
      builder: (_) {
        if (chatMap['type'] == "text") {
          return Container(
            width: size.width,
            alignment: chatMap['sendBy'] == _auth.currentUser!.displayName
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 9),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.blue,
                ),
                child: Column(
                  children: [
                    Text(
                      chatMap['sendBy'],
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: size.height / 200,
                    ),
                    Text(
                      chatMap['message'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )),
          );
        } else if (chatMap['type'] == "img") {
          return Container(
            width: size.width,
            alignment: chatMap['sendBy'] == _auth.currentUser!.displayName
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 9),
              height: size.height / 2,
              child: Image.network(
                chatMap['message'],
              ),
            ),
          );
        } else if (chatMap['type'] == "notify") {
          return Container(
            width: size.width,
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromARGB(186, 158, 158, 158),
              ),
              child: Text(
                chatMap['message'],
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                ),
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
