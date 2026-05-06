import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class IOSimulationScreen extends StatefulWidget {
  const IOSimulationScreen({super.key});

  @override
  State<IOSimulationScreen> createState() => _IOSimulationScreenState();
}

class _IOSimulationScreenState extends State<IOSimulationScreen>
    with SingleTickerProviderStateMixin {
  int _selectedMode = 0;
  bool _isAnimating = false;
  double _cpuUtilization = 0;
  String _currentStage = '';
  final List<String> _modes = ['Programmed I/O', 'Interrupt-Driven', 'DMA'];
  final List<String> _devices = ['Keyboard', 'Disk', 'Network'];
  int _selectedDevice = 0;
  late AnimationController _progressController;
  Timer? _simulationTimer;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..addListener(() {
      setState(() {
        _cpuUtilization = _progressController.value;
      });
    });
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  void _startSimulation() {
    if (_isAnimating) return;
    setState(() {
      _isAnimating = true;
      _cpuUtilization = 0;
    });
    _progressController.forward(from: 0);
    
    _runSimulation();
  }

  void _runSimulation() {
    int step = 0;
    final totalSteps = _selectedMode == 2 ? 4 : 8;
    
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      step++;
      
      switch (_selectedMode) {
        case 0:
          _simulateProgrammedIO(step);
          break;
        case 1:
          _simulateInterruptDriven(step);
          break;
        case 2:
          _simulateDMA(step);
          break;
      }
      
      if (step >= totalSteps) {
        timer.cancel();
        setState(() {
          _isAnimating = false;
        });
      }
    });
  }

  void _simulateProgrammedIO(int step) {
    setState(() {
      switch (step) {
        case 1:
          _currentStage = 'CPU checks device status';
          _cpuUtilization = 0.9;
          break;
        case 2:
          _currentStage = 'Device busy - CPU waits...';
          _cpuUtilization = 0.3;
          break;
        case 3:
          _currentStage = 'CPU polls again...';
          _cpuUtilization = 0.8;
          break;
        case 4:
          _currentStage = 'Still waiting...';
          _cpuUtilization = 0.2;
          break;
        case 5:
          _currentStage = 'Device ready';
          _cpuUtilization = 0.85;
          break;
        case 6:
          _currentStage = 'CPU reads data';
          _cpuUtilization = 0.9;
          break;
        case 7:
          _currentStage = 'CPU processes data';
          _cpuUtilization = 1.0;
          break;
        case 8:
          _currentStage = 'Complete';
          _cpuUtilization = 0;
          break;
      }
    });
  }

  void _simulateInterruptDriven(int step) {
    setState(() {
      switch (step) {
        case 1:
          _currentStage = 'CPU executes other tasks';
          _cpuUtilization = 0.7;
          break;
        case 2:
          _currentStage = 'Device finishes (interrupt!)';
          _cpuUtilization = 0.3;
          break;
        case 3:
          _currentStage = 'CPU saves context';
          _cpuUtilization = 0.8;
          break;
        case 4:
          _currentStage = 'Jump to ISR';
          _cpuUtilization = 0.85;
          break;
        case 5:
          _currentStage = 'Read device data';
          _cpuUtilization = 0.9;
          break;
        case 6:
          _currentStage = 'Process data in ISR';
          _cpuUtilization = 0.95;
          break;
        case 7:
          _currentStage = 'Restore context';
          _cpuUtilization = 0.8;
          break;
        case 8:
          _currentStage = 'Resume normal execution';
          _cpuUtilization = 0;
          break;
      }
    });
  }

  void _simulateDMA(int step) {
    setState(() {
      switch (step) {
        case 1:
          _currentStage = 'CPU programs DMA controller';
          _cpuUtilization = 0.9;
          break;
        case 2:
          _currentStage = 'CPU continues work';
          _cpuUtilization = 0.2;
          break;
        case 3:
          _currentStage = 'DMA transfers data';
          _cpuUtilization = 0.15;
          break;
        case 4:
          _currentStage = 'DMA sends interrupt';
          _cpuUtilization = 0.3;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('I/O Process Simulation'),
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
            _buildModeSelector(),
            const SizedBox(height: 16),
            _buildDeviceSelector(),
            const SizedBox(height: 16),
            _buildArchitectureDiagram(),
            const SizedBox(height: 16),
            _buildStatusPanel(),
            const SizedBox(height: 16),
            _buildCPUUtilization(),
            const SizedBox(height: 16),
            _buildExplanation(),
            const SizedBox(height: 16),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.panelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'I/O Mode',
            style: GoogleFonts.rajdhani(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<int>(
            segments: _modes
                .map((m) => ButtonSegment(
                      value: _modes.indexOf(m),
                      label: Text(m, style: const TextStyle(fontSize: 12)),
                    ))
                .toList(),
            selected: {_selectedMode},
            onSelectionChanged: (set) => setState(() => _selectedMode = set.first),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppTheme.accentCyan.withOpacity(0.2);
                }
                return AppTheme.background;
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.panelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Device',
            style: GoogleFonts.rajdhani(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _devices.asMap().entries.map((e) {
              final isSelected = _selectedDevice == e.key;
              return GestureDetector(
                onTap: () => setState(() => _selectedDevice = e.key),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: isSelected
                      ? AppTheme.glowCyan
                      : BoxDecoration(
                          color: AppTheme.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                  child: Column(
                    children: [
                      Icon(
                        _getDeviceIcon(e.value),
                        color: isSelected ? AppTheme.accentCyan : AppTheme.textSecondary,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        e.value,
                        style: GoogleFonts.rajdhani(
                          fontSize: 12,
                          color: isSelected ? AppTheme.accentCyan : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  IconData _getDeviceIcon(String device) {
    switch (device) {
      case 'Keyboard':
        return Icons.keyboard;
      case 'Disk':
        return Icons.storage;
      case 'Network':
        return Icons.wifi;
      default:
        return Icons.devices;
    }
  }

  Widget _buildArchitectureDiagram() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.panelDecoration,
      child: Column(
        children: [
          Text(
            'System Architecture',
            style: GoogleFonts.rajdhani(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNode('CPU', Icons.memory, AppTheme.accentCyan, true),
              _buildBus(),
              _buildNode('I/O\nController', Icons.settings_input_component, AppTheme.accentAmber, _selectedMode == 2),
              _buildBus(),
              _buildNode(_devices[_selectedDevice], _getDeviceIcon(_devices[_selectedDevice]), AppTheme.accentGreen, false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNode(String label, IconData icon, Color color, bool isActive) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? color : color.withOpacity(0.5),
              width: isActive ? 2 : 1,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Icon(icon, color: color, size: 32),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.rajdhani(
            fontSize: 12,
            color: AppTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBus() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentCyan.withOpacity(0.5),
            AppTheme.accentAmber.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildStatusPanel() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _currentStage.isNotEmpty ? AppTheme.accentCyan : AppTheme.borderColor,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isAnimating)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(AppTheme.accentCyan),
              ),
            ).animate(onPlay: (c) => c.repeat()).rotate(duration: 1000.ms)
          else
            const Icon(Icons.play_circle_outline, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Text(
            _currentStage.isEmpty ? 'Ready to simulate' : _currentStage,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 14,
              color: _currentStage.isNotEmpty ? AppTheme.accentCyan : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCPUUtilization() {
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
                'CPU Utilization',
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                '${(_cpuUtilization * 100).toStringAsFixed(0)}%',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _cpuUtilization > 0.7
                      ? AppTheme.accentGreen
                      : _cpuUtilization > 0.3
                          ? AppTheme.accentAmber
                          : AppTheme.accentRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _cpuUtilization,
              minHeight: 12,
              backgroundColor: AppTheme.background,
              valueColor: AlwaysStoppedAnimation(
                _cpuUtilization > 0.7
                    ? AppTheme.accentGreen
                    : _cpuUtilization > 0.3
                        ? AppTheme.accentAmber
                        : AppTheme.accentRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanation() {
    final explanations = [
      'CPU actively polls the device, wasting cycles waiting. Simple but inefficient.',
      'Device interrupts CPU when ready, allowing CPU to do other work. More efficient.',
      'DMA controller transfers data directly to memory. CPU is almost completely free.',
    ];
    
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
                'How it works',
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
            explanations[_selectedMode],
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isAnimating ? null : _startSimulation,
        icon: const Icon(Icons.play_arrow),
        label: const Text('Start Simulation'),
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
              'I/O Transfer Modes',
              style: GoogleFonts.rajdhani(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentCyan,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoItem('Programmed I/O', 'CPU continuously checks device status. Simple but wastes CPU cycles.'),
            _buildInfoItem('Interrupt-Driven', 'Device notifies CPU when ready via interrupt. CPU can do other work.'),
            _buildInfoItem('DMA', 'Direct Memory Access - DMA controller handles data transfer. CPU is free.'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.rajdhani(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.accentAmber,
            ),
          ),
          Text(
            desc,
            style: GoogleFonts.rajdhani(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}