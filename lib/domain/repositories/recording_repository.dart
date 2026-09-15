import '../entities/recording.dart';

class RecordingFilters {
  const RecordingFilters({
    this.court,
    this.courtroom,
    this.query,
    this.fromDate,
    this.toDate,
    this.tab = RecordingTab.all,
  });

  final String? court;
  final String? courtroom;
  final String? query;
  final DateTime? fromDate;
  final DateTime? toDate;
  final RecordingTab tab;
}

enum RecordingTab { all, myList, savedOffline }

abstract class RecordingRepository {
  /// Returns a map of `court_name -> province` built from `/courts`.
  /// Recordings don't carry `province`, so this is needed for province scoping.
  Future<Map<String, String>> fetchCourtProvinces();

  Future<List<Recording>> fetchRecordings({
    required int page,
    required int pageSize,
    required RecordingFilters filters,
    String? userId,
    /// When true, persist raw list JSON for [userId] (My List only, online sessions).
    bool writeMyListCache = false,
  });

  Future<Recording> fetchRecording(String id);

  /// Returns every case recording whose court's province matches
  /// [provinceName] (case-insensitive, server-side `ilike %{name}%`).
  /// The endpoint returns a flat list with no pagination or sort guarantees,
  /// so callers should sort/filter/paginate client-side.
  Future<List<Recording>> fetchRecordingsByProvince(String provinceName);
}
