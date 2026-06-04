import 'package:flutter/material.dart';

class ListCard extends StatelessWidget {
  const ListCard({
    super.key,
    required this.name,
    required this.summary,
    this.icon = Icons.shield,
    this.onTap,
    this.summaryMaxLines = 1,
  });

  final String name;
  final String summary;
  final IconData icon;
  final VoidCallback? onTap;
  final int summaryMaxLines;

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon),
        title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          summary,
          maxLines: summaryMaxLines,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: onTap == null ? null : const Icon(Icons.chevron_right),
      ),
    );
  }
}
