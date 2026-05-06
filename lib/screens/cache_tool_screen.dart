// ===== FILE: lib/screens/cache_tool_screen.dart =====
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/cache_state.dart';

class CacheToolScreen extends StatefulWidget {
  const CacheToolScreen({super.key});

  @override
  State<CacheToolScreen> createState() => _CacheToolScreenState();
}

class _CacheToolScreenState extends State<CacheToolScreen> {
  final TextEditingController _addressController = TextEditingController(text: '0,4,8,4,0,12,8');
  late CacheState _cacheState;
  CacheMapping _mapping = CacheMapping.directMapped;
  List<int> _accessHistory = [];
  List<String> _hitMissHistory = [];
  int _currentAccessIndex = -1;
  String _narratorText = 'Enter memory addresses and tap Simulate All to see how cache works.';

  static const List<String> _mappingExplanations = [
    'Direct-Mapped: Each address goes to exactly one slot. Simple but inflexible.',
    '2-Way Set-Associative: Each address can go to one of 2 slots. Better hit rate.',
    '4-Way Set-Associative: Each address can go to one of 4 slots. Best hit rate, most complex.',
  ];

  @override
  void initState() {
    super.initState();
    _updateMapping();
  }

  void _updateMapping() {
    setState(() {
      _cacheState = CacheState(
        sets: 4,
        ways: _mapping.ways,
        blockSize: 1,
      );
    });
  }

  void _setMapping(CacheMapping mapping) {
    setState(() {
      _mapping = mapping;
      _cacheState = CacheState(
        sets: 4,
        ways: mapping.ways,
        blockSize: 1,
      );
      _accessHistory = [];
      _hitMissHistory = [];
      _currentAccessIndex = -1;
      _narratorText = _mappingExplanations[mapping.index];
    });
  }

  void _simulateAll() {
    final addresses = _addressController.text
        .split(',')
        .map((s) => int.tryParse(s.trim()))
        .whereType<int>()
        .toList();
    
    _cacheState.reset();
    _accessHistory.clear();
    _hitMissHistory.clear();
    
    for (final addr in addresses) {
      _cacheState.access(addr);
      _accessHistory.add(addr);
      _hitMissHistory.add(_cacheState.lastResult);
    }
    
    final lastAddr = addresses.last;
    setState(() {
      _currentAccessIndex = _accessHistory.length - 1;
      if (_hitMissHistory.last.contains('HIT')) {
        _narratorText = 'Found it! Address $lastAddr was already in cache. No need to go to RAM — saved time!';
      } else {
        _narratorText = 'Not in cache. We had to fetch it from RAM.';
      }
    });
  }

