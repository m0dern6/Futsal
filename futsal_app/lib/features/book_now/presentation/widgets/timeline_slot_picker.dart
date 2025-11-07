import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:futsalpay/core/config/dimension.dart';

class TimeSlot {
  final TimeOfDay time;
  final bool isBooked;
  final int index; // index from 0..segmentCount-1
  bool isSelected;

  TimeSlot({
    required this.time,
    this.isBooked = false,
    required this.index,
    this.isSelected = false,
  });

  String get formattedTime {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}

class TimelineSlotPicker extends StatefulWidget {
  final TimeOfDay openingTime;
  final TimeOfDay closingTime;
  final List<TimeOfDay> bookedSlots; // start of each booked hour
  final Function(TimeSlot, TimeSlot) onSlotsSelected;
  final void Function(String message)? onError;
  final int slotDurationMinutes;

  const TimelineSlotPicker({
    super.key,
    required this.openingTime,
    required this.closingTime,
    required this.bookedSlots,
    required this.onSlotsSelected,
    this.onError,
    this.slotDurationMinutes = 60,
  });

  @override
  State<TimelineSlotPicker> createState() => _TimelineSlotPickerState();
}

class _TimelineSlotPickerState extends State<TimelineSlotPicker> {
  late List<TimeSlot> timeSlots; // segments
  TimeSlot? startSlot;
  TimeSlot? endSlot;

  int get _totalMinutes =>
      (widget.closingTime.hour * 60 + widget.closingTime.minute) -
      (widget.openingTime.hour * 60 + widget.openingTime.minute);

  int get _segmentCount =>
      math.max(1, (_totalMinutes / widget.slotDurationMinutes).ceil());

  @override
  void initState() {
    super.initState();
    timeSlots = _generateTimeSlots();
  }

  bool _sameBooked(List<TimeOfDay> a, List<TimeOfDay> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    final am = a.map((t) => t.hour * 60 + t.minute).toList()..sort();
    final bm = b.map((t) => t.hour * 60 + t.minute).toList()..sort();
    for (int i = 0; i < am.length; i++) {
      if (am[i] != bm[i]) return false;
    }
    return true;
  }

  @override
  void didUpdateWidget(covariant TimelineSlotPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final openingChanged = oldWidget.openingTime != widget.openingTime;
    final closingChanged = oldWidget.closingTime != widget.closingTime;
    final bookedChanged = !_sameBooked(
      oldWidget.bookedSlots,
      widget.bookedSlots,
    );

    if (openingChanged || closingChanged || bookedChanged) {
      final prevStartIdx = startSlot?.index;
      final prevEndIdx = endSlot?.index;
      timeSlots = _generateTimeSlots();
      if (!openingChanged && !closingChanged) {
        // Preserve selection if indices are still valid
        startSlot = (prevStartIdx != null && prevStartIdx < timeSlots.length)
            ? timeSlots[prevStartIdx]
            : null;
        endSlot = (prevEndIdx != null && prevEndIdx < timeSlots.length)
            ? timeSlots[prevEndIdx]
            : null;
      } else {
        // Opening/closing changed; reset selection
        startSlot = null;
        endSlot = null;
      }
      setState(() {});
    }
  }

  List<TimeSlot> _generateTimeSlots() {
    final slots = <TimeSlot>[];
    for (int i = 0; i < _segmentCount; i++) {
      final slotMinutes = _startInMinutes + (i * widget.slotDurationMinutes);
      final hour = (slotMinutes ~/ 60) % 24;
      final minute = slotMinutes % 60;
      final isBooked = widget.bookedSlots.any(
        (b) => b.hour == hour && b.minute == minute,
      );
      slots.add(
        TimeSlot(
          time: TimeOfDay(hour: hour, minute: minute),
          index: i,
          isBooked: isBooked,
        ),
      );
    }
    return slots;
  }

  int get _startInMinutes =>
      widget.openingTime.hour * 60 + widget.openingTime.minute;

  String _format(TimeOfDay t) {
    final h = t.hour;
    final m = t.minute.toString().padLeft(2, '0');
    final ap = h >= 12 ? 'PM' : 'AM';
    final dh = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$dh:$m $ap';
  }

  // Note: booking overlap validation happens on Continue in the parent screen.

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final openingLabel = _format(widget.openingTime);
    final closingLabel = _format(widget.closingTime);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final paddingH = Dimension.width(12);
            // Using discrete hour containers; no track/ticks needed
            final segmentWidth = Dimension.width(64);

