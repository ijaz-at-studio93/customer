import 'package:flutter/material.dart';

import '../../properties/properties.dart';
import '../../utils/utils.dart';

/// Represents a header widget for displaying the name of a month and year.
class SelectedDateWidget extends StatefulWidget {
  const SelectedDateWidget({
    super.key,
    required this.date,
    this.headerProps,
    required this.locale,
  });

  /// Represents the date for the month header.
  final DateTime date;

  /// A `String` that represents the locale code to use for formatting the month name in the header.
  final String locale;

  /// Contains properties for configuring the appearance and behavior of the month header.
  final EasyHeaderProps? headerProps;

  @override
  State<SelectedDateWidget> createState() => _SelectedDateWidgetState();
}

class _SelectedDateWidgetState extends State<SelectedDateWidget> {
  bool  isToday  =  false;
  @override
  Widget build(BuildContext context) {
    //  This code conditionally displays the selected date in the header of the EasyDateTimeLineWidget
    //  based on the showSelectedDate property of the headerProps object
    //  and formats it according to the selected date format.

      return Visibility(
      visible:
          (widget.headerProps == null ? true : widget.headerProps!.showSelectedDate == true),
      child: Text(
        _getDateFormat(),
        style:
            widget.headerProps?.selectedDateStyle ?? EasyTextStyles.selectedDateStyle,
      ),
    );
  }

  String _getDateFormat() {
    if (widget.headerProps == null) {
      return EasyDateFormatter.fullDayName(
        widget.date,
        widget.locale,
      );
    } else {
      if (widget.headerProps!.dateFormatter != null) {
        return EasyDateFormatter.customFormat(
          widget.headerProps!.dateFormatter!.format(),
          widget.date,
          widget.locale,
        );
      } else {
        // TODO: Remove this deprecated code after v1.0.2
        return EasyDateFormatter.customFormat(
          widget.headerProps!.selectedDateFormat.formatter,
          widget.date,
          widget.locale,
        );
      }
    }
  }
}
