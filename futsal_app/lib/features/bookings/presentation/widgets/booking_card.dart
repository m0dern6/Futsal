import 'package:flutter/material.dart';
import 'package:futsalpay/core/config/dimension.dart';
import 'package:futsalpay/features/bookings/data/model/booking_model.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;

  const BookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final titleStyle = TextStyle(
      color: colorScheme.onSurface,
      fontSize: Dimension.font(15.5),
      fontWeight: FontWeight.w700,
    );

    // Removed unused subtitleStyle to satisfy strict lints

    return Container(
      margin: EdgeInsets.only(bottom: Dimension.height(14)),
      padding: EdgeInsets.all(Dimension.width(14)),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(Dimension.width(14)),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.03),
            blurRadius: Dimension.width(10),
            offset: Offset(0, Dimension.height(4)),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: Dimension.width(48),
                height: Dimension.width(48),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(Dimension.width(14)),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: colorScheme.primary,
                  size: Dimension.width(22),
                ),
              ),
              SizedBox(width: Dimension.width(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.groundName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: titleStyle,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimension.width(10),
                  vertical: Dimension.height(5),
                ),
                decoration: BoxDecoration(
                  color: booking.statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(Dimension.width(20)),
                  border: Border.all(
                    color: booking.statusColor.withOpacity(0.4),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  booking.statusText,
                  style: TextStyle(
                    color: booking.statusColor,
                    fontSize: Dimension.font(10.5),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Dimension.height(12)),
          Wrap(
            spacing: Dimension.width(12),
            runSpacing: Dimension.height(8),
            children: [
              _InfoChip(
                icon: Icons.calendar_today_rounded,
                label:
                    '${booking.bookingDate.day.toString().padLeft(2, '0')}/${booking.bookingDate.month.toString().padLeft(2, '0')}/${booking.bookingDate.year}',
              ),
              _InfoChip(
                icon: Icons.access_time_rounded,
                label: '${booking.startTime} - ${booking.endTime}',
              ),
              _InfoChip(
                icon: Icons.payments_rounded,
                label: 'Rs. ${booking.totalAmount}',
              ),
            ],
          ),
          // Add Review button for completed bookings
          if (booking.statusText == 'Completed') ...[
            SizedBox(height: Dimension.height(16)),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                icon: Icon(Icons.rate_review_rounded),
                label: Text('Add Review'),
                onPressed: () {
                  // TODO: Show review input dialog/bottom sheet
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Add Review'),
                      content: Text('Review input form goes here.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Submit review
                            Navigator.of(context).pop();
                          },
                          child: Text('Submit'),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimension.width(12),
        vertical: Dimension.height(6),
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.35),
        borderRadius: BorderRadius.circular(Dimension.width(18)),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.35),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: colorScheme.primary, size: Dimension.width(14)),
          SizedBox(width: Dimension.width(6)),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: Dimension.font(11),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
