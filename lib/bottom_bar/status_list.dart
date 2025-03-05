import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StatusList extends StatelessWidget {
  final String status;

  const StatusList({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('request')
          .where('status', isEqualTo: status) // ✅ Filter requests by status
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var requests = snapshot.data!.docs;

        if (requests.isEmpty) {
          return Center(
            child: Text("No $status requests"),
          );
        }

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            var data = requests[index].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.all(10),
              child: ListTile(
                title: Text(data['location'] ?? "Unknown Location"),
                subtitle: Text("Area: ${data['area'] ?? 'N/A'}"),
                trailing: Text(data['status'].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            );
          },
        );
      },
    );
  }
}
