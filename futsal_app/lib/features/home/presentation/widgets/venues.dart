import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futsalpay/core/config/dimension.dart';
import 'package:futsalpay/features/home/data/model/futsal_ground_model.dart';
import 'package:go_router/go_router.dart';
import 'package:futsalpay/features/home/presentation/bloc/futsal_ground_bloc.dart';
import 'package:shimmer/shimmer.dart';

class Venues extends StatefulWidget {
  const Venues({super.key});

  @override
  State<Venues> createState() => _VenuesState();
}

class _VenuesState extends State<Venues> {
  @override
  void initState() {
    super.initState();
    context.read<FutsalGroundBloc>().add(LoadFutsalGrounds());
  }

  @override
  Widget build(BuildContext context) {
    Dimension.init(context);
    return BlocBuilder<FutsalGroundBloc, FutsalGroundState>(
      builder: (context, state) {
        if (state is FutsalGroundLoading) {
          return _buildShimmerEffect();
        }
        if (state is FutsalGroundLoaded) {
          return SingleChildScrollView(
            child: Wrap(
              spacing: Dimension.width(20),
              runSpacing: Dimension.height(10),
              children: state.grounds
                  .map((ground) => _buildVenueCard(context, ground))
                  .toList(),
            ),
          );
        }
        if (state is FutsalGroundError) {
          return Center(
            child: Text('Failed to load grounds: ${state.message}'),
          );
        }
        return const Center(child: Text('No grounds available.'));
      },
    );
  }

  // Helper widget to build the exact card design from your spec
  Widget _buildVenueCard(BuildContext context, FutsalGroundModel ground) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Container(
        width: Dimension.width(150), // Set a fixed width to control wrapping
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xff04340B),
            width: Dimension.width(0.5),
          ),
          borderRadius: BorderRadius.circular(Dimension.width(4)),
        ),
        child: Column(
          children: [
            // Using ClipRRect to contain the image within the border radius
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(Dimension.width(4)),
                topRight: Radius.circular(Dimension.width(4)),
              ),
              child: Image.network(
                ground.imageUrl,
                width: double.infinity, // Image takes full width of container
                height: Dimension.height(
                  120,
                ), // Fixed height as per your design
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => SizedBox(
                  height: Dimension.height(120),
                  child: Icon(Icons.error, color: Colors.grey),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(Dimension.width(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ground.name,
                    style: TextStyle(
                      color: Color(0xff91A693),
                      fontSize: Dimension.font(14),
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Rs.${ground.pricePerHour}/hr',
                    style: TextStyle(
                      color: Color(0xff91A693),
                      fontSize: Dimension.font(11.5),
                    ),
                  ),
                  SizedBox(height: Dimension.height(4)),
                  _buildRatingStars(ground.averageRating), // Dynamic stars
                  SizedBox(height: Dimension.height(8)),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color(0xff156F1F),
                      backgroundColor: const Color(0xff156F1F),
                      padding: EdgeInsets.zero,
                      minimumSize: Size(
                        double.infinity,
                        Dimension.height(30),
                      ), // Full width button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Dimension.width(4)),
                      ),
                    ),
                    onPressed: () {
                      context.push('/bookNow', extra: ground);
                    },
                    child: Text(
                      'Book Now',
                      style: TextStyle(
                        fontSize: Dimension.font(11.5),
                        color: Color(0xff9CC49F),
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

  // Helper to dynamically generate the star rating
  Widget _buildRatingStars(double rating) {
    int numberOfStars = rating.round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < numberOfStars ? Icons.star : Icons.star_border,
          color: Colors.yellow,
          size: Dimension.font(11.5),
        );
      }),
    );
  }

  // Shimmer effect that matches the final layout
  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        child: Wrap(
          spacing: Dimension.width(20),
          runSpacing: Dimension.height(10),
          children: List.generate(6, (index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              child: Container(
                width: Dimension.width(150),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xff04340B),
                    width: Dimension.width(0.5),
                  ),
                  borderRadius: BorderRadius.circular(Dimension.width(4)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: Dimension.height(120),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(Dimension.width(4)),
                          topRight: Radius.circular(Dimension.width(4)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(Dimension.width(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: Dimension.height(16),
                            color: Colors.white,
                          ),
                          SizedBox(height: Dimension.height(4)),
                          Container(
                            width: Dimension.width(80),
                            height: Dimension.height(12),
                            color: Colors.white,
                          ),
                          SizedBox(height: Dimension.height(4)),
                          Container(
                            width: Dimension.width(60),
                            height: Dimension.height(11.5),
                            color: Colors.white,
                          ),
                          SizedBox(height: Dimension.height(8)),
                          Container(
                            width: double.infinity,
                            height: Dimension.height(30),
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
