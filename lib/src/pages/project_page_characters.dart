part of 'project_page.dart';

class _CharactersSection extends StatefulWidget {
  const _CharactersSection();

  static const List<_CharacterCardData> _initialCharacters = <_CharacterCardData>[
    _CharacterCardData(
      name: 'Personagem 1',
      alias: 'Vulgo Personagem 1',
      accent: Color(0xFFE4C2D7),
      avatarColor: Color(0xFFF4B37E),
      icon: Icons.person_rounded,
      birthYear: 2002,
      birthDay: 21,
      birthMonth: 3,
      heightCm: 168,
      weightKg: 58,
      quote: 'Frase de efeito do personagem.',
      synopsis: '',
      seed: 11,
    ),
    _CharacterCardData(
      name: 'Personagem 2',
      alias: 'Vulgo Personagem 2',
      accent: Color(0xFFD9D4E9),
      avatarColor: Color(0xFF7EA7F4),
      icon: Icons.person_rounded,
      birthYear: 1998,
      birthDay: 8,
      birthMonth: 11,
      heightCm: 182,
      weightKg: 74,
      quote: 'Outra frase de efeito do personagem.',
      synopsis: '',
      seed: 23,
    ),
    _CharacterCardData(
      name: 'Personagem 3',
      alias: 'Vulgo Personagem 3',
      accent: Color(0xFFE7E0B7),
      avatarColor: Color(0xFFF4B37E),
      icon: Icons.person_rounded,
      birthYear: 2001,
      birthDay: 19,
      birthMonth: 7,
      heightCm: 175,
      weightKg: 67,
      quote: 'Frase de efeito do personagem.',
      synopsis: '',
      seed: 37,
      initiallyExpanded: true,
    ),
  ];

  @override
  State<_CharactersSection> createState() => _CharactersSectionState();
}

class _CharactersSectionState extends State<_CharactersSection> {
  late List<_CharacterListItem> _characters;

  @override
  void initState() {
    super.initState();
    _characters = _CharactersSection._initialCharacters
        .indexed
        .map(
          (entry) => _CharacterListItem(
            data: entry.$2,
            unpinnedIndex: entry.$1,
          ),
        )
        .toList(growable: true);
  }

  void _togglePinned(_CharacterListItem character) {
    setState(() {
      final currentIndex = _characters.indexOf(character);
      if (currentIndex == -1) return;

      if (!character.isPinned) {
        character.unpinnedIndex = _unpinnedIndexAt(currentIndex);
      }

      _characters.removeAt(currentIndex);
      character.isPinned = !character.isPinned;

      if (character.isPinned) {
        _characters.insert(0, character);
      } else {
        final pinnedCount = _characters.where((item) => item.isPinned).length;
        final unpinnedCount = _characters.length - pinnedCount;
        final targetUnpinnedIndex = character.unpinnedIndex.clamp(0, unpinnedCount) as int;
        _characters.insert(pinnedCount + targetUnpinnedIndex, character);
        _updateUnpinnedSlots();
      }
    });
  }

  int _unpinnedIndexAt(int listIndex) {
    var count = 0;

    for (var index = 0; index < listIndex; index += 1) {
      if (!_characters[index].isPinned) {
        count += 1;
      }
    }

    return count;
  }

  void _updateUnpinnedSlots() {
    var unpinnedIndex = 0;

    for (final character in _characters) {
      if (!character.isPinned) {
        character.unpinnedIndex = unpinnedIndex;
        unpinnedIndex += 1;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 160),
      itemCount: _characters.length,
      itemBuilder: (context, index) {
        final character = _characters[index];
        return _CharacterCard(
          key: ValueKey(character.data.seed),
          data: character.data,
          isPinned: character.isPinned,
          onTogglePinned: () => _togglePinned(character),
        );
      },
    );
  }
}

class _CharacterListItem {
  final _CharacterCardData data;
  bool isPinned;
  int unpinnedIndex;

  _CharacterListItem({
    required this.data,
    this.isPinned = false,
    required this.unpinnedIndex,
  });
}

class _CharacterCardData {
  final String name;
  final String alias;
  final Color accent;
  final Color avatarColor;
  final IconData icon;
  final int birthYear;
  final int birthDay;
  final int birthMonth;
  final double heightCm;
  final double weightKg;
  final String quote;
  final String synopsis;
  final int seed;
  final bool initiallyExpanded;

  const _CharacterCardData({
    required this.name,
    required this.alias,
    required this.accent,
    required this.avatarColor,
    required this.icon,
    required this.birthYear,
    required this.birthDay,
    required this.birthMonth,
    required this.heightCm,
    required this.weightKg,
    required this.quote,
    required this.synopsis,
    required this.seed,
    this.initiallyExpanded = false,
  });
}

enum _CharacterDateType { lastModified, lastAccessed, createdAt }

enum _HeightUnit { centimeters, meters, feetAndInches }

enum _WeightUnit { kilograms, grams, pounds, ounces }

class _CharacterDateEntry {
  final String label;
  final DateTime value;

  const _CharacterDateEntry({
    required this.label,
    required this.value,
  });
}

class _CharacterDateEntries {
  final _CharacterDateEntry lastModified;
  final _CharacterDateEntry lastAccessed;
  final _CharacterDateEntry createdAt;

  const _CharacterDateEntries({
    required this.lastModified,
    required this.lastAccessed,
    required this.createdAt,
  });

  factory _CharacterDateEntries.fromSeed(int seed) {
    final normalizedSeed = seed.abs();
    final now = DateTime.now();
    final createdAt = now.subtract(
      Duration(days: 180 + (normalizedSeed % 250), hours: 3 + (normalizedSeed % 9)),
    );
    final lastModified = now.subtract(
      Duration(days: 1 + (normalizedSeed % 15), hours: 3 + (normalizedSeed % 7)),
    );
    final lastAccessed = now.subtract(
      Duration(hours: 4 + (normalizedSeed % 18), minutes: 8 + (normalizedSeed % 40)),
    );

    return _CharacterDateEntries(
      lastModified: _CharacterDateEntry(
        label: 'Ultima modificacao',
        value: lastModified,
      ),
      lastAccessed: _CharacterDateEntry(
        label: 'Ultimo acesso',
        value: lastAccessed,
      ),
      createdAt: _CharacterDateEntry(
        label: 'Criado em',
        value: createdAt,
      ),
    );
  }

