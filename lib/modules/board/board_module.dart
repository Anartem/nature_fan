import 'package:flutter_modular/flutter_modular.dart';
import 'package:nature_fan/modules/board/ar_page.dart';
import 'package:nature_fan/modules/board/board_bloc.dart';
import 'package:nature_fan/modules/board/board_page.dart';

class BoardModule extends Module {
  static const route = "/board";

  @override
  List<Bind<Object>> get binds => [
    Bind((i) => BoardBloc()),
  ];

  @override
  List<ModularRoute> get routes => [
    RedirectRoute(route, to: "$route/"),
    ChildRoute("/", child: (_, __) => const BoardPage()),
    ChildRoute("/ar", child: (_, __) => const ArPage()),
  ];
}