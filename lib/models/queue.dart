class QueueStep {
  final String titleKey;
  final String descriptionKey;
  final bool isCompleted;
  final bool isCurrent;
  final String? time;

  const QueueStep({
    required this.titleKey,
    required this.descriptionKey,
    this.isCompleted = false,
    this.isCurrent = false,
    this.time,
  });
}

class LiveQueueData {
  final String tokenNumber;
  final String gate;
  final String crop;
  final String mandiName;
  final int farmersAhead;
  final int estimatedWaitMinutes;
  final int totalDailyCapacity;
  final int currentGateProcessing;
  final List<QueueStep> steps;

  const LiveQueueData({
    required this.tokenNumber,
    required this.gate,
    required this.crop,
    required this.mandiName,
    required this.farmersAhead,
    required this.estimatedWaitMinutes,
    required this.totalDailyCapacity,
    required this.currentGateProcessing,
    required this.steps,
  });

  String get formattedWaitTime {
    final hours = estimatedWaitMinutes ~/ 60;
    final mins = estimatedWaitMinutes % 60;
    if (hours > 0 && mins > 0) {
      return '~ $hours hr $mins min';
    } else if (hours > 0) {
      return '~ $hours hr';
    } else {
      return '~ $mins min';
    }
  }
}
