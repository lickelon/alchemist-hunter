import 'package:flutter/material.dart';

class ListCard extends StatelessWidget {
  final String name;
  final String description;
  final String? buttonText;
  final IconData icon;
  final VoidCallback? onTap;
  final VoidCallback? onButtonPressed;

  const ListCard({
    super.key,
    required this.name,
    required this.description,
    this.buttonText,
    this.icon = Icons.shield,
    this.onTap,
    this.onButtonPressed,
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
          onTap: onTap,
          leading: Icon(icon),
          title: Text(name),
          subtitle: Text(description),
          trailing: buttonText == null
              ? const Icon(Icons.chevron_right)
              : ElevatedButton(
                  onPressed: onButtonPressed ?? onTap,
                  child: Text(buttonText!),
                ),
        ),
      ),
    );
  }
}
