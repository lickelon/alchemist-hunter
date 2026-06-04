import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.subtitleMaxLines = 1,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final int subtitleMaxLines;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          subtitle,
          maxLines: subtitleMaxLines,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
