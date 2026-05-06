// ===== FILE: lib/screens/memory_hierarchy_screen.dart =====
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
  String _narratorText = 'Tap Simulate Access to start the memory hierarchy demonstration.';
  int _hitLevel = 0;
  late AnimationController _pulseController;
  late AnimationController _dataController;
  String _hitLocation = '';

  final List<MemoryLevel> _levels = [
    MemoryLevel(name: 'Registers', size: '32-256B', latency: '1 cycle', color: AppTheme.accentCyan, analogy: 'Your hands — instant access, tiny capacity'),
    MemoryLevel(name: 'L1 Cache', size: '32KB', latency: '4 cycles', color: AppTheme.accentGreen, analogy: 'Your desk — fast, small'),
    MemoryLevel(name: 'L2 Cache', size: '256KB', latency: '12 cycles', color: AppTheme.accentAmber, analogy: 'Your bookshelf — medium speed, more space'),
    MemoryLevel(name: 'RAM', size: '8-32GB', latency: '100 cycles', color: const Color(0xFFF97316), analogy: 'Filing cabinet in the same room — slower, much more space'),
    MemoryLevel(name: 'SSD', size: '256GB-2TB', latency: '100K cycles', color: AppTheme.accentRed, analogy: 'Archive in another building — very slow, huge capacity'),
  ];

  static const Map<String, String> _narratorPhrases = {
    'pre': 'Imagine your brain trying to remember something. First you check your short-term memory (fast!), then your notes (slower), then the library (slowest).',
    'checking': 'Checking {level}... not there.',
    'found': 'FOUND IT in {level}! Now copying it up to the faster levels so next time it\'s quicker to find.',
    'hit': 'CACHE HIT — Found the data here! No need to go deeper.',
    'miss': 'CACHE MISS — Not here. Going deeper…',
    'complete': 'Search complete. {location}. It took {cycles} clock cycles.',
  };

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
      _narratorText = _narratorPhrases['pre']!;
      _hitLocation = '';
    });

    final random = Random();
    _hitLevel = random.nextInt(3);
    _hitLocation = _levels[_hitLevel].name;
    
    for (int i = _levels.length - 1; i >= 0; i--) {
      await Future.delayed(const Duration(milliseconds: 400));
      
      setState(() {
        _currentLevel = i;
        if (i == _hitLevel) {
          _result = 'HIT at ${_levels[i].name}';
          _narratorText = _narratorPhrases['found']!.replaceAll('{level}', _levels[i].name);
        } else {
          _result = 'MISS - checking ${_levels[i].name}';
          _narratorText = _narratorPhrases['checking']!.replaceAll('{level}', _levels[i].name);
        }
      });

      if (i == _hitLevel) {
        await Future.delayed(const Duration(milliseconds: 300));
        for (int j = i - 1; j >= 0; j--) {
          await Future.delayed(const Duration(milliseconds: 200));
          setState(() {
            _currentLevel = j;
            _narratorText = _narratorPhrases['found']!.replaceAll('{level}', _levels[j].name);
          });
        }
        break;
      }
    }

    final searchCycles = int.parse(_levels[_hitLevel].latency.split(' ')[0]);
    
    setState(() {
      _isAnimating = false;
      _narratorText = _narratorPhrases['complete']!
          .replaceAll('{location}', 'Data was found in $_hitLocation')
          .replaceAll('{cycles}', '$searchCycles');
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
            _buildNarratorPanel(),
            const SizedBox(height: 16),
            _buildAnalogyCard(),
            const SizedBox(height: 16),
            _buildPyramid(),
            const SizedBox(height: 16),
            _buildResultPanel(),
            const SizedBox(height: 16),
            _buildControls(),
            const SizedBox(height: 16),
            _buildColorLegend(),
            if (_currentLevel >= 0) ...[
              const SizedBox(height: 16),
              _buildSpeedComparison(),
            ],
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

  Widget _buildAnalogyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.panelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Real-World Analogy',
            style: GoogleFonts.rajdhani(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ..._levels.map((level) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: level.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${level.name} = ${level.analogy}',
                    style: GoogleFonts.rajdhani(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
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
                final width = 0.4 + (reversedIndex * 0.15);
                final isActive = _currentLevel == reversedIndex;
                
                return Positioned(
                  bottom: reversedIndex * 65.0,
                  child: GestureDetector(
                    onTap: () => _showLevelTooltip(level),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 300 * width,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            level.color,
                            level.color.withOpacity(0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isActive ? Colors.white : level.color.withOpacity(0.3),
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
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          if (isActive)
                            Positioned(
                              top: -20,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: level.color),
                                  ),
                                  child: Text(
                                    _result.contains('HIT') ? 'HIT' : 'Checking...',
                                    style: GoogleFonts.rajdhani(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: _result.contains('HIT') ? AppTheme.accentGreen : AppTheme.accentAmber,
                                    ),
                                  ),
                                ),
                              ),
                            ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(duration: 300.ms).slideY(begin: 0, end: -0.2, duration: 500.ms),
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
                          if (isActive)
                            Positioned(
                              top: -40,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentRed.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  level.latency,
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 10,
                                    color: AppTheme.accentRed,
                                  ),
                                ),
                              ),
                            ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
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
                                    ),
                                  Text(
                                    level.name,
                                    style: GoogleFonts.rajdhani(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (isActive)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.only(left: 8),
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
                                    ),
                                ],
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
                  ),
                );
              }),
            ),
          ),
        ],
      ),
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
                    ? Icons.search
                    : Icons.memory,
            color: _result.contains('HIT')
                ? AppTheme.accentGreen
                : _result.contains('MISS')
                    ? AppTheme.accentAmber
                    : AppTheme.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _result.isEmpty ? 'Ready to simulate' : _result,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 14,
                color: _result.contains('HIT')
                    ? AppTheme.accentGreen
                    : _result.contains('MISS')
                        ? AppTheme.accentAmber
                        : AppTheme.textSecondary,
              ),
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

  Widget _buildSpeedComparison() {
    final searchCycles = int.parse(_levels[_hitLevel].latency.split(' ')[0]);
    final fullLatency = int.parse(_levels[3].latency.split(' ')[0]);
    final speedup = fullLatency ~/ searchCycles;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentGreen),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.speed, color: AppTheme.accentGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                'Speed Comparison',
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accentGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Data was found in $_hitLocation. It took $searchCycles clock cycles.',
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'If it had been in RAM, it would have taken $fullLatency cycles — ${speedup}x longer!',
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
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
          _buildLegendItem('Amber', 'Checking', AppTheme.accentAmber),
          _buildLegendItem('Cyan', 'Active', AppTheme.accentCyan),
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

  void _showLevelTooltip(MemoryLevel level) {
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
              level.name,
              style: GoogleFonts.rajdhani(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: level.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              level.analogy,
              style: GoogleFonts.rajdhani(
                fontSize: 16,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Size: ${level.size} | Latency: ${level.latency}',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
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
  final String analogy;

  MemoryLevel({
    required this.name,
    required this.size,
    required this.latency,
    required this.color,
    required this.analogy,
  });
}