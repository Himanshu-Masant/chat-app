import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    Key? key,
    required this.user,
    required this.id,
  }) : super(key: key);

  final String user;
  final String id;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userId = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController _msg = TextEditingController();
  FirebaseFirestore db = FirebaseFirestore.instance;

  String _docId = "";
  dynamic _data = {};
  Map _userOne = {};
  Map _userTwo = {};

  _submitMsg() {
    final connection = {
      "users": [widget.id, _userId],
      widget.id: _userOne,
      _userId: _userTwo,
    };

    final message = {
      "users": [widget.id, _userId],
      "msg": [
        {
          "content": _msg.text,
          "senderId": _userId,
        },
      ]
    };

    final exists = [
      {
        "content": _msg.text,
        "senderId": _userId,
      }
    ];

    if (_data == null) {
      db.collection("chats").doc(_docId).set(message);
      db.collection("connection").add(connection);
    } else {
      db.collection("chats").doc(_docId).update({
        "msg": FieldValue.arrayUnion(exists),
      });
    }

    setState(() {
      _msg.text = "";
    });
  }

  _getData() {
    final one = widget.id;
    final two = _userId;

    _docId = one.compareTo(two) < 0 ? "$one+$two" : "$two+$one";

    db.collection("users").doc(one).get().then((DocumentSnapshot doc) {
      _userOne = doc.data() as Map<String, dynamic>;
    });

    db.collection("users").doc(two).get().then((DocumentSnapshot doc) {
      _userTwo = doc.data() as Map<String, dynamic>;
    });
  }

  @override
  void initState() {
    _getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: db.collection("chats").doc(_docId).snapshots(),
      builder: (context, snapshot) {
        _data = snapshot.data?.data();

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.user),
          ),
          body: Column(
            children: [
              const SizedBox(height: 10),
              Expanded(
                child: _data == null
                    ? const Center(
                        child: Text("No Messages Found"),
                      )
                    : ListView.builder(
                        itemCount: _data["msg"].length,
                        itemBuilder: (e, index) {
                          return MessageText(
                            userId: _userId,
                            msgId: _data["msg"][index]["senderId"],
                            text: _data["msg"][index]["content"],
                          );
                        },
                      ),
              ),
              Form(
                key: _formKey,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                        decoration: const InputDecoration(
                          icon: Icon(Icons.email_outlined),
                          border: InputBorder.none,
                          hintText: "Type Here",
                        ),
                        controller: _msg,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your message";
                          }
                          return null;
                        },
                      ),
                    ),
                    IconButton(
                      color: Colors.teal,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _submitMsg();
                        }
                      },
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MessageText extends StatelessWidget {
  const MessageText({
    Key? key,
    required this.userId,
    required this.msgId,
    required this.text,
  }) : super(key: key);

  final String userId;
  final String msgId;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          msgId == userId ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          width: MediaQuery.of(context).size.width / 2.25,
          margin: const EdgeInsets.all(5),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.teal[100],
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(2, 2),
                blurRadius: 4,
              ),
            ],
            borderRadius: msgId == userId
                ? const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  )
                : const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }
}
