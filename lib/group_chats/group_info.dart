// ignore_for_file: avoid_unnecessary_containers, sized_box_for_whitespace

import 'package:app_chat/Screens/home_screen.dart';
import 'package:app_chat/group_chats/add_members.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupInfo extends StatefulWidget {
  final String groupName, groupId;
  const GroupInfo({required this.groupName, required this.groupId, Key? key})
      : super(key: key);

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List membersList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getGroupMembers();
  }

  bool checkAdmin() {
    bool isAdmin = false;
    membersList.forEach((element) {
      if (element['uid'] == _auth.currentUser!.uid) {
        isAdmin = element['isAdmin'];
      }
    });
    return isAdmin;
  }

  void getGroupMembers() async {
    await _firestore
        .collection('groups')
        .doc(widget.groupId)
        .get()
        .then((value) {
      setState(() {
        membersList = value['members'];
        isLoading = false;
      });
    });
  }

  void showRemoveDialog(int index) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: ListTile(
              onTap: () => removeUser(index),
              title: const Text("Remove This Members"),
            ),
          );
        });
  }

//ELIMINAR USUARIO DEL GRUPO
  void removeUser(int index) async {
    if (checkAdmin()) {
      if (_auth.currentUser!.uid != membersList[index]['uid']) {
        setState(() {
          isLoading = true;
        });

        String uid = membersList[index]['uid'];

        membersList.removeAt(index);

        await _firestore.collection('groups').doc(widget.groupId).update({
          "members": membersList,
        });

        await _firestore
            .collection('users')
            .doc(uid)
            .collection('groups')
            .doc(widget.groupId)
            .delete();

        setState(() {
          isLoading = false;
        });
      }
    } else {
      print("Can't remove");
    }
  }

  //METOD DE SALIR DEL GRUPO, INFORMACION
  void onLeaveGroup() async {
    if (!checkAdmin()) {
      setState(() {
        isLoading = true;
      });

      String uid = _auth.currentUser!.uid;

      for (int i = 0; i < membersList.length; i++) {
        if (membersList[i]['uid'] == uid) {
          membersList.removeAt(i);
        }
      }
      await _firestore.collection('groups').doc(widget.groupId).update({
        "members": membersList,
      });

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('groups')
          .doc(widget.groupId)
          .delete();

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
          (route) => false);
    } else {
      print("Cant't left group");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: isLoading
            ? Container(
                height: size.height,
                width: size.width,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Align(
                        alignment: Alignment.centerLeft, child: BackButton()),
                    Container(
                      height: size.height / 8,
                      width: size.width / 1.1,
                      child: Row(
                        children: [
                          Container(
                            height: size.height / 11,
                            width: size.height / 11,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey,
                            ),
                            child: Icon(
                              Icons.group,
                              color: Colors.white,
                              size: size.width / 10,
                            ),
                          ),
                          SizedBox(
                            width: size.width / 20,
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                widget.groupName.toUpperCase(),
                                style: TextStyle(
                                  fontSize: size.width / 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: size.height / 20,
                    ),
                    Container(
                      width: size.width / 1.1,
                      child: Text(
                        "${membersList.length} Members",
                        style: TextStyle(
                          fontSize: size.width / 25,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: size.height / 25,
                    ),
                    //Member Name
                    ListTile(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddMembersINGroup(
                            groupId: widget.groupId,
                            groupName: widget.groupName,
                            membersList: membersList,
                          ),
                        ),
                      ),
                      leading: const Icon(
                        Icons.add,
                        color: Colors.redAccent,
                      ),
                      title: Text(
                        "Add Members",
                        style: TextStyle(
                          fontSize: size.width / 30,
                          fontWeight: FontWeight.w500,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),

                    Flexible(
                      child: ListView.builder(
                        itemCount: membersList.length,
                        shrinkWrap: true,
                        //scrool, mueve el pulsador de ariba o abajo
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () => showRemoveDialog(index),
                            leading: const Icon(Icons.account_circle_sharp),
                            title: Text(
                              membersList[index]['name'],
                              style: TextStyle(
                                fontSize: size.width / 30,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(membersList[index]['email']),
                            trailing: Text(
                                membersList[index]['isAdmin'] ? "Admin" : ""),
                          );
                        },
                      ),
                    ),

                    ListTile(
                      onTap: onLeaveGroup,
                      leading: const Icon(
                        Icons.logout,
                        color: Colors.redAccent,
                      ),
                      title: Text(
                        "Leave Group",
                        style: TextStyle(
                          fontSize: size.width / 30,
                          fontWeight: FontWeight.w500,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
