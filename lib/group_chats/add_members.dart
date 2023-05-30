import 'package:app_chat/Screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddMembersINGroup extends StatefulWidget {
  final String groupName, groupId;
  final List membersList;
  const AddMembersINGroup(
      {required this.membersList,
      required this.groupName,
      required this.groupId,
      Key? key})
      : super(key: key);

  @override
  State<AddMembersINGroup> createState() => _AddMembersINGroupState();
}

class _AddMembersINGroupState extends State<AddMembersINGroup> {
  final TextEditingController _search = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  List membersList = [];

  @override
  void initState() {
    super.initState();
    membersList = widget.membersList;
  }

  //busca un usuario, para agregar
  void onSearch() async {
    setState(() {
      isLoading = true;
    });

    await _firestore
        .collection('users')
        .where("email", isEqualTo: _search.text)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        isLoading = false;
      });
      print(userMap);
    });
  }

  void onAddMembers() async {
    membersList.add({
      "name": userMap!['name'],
      "email": userMap!['email'],
      "uid": userMap!['uid'],
      "isAdmin": false,
    });

    await _firestore.collection('groups').doc(widget.groupId).update({
      "members": membersList,
    });

    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('groups')
        .doc(widget.groupId)
        .set({
      "name": widget.groupName,
      "id": widget.groupId,
    });

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Members"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: size.height / 80,
            ),
            Container(
              height: size.height / 14,
              width: size.width,
              alignment: Alignment.center,
              child: Container(
                height: size.height / 14,
                width: size.width / 1.15,
                child: TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    hintText: "Search",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: size.height / 50,
            ),
            isLoading
                ? Container(
                    height: size.height / 12,
                    width: size.width / 12,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  )
                : ElevatedButton(
                    onPressed: onSearch,
                    child: const Text("Search"),
                  ),
            userMap != null
                ? ListTile(
                    onTap: onAddMembers,
                    leading: const Icon(Icons.account_box),
                    title: Text(userMap!['name']),
                    subtitle: Text(userMap!['email']),
                    trailing: const Icon(Icons.add),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
