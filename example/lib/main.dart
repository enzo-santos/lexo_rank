import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lexo_rank/lexo_rank.dart';
import 'package:lexo_rank/lexo_rank/lexo_rank_bucket.dart';

typedef LexoItem = ({String rank, String value});

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lexo Rank Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends HookWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = useState<List<LexoItem>>([]);

    final itemValueController = useTextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lexo Rank'),
      ),
      body: Column(
        children: [
          SizedBox(
            width: 300,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: itemValueController,
                  ),
                ),
                TextButton(
                    onPressed: () {
                      final lastRank = (items.value.isEmpty)
                          ? LexoRank.middle(bucket: LexoRankBucket.bucket2)
                          : LexoRank.parse(items.value.last.rank).genNext();

                      items.value = [
                        ...items.value,
                        (rank: lastRank.value, value: itemValueController.text)
                      ];

                      itemValueController.clear();
                    },
                    child: const Text('Add')),
              ],
            ),
          ),
          Expanded(
            child: ReorderableListView(
              children: items.value
                  .map((e) => ListTile(
                        key: ValueKey(e.rank),
                        title: Text(e.value),
                        subtitle: Text(e.rank),
                      ))
                  .toList(),
              onReorder: (oldIndex, newIndex) {
                final LexoRank newRank;
                if (newIndex == 0) {
                  newRank =
                      LexoRank.parse(items.value[newIndex].rank).genPrev();
                } else if (newIndex == items.value.length) {
                  newRank =
                      LexoRank.parse(items.value[newIndex - 1].rank).genNext();
                } else {
                  newRank = LexoRank.parse(items.value[newIndex - 1].rank)
                      .genBetween(LexoRank.parse(items.value[newIndex].rank));
                }

                final newList = items.value.toList();
                newList[oldIndex] =
                    (rank: newRank.value, value: newList[oldIndex].value);

                items.value = newList
                  ..sort(
                    (a, b) => a.rank.compareTo(b.rank),
                  );
              },
            ),
          )
        ],
      ),
    );
  }
}
