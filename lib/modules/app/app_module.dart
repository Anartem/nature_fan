import 'package:flutter_modular/flutter_modular.dart';
import 'package:nature_fan/modules/app/chooser_page.dart';
import 'package:nature_fan/modules/board/board_module.dart';
import 'package:nature_fan/modules/tree/tree_module.dart';

class AppModule extends Module {
  static const route = "/";

  @override
  List<Bind<Object>> get binds => [];

  @override
  List<ModularRoute> get routes => [
    ChildRoute(ChooserPage.route, child:(_, __) => const ChooserPage()),
    ModuleRoute(BoardModule.route, module: BoardModule()),
    ModuleRoute(TreeModule.route, module: TreeModule()),
  ];
}