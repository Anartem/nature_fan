import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:nature_fan/bl/socket_client.dart';
import 'package:nature_fan/models/anchor_model.dart';
import 'package:nature_fan/models/message_model.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

class BoardBloc implements Disposable {
  final BehaviorSubject<bool> _initController = BehaviorSubject();
  Stream<bool> get initStream => _initController.stream;

  final BehaviorSubject<bool> _statusController = BehaviorSubject();
  Stream<bool> get statusStream => _statusController.stream;

  final BehaviorSubject<List<MessageModel>> _listController = BehaviorSubject.seeded([]);
  Stream<List<MessageModel>> get listStream => _listController.stream;

  final BehaviorSubject<List<AnchorModel>> _anchorController = BehaviorSubject.seeded([]);
  Stream<List<AnchorModel>> get anchorStream => _anchorController.stream;

  SocketClient? _client;
  Completer? _refreshCompleter;

  BoardBloc() {
    _init();
  }

  void _init() async {
    ByteData data = await rootBundle.load("assets/duck.glb");
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, "duck.glb");
    await File(path).writeAsBytes(bytes);
  }

  void start(String address) async {
    _client = SocketClient()
      ..onStatus = _statusController.add
      ..onMessage = _onMessage
      ..onAnchor = _anchorController.add
      ..start(address);

    _initController.add(true);
  }

  void stop() {
    _initController.add(false);
    _listController.add([]);
    _anchorController.add([]);
    _client?.dispose();
  }

  void post(String message) {
    if (message.isNotEmpty) {
      _client?.postMessage(message);
    }
  }

  void postAnchor(List<double> position) {
    _client?.postAnchor(AnchorModel(position: position));
  }

  void _onMessage(List<MessageModel> update) {
    List<MessageModel> list = _listController.value;
    int timestamp = list.isEmpty ? 0 : list.first.timestamp;
    int newTimestamp = update.isEmpty ? 0 : update.first.timestamp;
    list = update..addAll(list);
    list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    _listController.add(list);
    if (newTimestamp <= timestamp) {
      _refreshCompleter?.complete();
      _refreshCompleter = null;
    }
  }

  Future<void> refresh() {
    List<MessageModel> list = _listController.value;
    _client?.refresh(list.isEmpty ? 0 : list.first.timestamp);
    _refreshCompleter ??= Completer();
    return _refreshCompleter!.future;
  }

  @override
  void dispose() {
    _initController.close();
    _statusController.close();
    _listController.close();
    _anchorController.close();
  }
}
