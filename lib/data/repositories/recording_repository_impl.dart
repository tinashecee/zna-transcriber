import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/recording.dart';
import '../../domain/repositories/recording_repository.dart';
import '../api/api_client.dart';
import '../models/recording_model.dart';
import 'recordings_cache_repository.dart';
import '../../services/offline_audio_download_service.dart';

/// Recording repository — list fetches are fresh from API; optional My List
/// JSON is persisted for offline via [RecordingsCacheRepository].
class RecordingRepositoryImpl implements RecordingRepository {
  RecordingRepositoryImpl(
    this._client, [
    RecordingsCacheRepository? recordingsCache,
    OfflineAudioDownloadService? offlineAudioDownloadService,
  ])  : _recordingsCache = recordingsCache,
        _offlineAudioDownloadService = offlineAudioDownloadService;

  final ApiClient _client;
  final RecordingsCacheRepository? _recordingsCache;
  final OfflineAudioDownloadService? _offlineAudioDownloadService;

  Future<List<String>> fetchCourts() async {
    final response = await _client.dio.get<dynamic>('/courts');
    final raw = response.data;
    final list = raw is List
        ? raw
        : (raw is Map<String, dynamic> ? raw['data'] as List? : null);
    final courts = (list ?? [])
        .map((e) => e is Map<String, dynamic> ? e['court_name'] : e)
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return courts;
  }

  /// Returns a map of `court_name -> province` built from `/courts`.
  /// The API returns a `province` field on each court entry, which is the
  /// only way to derive a recording's province (recordings only carry
  /// `court`, not `province`).
  @override
  Future<Map<String, String>> fetchCourtProvinces() async {
    final response = await _client.dio.get<dynamic>('/courts');
    final raw = response.data;
    final list = raw is List
        ? raw
        : (raw is Map<String, dynamic> ? raw['data'] as List? : null);
    final map = <String, String>{};
    for (final item in list ?? const []) {
      if (item is! Map<String, dynamic>) continue;
      final name = item['court_name']?.toString().trim() ?? '';
      final province = _provinceFromCourtJson(item);
      if (name.isEmpty || province.isEmpty) continue;
      map[name] = province;
    }
    return map;
  }

  Future<List<String>> fetchCourtrooms(String court) async {
    // Fetch fresh - courtrooms are part of the by_court map
    final response = await _client.dio.get<dynamic>('/courtrooms');
    final raw = response.data;
    final list = raw is List
        ? raw
        : (raw is Map<String, dynamic> ? raw['data'] as List? : null);
    final rooms = (list ?? [])
        .map((e) => e is Map<String, dynamic> ? e['courtroom_name'] : e)
        .map((e) => e.toString())
        .toList();
    return rooms;
  }

  Future<Map<String, List<String>>> fetchCourtroomsByCourt() async {
    // Make both API calls in parallel for better performance
    final courtsResponse = _client.dio.get<dynamic>('/courts');
    final courtroomsResponse = _client.dio.get<dynamic>('/courtrooms');
    
    final results = await Future.wait([courtsResponse, courtroomsResponse]);
    final courtsRaw = results[0].data;
    
    final courtsList = courtsRaw is List
        ? courtsRaw
        : (courtsRaw is Map<String, dynamic> ? courtsRaw['data'] as List? : null);
    
    // Create a map of court_id -> court_name
    final courtIdToName = <int, String>{};
    for (final courtItem in courtsList ?? const []) {
      if (courtItem is! Map<String, dynamic>) continue;
      final courtId = courtItem['court_id'];
      final courtName = courtItem['court_name']?.toString().trim() ?? '';
      if (courtId != null && courtName.isNotEmpty) {
        courtIdToName[courtId is int ? courtId : int.tryParse(courtId.toString()) ?? -1] = courtName;
      }
    }
    
    // Process courtrooms
    final raw = results[1].data;
    final list = raw is List
        ? raw
        : (raw is Map<String, dynamic> ? raw['data'] as List? : null);
    final map = <String, List<String>>{};
    for (final item in list ?? const []) {
      if (item is! Map<String, dynamic>) continue;
      
      // Try court_name first, then map court_id to court_name
      String? courtName = item['court_name']?.toString();
      if (courtName == null || courtName.isEmpty) {
        final courtId = item['court_id'];
        if (courtId != null) {
          final id = courtId is int ? courtId : int.tryParse(courtId.toString());
          if (id != null) {
            courtName = courtIdToName[id];
          }
        }
      }
      
      final roomName = (item['courtroom_name'] ?? '').toString();
      if (courtName == null || courtName.isEmpty || roomName.isEmpty) continue;
      map.putIfAbsent(courtName, () => []);
      map[courtName]!.add(roomName);
    }
    for (final entry in map.entries) {
      entry.value.sort();
    }
    return map;
  }

