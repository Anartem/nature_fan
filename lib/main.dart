import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:nature_fan/modules/app/app_module.dart';
import 'package:nature_fan/modules/app/app_page.dart';
import 'package:nature_fan/modules/app/chooser_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Modular.setInitialRoute(ChooserPage.route);

  runApp(
    ModularApp(
      module: AppModule(),
      child: const AppPage(),
    ),
  );
}
