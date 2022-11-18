import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:nature_fan/modules/board/board_module.dart';
import 'package:nature_fan/modules/tree/tree_module.dart';

class ChooserPage extends StatelessWidget {
  static const route = "/chooser";

  const ChooserPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => Modular.to.pushReplacementNamed(TreeModule.route),
                child: const Text("Я - дерево"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Modular.to.pushReplacementNamed(BoardModule.route),
                child: const Text("Я - любитель природы"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