  @override
  Future<List<Recording>> fetchRecordings({
    required int page,
    required int pageSize,
    required RecordingFilters filters,
    String? userId,
    bool writeMyListCache = false,
  }) async {
    final useUserEndpoint = filters.tab == RecordingTab.myList;
    if (useUserEndpoint && (userId == null || userId.isEmpty)) {
      throw DioException(
        requestOptions: RequestOptions(path: '/user/recordings/latest_paginated'),
        message: 'user_id is required for user recordings',
      );
    }

    final dateFormatter = DateFormat('yyyy-MM-dd');
    final offset = (page - 1) * pageSize;
    final hasSearch = filters.query != null && filters.query!.trim().isNotEmpty;
    // When search is active, ignore court/courtroom filters
    // Otherwise, use the filters from the state
    final effectiveCourt = hasSearch ? null : (filters.court?.trim().isNotEmpty == true ? filters.court : null);
    final effectiveCourtroom = hasSearch ? null : (filters.courtroom?.trim().isNotEmpty == true ? filters.courtroom : null);
    final hasCourt = effectiveCourt != null && effectiveCourt.trim().isNotEmpty;
    final hasCourtroom =
        effectiveCourtroom != null && effectiveCourtroom.trim().isNotEmpty;

    final endpoint = useUserEndpoint
        ? '/user/recordings/latest_paginated'
        : '/recordings/latest_paginated';

    // Only use by_court endpoints when a courtroom is selected (not just court)
    // Court alone should not filter - only courtroom filters
    if (!useUserEndpoint && !hasSearch && hasCourtroom && hasCourt) {
      final encodedCourt = Uri.encodeComponent(effectiveCourt.trim());
      final encodedRoom = Uri.encodeComponent(effectiveCourtroom.trim());

      // Backend applies province scope + sorts by date_stamp desc, id desc.
      final courtEndpoint =
          '/recordings/by_court_and_room/$encodedCourt/$encodedRoom';

      final response = await _client.dio.get<List<dynamic>>(courtEndpoint);
      final items = (response.data ?? [])
          .map((json) => RecordingModel.fromJson(json as Map<String, dynamic>))
          .map((model) => model.toEntity())
          .toList();

      // Ensure "latest first" even if backend changes ordering.
      items.sort((a, b) {
        final byDate = b.date.compareTo(a.date);
        if (byDate != 0) return byDate;
        return b.id.compareTo(a.id);
      });

      // Client paginate.
      if (offset >= items.length) return const [];
      final end = (offset + pageSize) > items.length ? items.length : offset + pageSize;
      return items.sublist(offset, end);
    }

    final queryParameters = <String, dynamic>{
      'limit': pageSize,
      'offset': offset,
      'sort_by': 'date_stamp',
      'sort_dir': 'desc',
      if (filters.query != null && filters.query!.isNotEmpty) 'q': filters.query,
      // When courtroom is set, court must also be included (both are needed for filtering)
      if (effectiveCourtroom != null) 'courtroom': effectiveCourtroom,
      // Court should always be set when courtroom is selected
      if (effectiveCourtroom != null && effectiveCourt != null) 'court': effectiveCourt,
      if (filters.fromDate != null)
        'start_date': dateFormatter.format(filters.fromDate!),
      if (filters.toDate != null)
        'end_date': dateFormatter.format(filters.toDate!),
      if (useUserEndpoint) 'user_id': userId,
    };
    
    final response = await _client.dio.get<Map<String, dynamic>>(
      endpoint,
      queryParameters: queryParameters,
    );

    final rawList = response.data?['items'] as List<dynamic>? ?? [];
    final items = rawList
        .map((json) => RecordingModel.fromJson(json as Map<String, dynamic>))
        .map((model) => model.toEntity())
        .toList();

    if (writeMyListCache &&
        userId != null &&
        userId.isNotEmpty &&
        filters.tab == RecordingTab.myList) {
      final maps = <Map<String, dynamic>>[];
      for (final e in rawList) {
        if (e is Map<String, dynamic>) maps.add(Map<String, dynamic>.from(e));
      }
      await _recordingsCache?.upsertMyListItems(userId, maps);
      // Fire-and-forget audio prefetch (do not block list rendering).
      // This uses the authenticated Dio client (JWT) and saves to app storage.
      _offlineAudioDownloadService?.prefetchForMyList(
        ownerUserId: userId,
        myListItems: maps,
      );
    }

    return items;
  }

  @override
  Future<List<Recording>> fetchRecordingsByProvince(String provinceName) async {
    final encoded = Uri.encodeComponent(provinceName.trim());
    final endpoint = '/recordings/by_province/$encoded';
    print('[RecordingsRepo] GET $endpoint');
    final response = await _client.dio.get<dynamic>(endpoint);
    final raw = response.data;
    // The endpoint returns a bare JSON array of recordings.
    final list = raw is List
        ? raw
        : (raw is Map<String, dynamic> ? raw['items'] as List? ?? raw['data'] as List? : null);
    final items = (list ?? const [])
        .map((json) => RecordingModel.fromJson(json as Map<String, dynamic>))
        .map((model) => model.toEntity())
        .toList();
    items.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      if (byDate != 0) return byDate;
      return b.id.compareTo(a.id);
    });
    print('[RecordingsRepo] by_province returned ${items.length} items for "$provinceName"');
    return items;
  }

  @override
  Future<Recording> fetchRecording(String id) async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      '/recordings/$id',
    );
    final data = response.data;
    if (data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Recording not found',
      );
    }
    return RecordingModel.fromJson(data).toEntity();
  }

  static String _provinceFromCourtJson(Map<String, dynamic> item) {
    for (final key in ['province', 'province_name', 'Province']) {
      final value = item[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return '';
  }
}
