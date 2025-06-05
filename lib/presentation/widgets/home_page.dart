import 'package:flutter/material.dart';
import 'package:scroll_to/domain/entities/item.dart';
import 'package:scroll_to/domain/use_cases/find_all_use_case.dart';
import 'package:scroll_to/presentation/core/build_context_extension.dart';
import 'package:scroll_to/presentation/providers/selected_category_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
        centerTitle: true,
      ),
      body: FutureBuilder<Iterable<Item<String>>>(
        future: const FindAllUseCase()(),
        builder: (_, snapshot) {
          return snapshot.hasError
              ? Center(
                  child: Text('error'),
                )
              : snapshot.hasData
                  ? _DataView(items: snapshot.data!)
                  : Center(
                      child: CircularProgressIndicator(),
                    );
        },
      ),
    );
  }
}

class _DataView extends StatefulWidget {
  const _DataView({required this.items});

  final Iterable<Item<String>> items;

  @override
  State<_DataView> createState() => _DataViewState();
}

class _DataViewState extends State<_DataView> {
  late Map<CategoryItem<String>, GlobalKey> _cache;
  late ScrollController _scrollController;
  late VoidCallback _onScroll;
  late SelectedCategoryController<String> _selectedCategoryController;

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
    _cache = <CategoryItem<String>, GlobalKey>{
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
    _selectedCategoryController = SelectedCategoryControllerImpl<String>(
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
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.primary;
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
            height: 55.0,
            child: ValueListenableBuilder<CategoryItem<String>?>(
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
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isSelected
                                  ? selectedColor
                                  : Colors.transparent,
                              width: 2.0,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            category.value,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: isSelected ? selectedColor : null,
                              fontWeight: isSelected ? FontWeight.bold : null,
                            ),
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
              const SliverToBoxAdapter(
                child: SizedBox.square(dimension: 16.0),
              )
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

  final Item<String> item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return SliverPadding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
      ),
      sliver: SliverToBoxAdapter(
        child: item.when<Widget>(
          category: (_, label) => Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              label,
              style: textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          product: (_, label, ___) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                label,
                style: textTheme.titleMedium,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
