import 'package:flutter/material.dart';
import 'package:futsalpay/core/config/dimension.dart';
import 'package:futsalpay/features/reviews/data/repository/review_repository_impl.dart';

class AddReviewDialog extends StatefulWidget {
  final int groundId;
  final String groundName;

  const AddReviewDialog({
    Key? key,
    required this.groundId,
    required this.groundName,
  }) : super(key: key);

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  int _rating = 5;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      print('=== SUBMITTING REVIEW ===');
      print('Ground ID: ${widget.groundId}');
      print('Ground ID Type: ${widget.groundId.runtimeType}');
      print('Ground Name: ${widget.groundName}');
      print('Rating: $_rating');
      print('Comment: ${_commentController.text.trim()}');

      final reviewData = {
        'groundId': widget.groundId, // Send as integer, not string
        'rating': _rating,
        'comment': _commentController.text.trim(),
      };
      print('Review Data: $reviewData');
      print('Review Data groundId type: ${reviewData['groundId'].runtimeType}');

      final repository = ReviewRepositoryImpl();
      final result = await repository.createReview(reviewData);

      print('Review created successfully: ${result.id}');

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('=== ERROR SUBMITTING REVIEW ===');
      print('Error: $e');
      print('Stack Trace: $stackTrace');

      if (mounted) {
        setState(() => _isSubmitting = false);

        // Show user-friendly error for duplicate review
        String errorMessage;
        if (e.toString().contains('already reviewed this ground')) {
          errorMessage = 'You have already submitted a review for this ground.';
        } else {
          errorMessage = 'Failed to submit review. Please try again.';
        }

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error Submitting Review'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    errorMessage,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text('Error: $e'),
                  const SizedBox(height: 8),
                  const Text(
                    'Debug Info:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Ground ID: ${widget.groundId}'),
                  Text('Rating: $_rating'),
                  Text(
                    'Comment Length: ${_commentController.text.trim().length}',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit review: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimension.width(20)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(Dimension.width(20)),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(Dimension.width(10)),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(
                          Dimension.width(12),
                        ),
                      ),
                      child: Icon(
                        Icons.rate_review_rounded,
                        color: colorScheme.primary,
                        size: Dimension.width(24),
                      ),
                    ),
                    SizedBox(width: Dimension.width(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Review',
                            style: TextStyle(
                              fontSize: Dimension.font(20),
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            widget.groundName,
                            style: TextStyle(
                              fontSize: Dimension.font(13),
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Dimension.height(20)),
                Text(
                  'Rating',
                  style: TextStyle(
                    fontSize: Dimension.font(14),
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: Dimension.height(10)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () => setState(() => _rating = index + 1),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimension.width(4),
                        ),
                        child: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: index < _rating
                              ? const Color(0xFFFFC107)
                              : colorScheme.onSurface.withOpacity(0.3),
                          size: Dimension.width(36),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: Dimension.height(20)),
                Text(
                  'Your Review',
                  style: TextStyle(
                    fontSize: Dimension.font(14),
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: Dimension.height(10)),
                TextFormField(
                  controller: _commentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Share your experience...',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.4),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withOpacity(
                      0.3,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimension.width(12)),
                      borderSide: BorderSide(
                        color: colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimension.width(12)),
                      borderSide: BorderSide(
                        color: colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimension.width(12)),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your review';
                    }
                    if (value.trim().length < 10) {
                      return 'Review must be at least 10 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: Dimension.height(24)),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: Dimension.height(14),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              Dimension.width(12),
                            ),
                          ),
                          side: BorderSide(color: colorScheme.outline),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: Dimension.font(14),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: Dimension.width(12)),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitReview,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: EdgeInsets.symmetric(
                            vertical: Dimension.height(14),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              Dimension.width(12),
                            ),
                          ),
                        ),
                        child: _isSubmitting
                            ? SizedBox(
                                height: Dimension.width(20),
                                width: Dimension.width(20),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    colorScheme.onPrimary,
                                  ),
                                ),
                              )
                            : Text(
                                'Submit',
                                style: TextStyle(
                                  fontSize: Dimension.font(14),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
