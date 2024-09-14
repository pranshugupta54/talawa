import 'package:intl/intl.dart';

String combineDateTime(String date, String time) {
  return '$date $time';
}

Map<String, String> splitDateTime(String dateTimeStr) {
  final DateTime dateTime = DateTime.parse(dateTimeStr).toUtc();
  return {
    'date': DateFormat('yyyy-MM-dd').format(dateTime),
    'time': DateFormat('HH:mm:ss.SSS').format(dateTime),
  };
}

String convertUTCToLocal(String utcTime) {
  final DateTime dateTime = DateTime.parse(utcTime).toLocal();
  return DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').format(dateTime);
}

String convertLocalToUTC(String localTime) {
  final DateTime dateTime = DateTime.parse(localTime).toUtc();
  return DateFormat('yyyy-MM-ddTHH:mm:ss.SSS\'Z\'').format(dateTime);
}

void traverseAndConvertDates(
  Map<String, dynamic> obj,
  String Function(String) convertFn,
  Map<String, String> Function(String) splitFn,
) {
  obj.forEach((key, value) {
    dateTimeFields['pairedFields'].forEach((field) {
      if (key == field['dateField'] && obj.containsKey(field['timeField'])) {
        final combinedDateTime = combineDateTime(
          obj[field['dateField']] as String,
          obj[field['timeField']] as String,
        );
        final convertedDateTime = convertFn(combinedDateTime);
        final splitDateTime = splitFn(convertedDateTime);
        obj[field['dateField']] = splitDateTime['date'];
        obj[field['timeField']] = splitDateTime['time'];
      }
    });

    if (dateTimeFields['directFields'].contains(key)) {
      obj[key] = convertFn(value as String);
    }

    if (value is Map) {
      traverseAndConvertDates(value, convertFn, splitFn);
    } else if (value is List) {
      for (var item in value) {
        if (item is Map) {
          traverseAndConvertDates(item, convertFn, splitFn);
        }
      }
    }
  });
}

const dateTimeFields = {
  'directFields': [
    'createdAt',
    'birthDate',
    'updatedAt',
    'recurrenceStartDate',
    'recurrenceEndDate',
    'pluginCreatedBy',
    'dueDate',
    'completionDate',
    'startCursor',
    'endCursor',
  ],
  'pairedFields': [
    {'dateField': 'startDate', 'timeField': 'startTime'},
    {'dateField': 'endDate', 'timeField': 'endTime'},
  ],
};
