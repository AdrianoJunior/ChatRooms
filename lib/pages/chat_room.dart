import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatRoom extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String roomId;

  final _messageController = TextEditingController();

  ChatRoom(this.roomId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Room'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _auth.signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _firestore
                  .collection('rooms')
                  .doc(roomId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                List<Widget> messageList = [];
                for (var document in snapshot.data!.docs) {
                  final data = document.data() as Map<String, dynamic>;
                  final String message = data['message'];
                  final String userName = data['userName'];

                  messageList.add(
                    ListTile(
                      title: Text('$userName: $message'),
                    ),
                  );
                }

                return ListView(
                  children: messageList,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onSubmitted: (String value) {
                      _sendMessage(value);
                    },


                    controller: _messageController,
                    decoration: const InputDecoration(
                      labelText: 'Enter message',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    _sendMessage(_messageController.text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage([String message = '']) async {
    if (message.isNotEmpty) {
      final User? user = _auth.currentUser;
      final userData = await _firestore.collection('users').doc(user!.uid).get();
      final String userName = userData.data()!['name'];

      await _firestore
          .collection('rooms')
          .doc(roomId)
          .collection('messages')
          .add({
        'message': message,
        'userName': userName,
        'timestamp': FieldValue.serverTimestamp(),
      }).then((value) {
        _messageController.clear();
      });
    }
  }
}
