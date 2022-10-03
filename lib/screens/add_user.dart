import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/components/chart_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({Key? key}) : super(key: key);

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final user = FirebaseAuth.instance.currentUser!;
  FirebaseFirestore db = FirebaseFirestore.instance;

  List _dataList = [];
  String _searchQuery = "";

  _handleSearch() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Search Query : $_searchQuery")),
    );
  }

  _readData() async {
    final userId = user.uid;
    final docRef = db.collection("users").where("user", isNotEqualTo: userId);
    QuerySnapshot querySnapshot = await docRef.get();
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
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
      return Scaffold(
        appBar: AppBar(
          title: const Text("Add People"),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add People"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Form(
            key: _formKey,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextFormField(
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                      decoration: const InputDecoration(
                        icon: Icon(Icons.person_outlined),
                        border: InputBorder.none,
                        hintText: "Search Name",
                      ),
                      onChanged: (text) => _searchQuery = text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter search query";
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.teal,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    color: Colors.white,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _handleSearch();
                      }
                    },
                    icon: const Icon(Icons.search),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: _dataList.length,
              itemBuilder: (e, index) {
                return ChatUserCard(
                  uid: _dataList[index]["user"],
                  name: _dataList[index]["name"],
                  desc: _dataList[index]["about"],
                  image: _dataList[index]["image"],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
