import 'dart:io';

import 'package:flutter_modular/flutter_modular.dart';
import 'package:nature_fan/bl/anchor_storage.dart';
import 'package:nature_fan/bl/mesage_storage.dart';
import 'package:nature_fan/bl/socket_server.dart';
import 'package:nature_fan/models/anchor_model.dart';
import 'package:rxdart/rxdart.dart';

class TreeBloc implements Disposable {
  late final MessageStorage _messageStorage;
  late final AnchorStorage _anchorStorage;

  final BehaviorSubject<bool> _initController = BehaviorSubject();
  Stream<bool> get initStream => _initController.stream;

  final BehaviorSubject<bool> _statusController = BehaviorSubject();
  Stream<bool> get statusStream => _statusController.stream;

  SocketServer? _server;

  TreeBloc(this._messageStorage, this._anchorStorage);

  void start() {
    _initController.add(true);
    _server = SocketServer()
      ..onStatus = _statusController.add
      ..onMessage = _messageStorage.insertData
      ..onRefresh = _messageStorage.getData
      ..onAnchor = _onAnchor
      ..start();
  }

  void stop() {
    _initController.add(false);
    _server?.dispose();
  }

  Future<List<AnchorModel>> _onAnchor(final AnchorModel? anchor) async {
    if (anchor != null) {
      await _anchorStorage.insertData(anchor);
    }
    return _anchorStorage.getData();
  }

  Future<String> getIp() async {
    List<NetworkInterface> list = await NetworkInterface.list();
    return list.firstWhere((element) => element.name == "wlan0").addresses.first.address;
  }

  @override
  void dispose() {
    _server?.dispose();
    _statusController.close();
    _initController.close();
  }
}