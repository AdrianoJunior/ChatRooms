import 'package:chat_room/pages/auth.dart';
import 'package:chat_room/utils/nav.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_room.dart';

class HomePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Rooms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _auth.signOut().then((value) {
                push(context, Auth(), replace: true);

              });
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _firestore.collection('rooms').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
          if(snapshot.data == null) {
            return const Center(child: Text('There\'s no Chat room created yet.'),);
          }
          List<Widget> roomList = [];
          for (var document in snapshot.data!.docs) {
            final data = document.data() as Map<String, dynamic>;
            roomList.add(
              ListTile(
                title: Text(data['name']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatRoom(document.id),
                    ),
                  );
                },
              ),
            );
          }

          return ListView(
            children: roomList,
          );
        },
      ),
    );
  }
}