// ===== FILE: lib/screens/system_flow_screen.dart =====
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class SystemFlowScreen extends StatefulWidget {
  const SystemFlowScreen({super.key});

  @override
  State<SystemFlowScreen> createState() => _SystemFlowScreenState();
}

class _SystemFlowScreenState extends State<SystemFlowScreen>
    with SingleTickerProviderStateMixin {
  int? _selectedComponent;
  bool _isAnimatingFlow = false;
  int _flowStep = -1;
  late AnimationController _clockController;
  late Animation<double> _clockAnimation;
  
  final List<Map<String, dynamic>> _components = [
    {
      'name': 'Input Device',
      'shortName': 'Input',
      'description': 'Devices that provide data to the system: keyboard, mouse, scanner',
      'icon': Icons.input,
      'color': AppTheme.accentGreen,
      'analogy': 'like your mouth — you use it to give information to someone',
      'details': 'Input devices convert physical input into digital data that the CPU can process.',
    },
    {
      'name': 'CPU',
      'shortName': 'CPU',
      'description': 'Central Processing Unit - executes instructions',
      'icon': Icons.memory,
      'color': AppTheme.accentCyan,
      'analogy': 'like your brain — it processes everything and makes decisions',
      'details': 'The CPU fetches, decodes, and executes instructions. It contains the ALU, control unit, and registers.',
    },
    {
      'name': 'Memory (RAM)',
      'shortName': 'Memory',
      'description': 'Random Access Memory - stores data and programs',
      'icon': Icons.sd_storage,
      'color': AppTheme.accentAmber,
      'analogy': 'like your short-term memory — holds what you\'re currently thinking about',
      'details': 'RAM provides fast read/write access to data. It is volatile - data is lost when power is off.',
    },
    {
      'name': 'Output Device',
      'shortName': 'Output',
      'description': 'Devices that display or output results: monitor, printer',
      'icon': Icons.output,
      'color': AppTheme.accentRed,
      'analogy': 'like your hands or voice — the results of your thinking',
      'details': 'Output devices convert digital data into human-readable forms like text, images, or sound.',
    },
  ];

  final List<Map<String, dynamic>> _quizQuestions = [
    {
      'question': 'What does the CPU do?',
      'options': ['Stores data long-term', 'Processes data and runs programs', 'Displays images', 'Connects to the internet'],
      'correct': 1,
      'explain': 'The CPU (Central Processing Unit) is like your brain - it processes everything and makes decisions.',
    },
    {
      'question': 'Which is the fastest memory?',
      'options': ['RAM', 'SSD', 'CPU Registers', 'Hard Drive'],
      'correct': 2,
      'explain': 'CPU Registers are the fastest - they\'re built right into the processor.',
    },
    {
      'question': 'What does an input device do?',
      'options': ['Shows results', 'Stores programs', 'Takes input from user', 'Processes calculations'],
      'correct': 2,
      'explain': 'Input devices like keyboards and mice take input from the user and send it to the CPU.',
    },
  ];
  
  int _currentQuizIndex = 0;
  int? _selectedQuizAnswer;
  bool _quizAnswered = false;

  static const List<String> _flowNarrator = [
    'Starting from Input Device...',
    'Data travels to CPU via the bus...',
    'CPU processes the data...',
    'Data flows to Memory (RAM)...',
    'Results return to CPU...',
    'Output sent to Output Device!',
  ];

  @override
  void initState() {
    super.initState();
    _clockController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    
    _clockAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(_clockController);
  }

  @override
  void dispose() {
    _clockController.dispose();
    super.dispose();
  }

  void _startDataFlow() {
    setState(() {
      _isAnimatingFlow = true;
      _flowStep = 0;
    });
    
    for (int i = 0; i < 6; i++) {
      Future.delayed(Duration(milliseconds: 1000 * (i + 1)), () {
        if (mounted && _isAnimatingFlow) {
          setState(() {
            _flowStep = i;
          });
          if (i == 5) {
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) {
                setState(() {
                  _isAnimatingFlow = false;
                  _flowStep = -1;
                });
              }
            });
          }
        }
      });
    }
  }

  void _stopDataFlow() {
    setState(() {
      _isAnimatingFlow = false;
      _flowStep = -1;
    });
  }

  void _answerQuiz(int answerIndex) {
    setState(() {
      _selectedQuizAnswer = answerIndex;
      _quizAnswered = true;
    });
  }

  void _nextQuestion() {
    setState(() {
      _currentQuizIndex = (_currentQuizIndex + 1) % _quizQuestions.length;
      _selectedQuizAnswer = null;
      _quizAnswered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Flow Diagram'),
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
            _buildClockVisualizer(),
            const SizedBox(height: 16),
            _buildSystemArchitecture(),
            const SizedBox(height: 16),
            if (_selectedComponent != null) _buildDetailPanel(),
            const SizedBox(height: 16),
            _buildDataFlowControls(),
            const SizedBox(height: 16),
            _buildBusExplanation(),
            const SizedBox(height: 16),
            _buildQuizCard(),
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
                  'This is the big picture of how a computer works. Tap a component to learn what it does and how it connects to the others.',
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

  Widget _buildClockVisualizer() {
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
                'Clock Signal',
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentCyan.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Running',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: AppTheme.accentCyan,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 60,
            child: AnimatedBuilder(
              animation: _clockAnimation,
              builder: (context, _) {
                return CustomPaint(
                  size: const Size(double.infinity, 60),
                  painter: ClockWavePainter(_clockAnimation.value),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemArchitecture() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final minBoxWidth = ((availableWidth - 64) / 7).clamp(60.0, 80.0);
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.panelDecoration,
          child: Column(
            children: [
              Text(
                'Computer System Architecture',
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: double.infinity),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildComponentBox(0, minBoxWidth),
                      _buildBusColumn(0),
                      _buildComponentBox(1, minBoxWidth),
                      _buildBusColumn(1),
                      _buildComponentBox(2, minBoxWidth),
                      _buildBusColumn(2),
                      _buildComponentBox(3, minBoxWidth),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildComponentBox(int index, double minBoxWidth) {
    final component = _components[index];
    final isSelected = _selectedComponent == index;
    final isActive = _flowStep == index;
    final color = component['color'] as Color;
    
    return GestureDetector(
      onTap: () => setState(() {
        _selectedComponent = isSelected ? null : index;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: minBoxWidth,
        height: 100,
        decoration: BoxDecoration(
          color: isSelected || isActive
              ? color.withOpacity(0.2)
              : AppTheme.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected || isActive ? color : AppTheme.borderColor,
            width: isActive ? 3 : (isSelected ? 2 : 1),
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 16,
                    spreadRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              component['icon'] as IconData,
              color: isSelected || isActive ? color : AppTheme.textSecondary,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              component['shortName'] as String,
              style: GoogleFonts.rajdhani(
                fontSize: 12,
                color: isSelected || isActive ? color : AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Active',
                  style: GoogleFonts.rajdhani(
                    fontSize: 9,
                    color: color,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusColumn(int index) {
    final isActive = (_flowStep == index || _flowStep == index + 1);
    
    return SizedBox(
      width: 50,
      child: Column(
        children: [
          _buildBusLine('D', AppTheme.accentCyan, isActive),
          const SizedBox(height: 2),
          _buildBusLine('A', AppTheme.accentAmber, isActive),
          const SizedBox(height: 2),
          _buildBusLine('C', AppTheme.accentGreen, isActive),
        ],
      ),
    );
  }

  Widget _buildBusLine(String label, Color color, bool isActive) {
    return Container(
      width: 40,
      height: 24,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isActive
              ? [color, color.withOpacity(0.3)]
              : [color.withOpacity(0.6), color.withOpacity(0.2)],
        ),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isActive)
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ).animate(onPlay: (c) => c.repeat()).scale(
                begin: const Offset(1, 1),
                end: const Offset(1.5, 1.5),
                duration: 500.ms,
              ),
            Text(
              label,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                color: isActive ? Colors.white : color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ).animate(target: isActive ? 1 : 0).fadeIn(duration: 300.ms);
  }

  Widget _buildDetailPanel() {
    final component = _components[_selectedComponent!];
    final color = component['color'] as Color;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(component['icon'] as IconData, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  component['name'] as String,
                  style: GoogleFonts.rajdhani(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => setState(() => _selectedComponent = null),
                color: AppTheme.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            component['description'] as String,
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'In real life, this is ${component['analogy'] as String}.',
                  style: GoogleFonts.rajdhani(
                    fontSize: 13,
                    color: AppTheme.textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  component['details'] as String,
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
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildDataFlowControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.panelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Data Flow Animation',
            style: GoogleFonts.rajdhani(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          if (_isAnimatingFlow && _flowStep >= 0)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentCyan.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.directions, color: AppTheme.accentCyan, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _flowNarrator[_flowStep],
                      style: GoogleFonts.rajdhani(
                        fontSize: 14,
                        color: AppTheme.accentCyan,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _isAnimatingFlow ? _stopDataFlow : _startDataFlow,
                icon: Icon(_isAnimatingFlow ? Icons.stop : Icons.play_arrow),
                label: Text(_isAnimatingFlow ? 'Stop' : 'Show Data Flow'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBusExplanation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.panelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cable, color: AppTheme.accentAmber, size: 20),
              const SizedBox(width: 8),
              Text(
                'System Buses',
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildBusItem('Data Bus (D)', 'Transfers actual data between components', AppTheme.accentCyan),
          _buildBusItem('Address Bus (A)', 'Carries memory addresses for data location', AppTheme.accentAmber),
          _buildBusItem('Control Bus (C)', 'Carries control signals (read, write, clock)', AppTheme.accentGreen),
        ],
      ),
    );
  }

  Widget _buildBusItem(String name, String desc, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
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

  Widget _buildQuizCard() {
    final question = _quizQuestions[_currentQuizIndex];
    final isCorrect = _selectedQuizAnswer == question['correct'];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.panelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.quiz, color: AppTheme.accentAmber, size: 20),
              const SizedBox(width: 8),
              Text(
                'Quiz Me',
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question['question'] as String,
            style: GoogleFonts.rajdhani(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate((question['options'] as List).length, (i) {
            final option = (question['options'] as List)[i];
            final isSelected = _selectedQuizAnswer == i;
            final showResult = _quizAnswered && i == question['correct'];
            final isWrong = _quizAnswered && isSelected && !isCorrect;
            
            return GestureDetector(
              onTap: _quizAnswered ? null : () => _answerQuiz(i),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: showResult 
                      ? AppTheme.accentGreen.withOpacity(0.2)
                      : isWrong 
                          ? AppTheme.accentRed.withOpacity(0.2)
                          : isSelected 
                              ? AppTheme.accentCyan.withOpacity(0.2)
                              : AppTheme.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: showResult 
                        ? AppTheme.accentGreen
                        : isWrong 
                            ? AppTheme.accentRed
                            : isSelected 
                                ? AppTheme.accentCyan
                                : AppTheme.borderColor,
                  ),
                ),
                child: Row(
                  children: [
                    if (showResult)
                      const Icon(Icons.check, color: AppTheme.accentGreen, size: 16),
                    if (isWrong)
                      const Icon(Icons.close, color: AppTheme.accentRed, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        option,
                        style: GoogleFonts.rajdhani(
                          fontSize: 13,
                          color: showResult || isWrong 
                              ? AppTheme.textPrimary 
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          if (_quizAnswered) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCorrect 
                    ? AppTheme.accentGreen.withOpacity(0.1)
                    : AppTheme.accentAmber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.info,
                    color: isCorrect ? AppTheme.accentGreen : AppTheme.accentAmber,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      question['explain'] as String,
                      style: GoogleFonts.rajdhani(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextQuestion,
                child: const Text('Next Question'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildColorLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.panelDecoration,
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: [
          _buildLegendItem('Green', 'Input', AppTheme.accentGreen),
          _buildLegendItem('Cyan', 'CPU', AppTheme.accentCyan),
          _buildLegendItem('Amber', 'Memory', AppTheme.accentAmber),
          _buildLegendItem('Red', 'Output', AppTheme.accentRed),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String color, String meaning, Color actualColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
          overflow: TextOverflow.ellipsis,
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
              'System Architecture',
              style: GoogleFonts.rajdhani(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentCyan,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'This diagram shows how data flows between the main components of a computer system. '
              'The CPU communicates with memory and I/O devices through the system bus.',
              style: GoogleFonts.rajdhani(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoItem('CPU', 'Executes instructions and controls other components'),
            _buildInfoItem('Memory', 'Stores programs and data for CPU access'),
            _buildInfoItem('I/O', 'Input/Output devices for user interaction'),
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
          const Icon(Icons.check_circle, color: AppTheme.accentGreen, size: 16),
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
}

class ClockWavePainter extends CustomPainter {
  final double phase;

  ClockWavePainter(this.phase);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accentCyan
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final amplitude = size.height / 3;
    final centerY = size.height / 2;
    final period = size.width / 4;

    path.moveTo(0, centerY);
    
    for (double x = 0; x <= size.width; x++) {
      final y = centerY - amplitude * sin((x / period + phase));
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
    
    final dotPaint = Paint()
      ..color = AppTheme.accentCyan
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.width - 10, centerY - amplitude * sin((size.width / 4 + phase - 0.1))),
      4,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ClockWavePainter oldDelegate) {
    return oldDelegate.phase != phase;
  }
}