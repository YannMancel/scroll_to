import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:scroll_to/item.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.title,
  });

  final String title;

  Future<Iterable<Item>> _getItems({
    int categoryCount = 100,
    int productCount = 10,
  }) async {
    return Isolate.run(() {
      final items = Iterable<CategoryItem>.generate(
        categoryCount,
        (index) => CategoryItem(
          index * (1 + productCount),
          label: 'Category $index',
        ),
      ).fold(
        const <Item>[],
        (join, e) => [
          ...join,
          e,
          ...Iterable<Item>.generate(
            productCount,
            (index) => ProductItem(
              e.index + index + 1,
              label: 'Product $index of ${e.label}',
              subIndex: index,
            ),
          ),
        ],
      );
      return items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: FutureBuilder<Iterable<Item>>(
        future: _getItems(),
        builder: (_, snapshot) {
          return snapshot.hasError
              ? Center(
                  child: Text('error'),
                )
              : snapshot.hasData
                  ? _Data(items: snapshot.data!)
                  : Center(
                      child: CircularProgressIndicator(),
                    );
        },
      ),
    );
  }
}

class _Data extends StatefulWidget {
  const _Data({required this.items});

  final Iterable<Item> items;

  @override
  State<_Data> createState() => _DataState();
}

class _DataState extends State<_Data> {
  late Map<CategoryItem, GlobalKey> _cache;

  Future<void> _scrollTo(GlobalKey key) async {
    await Scrollable.ensureVisible(
      key.currentContext!,
      alignment: 0.0,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void initState() {
    super.initState();
    _cache = <CategoryItem, GlobalKey>{
      for (final category in widget.items.categories) category: GlobalKey(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 50.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _cache.keys.length,
            itemBuilder: (_, index) {
              final category = _cache.keys.toList()[index];
              return Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: GestureDetector(
                  onTap: () async => _scrollTo(_cache[category]!),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(category.label),
                  ),
                ),
              );
            },
          ),
        ),
        const Divider(),
        Expanded(
          child: CustomScrollView(
            slivers: <Widget>[
              for (final item in widget.items)
                SliverToBoxAdapter(
                  key: item.map(
                    category: (type) => _cache[type],
                    product: (_) => null,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: item.when(
                      category: (_, label) => Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(label),
                      ),
                      product: (_, label, ___) => Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ListTile(
                          title: Text(label),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
