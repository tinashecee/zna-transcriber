import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../services/auth_session.dart';
import '../../domain/entities/recording.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/recording_repository.dart';
import '../../services/dio_error_mapper.dart';

class RecordingsState {
  RecordingsState({
    required this.items,
    required this.isLoading,
    required this.page,
    required this.filters,
    this.errorMessage,
  });

  final List<Recording> items;
  final bool isLoading;
  final int page;
  final RecordingFilters filters;
  final String? errorMessage;

  RecordingsState copyWith({
    List<Recording>? items,
    bool? isLoading,
    int? page,
    RecordingFilters? filters,
    String? errorMessage,
  }) {
    return RecordingsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      page: page ?? this.page,
      filters: filters ?? this.filters,
      errorMessage: errorMessage,
    );
  }

  factory RecordingsState.initial({bool apiKeySession = false}) =>
      RecordingsState(
        items: const [],
        isLoading: false,
        page: 1,
        // API-key sessions browse the full catalog; JWT users start on My List.
        filters: RecordingFilters(
          tab: apiKeySession ? RecordingTab.all : RecordingTab.myList,
        ),
      );
}

class RecordingsController extends StateNotifier<RecordingsState> {
  RecordingsController(Ref ref)
      : _ref = ref,
        super(
          RecordingsState.initial(
            apiKeySession: ref.read(authSessionProvider).hasApiKey,
          ),
        );

  final Ref _ref;
  static const _pageSize = 20;

  /// After [dispose] (e.g. provider invalidation on logout), async work must
  /// not call [state] setters — StateNotifier throws [StateError].
  bool _alive = true;

  @override
  void dispose() {
    _alive = false;
    super.dispose();
  }

  void _set(RecordingsState next) {
    if (!_alive) return;
    state = next;
  }

  void _mutate(RecordingsState Function(RecordingsState s) fn) {
    if (!_alive) return;
    state = fn(state);
  }

  /// Roles limited to recordings in their own province on the All tab.
  /// API-key sessions are never province-scoped (full court/recording access).
  static bool isProvinceScopedRole(String? role, {bool hasApiKey = false}) {
    if (hasApiKey) return false;
    final normalized = role?.toLowerCase().trim();
    return normalized == 'transcriber' || normalized == 'court_recorder';
  }

  /// Offline-only session has no JWT — All / My List need the API.
  void enterOfflinePlaceholder() {
    _mutate(
      (s) => s.copyWith(
        items: const [],
        isLoading: false,
        page: 1,
        errorMessage:
            'Offline mode: connect online and sign in with a JWT to browse '
            'All or My List. Open "Saved offline" for cached My List copies.',
      ),
    );
    print('[RecordingsController] offline-only placeholder applied');
  }

  Future<void> bootstrapOfflineSession() async {
    _set(
      RecordingsState(
        items: const [],
        isLoading: true,
        page: 1,
        filters: const RecordingFilters(tab: RecordingTab.savedOffline),
        errorMessage: null,
      ),
    );
    await _load(page: 1, replace: true);
  }

  Future<void> loadInitial() async {
    if (!_alive) return;
    final filters = state.filters;
    _set(
      RecordingsState(
        items: const [],
        isLoading: true,
        page: 1,
        filters: filters,
        errorMessage: null,
      ),
    );
    print('[RecordingsController] State cleared, fetching fresh from API...');
    await _load(page: 1, replace: true);
  }

  Future<void> loadMore() async {
    if (!_alive) return;
    if (state.isLoading) return;
    await _load(page: state.page + 1, replace: false);
  }