            int? anchorIdx = startSlot?.index;
            int? boundaryIdx = endSlot?.index; // exclusive end boundary
            // Legacy range vars not needed in boxes UI
            // int? rangeStart = ...
            // int? rangeEndExclusive = ...

            // Discrete boxes view: no need to compute contiguous ranges

            // Tap handling happens per hour box below

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: paddingH),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      _timeChip(openingLabel, cs),
                      _timeChip(closingLabel, cs),
                    ],
                  ),
                ),
                SizedBox(height: Dimension.height(8)),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: paddingH),
                    child: Row(
                      children: List.generate(_segmentCount, (int i) {
                        final slot = timeSlots[i];
                        final isAnchorOnly =
                            (anchorIdx != null &&
                            boundaryIdx == null &&
                            i == anchorIdx);
                        final inSelectedRange =
                            (anchorIdx != null && boundaryIdx != null)
                            ? (i >= math.min(anchorIdx, boundaryIdx) &&
                                  i <= math.max(anchorIdx, boundaryIdx))
                            : false;

                        final bool isSelected = isAnchorOnly || inSelectedRange;
                        final bool isBooked = slot.isBooked;

                        Color bg;
                        Color fg = cs.onSurface;
                        if (isSelected) {
                          // Dark green for selected boxes
                          bg = const Color(0xFF2E7D32);
                          fg = Colors.white;
                        } else if (isBooked) {
                          bg = Colors.red.withOpacity(0.22);
                          fg = cs.onSurface.withOpacity(0.9);
                        } else {
                          bg = cs.surfaceContainerHighest;
                          fg = cs.onSurface.withOpacity(0.9);
                        }

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (startSlot == null) {
                                startSlot = slot;
                                endSlot = null;
                              } else if (endSlot == null) {
                                endSlot = slot;
                                final a = startSlot!;
                                final b = endSlot!;
                                final s = a.index <= b.index ? a : b;
                                final e = a.index <= b.index ? b : a;
                                widget.onSlotsSelected(s, e);
                              } else {
                                // Adjust existing range by nearest boundary
                                final sIdx = startSlot!.index;
                                final eIdx = endSlot!.index;
                                final minIdx = math.min(sIdx, eIdx);
                                final maxIdx = math.max(sIdx, eIdx);
                                final t = slot.index;

                                if (t > minIdx && t < maxIdx) {
                                  final distStart = t - minIdx;
                                  final distEnd = maxIdx - t;
                                  if (distStart < distEnd) {
                                    // Closer to start: move start to tap
                                    startSlot = timeSlots[t];
                                    endSlot = timeSlots[maxIdx];
                                  } else if (distEnd < distStart) {
                                    // Closer to end: move end to tap
                                    startSlot = timeSlots[minIdx];
                                    endSlot = timeSlots[t];
                                  } else {
                                    // Tie: prefer moving end (so 6..10 tap 8 => 6..8)
                                    startSlot = timeSlots[minIdx];
                                    endSlot = timeSlots[t];
                                  }
                                } else if (t <= minIdx) {
                                  // Tap to the left: move start to tap
                                  startSlot = timeSlots[t];
                                  endSlot = timeSlots[maxIdx];
                                } else {
                                  // t >= maxIdx
                                  // Tap to the right: move end to tap
                                  startSlot = timeSlots[minIdx];
                                  endSlot = timeSlots[t];
                                }

                                final a = startSlot!;
                                final b = endSlot!;
                                final s = a.index <= b.index ? a : b;
                                final e = a.index <= b.index ? b : a;
                                widget.onSlotsSelected(s, e);
                              }
                            });
                          },
                          child: Container(
                            width: segmentWidth,
                            height: Dimension.height(46),
                            margin: EdgeInsets.zero,
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(
                                Dimension.width(8),
                              ),
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _compactLabel(slot.time),
                              style: TextStyle(
                                fontSize: Dimension.font(10),
                                color: fg,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // No handle widgets needed for discrete containers

  String _compactLabel(TimeOfDay t) {
    final h = t.hour == 0 ? 12 : (t.hour > 12 ? t.hour - 12 : t.hour);
    final ap = t.hour >= 12 ? 'PM' : 'AM';
    return '$h$ap';
  }

  Widget _timeChip(String label, ColorScheme cs) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimension.width(8),
        vertical: Dimension.height(4),
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(Dimension.width(8)),
        border: Border.all(color: cs.outline.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: cs.onSurface.withOpacity(0.8),
          fontSize: Dimension.font(10),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
