import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/components/chart_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  FirebaseFirestore db = FirebaseFirestore.instance;

  List _dataList = [];

  _readData() async {
    final userId = user.uid;
    final docRef =
        db.collection("connection").where("users", arrayContains: userId);
    QuerySnapshot querySnapshot = await docRef.get();
    final arr = querySnapshot.docs.map((doc) => doc.data()).toList();

    List allData = [];

    for (var element in arr) {
      final Map data = element as Map<String, dynamic>;
      data["users"].removeWhere((str) {
        return str == userId;
      });
      allData.add(data);
    }

    setState(() {
      _dataList = allData;
    });
  }

  @override
  void initState() {
    _readData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_dataList.isEmpty) {
      return const Center(
        child: Text("No Connection Found"),
      );
    }

    return ListView.builder(
      itemCount: _dataList.length,
      itemBuilder: (e, index) {
        final String user = _dataList[index]["users"][0];
        return ChatUserCard(
          uid: user,
          name: _dataList[index][user]["name"],
          desc: _dataList[index][user]["about"],
          image: _dataList[index][user]["image"],
        );
      },
    );
  }
}
