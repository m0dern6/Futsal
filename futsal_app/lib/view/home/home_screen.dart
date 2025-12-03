import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/view/home/bloc/all_futsal/all_futsal_bloc.dart';
import 'package:ui/view/home/bloc/all_futsal/all_futsal_event.dart';
import 'package:ui/view/home/bloc/all_futsal/all_futsal_state.dart';
import 'package:ui/view/home/bloc/top_reviewed_futsal/top_reviewed_futsal_bloc.dart';
import 'package:ui/view/home/bloc/top_reviewed_futsal/top_reviewed_futsal_event.dart';
import 'package:ui/view/home/bloc/top_reviewed_futsal/top_reviewed_futsal_state.dart';
import 'package:ui/view/home/bloc/trending_futsal/trending_futsal_bloc.dart';
import 'package:ui/view/home/bloc/trending_futsal/trending_futsal_event.dart';
import 'package:ui/view/home/bloc/trending_futsal/trending_futsal_state.dart';
import '../../core/dimension.dart';
import '../futsal/futsal_details.dart';
// removed book_now import since Book Now button removed from card

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<_CategoryData> _categories = const [
    _CategoryData(label: 'All', iconPath: 'assets/icons/all.png'),
    _CategoryData(label: 'Trending', iconPath: 'assets/icons/trending.png'),
    _CategoryData(label: 'Top Reviewed', iconPath: 'assets/icons/reviewed.png'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  Future<void> _onRefresh() async {
    // Refresh current category data based on active tab
    final index = _tabController.index;
    switch (index) {
      case 0:
        context.read<AllFutsalBloc>().add(const LoadAllFutsals());
        break;
      case 1:
        context.read<TrendingFutsalBloc>().add(const LoadTrendingFutsals());
        break;
      case 2:
        context.read<TopReviewedFutsalBloc>().add(
          const LoadTopReviewedFutsals(),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    Dimension.init(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(Dimension.height(145)),
        child: Container(
          width: double.infinity,
          color: Theme.of(context).appBarTheme.backgroundColor,
          padding: EdgeInsets.symmetric(
            horizontal: Dimension.width(20),
            vertical: Dimension.height(20),
          ),
          child: Column(
            children: [
              SizedBox(height: Dimension.height(40)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back!',
                        style: TextStyle(
                          fontSize: Dimension.font(10),
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.6),
                          height: 1.2,
                        ),
                      ),
                      Text(
                        'Find your court',
                        style: TextStyle(
                          fontSize: Dimension.font(12),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  Container(
                    width: Dimension.width(25),
                    height: Dimension.height(25),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(80),
                    ),
                    child: Icon(
                      Icons.notifications_none,
                      size: Dimension.width(15),
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: Dimension.height(20)),
              // Search Bar
              SizedBox(
                height: Dimension.height(40),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: Dimension.width(8),
                      vertical: Dimension.height(8),
                    ),
                    isDense: true,
                    hint: Row(
                      children: [
                        Icon(
                          Icons.search,
                          size: Dimension.width(16),
                          color: Colors.grey[400],
                        ),
                        SizedBox(width: Dimension.width(6)),
                        Text(
                          'Search Futsal Courts',
                          style: TextStyle(
                            fontSize: Dimension.font(14),
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              size: Dimension.width(18),
                              color: Colors.grey[600],
                            ),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimension.width(10)),
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimension.width(10)),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                        width: 3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              overlayColor: WidgetStateProperty.all(Colors.transparent),

              controller: _tabController,
              splashBorderRadius: null,
              splashFactory: null,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: EdgeInsets.symmetric(
                horizontal: Dimension.width(10),
              ),
              tabs: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: Dimension.height(15)),
                  child: Text('All Futsal'),
                ),
                Text('Trending'),
                Text('Top Reviewed'),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: Dimension.height(8)),
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAllFutsalTab(),
                  _buildTrendingFutsalTab(),
                  _buildTopReviewedFutsalTab(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _filterFutsals(List<dynamic> futsals) {
    if (_searchQuery.isEmpty) return futsals;
    return futsals.where((futsal) {
      final name = (futsal.name ?? '').toLowerCase();
      final location = (futsal.location ?? '').toLowerCase();
      return name.contains(_searchQuery) || location.contains(_searchQuery);
    }).toList();
  }

  Widget _buildAllFutsalTab() {
    return BlocBuilder<AllFutsalBloc, AllFutsalState>(
      builder: (context, state) {
        if (state is AllFutsalLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C853)),
            ),
          );
        } else if (state is AllFutsalError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: Dimension.width(64),
                  color: Colors.grey[400],
                ),
                SizedBox(height: Dimension.height(16)),
                Text(
                  'Failed to load futsals',
                  style: TextStyle(
                    fontSize: Dimension.font(16),
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: Dimension.height(8)),
                Text(
                  state.message,
                  style: TextStyle(
                    fontSize: Dimension.font(13),
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: Dimension.height(16)),
                ElevatedButton(
                  onPressed: () {
                    context.read<AllFutsalBloc>().add(const LoadAllFutsals());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else if (state is AllFutsalLoaded) {
          final futsals = _filterFutsals(state.futsals);

          if (futsals.isEmpty) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: const Color(0xFF00C853),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sports_soccer,
                          size: Dimension.width(64),
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: Dimension.height(16)),
                        Text(
                          'No futsals available',
                          style: TextStyle(
                            fontSize: Dimension.font(16),
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: Dimension.height(8)),
                        Text(
                          'Pull down to refresh',
                          style: TextStyle(
                            fontSize: Dimension.font(13),
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: const Color(0xFF00C853),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: Dimension.width(20),
                vertical: Dimension.height(12),
              ),
              itemCount: futsals.length,
              separatorBuilder: (context, index) =>
                  SizedBox(height: Dimension.height(12)),
              itemBuilder: (context, index) {
                final futsal = futsals[index];
                return _CourtCard(court: futsal.toMap());
              },
            ),
          );
        }

        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C853)),
          ),
        );
      },
    );
  }

  Widget _buildTrendingFutsalTab() {
    return BlocBuilder<TrendingFutsalBloc, TrendingFutsalState>(
      builder: (context, state) {
        if (state is TrendingFutsalLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C853)),
            ),
          );
        } else if (state is TrendingFutsalError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: Dimension.width(64),
                  color: Colors.grey[400],
                ),
                SizedBox(height: Dimension.height(16)),
                Text(
                  'Failed to load trending futsals',
                  style: TextStyle(
                    fontSize: Dimension.font(16),
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: Dimension.height(8)),
                Text(
                  state.message,
                  style: TextStyle(
                    fontSize: Dimension.font(13),
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: Dimension.height(16)),
                ElevatedButton(
                  onPressed: () {
                    context.read<TrendingFutsalBloc>().add(
                      const LoadTrendingFutsals(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else if (state is TrendingFutsalLoaded) {
          final futsals = _filterFutsals(state.futsals);

          if (futsals.isEmpty) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: const Color(0xFF00C853),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sports_soccer,
                          size: Dimension.width(64),
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: Dimension.height(16)),
                        Text(
                          'No trending futsals available',
                          style: TextStyle(
                            fontSize: Dimension.font(16),
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: Dimension.height(8)),
                        Text(
                          'Pull down to refresh',
                          style: TextStyle(
                            fontSize: Dimension.font(13),
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: const Color(0xFF00C853),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: Dimension.width(20),
                vertical: Dimension.height(12),
              ),
              itemCount: futsals.length,
              separatorBuilder: (context, index) =>
                  SizedBox(height: Dimension.height(12)),
              itemBuilder: (context, index) {
                final futsal = futsals[index];
                return _CourtCard(court: futsal.toMap());
              },
            ),
          );
        }

        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C853)),
          ),
        );
      },
    );
  }

  Widget _buildTopReviewedFutsalTab() {
    return BlocBuilder<TopReviewedFutsalBloc, TopReviewedFutsalState>(
      builder: (context, state) {
        if (state is TopReviewedFutsalLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C853)),
            ),
          );
        } else if (state is TopReviewedFutsalError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: Dimension.width(64),
                  color: Colors.grey[400],
                ),
                SizedBox(height: Dimension.height(16)),
                Text(
                  'Failed to load top reviewed futsals',
                  style: TextStyle(
                    fontSize: Dimension.font(16),
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: Dimension.height(8)),
                Text(
                  state.message,
                  style: TextStyle(
                    fontSize: Dimension.font(13),
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: Dimension.height(16)),
                ElevatedButton(
                  onPressed: () {
                    context.read<TopReviewedFutsalBloc>().add(
                      const LoadTopReviewedFutsals(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else if (state is TopReviewedFutsalLoaded) {
          final futsals = _filterFutsals(state.futsals);

          if (futsals.isEmpty) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: const Color(0xFF00C853),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sports_soccer,
                          size: Dimension.width(64),
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: Dimension.height(16)),
                        Text(
                          'No top reviewed futsals available',
                          style: TextStyle(
                            fontSize: Dimension.font(16),
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: Dimension.height(8)),
                        Text(
                          'Pull down to refresh',
                          style: TextStyle(
                            fontSize: Dimension.font(13),
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: const Color(0xFF00C853),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: Dimension.width(20),
                vertical: Dimension.height(12),
              ),
              itemCount: futsals.length,
              separatorBuilder: (context, index) =>
                  SizedBox(height: Dimension.height(12)),
              itemBuilder: (context, index) {
                final futsal = futsals[index];
                return _CourtCard(court: futsal.toMap());
              },
            ),
          );
        }

        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C853)),
          ),
        );
      },
    );
  }
}

