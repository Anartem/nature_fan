import 'dart:async';

import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:nature_fan/models/anchor_model.dart';
import 'package:nature_fan/modules/board/board_bloc.dart';
import 'package:vector_math/vector_math_64.dart';

class ArPage extends StatefulWidget {
  static const route = "/ar";

  const ArPage({Key? key}) : super(key: key);

  @override
  State<ArPage> createState() => _ArPageState();
}

class _ArPageState extends State<ArPage> {
  static const Duration _delay = Duration(milliseconds: 2000);

  late final BoardBloc _bloc = Modular.get();

  late final ARSessionManager _arSessionManager;
  late final ARObjectManager _arObjectManager;
  late final ARAnchorManager _arAnchorManager;

  ARPlaneAnchor? _anchor;

  final ValueNotifier<bool> _busyNotifier = ValueNotifier(true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AR")),
      body: SafeArea(
        child: Stack(
          children: [
            ARView(
              onARViewCreated: _onArViewCreated,
              planeDetectionConfig: PlaneDetectionConfig.horizontal,
              showPlatformType: false,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ValueListenableBuilder<bool>(
                valueListenable: _busyNotifier,
                builder: (context, isBusy, _) {
                  String text = _anchor == null
                      ? "Перемещайте телефон, чтобы приложение смогло распознать сцену. Коснитесь распознанной поверхности, чтобы добавить уточку"
                      : "Коснитесь распознанной поверхности, чтобы переставить уточку";
                  return MaterialBanner(
                    content: Text(text),
                    actions: [
                      TextButton(
                        onPressed: isBusy || _anchor == null ? null : _onRemove,
                        child: const Text("Убрать"),
                      ),
                      TextButton(
                        onPressed: isBusy ? null : _onPost,
                        child: const Text("Опубликовать"),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onArViewCreated(
    ARSessionManager arSessionManager,
    ARObjectManager arObjectManager,
    ARAnchorManager arAnchorManager,
    ARLocationManager arLocationManager,
  ) {
    _arSessionManager = arSessionManager;
    _arObjectManager = arObjectManager;
    _arAnchorManager = arAnchorManager;

    _arSessionManager
      ..onInitialize(
        showFeaturePoints: false,
        showPlanes: true,
        showWorldOrigin: false,
        handleTaps: true,
        handlePans: false,
        handleRotation: false,
      )
      ..onPlaneOrPointTap = _onTap;

    _arObjectManager.onInitialize();

    _busyNotifier.value = false;

    _bloc.anchorStream.first.then(_onCreateScene);
  }

  void _onCreateScene(List<AnchorModel> list) async {
    _busyNotifier.value = true;

    await Future.delayed(_delay);

    for (AnchorModel model in list) {
      await _addAnchorFromMatrix(Matrix4.fromList(model.position)).then(_addNode);
    }

    _busyNotifier.value = false;
  }

  void _onTap(List<ARHitTestResult> hits) {
    if (_busyNotifier.value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            "Утки летят, подождите",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
          ),
        ),
      );
      return;
    }

    if (hits.indexWhere((element) => element.type == ARHitTestResultType.plane) == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            "Кликните по поверхности, показанной белыми точками",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
          ),
        ),
      );
      return;
    }

    _busyNotifier.value = true;
    _removeNode()
        .then((value) => _addAnchor(hits))
        .then((anchor) => _anchor = anchor)
        .then((anchor) => _addNode(anchor))
        .whenComplete(() => _busyNotifier.value = false);
  }

  void _onRemove() {
    if (_busyNotifier.value) {
      return;
    }

    _busyNotifier.value = true;

    _removeNode().whenComplete(() {
      _anchor = null;
      _busyNotifier.value = false;
    });
  }

  Future<ARNode?> _addNode(final ARPlaneAnchor? anchor) async {
    if (anchor != null) {
      ARNode node = ARNode(
        type: NodeType.fileSystemAppFolderGLB,
        uri: "duck.glb",
        scale: Vector3(0.2, 0.2, 0.2),
        position: Vector3(0.0, 0.0, 0.0),
        rotation: Vector4(1.0, 0.0, 0.0, 0.0),
      );

      try {
        _arObjectManager.addNode(node, planeAnchor: anchor);
      } catch (error) {

      }

      return Future.delayed(_delay).then((_) => node);
    }

    return null;
  }

  Future<ARPlaneAnchor?> _addAnchorFromMatrix(Matrix4 matrix) async {
    ARPlaneAnchor anchor = ARPlaneAnchor(transformation: matrix);
    try {
      _arAnchorManager.addAnchor(anchor);
    } catch (error) {

    }

    return Future.delayed(_delay).then((_) => anchor);
  }

  Future<ARPlaneAnchor?> _addAnchor(List<ARHitTestResult> hits) async {
    int index = hits.indexWhere((element) => element.type == ARHitTestResultType.plane);

    if (index != -1) {
      ARHitTestResult hit = hits[index];
      ARPlaneAnchor anchor = ARPlaneAnchor(transformation: hit.worldTransform);
      try {
        _arAnchorManager.addAnchor(anchor);
      } catch (error) {

      }

      return Future.delayed(_delay).then((_) => anchor);
    }

    return null;
  }

  Future<void> _removeNode() async {
    if (_anchor != null) {
      try {
        _arAnchorManager.removeAnchor(_anchor!);
      } catch (error) {

      }

      return Future.delayed(_delay);
    }
  }

  void _onPost() {
    List<double> buffer = List.generate(16, (index) => 0.0);
    _anchor?.transformation.copyIntoArray(buffer);
    _bloc.postAnchor(buffer);
    Modular.to.pop();
  }

  @override
  void dispose() {
    _arSessionManager.dispose();
    _busyNotifier.dispose();
    super.dispose();
  }
}
