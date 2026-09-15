import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/providers.dart';
import '../../domain/entities/user.dart';
import '../../services/dio_error_mapper.dart';

const Color _accent = Color(0xFF115343);

/// Returns the selected magistrate [User] on confirm, or null if cancelled.
Future<User?> showProofreadMagistrateDialog({
  required BuildContext context,
  required WidgetRef ref,
  required String courtName,
  required String caseNumber,
  required String caseTitle,
}) {
  return showDialog<User>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _ProofreadMagistrateDialog(
      courtName: courtName,
      caseNumber: caseNumber,
      caseTitle: caseTitle,
    ),
  );
}

class _ProofreadMagistrateDialog extends ConsumerStatefulWidget {
  const _ProofreadMagistrateDialog({
    required this.courtName,
    required this.caseNumber,
    required this.caseTitle,
  });

  final String courtName;
  final String caseNumber;
  final String caseTitle;

  @override
  ConsumerState<_ProofreadMagistrateDialog> createState() =>
      _ProofreadMagistrateDialogState();
}

class _ProofreadMagistrateDialogState
    extends ConsumerState<_ProofreadMagistrateDialog> {
  bool _loading = true;
  String? _error;
  String? _caseProvince;
  List<User> _magistrates = const [];
  String? _selectedId;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(recordingRepositoryProvider);
      final provinces = await repo.fetchCourtProvinces();
      final courtKey = widget.courtName.trim();
      String? province = provinces[courtKey];
      if (province == null || province.isEmpty) {
        for (final e in provinces.entries) {
          if (e.key.trim().toLowerCase() == courtKey.toLowerCase()) {
            province = e.value;
            break;
          }
        }
      }

      final magistrates = await ref
          .read(assignmentRepositoryProvider)
          .getMagistrateUsers(province: province);

      if (!mounted) return;
      setState(() {
        _caseProvince = province;
        _magistrates = magistrates;
        _loading = false;
        if (magistrates.length == 1) {
          _selectedId = magistrates.first.id;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = mapDioError(e);
      });
    }
  }

  User? get _selected {
    if (_selectedId == null) return null;
    for (final u in _magistrates) {
      if (u.id == _selectedId) return u;
    }
    return null;
  }

  List<User> get _filteredMagistrates {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _magistrates;
    return _magistrates.where((u) {
      final name = u.name.toLowerCase();
      final email = u.email.toLowerCase();
      final role = u.role.toLowerCase();
      return name.contains(q) || email.contains(q) || role.contains(q);
    }).toList();
  }

  Widget _buildMagistratePicker() {
    final filtered = _filteredMagistrates;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Magistrate *',
          style: GoogleFonts.roboto(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search by name, email, or role…',
            prefixIcon: const Icon(Icons.search, size: 20),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear',
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  ),
            border: const OutlineInputBorder(),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: filtered.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No magistrates match "$_query".',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: Colors.grey.shade200),
                  itemBuilder: (context, index) {
                    final u = filtered[index];
                    final label =
                        u.name.isNotEmpty ? u.name : u.email;
                    final selected = u.id == _selectedId;
                    return ListTile(
                      dense: true,
                      selected: selected,
                      selectedTileColor: _accent.withValues(alpha: 0.08),
                      leading: Icon(
                        selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        size: 20,
                        color: selected ? _accent : Colors.grey,
                      ),
                      title: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      subtitle: Text(
                        '${u.role}${u.email.isNotEmpty && u.name.isNotEmpty ? ' · ${u.email}' : ''}',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.roboto(
                          fontSize: 11,
                          color: Colors.grey[700],
                        ),
                      ),
                      onTap: () => setState(() => _selectedId = u.id),
                    );
                  },
                ),
        ),
        if (_selected != null) ...[
          const SizedBox(height: 8),
          Text(
            'Selected: ${_selected!.name.isNotEmpty ? _selected!.name : _selected!.email}',
            style: GoogleFonts.roboto(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _accent,
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.gavel, color: _accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Send for proof-reading',
              style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To mark this case as Completed, select a magistrate to proof-read '
              'the transcript. An email will be sent with case details and a link '
              'to open it on testimony.co.zw.',
              style: GoogleFonts.roboto(fontSize: 13, color: Colors.grey[800]),
            ),
            const SizedBox(height: 12),
            Text(
              '${widget.caseNumber} · ${widget.caseTitle}',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w600,
                color: _accent,
              ),
            ),
            if (_caseProvince != null && _caseProvince!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Province: $_caseProvince',
                style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
            const SizedBox(height: 16),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _error!,
                    style: GoogleFonts.roboto(color: Colors.red.shade700),
                  ),
                  const SizedBox(height: 8),
                  TextButton(onPressed: _load, child: const Text('Retry')),
                ],
              )
            else if (_magistrates.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Text(
                  _caseProvince == null || _caseProvince!.isEmpty
                      ? 'No magistrates found. Could not determine the province '
                          'for court "${widget.courtName}".'
                      : 'No magistrates found for province "$_caseProvince". '
                          'Ask an admin to add a magistrate for this province.',
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    color: Colors.orange.shade900,
                  ),
                ),
              )
            else
              _buildMagistratePicker(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _selected == null
              ? null
              : () => Navigator.of(context).pop(_selected),
          icon: const Icon(Icons.send, size: 16),
          label: const Text('Send & complete'),
          style: FilledButton.styleFrom(backgroundColor: _accent),
        ),
      ],
    );
  }
}

/// Extracts a useful message from Dio errors for proof-read feedback.
String proofreadErrorMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map) {
      final msg = data['message']?.toString() ?? data['error']?.toString();
      if (msg != null && msg.trim().isNotEmpty) {
        return msg.trim();
      }
    }
    if (error.response?.statusCode == 503) {
      return 'Email service is unavailable. Please try again later.';
    }
    if (error.response?.statusCode == 403) {
      return 'You are not assigned to this case and cannot request proof-reading.';
    }
  }
  return mapDioError(error);
}
