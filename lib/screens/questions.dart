import 'dart:io';
import 'package:flutter/material.dart';
import 'package:chat_app/main_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({Key? key}) : super(key: key);

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  final _userId = FirebaseAuth.instance.currentUser!.uid;
  final _storageRef = FirebaseStorage.instance.ref();
  FirebaseFirestore db = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  String _name = "";
  String _about = "";
  String _imageUrl = "";
  bool _showImg = false;

  late File _imageFile;

  _uploadImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
        _showImg = true;
      });

      try {
        final imageRef = _storageRef.child("images/${image.name}");
        await imageRef.putFile(_imageFile);
        _imageUrl = await imageRef.getDownloadURL();
      } on FirebaseException catch (e) {
        debugPrint("Error => ${e.message}");
      }
    } else {
      debugPrint("Error occurred while uploading image");
    }
  }

  _sendData() {
    final data = <String, String>{
      "name": _name,
      "about": _about,
      "image": _imageUrl,
      "user": _userId
    };

    db.collection("users").doc(_userId).set(data).then(
          (value) => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const MainPage(),
              )),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                const Text(
                  "Chat App",
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text("Setup your profile for the chat app"),
                const SizedBox(height: 30),
                _showImg
                    ? Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: FileImage(_imageFile),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: _uploadImage,
                          icon: const Icon(Icons.upload_outlined),
                        ),
                      ),
                const SizedBox(height: 10),
                Text(
                  _showImg ? "Image Uploaded ✅" : "Upload Image",
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                    decoration: const InputDecoration(
                      icon: Icon(Icons.person_outlined),
                      border: UnderlineInputBorder(),
                      labelText: "Name",
                      hintText: "Enter Your Name",
                    ),
                    onChanged: (text) => _name = text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your Name";
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                    decoration: const InputDecoration(
                      icon: Icon(Icons.person_outlined),
                      border: UnderlineInputBorder(),
                      labelText: "Bio",
                      hintText: "Tell About Yourself",
                    ),
                    onChanged: (text) => _about = text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please tell about yourself";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  margin: const EdgeInsets.all(10),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _sendData();
                      }
                    },
                    child: const Text("Next"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
