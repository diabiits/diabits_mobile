class LastSyncRequest {
  final String syncTime;

  LastSyncRequest({required this.syncTime});

  /// Converts the [LastSyncRequest] instance to a JSON map.
  Map<String, dynamic> toJson() => {"syncTime": syncTime};
}
