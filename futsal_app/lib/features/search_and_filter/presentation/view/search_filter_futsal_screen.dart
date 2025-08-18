import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:futsalpay/core/config/dimension.dart';
import 'package:futsalpay/features/home/data/model/futsal_ground_model.dart';
import 'package:futsalpay/features/home/domain/futsal_ground_repository.dart';

enum SortState { none, high, low }

class SearchFilterFutsalScreen extends StatefulWidget {
  const SearchFilterFutsalScreen({super.key});

  @override
  State<SearchFilterFutsalScreen> createState() =>
      _SearchFilterFutsalScreenState();
}

class _SearchFilterFutsalScreenState extends State<SearchFilterFutsalScreen> {
  final _searchCtrl = TextEditingController();

  SortState _priceState = SortState.none;
  SortState _ratingState = SortState.none;

  bool _loading = false;
  String? _error;

  List<FutsalGroundModel> _allResults = [];
  List<FutsalGroundModel> _displayResults = [];

  @override
  void initState() {
    super.initState();
    _loadDefaultResults();
  }

  Future<void> _loadDefaultResults() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = context.read<FutsalGroundRepository>();
      final list = await repo.getFutsalGrounds(page: 1, pageSize: 100);
      setState(() {
        _allResults = list;
        _applyFiltersAndSort();
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _applyFiltersAndSort() {
    final query = _searchCtrl.text.trim().toLowerCase();
    var list = _allResults.where((g) {
      if (query.isEmpty) return true;
      return g.name.toLowerCase().contains(query) ||
          g.location.toLowerCase().contains(query);
    }).toList();

    // Apply rating sort first if selected
    if (_ratingState != SortState.none) {
      if (_ratingState == SortState.high) {
        list.sort((a, b) => b.averageRating.compareTo(a.averageRating));
      } else if (_ratingState == SortState.low) {
        list.sort((a, b) => a.averageRating.compareTo(b.averageRating));
      }
    }

    // Then apply price sort (price takes precedence if selected)
    if (_priceState != SortState.none) {
      if (_priceState == SortState.high) {
        list.sort((a, b) => b.pricePerHour.compareTo(a.pricePerHour));
      } else if (_priceState == SortState.low) {
        list.sort((a, b) => a.pricePerHour.compareTo(b.pricePerHour));
      }
    }

    setState(() => _displayResults = list);
  }

  void _cyclePriceState() {
    setState(() {
      _priceState = _nextState(_priceState);
      // If user activates price sort, keep rating as-is; then apply
      _applyFiltersAndSort();
    });
  }

  void _cycleRatingState() {
    setState(() {
      _ratingState = _nextState(_ratingState);
      _applyFiltersAndSort();
    });
  }

  SortState _nextState(SortState s) {
    switch (s) {
      case SortState.none:
        return SortState.high;
      case SortState.high:
        return SortState.low;
      case SortState.low:
        return SortState.none;
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Dimension.init(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchCtrl,
          decoration: InputDecoration(
            hintText: 'Search by name or area',
            border: InputBorder.none,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(.6),
            ),
          ),
          onChanged: (_) => _applyFiltersAndSort(),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _applyFiltersAndSort(),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(Dimension.width(16)),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.surface,
                      foregroundColor: theme.colorScheme.onSurface,
                      elevation: 0,
                    ),
                    onPressed: _cyclePriceState,
                    icon: _priceState == SortState.high
                        ? const Icon(Icons.arrow_upward)
                        : _priceState == SortState.low
                        ? const Icon(Icons.arrow_downward)
                        : const Icon(Icons.swap_vert),
                    label: Text(
                      _priceState == SortState.none
                          ? 'Price'
                          : (_priceState == SortState.high
                                ? 'Price: High'
                                : 'Price: Low'),
                    ),
                  ),
                ),
                SizedBox(width: Dimension.width(12)),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.surface,
                      foregroundColor: theme.colorScheme.onSurface,
                      elevation: 0,
                    ),
                    onPressed: _cycleRatingState,
                    icon: _ratingState == SortState.high
                        ? const Icon(Icons.arrow_upward)
                        : _ratingState == SortState.low
                        ? const Icon(Icons.arrow_downward)
                        : const Icon(Icons.swap_vert),
                    label: Text(
                      _ratingState == SortState.none
                          ? 'Rating'
                          : (_ratingState == SortState.high
                                ? 'Rating: High'
                                : 'Rating: Low'),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: Dimension.height(12)),

            Expanded(child: _buildResults(theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(ThemeData theme) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text('Error: $_error'));
    if (_displayResults.isEmpty) return Center(child: Text('No results'));

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: Dimension.height(12),
        crossAxisSpacing: Dimension.width(12),
        childAspectRatio: 0.72,
      ),
      itemCount: _displayResults.length,
      itemBuilder: (context, index) {
        final g = _displayResults[index];
        return _resultCard(g, theme);
      },
    );
  }

  Widget _resultCard(FutsalGroundModel g, ThemeData theme) {
    return InkWell(
      onTap: () => context.push('/bookNow', extra: g),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(.14)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.network(
                g.imageUrl,
                height: Dimension.height(110),
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: Dimension.height(110),
                  color: theme.colorScheme.surfaceContainer,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(Dimension.width(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    g.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: Dimension.height(6)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rs.${g.pricePerHour}/hr',
                        style: theme.textTheme.bodySmall,
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.amber),
                          SizedBox(width: 4),
                          Text(g.averageRating.toStringAsFixed(1)),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: Dimension.height(8)),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: Dimension.height(10),
                        ),
                      ),
                      onPressed: () => context.push('/bookNow', extra: g),
                      child: Text(
                        'Book Now',
                        style: theme.textTheme.labelLarge!.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
