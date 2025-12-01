import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/dimension.dart';
import '../futsal/futsal_details.dart';
import '../book_now/book_now.dart';
import 'bloc/favorite_bloc.dart';
import 'bloc/favorite_event.dart';
import 'bloc/favorite_state.dart';

class Favorite extends StatefulWidget {
  const Favorite({super.key});

  @override
  State<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  Future<void> _onRefresh() async {
    context.read<FavoriteBloc>().add(const LoadFavorites());
  }

  @override
  Widget build(BuildContext context) {
    Dimension.init(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFfffff),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.fromLTRB(
                Dimension.width(20),
                Dimension.height(16),
                Dimension.width(20),
                Dimension.height(12),
              ),
              decoration: BoxDecoration(
                color: Color(0xffffffff),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: Dimension.width(10),
                    offset: Offset(0, Dimension.height(2)),
                  ),
                ],
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
                    'Favorites',
                    style: TextStyle(
                      fontSize: Dimension.font(24),
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: Dimension.height(10)),

            // Search Bar (decorative)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimension.width(20)),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimension.width(16),
                  vertical: Dimension.height(12),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Dimension.width(12)),
                  border: Border.all(
                    color: const Color(0xFF00C853).withOpacity(0.18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00C853).withOpacity(0.06),
                      blurRadius: Dimension.width(12),
                      offset: Offset(0, Dimension.height(3)),
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
                      'Search favorites...',
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

            SizedBox(height: Dimension.height(14)),

            // Favorites List with BLoC
            Expanded(
              child: BlocBuilder<FavoriteBloc, FavoriteState>(
                builder: (context, state) {
                  if (state is FavoriteLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF00C853),
                        ),
                      ),
                    );
                  } else if (state is FavoriteError) {
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
                            'Failed to load favorites',
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
                            onPressed: _onRefresh,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00C853),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  } else if (state is FavoriteLoaded ||
                      state is FavoriteActionSuccess) {
                    final favorites = state is FavoriteLoaded
                        ? state.favorites
                        : (state as FavoriteActionSuccess).favorites;

                    if (favorites.isEmpty) {
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
                                    Icons.favorite_border,
                                    size: Dimension.width(64),
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: Dimension.height(16)),
                                  Text(
                                    'No favorites yet',
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
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimension.width(20),
                        ),
                        itemCount: favorites.length,
                        itemBuilder: (context, index) {
                          final futsal = favorites[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: Dimension.height(16),
                            ),
                            child: _FavoriteCard(court: futsal.toMap()),
                          );
                        },
                      ),
                    );
                  }

                  // Initial state
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
                                Icons.favorite_border,
                                size: Dimension.width(64),
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: Dimension.height(16)),
                              Text(
                                'Pull down to load favorites',
                                style: TextStyle(
                                  fontSize: Dimension.font(16),
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final Map<String, dynamic> court;
  const _FavoriteCard({required this.court});

  @override
  Widget build(BuildContext context) {
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
        height: Dimension.height(140),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Dimension.width(18)),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: Dimension.width(14),
              offset: Offset(0, Dimension.height(4)),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image (full-height with proper radius)
            SizedBox(
              width: Dimension.width(120),
              height: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(Dimension.width(18)),
                  bottomLeft: Radius.circular(Dimension.width(18)),
                ),
                child: court['imageUrl'] != null
                    ? Image.network(
                        court['imageUrl'],
                        width: Dimension.width(120),
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[200],
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.image_not_supported,
                            size: Dimension.width(28),
                            color: Colors.grey[500],
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.image,
                          size: Dimension.width(28),
                          color: Colors.grey[500],
                        ),
                      ),
              ),
            ),

            // Details
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(Dimension.width(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                court['name'] ?? 'Futsal Court',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: Dimension.font(16),
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: Dimension.height(4)),
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
                                      court['location'] ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: Dimension.font(13),
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimension.width(10),
                            vertical: Dimension.height(6),
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00C853), Color(0xFF00A843)],
                            ),
                            borderRadius: BorderRadius.circular(
                              Dimension.width(10),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00C853).withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'Rs ${court['pricePerHour']}/hr',
                            style: TextStyle(
                              fontSize: Dimension.font(11),
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Dimension.height(10)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: Dimension.width(16),
                              color: const Color(0xFFFFA500),
                            ),
                            SizedBox(width: Dimension.width(4)),
                            Text(
                              (court['averageRating'] ?? 0.0).toString(),
                              style: TextStyle(
                                fontSize: Dimension.font(13),
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            // Favorite icon (static for now)
                            Container(
                              padding: EdgeInsets.all(Dimension.width(6)),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(
                                  Dimension.width(8),
                                ),
                              ),
                              child: Icon(
                                Icons.favorite,
                                size: Dimension.width(18),
                                color: Colors.red,
                              ),
                            ),
                            SizedBox(width: Dimension.width(10)),
                            // Book Now Button (small)
                            SizedBox(
                              height: Dimension.height(34),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          BookNow(futsalData: court),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00C853),
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Dimension.width(14),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      Dimension.width(10),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Book Now',
                                  style: TextStyle(
                                    fontSize: Dimension.font(12),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