  Future<void> updateFilters(RecordingFilters filters) async {
    if (!_alive) return;
    final current = state.filters;
    final hasQuery = filters.query != null && filters.query!.trim().isNotEmpty;
    final courtChanged =
        filters.court != current.court || filters.courtroom != current.courtroom;
    final queryChanged = filters.query != current.query;

    var normalized = filters;
    if (hasQuery) {
      normalized = RecordingFilters(
        court: null,
        courtroom: null,
        query: filters.query?.trim(),
        fromDate: filters.fromDate,
        toDate: filters.toDate,
        tab: filters.tab,
      );
    } else if (courtChanged && queryChanged) {
      // Court selection should clear search to avoid conflict.
      normalized = RecordingFilters(
        court: filters.court,
        courtroom: filters.courtroom,
        query: null,
        fromDate: filters.fromDate,
        toDate: filters.toDate,
        tab: filters.tab,
      );
    } else if (courtChanged && !hasQuery) {
      normalized = RecordingFilters(
        court: filters.court,
        courtroom: filters.courtroom,
        query: null,
        fromDate: filters.fromDate,
        toDate: filters.toDate,
        tab: filters.tab,
      );
    }

    _mutate((s) => s.copyWith(filters: normalized, page: 1, items: []));
    await loadInitial();
  }

  Future<void> _load({required int page, required bool replace}) async {
    if (!_alive) return;
    try {
      final repo = _ref.read(recordingRepositoryProvider);
      final session = _ref.read(authSessionProvider);
      final user = session.user;
      final userId = user?.id;
      final f = state.filters;
      final offlineOnly = session.offlineOnly;
      print(
        '[RecordingsController] _load page=$page replace=$replace '
        'tab=${f.tab.name} role=${user?.role} province=${user?.province} '
        'userId=$userId query="${f.query}" court="${f.court}" '
        'courtroom="${f.courtroom}" from=${f.fromDate} to=${f.toDate}',
      );

      if (f.tab == RecordingTab.savedOffline) {
        final cache = _ref.read(recordingsCacheRepositoryProvider);
        if (userId == null || userId.isEmpty) {
          _mutate(
            (s) => s.copyWith(
              isLoading: false,
              items: const [],
              errorMessage: 'Sign in required to view saved recordings.',
            ),
          );
          return;
        }
        if (page > 1) {
          _mutate((s) => s.copyWith(isLoading: false));
          return;
        }
        final items = await cache.recordingsForUser(userId);
        if (!_alive) return;
        _mutate(
          (s) => s.copyWith(
            isLoading: false,
            page: 1,
            items: items,
            errorMessage: items.isEmpty
                ? 'No recordings saved on this device yet. Sign in online and '
                      'open My List to refresh the offline copy.'
                : null,
          ),
        );
        return;
      }

      if (offlineOnly &&
          (f.tab == RecordingTab.all || f.tab == RecordingTab.myList)) {
        enterOfflinePlaceholder();
        return;
      }

      if (state.filters.tab == RecordingTab.all &&
          isProvinceScopedRole(user?.role, hasApiKey: session.hasApiKey)) {
        final f = state.filters;
        final hasCourtFilter = (f.court ?? '').trim().isNotEmpty ||
            (f.courtroom ?? '').trim().isNotEmpty;

        final List<Recording> items;
        if (hasCourtFilter) {
          print(
            '[RecordingsController] scoped role + court filter '
            '(standard fetchRecordings)',
          );
          items = await repo.fetchRecordings(
            page: page,
            pageSize: _pageSize,
            filters: f,
          );
        } else {
          print('[RecordingsController] scoped path (province only)');
          items = await _loadScopedAll(
            repo: repo,
            user: user!,
            page: page,
          );
        }
        if (!_alive) return;
        print(
          '[RecordingsController] scoped path returned ${items.length} items '
          'for page=$page',
        );
        _mutate(
          (s) => s.copyWith(
            isLoading: false,
            page: page,
            items: replace ? items : [...s.items, ...items],
          ),
        );
        return;
      }

      print('[RecordingsController] default path (fetchRecordings)');
      final filters = state.filters;
      final items = await repo.fetchRecordings(
        page: page,
        pageSize: _pageSize,
        filters: filters,
        userId: userId,
        writeMyListCache:
            !offlineOnly && filters.tab == RecordingTab.myList,
      );
      if (!_alive) return;
      print('[RecordingsController] default path returned ${items.length} items');

      _mutate(
        (s) => s.copyWith(
          isLoading: false,
          page: page,
          items: replace ? items : [...s.items, ...items],
        ),
      );
    } catch (error) {
      if (!_alive) return;
      print('[RecordingsController] _load error: $error');
      _mutate(
        (s) => s.copyWith(
          isLoading: false,
          errorMessage: mapDioError(error),
        ),
      );
    }
  }

