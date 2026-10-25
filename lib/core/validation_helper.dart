enum DateTimeError { none, pastDate, pastTime }

class DateTimeValidator {
  static DateTimeError check(DateTime date, DateTime time, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    final pickedDay = DateTime(date.year, date.month, date.day);

    if (pickedDay.isBefore(today)) return DateTimeError.pastDate;

    final picked = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    if (picked.isBefore(current)) return DateTimeError.pastTime;

    return DateTimeError.none;
  }
}