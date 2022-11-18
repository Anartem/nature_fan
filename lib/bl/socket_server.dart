import 'dart:convert';

import 'package:flutter_modular/flutter_modular.dart';
import 'package:nature_fan/models/anchor_model.dart';
import 'package:nature_fan/models/message_model.dart';
import 'package:socket_io/socket_io.dart';

class SocketServer implements Disposable {
  static const _port = 9000;

  late final Server _server;

  void Function(bool)? onStatus;
  Future<int> Function(MessageModel)? onMessage;
  Future<List<MessageModel>> Function(int)? onRefresh;
  Future<List<AnchorModel>> Function(AnchorModel?)? onAnchor;

  SocketServer() {
    _init();
  }

  void _init() {
    _server = Server();

    _server.on('connection', (client) {
      onAnchor?.call(null).then((data) => client.emit('anchor', jsonEncode(data.map((i) => i.toJson()).toList())));

      client.on('timestamp', (data) {
        onRefresh?.call(data).then((data) => client.emit('refresh', jsonEncode(data.map((i) => i.toJson()).toList())));
      });

      client.on('msg', (data) {
        MessageModel model = MessageModel.fromJson(data);
        _server.emit('refresh', jsonEncode([model].map((i) => i.toJson()).toList()));
        onMessage?.call(model);
      });

      client.on('anchor', (data) {
        AnchorModel model = AnchorModel.fromJson(data);
        onAnchor?.call(model).then((data) => _server.emit('anchor', jsonEncode(data.map((i) => i.toJson()).toList())));
      });
    });
  }

  void start() async {
    await _server.listen(_port);
    onStatus?.call(true);
  }

  @override
  dispose() {
    _server.close();
  }
}
