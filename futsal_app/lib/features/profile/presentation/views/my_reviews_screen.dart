import 'package:flutter/material.dart';
import '../../../reviews/data/repository/review_repository_impl.dart';
import '../../../reviews/presentation/review_list.dart';
import '../../../reviews/data/model/review_model.dart';

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({Key? key}) : super(key: key);

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  List<ReviewModel> _myReviews = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchMyReviews();
  }

  Future<void> _fetchMyReviews() async {
    setState(() => _loading = true);
    try {
      final repo = ReviewRepositoryImpl();
      final reviews = await repo.getUserReviews();
      setState(() => _myReviews = reviews);
    } catch (e) {
      // Optionally show error
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Reviews')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchMyReviews,
              child: ReviewList(reviews: _myReviews),
            ),
    );
  }
}
