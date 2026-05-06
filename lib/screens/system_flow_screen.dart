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
  late AnimationController _clockController;
  late Animation<double> _clockAnimation;

  final List<SystemComponent> _components = [
    SystemComponent(
      name: 'Input Device',
      description: 'Devices that provide data to the system: keyboard, mouse, scanner',
      icon: Icons.input,
      details: 'Input devices convert physical input into digital data that the CPU can process.',
    ),
    SystemComponent(
      name: 'CPU',
      description: 'Central Processing Unit - executes instructions',
      icon: Icons.memory,
      details: 'The CPU fetches, decodes, and executes instructions. It contains the ALU, control unit, and registers.',
    ),
    SystemComponent(
      name: 'Memory (RAM)',
      description: 'Random Access Memory - stores data and programs',
      icon: Icons.sd_storage,
      details: 'RAM provides fast read/write access to data. It is volatile - data is lost when power is off.',
    ),
    SystemComponent(
      name: 'Output Device',
      description: 'Devices that display or output results: monitor, printer',
      icon: Icons.output,
      details: 'Output devices convert digital data into human-readable forms like text, images, or sound.',
    ),
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
            _buildClockVisualizer(),
            const SizedBox(height: 16),
            _buildSystemDiagram(),
            const SizedBox(height: 16),
            if (_selectedComponent != null) _buildDetailPanel(),
            const SizedBox(height: 16),
            _buildBusExplanation(),
          ],
        ),
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

  Widget _buildSystemDiagram() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildComponent(0),
              _buildBusColumn(0),
              _buildComponent(1),
              _buildBusColumn(1),
              _buildComponent(2),
              _buildBusColumn(2),
              _buildComponent(3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComponent(int index) {
    final component = _components[index];
    final isSelected = _selectedComponent == index;
    
    return GestureDetector(
      onTap: () => setState(() {
        _selectedComponent = isSelected ? null : index;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 60,
        height: 80,
        decoration: BoxDecoration(
          color: isSelected 
              ? component.icon == Icons.memory 
                  ? AppTheme.accentCyan.withOpacity(0.2)
                  : component.icon == Icons.input
                      ? AppTheme.accentGreen.withOpacity(0.2)
                      : component.icon == Icons.sd_storage
                          ? AppTheme.accentAmber.withOpacity(0.2)
                          : AppTheme.accentRed.withOpacity(0.2)
              : AppTheme.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? component.icon == Icons.memory 
                    ? AppTheme.accentCyan
                    : component.icon == Icons.input
                        ? AppTheme.accentGreen
                        : component.icon == Icons.sd_storage
                            ? AppTheme.accentAmber
                            : AppTheme.accentRed
                : AppTheme.borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: component.icon == Icons.memory 
                        ? AppTheme.accentCyan
                        : component.icon == Icons.input
                            ? AppTheme.accentGreen
                            : component.icon == Icons.sd_storage
                                ? AppTheme.accentAmber
                                : AppTheme.accentRed
                        .withOpacity(0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              component.icon,
              color: isSelected 
                  ? component.icon == Icons.memory 
                      ? AppTheme.accentCyan
                      : component.icon == Icons.input
                          ? AppTheme.accentGreen
                          : component.icon == Icons.sd_storage
                              ? AppTheme.accentAmber
                              : AppTheme.accentRed
                  : AppTheme.textSecondary,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              component.name.split(' ').first,
              style: GoogleFonts.rajdhani(
                fontSize: 9,
                color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusColumn(int index) {
    return SizedBox(
      width: 50,
      child: Column(
        children: [
          _buildBusLine('D', AppTheme.accentCyan),
          _buildBusLine('A', AppTheme.accentAmber),
          _buildBusLine('C', AppTheme.accentGreen),
        ],
      ),
    );
  }

  Widget _buildBusLine(String label, Color color) {
    return Container(
      width: 40,
      height: 24,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withOpacity(0.6),
            color.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(
      duration: 2000.ms,
      color: color.withOpacity(0.3),
    );
  }

  Widget _buildDetailPanel() {
    final component = _components[_selectedComponent!];
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glowCyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(component.icon, color: AppTheme.accentCyan, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  component.name,
                  style: GoogleFonts.rajdhani(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentCyan,
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
            component.description,
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
            child: Text(
              component.details,
              style: GoogleFonts.rajdhani(
                fontSize: 13,
                color: AppTheme.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
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

class SystemComponent {
  final String name;
  final String description;
  final IconData icon;
  final String details;

  SystemComponent({
    required this.name,
    required this.description,
    required this.icon,
    required this.details,
  });
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