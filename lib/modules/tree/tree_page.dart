import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:nature_fan/modules/tree/tree_bloc.dart';

class TreePage extends StatefulWidget {
  const TreePage({Key? key}) : super(key: key);

  @override
  State<TreePage> createState() => _TreePageState();
}

class _TreePageState extends State<TreePage> {
  late final TreeBloc _bloc = Modular.get();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder(
          stream: _bloc.initStream,
          builder: (context, snapshot) {
            bool isInit = snapshot.data ?? false;
            if (isInit) {
              return Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StreamBuilder<bool>(
                      stream: _bloc.statusStream,
                      builder: (context, snapshot) {
                        bool enable = snapshot.data ?? false;
                        return Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: enable ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _bloc.stop,
                      child: const Text("Прервать"),
                    ),
                    const SizedBox(width: 16),
                    FutureBuilder<String>(
                      future: _bloc.getIp(),
                      builder: (context, snapshot) {
                        return Text(snapshot.data ?? "");
                      },
                    ),
                  ],
                ),
              );
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "Поднимите точку доступа и запустите вещание, чтобы любители природы могли к ней подключиться",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
                ButtonBar(
                  children: [
                    const TextButton(
                      onPressed: AppSettings.openHotspotSettings,
                      child: Text("Точка доступа"),
                    ),
                    ElevatedButton(
                      onPressed: _bloc.start,
                      child: const Text("Запустить вещание"),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
