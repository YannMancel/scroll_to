import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:scroll_to/build_context_extension.dart';
import 'package:scroll_to/item.dart';
import 'package:scroll_to/selected_category_controller.dart';

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
  late ScrollController _scrollController;
  late VoidCallback _onScroll;
  late SelectedCategoryController _selectedCategoryController;

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
    _onScroll = () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          _selectedCategoryController.visibleItems = context
              .whereChildWidgets(
                (element) => element.widget.runtimeType == _ItemView,
                canOnlySearchVisibleChildren: true,
              )
              .cast<_ItemView>()
              .map((widget) => widget.item)
              .toList();
        }
      });
    };
    _scrollController = ScrollController()..addListener(_onScroll);
    _selectedCategoryController = SelectedCategoryControllerImpl(
      allItems: widget.items.toList(),
    );
    _onScroll();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _selectedCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.black12,
                width: 2.0,
              ),
            ),
          ),
          child: SizedBox(
            height: 50.0,
            child: ValueListenableBuilder(
              valueListenable: _selectedCategoryController.selectedCategory,
              builder: (_, selectedCategory, __) => ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 16.0),
                itemCount: _cache.keys.length,
                itemBuilder: (_, index) {
                  final category = _cache.keys.toList()[index];
                  final isSelected = category == selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: GestureDetector(
                      onTap: () async => _scrollTo(_cache[category]!),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          category.label,
                          style: TextStyle(
                            color: isSelected ? Colors.blue : null,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        Expanded(
          child: CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              for (final item in widget.items)
                _ItemView(
                  item,
                  key: item.map<GlobalKey?>(
                    category: (type) => _cache[type],
                    product: (_) => null,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ItemView extends StatelessWidget {
  const _ItemView(
    this.item, {
    super.key,
  });

  final Item item;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: item.when<Widget>(
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
    );
  }
}
