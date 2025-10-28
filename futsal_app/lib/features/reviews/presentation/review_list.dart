import 'package:flutter/material.dart';
import '../data/model/review_model.dart';

class ReviewList extends StatelessWidget {
  final List<ReviewModel> reviews;
  const ReviewList({Key? key, required this.reviews}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const Center(child: Text('No reviews yet.'));
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: reviews.length,
      separatorBuilder: (_, __) => Divider(),
      itemBuilder: (context, index) {
        final review = reviews[index];
        return ListTile(
          leading: Icon(Icons.person),
          title: Text(review.comment),
          subtitle: Text('Rating: [33m${review.rating}[0m'),
          trailing: Text('${review.createdAt.toLocal()}'.split(' ')[0]),
        );
      },
    );
  }
}