  void _stepThroughHistory(int index) {
    _cacheState.reset();
    for (int i = 0; i <= index; i++) {
      _cacheState.access(_accessHistory[i]);
    }
    setState(() {
      _currentAccessIndex = index;
      if (_hitMissHistory[index].contains('HIT')) {
        _narratorText = 'Found it! Address ${_accessHistory[index]} was already in cache. No need to go to RAM.';
      } else if (_hitMissHistory[index].contains('EVICT')) {
        _narratorText = 'Cache is full! We need to remove an old entry to make room for the new one.';
      } else {
        _narratorText = 'Not in cache. We had to fetch it from RAM and store it in cache.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cache Memory Tool'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNarratorPanel(),
            const SizedBox(height: 16),
            _buildMappingSelector(),
            const SizedBox(height: 16),
            _buildAddressInput(),
            const SizedBox(height: 16),
            _buildCacheVisualization(),
            const SizedBox(height: 16),
            _buildHitMissHistory(),
            const SizedBox(height: 16),
            _buildHitRate(),
            const SizedBox(height: 16),
            _buildLRUVisualization(),
            const SizedBox(height: 16),
            _buildColorLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildNarratorPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2035),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF59E0B), width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb, color: Color(0xFFF59E0B), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What\'s happening?',
                  style: GoogleFonts.rajdhani(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _narratorText,
                  style: GoogleFonts.rajdhani(
                    fontSize: 15,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMappingSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.panelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cache Mapping',
            style: GoogleFonts.rajdhani(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<CacheMapping>(
            segments: CacheMapping.values
                .map((m) => ButtonSegment(
                      value: m,
                      label: Text(m.name, style: const TextStyle(fontSize: 11)),
                    ))
                .toList(),
            selected: {_mapping},
            onSelectionChanged: (set) => _setMapping(set.first),
          ),
          const SizedBox(height: 8),
          Text(
            _mappingExplanations[_mapping.index],
            style: GoogleFonts.rajdhani(
              fontSize: 12,
              color: AppTheme.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressInput() {
    final addresses = _addressController.text.split(',').where((s) => s.trim().isNotEmpty).toList();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.panelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pin_drop, color: AppTheme.accentCyan, size: 20),
              const SizedBox(width: 8),
              Text(
                'Memory Addresses',
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Enter addresses (0-15) separated by commas',
            style: GoogleFonts.rajdhani(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addressController,
            style: GoogleFonts.jetBrainsMono(fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'e.g., 0,4,8,4,0,12,8',
            ),
          ),
          if (addresses.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  final addr = addresses[index].trim();
                  final isCurrent = index == _currentAccessIndex && _currentAccessIndex >= 0;
                  return GestureDetector(
                    onTap: () => _stepThroughHistory(index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isCurrent 
                            ? AppTheme.accentAmber.withOpacity(0.3) 
                            : AppTheme.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCurrent ? AppTheme.accentAmber : AppTheme.borderColor,
                          width: isCurrent ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Addr $addr',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            color: isCurrent ? AppTheme.accentAmber : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ).animate(target: addresses.isNotEmpty ? 1 : 0).fadeIn(),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _simulateAll,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Simulate All'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCacheVisualization() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.panelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cache State',
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              if (_accessHistory.isNotEmpty)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, size: 20),
                      onPressed: _currentAccessIndex > 0
                          ? () => _stepThroughHistory(_currentAccessIndex - 1)
                          : null,
                      color: AppTheme.textSecondary,
                    ),
                    Text(
                      '${_currentAccessIndex + 1}/${_accessHistory.length}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward, size: 20),
                      onPressed: _currentAccessIndex < _accessHistory.length - 1
                          ? () => _stepThroughHistory(_currentAccessIndex + 1)
                          : null,
                      color: AppTheme.textSecondary,
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(_cacheState.sets, (setIndex) {
            return _buildCacheSetGrid(setIndex);
          }),
        ],
      ),
    );
  }

  Widget _buildCacheSetGrid(int setIndex) {
    final set = _cacheState.cache[setIndex];
    final slotLetter = String.fromCharCode(65 + setIndex);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cache Slot $slotLetter',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: List.generate(_mapping.ways, (wayIndex) {
              final line = set[wayIndex];
              final slotNum = wayIndex + 1;
              final slotName = '$slotLetter$slotNum';
              final isLastUsed = line.lastUsed == _cacheState.totalAccesses &&
                  _cacheState.totalAccesses > 0;
              final isCurrentAccess = _currentAccessIndex >= 0 && 
                  _cacheState.getTag(_accessHistory[_currentAccessIndex]) == line.tag;
              
              Color borderColor = AppTheme.borderColor;
              Color bgColor = AppTheme.surface;
              String emoji = line.valid ? '📦' : '⬜';
              String statusText = '';
              
              if (isLastUsed) {
                borderColor = AppTheme.accentAmber;
                bgColor = AppTheme.accentAmber.withOpacity(0.1);
                emoji = '🗑️';
                statusText = 'Evict next';
              } else if (isCurrentAccess) {
                borderColor = AppTheme.accentGreen;
                bgColor = AppTheme.accentGreen.withOpacity(0.1);
                emoji = '✨';
                statusText = 'Just accessed';
              } else if (line.valid) {
                borderColor = AppTheme.accentCyan;
              }
              
              return Expanded(
                child: GestureDetector(
                  onTap: () => _showCacheSlotBottomSheet(slotName, line, setIndex, wayIndex),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: borderColor, width: 2),
                    ),
                    child: Column(
                      children: [
                        Text(
                          slotName,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: borderColor,
                          ),
                        ),
                        if (line.valid) ...[
                          Text(
                            'Addr ${line.tag}',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              color: AppTheme.accentCyan,
                            ),
                          ),
                        ] else ...[
                          Text(
                            'Empty',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                        if (statusText.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: borderColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 10),
                            ),
                          )
                        else
                          Text(
                            emoji,
                            style: const TextStyle(fontSize: 10),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _showCacheSlotBottomSheet(String slotName, CacheLine line, int setIndex, int wayIndex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cache Slot $slotName',
              style: GoogleFonts.rajdhani(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentCyan,
              ),
            ),
            const SizedBox(height: 8),
            if (line.valid) ...[
              Text(
                'Holds memory address ${line.tag}',
                style: GoogleFonts.rajdhani(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'This is like having a specific bookmark in your notebook. When you need this address, the CPU checks here first instead of going to slow RAM.',
                style: GoogleFonts.rajdhani(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ] else ...[
              Text(
                'This slot is empty and waiting for data.',
                style: GoogleFonts.rajdhani(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
    return const SizedBox.shrink();
  }

  Widget _buildHitMissHistory() {
    if (_hitMissHistory.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.panelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hit/Miss History',
            style: GoogleFonts.rajdhani(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_accessHistory.length, (i) {
                final result = _hitMissHistory[i];
                final isHit = result.contains('HIT');
                final addr = _accessHistory[i];
                final isCurrent = i == _currentAccessIndex;
                
                return GestureDetector(
                  onTap: () => _stepThroughHistory(i),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isCurrent 
                          ? (isHit ? AppTheme.accentGreen : AppTheme.accentRed).withOpacity(0.2)
                          : AppTheme.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCurrent 
                            ? (isHit ? AppTheme.accentGreen : AppTheme.accentRed)
                            : AppTheme.borderColor,
                        width: isCurrent ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$addr',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          isHit ? 'HIT' : 'MISS',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isHit ? AppTheme.accentGreen : AppTheme.accentRed,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHitRate() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glowGreen,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hit Rate',
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                '${_cacheState.hits} hits / ${_cacheState.misses} misses',
                style: GoogleFonts.rajdhani(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: _cacheState.hitRate,
                  strokeWidth: 6,
                  backgroundColor: AppTheme.background,
                  valueColor: AlwaysStoppedAnimation(AppTheme.accentGreen),
                ),
              ),
              Text(
                _cacheState.hitRateString,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLRUVisualization() {
    if (_cacheState.totalAccesses == 0 || _mapping == CacheMapping.directMapped) {
      return const SizedBox.shrink();
    }
    
    final lruOrder = <int>[];
    for (int setIdx = 0; setIdx < _cacheState.sets; setIdx++) {
      final set = _cacheState.cache[setIdx];
      final sortedWays = List.generate(set.length, (i) => i)
        ..sort((a, b) => set[a].lastUsed.compareTo(set[b].lastUsed));
      lruOrder.addAll(sortedWays);
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.panelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.replay, color: AppTheme.accentAmber, size: 20),
              const SizedBox(width: 8),
              Text(
                'LRU Order (Least Recently Used)',
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'When cache is full, the entry used LONGEST AGO will be removed first to make room for new data.',
            style: GoogleFonts.rajdhani(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _buildLRUQueue(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLRUQueue() {
    final widgets = <Widget>[];
    final uniqueTags = <int>{};
    
    for (final addr in _accessHistory.reversed) {
      final tag = _cacheState.getTag(addr);
      if (!uniqueTags.contains(tag)) {
        uniqueTags.add(tag);
        final isEvictCandidate = uniqueTags.length > _mapping.ways;
        
        widgets.add(Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isEvictCandidate 
                ? AppTheme.accentAmber.withOpacity(0.2) 
                : AppTheme.accentCyan.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isEvictCandidate ? AppTheme.accentAmber : AppTheme.accentCyan,
            ),
          ),
          child: Text(
            'Addr $addr',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              color: isEvictCandidate ? AppTheme.accentAmber : AppTheme.textPrimary,
            ),
          ),
        ));
        
        if (widgets.length >= _mapping.ways) break;
      }
    }
    
    return widgets;
  }

  Widget _buildColorLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.panelDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem('Green', 'HIT', AppTheme.accentGreen),
          _buildLegendItem('Red', 'MISS', AppTheme.accentRed),
          _buildLegendItem('Amber', 'Evict', AppTheme.accentAmber),
          _buildLegendItem('Cyan', 'Filled', AppTheme.accentCyan),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String color, String meaning, Color actualColor) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: actualColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          meaning,
          style: GoogleFonts.rajdhani(
            fontSize: 10,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  void _showInfoDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cache Memory',
              style: GoogleFonts.rajdhani(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentCyan,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoItem('Direct-Mapped', 'Each memory address maps to exactly one cache line'),
            _buildInfoItem('2-Way Set-Associative', 'Each set has 2 lines - more flexible, better hit rate'),
            _buildInfoItem('4-Way Set-Associative', 'Each set has 4 lines - even more flexible'),
            _buildInfoItem('LRU', 'Least Recently Used replacement - evicts oldest accessed block'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: AppTheme.accentCyan,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.rajdhani(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  desc,
                  style: GoogleFonts.rajdhani(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
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