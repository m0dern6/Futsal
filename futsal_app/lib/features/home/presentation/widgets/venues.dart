import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    return BlocBuilder<FutsalGroundBloc, FutsalGroundState>(
      builder: (context, state) {
        if (state is FutsalGroundLoading) {
          return _buildShimmerEffect();
        }
        if (state is FutsalGroundLoaded) {
          return SingleChildScrollView(
            child: Wrap(
              spacing: 4.0, // Horizontal space between cards
              runSpacing: 4.0, // Vertical space between lines
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
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
      child: Container(
        width: 170, // Set a fixed width to control wrapping
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xff04340B), width: 0.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            // Using ClipRRect to contain the image within the border radius
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
              child: Image.network(
                ground.imageUrl,
                width: double.infinity, // Image takes full width of container
                height: 130, // Fixed height as per your design
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox(
                  height: 130,
                  child: Icon(Icons.error, color: Colors.grey),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ground.name,
                    style: const TextStyle(
                      color: Color(0xff91A693),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Rs.${ground.pricePerHour}/hr',
                    style: const TextStyle(
                      color: Color(0xff91A693),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  _buildRatingStars(ground.averageRating), // Dynamic stars
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color(0xff156F1F),
                      backgroundColor: const Color(0xff156F1F),
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(
                        double.infinity,
                        35,
                      ), // Full width button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onPressed: () {
                      context.push('/bookNow');
                    },
                    child: const Text(
                      'Book Now',
                      style: TextStyle(fontSize: 14, color: Color(0xff9CC49F)),
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
          size: 14,
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
          spacing: 4.0,
          runSpacing: 4.0,
          children: List.generate(6, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 6.0,
                vertical: 6.0,
              ),
              child: Container(
                width: 170,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xff04340B),
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 130,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 100,
                            height: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 5),
                          Container(width: 80, height: 14, color: Colors.white),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            height: 35,
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