  _CharacterDateEntry forType(_CharacterDateType type) {
    return switch (type) {
      _CharacterDateType.lastModified => lastModified,
      _CharacterDateType.lastAccessed => lastAccessed,
      _CharacterDateType.createdAt => createdAt,
    };
  }
}

class _ZodiacSignData {
  final String name;
  final String symbol;
  final String description;

  const _ZodiacSignData({
    required this.name,
    required this.symbol,
    required this.description,
  });
}

class _CharacterCard extends StatefulWidget {
  final _CharacterCardData data;
  final bool isPinned;
  final VoidCallback onTogglePinned;

  const _CharacterCard({
    super.key,
    required this.data,
    required this.isPinned,
    required this.onTogglePinned,
  });

  @override
  State<_CharacterCard> createState() => _CharacterCardState();
}

class _CharacterCardState extends State<_CharacterCard> with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  late final Animation<double> _fadeAnimation;
  late final ScrollController _synopsisScrollController;
  _CharacterDateEntries? _dateEntries;
  DateTime? _birthdayValue;
  double? _heightCmValue;
  double? _weightKgValue;
  TextEditingController? _heightController;
  TextEditingController? _weightController;
  TextEditingController? _quoteController;
  TextEditingController? _synopsisController;
  bool? _isEditing;
  _CharacterDateType _dateType = _CharacterDateType.lastModified;
  _HeightUnit _heightUnit = _HeightUnit.centimeters;
  _WeightUnit _weightUnit = _WeightUnit.kilograms;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.data.initiallyExpanded;
    _dateEntries = _CharacterDateEntries.fromSeed(widget.data.seed);
    _birthdayValue = DateTime(
      widget.data.birthYear,
      widget.data.birthMonth,
      widget.data.birthDay,
    );
    _heightCmValue = widget.data.heightCm;
    _weightKgValue = widget.data.weightKg;
    _heightController = TextEditingController(
      text: _formatHeightEditorValue(widget.data.heightCm, _heightUnit),
    );
    _weightController = TextEditingController(
      text: _formatWeightEditorValue(widget.data.weightKg, _weightUnit),
    );
    _quoteController = TextEditingController(text: widget.data.quote);
    _synopsisController = TextEditingController(text: widget.data.synopsis);
    _isEditing = false;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      value: _isExpanded ? 1 : 0,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.18, 1, curve: Curves.easeOut),
      reverseCurve: const Interval(0, 0.82, curve: Curves.easeIn),
    );
    _synopsisScrollController = ScrollController();
  }

  @override
  void dispose() {
    _synopsisScrollController.dispose();
    _heightController?.dispose();
    _weightController?.dispose();
    _quoteController?.dispose();
    _synopsisController?.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _openCharacterPage() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _CharacterPlaceholderPage(title: widget.data.name),
      ),
    );
  }

  void _cycleDateType() {
    setState(() {
      _dateType = switch (_dateType) {
        _CharacterDateType.lastModified => _CharacterDateType.lastAccessed,
        _CharacterDateType.lastAccessed => _CharacterDateType.createdAt,
        _CharacterDateType.createdAt => _CharacterDateType.lastModified,
      };
    });
  }

  Future<void> _showSignDescription(Rect anchorRect) async {
    final sign = _signData;
    final descriptionLines = sign.description.split('\n');
    final dateRange = descriptionLines.isNotEmpty ? descriptionLines.first : '';
    final traitsLine = descriptionLines.length > 1 ? descriptionLines.sublist(1).join(' ') : '';
    final traits = traitsLine
        .split(',')
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList(growable: false);

    await _showAnchoredInfoBubble(
      context: context,
      anchorRect: anchorRect,
      width: 232,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${sign.symbol} ${sign.name}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C262C),
            ),
          ),
          if (dateRange.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              dateRange,
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.46),
                fontSize: 11,
                fontStyle: FontStyle.italic,
                letterSpacing: 0.2,
              ),
            ),
          ],
          if (traits.isNotEmpty) ...[
            const SizedBox(height: 9),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final trait in traits) _ZodiacTraitPill(label: trait),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showCharacterAge(Rect anchorRect) async {
    await _showAnchoredInfoBubble(
      context: context,
      anchorRect: anchorRect,
      width: 150,
      child: Text(
        'Idade: ${_calculateAge(_birthday)} anos',
        style: TextStyle(
          color: Colors.black.withValues(alpha: 0.68),
          fontSize: 12,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Future<void> _selectHeightUnit() async {
    final selectedUnit = await showModalBottomSheet<_HeightUnit>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _ProjectBottomSheetFrame(
          title: 'Unidade de medida',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final unit in _HeightUnit.values)
                _HeightUnitOption(
                  label: _heightUnitMenuLabel(unit),
                  isSelected: unit == _heightUnit,
                  onTap: () => Navigator.of(context).pop(unit),
                ),
            ],
          ),
        );
      },
    );

    if (!mounted || selectedUnit == null) {
      return;
    }

    setState(() {
      if (_editing) {
        _commitHeightText(restoreText: false);
      }
      _heightUnit = selectedUnit;
      if (_editing) {
        _heightTextController.text = _formatHeightEditorValue(_heightCm, _heightUnit);
      }
    });
  }

  Future<void> _selectWeightUnit() async {
    final selectedUnit = await showModalBottomSheet<_WeightUnit>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _ProjectBottomSheetFrame(
          title: 'Unidade de peso',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final unit in _WeightUnit.values)
                _HeightUnitOption(
                  label: _weightUnitMenuLabel(unit),
                  isSelected: unit == _weightUnit,
                  onTap: () => Navigator.of(context).pop(unit),
                ),
            ],
          ),
        );
      },
    );

    if (!mounted || selectedUnit == null) {
      return;
    }

    setState(() {
      if (_editing) {
        _commitWeightText(restoreText: false);
      }
      _weightUnit = selectedUnit;
      if (_editing) {
        _weightTextController.text = _formatWeightEditorValue(_weightKg, _weightUnit);
      }
    });
  }

  Future<void> _selectBirthday() async {
    var tempMonth = _birthday.month;
    var tempDay = _birthday.day;
    final monthController = FixedExtentScrollController(initialItem: tempMonth - 1);
    final dayController = FixedExtentScrollController(initialItem: tempDay - 1);

    final selectedDate = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return _ProjectBottomSheetFrame(
              title: 'Aniversario',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 188,
                    child: Row(
                      children: [
                        Expanded(
                          child: _CharacterBirthdayWheel(
                            label: 'Mes',
                            controller: monthController,
                            onSelectedItemChanged: (index) {
                              setModalState(() {
                                tempMonth = index + 1;
                                final maxDay = _daysInMonth(tempMonth);

                                if (tempDay > maxDay) {
                                  tempDay = maxDay;
                                  dayController.jumpToItem(tempDay - 1);
                                }
                              });
                            },
                            children: [
                              for (var index = 0; index < _monthLabels.length; index += 1)
                                Center(
                                  child: Text(
                                    _monthLabels[index],
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
                          child: _CharacterBirthdayWheel(
                            label: 'Dia',
                            controller: dayController,
                            onSelectedItemChanged: (index) {
                              tempDay = index + 1;
                            },
                            children: [
                              for (var day = 1; day <= _daysInMonth(tempMonth); day += 1)
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
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pop(DateTime(_birthday.year, tempMonth, tempDay));
                      },
                      child: const Text('Aplicar'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    monthController.dispose();
    dayController.dispose();

    if (!mounted || selectedDate == null) {
      return;
    }

    setState(() {
      _birthdayValue = selectedDate;
    });
  }

  void _commitHeightText({bool restoreText = true}) {
    final parsedHeight = _parseHeightToCm(_heightTextController.text, _heightUnit);

    if (parsedHeight != null) {
      _heightCmValue = parsedHeight;
    }

    if (restoreText) {
      _heightTextController.text = _formatHeightEditorValue(_heightCm, _heightUnit);
    }
  }

  void _commitWeightText({bool restoreText = true}) {
    final parsedWeight = _parseWeightToKg(_weightTextController.text, _weightUnit);

    if (parsedWeight != null) {
      _weightKgValue = parsedWeight;
    }

    if (restoreText) {
      _weightTextController.text = _formatWeightEditorValue(_weightKg, _weightUnit);
    }
  }

  void _toggleEditing() {
    FocusScope.of(context).unfocus();
    final wasEditing = _editing;

    setState(() {
      if (wasEditing) {
        _commitHeightText();
        _commitWeightText();
      } else {
        _heightTextController.text = _formatHeightEditorValue(_heightCm, _heightUnit);
        _weightTextController.text = _formatWeightEditorValue(_weightKg, _weightUnit);
      }

      _isEditing = !wasEditing;
    });
  }

  TextEditingController get _quoteTextController {
    return _quoteController ??= TextEditingController(text: widget.data.quote);
  }

  TextEditingController get _synopsisTextController {
    return _synopsisController ??= TextEditingController(text: widget.data.synopsis);
  }

  TextEditingController get _heightTextController {
    return _heightController ??= TextEditingController(
      text: _formatHeightEditorValue(_heightCm, _heightUnit),
    );
  }

  TextEditingController get _weightTextController {
    return _weightController ??= TextEditingController(
      text: _formatWeightEditorValue(_weightKg, _weightUnit),
    );
  }

  bool get _editing => _isEditing ?? false;

  DateTime get _birthday => _birthdayValue ??= DateTime(
    widget.data.birthYear,
    widget.data.birthMonth,
    widget.data.birthDay,
  );

  double get _heightCm => _heightCmValue ??= widget.data.heightCm;

  double get _weightKg => _weightKgValue ??= widget.data.weightKg;

  _ZodiacSignData get _signData => _zodiacSignFor(_birthday);

  _CharacterDateEntries get _effectiveDateEntries {
    return _dateEntries ??= _CharacterDateEntries.fromSeed(widget.data.seed);
  }

  _CharacterDateEntry get _currentDateEntry => _effectiveDateEntries.forType(_dateType);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.data.accent.withValues(alpha: 0.46),
                      Colors.white.withValues(alpha: 0.62),
                      const Color(0xFFF4F2F4).withValues(alpha: 0.74),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.68),
                    width: 0.75,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.18),
                                Colors.white.withValues(alpha: 0.03),
                                const Color(0x2AD8AFC2),
                              ],
                              stops: const [0.0, 0.45, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              top: const Radius.circular(16),
                              bottom: Radius.circular(_isExpanded ? 0 : 16),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                widget.data.accent.withValues(alpha: 0.94),
                                Colors.white.withValues(alpha: 0.92),
                                const Color(0xFFF2EED7).withValues(alpha: 0.84),
                              ],
                            ),
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.white.withValues(alpha: 0.22),
                                width: 0.8,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              _CharacterAvatarTile(
                                accent: widget.data.accent,
                                avatarColor: widget.data.avatarColor,
                                icon: widget.data.icon,
                                isExpanded: _isExpanded,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _openCharacterPage,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.data.name,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              fontStyle: FontStyle.italic,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black.withValues(alpha: 0.28),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 1.5),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            widget.data.alias,
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha: 0.86),
                                              fontSize: 11,
                                              fontStyle: FontStyle.italic,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black.withValues(alpha: 0.16),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 1),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: _toggleExpanded,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(8, 8, 10, 8),
                                    child: AnimatedRotation(
                                      turns: _isExpanded ? 0.5 : 0,
                                      duration: const Duration(milliseconds: 220),
                                      curve: Curves.easeOutCubic,
                                      child: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Colors.black.withValues(alpha: 0.48),
                                        size: 26,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ClipRect(
                          child: SizeTransition(
                            sizeFactor: _expandAnimation,
                            axisAlignment: -1,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: _ExpandedCharacterBody(
                                dateEntry: _currentDateEntry,
                                isEditing: _editing,
                                birthdayLabel: _formatBirthdayLabel(_birthday.day, _birthday.month),
                                heightLabel: _formatHeightLabel(_heightCm, _heightUnit),
                                weightLabel: _formatWeightLabel(_weightKg, _weightUnit),
                                heightUnit: _heightUnit,
                                weightUnit: _weightUnit,
                                signData: _signData,
                                synopsisController: _synopsisTextController,
                                synopsisScrollController: _synopsisScrollController,
                                quoteController: _quoteTextController,
                                heightController: _heightTextController,
                                weightController: _weightTextController,
                                onCycleDateType: _cycleDateType,
                                onTapSign: _showSignDescription,
                                onTapAge: _showCharacterAge,
                                onTapBirthday: _selectBirthday,
                                onTapHeightUnit: _selectHeightUnit,
                                onTapWeightUnit: _selectWeightUnit,
                                onCommitHeight: () {
                                  setState(() {
                                    _commitHeightText();
                                  });
                                },
                                onCommitWeight: () {
                                  setState(() {
                                    _commitWeightText();
                                  });
                                },
                                onToggleEditing: _toggleEditing,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: -4,
            top: -4,
            child: _CharacterPinBadge(
              isActive: widget.isPinned,
              onTap: widget.onTogglePinned,
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacterAvatarTile extends StatelessWidget {
  final Color accent;
  final Color avatarColor;
  final IconData icon;
  final bool isExpanded;

  const _CharacterAvatarTile({
    required this.accent,
    required this.avatarColor,
    required this.icon,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78,
      height: 60,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                bottomLeft: Radius.circular(isExpanded ? 0 : 16),
                topRight: const Radius.circular(14),
                bottomRight: const Radius.circular(14),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accent.withValues(alpha: 0.76),
                      avatarColor.withValues(alpha: 0.94),
                      Colors.white.withValues(alpha: 0.2),
                    ],
                    stops: const [0.0, 0.58, 1.0],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.24),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.08),
                            ],
                            stops: const [0.0, 0.38, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: 58,
                        height: 22,
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.26),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    Center(
                      child: Icon(
                        icon,
                        size: 33,
                        color: const Color(0xFF171419),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacterPinBadge extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _CharacterPinBadge({
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOutCubic,
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFFF4EEF3).withValues(alpha: isActive ? 0.9 : 0.78),
                gradient: isActive
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFF6D3E5).withValues(alpha: 0.96),
                          const Color(0xFFF0BEDB).withValues(alpha: 0.9),
                        ],
                      )
                    : null,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.white.withValues(alpha: isActive ? 0.84 : 0.7),
                  width: 0.65,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isActive
                        ? const Color(0xFFDF6EB8).withValues(alpha: 0.26)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: isActive ? 10 : 5,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Center(
                child: AnimatedScale(
                  scale: isActive ? 1.06 : 1,
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOutCubic,
                  child: Transform.rotate(
                    angle: -0.32,
                    child: Icon(
                      isActive ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                      size: isActive ? 16 : 15,
                      color: Color(0xFF8A828C).withValues(alpha: isActive ? 0.98 : 0.56),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpandedCharacterBody extends StatelessWidget {
  final _CharacterDateEntry dateEntry;
  final bool isEditing;
  final String birthdayLabel;
  final String heightLabel;
  final String weightLabel;
  final _HeightUnit heightUnit;
  final _WeightUnit weightUnit;
  final _ZodiacSignData signData;
  final TextEditingController synopsisController;
  final ScrollController synopsisScrollController;
  final TextEditingController quoteController;
  final TextEditingController heightController;
  final TextEditingController weightController;
  final VoidCallback onCycleDateType;
  final ValueChanged<Rect> onTapSign;
  final ValueChanged<Rect> onTapAge;
  final VoidCallback onTapBirthday;
  final VoidCallback onTapHeightUnit;
  final VoidCallback onTapWeightUnit;
  final VoidCallback onCommitHeight;
  final VoidCallback onCommitWeight;
  final VoidCallback onToggleEditing;

  const _ExpandedCharacterBody({
    required this.dateEntry,
    required this.isEditing,
    required this.birthdayLabel,
    required this.heightLabel,
    required this.weightLabel,
    required this.heightUnit,
    required this.weightUnit,
    required this.signData,
    required this.synopsisController,
    required this.synopsisScrollController,
    required this.quoteController,
    required this.heightController,
    required this.weightController,
    required this.onCycleDateType,
    required this.onTapSign,
    required this.onTapAge,
    required this.onTapBirthday,
    required this.onTapHeightUnit,
    required this.onTapWeightUnit,
    required this.onCommitHeight,
    required this.onCommitWeight,
    required this.onToggleEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _CharacterTimeField(
                  dateEntry: dateEntry,
                  onTapClock: onCycleDateType,
                ),
              ),
              const SizedBox(width: 12),
              _MiniGlassButton(
                icon: isEditing ? Icons.check_rounded : Icons.edit_outlined,
                onTap: onToggleEditing,
                radius: 12,
                fillColor: Colors.white.withValues(alpha: 0.34),
              ),
            ],
          ),
          const SizedBox(height: 12),
          EditableSynopsisPanel(
            controller: synopsisController,
            scrollController: synopsisScrollController,
            isEditing: isEditing,
            placeholderText: synopsisPlaceholderText,
            textStyle: const TextStyle(
              color: Color(0xFF171419),
              fontSize: 11,
              height: 1.35,
            ),
            fillColor: Colors.white.withValues(alpha: 0.82),
            placeholderStyle: const TextStyle(
              color: Color(0xFF8F8990),
              fontSize: 11,
              height: 1.35,
              fontStyle: FontStyle.italic,
            ),
            viewerBuilder: (context, text, style) {
              return _CharacterMarkdownText(
                data: text,
                style: style,
              );
            },
          ),
          const SizedBox(height: 12),
          _CharacterQuoteStrip(
            controller: quoteController,
            isEditing: isEditing,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _CharacterBirthdayField(
                  birthdayLabel: birthdayLabel,
                  signData: signData,
                  isEditing: isEditing,
                  onTapAge: onTapAge,
                  onTapBirthday: onTapBirthday,
                  onTapSign: onTapSign,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CharacterHeightField(
                  heightLabel: heightLabel,
                  unitLabel: _heightUnitCompactLabel(heightUnit),
                  controller: heightController,
                  isEditing: isEditing,
                  onTapUnit: onTapHeightUnit,
                  onCommitHeight: onCommitHeight,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CharacterWeightField(
                  weightLabel: weightLabel,
                  unitLabel: _weightUnitCompactLabel(weightUnit),
                  controller: weightController,
                  isEditing: isEditing,
                  onTapUnit: onTapWeightUnit,
                  onCommitWeight: onCommitWeight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              _TagPill(label: 'Tag 1', color: Color(0xFFF4B8D8)),
              SizedBox(width: 8),
              _TagPill(label: 'Tag 2', color: Color(0xFFAEC8F6)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CharacterTimeField extends StatelessWidget {
  final _CharacterDateEntry dateEntry;
  final VoidCallback onTapClock;

  const _CharacterTimeField({
    required this.dateEntry,
    required this.onTapClock,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Stack(
        children: [
          Positioned.fill(
            left: 16,
            child: _SoftGlassContainer(
              radius: 18,
              padding: const EdgeInsets.only(left: 32, right: 12),
              child: Text(
                '${dateEntry.label}: ${_formatDateTime(dateEntry.value)}, ${_formatRelativePhrase(dateEntry.value)}.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.62),
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 2,
            bottom: 2,
            child: _MiniGlassButton(
              diameter: 32,
              icon: Icons.history_rounded,
              onTap: onTapClock,
              fillColor: const Color(0xFFF0BEDB).withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniGlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double diameter;
  final double radius;
  final Color fillColor;

  const _MiniGlassButton({
    required this.icon,
    required this.onTap,
    this.diameter = 34,
    this.radius = 999,
    this.fillColor = const Color(0x6BFFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.68),
              width: 0.8,
            ),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF544959),
            size: diameter * 0.48,
          ),
        ),
      ),
    );
  }
}

class _SoftGlassContainer extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;

  const _SoftGlassContainer({
    required this.child,
    required this.radius,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          alignment: Alignment.centerLeft,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.34),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.68),
              width: 0.8,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  final String label;
  final Color color;

  const _TagPill({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.black.withValues(alpha: 0.38),
          fontSize: 11,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

class _CharacterQuoteStrip extends StatelessWidget {
  final TextEditingController controller;
  final bool isEditing;

  const _CharacterQuoteStrip({
    required this.controller,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(999),
              border: Border(
                right: BorderSide(
                  color: Colors.white.withValues(alpha: 0.52),
                  width: 0.8,
                ),
              ),
            ),
            child: const Icon(
              Icons.chat_bubble_rounded,
              size: 18,
              color: Color(0xFF171419),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: isEditing
                ? TextField(
                    controller: controller,
                    keyboardType: TextInputType.multiline,
                    maxLines: 2,
                    minLines: 1,
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: 'Frase de efeito do personagem',
                      prefixText: '"',
                      suffixText: '"',
                      prefixStyle: TextStyle(
                        color: Colors.black.withValues(alpha: 0.5),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                      suffixStyle: TextStyle(
                        color: Colors.black.withValues(alpha: 0.5),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.5),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : _CharacterMarkdownText(
                    data: '"${controller.text}"',
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.5),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CharacterMetricField extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CharacterMetricField({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.62),
          width: 0.75,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF171419)),
          Container(
            width: 1.3,
            height: 18,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            color: const Color(0xFFDF6EB8),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.68),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacterBirthdayField extends StatelessWidget {
  final String birthdayLabel;
  final _ZodiacSignData signData;
  final bool isEditing;
  final ValueChanged<Rect> onTapAge;
  final VoidCallback onTapBirthday;
  final ValueChanged<Rect> onTapSign;

  const _CharacterBirthdayField({
    required this.birthdayLabel,
    required this.signData,
    required this.isEditing,
    required this.onTapAge,
    required this.onTapBirthday,
    required this.onTapSign,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: isEditing ? onTapBirthday : null,
              child: Container(
                padding: const EdgeInsets.only(left: 12, right: 56),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.42),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.62),
                    width: 0.75,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isEditing ? Icons.edit_calendar_outlined : Icons.cake_outlined,
                      size: 18,
                      color: const Color(0xFF171419),
                    ),
                    Container(
                      width: 1.3,
                      height: 18,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      color: const Color(0xFFDF6EB8),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Builder(
                          builder: (textContext) {
                            return GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: isEditing
                                  ? null
                                  : () => onTapAge(_rectFromContext(textContext)),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    birthdayLabel,
                                    style: TextStyle(
                                      color: Colors.black.withValues(alpha: 0.68),
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  SizedBox(
                                    width: 34,
                                    height: 2,
                                    child: CustomPaint(
                                      painter: _DashedUnderlinePainter(
                                        color: const Color(0xFF8A828C).withValues(alpha: 0.58),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 4,
            top: 4,
            bottom: 4,
            child: _CharacterSignButton(
              signData: signData,
              onTap: onTapSign,
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacterHeightField extends StatelessWidget {
  final String heightLabel;
  final String unitLabel;
  final TextEditingController controller;
  final bool isEditing;
  final VoidCallback onTapUnit;
  final VoidCallback onCommitHeight;

  const _CharacterHeightField({
    required this.heightLabel,
    required this.unitLabel,
    required this.controller,
    required this.isEditing,
    required this.onTapUnit,
    required this.onCommitHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: Stack(
        children: [
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: Ink(
                padding: const EdgeInsets.only(left: 12, right: 74),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.42),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.62),
                    width: 0.75,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.straighten_rounded,
                      size: 18,
                      color: Color(0xFF171419),
                    ),
                    Container(
                      width: 1.3,
                      height: 18,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      color: const Color(0xFFDF6EB8),
                    ),
                    Expanded(
                      child: isEditing
                          ? TextField(
                              controller: controller,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => onCommitHeight(),
                              onTapOutside: (_) {
                                FocusScope.of(context).unfocus();
                                onCommitHeight();
                              },
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: 'Altura',
                              ),
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.68),
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                            )
                          : Text(
                              heightLabel,
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.68),
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 4,
            top: 4,
            bottom: 4,
            child: _CharacterUnitButton(
              label: unitLabel,
              onTap: onTapUnit,
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacterWeightField extends StatelessWidget {
  final String weightLabel;
  final String unitLabel;
  final TextEditingController controller;
  final bool isEditing;
  final VoidCallback onTapUnit;
  final VoidCallback onCommitWeight;

  const _CharacterWeightField({
    required this.weightLabel,
    required this.unitLabel,
    required this.controller,
    required this.isEditing,
    required this.onTapUnit,
    required this.onCommitWeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: Stack(
        children: [
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: Ink(
                padding: const EdgeInsets.only(left: 12, right: 54),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.42),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.62),
                    width: 0.75,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.balance_outlined,
                      size: 18,
                      color: Color(0xFF171419),
                    ),
                    Container(
                      width: 1.3,
                      height: 18,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      color: const Color(0xFFDF6EB8),
                    ),
                    Expanded(
                      child: isEditing
                          ? TextField(
                              controller: controller,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => onCommitWeight(),
                              onTapOutside: (_) {
                                FocusScope.of(context).unfocus();
                                onCommitWeight();
                              },
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: 'Peso',
                              ),
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.68),
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                            )
                          : Text(
                              weightLabel,
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.68),
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 4,
            top: 4,
            bottom: 4,
            child: _CharacterUnitButton(
              label: unitLabel,
              onTap: onTapUnit,
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacterSignButton extends StatelessWidget {
  final _ZodiacSignData signData;
  final ValueChanged<Rect> onTap;

  const _CharacterSignButton({
    required this.signData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (buttonContext) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onTap(_rectFromContext(buttonContext)),
            borderRadius: BorderRadius.circular(999),
            child: Ink(
              width: 52,
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFFF3D7E6).withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.82),
                  width: 0.75,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    signData.symbol,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 0.9,
                      color: Color(0xFF544959),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        signData.name,
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.48),
                          fontSize: 7.1,
                          height: 0.9,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ZodiacTraitPill extends StatelessWidget {
  final String label;

  const _ZodiacTraitPill({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF4EEF3).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.82),
          width: 0.7,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.black.withValues(alpha: 0.6),
            fontSize: 10.5,
            fontStyle: FontStyle.italic,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _CharacterUnitButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CharacterUnitButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFF0E2EA).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.82),
              width: 0.75,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Unidade',
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.42),
                  fontSize: 7.6,
                  height: 0.9,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.42),
                      fontSize: 8.8,
                      height: 0.9,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Icon(
                    Icons.expand_more_rounded,
                    size: 12,
                    color: Colors.black.withValues(alpha: 0.38),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeightUnitOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _HeightUnitOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.42),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C262C),
                    ),
                  ),
                ),
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: isSelected ? const Color(0xFFDF6EB8) : const Color(0xFF544959),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CharacterBirthdayWheel extends StatelessWidget {
  final String label;
  final FixedExtentScrollController controller;
  final ValueChanged<int> onSelectedItemChanged;
  final List<Widget> children;

  const _CharacterBirthdayWheel({
    required this.label,
    required this.controller,
    required this.onSelectedItemChanged,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.5),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.32),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.58),
                    width: 0.8,
                  ),
                ),
                child: CupertinoTheme(
                  data: const CupertinoThemeData(
                    brightness: Brightness.light,
                  ),
                  child: CupertinoPicker(
                    scrollController: controller,
                    itemExtent: 36,
                    diameterRatio: 1.25,
                    useMagnifier: true,
                    magnification: 1.06,
                    selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
                      background: const Color(0x1CFFFFFF),
                    ),
                    onSelectedItemChanged: onSelectedItemChanged,
                    children: children,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CharacterMarkdownText extends StatelessWidget {
  final String data;
  final TextStyle style;

  const _CharacterMarkdownText({
    required this.data,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final sanitizedData = _sanitizeCharacterMarkdown(data);
    final normalizedData = sanitizedData.trim().isEmpty ? ' ' : sanitizedData;
    final styleSheet = MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: style,
      pPadding: EdgeInsets.zero,
      blockSpacing: 0,
      listIndent: 18,
      listBullet: style,
      listBulletPadding: const EdgeInsets.only(right: 6),
      strong: style.copyWith(
        fontWeight: FontWeight.w700,
        fontStyle: style.fontStyle,
      ),
      em: style.copyWith(fontStyle: FontStyle.italic),
      code: style.copyWith(
        fontFamily: 'monospace',
        backgroundColor: Colors.transparent,
      ),
      blockquote: style,
      blockquotePadding: EdgeInsets.zero,
      blockquoteDecoration: const BoxDecoration(),
    );

    return MarkdownBody(
      data: normalizedData,
      shrinkWrap: true,
      softLineBreak: true,
      styleSheet: styleSheet,
    );
  }
}

String _sanitizeCharacterMarkdown(String data) {
  final withoutHtml = data.replaceAll(RegExp(r'<[^>]*>'), '');
  final rawLines = withoutHtml.split('\n');
  final sanitizedLines = <String>[];
  final atxHeadingPattern = RegExp(r'^\s{0,3}#{1,6}\s*');
  final setextHeadingPattern = RegExp(r'^\s{0,3}(=+|-+)\s*$');

  for (final line in rawLines) {
    final normalizedLine = line.replaceFirst(atxHeadingPattern, '');

    if (setextHeadingPattern.hasMatch(normalizedLine) &&
        sanitizedLines.isNotEmpty &&
        sanitizedLines.last.trim().isNotEmpty) {
      continue;
    }

    sanitizedLines.add(normalizedLine);
  }

  return sanitizedLines.join('\n');
}

String _formatBirthdayLabel(int day, int month) {
  final dayLabel = day.toString().padLeft(2, '0');
  final monthLabel = month.toString().padLeft(2, '0');
  return '$dayLabel/$monthLabel';
}

int _calculateAge(DateTime birthday) {
  final now = DateTime.now();
  var age = now.year - birthday.year;
  final hadBirthdayThisYear =
      now.month > birthday.month ||
      (now.month == birthday.month && now.day >= birthday.day);

  if (!hadBirthdayThisYear) {
    age -= 1;
  }

  return age;
}

const List<String> _monthLabels = <String>[
  'Jan',
  'Fev',
  'Mar',
  'Abr',
  'Mai',
  'Jun',
  'Jul',
  'Ago',
  'Set',
  'Out',
  'Nov',
  'Dez',
];

int _daysInMonth(int month) {
  return DateTime(2000, month + 1, 0).day;
}

Rect _rectFromContext(BuildContext context) {
  final box = context.findRenderObject() as RenderBox;
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  final offset = box.localToGlobal(Offset.zero, ancestor: overlay);
  return offset & box.size;
}

Future<void> _showAnchoredInfoBubble({
  required BuildContext context,
  required Rect anchorRect,
  required Widget child,
  double width = 180,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierLabel: 'Info',
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 140),
    pageBuilder: (context, animation, secondaryAnimation) {
      final screenSize = MediaQuery.of(context).size;
      const horizontalPadding = 12.0;
      const arrowSize = 12.0;
      const verticalGap = 8.0;
      const estimatedHeight = 110.0;
      final left = (anchorRect.center.dx - (width / 2))
          .clamp(
            horizontalPadding,
            screenSize.width - width - horizontalPadding,
          )
          .toDouble();
      final showAbove = anchorRect.bottom + estimatedHeight > screenSize.height - 24;
      final top = (showAbove
              ? anchorRect.top - estimatedHeight - arrowSize - verticalGap
              : anchorRect.bottom + verticalGap)
          .clamp(12.0, screenSize.height - estimatedHeight - 12.0)
          .toDouble();
      final pointerLeft = (anchorRect.center.dx - left - (arrowSize / 2))
          .clamp(
            18.0,
            width - 18.0,
          )
          .toDouble();

      return Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => Navigator.of(context).pop(),
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              left: left,
              top: top,
              width: width,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 140),
                tween: Tween<double>(begin: 0.96, end: 1),
                builder: (context, scale, dialogChild) {
                  return Transform.scale(
                    scale: scale,
                    alignment: showAbove ? Alignment.bottomCenter : Alignment.topCenter,
                    child: dialogChild,
                  );
                },
                child: _AnchoredInfoBubble(
                  showAbove: showAbove,
                  pointerLeft: pointerLeft,
                  arrowSize: arrowSize,
                  child: child,
                ),
              ),
            ),
          ],
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

class _AnchoredInfoBubble extends StatelessWidget {
  final bool showAbove;
  final double pointerLeft;
  final double arrowSize;
  final Widget child;

  const _AnchoredInfoBubble({
    required this.showAbove,
    required this.pointerLeft,
    required this.arrowSize,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bubble = ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.86),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    final arrow = Positioned(
      left: pointerLeft,
      top: showAbove ? null : 0,
      bottom: showAbove ? 0 : null,
      child: CustomPaint(
        size: Size(arrowSize, arrowSize),
        painter: _BubbleArrowPainter(
          color: Colors.white.withValues(alpha: 0.9),
          pointUp: !showAbove,
        ),
      ),
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: showAbove
              ? EdgeInsets.only(bottom: arrowSize - 1)
              : EdgeInsets.only(top: arrowSize - 1),
          child: bubble,
        ),
        arrow,
      ],
    );
  }
}

class _BubbleArrowPainter extends CustomPainter {
  final Color color;
  final bool pointUp;

  const _BubbleArrowPainter({
    required this.color,
    required this.pointUp,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();

    if (pointUp) {
      path
        ..moveTo(size.width / 2, 0)
        ..lineTo(0, size.height)
        ..lineTo(size.width, size.height)
        ..close();
    } else {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height)
        ..close();
    }

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _BubbleArrowPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.pointUp != pointUp;
  }
}

class _DashedUnderlinePainter extends CustomPainter {
  final Color color;

  const _DashedUnderlinePainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 4.0;
    const dashGap = 2.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    var startX = 0.0;
    final y = size.height / 2;

    while (startX < size.width) {
      final endX = (startX + dashWidth).clamp(0.0, size.width);
      canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
      startX += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedUnderlinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

String _formatHeightEditorValue(double heightCm, _HeightUnit unit) {
  switch (unit) {
    case _HeightUnit.centimeters:
      return heightCm.toStringAsFixed(0);
    case _HeightUnit.meters:
      return (heightCm / 100).toStringAsFixed(2);
    case _HeightUnit.feetAndInches:
      return _formatFeetAndInches(heightCm);
  }
}

double? _parseHeightToCm(String rawValue, _HeightUnit unit) {
  switch (unit) {
    case _HeightUnit.centimeters:
      final normalized = rawValue.replaceAll(',', '.').trim();
      final parsed = double.tryParse(normalized);

      if (parsed == null || parsed <= 0) {
        return null;
      }

      return parsed;
    case _HeightUnit.meters:
      final normalized = rawValue.replaceAll(',', '.').trim();
      final parsed = double.tryParse(normalized);

      if (parsed == null || parsed <= 0) {
        return null;
      }

      return parsed * 100;
    case _HeightUnit.feetAndInches:
      return _parseFeetAndInchesToCm(rawValue);
  }
}

String _formatWeightEditorValue(double weightKg, _WeightUnit unit) {
  switch (unit) {
    case _WeightUnit.kilograms:
      return _formatCompactDecimal(weightKg);
    case _WeightUnit.grams:
      return _formatCompactDecimal(weightKg * 1000);
    case _WeightUnit.pounds:
      return _formatCompactDecimal(weightKg * 2.2046226218);
    case _WeightUnit.ounces:
      return _formatCompactDecimal(weightKg * 35.27396195);
  }
}

double? _parseWeightToKg(String rawValue, _WeightUnit unit) {
  final normalized = rawValue.replaceAll(',', '.').trim();
  final parsed = double.tryParse(normalized);

  if (parsed == null || parsed <= 0) {
    return null;
  }

  return switch (unit) {
    _WeightUnit.kilograms => parsed,
    _WeightUnit.grams => parsed / 1000,
    _WeightUnit.pounds => parsed / 2.2046226218,
    _WeightUnit.ounces => parsed / 35.27396195,
  };
}

String _formatHeightLabel(double heightCm, _HeightUnit unit) {
  return _formatHeightEditorValue(heightCm, unit);
}

String _formatWeightLabel(double weightKg, _WeightUnit unit) {
  return _formatWeightEditorValue(weightKg, unit);
}

String _formatFeetAndInches(double heightCm) {
  final totalInches = heightCm / 2.54;
  var feet = (totalInches / 12).floor();
  var inches = (totalInches - (feet * 12)).round();

  if (inches == 12) {
    feet += 1;
    inches = 0;
  }

  return "$feet'${inches.toString().padLeft(2, '0')}\"";
}

double? _parseFeetAndInchesToCm(String rawValue) {
  final normalized = rawValue.trim().toLowerCase();

  if (normalized.isEmpty) {
    return null;
  }

  final primaryPattern = RegExp(
    r"""^\s*(\d+)\s*(?:'|ft)\s*(\d{1,2})?\s*(?:"|in)?\s*$""",
  );
  final primaryMatch = primaryPattern.firstMatch(normalized);

  if (primaryMatch != null) {
    final feet = int.tryParse(primaryMatch.group(1)!);
    final inches = int.tryParse(primaryMatch.group(2) ?? '0');

    if (feet == null || inches == null || inches >= 12) {
      return null;
    }

    return ((feet * 12) + inches) * 2.54;
  }

  final spacedPattern = RegExp(r'^\s*(\d+)\s+(\d{1,2})\s*$');
  final spacedMatch = spacedPattern.firstMatch(normalized);

  if (spacedMatch != null) {
    final feet = int.tryParse(spacedMatch.group(1)!);
    final inches = int.tryParse(spacedMatch.group(2)!);

    if (feet == null || inches == null || inches >= 12) {
      return null;
    }

    return ((feet * 12) + inches) * 2.54;
  }

  final plainNumber = double.tryParse(normalized.replaceAll(',', '.'));

  if (plainNumber == null || plainNumber <= 0) {
    return null;
  }

  if (plainNumber <= 9) {
    return plainNumber * 30.48;
  }

  return plainNumber * 2.54;
}

String _formatCompactDecimal(double value) {
  final hasFraction = value != value.roundToDouble();
  return hasFraction ? value.toStringAsFixed(1) : value.toStringAsFixed(0);
}

String _heightUnitCompactLabel(_HeightUnit unit) {
  return switch (unit) {
    _HeightUnit.centimeters => 'cm',
    _HeightUnit.meters => 'm',
    _HeightUnit.feetAndInches => 'ft/in',
  };
}

String _heightUnitMenuLabel(_HeightUnit unit) {
  return switch (unit) {
    _HeightUnit.centimeters => 'Centimetros (cm)',
    _HeightUnit.meters => 'Metros (m)',
    _HeightUnit.feetAndInches => 'Pes e polegadas (ft/in)',
  };
}

String _weightUnitCompactLabel(_WeightUnit unit) {
  return switch (unit) {
    _WeightUnit.kilograms => 'kg',
    _WeightUnit.grams => 'g',
    _WeightUnit.pounds => 'lb',
    _WeightUnit.ounces => 'oz',
  };
}

String _weightUnitMenuLabel(_WeightUnit unit) {
  return switch (unit) {
    _WeightUnit.kilograms => 'Quilogramas (kg)',
    _WeightUnit.grams => 'Gramas (g)',
    _WeightUnit.pounds => 'Libras (lb)',
    _WeightUnit.ounces => 'Oncas (oz)',
  };
}

String _formatDateTime(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = value.year.toString().padLeft(4, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');

  return '$day/$month/$year $hour:$minute';
}

String _formatRelativePhrase(DateTime value) {
  final difference = DateTime.now().difference(value);

  if (difference.inMinutes < 1) return 'ha menos de 1 minuto';
  if (difference.inMinutes < 60) {
    return 'ha ${_pluralizeCount(difference.inMinutes, 'minuto', 'minutos')}';
  }
  if (difference.inHours < 24) {
    return 'ha ${_pluralizeCount(difference.inHours, 'hora', 'horas')}';
  }
  if (difference.inDays < 7) {
    return 'ha ${_pluralizeCount(difference.inDays, 'dia', 'dias')}';
  }
  if (difference.inDays < 30) {
    return 'ha ${_pluralizeCount((difference.inDays / 7).floor(), 'semana', 'semanas')}';
  }
  if (difference.inDays < 365) {
    return 'ha ${_pluralizeCount((difference.inDays / 30).floor(), 'mes', 'meses')}';
  }
  return 'ha ${_pluralizeCount((difference.inDays / 365).floor(), 'ano', 'anos')}';
}

String _pluralizeCount(int value, String singular, String plural) {
  final normalizedValue = value < 1 ? 1 : value;
  return normalizedValue == 1 ? '1 $singular' : '$normalizedValue $plural';
}

_ZodiacSignData _zodiacSignFor(DateTime birthday) {
  final month = birthday.month;
  final day = birthday.day;

  if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) {
    return const _ZodiacSignData(
      name: 'Áries',
      symbol: '\u2648',
      description: '21/03 - 20/04\niniciativa, impulsividade, assertividade, competitividade, ação direta.',
    );
  }
  if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) {
    return const _ZodiacSignData(
      name: 'Touro',
      symbol: '\u2649',
      description:
          '21/04 - 20/05\nestabilidade, persistência, apego material, sensorialidade, resistência à mudança.',
    );
  }
  if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) {
    return const _ZodiacSignData(
      name: 'Gêmeos',
      symbol: '\u264A',
      description:
          '21/05 - 20/06\ncuriosidade, versatilidade, comunicação rápida, dispersão, adaptação constante.',
    );
  }
  if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) {
    return const _ZodiacSignData(
      name: 'Câncer',
      symbol: '\u264B',
      description:
          '21/06 - 22/07\nemotividade, proteção, apego ao passado, sensibilidade, vínculo familiar.',
    );
  }
  if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) {
    return const _ZodiacSignData(
      name: 'Leão',
      symbol: '\u264C',
      description:
          '23/07 - 22/08\nautoexpressão, orgulho, liderança, necessidade de reconhecimento, teatralidade.',
    );
  }
  if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) {
    return const _ZodiacSignData(
      name: 'Virgem',
      symbol: '\u264D',
      description:
          '23/08 - 22/09\nanálise, precisão, utilidade, crítica, foco em melhoria contínua.',
    );
  }
  if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) {
    return const _ZodiacSignData(
      name: 'Libra',
      symbol: '\u264E',
      description:
          '23/09 - 22/10\nequilíbrio, mediação, estética, sociabilidade, indecisão estratégica.',
    );
  }
  if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) {
    return const _ZodiacSignData(
      name: 'Escorpião',
      symbol: '\u264F',
      description:
          '23/10 - 21/11\nintensidade, controle, profundidade emocional, transformação, sigilo.',
    );
  }
  if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) {
    return const _ZodiacSignData(
      name: 'Sagitário',
      symbol: '\u2650',
      description:
          '22/11 - 21/12\nexpansão, idealismo, franqueza, busca por sentido, inquietação.',
    );
  }
  if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) {
    return const _ZodiacSignData(
      name: 'Capricórnio',
      symbol: '\u2651',
      description:
          '22/12 - 20/01\ndisciplina, responsabilidade, ambição estrutural, pragmatismo, contenção emocional.',
    );
  }
  if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) {
    return const _ZodiacSignData(
      name: 'Aquário',
      symbol: '\u2652',
      description:
          '21/01 - 18/02\ninovação, ruptura de padrões, pensamento coletivo, desapego, excentricidade funcional.',
    );
  }
  return const _ZodiacSignData(
    name: 'Peixes',
    symbol: '\u2653',
    description:
        '19/02 - 20/03\nimaginação, empatia, dissolução de limites, escapismo, sensibilidade difusa.',
  );
}

class _CharacterPlaceholderPage extends StatelessWidget {
  final String title;

  const _CharacterPlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/FUNDO.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderCircleButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF2C262C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pagina interna do personagem em construcao.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black.withValues(alpha: 0.58),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
