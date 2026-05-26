part of '../character_notebook_page.dart';

const String _historyStorageKey = 'history.timeline.v1';
const _HistoryEmotionWheel _historyEmotionWheel = _HistoryEmotionWheel.plutchik;
const Color _historyTimelineBackgroundColor = Color(0xFFFDF2F8);

enum _HistoryEmotionWheel { arousalValence, plutchik }

class _HistoryMilestoneDetails {
  final String emotionId;
  final List<String> emotionIds;
  final String markdown;
  final int? month;
  final int? day;

  const _HistoryMilestoneDetails({
    required this.emotionId,
    this.emotionIds = const <String>[],
    this.markdown = '',
    this.month,
    this.day,
  });

  List<String> get resolvedEmotionIds =>
      emotionIds.isEmpty ? [emotionId] : emotionIds;

  _HistoryMilestoneDetails copyWith({
    String? emotionId,
    List<String>? emotionIds,
    String? markdown,
    int? month,
    bool clearMonth = false,
    int? day,
    bool clearDay = false,
  }) {
    return _HistoryMilestoneDetails(
      emotionId: emotionId ?? this.emotionId,
      emotionIds: emotionIds ?? this.emotionIds,
      markdown: markdown ?? this.markdown,
      month: clearMonth ? null : month ?? this.month,
      day: clearDay ? null : day ?? this.day,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'emotionId': emotionId,
      'emotionIds': emotionIds,
      'markdown': markdown,
      'month': month,
      'day': day,
    };
  }

  factory _HistoryMilestoneDetails.fromJson(
    Map<String, Object?> json,
    _HistoryEmotionWheel wheel,
  ) {
    final catalog = _historyEmotionCatalog(wheel);
    final rawEmotionId = json['emotionId'] as String?;
    final emotionIds = _readHistoryEmotionIds(
      json['emotionIds'],
      rawEmotionId,
      wheel,
    );
    return _HistoryMilestoneDetails(
      emotionId: emotionIds.isEmpty ? catalog.first.id : emotionIds.first,
      emotionIds: emotionIds,
      markdown: json['markdown'] as String? ?? '',
      month: _readHistoryInt(json['month']),
      day: _readHistoryInt(json['day']),
    );
  }
}

class _CharacterHistoryDraft {
  final double? deathAge;
  final _HistoryEmotionWheel emotionWheel;
  final _HistoryMilestoneDetails birthDetails;
  final _HistoryMilestoneDetails deathDetails;
  final List<_CharacterHistoryEvent> events;

  const _CharacterHistoryDraft({
    this.deathAge,
    this.emotionWheel = _historyEmotionWheel,
    this.birthDetails = const _HistoryMilestoneDetails(
      emotionId: 'alegria_plutchik',
    ),
    this.deathDetails = const _HistoryMilestoneDetails(
      emotionId: 'tristeza_plutchik',
    ),
    this.events = const <_CharacterHistoryEvent>[],
  });

  _CharacterHistoryDraft copyWith({
    double? deathAge,
    bool clearDeathAge = false,
    _HistoryEmotionWheel? emotionWheel,
    _HistoryMilestoneDetails? birthDetails,
    _HistoryMilestoneDetails? deathDetails,
    List<_CharacterHistoryEvent>? events,
  }) {
    return _CharacterHistoryDraft(
      deathAge: clearDeathAge ? null : deathAge ?? this.deathAge,
      emotionWheel: emotionWheel ?? this.emotionWheel,
      birthDetails: birthDetails ?? this.birthDetails,
      deathDetails: deathDetails ?? this.deathDetails,
      events: events ?? this.events,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'deathAge': deathAge,
      'emotionWheel': _historyEmotionWheel.name,
      'birthDetails': birthDetails.toJson(),
      'deathDetails': deathDetails.toJson(),
      'events': events.map((event) => event.toJson()).toList(growable: false),
    };
  }

  factory _CharacterHistoryDraft.fromJson(Map<String, Object?> json) {
    final rawEvents = json['events'];
    final emotionWheel = _historyEmotionWheelFromName(
      json['emotionWheel'] as String?,
    );
    var birthDetails = _readHistoryMilestoneDetails(
      json['birthDetails'],
      emotionWheel,
    );
    var deathDetails = _readHistoryMilestoneDetails(
      json['deathDetails'],
      emotionWheel,
    );
    var deathAge = _readHistoryDouble(json['deathAge']);

    final rawMilestones = json['milestones'];
    if (rawMilestones is List) {
      for (final rawMilestone in rawMilestones.whereType<Map>()) {
        final milestone = rawMilestone.map(
          (key, value) => MapEntry(key.toString(), value),
        );
        final type = _historyTimelineItemTypeFromName(
          milestone['type'] as String?,
        );
        final details = _readHistoryMilestoneDetails(
          milestone['details'],
          emotionWheel,
        );
        if (type == _HistoryTimelineItemType.birth) {
          birthDetails = details;
        } else if (type == _HistoryTimelineItemType.death && deathAge == null) {
          deathAge = _readHistoryDouble(milestone['ageOffset']);
          deathDetails = details;
        }
      }
    }

    return _CharacterHistoryDraft(
      deathAge: deathAge,
      emotionWheel: emotionWheel,
      birthDetails: birthDetails,
      deathDetails: deathDetails,
      events: rawEvents is List
          ? rawEvents
                .whereType<Map>()
                .map(
                  (event) => _CharacterHistoryEvent.fromJson(
                    event.map((key, value) => MapEntry(key.toString(), value)),
                  ),
                )
                .toList(growable: false)
          : const <_CharacterHistoryEvent>[],
    );
  }
}

class _CharacterHistoryEvent {
  final String id;
  final String title;
  final double ageOffset;
  final int? month;
  final int? day;
  final _HistoryEmotionWheel emotionWheel;
  final List<String> emotionIds;
  final List<int> presentCharacterIds;
  final String markdown;

  const _CharacterHistoryEvent({
    required this.id,
    required this.title,
    required this.ageOffset,
    this.month,
    this.day,
    required this.emotionWheel,
    required this.emotionIds,
    this.presentCharacterIds = const <int>[],
    required this.markdown,
  });

  String get emotionId => emotionIds.isEmpty
      ? _historyEmotionCatalog(emotionWheel).first.id
      : emotionIds.first;

  _CharacterHistoryEvent copyWith({
    String? id,
    String? title,
    double? ageOffset,
    int? month,
    bool clearMonth = false,
    int? day,
    bool clearDay = false,
    _HistoryEmotionWheel? emotionWheel,
    List<String>? emotionIds,
    List<int>? presentCharacterIds,
    String? markdown,
  }) {
    return _CharacterHistoryEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      ageOffset: ageOffset ?? this.ageOffset,
      month: clearMonth ? null : month ?? this.month,
      day: clearDay ? null : day ?? this.day,
      emotionWheel: emotionWheel ?? this.emotionWheel,
      emotionIds: emotionIds ?? this.emotionIds,
      presentCharacterIds: presentCharacterIds ?? this.presentCharacterIds,
      markdown: markdown ?? this.markdown,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'title': title,
      'ageOffset': ageOffset,
      'month': month,
      'day': day,
      'emotionWheel': emotionWheel.name,
      'emotionId': emotionId,
      'emotionIds': emotionIds,
      'presentCharacterIds': presentCharacterIds,
      'markdown': markdown,
    };
  }

  factory _CharacterHistoryEvent.fromJson(Map<String, Object?> json) {
    final emotionWheel = _historyEmotionWheelFromName(
      json['emotionWheel'] as String?,
    );
    final emotionIds = _readHistoryEmotionIds(
      json['emotionIds'],
      json['emotionId'] as String?,
      emotionWheel,
    );
    return _CharacterHistoryEvent(
      id: (json['id'] as String?)?.trim().isNotEmpty == true
          ? json['id'] as String
          : _newHistoryEventId(),
      title: json['title'] as String? ?? 'Evento sem titulo',
      ageOffset: _readHistoryDouble(json['ageOffset']) ?? 0,
      month: _readHistoryInt(json['month']),
      day: _readHistoryInt(json['day']),
      emotionWheel: emotionWheel,
      emotionIds: emotionIds,
      presentCharacterIds: _readHistoryIntList(json['presentCharacterIds']),
      markdown: json['markdown'] as String? ?? '',
    );
  }
}

class _HistoryEmotionDefinition {
  final String id;
  final String label;
  final String description;
  final Color color;
  final int? plutchikIndex;
  final int? plutchikIntensity;

  const _HistoryEmotionDefinition({
    required this.id,
    required this.label,
    required this.description,
    required this.color,
    this.plutchikIndex,
    this.plutchikIntensity,
  });
}

class _HistoryEventEditorResult {
  final _CharacterHistoryEvent? event;
  final bool delete;

  const _HistoryEventEditorResult.save(this.event) : delete = false;
  const _HistoryEventEditorResult.delete() : event = null, delete = true;
}

class _HistoryDeathEditorResult {
  final double? deathAge;
  final _HistoryMilestoneDetails? details;
  final bool clear;

  const _HistoryDeathEditorResult.apply(this.deathAge, this.details)
    : clear = false;
  const _HistoryDeathEditorResult.clear()
    : deathAge = null,
      details = null,
      clear = true;
}

class _HistoryMonthDay {
  final int month;
  final int day;

  const _HistoryMonthDay({required this.month, required this.day});
}

