

// 1. كلاس جديد لتمثيل أي عنصر على الخط الزمني
class TimelineItem {
  final DateTime date;
  final dynamic event; // يمكن أن يكون معاملة أو هدفاً

  TimelineItem({required this.date, required this.event});
}
