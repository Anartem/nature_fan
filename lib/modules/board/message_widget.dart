import 'package:flutter/material.dart';
import 'package:nature_fan/models/message_model.dart';

class MessageWidget extends StatelessWidget {
  final MessageModel _message;

  const MessageWidget(this._message, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _message.message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            Text(
              _convert(DateTime.fromMillisecondsSinceEpoch(_message.timestamp)),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.secondary),
            ),
          ],
        ),
      ),
    );
  }

  String _convert(DateTime time) =>
      "${time.year.toString()}.${time.month.toString().padLeft(2, '0')}.${time.day.toString().padLeft(2, '0')} ${time.hour.toString().padLeft(2, '0')}.${time.minute.toString().padLeft(2, '0')}.${time.second.toString().padLeft(2, '0')}";
}
