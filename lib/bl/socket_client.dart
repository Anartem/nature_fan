import 'dart:convert';

import 'package:flutter_modular/flutter_modular.dart';
import 'package:nature_fan/models/anchor_model.dart';
import 'package:nature_fan/models/message_model.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketClient implements Disposable {
  late final Socket _client;

  void Function(bool)? onStatus;
  void Function(List<MessageModel>)? onMessage;
  void Function(List<AnchorModel>)? onAnchor;

  SocketClient() {
    _init();
  }

  void _init() {
    _client = io(
      'http://localhost:9000',
      OptionBuilder().setTransports(['websocket']).disableAutoConnect().build(),
    );

    _client.onConnect((_) {
      _client.emit('timestamp', 0);
    });

    _client.on('refresh', (data) {
      List<MessageModel> list = List.from(json.decode(data).map((e) => MessageModel.fromJson(e)));
      onMessage?.call(list);
    });

    _client.on('anchor', (data) {
      List<AnchorModel> list = List.from(json.decode(data).map((e) => AnchorModel.fromJson(e)));
      onAnchor?.call(list);
    });

    _client.onDisconnect((_) => onStatus?.call(false));
    _client.onConnect((_) => onStatus?.call(true));
    _client.onConnecting((_) => onStatus?.call(false));
    _client.onConnectError((error) => onStatus?.call(false));
  }

  void start(String address) {
    _client.io.uri = 'http://$address:9000';
    _client.connect();
  }

  void stop() {
    _client.disconnect();
    _client.clearListeners();
    _client.close();
  }

  void postMessage(String message) {
    _client.emit(
      'msg',
      MessageModel.fromString(
        message: message,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ).toJson(),
    );
  }

  void postAnchor(AnchorModel model) {
    _client.emit('anchor', model.toJson());
  }

  void refresh(int timestamp) {
    _client.emit('timestamp', timestamp);
  }

  @override
  void dispose() {
    _client.disconnect();
    _client.clearListeners();
    _client.close();
  }
}