class _CategoryData {
  final String label;
  final String iconPath;
  const _CategoryData({required this.label, required this.iconPath});
}

// legacy category tab widget removed

class _CourtCard extends StatelessWidget {
  final Map<String, dynamic> court;

  const _CourtCard({required this.court});

  @override
  Widget build(BuildContext context) {
    // full-width card in vertical list

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FutsalDetails(futsalData: court),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: Dimension.height(12)),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(Dimension.width(8)),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.08),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                blurRadius: Dimension.width(12),
                offset: Offset(0, Dimension.height(4)),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Court Image (larger) with subtle border and price overlay
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(Dimension.width(8)),
                    topRight: Radius.circular(Dimension.width(8)),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(Dimension.width(8)),
                    topRight: Radius.circular(Dimension.width(8)),
                  ),
                  child: SizedBox(
                    height: Dimension.height(160),
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (court['imageUrl'] != null)
                          Image.network(court['imageUrl'], fit: BoxFit.cover)
                        else
                          Container(color: Colors.grey[200]),

                        // Price badge at bottom-left of the image
                        Positioned(
                          left: Dimension.width(10),
                          bottom: Dimension.height(10),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimension.width(8),
                              vertical: Dimension.height(6),
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(
                                Dimension.width(6),
                              ),
                            ),
                            child: Text(
                              'Rs ${court['pricePerHour']}/hr',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: Dimension.font(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Court Details
              Padding(
                padding: EdgeInsets.all(Dimension.width(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Court Name
                    Text(
                      court['name'] ?? 'Court Name',
                      style: TextStyle(
                        fontSize: Dimension.font(15),
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: Dimension.height(6)),

                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: Dimension.width(14),
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: Dimension.width(4)),
                        Text(
                          court['location'] ?? 'Location',
                          style: TextStyle(
                            fontSize: Dimension.font(12),
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        Text(
                          court['distanceKm'] != null
                              ? '  ${court['distanceKm']} km'
                              : '  --- km',
                          style: TextStyle(
                            fontSize: Dimension.font(12),
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimary.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    SizedBox(height: Dimension.height(8)),

                    // Rating
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: Dimension.width(15),
                          color: const Color(0xFFFFA500),
                        ),
                        SizedBox(width: Dimension.width(4)),
                        Text(
                          court['averageRating']?.toString() ?? '0.0',
                          style: TextStyle(
                            fontSize: Dimension.font(12),
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        Text(
                          ' (${court['ratingCount']?.toString()} reviews)',
                          style: TextStyle(
                            fontSize: Dimension.font(10),
                            fontWeight: FontWeight.w500,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimary.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: Dimension.height(10)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
