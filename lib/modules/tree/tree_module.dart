import 'package:flutter_modular/flutter_modular.dart';
import 'package:nature_fan/bl/anchor_storage.dart';
import 'package:nature_fan/bl/mesage_storage.dart';
import 'package:nature_fan/modules/tree/tree_bloc.dart';
import 'package:nature_fan/modules/tree/tree_page.dart';

class TreeModule extends Module {
  static const route = "/tree";

  @override
  List<Bind<Object>> get binds => [
    Bind((i) => MessageStorage()),
    Bind((i) => AnchorStorage()),
    Bind((i) => TreeBloc(Modular.get(), Modular.get())),
  ];

  @override
  List<ModularRoute> get routes => [
    RedirectRoute(route, to: "$route/"),
    ChildRoute("/", child: (_, __) => const TreePage()),
  ];
}