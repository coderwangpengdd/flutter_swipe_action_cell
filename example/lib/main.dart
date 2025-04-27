/*
 * @Author: 王鹏 peng.wang@bigmarker.com
 * @Date: 2025-04-24 18:25:45
 * @LastEditors: 王鹏 peng.wang@bigmarker.com
 * @LastEditTime: 2025-04-27 13:58:33
 * @FilePath: /example/lib/main.dart
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import 'package:example/cell_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      /// Add this SwipeActionNavigatorObserver to close opening cell when navigator changes its routes
      /// 添加这个可以在路由切换的时候统一关闭打开的cell，全局有效
      navigatorObservers: [SwipeActionNavigatorObserver()],
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CupertinoButton.filled(
            child: const Text('Enter new page'),
            onPressed: () {
              Navigator.push(context,
                  CupertinoPageRoute(builder: (c) => const SwipeActionPage()));
            }),
      ),
    );
  }
}

class Model {
  String id = UniqueKey().toString();
  int index = 0;
  bool isDele = false;

  @override
  String toString() {
    return index.toString();
  }
}

class SwipeActionPage extends StatefulWidget {
  const SwipeActionPage({Key? key}) : super(key: key);

  @override
  _SwipeActionPageState createState() => _SwipeActionPageState();
}

class _SwipeActionPageState extends State<SwipeActionPage> {
  List<Model> list = List.generate(30, (index) {
    return Model()..index = index;
  });

  late SwipeActionController controller;

  @override
  void initState() {
    super.initState();
    controller = SwipeActionController(selectedIndexPathsChangeCallback:
        (changedIndexPaths, selected, currentCount) {
      print(
          'cell at ${changedIndexPaths.toString()} is/are ${selected ? 'selected' : 'unselected'} ,current selected count is $currentCount');

      /// I just call setState() to update simply in this example.
      /// But the whole page will be rebuilt.
      /// So when you are developing,you'd better update a little piece
      /// of UI sub tree for best performance....
      ///
      setState(() {});
    });
  }

  Widget bottomBar() {
    return Container(
      color: Colors.grey[200],
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: CupertinoButton.filled(
                  padding: const EdgeInsets.only(),
                  child: const Text('open cell at 2'),
                  onPressed: () {
                    controller.openCellAt(
                        index: 2, trailing: true, animated: true);
                  }),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: CupertinoButton.filled(
                  padding: const EdgeInsets.only(),
                  child: const Text('switch edit mode'),
                  onPressed: () {
                    controller.toggleEditingMode();
                  }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: bottomBar(),
      appBar: CupertinoNavigationBar(
        middle: CupertinoButton.filled(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            minSize: 0,
            child: const Text('deselect all', style: TextStyle(fontSize: 22)),
            onPressed: () {
              controller.deselectAll();
            }),
        leading: CupertinoButton.filled(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            minSize: 0,
            child: Text(
                'delete cells (${controller.getSelectedIndexPaths().length})',
                style: const TextStyle(color: Colors.white)),
            onPressed: () {
              /// 获取选取的索引集合
              List<int> selectedIndexes = controller.getSelectedIndexPaths();

              List<String> idList = [];
              for (var element in selectedIndexes) {
                idList.add(list[element].id);
              }

              /// 遍历id集合，并且在原来的list中删除这些id所对应的数据
              for (var itemId in idList) {
                list.removeWhere((element) {
                  return element.id == itemId;
                });
              }

              /// 更新内部数据，这句话一定要写哦
              controller.deleteCellAt(indexPaths: selectedIndexes);
              setState(() {});
            }),
        trailing: CupertinoButton.filled(
            minSize: 0,
            padding: const EdgeInsets.all(10),
            child: const Text('select all'),
            onPressed: () {
              controller.selectAll(dataLength: list.length);
            }),
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: list.length,
        padding: EdgeInsets.only(right: 16),
        itemBuilder: (context, index) {
          final GlobalKey<CellItemState> key = GlobalKey<CellItemState>();
          return _item(context, index, key);
        },
      ),
    );
  }

  Widget _item(BuildContext ctx, int index, GlobalKey key) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
          topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
      child: SwipeActionCell(
        controller: controller,
        index: index,
        backgroundColor: Colors.transparent,
        // Required!
        key: ValueKey(list[index]),

        // Animation default value below
        // deleteAnimationDuration: 400,
        selectedForegroundColor: Colors.black.withAlpha(30),
        openAnimationCurve: const ElasticOutCurve(0.6),
        openAnimationDuration: 800,
        closeAnimationCurve: const ElasticOutCurve(0.6),
        closeAnimationDuration: 600,
        fullSwipeFactor: 1,

        trailingActions: [
          SwipeAction(
              backgroundRadius: 8,
              widthSpace: 93,
              forceAlignmentToBoundary: true,
              content: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(right: 8),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color:
                        list[index].isDele == true ? Colors.red : Colors.green),
                child: Text(list[index].isDele == true ? "删除" : "添加"),
              ),
              performsFirstActionWithFullSwipe: true,
              onQuickTap: () {
                debugPrint("快速回应");
                list[index].isDele = !list[index].isDele;
                key.currentState?.setState(() {});
              },
              onTap: (handler, isScroll) async {
                debugPrint("慢速回应");
                if (isScroll) {
                  debugPrint("[animation] : 滑动删除");
                } else {
                  debugPrint("[animation] : 点击删除");
                }
                debugPrint("[animation] 动画结束回应 --- 1");

                debugPrint("[animation] 动画结束回应 --- 2");
                await handler(false);
                // list.removeAt(index);
                setState(() {});
              }),
          // SwipeAction(title: "action2", color: Colors.grey, onTap: (handler) {}),
        ],
        // leadingActions: [
        //   SwipeAction(
        //       title: "delete",
        //       onTap: (handler) async {
        //         await handler(true);
        //         list.removeAt(index);
        //         setState(() {});
        //       }),
        //   SwipeAction(
        //       title: "action3", color: Colors.orange, onTap: (handler) {}),
        // ],
        child: GestureDetector(
          onTap: () {
            Navigator.push(context,
                CupertinoPageRoute(builder: (ctx) => const HomePage()));
          },
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.lightBlue),
            padding: const EdgeInsets.all(20.0),
            margin: EdgeInsets.only(left: 16),
            child: CellItem(
              key: key,
              model: list[index],
            ),
          ),
        ),
      ),
    );
  }
}
