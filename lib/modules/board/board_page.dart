import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:nature_fan/models/message_model.dart';
import 'package:nature_fan/modules/board/board_bloc.dart';
import 'package:nature_fan/modules/board/message_widget.dart';
import 'package:nature_fan/modules/board/post_widget.dart';

class BoardPage extends StatefulWidget {
  const BoardPage({Key? key}) : super(key: key);

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  late final BoardBloc _bloc = Modular.get();

  final RegExp _ipRegExp = RegExp(r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)');
  final TextEditingController _inputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder(
          stream: _bloc.initStream,
          builder: (context, snapshot) {
            bool isInit = snapshot.data ?? false;
            if (isInit) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
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
                          child: const Text("Отключиться"),
                        ),
                      ],
                    ),
                  ),
                  Container(height: 1, color: Theme.of(context).colorScheme.surfaceVariant),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _bloc.refresh,
                      child: StreamBuilder<List<MessageModel>>(
                        stream: _bloc.listStream,
                        builder: (context, snapshot) {
                          List<MessageModel> list = snapshot.data ?? [];
                          return ListView(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            children: list.map((value) => MessageWidget(value)).toList(),
                          );
                        },
                      ),
                    ),
                  ),
                  Container(height: 1, color: Theme.of(context).colorScheme.surfaceVariant),
                  const PostWidget(),
                ],
              );
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      "Поключитесь к вещанию для отправки и получения сообщений",
                      textAlign: TextAlign.center,
                      style:
                      Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _onClient,
                    child: const Text("Подключиться"),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _onClient() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Подключиться к существующему вещанию"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Введите IP адрес, который отображается в приложении организатора вещания."),
              TextField(
                controller: _inputController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: "192.168.1.83",
                ),
              ),
            ],
          ),
          actions: [
            ButtonBar(
              children: [
                TextButton(
                  child: const Text("Позже"),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: const Text("Подключиться"),
                  onPressed: () {
                    Navigator.pop(context);
                    RegExpMatch? match = _ipRegExp.firstMatch(_inputController.text);
                    if (match != null) {
                      _bloc.start(match[0]!);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Неправильный IP адрес")),
                      );
                    }
                  },
                ),
              ],
            )
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }
}
