enum DateTimeError { none, pastDate, pastTime, invalidRange }

class DateTimeValidator {
  static DateTimeError check(DateTime dateTime, {DateTime? now}) {
    final current = now ?? DateTime.now();

    final today = DateTime(current.year, current.month, current.day);
    final pickedDay = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (pickedDay.isBefore(today)) return DateTimeError.pastDate;
    if (dateTime.isBefore(current)) return DateTimeError.pastTime;

    return DateTimeError.none;
  }

  static DateTimeError checkRange(DateTime start, DateTime end, {DateTime? now}) {
    final endError = check(end, now: now);
    if (endError != DateTimeError.none) return endError;

    if (!end.isAfter(start)) return DateTimeError.invalidRange;

    return DateTimeError.none;
  }

  static DateTimeError checkSeparate(DateTime date, DateTime time, {DateTime? now}) {
    final combined = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    return check(combined, now: now);
  }
}