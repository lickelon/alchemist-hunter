import 'package:flutter/material.dart';

class ListCard extends StatelessWidget {
  final String name;
  final String description;
  final String buttonText;
  final IconData icon;

  const ListCard({
    super.key,
    required this.name,
    required this.description,
    required this.buttonText,
    this.icon = Icons.shield,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(2),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: Icon(icon),
          title: Text(name),
          subtitle: Text(description),
          trailing: ElevatedButton(onPressed: () {}, child: Text(buttonText)),
        ),
      ),
    );
  }
}