extension _CharacterNotebookHistoryState on _CharacterNotebookPageState {
  Widget _buildHistoryTab() {
    final query = _historySearchQuery.trim();
    final emotionFilterIds = Set<String>.from(_historyEmotionFilterIds);
    final isFiltering = query.isNotEmpty || emotionFilterIds.isNotEmpty;
    final events = _sortedHistoryEvents(
      _historyDraft.events
          .where((event) => _matchesHistorySearch(event, query))
          .where(
            (event) => _matchesHistoryEmotionFilter(event, emotionFilterIds),
          )
          .toList(growable: false),
    );
    final timelineItems = _buildHistoryTimelineItems(
      events,
      includeMilestones: !isFiltering,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HistoryOverviewCard(
            accentColor: _draft.accent,
            eventCount: events.length,
            deathAge: _historyDraft.deathAge,
            onAddEvent: () => _createHistoryEvent(),
            onEditDeathAge: _editDeathAge,
          ),
          const SizedBox(height: 10),
          _HistorySearchField(
            controller: _historySearchController,
            accentColor: _draft.accent,
            activeFilterCount: emotionFilterIds.length,
            onFilterTap: _openHistoryEmotionFilter,
            onChanged: (value) {
              _historySearchQuery = value;
              _rebuildNotebook();
            },
          ),
          const SizedBox(height: 12),
          if (events.isEmpty && isFiltering)
            _HistoryEmptySearchResult(accentColor: _draft.accent)
          else
            _HistoryTimeline(
              accentColor: _draft.accent,
              avatarColor: _draft.avatarColor,
              emotionWheel: _historyEmotionWheel,
              availableCharacters: widget.availableCharacters,
              collapsedYearKeys: _collapsedHistoryYears,
              items: timelineItems,
              onViewEvent: _openHistoryEventViewer,
              onEditEvent: _openHistoryEventEditor,
              onDeleteEvent: _deleteHistoryEvent,
              onAddEventAtYear: _createHistoryEvent,
              onViewMilestone: _openHistoryMilestoneViewer,
              onEditMilestone: _openHistoryMilestoneEditor,
              onToggleYear: _toggleHistoryYearCollapsed,
            ),
        ],
      ),
    );
  }

  void _setHistoryDraft(_CharacterHistoryDraft next) {
    _historyDraft = next;
    _updateDraft(
      _draft.copyWith(
        notebookComplexityValues: _storeCharacterHistory(
          _draft.notebookComplexityValues,
          next,
        ),
      ),
      rebuild: true,
    );
  }

  void _toggleHistoryYearCollapsed(String yearKey) {
    if (!_collapsedHistoryYears.remove(yearKey)) {
      _collapsedHistoryYears.add(yearKey);
    }
    _rebuildNotebook();
  }

  Future<void> _openHistoryEmotionFilter() async {
    final tempSelectedIds = Set<String>.from(_historyEmotionFilterIds);
    await showProjectDismissibleSheet<void>(
      context: context,
      title: 'Filtrar emocoes',
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void applySelection() {
              _historyEmotionFilterIds
                ..clear()
                ..addAll(tempSelectedIds);
              _rebuildNotebook();
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HistoryEmotionFilterField(
                  accentColor: _draft.accent,
                  selectedEmotionIds: tempSelectedIds,
                  onToggle: (id) {
                    setModalState(() {
                      if (!tempSelectedIds.remove(id)) {
                        tempSelectedIds.add(id);
                      }
                    });
                    applySelection();
                  },
                  onClear: () {
                    setModalState(tempSelectedIds.clear);
                    applySelection();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _createHistoryEvent([double? ageOffset]) async {
    final events = _sortedHistoryEvents(_historyDraft.events);
    final lastAge = events.isEmpty ? 0.0 : events.last.ageOffset;
    final draft = _CharacterHistoryEvent(
      id: _newHistoryEventId(),
      title: 'Novo evento',
      ageOffset: ageOffset ?? lastAge + 1,
      emotionWheel: _historyEmotionWheel,
      emotionIds: [_historyEmotionCatalog(_historyEmotionWheel).first.id],
      markdown: '',
    );

    await _openHistoryEventEditor(draft);
  }

  void _deleteHistoryEvent(_CharacterHistoryEvent event) {
    _setHistoryDraft(
      _historyDraft.copyWith(
        events: _historyDraft.events
            .where((stored) => stored.id != event.id)
            .toList(growable: false),
      ),
    );
  }

  Future<_HistoryMonthDay?> _selectHistoryMonthDay({
    int? initialMonth,
    int? initialDay,
  }) async {
    var tempMonth = initialMonth ?? _birthday.month;
    var tempDay = (initialDay ?? _birthday.day)
        .clamp(1, daysInMonth(tempMonth))
        .toInt();
    final monthController = FixedExtentScrollController(
      initialItem: tempMonth - 1,
    );
    final dayController = FixedExtentScrollController(initialItem: tempDay - 1);

    final selectedDate = await showProjectDismissibleSheet<_HistoryMonthDay>(
      context: context,
      title: 'Mes e dia',
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 188,
                  child: Row(
                    children: [
                      Expanded(
                        child: _BirthdayWheel(
                          label: 'Mes',
                          controller: monthController,
                          onSelectedItemChanged: (index) {
                            setModalState(() {
                              tempMonth = index + 1;
                              final maxDay = daysInMonth(tempMonth);
                              if (tempDay > maxDay) {
                                tempDay = maxDay;
                                dayController.jumpToItem(tempDay - 1);
                              }
                            });
                          },
                          children: [
                            for (
                              var index = 0;
                              index < monthLabels.length;
                              index += 1
                            )
                              Center(
                                child: Text(
                                  monthLabels[index],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: Color(0xFF2C262C),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _BirthdayWheel(
                          label: 'Dia',
                          controller: dayController,
                          onSelectedItemChanged: (index) {
                            tempDay = index + 1;
                          },
                          children: [
                            for (
                              var day = 1;
                              day <= daysInMonth(tempMonth);
                              day += 1
                            )
                              Center(
                                child: Text(
                                  day.toString().padLeft(2, '0'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: Color(0xFF2C262C),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    style: _historyTextButtonStyle(_draft.accent),
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pop(_HistoryMonthDay(month: tempMonth, day: tempDay));
                    },
                    child: const Text('Aplicar'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    Future<void>.delayed(const Duration(milliseconds: 300), () {
      monthController.dispose();
      dayController.dispose();
    });

    return selectedDate;
  }

  Future<void> _openHistoryEventEditor(_CharacterHistoryEvent event) async {
    final titleController = TextEditingController(text: event.title);
    final ageController = TextEditingController(
      text: _formatHistoryNumber(event.ageOffset),
    );
    _HistoryMonthDay? selectedDate = event.month == null || event.day == null
        ? null
        : _HistoryMonthDay(month: event.month!, day: event.day!);
    final markdownController = TextEditingController(text: event.markdown);
    final editorScrollController = ScrollController();
    final emotionWheel = _historyEmotionWheel;
    var emotionIds = _validHistoryEmotionIds(event.emotionIds, emotionWheel);
    var presentCharacterIds = event.presentCharacterIds.toList(growable: true);
    String? ageError;

    try {
      final result =
          await showProjectDismissibleSheet<_HistoryEventEditorResult>(
            context: context,
            title: 'Evento da linha do tempo',
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setModalState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: _HistorySheetCloseButton(
                          accentColor: _draft.accent,
                          tooltip: 'Fechar edicao de evento',
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: _HistoryTextInput(
                              controller: titleController,
                              label: 'Titulo',
                              hintText: 'O que aconteceu?',
                              accentColor: _draft.accent,
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 118,
                            child: _HistoryTextInput(
                              controller: ageController,
                              label: 'Ano *',
                              hintText: '0',
                              accentColor: _draft.accent,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              errorText: ageError,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _HistoryDateSelectorButton(
                        accentColor: _draft.accent,
                        label: 'Mes e dia',
                        value: selectedDate,
                        onTap: () async {
                          final picked = await _selectHistoryMonthDay(
                            initialMonth: selectedDate?.month,
                            initialDay: selectedDate?.day,
                          );
                          if (picked == null) return;
                          setModalState(() => selectedDate = picked);
                        },
                        onClear: selectedDate == null
                            ? null
                            : () => setModalState(() => selectedDate = null),
                      ),
                      if (widget.availableCharacters.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _HistoryCharacterPresencePicker(
                          accentColor: _draft.accent,
                          characters: widget.availableCharacters,
                          selectedIds: presentCharacterIds,
                          onToggle: (characterId) {
                            setModalState(() {
                              if (!presentCharacterIds.remove(characterId)) {
                                presentCharacterIds = [
                                  ...presentCharacterIds,
                                  characterId,
                                ];
                              }
                            });
                          },
                        ),
                      ],
                      const SizedBox(height: 12),
                      _HistoryEmotionPicker(
                        accentColor: _draft.accent,
                        selectedEmotionIds: emotionIds,
                        onToggle: (id) {
                          setModalState(() {
                            if (!emotionIds.remove(id)) {
                              emotionIds = [...emotionIds, id];
                            }
                            if (emotionIds.isEmpty) {
                              emotionIds = [
                                _historyEmotionCatalog(emotionWheel).first.id,
                              ];
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 260,
                        child: _HistoryMarkdownEditor(
                          controller: markdownController,
                          scrollController: editorScrollController,
                          accentColor: _draft.accent,
                          onChanged: () {},
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (_historyDraft.events.any(
                            (stored) => stored.id == event.id,
                          )) ...[
                            IconButton.filledTonal(
                              style: _historyIconButtonStyle(_draft.accent),
                              tooltip: 'Excluir evento',
                              onPressed: () => Navigator.of(
                                context,
                              ).pop(const _HistoryEventEditorResult.delete()),
                              icon: const Icon(Icons.delete_outline_rounded),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: OutlinedButton(
                              style: _historyOutlinedButtonStyle(_draft.accent),
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton.icon(
                              style: _historyFilledButtonStyle(_draft.accent),
                              onPressed: () {
                                final parsedAge = _parseHistoryNumber(
                                  ageController.text,
                                );
                                if (parsedAge == null ||
                                    parsedAge < 0 ||
                                    parsedAge != parsedAge.roundToDouble()) {
                                  setModalState(() {
                                    ageError = 'Obrigatorio';
                                  });
                                  return;
                                }
                                Navigator.of(context).pop(
                                  _HistoryEventEditorResult.save(
                                    event.copyWith(
                                      title: titleController.text.trim().isEmpty
                                          ? 'Evento sem titulo'
                                          : titleController.text.trim(),
                                      ageOffset: parsedAge,
                                      month: selectedDate?.month,
                                      clearMonth: selectedDate == null,
                                      day: selectedDate?.day,
                                      clearDay: selectedDate == null,
                                      emotionWheel: emotionWheel,
                                      emotionIds: emotionIds,
                                      presentCharacterIds: presentCharacterIds,
                                      markdown: markdownController.text,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.check_rounded, size: 18),
                              label: const Text('Salvar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          );

      if (!mounted || result == null) return;

      if (result.delete) {
        _setHistoryDraft(
          _historyDraft.copyWith(
            events: _historyDraft.events
                .where((stored) => stored.id != event.id)
                .toList(growable: false),
          ),
        );
        return;
      }

      final saved = result.event;
      if (saved == null) return;

      final nextEvents = <_CharacterHistoryEvent>[
        for (final stored in _historyDraft.events)
          if (stored.id != saved.id) stored,
        saved,
      ];
      _setHistoryDraft(_historyDraft.copyWith(events: nextEvents));
    } finally {
      titleController.dispose();
      ageController.dispose();
      markdownController.dispose();
      editorScrollController.dispose();
    }
  }

  Future<void> _openHistoryEventViewer(_CharacterHistoryEvent event) async {
    final scrollController = ScrollController();
    final emotions = _resolveHistoryEmotions(
      _historyEmotionWheel,
      event.emotionIds,
    );
    var shouldOpenEditor = false;
    final relativeEvents = _sortedHistoryEvents(
      _historyDraft.events
          .where((item) => item.id != event.id)
          .toList(growable: false),
    );
    String? relativeEventId;

    try {
      await showProjectDismissibleSheet<void>(
        context: context,
        title: event.title,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              final relativeEvent = _historyEventById(
                relativeEvents,
                relativeEventId,
              );
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _HistoryMetricChip(
                        icon: Icons.calendar_month_rounded,
                        label: _historyDateLabel(
                          _HistoryTimelineItem.event(event),
                        ),
                        color: _draft.accent,
                      ),
                      for (final emotion in emotions)
                        _HistoryEmotionPill(emotion: emotion),
                    ],
                  ),
                  if (event.presentCharacterIds.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _HistoryPresentCharactersLine(
                      characterIds: event.presentCharacterIds,
                      characters: widget.availableCharacters,
                    ),
                  ],
                  const SizedBox(height: 12),
                  _HistoryRelativeMemoryPicker(
                    accentColor: _draft.accent,
                    events: relativeEvents,
                    selectedEventId: relativeEventId,
                    onChanged: (value) {
                      setModalState(() {
                        relativeEventId = value;
                      });
                    },
                  ),
                  if (relativeEvent != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _HistoryRelativeComparisonResult(
                        accentColor: _draft.accent,
                        currentEvent: event,
                        relativeEvent: relativeEvent,
                      ),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 360,
                    child: _HistoryMarkdownPreview(
                      text: event.markdown,
                      scrollController: scrollController,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton.filledTonal(
                        style: _historyIconButtonStyle(_draft.accent),
                        tooltip: 'Excluir evento',
                        onPressed: () {
                          _deleteHistoryEvent(event);
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          style: _historyFilledButtonStyle(_draft.accent),
                          onPressed: () {
                            shouldOpenEditor = true;
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.edit_rounded, size: 18),
                          label: const Text('Editar evento'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      );
      if (mounted && shouldOpenEditor) {
        await Future<void>.delayed(Duration.zero);
        if (mounted) {
          await _openHistoryEventEditor(event);
        }
      }
    } finally {
      scrollController.dispose();
    }
  }

  Future<void> _openHistoryMilestoneViewer(_HistoryTimelineItem item) async {
    if (item.type == _HistoryTimelineItemType.event) return;
    final scrollController = ScrollController();
    var shouldOpenEditor = false;

    try {
      await showProjectDismissibleSheet<void>(
        context: context,
        title: item.title,
        builder: (context) {
          final emotion = _resolveHistoryEmotion(
            _historyEmotionWheel,
            item.emotionId,
          );
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _HistoryMetricChip(
                    icon: Icons.calendar_month_rounded,
                    label: _historyDateLabel(item),
                    color: _draft.accent,
                  ),
                  _HistoryEmotionPill(emotion: emotion),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 360,
                child: _HistoryMarkdownPreview(
                  text: item.markdown,
                  scrollController: scrollController,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                style: _historyFilledButtonStyle(_draft.accent),
                onPressed: () {
                  shouldOpenEditor = true;
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: Text(
                  item.type == _HistoryTimelineItemType.birth
                      ? 'Editar nascimento'
                      : 'Editar morte',
                ),
              ),
            ],
          );
        },
      );
      if (mounted && shouldOpenEditor) {
        await Future<void>.delayed(Duration.zero);
        if (mounted) {
          await _openHistoryMilestoneEditor(item);
        }
      }
    } finally {
      scrollController.dispose();
    }
  }

  Future<void> _openHistoryMilestoneEditor(_HistoryTimelineItem item) async {
    switch (item.type) {
      case _HistoryTimelineItemType.birth:
        await _editBirthEventDetails();
        break;
      case _HistoryTimelineItemType.death:
        await _editDeathAge();
        break;
      case _HistoryTimelineItemType.event:
        break;
    }
  }

  Future<void> _editBirthEventDetails() async {
    final markdownController = TextEditingController(
      text: _historyDraft.birthDetails.markdown,
    );
    final editorScrollController = ScrollController();
    final emotionWheel = _historyEmotionWheel;
    var emotionIds = _validHistoryEmotionIds(
      _historyDraft.birthDetails.resolvedEmotionIds,
      emotionWheel,
    );

    try {
      final details =
          await showProjectDismissibleSheet<_HistoryMilestoneDetails>(
            context: context,
            title: 'Nascimento',
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setModalState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HistoryFixedDatePanel(
                        accentColor: _draft.accent,
                        label: 'Data do nascimento',
                        value: formatBirthdayLabel(
                          _birthday.day,
                          _birthday.month,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _HistoryEmotionPicker(
                        accentColor: _draft.accent,
                        selectedEmotionIds: emotionIds,
                        onToggle: (id) {
                          setModalState(() {
                            if (!emotionIds.remove(id)) {
                              emotionIds = [...emotionIds, id];
                            }
                            if (emotionIds.isEmpty) {
                              emotionIds = [
                                _historyEmotionCatalog(emotionWheel).first.id,
                              ];
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 260,
                        child: _HistoryMarkdownEditor(
                          controller: markdownController,
                          scrollController: editorScrollController,
                          accentColor: _draft.accent,
                          onChanged: () {},
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        style: _historyFilledButtonStyle(_draft.accent),
                        onPressed: () {
                          Navigator.of(context).pop(
                            _HistoryMilestoneDetails(
                              emotionId: emotionIds.first,
                              emotionIds: emotionIds,
                              markdown: markdownController.text,
                            ),
                          );
                        },
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text('Salvar'),
                      ),
                    ],
                  );
                },
              );
            },
          );

      if (!mounted || details == null) return;
      _setHistoryDraft(_historyDraft.copyWith(birthDetails: details));
    } finally {
      markdownController.dispose();
      editorScrollController.dispose();
    }
  }

  Future<void> _editDeathAge() async {
    final deathController = TextEditingController(
      text: _historyDraft.deathAge == null
          ? ''
          : _formatHistoryNumber(_historyDraft.deathAge!),
    );
    final markdownController = TextEditingController(
      text: _historyDraft.deathDetails.markdown,
    );
    final editorScrollController = ScrollController();
    final emotionWheel = _historyEmotionWheel;
    var selectedDate =
        _historyDraft.deathDetails.month == null ||
            _historyDraft.deathDetails.day == null
        ? null
        : _HistoryMonthDay(
            month: _historyDraft.deathDetails.month!,
            day: _historyDraft.deathDetails.day!,
          );
    var emotionIds = _validHistoryEmotionIds(
      _historyDraft.deathDetails.resolvedEmotionIds,
      emotionWheel,
    );
    String? errorText;
    final lastEventAge = _historyDraft.events.isEmpty
        ? 0.0
        : _historyDraft.events.map((event) => event.ageOffset).reduce(max);

    try {
      final selected = await showProjectDismissibleSheet<_HistoryDeathEditorResult>(
        context: context,
        title: 'Morte',
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HistoryTextInput(
                    controller: deathController,
                    label: 'Ano da morte *',
                    hintText: 'Ex.: 84',
                    accentColor: _draft.accent,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    errorText: errorText,
                  ),
                  const SizedBox(height: 12),
                  _HistoryDateSelectorButton(
                    accentColor: _draft.accent,
                    label: 'Mes e dia',
                    value: selectedDate,
                    onTap: () async {
                      final picked = await _selectHistoryMonthDay(
                        initialMonth: selectedDate?.month,
                        initialDay: selectedDate?.day,
                      );
                      if (picked == null) return;
                      setModalState(() => selectedDate = picked);
                    },
                    onClear: selectedDate == null
                        ? null
                        : () => setModalState(() => selectedDate = null),
                  ),
                  const SizedBox(height: 12),
                  _HistoryEmotionPicker(
                    accentColor: _draft.accent,
                    selectedEmotionIds: emotionIds,
                    onToggle: (id) {
                      setModalState(() {
                        if (!emotionIds.remove(id)) {
                          emotionIds = [...emotionIds, id];
                        }
                        if (emotionIds.isEmpty) {
                          emotionIds = [
                            _historyEmotionCatalog(emotionWheel).first.id,
                          ];
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 260,
                    child: _HistoryMarkdownEditor(
                      controller: markdownController,
                      scrollController: editorScrollController,
                      accentColor: _draft.accent,
                      onChanged: () {},
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: _historyOutlinedButtonStyle(_draft.accent),
                          onPressed: () => Navigator.of(
                            context,
                          ).pop(const _HistoryDeathEditorResult.clear()),
                          child: const Text('Remover'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          style: _historyFilledButtonStyle(_draft.accent),
                          onPressed: () {
                            final parsed = _parseHistoryNumber(
                              deathController.text.trim(),
                            );
                            if (parsed == null || parsed <= 0) {
                              setModalState(() => errorText = 'Invalido');
                              return;
                            }
                            if (parsed < lastEventAge) {
                              setModalState(
                                () => errorText =
                                    'Deve ser no ano ${_formatHistoryNumber(lastEventAge)} ou depois',
                              );
                              return;
                            }
                            Navigator.of(context).pop(
                              _HistoryDeathEditorResult.apply(
                                parsed,
                                _HistoryMilestoneDetails(
                                  emotionId: emotionIds.first,
                                  emotionIds: emotionIds,
                                  markdown: markdownController.text,
                                  month: selectedDate?.month,
                                  day: selectedDate?.day,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.check_rounded, size: 18),
                          label: const Text('Aplicar'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      );

      if (!mounted || selected == null) return;
      _setHistoryDraft(
        selected.clear
            ? _historyDraft.copyWith(clearDeathAge: true)
            : _historyDraft.copyWith(
                deathAge: selected.deathAge,
                deathDetails: selected.details ?? _historyDraft.deathDetails,
              ),
      );
    } finally {
      deathController.dispose();
      markdownController.dispose();
      editorScrollController.dispose();
    }
  }

  List<_HistoryTimelineItem> _buildHistoryTimelineItems(
    List<_CharacterHistoryEvent> events, {
    bool includeMilestones = true,
  }) {
    final items = <_HistoryTimelineItem>[
      if (includeMilestones)
        _HistoryTimelineItem.birth(_birthday, _historyDraft.birthDetails),
      for (final event in events) _HistoryTimelineItem.event(event),
      if (includeMilestones && _historyDraft.deathAge != null)
        _HistoryTimelineItem.death(
          _historyDraft.deathAge!,
          _historyDraft.deathDetails,
        ),
    ];

    items.sort(_compareTimelineItems);
    return items;
  }
}

class _HistoryOverviewCard extends StatelessWidget {
  final Color accentColor;
  final int eventCount;
  final double? deathAge;
  final VoidCallback onAddEvent;
  final VoidCallback onEditDeathAge;

  const _HistoryOverviewCard({
    required this.accentColor,
    required this.eventCount,
    required this.deathAge,
    required this.onAddEvent,
    required this.onEditDeathAge,
  });

  @override
  Widget build(BuildContext context) {
    final deathColor = deathAge == null ? const Color(0xFF8B8790) : accentColor;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.88)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.timeline_rounded,
                  size: 16,
                  color: _darkenCharacterDialogColor(accentColor, 0.18),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Linha do tempo',
                  style: TextStyle(
                    color: Color(0xFF2C262C),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _HistoryCompactChip(
                label: '$eventCount',
                icon: Icons.auto_stories_rounded,
                color: accentColor,
              ),
              const SizedBox(width: 6),
              _HistoryCompactChip(
                label: deathAge == null
                    ? '--'
                    : _formatHistoryNumber(deathAge!),
                iconWidget: _HistorySkullIcon(size: 13, color: deathColor),
                color: deathColor,
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                style: _historyIconButtonStyle(accentColor),
                tooltip: 'Adicionar evento',
                onPressed: onAddEvent,
                icon: const Icon(Icons.add_rounded, size: 18),
              ),
              const SizedBox(width: 6),
              IconButton.filledTonal(
                style: _historyIconButtonStyle(accentColor),
                tooltip: 'Definir morte',
                onPressed: onEditDeathAge,
                icon: const _HistorySkullIcon(size: 17),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryCompactChip extends StatelessWidget {
  final IconData? icon;
  final Widget? iconWidget;
  final String label;
  final Color color;

  const _HistoryCompactChip({
    this.icon,
    this.iconWidget,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget ?? Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF3A3339),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryMetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _HistoryMetricChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _darkenCharacterDialogColor(color, 0.18)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF3A3339),
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistorySearchField extends StatelessWidget {
  final TextEditingController controller;
  final Color accentColor;
  final int activeFilterCount;
  final VoidCallback onFilterTap;
  final ValueChanged<String> onChanged;

  const _HistorySearchField({
    required this.controller,
    required this.accentColor,
    required this.activeFilterCount,
    required this.onFilterTap,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Pesquisar eventos',
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 18,
            color: _darkenCharacterDialogColor(accentColor, 0.14),
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (controller.text.isNotEmpty)
                IconButton(
                  tooltip: 'Limpar busca',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close_rounded, size: 17),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _HistoryFilterButton(
                  accentColor: accentColor,
                  activeCount: activeFilterCount,
                  onTap: onFilterTap,
                ),
              ),
            ],
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 42,
            minHeight: 36,
          ),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.68),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: accentColor.withValues(alpha: 0.12)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: accentColor.withValues(alpha: 0.12)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: accentColor, width: 1.1),
          ),
        ),
      ),
    );
  }
}

class _HistoryFilterButton extends StatelessWidget {
  final Color accentColor;
  final int activeCount;
  final VoidCallback onTap;

  const _HistoryFilterButton({
    required this.accentColor,
    required this.activeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _darkenCharacterDialogColor(accentColor, 0.16);
    return Tooltip(
      message: 'Filtrar por emocao',
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 30,
          height: 30,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: activeCount > 0
                        ? accentColor.withValues(alpha: 0.16)
                        : Colors.white.withValues(alpha: 0.42),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: activeCount > 0
                          ? accentColor.withValues(alpha: 0.28)
                          : accentColor.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Icon(Icons.filter_alt_rounded, size: 16, color: color),
                ),
              ),
              if (activeCount > 0)
                Positioned(
                  right: -2,
                  top: -4,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      activeCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryEmotionFilterField extends StatelessWidget {
  final Color accentColor;
  final Set<String> selectedEmotionIds;
  final ValueChanged<String> onToggle;
  final VoidCallback onClear;

  const _HistoryEmotionFilterField({
    required this.accentColor,
    required this.selectedEmotionIds,
    required this.onToggle,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HistoryEmotionSearchSuggestions(
            accentColor: accentColor,
            selectedEmotionIds: selectedEmotionIds,
            onToggle: onToggle,
            compact: true,
            hintText:
                'Experimente pesquisar pelas emocoes primarias (alegria, antecipacao, confianca, medo, surpresa, tristeza, aversao, raiva)',
          ),
          if (selectedEmotionIds.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                style: _historyTextButtonStyle(accentColor),
                onPressed: onClear,
                child: const Text('Limpar'),
              ),
            ),
          if (selectedEmotionIds.isNotEmpty) ...[
            const SizedBox(height: 6),
            _HistoryEmotionPillWrap(
              emotions: _resolveHistoryEmotions(
                _historyEmotionWheel,
                selectedEmotionIds.toList(growable: false),
              ),
              compact: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _HistoryEmptySearchResult extends StatelessWidget {
  final Color accentColor;

  const _HistoryEmptySearchResult({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withValues(alpha: 0.12)),
      ),
      child: const Text(
        'Nenhum evento encontrado.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF645B64),
          fontSize: 12,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

class _HistoryTimeline extends StatelessWidget {
  final Color accentColor;
  final Color avatarColor;
  final _HistoryEmotionWheel emotionWheel;
  final List<CharacterListItem> availableCharacters;
  final Set<String> collapsedYearKeys;
  final List<_HistoryTimelineItem> items;
  final ValueChanged<_CharacterHistoryEvent> onViewEvent;
  final ValueChanged<_CharacterHistoryEvent> onEditEvent;
  final ValueChanged<_CharacterHistoryEvent> onDeleteEvent;
  final ValueChanged<double> onAddEventAtYear;
  final ValueChanged<_HistoryTimelineItem> onViewMilestone;
  final ValueChanged<_HistoryTimelineItem> onEditMilestone;
  final ValueChanged<String> onToggleYear;

  const _HistoryTimeline({
    required this.accentColor,
    required this.avatarColor,
    required this.emotionWheel,
    required this.availableCharacters,
    required this.collapsedYearKeys,
    required this.items,
    required this.onViewEvent,
    required this.onEditEvent,
    required this.onDeleteEvent,
    required this.onAddEventAtYear,
    required this.onViewMilestone,
    required this.onEditMilestone,
    required this.onToggleYear,
  });

  @override
  Widget build(BuildContext context) {
    final groups = _groupTimelineItems(items);

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
      decoration: BoxDecoration(
        color: _historyTimelineBackgroundColor.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < groups.length; index += 1) ...[
            if (index > 0)
              _HistoryTimelineIntervalArrow(
                accentColor: accentColor,
                previous: groups[index - 1].items.last,
                next: groups[index].items.first,
              ),
            _HistoryTimelineGroupRow(
              accentColor: accentColor,
              avatarColor: avatarColor,
              group: groups[index],
              isFirst: index == 0,
              isLast: index == groups.length - 1,
              emotionWheel: emotionWheel,
              availableCharacters: availableCharacters,
              collapsed: collapsedYearKeys.contains(groups[index].yearKey),
              onViewEvent: onViewEvent,
              onEditEvent: onEditEvent,
              onDeleteEvent: onDeleteEvent,
              onAddEventAtYear: onAddEventAtYear,
              onViewMilestone: onViewMilestone,
              onEditMilestone: onEditMilestone,
              onToggle: () => onToggleYear(groups[index].yearKey),
            ),
          ],
        ],
      ),
    );
  }
}

class _HistoryTimelineGroupRow extends StatelessWidget {
  final Color accentColor;
  final Color avatarColor;
  final _HistoryTimelineGroup group;
  final bool isFirst;
  final bool isLast;
  final _HistoryEmotionWheel emotionWheel;
  final List<CharacterListItem> availableCharacters;
  final bool collapsed;
  final ValueChanged<_CharacterHistoryEvent> onViewEvent;
  final ValueChanged<_CharacterHistoryEvent> onEditEvent;
  final ValueChanged<_CharacterHistoryEvent> onDeleteEvent;
  final ValueChanged<double> onAddEventAtYear;
  final ValueChanged<_HistoryTimelineItem> onViewMilestone;
  final ValueChanged<_HistoryTimelineItem> onEditMilestone;
  final VoidCallback onToggle;

  const _HistoryTimelineGroupRow({
    required this.accentColor,
    required this.avatarColor,
    required this.group,
    required this.isFirst,
    required this.isLast,
    required this.emotionWheel,
    required this.availableCharacters,
    required this.collapsed,
    required this.onViewEvent,
    required this.onEditEvent,
    required this.onDeleteEvent,
    required this.onAddEventAtYear,
    required this.onViewMilestone,
    required this.onEditMilestone,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final timelineColor = _darkenCharacterDialogColor(accentColor, 0.3);
    final railHeight = collapsed
        ? _collapsedTimelineGroupRailHeight
        : _timelineGroupRailHeight(group.items.length);
    final nodeSize = collapsed
        ? _collapsedTimelineGroupNodeSize
        : _timelineGroupRailNodeSize(group.items.length);
    final railTopHeight = (railHeight - nodeSize) / 2;
    final railBottomHeight = railTopHeight;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : (collapsed ? 6 : 18)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            height: railHeight,
            child: Column(
              children: [
                SizedBox(
                  height: railTopHeight,
                  child: Center(
                    child: _TimelineLineSegment(
                      color: timelineColor.withValues(alpha: 0.34),
                      visible: !isFirst,
                    ),
                  ),
                ),
                Container(
                  width: nodeSize,
                  height: nodeSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: timelineColor.withValues(alpha: 0.14),
                    border: Border.all(color: Colors.white, width: 1.4),
                    boxShadow: [
                      BoxShadow(
                        color: timelineColor.withValues(alpha: 0.16),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _HistoryTimelineGlyph(
                      type: group.iconType,
                      size: collapsed ? 16 : 18,
                      color: timelineColor,
                    ),
                  ),
                ),
                SizedBox(
                  height: railBottomHeight,
                  child: Center(
                    child: _TimelineLineSegment(
                      color: timelineColor.withValues(alpha: 0.34),
                      visible: !isLast,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 26,
                      height: 3,
                      decoration: BoxDecoration(
                        color: timelineColor.withValues(alpha: 0.34),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: onToggle,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Text(
                                group.ageLabel,
                                style: TextStyle(
                                  color: timelineColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 7),
                              _HistoryYearCountBadge(
                                count: group.eventCount,
                                color: timelineColor,
                              ),
                              const Spacer(),
                              _HistoryIconAction(
                                icon: Icons.add_rounded,
                                tooltip: 'Novo evento neste ano',
                                color: timelineColor,
                                onTap: () => onAddEventAtYear(group.ageOffset),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                collapsed
                                    ? Icons.keyboard_arrow_down_rounded
                                    : Icons.keyboard_arrow_up_rounded,
                                size: 18,
                                color: timelineColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (!collapsed) ...[
                  const SizedBox(height: 8),
                  _ParallelTimelineItems(
                    accentColor: accentColor,
                    avatarColor: avatarColor,
                    emotionWheel: emotionWheel,
                    availableCharacters: availableCharacters,
                    items: group.items,
                    onViewEvent: onViewEvent,
                    onEditEvent: onEditEvent,
                    onDeleteEvent: onDeleteEvent,
                    onViewMilestone: onViewMilestone,
                    onEditMilestone: onEditMilestone,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineLineSegment extends StatelessWidget {
  final Color color;
  final bool visible;

  const _TimelineLineSegment({required this.color, required this.visible});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: visible ? 1 : 0,
      child: SizedBox.expand(
        child: Center(
          child: Container(
            width: 3,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryYearCountBadge extends StatelessWidget {
  final int count;
  final Color color;

  const _HistoryYearCountBadge({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        count == 1 ? '1 evento' : '$count eventos',
        style: TextStyle(
          color: _darkenCharacterDialogColor(color, 0.16),
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _HistoryTimelineIntervalArrow extends StatelessWidget {
  final Color accentColor;
  final _HistoryTimelineItem previous;
  final _HistoryTimelineItem next;
  final bool compact;

  const _HistoryTimelineIntervalArrow({
    required this.accentColor,
    required this.previous,
    required this.next,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _darkenCharacterDialogColor(accentColor, 0.18);
    final text = _historyIntervalLabel(previous, next);
    return Padding(
      padding: EdgeInsets.fromLTRB(compact ? 34 : 64, 4, 0, compact ? 8 : 10),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: accentColor.withValues(alpha: 0.16)),
            ),
            child: Icon(Icons.arrow_downward_rounded, size: 14, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.56),
                fontSize: compact ? 10.8 : 11.5,
                height: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParallelTimelineItems extends StatelessWidget {
  final Color accentColor;
  final Color avatarColor;
  final _HistoryEmotionWheel emotionWheel;
  final List<CharacterListItem> availableCharacters;
  final List<_HistoryTimelineItem> items;
  final ValueChanged<_CharacterHistoryEvent> onViewEvent;
  final ValueChanged<_CharacterHistoryEvent> onEditEvent;
  final ValueChanged<_CharacterHistoryEvent> onDeleteEvent;
  final ValueChanged<_HistoryTimelineItem> onViewMilestone;
  final ValueChanged<_HistoryTimelineItem> onEditMilestone;

  const _ParallelTimelineItems({
    required this.accentColor,
    required this.avatarColor,
    required this.emotionWheel,
    required this.availableCharacters,
    required this.items,
    required this.onViewEvent,
    required this.onEditEvent,
    required this.onDeleteEvent,
    required this.onViewMilestone,
    required this.onEditMilestone,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var index = 0; index < items.length; index += 1) ...[
              if (index > 0)
                _HistoryTimelineIntervalArrow(
                  accentColor: accentColor,
                  previous: items[index - 1],
                  next: items[index],
                  compact: true,
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 17),
                    child: _ParallelTimelineNode(
                      color: _timelineItemColor(
                        items[index],
                        avatarColor,
                        emotionWheel,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _HistoryTimelineCard(
                      accentColor: accentColor,
                      item: items[index],
                      color: _timelineItemColor(
                        items[index],
                        avatarColor,
                        emotionWheel,
                      ),
                      emotionWheel: emotionWheel,
                      availableCharacters: availableCharacters,
                      onViewEvent: onViewEvent,
                      onEditEvent: onEditEvent,
                      onDeleteEvent: onDeleteEvent,
                      onViewMilestone: onViewMilestone,
                      onEditMilestone: onEditMilestone,
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ParallelTimelineNode extends StatelessWidget {
  final Color color;

  const _ParallelTimelineNode({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.32),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.4),
            ),
          ),
          const SizedBox(width: 7),
        ],
      ),
    );
  }
}

class _HistoryTimelineCard extends StatelessWidget {
  final Color accentColor;
  final _HistoryTimelineItem item;
  final Color color;
  final _HistoryEmotionWheel emotionWheel;
  final List<CharacterListItem> availableCharacters;
  final ValueChanged<_CharacterHistoryEvent> onViewEvent;
  final ValueChanged<_CharacterHistoryEvent> onEditEvent;
  final ValueChanged<_CharacterHistoryEvent> onDeleteEvent;
  final ValueChanged<_HistoryTimelineItem> onViewMilestone;
  final ValueChanged<_HistoryTimelineItem> onEditMilestone;

  const _HistoryTimelineCard({
    required this.accentColor,
    required this.item,
    required this.color,
    required this.emotionWheel,
    required this.availableCharacters,
    required this.onViewEvent,
    required this.onEditEvent,
    required this.onDeleteEvent,
    required this.onViewMilestone,
    required this.onEditMilestone,
  });

  @override
  Widget build(BuildContext context) {
    final event = item.event;
    final emotions = _resolveHistoryEmotions(emotionWheel, item.emotionIds);
    final monthDay = _historyMonthDayLabel(item);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: event == null
            ? () => onViewMilestone(item)
            : () => onViewEvent(event),
        child: Ink(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.76),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Icon(Icons.circle, size: 7, color: color),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF2C262C),
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (item.markdown.trim().isNotEmpty) ...[
                          const SizedBox(height: 6),
                          _HistoryMarkdownCollapsed(text: item.markdown),
                        ],
                        const SizedBox(height: 7),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            if (monthDay.isNotEmpty)
                              _HistorySmallLabelChip(
                                label: monthDay,
                                color: color,
                              ),
                            for (final emotion in emotions)
                              _HistoryEmotionPill(
                                emotion: emotion,
                                compact: true,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (event != null) ...[
                    _HistoryIconAction(
                      icon: Icons.edit_outlined,
                      tooltip: 'Editar evento',
                      color: color,
                      onTap: () => onEditEvent(event),
                    ),
                    const SizedBox(width: 6),
                    _HistoryIconAction(
                      icon: Icons.delete_outline_rounded,
                      tooltip: 'Excluir evento',
                      color: color,
                      onTap: () => onDeleteEvent(event),
                    ),
                  ] else ...[
                    _HistoryIconAction(
                      icon: Icons.edit_outlined,
                      tooltip: item.type == _HistoryTimelineItemType.birth
                          ? 'Editar nascimento'
                          : 'Editar morte',
                      color: color,
                      onTap: () => onEditMilestone(item),
                    ),
                  ],
                ],
              ),
              if (event != null && event.presentCharacterIds.isNotEmpty) ...[
                const SizedBox(height: 8),
                _HistoryPresentCharactersLine(
                  characterIds: event.presentCharacterIds,
                  characters: availableCharacters,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryIconAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  const _HistoryIconAction({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 15, color: color),
        ),
      ),
    );
  }
}

class _HistorySheetCloseButton extends StatelessWidget {
  final Color accentColor;
  final String tooltip;
  final VoidCallback onTap;

  const _HistorySheetCloseButton({
    required this.accentColor,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _darkenCharacterDialogColor(accentColor, 0.2);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: accentColor.withValues(alpha: 0.16)),
          ),
          child: Icon(Icons.close_rounded, size: 18, color: color),
        ),
      ),
    );
  }
}

class _HistoryTimelineGlyph extends StatelessWidget {
  final _HistoryTimelineItemType type;
  final double size;
  final Color color;

  const _HistoryTimelineGlyph({
    required this.type,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      _HistoryTimelineItemType.birth => Icon(
        Icons.cake_outlined,
        size: size,
        color: color,
      ),
      _HistoryTimelineItemType.death => _HistorySkullIcon(
        size: size,
        color: color,
      ),
      _HistoryTimelineItemType.event => Icon(
        Icons.menu_book_rounded,
        size: size,
        color: color,
      ),
    };
  }
}

class _HistorySkullIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const _HistorySkullIcon({required this.size, this.color});

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? IconTheme.of(context).color ?? Colors.black;
    final holeColor = Theme.of(context).colorScheme.surface;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: size * 0.05,
            left: size * 0.12,
            right: size * 0.12,
            height: size * 0.64,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: resolvedColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(size * 0.32),
                  topRight: Radius.circular(size * 0.32),
                  bottomLeft: Radius.circular(size * 0.16),
                  bottomRight: Radius.circular(size * 0.16),
                ),
              ),
            ),
          ),
          Positioned(
            top: size * 0.56,
            left: size * 0.28,
            right: size * 0.28,
            height: size * 0.34,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: resolvedColor,
                borderRadius: BorderRadius.circular(size * 0.08),
              ),
            ),
          ),
          Positioned(
            top: size * 0.31,
            left: size * 0.25,
            width: size * 0.19,
            height: size * 0.19,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: holeColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: size * 0.31,
            right: size * 0.25,
            width: size * 0.19,
            height: size * 0.19,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: holeColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: size * 0.51,
            width: size * 0.12,
            height: size * 0.16,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: holeColor,
                borderRadius: BorderRadius.circular(size * 0.04),
              ),
            ),
          ),
          for (final left in <double>[0.36, 0.48, 0.60])
            Positioned(
              bottom: size * 0.13,
              left: size * left,
              width: size * 0.04,
              height: size * 0.16,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: holeColor,
                  borderRadius: BorderRadius.circular(size * 0.02),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HistoryEmotionPill extends StatelessWidget {
  final _HistoryEmotionDefinition emotion;
  final bool compact;

  const _HistoryEmotionPill({required this.emotion, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: emotion.color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: emotion.color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: emotion.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            emotion.label,
            style: TextStyle(
              color: const Color(0xFF3A3339),
              fontSize: compact ? 10.5 : 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryEmotionPillWrap extends StatelessWidget {
  final List<_HistoryEmotionDefinition> emotions;
  final bool compact;

  const _HistoryEmotionPillWrap({required this.emotions, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final emotion in emotions)
          _HistoryEmotionPill(emotion: emotion, compact: compact),
      ],
    );
  }
}

class _HistorySmallLabelChip extends StatelessWidget {
  final String label;
  final Color color;

  const _HistorySmallLabelChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _darkenCharacterDialogColor(color, 0.16),
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _HistoryMarkdownCollapsed extends StatelessWidget {
  final String text;

  const _HistoryMarkdownCollapsed({required this.text});

  @override
  Widget build(BuildContext context) {
    final plain = sanitizeCharacterMarkdown(text).trim();
    final resolved = plain.isEmpty ? 'Sem texto registrado.' : plain;
    return Text(
      resolved,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Colors.black.withValues(alpha: plain.isEmpty ? 0.38 : 0.62),
        fontSize: 11.5,
        height: 1.35,
        fontStyle: plain.isEmpty ? FontStyle.italic : FontStyle.normal,
      ),
    );
  }
}

class _HistoryPresentCharactersLine extends StatelessWidget {
  final List<int> characterIds;
  final List<CharacterListItem> characters;

  const _HistoryPresentCharactersLine({
    required this.characterIds,
    required this.characters,
  });

  @override
  Widget build(BuildContext context) {
    final names = [
      for (final id in characterIds)
        for (final character in characters)
          if (character.id == id)
            character.data.name.trim().isEmpty
                ? 'Sem nome'
                : character.data.name.trim(),
    ];
    if (names.isEmpty) return const SizedBox.shrink();

    return Text(
      'Presentes: ${names.join(', ')}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Colors.black.withValues(alpha: 0.5),
        fontSize: 11,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

class _HistoryRelativeMemoryPicker extends StatelessWidget {
  final Color accentColor;
  final List<_CharacterHistoryEvent> events;
  final String? selectedEventId;
  final ValueChanged<String?> onChanged;

  const _HistoryRelativeMemoryPicker({
    required this.accentColor,
    required this.events,
    required this.selectedEventId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selectedValue =
        selectedEventId != null &&
            events.any((event) => event.id == selectedEventId)
        ? selectedEventId
        : null;

    if (events.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _historyTimelineBackgroundColor.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withValues(alpha: 0.12)),
        ),
        child: Text(
          'Crie outro evento para comparar datas na linha do tempo.',
          style: TextStyle(
            color: Colors.black.withValues(alpha: 0.56),
            fontSize: 12,
            fontStyle: FontStyle.italic,
            height: 1.25,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _historyTimelineBackgroundColor.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.compare_arrows_rounded,
                  size: 17,
                  color: _darkenCharacterDialogColor(accentColor, 0.16),
                ),
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'Comparar datas',
                  style: TextStyle(
                    color: Color(0xFF2C262C),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (selectedValue != null)
                TextButton(
                  style: _historyTextButtonStyle(accentColor),
                  onPressed: () => onChanged(null),
                  child: const Text('Limpar'),
                ),
            ],
          ),
          const SizedBox(height: 9),
          DropdownButtonFormField<String>(
            initialValue: selectedValue,
            isExpanded: true,
            iconEnabledColor: _darkenCharacterDialogColor(accentColor, 0.16),
            dropdownColor: const Color(0xFFFFF8FC),
            decoration: InputDecoration(
              helperText: 'Escolha um evento de referencia.',
              helperStyle: TextStyle(
                color: Colors.black.withValues(alpha: 0.45),
                fontSize: 10.5,
                height: 1.15,
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.74),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: accentColor.withValues(alpha: 0.14),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: accentColor, width: 1.2),
              ),
            ),
            hint: const Text('Selecionar evento'),
            items: [
              for (final event in events)
                DropdownMenuItem<String>(
                  value: event.id,
                  child: Text(
                    '${_historyDateLabel(_HistoryTimelineItem.event(event))} - ${event.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _HistoryRelativeComparisonResult extends StatelessWidget {
  final Color accentColor;
  final _CharacterHistoryEvent currentEvent;
  final _CharacterHistoryEvent relativeEvent;

  const _HistoryRelativeComparisonResult({
    required this.accentColor,
    required this.currentEvent,
    required this.relativeEvent,
  });

  @override
  Widget build(BuildContext context) {
    final color = _darkenCharacterDialogColor(accentColor, 0.16);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.timeline_rounded, size: 18, color: color),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _relativeHistoryEventText(currentEvent, relativeEvent),
                  style: const TextStyle(
                    color: Color(0xFF2C262C),
                    fontSize: 14,
                    height: 1.25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${_historyDateLabel(_HistoryTimelineItem.event(currentEvent))} comparado com ${_historyDateLabel(_HistoryTimelineItem.event(relativeEvent))}.',
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.54),
                    fontSize: 11.5,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final Color accentColor;
  final TextInputType? keyboardType;
  final String? errorText;

  const _HistoryTextInput({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.accentColor,
    this.keyboardType,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 5),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.56),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            color: Color(0xFF2C262C),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            filled: true,
            fillColor: _historyTimelineBackgroundColor.withValues(alpha: 0.78),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: accentColor, width: 1.2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFFB94358)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: Color(0xFFB94358),
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryDateSelectorButton extends StatelessWidget {
  final Color accentColor;
  final String label;
  final _HistoryMonthDay? value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _HistoryDateSelectorButton({
    required this.accentColor,
    required this.label,
    required this.value,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final valueLabel = value == null
        ? 'Sem mes/dia'
        : _formatHistoryMonthDay(value!.month, value!.day);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 11, 10, 11),
          decoration: BoxDecoration(
            color: _historyTimelineBackgroundColor.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  size: 16,
                  color: _darkenCharacterDialogColor(accentColor, 0.16),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.5),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      valueLabel,
                      style: const TextStyle(
                        color: Color(0xFF2C262C),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (onClear != null)
                IconButton(
                  tooltip: 'Remover data',
                  onPressed: onClear,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close_rounded, size: 17),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryFixedDatePanel extends StatelessWidget {
  final Color accentColor;
  final String label;
  final String value;

  const _HistoryFixedDatePanel({
    required this.accentColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cake_outlined,
            size: 17,
            color: _darkenCharacterDialogColor(accentColor, 0.16),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.5),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF2C262C),
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCharacterPresencePicker extends StatelessWidget {
  final Color accentColor;
  final List<CharacterListItem> characters;
  final List<int> selectedIds;
  final ValueChanged<int> onToggle;

  const _HistoryCharacterPresencePicker({
    required this.accentColor,
    required this.characters,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final selectableCharacters = characters
        .where((character) => character.id != null)
        .toList(growable: false);
    if (selectableCharacters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personagens presentes',
          style: TextStyle(
            color: Color(0xFF2C262C),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final character in selectableCharacters)
              _HistoryCharacterPresenceChip(
                character: character,
                selected: selectedIds.contains(character.id),
                accentColor: accentColor,
                onTap: () => onToggle(character.id!),
              ),
          ],
        ),
      ],
    );
  }
}

class _HistoryCharacterPresenceChip extends StatelessWidget {
  final CharacterListItem character;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  const _HistoryCharacterPresenceChip({
    required this.character,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = character.data.accent;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 6, 10, 6),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.16)
                : Colors.white.withValues(alpha: 0.52),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? color.withValues(alpha: 0.42)
                  : accentColor.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? Icons.check_rounded : Icons.person_outline_rounded,
                size: 14,
                color: selected ? color : const Color(0xFF645B64),
              ),
              const SizedBox(width: 5),
              Text(
                character.data.name.trim().isEmpty
                    ? 'Sem nome'
                    : character.data.name.trim(),
                style: const TextStyle(
                  color: Color(0xFF2C262C),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryEmotionPicker extends StatelessWidget {
  final Color accentColor;
  final List<String> selectedEmotionIds;
  final ValueChanged<String> onToggle;

  const _HistoryEmotionPicker({
    required this.accentColor,
    required this.selectedEmotionIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final selectedEmotions = _resolveHistoryEmotions(
      _historyEmotionWheel,
      selectedEmotionIds,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HistoryEmotionSearchSuggestions(
          accentColor: accentColor,
          selectedEmotionIds: selectedEmotions
              .map((emotion) => emotion.id)
              .toSet(),
          onToggle: onToggle,
        ),
        const SizedBox(height: 8),
        _HistoryPlutchikPicker(
          accentColor: accentColor,
          selectedEmotionIds: selectedEmotions
              .map((emotion) => emotion.id)
              .toSet(),
          onSelected: onToggle,
        ),
        const SizedBox(height: 8),
        _HistoryEmotionPillWrap(emotions: selectedEmotions),
      ],
    );
  }
}

class _HistoryEmotionSearchSuggestions extends StatefulWidget {
  final Color accentColor;
  final Set<String> selectedEmotionIds;
  final ValueChanged<String> onToggle;
  final bool compact;
  final String? hintText;

  const _HistoryEmotionSearchSuggestions({
    required this.accentColor,
    required this.selectedEmotionIds,
    required this.onToggle,
    this.compact = false,
    this.hintText,
  });

  @override
  State<_HistoryEmotionSearchSuggestions> createState() =>
      _HistoryEmotionSearchSuggestionsState();
}

class _HistoryEmotionSearchSuggestionsState
    extends State<_HistoryEmotionSearchSuggestions> {
  late final TextEditingController _controller;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matches = _query.trim().isEmpty
        ? const <_HistoryEmotionDefinition>[]
        : _searchHistoryEmotions(_query);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          minLines: _query.trim().isEmpty ? (widget.compact ? 3 : 2) : 1,
          maxLines: null,
          onChanged: (value) => setState(() => _query = value),
          style: const TextStyle(
            color: Color(0xFF2C262C),
            fontSize: 13,
            height: 1.25,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText:
                widget.hintText ??
                'Experimente pesquisar pelas emocoes primarias (alegria, antecipacao, confianca, medo, surpresa, tristeza, aversao, raiva)',
            hintMaxLines: 4,
            prefixIcon: Icon(
              Icons.search_rounded,
              size: 17,
              color: _darkenCharacterDialogColor(widget.accentColor, 0.14),
            ),
            suffixIcon: _query.trim().isEmpty
                ? null
                : IconButton(
                    tooltip: 'Limpar pesquisa',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.close_rounded, size: 16),
                    onPressed: () {
                      _controller.clear();
                      setState(() => _query = '');
                    },
                  ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.66),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 9,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(
                color: widget.accentColor.withValues(alpha: 0.12),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(
                color: widget.accentColor.withValues(alpha: 0.12),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(color: widget.accentColor, width: 1.1),
            ),
          ),
        ),
        if (matches.isNotEmpty) ...[
          SizedBox(height: widget.compact ? 6 : 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final emotion in matches.take(widget.compact ? 5 : 8))
                _HistoryEmotionSuggestionChip(
                  emotion: emotion,
                  selected: widget.selectedEmotionIds.contains(emotion.id),
                  onTap: () => widget.onToggle(emotion.id),
                ),
            ],
          ),
        ],
        if (_query.trim().isNotEmpty && matches.isEmpty) ...[
          const SizedBox(height: 6),
          Text(
            'Nenhuma emocao encontrada.',
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.48),
              fontSize: 11.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        if (matches.isNotEmpty) SizedBox(height: widget.compact ? 6 : 8),
      ],
    );
  }
}

class _HistoryEmotionSuggestionChip extends StatelessWidget {
  final _HistoryEmotionDefinition emotion;
  final bool selected;
  final VoidCallback onTap;

  const _HistoryEmotionSuggestionChip({
    required this.emotion,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = _darkenCharacterDialogColor(emotion.color, 0.28);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 5, 9, 5),
          decoration: BoxDecoration(
            color: selected
                ? emotion.color.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.58),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? emotion.color.withValues(alpha: 0.34)
                  : emotion.color.withValues(alpha: 0.16),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? Icons.check_rounded : Icons.add_rounded,
                size: 13,
                color: textColor,
              ),
              const SizedBox(width: 4),
              Text(
                emotion.label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryPlutchikPicker extends StatelessWidget {
  final Color accentColor;
  final Set<String> selectedEmotionIds;
  final ValueChanged<String> onSelected;

  const _HistoryPlutchikPicker({
    required this.accentColor,
    required this.selectedEmotionIds,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = (constraints.maxWidth * 0.98).clamp(360.0, 520.0);
        return SizedBox(
          height: height,
          child: LayoutBuilder(
            builder: (context, innerConstraints) {
              final size = Size(
                innerConstraints.maxWidth,
                innerConstraints.maxHeight,
              );
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (details) {
                  final picked = _plutchikEmotionFromPosition(
                    size,
                    details.localPosition,
                  );
                  if (picked != null) onSelected(picked.id);
                },
                child: CustomPaint(
                  painter: _PlutchikWheelPainter(
                    accentColor: accentColor,
                    selectedEmotionIds: selectedEmotionIds,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _PlutchikWheelPainter extends CustomPainter {
  final Color accentColor;
  final Set<String> selectedEmotionIds;

  const _PlutchikWheelPainter({
    required this.accentColor,
    required this.selectedEmotionIds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerLimit = min(size.width, size.height) * 0.48;
    final radius = outerLimit * 0.68;
    final dyadInnerRadius = radius * 1.06;
    final dyadOuterRadius = outerLimit * 0.98;
    final sectorSweep = pi * 2 / 8;
    final gap = sectorSweep * 0.055;
    for (var index = 0; index < 8; index += 1) {
      final first = _plutchikEmotionAt(index, 2);
      final second = _plutchikEmotionAt((index + 1) % 8, 2);
      final boundaryAngle = -pi / 2 + (index + 0.5) * sectorSweep;
      final path = _plutchikPetalSegmentPath(
        center: center,
        innerRadius: dyadInnerRadius,
        outerRadius: dyadOuterRadius,
        startAngle: boundaryAngle - sectorSweep * 0.32,
        sweep: sectorSweep * 0.64,
        tipFactor: 0.90,
      );
      final dyadColor = Color.lerp(first.color, second.color, 0.5)!;
      canvas.drawPath(path, Paint()..color = dyadColor.withValues(alpha: 0.22));
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.66)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
      final dyad = _plutchikDyadAt(index);
      if (selectedEmotionIds.contains(dyad.id)) {
        canvas.drawPath(
          path,
          Paint()
            ..color = _darkenCharacterDialogColor(dyadColor, 0.16)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2,
        );
        final markerOffset =
            center +
            Offset(cos(boundaryAngle), sin(boundaryAngle)) *
                ((dyadInnerRadius + dyadOuterRadius) / 2);
        canvas.drawCircle(
          markerOffset,
          4.2,
          Paint()..color = Colors.white.withValues(alpha: 0.9),
        );
        canvas.drawCircle(
          markerOffset,
          2.5,
          Paint()..color = _darkenCharacterDialogColor(dyadColor, 0.18),
        );
      }
    }

    for (var index = 0; index < 8; index += 1) {
      for (var intensity = 1; intensity <= 3; intensity += 1) {
        final emotion = _plutchikEmotionAt(index, intensity);
        final inner = switch (intensity) {
          3 => radius * 0.08,
          2 => radius * 0.36,
          _ => radius * 0.66,
        };
        final outer = switch (intensity) {
          3 => radius * 0.36,
          2 => radius * 0.66,
          _ => radius,
        };
        final startAngle =
            -pi / 2 - sectorSweep / 2 + index * sectorSweep + gap;
        final path = _plutchikPetalSegmentPath(
          center: center,
          innerRadius: inner,
          outerRadius: outer,
          startAngle: startAngle,
          sweep: sectorSweep - gap * 2,
          tipFactor: intensity == 1 ? 0.78 : 0.96,
        );
        final selected = selectedEmotionIds.contains(emotion.id);
        final fillStrength = switch (intensity) {
          1 => 0.34,
          2 => 0.62,
          _ => 0.92,
        };
        canvas.drawPath(
          path,
          Paint()
            ..color = Color.lerp(
              Colors.white,
              emotion.color,
              fillStrength,
            )!.withValues(alpha: selected ? 1 : 0.92),
        );
        canvas.drawPath(
          path,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.74)
            ..style = PaintingStyle.stroke
            ..strokeWidth = selected ? 2.1 : 0.9,
        );
        if (selected) {
          canvas.drawPath(
            path,
            Paint()
              ..color = _darkenCharacterDialogColor(emotion.color, 0.16)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.4,
          );
          final markerOffset =
              center +
              Offset(
                    cos(startAngle + (sectorSweep - gap * 2) / 2),
                    sin(startAngle + (sectorSweep - gap * 2) / 2),
                  ) *
                  ((inner + outer) / 2);
          canvas.drawCircle(
            markerOffset,
            4.2,
            Paint()..color = Colors.white.withValues(alpha: 0.9),
          );
          canvas.drawCircle(
            markerOffset,
            2.5,
            Paint()..color = _darkenCharacterDialogColor(emotion.color, 0.18),
          );
        }
      }
    }

    canvas.drawCircle(
      center,
      radius * 0.08,
      Paint()..color = Colors.white.withValues(alpha: 0.78),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = accentColor.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _PlutchikWheelPainter oldDelegate) {
    return oldDelegate.accentColor != accentColor ||
        oldDelegate.selectedEmotionIds.length != selectedEmotionIds.length ||
        !oldDelegate.selectedEmotionIds.containsAll(selectedEmotionIds);
  }
}

Path _plutchikPetalSegmentPath({
  required Offset center,
  required double innerRadius,
  required double outerRadius,
  required double startAngle,
  required double sweep,
  required double tipFactor,
}) {
  final innerRect = Rect.fromCircle(center: center, radius: innerRadius);
  final endAngle = startAngle + sweep;
  final midAngle = startAngle + sweep / 2;
  final outerStart =
      center +
      Offset(cos(startAngle), sin(startAngle)) * outerRadius * tipFactor;
  final outerTip = center + Offset(cos(midAngle), sin(midAngle)) * outerRadius;
  final outerEnd =
      center + Offset(cos(endAngle), sin(endAngle)) * outerRadius * tipFactor;
  final innerEnd = center + Offset(cos(endAngle), sin(endAngle)) * innerRadius;
  final path = Path()..moveTo(outerStart.dx, outerStart.dy);
  path.quadraticBezierTo(outerTip.dx, outerTip.dy, outerEnd.dx, outerEnd.dy);
  if (innerRadius <= 0) {
    path.lineTo(center.dx, center.dy);
  } else {
    path.lineTo(innerEnd.dx, innerEnd.dy);
    path.arcTo(innerRect, startAngle + sweep, -sweep, false);
  }
  path.close();
  return path;
}

class _HistoryMarkdownEditor extends StatelessWidget {
  final TextEditingController controller;
  final ScrollController scrollController;
  final Color accentColor;
  final VoidCallback onChanged;

  const _HistoryMarkdownEditor({
    required this.controller,
    required this.scrollController,
    required this.accentColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _historyEditorDecoration(accentColor),
      child: TextField(
        controller: controller,
        scrollController: scrollController,
        expands: true,
        maxLines: null,
        minLines: null,
        textAlignVertical: TextAlignVertical.top,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          hintText: 'Markdown e escrita livre do evento.',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
          hintStyle: TextStyle(
            color: Colors.black.withValues(alpha: 0.38),
            fontStyle: FontStyle.italic,
          ),
        ),
        style: const TextStyle(
          color: Color(0xFF2C262C),
          fontSize: 14,
          height: 1.45,
        ),
        onChanged: (_) => onChanged(),
      ),
    );
  }
}

class _HistoryMarkdownPreview extends StatelessWidget {
  final String text;
  final ScrollController scrollController;

  const _HistoryMarkdownPreview({
    required this.text,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _historyEditorDecoration(const Color(0xFFDF6EB8)),
      child: Scrollbar(
        controller: scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: scrollController,
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(14),
          child: Align(
            alignment: Alignment.topLeft,
            child: text.trim().isEmpty
                ? Text(
                    'Nada para visualizar ainda.',
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.44),
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : MarkdownBody(
                    data: text,
                    selectable: true,
                    shrinkWrap: true,
                    softLineBreak: true,
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                        .copyWith(
                          p: const TextStyle(
                            color: Color(0xFF2C262C),
                            fontSize: 14,
                            height: 1.45,
                          ),
                          h1: const TextStyle(
                            color: Color(0xFF2C262C),
                            fontSize: 20,
                            height: 1.25,
                            fontWeight: FontWeight.w800,
                          ),
                          h2: const TextStyle(
                            color: Color(0xFF2C262C),
                            fontSize: 17,
                            height: 1.3,
                            fontWeight: FontWeight.w800,
                          ),
                          h3: const TextStyle(
                            color: Color(0xFF2C262C),
                            fontSize: 15.5,
                            height: 1.3,
                            fontWeight: FontWeight.w800,
                          ),
                          blockSpacing: 8,
                          listIndent: 18,
                        ),
                  ),
          ),
        ),
      ),
    );
  }
}

BoxDecoration _historyEditorDecoration(Color accentColor) {
  return BoxDecoration(
    color: Colors.white.withValues(alpha: 0.68),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: accentColor.withValues(alpha: 0.14)),
  );
}

ButtonStyle _historyFilledButtonStyle(Color accentColor) {
  final color = _darkenCharacterDialogColor(accentColor, 0.12);
  return FilledButton.styleFrom(
    backgroundColor: color,
    foregroundColor: Colors.white,
    disabledBackgroundColor: color.withValues(alpha: 0.34),
    disabledForegroundColor: Colors.white.withValues(alpha: 0.72),
    minimumSize: const Size(0, 44),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  );
}

ButtonStyle _historyOutlinedButtonStyle(Color accentColor) {
  final color = _darkenCharacterDialogColor(accentColor, 0.14);
  return OutlinedButton.styleFrom(
    backgroundColor: _historyTimelineBackgroundColor.withValues(alpha: 0.7),
    foregroundColor: color,
    side: BorderSide(color: accentColor.withValues(alpha: 0.26)),
    minimumSize: const Size(0, 44),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  );
}

ButtonStyle _historyTextButtonStyle(Color accentColor) {
  return TextButton.styleFrom(
    foregroundColor: _darkenCharacterDialogColor(accentColor, 0.12),
    textStyle: const TextStyle(fontWeight: FontWeight.w800),
  );
}

ButtonStyle _historyIconButtonStyle(Color accentColor) {
  final color = _darkenCharacterDialogColor(accentColor, 0.16);
  return IconButton.styleFrom(
    backgroundColor: accentColor.withValues(alpha: 0.13),
    foregroundColor: color,
    disabledBackgroundColor: accentColor.withValues(alpha: 0.06),
    disabledForegroundColor: color.withValues(alpha: 0.44),
  );
}

class _HistoryTimelineItem {
  final _HistoryTimelineItemType type;
  final double ageOffset;
  final DateTime? birthDate;
  final _HistoryMilestoneDetails? milestoneDetails;
  final _CharacterHistoryEvent? event;

  const _HistoryTimelineItem._({
    required this.type,
    required this.ageOffset,
    this.birthDate,
    this.milestoneDetails,
    this.event,
  });

  factory _HistoryTimelineItem.birth(
    DateTime birthday,
    _HistoryMilestoneDetails details,
  ) => _HistoryTimelineItem._(
    type: _HistoryTimelineItemType.birth,
    ageOffset: 0,
    birthDate: birthday,
    milestoneDetails: details,
  );

  factory _HistoryTimelineItem.event(_CharacterHistoryEvent event) =>
      _HistoryTimelineItem._(
        type: _HistoryTimelineItemType.event,
        ageOffset: event.ageOffset,
        event: event,
      );

  factory _HistoryTimelineItem.death(
    double ageOffset,
    _HistoryMilestoneDetails details,
  ) => _HistoryTimelineItem._(
    type: _HistoryTimelineItemType.death,
    ageOffset: ageOffset,
    milestoneDetails: details,
  );

  String get title {
    return switch (type) {
      _HistoryTimelineItemType.birth => 'Nascimento',
      _HistoryTimelineItemType.death => 'Morte',
      _HistoryTimelineItemType.event => event?.title ?? 'Evento',
    };
  }

  String get markdown => event?.markdown ?? milestoneDetails?.markdown ?? '';

  String get emotionId =>
      event?.emotionId ?? milestoneDetails?.emotionId ?? 'calma';

  List<String> get emotionIds =>
      event?.emotionIds ?? milestoneDetails?.resolvedEmotionIds ?? ['calma'];

  int? get month {
    if (event != null) return event!.month;
    if (type == _HistoryTimelineItemType.birth) {
      return milestoneDetails?.month ?? birthDate?.month;
    }
    return milestoneDetails?.month;
  }

  int? get day {
    if (event != null) return event!.day;
    if (type == _HistoryTimelineItemType.birth) {
      return milestoneDetails?.day ?? birthDate?.day;
    }
    return milestoneDetails?.day;
  }

  String get ageLabel {
    return switch (type) {
      _HistoryTimelineItemType.birth => 'Ano 0',
      _ => _historyAgeLabel(ageOffset),
    };
  }

  int get order {
    return switch (type) {
      _HistoryTimelineItemType.birth => 0,
      _HistoryTimelineItemType.event => 1,
      _HistoryTimelineItemType.death => 2,
    };
  }
}

enum _HistoryTimelineItemType { birth, event, death }

class _HistoryTimelineGroup {
  final double ageOffset;
  final List<_HistoryTimelineItem> items;

  const _HistoryTimelineGroup({required this.ageOffset, required this.items});

  String get yearKey => _formatHistoryNumber(ageOffset);

  String get ageLabel {
    return _historyAgeLabel(ageOffset);
  }

  _HistoryTimelineItemType get iconType {
    if (ageOffset == 0) return _HistoryTimelineItemType.birth;
    if (items.any((item) => item.type == _HistoryTimelineItemType.death)) {
      return _HistoryTimelineItemType.death;
    }
    return _HistoryTimelineItemType.event;
  }

  int get eventCount =>
      items.where((item) => item.type == _HistoryTimelineItemType.event).length;
}

List<_HistoryTimelineGroup> _groupTimelineItems(
  List<_HistoryTimelineItem> items,
) {
  final groups = <_HistoryTimelineGroup>[];
  for (final item in items) {
    if (groups.isNotEmpty && groups.last.ageOffset == item.ageOffset) {
      groups[groups.length - 1] = _HistoryTimelineGroup(
        ageOffset: groups.last.ageOffset,
        items: [...groups.last.items, item]..sort(_compareTimelineItems),
      );
      continue;
    }

    groups.add(_HistoryTimelineGroup(ageOffset: item.ageOffset, items: [item]));
  }
  return groups;
}

int _compareTimelineItems(_HistoryTimelineItem a, _HistoryTimelineItem b) {
  final ageCompare = a.ageOffset.compareTo(b.ageOffset);
  if (ageCompare != 0) return ageCompare;
  final monthCompare = (a.month ?? 0).compareTo(b.month ?? 0);
  if (monthCompare != 0) return monthCompare;
  final dayCompare = (a.day ?? 0).compareTo(b.day ?? 0);
  if (dayCompare != 0) return dayCompare;
  final orderCompare = a.order.compareTo(b.order);
  if (orderCompare != 0) return orderCompare;
  return a.title.toLowerCase().compareTo(b.title.toLowerCase());
}

const double _collapsedTimelineGroupRailHeight = 44;
const double _collapsedTimelineGroupNodeSize = 30;

double _timelineGroupRailHeight(int itemCount) {
  return itemCount <= 1 ? 112 : 136 + ((itemCount - 1) * 34);
}

double _timelineGroupRailNodeSize(int itemCount) {
  return itemCount > 1 ? 40 : 34;
}

Color _timelineItemColor(
  _HistoryTimelineItem item,
  Color avatarColor,
  _HistoryEmotionWheel emotionWheel,
) {
  if (item.event == null) {
    if (item.milestoneDetails != null) {
      return _resolveHistoryEmotion(emotionWheel, item.emotionId).color;
    }
    return item.type == _HistoryTimelineItemType.birth
        ? avatarColor
        : const Color(0xFF5E5963);
  }

  return _resolveHistoryEmotion(emotionWheel, item.emotionId).color;
}

List<String> _readHistoryEmotionIds(
  Object? rawEmotionIds,
  String? rawEmotionId,
  _HistoryEmotionWheel wheel,
) {
  final catalog = _historyEmotionCatalog(wheel);
  final ids = <String>[];
  if (rawEmotionIds is List) {
    for (final value in rawEmotionIds) {
      final id = value?.toString();
      if (id != null &&
          catalog.any((emotion) => emotion.id == id) &&
          !ids.contains(id)) {
        ids.add(id);
      }
    }
  }
  if (ids.isEmpty &&
      rawEmotionId != null &&
      catalog.any((emotion) => emotion.id == rawEmotionId)) {
    ids.add(rawEmotionId);
  }
  if (ids.isEmpty) ids.add(catalog.first.id);
  return ids;
}

List<String> _validHistoryEmotionIds(
  List<String> emotionIds,
  _HistoryEmotionWheel wheel,
) {
  return _readHistoryEmotionIds(emotionIds, null, wheel);
}

_CharacterHistoryDraft _decodeCharacterHistory(Map<String, String> values) {
  final raw = values[_historyStorageKey];
  if (raw == null || raw.trim().isEmpty) {
    return _defaultCharacterHistoryDraft();
  }

  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, Object?>) {
      return _CharacterHistoryDraft.fromJson(decoded);
    }
    if (decoded is Map) {
      return _CharacterHistoryDraft.fromJson(
        decoded.map((key, value) => MapEntry(key.toString(), value)),
      );
    }
  } catch (_) {
    return _defaultCharacterHistoryDraft();
  }

  return _defaultCharacterHistoryDraft();
}

_CharacterHistoryDraft _defaultCharacterHistoryDraft() {
  return const _CharacterHistoryDraft();
}

Map<String, String> _storeCharacterHistory(
  Map<String, String> values,
  _CharacterHistoryDraft history,
) {
  return <String, String>{
    ...values,
    _historyStorageKey: jsonEncode(history.toJson()),
  };
}

String _newHistoryEventId() =>
    'history_${DateTime.now().microsecondsSinceEpoch}';

_HistoryEmotionWheel _historyEmotionWheelFromName(String? value) {
  for (final wheel in _HistoryEmotionWheel.values) {
    if (wheel.name == value) return wheel;
  }
  return _historyEmotionWheel;
}

_HistoryTimelineItemType _historyTimelineItemTypeFromName(String? value) {
  for (final type in _HistoryTimelineItemType.values) {
    if (type.name == value) return type;
  }
  return _HistoryTimelineItemType.event;
}

_HistoryMilestoneDetails _readHistoryMilestoneDetails(
  Object? value,
  _HistoryEmotionWheel wheel,
) {
  if (value is Map<String, Object?>) {
    return _HistoryMilestoneDetails.fromJson(value, wheel);
  }
  if (value is Map) {
    return _HistoryMilestoneDetails.fromJson(
      value.map((key, value) => MapEntry(key.toString(), value)),
      wheel,
    );
  }
  return _HistoryMilestoneDetails(
    emotionId: _historyEmotionCatalog(wheel).first.id,
  );
}

List<_CharacterHistoryEvent> _sortedHistoryEvents(
  List<_CharacterHistoryEvent> events,
) {
  return events.toList(growable: false)..sort((a, b) {
    final ageCompare = a.ageOffset.compareTo(b.ageOffset);
    if (ageCompare != 0) return ageCompare;
    final monthCompare = (a.month ?? 0).compareTo(b.month ?? 0);
    if (monthCompare != 0) return monthCompare;
    final dayCompare = (a.day ?? 0).compareTo(b.day ?? 0);
    if (dayCompare != 0) return dayCompare;
    return a.title.toLowerCase().compareTo(b.title.toLowerCase());
  });
}

bool _matchesHistorySearch(_CharacterHistoryEvent event, String query) {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) return true;

  return [
    event.title,
    event.markdown,
    _historyAgeLabel(event.ageOffset),
    _formatHistoryMonthDay(event.month, event.day),
  ].any((value) => value.toLowerCase().contains(normalizedQuery));
}

bool _matchesHistoryEmotionFilter(
  _CharacterHistoryEvent event,
  Set<String> emotionIds,
) {
  return emotionIds.isEmpty ||
      event.emotionIds.any((emotionId) => emotionIds.contains(emotionId));
}

List<_HistoryEmotionDefinition> _searchHistoryEmotions(String query) {
  final normalizedQuery = _normalizeHistoryText(query);
  if (normalizedQuery.isEmpty) return const <_HistoryEmotionDefinition>[];

  final catalog = _historyEmotionCatalog(_historyEmotionWheel);
  final matches = <_HistoryEmotionDefinition>[];
  final anchor = _historyEmotionSearchAnchor(normalizedQuery, catalog);
  if (anchor != null) {
    for (final emotion in _hierarchicalHistoryEmotionSuggestions(anchor)) {
      _addHistoryEmotionSuggestion(matches, emotion);
    }
  }

  for (final emotion in catalog.where((emotion) {
    return [
      emotion.label,
      emotion.description,
      emotion.id,
    ].any((value) => _normalizeHistoryText(value).contains(normalizedQuery));
  })) {
    _addHistoryEmotionSuggestion(matches, emotion);
  }

  return matches;
}

_HistoryEmotionDefinition? _historyEmotionSearchAnchor(
  String normalizedQuery,
  List<_HistoryEmotionDefinition> catalog,
) {
  _HistoryEmotionDefinition? findMatch(bool Function(String value) matches) {
    for (final emotion in catalog) {
      if ([
        emotion.label,
        emotion.id,
      ].any((value) => matches(_normalizeHistoryText(value)))) {
        return emotion;
      }
    }
    return null;
  }

  return findMatch((value) => value == normalizedQuery) ??
      findMatch((value) => value.startsWith(normalizedQuery)) ??
      findMatch((value) => value.contains(normalizedQuery));
}

List<_HistoryEmotionDefinition> _hierarchicalHistoryEmotionSuggestions(
  _HistoryEmotionDefinition anchor,
) {
  final index = anchor.plutchikIndex;
  final intensity = anchor.plutchikIntensity;
  if (index == null || intensity == null) {
    return [anchor];
  }

  final suggestions = <_HistoryEmotionDefinition>[];
  void add(_HistoryEmotionDefinition emotion) {
    _addHistoryEmotionSuggestion(suggestions, emotion);
  }

  final broad = _plutchikEmotionAt(index, 1);
  final middle = _plutchikEmotionAt(index, 2);
  final intense = _plutchikEmotionAt(index, 3);
  final dyad = _plutchikDyadAt((index + 1) % 8);

  if (intensity == 3) {
    add(intense);
    add(middle);
    add(broad);
    add(dyad);
  } else if (intensity == 2) {
    add(broad);
    add(dyad);
    add(middle);
  } else {
    add(broad);
    add(dyad);
  }

  return suggestions;
}

void _addHistoryEmotionSuggestion(
  List<_HistoryEmotionDefinition> suggestions,
  _HistoryEmotionDefinition emotion,
) {
  if (!suggestions.any((stored) => stored.id == emotion.id)) {
    suggestions.add(emotion);
  }
}

String _normalizeHistoryText(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp('[áàâãä]'), 'a')
      .replaceAll(RegExp('[éèêë]'), 'e')
      .replaceAll(RegExp('[íìîï]'), 'i')
      .replaceAll(RegExp('[óòôõö]'), 'o')
      .replaceAll(RegExp('[úùûü]'), 'u')
      .replaceAll('ç', 'c');
}

double? _readHistoryDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return _parseHistoryNumber(value);
  return null;
}

double? _parseHistoryNumber(String raw) {
  return double.tryParse(raw.trim().replaceAll(',', '.'));
}

int? _readHistoryInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

List<int> _readHistoryIntList(Object? value) {
  if (value is! List) return const <int>[];
  return value
      .map((entry) => _readHistoryInt(entry))
      .whereType<int>()
      .toList(growable: false);
}

String _formatHistoryNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(1);
}

String _historyAgeLabel(double ageOffset) {
  return 'Ano ${_formatHistoryNumber(ageOffset)}';
}

String _formatHistoryMonthDay(int? month, int? day) {
  if (month == null) return '';
  final monthLabel = monthLabels[(month - 1).clamp(0, 11)];
  if (day == null) return monthLabel;
  return '${day.toString().padLeft(2, '0')} $monthLabel';
}

String _historyDateLabel(_HistoryTimelineItem item) {
  final monthDay = _historyMonthDayLabel(item);
  return monthDay.isEmpty ? item.ageLabel : '${item.ageLabel} - $monthDay';
}

String _historyMonthDayLabel(_HistoryTimelineItem item) {
  return _formatHistoryMonthDay(item.month, item.day);
}

String _historyIntervalLabel(
  _HistoryTimelineItem previous,
  _HistoryTimelineItem next,
) {
  final duration = _historyIntervalDurationLabel(previous, next);
  return '$duration antes de "${next.title}".';
}

String _historyIntervalDurationLabel(
  _HistoryTimelineItem previous,
  _HistoryTimelineItem next,
) {
  final previousDate = _historyTimelinePseudoDate(previous);
  final nextDate = _historyTimelinePseudoDate(next);
  if (previousDate == null || nextDate == null) {
    final years = (next.ageOffset - previous.ageOffset).clamp(
      0,
      double.infinity,
    );
    if (years == 0) return 'no mesmo ano';
    return _historyDurationPartsText([
      _historyDurationPart(years.toDouble(), 'ano'),
    ]);
  }

  if (!nextDate.isAfter(previousDate)) return 'no mesmo dia';

  var years = nextDate.year - previousDate.year;
  var months = nextDate.month - previousDate.month;
  var days = nextDate.day - previousDate.day;

  if (days < 0) {
    months -= 1;
    final previousMonth = DateTime(nextDate.year, nextDate.month, 0);
    days += daysInMonth(previousMonth.month);
  }
  if (months < 0) {
    years -= 1;
    months += 12;
  }

  final parts = <String>[
    if (years > 0) _historyDurationPart(years.toDouble(), 'ano'),
    if (months > 0) _historyDurationPart(months.toDouble(), 'mes'),
    if (days > 0) _historyDurationPart(days.toDouble(), 'dia'),
  ];
  return parts.isEmpty ? 'no mesmo dia' : _historyDurationPartsText(parts);
}

DateTime? _historyTimelinePseudoDate(_HistoryTimelineItem item) {
  if (item.month == null || item.day == null) return null;
  if (item.ageOffset != item.ageOffset.roundToDouble()) return null;
  return DateTime(2000 + item.ageOffset.toInt(), item.month!, item.day!);
}

String _historyDurationPart(double value, String singular) {
  final label = _formatHistoryNumber(value);
  final plural = singular == 'mes' ? 'meses' : '${singular}s';
  return value == 1 ? '$label $singular' : '$label $plural';
}

String _historyDurationPartsText(List<String> parts) {
  if (parts.length <= 1) return parts.first;
  if (parts.length == 2) return '${parts.first} e ${parts.last}';
  return '${parts.sublist(0, parts.length - 1).join(', ')} e ${parts.last}';
}

_CharacterHistoryEvent? _historyEventById(
  List<_CharacterHistoryEvent> events,
  String? id,
) {
  if (id == null) return null;
  for (final event in events) {
    if (event.id == id) return event;
  }
  return null;
}

String _relativeHistoryEventText(
  _CharacterHistoryEvent event,
  _CharacterHistoryEvent relativeEvent,
) {
  final delta = event.ageOffset - relativeEvent.ageOffset;
  if (delta == 0) {
    return 'No mesmo ano de "${relativeEvent.title}".';
  }

  final years = _formatHistoryNumber(delta.abs());
  final yearLabel = delta.abs() == 1 ? 'ano' : 'anos';
  final direction = delta > 0 ? 'depois' : 'antes';
  return '$years $yearLabel $direction de "${relativeEvent.title}".';
}

_HistoryEmotionDefinition? _plutchikEmotionFromPosition(
  Size size,
  Offset position,
) {
  final center = Offset(size.width / 2, size.height / 2);
  final outerLimit = min(size.width, size.height) * 0.48;
  final radius = outerLimit * 0.68;
  final dyadInnerRadius = radius * 1.06;
  final dyadOuterRadius = outerLimit * 0.98;
  final delta = position - center;
  final distance = delta.distance;
  if (distance <= radius * 0.08 || distance > dyadOuterRadius) return null;

  final sectorSweep = pi * 2 / 8;
  final angle = atan2(delta.dy, delta.dx);

  if (distance > dyadInnerRadius) {
    final dyadNormalized = (angle + pi / 2) % (pi * 2);
    final dyadIndex = (dyadNormalized / sectorSweep).floor().clamp(0, 7);
    return _plutchikDyadAt(dyadIndex);
  }

  final normalized = (angle + pi / 2 + sectorSweep / 2) % (pi * 2);
  final index = (normalized / sectorSweep).floor().clamp(0, 7);
  final normalizedRadius = distance / radius;
  final intensity = normalizedRadius <= 0.36
      ? 3
      : normalizedRadius <= 0.66
      ? 2
      : 1;
  return _plutchikEmotionAt(index, intensity);
}

_HistoryEmotionDefinition _plutchikEmotionAt(int index, int intensity) {
  return _plutchikEmotions.firstWhere(
    (emotion) =>
        emotion.plutchikIndex == index &&
        emotion.plutchikIntensity == intensity,
    orElse: () => _plutchikEmotions.first,
  );
}

_HistoryEmotionDefinition _plutchikDyadAt(int index) {
  return _plutchikDyads[index % 8];
}

const List<_HistoryEmotionDefinition> _plutchikDyads =
    <_HistoryEmotionDefinition>[
      _HistoryEmotionDefinition(
        id: 'otimismo',
        label: 'Otimismo',
        description: 'Alegria e antecipacao.',
        color: Color(0xFFE7A042),
      ),
      _HistoryEmotionDefinition(
        id: 'amor',
        label: 'Amor',
        description: 'Alegria e confianca.',
        color: Color(0xFFB5C954),
      ),
      _HistoryEmotionDefinition(
        id: 'submissao',
        label: 'Submissao',
        description: 'Confianca e medo.',
        color: Color(0xFF7EB765),
      ),
      _HistoryEmotionDefinition(
        id: 'assombro',
        label: 'Assombro',
        description: 'Medo e surpresa.',
        color: Color(0xFF55A6A7),
      ),
      _HistoryEmotionDefinition(
        id: 'desaprovacao',
        label: 'Desaprovacao',
        description: 'Surpresa e tristeza.',
        color: Color(0xFF6D99C2),
      ),
      _HistoryEmotionDefinition(
        id: 'remorso',
        label: 'Remorso',
        description: 'Tristeza e aversao.',
        color: Color(0xFF775EAA),
      ),
      _HistoryEmotionDefinition(
        id: 'desprezo',
        label: 'Desprezo',
        description: 'Aversao e raiva.',
        color: Color(0xFFAA5B82),
      ),
      _HistoryEmotionDefinition(
        id: 'agressividade',
        label: 'Agressividade',
        description: 'Raiva e antecipacao.',
        color: Color(0xFFD05E43),
      ),
    ];

_HistoryEmotionDefinition _resolveHistoryEmotion(
  _HistoryEmotionWheel wheel,
  String id,
) {
  final catalog = _historyEmotionCatalog(wheel);
  return catalog.firstWhere(
    (emotion) => emotion.id == id,
    orElse: () => catalog.first,
  );
}

List<_HistoryEmotionDefinition> _resolveHistoryEmotions(
  _HistoryEmotionWheel wheel,
  List<String> ids,
) {
  final catalog = _historyEmotionCatalog(wheel);
  final resolved = <_HistoryEmotionDefinition>[];
  for (final id in ids) {
    final emotion = catalog.firstWhere(
      (emotion) => emotion.id == id,
      orElse: () => catalog.first,
    );
    if (!resolved.any((stored) => stored.id == emotion.id)) {
      resolved.add(emotion);
    }
  }
  if (resolved.isEmpty) resolved.add(catalog.first);
  return resolved;
}

List<_HistoryEmotionDefinition> _historyEmotionCatalog(
  _HistoryEmotionWheel wheel,
) {
  return const <_HistoryEmotionDefinition>[
    ..._plutchikEmotions,
    ..._plutchikDyads,
  ];
}

const List<_HistoryEmotionDefinition> _plutchikEmotions =
    <_HistoryEmotionDefinition>[
      _HistoryEmotionDefinition(
        id: 'serenidade',
        label: 'Serenidade',
        description: 'Prazer calmo e contentamento leve.',
        color: Color(0xFFE6C84F),
        plutchikIndex: 0,
        plutchikIntensity: 1,
      ),
      _HistoryEmotionDefinition(
        id: 'alegria_plutchik',
        label: 'Alegria',
        description: 'Abertura, prazer e recompensa.',
        color: Color(0xFFE6C84F),
        plutchikIndex: 0,
        plutchikIntensity: 2,
      ),
      _HistoryEmotionDefinition(
        id: 'extase',
        label: 'Extase',
        description: 'Alegria em intensidade maxima.',
        color: Color(0xFFE6C84F),
        plutchikIndex: 0,
        plutchikIntensity: 3,
      ),
      _HistoryEmotionDefinition(
        id: 'aceitacao',
        label: 'Aceitacao',
        description: 'Abertura e permissao relacional.',
        color: Color(0xFF67A95C),
        plutchikIndex: 1,
        plutchikIntensity: 1,
      ),
      _HistoryEmotionDefinition(
        id: 'confianca',
        label: 'Confianca',
        description: 'Vinculo, seguranca e entrega.',
        color: Color(0xFF67A95C),
        plutchikIndex: 1,
        plutchikIntensity: 2,
      ),
      _HistoryEmotionDefinition(
        id: 'admiracao',
        label: 'Admiracao',
        description: 'Confianca intensa e reverencia.',
        color: Color(0xFF67A95C),
        plutchikIndex: 1,
        plutchikIntensity: 3,
      ),
      _HistoryEmotionDefinition(
        id: 'apreensao',
        label: 'Apreensao',
        description: 'Alerta leve diante de risco.',
        color: Color(0xFF4C8E70),
        plutchikIndex: 2,
        plutchikIntensity: 1,
      ),
      _HistoryEmotionDefinition(
        id: 'medo_plutchik',
        label: 'Medo',
        description: 'Perigo, fuga e autopreservacao.',
        color: Color(0xFF4C8E70),
        plutchikIndex: 2,
        plutchikIntensity: 2,
      ),
      _HistoryEmotionDefinition(
        id: 'terror',
        label: 'Terror',
        description: 'Medo extremo e urgencia de sobrevivencia.',
        color: Color(0xFF4C8E70),
        plutchikIndex: 2,
        plutchikIntensity: 3,
      ),
      _HistoryEmotionDefinition(
        id: 'distracao',
        label: 'Distracao',
        description: 'Desvio leve de atencao.',
        color: Color(0xFF4E91B8),
        plutchikIndex: 3,
        plutchikIntensity: 1,
      ),
      _HistoryEmotionDefinition(
        id: 'surpresa',
        label: 'Surpresa',
        description: 'Ruptura de expectativa e orientacao.',
        color: Color(0xFF4E91B8),
        plutchikIndex: 3,
        plutchikIntensity: 2,
      ),
      _HistoryEmotionDefinition(
        id: 'espanto',
        label: 'Espanto',
        description: 'Surpresa intensa e absorvente.',
        color: Color(0xFF4E91B8),
        plutchikIndex: 3,
        plutchikIntensity: 3,
      ),
      _HistoryEmotionDefinition(
        id: 'pensatividade',
        label: 'Pensatividade',
        description: 'Tristeza leve e recolhimento.',
        color: Color(0xFF5D72B4),
        plutchikIndex: 4,
        plutchikIntensity: 1,
      ),
      _HistoryEmotionDefinition(
        id: 'tristeza_plutchik',
        label: 'Tristeza',
        description: 'Perda, retraimento e luto.',
        color: Color(0xFF5D72B4),
        plutchikIndex: 4,
        plutchikIntensity: 2,
      ),
      _HistoryEmotionDefinition(
        id: 'luto',
        label: 'Luto',
        description: 'Tristeza extrema por perda.',
        color: Color(0xFF5D72B4),
        plutchikIndex: 4,
        plutchikIntensity: 3,
      ),
      _HistoryEmotionDefinition(
        id: 'tedio',
        label: 'Tedio',
        description: 'Rejeicao fraca e afastamento passivo.',
        color: Color(0xFF8661A8),
        plutchikIndex: 5,
        plutchikIntensity: 1,
      ),
      _HistoryEmotionDefinition(
        id: 'aversao',
        label: 'Aversao',
        description: 'Rejeicao, nojo e afastamento.',
        color: Color(0xFF8661A8),
        plutchikIndex: 5,
        plutchikIntensity: 2,
      ),
      _HistoryEmotionDefinition(
        id: 'repulsa',
        label: 'Repulsa',
        description: 'Aversao extrema e expulsiva.',
        color: Color(0xFF8661A8),
        plutchikIndex: 5,
        plutchikIntensity: 3,
      ),
      _HistoryEmotionDefinition(
        id: 'irritacao',
        label: 'Irritacao',
        description: 'Raiva leve e incomodo ativo.',
        color: Color(0xFFC85655),
        plutchikIndex: 6,
        plutchikIntensity: 1,
      ),
      _HistoryEmotionDefinition(
        id: 'raiva',
        label: 'Raiva',
        description: 'Confronto, limite e ataque.',
        color: Color(0xFFC85655),
        plutchikIndex: 6,
        plutchikIntensity: 2,
      ),
      _HistoryEmotionDefinition(
        id: 'furia',
        label: 'Furia',
        description: 'Raiva extrema e explosiva.',
        color: Color(0xFFC85655),
        plutchikIndex: 6,
        plutchikIntensity: 3,
      ),
      _HistoryEmotionDefinition(
        id: 'interesse',
        label: 'Interesse',
        description: 'Orientacao leve para o que vem.',
        color: Color(0xFFD8893C),
        plutchikIndex: 7,
        plutchikIntensity: 1,
      ),
      _HistoryEmotionDefinition(
        id: 'antecipacao',
        label: 'Antecipacao',
        description: 'Expectativa, busca e preparacao.',
        color: Color(0xFFD8893C),
        plutchikIndex: 7,
        plutchikIntensity: 2,
      ),
      _HistoryEmotionDefinition(
        id: 'vigilancia',
        label: 'Vigilancia',
        description: 'Antecipacao intensa e sustentada.',
        color: Color(0xFFD8893C),
        plutchikIndex: 7,
        plutchikIntensity: 3,
      ),
    ];
