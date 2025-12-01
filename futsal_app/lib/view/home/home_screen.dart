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
import '../book_now/book_now.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategory = 0;

  final List<_CategoryData> _categories = const [
    _CategoryData(label: 'All', iconPath: 'assets/icons/all.png'),
    _CategoryData(label: 'Trending', iconPath: 'assets/icons/trending.png'),
    _CategoryData(label: 'Top Reviewed', iconPath: 'assets/icons/reviewed.png'),
  ];

  @override
  void initState() {
    super.initState();
    // Data already loaded in splash screen, no need to load here
  }

  void _onCategoryChanged(int index) {
    setState(() => _selectedCategory = index);
  }

  Future<void> _onRefresh() async {
    // Refresh current category data
    switch (_selectedCategory) {
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
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar with logo and name
            Padding(
              padding: EdgeInsets.fromLTRB(
                Dimension.width(20),
                Dimension.height(16),
                Dimension.width(20),
                Dimension.height(12),
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/logo/logo.png',
                    width: Dimension.width(50),
                    height: Dimension.width(50),
                  ),
                  SizedBox(width: Dimension.width(12)),
                  Text(
                    'Futsal Pay',
                    style: TextStyle(
                      fontSize: Dimension.font(22),
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar (not typable)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimension.width(20)),
              child: GestureDetector(
                onTap: () {
                  // Navigate to search screen when tapped
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimension.width(16),
                    vertical: Dimension.height(8),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Dimension.width(6)),
                    border: Border.all(
                      color: const Color(0xFF00C853).withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00C853).withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: const Color(0xFF00C853),
                        size: Dimension.width(22),
                      ),
                      SizedBox(width: Dimension.width(12)),
                      Text(
                        'Search futsal courts...',
                        style: TextStyle(
                          fontSize: Dimension.font(15),
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: Dimension.height(12)),

            // Category Tabs
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimension.width(20)),
              child: SizedBox(
                height: Dimension.height(30),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final selected = index == _selectedCategory;
                    return Padding(
                      padding: EdgeInsets.only(right: Dimension.width(10)),
                      child: _CategoryTab(
                        label: category.label,
                        iconPath: category.iconPath,
                        selected: selected,
                        onTap: () => _onCategoryChanged(index),
                      ),
                    );
                  },
                ),
              ),
            ),

            SizedBox(height: Dimension.height(20)),

            // Futsal Court Cards with Pull-to-Refresh
            Expanded(
              child: _selectedCategory == 0
                  ? _buildAllFutsalTab()
                  : _selectedCategory == 1
                  ? _buildTrendingFutsalTab()
                  : _buildTopReviewedFutsalTab(),
            ),
          ],
        ),
      ),
    );
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
          final futsals = state.futsals;

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
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: Dimension.width(20)),
              child: Wrap(
                spacing: Dimension.width(12),
                runSpacing: Dimension.height(12),
                children: futsals.map((futsal) {
                  return _CourtCard(court: futsal.toMap());
                }).toList(),
              ),
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
          final futsals = state.futsals;

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
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: Dimension.width(20)),
              child: Wrap(
                spacing: Dimension.width(12),
                runSpacing: Dimension.height(12),
                children: futsals.map((futsal) {
                  return _CourtCard(court: futsal.toMap());
                }).toList(),
              ),
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
          final futsals = state.futsals;

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
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: Dimension.width(20)),
              child: Wrap(
                spacing: Dimension.width(12),
                runSpacing: Dimension.height(12),
                children: futsals.map((futsal) {
                  return _CourtCard(court: futsal.toMap());
                }).toList(),
              ),
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

class _CategoryTab extends StatelessWidget {
  final String label;
  final String iconPath;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryTab({
    required this.label,
    required this.iconPath,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: EdgeInsets.symmetric(
          horizontal: Dimension.width(6),
          vertical: 0,
        ),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [Color(0xFF00C853), Color(0xFF00A843)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: selected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(Dimension.width(6)),
          border: Border.all(
            color: selected
                ? const Color(0xFF00C853)
                : Colors.black.withOpacity(0.06),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: Dimension.width(28),
              height: Dimension.width(28),
              // color: selected ? Colors.black : Colors.black.withOpacity(0.6),
            ),
            SizedBox(width: Dimension.width(2)),
            Text(
              label,
              style: TextStyle(
                fontSize: Dimension.font(14),
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? Colors.white : Colors.black.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourtCard extends StatelessWidget {
  final Map<String, dynamic> court;

  const _CourtCard({required this.court});

  @override
  Widget build(BuildContext context) {
    final cardWidth = (Dimension.deviceWidth - Dimension.width(52)) / 2;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FutsalDetails(futsalData: court),
          ),
        );
      },
      child: Container(
        width: cardWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Dimension.width(8)),
          border: Border.all(color: Colors.black.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: Dimension.width(12),
              offset: Offset(0, Dimension.height(4)),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Court Image
            Container(
              height: Dimension.height(120),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(Dimension.width(8)),
                  topRight: Radius.circular(Dimension.width(8)),
                ),
                image: court['imageUrl'] != null
                    ? DecorationImage(
                        image: NetworkImage(court['imageUrl']),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              // child: Stack(
              //   children: [
              //     // Favorite Button
              //     Positioned(
              //       top: Dimension.height(8),
              //       right: Dimension.width(8),
              //       child: Container(
              //         padding: EdgeInsets.all(Dimension.width(6)),
              //         decoration: BoxDecoration(
              //           color: Colors.white,
              //           shape: BoxShape.circle,
              //           boxShadow: [
              //             BoxShadow(
              //               color: Colors.black.withOpacity(0.1),
              //               blurRadius: Dimension.width(8),
              //             ),
              //           ],
              //         ),
              //         child: Icon(
              //           Icons.favorite_border,
              //           size: Dimension.width(16),
              //           color: Colors.black,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
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
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
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
                      Expanded(
                        child: Text(
                          court['location'] ?? 'Location',
                          style: TextStyle(
                            fontSize: Dimension.font(12),
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimension.height(8)),

                  // Rating and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                              fontSize: Dimension.font(13),
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),

                      // Price
                      Text(
                        'Rs ${court['pricePerHour']}/hr',
                        style: TextStyle(
                          fontSize: Dimension.font(13),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF00C853),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: Dimension.height(10)),

                  // Book Now Button
                  SizedBox(
                    width: double.infinity,
                    height: Dimension.height(32),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookNow(futsalData: court),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C853),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: const Color(0xFF00C853).withOpacity(0.4),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            Dimension.width(8),
                          ),
                        ),
                      ),
                      child: Text(
                        'Book Now',
                        style: TextStyle(
                          fontSize: Dimension.font(12),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
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
