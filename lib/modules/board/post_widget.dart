import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:nature_fan/modules/board/board_bloc.dart';

class PostWidget extends StatefulWidget {
  const PostWidget({Key? key}) : super(key: key);

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  late final BoardBloc _bloc = Modular.get();

  final TextEditingController _inputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              keyboardType: TextInputType.text,
              maxLines: 1,
              maxLength: 80,
              decoration: const InputDecoration(
                hintText: "Введите сообщение",
              ),
            ),
          ),
          const SizedBox(width: 16),
          StreamBuilder<bool>(
            stream: _bloc.statusStream,
            builder: (context, snapshot) {
              bool isEnabled = snapshot.data ?? false;
              return Row(
                children: [
                  IconButton(
                    onPressed: isEnabled ? _onPost : null,
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    icon: const Icon(Icons.add),
                  ),
                  const SizedBox(width: 16,),
                  TextButton(
                    onPressed: isEnabled ? _onAR : null,
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: const Text("AR"),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _onPost() {
    _bloc.post(_inputController.text);
    _inputController.clear();
  }

  void _onAR() {
    Modular.to.pushNamed("./ar");
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }
}
