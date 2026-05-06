import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class MemoryHierarchyScreen extends StatefulWidget {
  const MemoryHierarchyScreen({super.key});

  @override
  State<MemoryHierarchyScreen> createState() => _MemoryHierarchyScreenState();
}

class _MemoryHierarchyScreenState extends State<MemoryHierarchyScreen>
    with TickerProviderStateMixin {
  bool _isAnimating = false;
  int _currentLevel = -1;
  String _result = '';
  late AnimationController _pulseController;
  late AnimationController _dataController;

  final List<MemoryLevel> _levels = [
    MemoryLevel(name: 'Registers', size: '32-256B', latency: '1 cycle', color: AppTheme.accentCyan),
    MemoryLevel(name: 'L1 Cache', size: '32KB', latency: '4 cycles', color: AppTheme.accentGreen),
    MemoryLevel(name: 'L2 Cache', size: '256KB', latency: '12 cycles', color: AppTheme.accentAmber),
    MemoryLevel(name: 'RAM', size: '8-32GB', latency: '100 cycles', color: const Color(0xFFF97316)),
    MemoryLevel(name: 'SSD', size: '256GB-2TB', latency: '100K cycles', color: AppTheme.accentRed),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    
    _dataController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  Future<void> _simulateAccess() async {
    if (_isAnimating) return;
    
    setState(() {
      _isAnimating = true;
      _result = '';
      _currentLevel = -1;
    });

    final random = Random();
    final hitLevel = random.nextInt(3);
    
    for (int i = _levels.length - 1; i >= 0; i--) {
      await Future.delayed(const Duration(milliseconds: 400));
      
      setState(() {
        _currentLevel = i;
        if (i == hitLevel) {
          _result = 'HIT at ${_levels[i].name}';
        } else if (i > hitLevel) {
          _result = 'MISS - checking ${_levels[i].name}';
        }
      });

      if (i == hitLevel) {
        await Future.delayed(const Duration(milliseconds: 300));
        for (int j = i - 1; j >= 0; j--) {
          await Future.delayed(const Duration(milliseconds: 200));
          setState(() {
            _currentLevel = j;
            _result = 'Data bubbles up to ${_levels[j].name}';
          });
        }
        break;
      }
    }

    setState(() {
      _isAnimating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Hierarchy'),
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
          children: [
            _buildPyramid(),
            const SizedBox(height: 16),
            _buildLegend(),
            const SizedBox(height: 16),
            _buildResultPanel(),
            const SizedBox(height: 16),
            _buildControls(),
            const SizedBox(height: 16),
            _buildExplanationPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildPyramid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.panelDecoration,
      child: Column(
        children: [
          Text(
            'Memory Hierarchy Pyramid',
            style: GoogleFonts.rajdhani(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 320,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: List.generate(_levels.length, (index) {
                final reversedIndex = _levels.length - 1 - index;
                final level = _levels[reversedIndex];
                final width = 0.3 + (reversedIndex * 0.18);
                final isActive = _currentLevel == reversedIndex;
                
                return Positioned(
                  bottom: reversedIndex * 56.0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 280 * width,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          level.color,
                          level.color.withOpacity(0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isActive ? level.color : level.color.withOpacity(0.3),
                        width: isActive ? 3 : 1,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: level.color.withOpacity(0.6),
                                blurRadius: 16,
                                spreadRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isActive)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.8),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.3, 1.3),
                            duration: 400.ms,
                          ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              level.name,
                              style: GoogleFonts.rajdhani(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${level.size} | ${level.latency}',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                color: Colors.white70,
                              ),
                            ),
                          ],
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

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.panelDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem('FAST', AppTheme.accentCyan),
          _buildLegendItem('SLOW', AppTheme.accentRed),
          _buildLegendItem('SMALL', AppTheme.accentGreen),
          _buildLegendItem('LARGE', AppTheme.accentAmber),
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
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.rajdhani(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildResultPanel() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _result.contains('HIT')
              ? AppTheme.accentGreen
              : _result.contains('MISS')
                  ? AppTheme.accentRed
                  : AppTheme.borderColor,
          width: 2,
        ),
        boxShadow: _result.isNotEmpty
            ? [
                BoxShadow(
                  color: (_result.contains('HIT')
                          ? AppTheme.accentGreen
                          : AppTheme.accentRed)
                      .withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _result.contains('HIT')
                ? Icons.check_circle
                : _result.contains('MISS')
                    ? Icons.error
                    : Icons.memory,
            color: _result.contains('HIT')
                ? AppTheme.accentGreen
                : _result.contains('MISS')
                    ? AppTheme.accentRed
                    : AppTheme.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            _result.isEmpty ? 'Ready to simulate' : _result,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 14,
              color: _result.contains('HIT')
                  ? AppTheme.accentGreen
                  : _result.contains('MISS')
                      ? AppTheme.accentRed
                      : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: _isAnimating ? null : _simulateAccess,
          icon: const Icon(Icons.play_arrow),
          label: const Text('Simulate Access'),
        ),
      ],
    );
  }

  Widget _buildExplanationPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.panelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Concepts',
            style: GoogleFonts.rajdhani(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildConceptItem('Temporal Locality', 'Recently accessed data is likely to be accessed again'),
          _buildConceptItem('Spatial Locality', 'Data near recently accessed data is likely to be accessed soon'),
          _buildConceptItem('Hit Rate', 'Percentage of memory accesses found in cache'),
          _buildConceptItem('Latency', 'Time delay for memory access in clock cycles'),
        ],
      ),
    );
  }

  Widget _buildConceptItem(String title, String desc) {
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
          const SizedBox(width: 8),
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
              'Memory Hierarchy',
              style: GoogleFonts.rajdhani(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentCyan,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'The memory hierarchy is organized by speed and size. '
              'Fastest storage (registers) is closest to the CPU, while '
              'slowest (SSD/HDD) provides the largest capacity.',
              style: GoogleFonts.rajdhani(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(_levels.length, (i) {
              final level = _levels[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: level.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${level.name}: ${level.size} (${level.latency})',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class MemoryLevel {
  final String name;
  final String size;
  final String latency;
  final Color color;

  MemoryLevel({
    required this.name,
    required this.size,
    required this.latency,
    required this.color,
  });
}