import 'package:example/main.dart';
import 'package:flutter/cupertino.dart';

class CellItem extends StatefulWidget {
  final Model? model;
  const CellItem({super.key, this.model});

  @override
  State<CellItem> createState() => CellItemState();
}

class CellItemState extends State<CellItem> {
  @override
  Widget build(BuildContext context) {
    debugPrint("更新这个widget");
    return Text(
        "This is index of ${widget.model?.index}, ${widget.model?.isDele == true ? "删除" : "添加"}",
        style: const TextStyle(fontSize: 30));
  }
}
