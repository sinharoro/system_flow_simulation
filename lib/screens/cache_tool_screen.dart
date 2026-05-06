import 'package:flutter/material.dart';
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
  int _currentAccessIndex = -1;

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
      _currentAccessIndex = -1;
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
    
    for (final addr in addresses) {
      _cacheState.access(addr);
      _accessHistory.add(addr);
    }
    
    setState(() {
      _currentAccessIndex = _accessHistory.length - 1;
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
            _buildMappingSelector(),
            const SizedBox(height: 16),
            _buildAddressInput(),
            const SizedBox(height: 16),
            _buildCacheVisualization(),
            const SizedBox(height: 16),
            _buildHitRate(),
            const SizedBox(height: 16),
            _buildLRUExplanation(),
          ],
        ),
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
        ],
      ),
    );
  }

  Widget _buildAddressInput() {
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
            return _buildCacheSet(setIndex);
          }),
        ],
      ),
    );
  }

  Widget _buildCacheSet(int setIndex) {
    final set = _cacheState.cache[setIndex];
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
            'Set $setIndex',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: List.generate(_mapping.ways, (wayIndex) {
              final line = set[wayIndex];
              final isLastUsed = line.lastUsed == _cacheState.totalAccesses &&
                  _cacheState.totalAccesses > 0;
              
              Color borderColor = AppTheme.borderColor;
              Color bgColor = AppTheme.surface;
              
              if (line.valid) {
                if (isLastUsed) {
                  borderColor = AppTheme.accentAmber;
                  bgColor = AppTheme.accentAmber.withOpacity(0.1);
                } else if (_accessHistory.isNotEmpty &&
                    _currentAccessIndex >= 0 &&
                    _accessHistory[_currentAccessIndex] == line.tag) {
                  borderColor = AppTheme.accentGreen;
                  bgColor = AppTheme.accentGreen.withOpacity(0.1);
                }
              }
              
              return Expanded(
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
                        'Way $wayIndex',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (line.valid)
                        Text(
                          'Tag: ${line.tag}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            color: AppTheme.accentCyan,
                          ),
                        )
                      else
                        Text(
                          'Empty',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      if (isLastUsed)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.accentAmber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            'LRU',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 8,
                              color: AppTheme.accentAmber,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _stepThroughHistory(int index) {
    _cacheState.reset();
    for (int i = 0; i <= index; i++) {
      _cacheState.access(_accessHistory[i]);
    }
    setState(() {
      _currentAccessIndex = index;
    });
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

  Widget _buildLRUExplanation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.panelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppTheme.accentAmber, size: 20),
              const SizedBox(width: 8),
              Text(
                'LRU Policy',
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
            'Least Recently Used (LRU) evicts the block that hasn\'t been accessed for the longest time. '
            'The amber highlighted line shows which block will be evicted next.',
            style: GoogleFonts.rajdhani(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildLegendItem('Valid', AppTheme.accentGreen),
              const SizedBox(width: 16),
              _buildLegendItem('LRU Candidate', AppTheme.accentAmber),
              const SizedBox(width: 16),
              _buildLegendItem('Current Access', AppTheme.accentCyan),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.rajdhani(
            fontSize: 11,
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