  /// Province-scoped fetch + client-side filter/sort/paginate for
  /// transcriber / court_recorder on the All tab.
  Future<List<Recording>> _loadScopedAll({
    required RecordingRepository repo,
    required User user,
    required int page,
  }) async {
    if (!_alive) return const [];
    final userProvince = user.province?.trim() ?? '';
    final filters = state.filters;

    // Province base set: everything whose court's province matches the
    // user's province. If the user has no province, this set is empty and
    // the user only sees what's in their province.
    print('[RecordingsController] scoped fetch start: province="$userProvince"');
    final provinceItems = userProvince.isEmpty
        ? <Recording>[]
        : await repo.fetchRecordingsByProvince(userProvince);
    if (!_alive) return const [];
    print(
      '[RecordingsController] scoped fetch done: province=${provinceItems.length}',
    );

    var combined = provinceItems;
    final beforeFilterCount = combined.length;

    combined = _applyClientFilters(combined, filters);
    final afterFilterCount = combined.length;

    combined.sort((a, b) => b.date.compareTo(a.date));

    final start = (page - 1) * _pageSize;
    if (start >= combined.length) {
      print(
        '[RecordingsController] scoped all: beforeFilter=$beforeFilterCount '
        'afterFilter=$afterFilterCount page=$page -> 0 (past end)',
      );
      return const [];
    }
    final end =
        (start + _pageSize) > combined.length ? combined.length : start + _pageSize;
    final pageItems = combined.sublist(start, end);

    print(
      '[RecordingsController] scoped all: beforeFilter=$beforeFilterCount '
      'afterFilter=$afterFilterCount page=$page -> ${pageItems.length}',
    );
    return pageItems;
  }

  List<Recording> _applyClientFilters(
    List<Recording> items,
    RecordingFilters filters,
  ) {
    final q = filters.query?.trim().toLowerCase() ?? '';
    final court = filters.court?.trim();
    final courtroom = filters.courtroom?.trim();
    final from = filters.fromDate;
    final to = filters.toDate;

    return items.where((r) {
      if (q.isNotEmpty) {
        final haystack = [
          r.caseNumber,
          r.title,
          r.court,
          r.courtroom,
          r.judgeName,
          r.prosecutionCounsel,
          r.defenseCounsel,
        ].join(' ').toLowerCase();
        if (!haystack.contains(q)) return false;
      }
      if (q.isEmpty) {
        if (court != null && court.isNotEmpty && r.court != court) {
          return false;
        }
        if (courtroom != null && courtroom.isNotEmpty && r.courtroom != courtroom) {
          return false;
        }
      }
      if (from != null && r.date.isBefore(DateTime(from.year, from.month, from.day))) {
        return false;
      }
      if (to != null) {
        final endOfDay = DateTime(to.year, to.month, to.day, 23, 59, 59);
        if (r.date.isAfter(endOfDay)) return false;
      }
      return true;
    }).toList();
  }
}

final recordingsControllerProvider =
    StateNotifierProvider<RecordingsController, RecordingsState>((ref) {
  final notifier = RecordingsController(ref);
  final offlineOnly = ref.read(authSessionProvider).offlineOnly;
  Future.microtask(() async {
    if (offlineOnly) {
      await notifier.bootstrapOfflineSession();
    } else {
      await notifier.loadInitial();
    }
  });
  return notifier;
});
