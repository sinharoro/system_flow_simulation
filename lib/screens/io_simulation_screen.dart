// ===== FILE: lib/screens/io_simulation_screen.dart =====
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
  String _narratorText = '';
  final List<String> _modes = ['Prog I/O', 'Interrupt', 'DMA'];
  final List<String> _devices = ['Keyboard', 'Disk', 'Network'];
  int _selectedDevice = 0;
  late AnimationController _progressController;
  Timer? _simulationTimer;
  int _wastedCycles = 0;
  int _cpuFreedCycles = 0;
  final List<String> _stageHistory = [];

  static const List<String> _narratorPhrases = [
    'Imagine you\'re waiting for a pizza delivery. With Programmed I/O, you stand at the door and check every 30 seconds. You can\'t do anything else.',
    'With interrupt-driven I/O, you go about your day and the doorbell rings when the pizza arrives. You only stop when needed.',
    'With DMA (Direct Memory Access), you hire an assistant to handle the delivery entirely. You never even need to go to the door.',
  ];

  static const Map<String, String> _cpuUtilLabels = {
    'low': 'CPU mostly idle — wasting potential',
    'medium': 'CPU doing real work',
    'high': 'CPU fully busy — but is it useful work?',
  };

  @override
  void initState() {
    super.initState();
    _narratorText = _narratorPhrases[0];
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
      _wastedCycles = 0;
      _cpuFreedCycles = 0;
      _stageHistory.clear();
      _narratorText = _narratorPhrases[_selectedMode];
    });
    _progressController.forward(from: 0);
    
    _runSimulation();
  }

  void _runSimulation() {
    int step = 0;
    final totalSteps = _selectedMode == 2 ? 4 : 8;
    
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      step++;
      _stageHistory.add(_currentStage);
      
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
          _wastedCycles += 1;
          break;
        case 2:
          _currentStage = 'Device busy - CPU waits...';
          _cpuUtilization = 0.3;
          _wastedCycles += 2;
          break;
        case 3:
          _currentStage = 'CPU polls again...';
          _cpuUtilization = 0.8;
          _wastedCycles += 1;
          break;
        case 4:
          _currentStage = 'Still waiting...';
          _cpuUtilization = 0.2;
          _wastedCycles += 3;
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
          _cpuFreedCycles += 2;
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
          _cpuFreedCycles += 4;
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
          _cpuFreedCycles += 3;
          break;
        case 3:
          _currentStage = 'DMA transfers data';
          _cpuUtilization = 0.15;
          _cpuFreedCycles += 2;
          break;
        case 4:
          _currentStage = 'DMA sends interrupt';
          _cpuUtilization = 0.3;
          _cpuFreedCycles += 1;
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
            _buildNarratorPanel(),
            const SizedBox(height: 16),
            _buildModeSelector(),
            const SizedBox(height: 16),
            _buildDeviceSelector(),
            const SizedBox(height: 16),
            _buildArchitectureFlow(),
            const SizedBox(height: 16),
            _buildStatusPanel(),
            const SizedBox(height: 16),
            _buildCPUUtilizationBar(),
            const SizedBox(height: 16),
            if (_selectedMode == 0 && _wastedCycles > 0) _buildWastedCounter(),
            if (_selectedMode == 2 && _cpuFreedCycles > 0) _buildCPUFreedCounter(),
            const SizedBox(height: 16),
            _buildControls(),
            const SizedBox(height: 16),
            _buildColorLegend(),
            const SizedBox(height: 16),
            _buildComparisonCard(),
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
                  _narratorText.isEmpty ? _narratorPhrases[_selectedMode] : _narratorText,
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            child: SegmentedButton<int>(
              segments: _modes
                  .asMap()
                  .entries
                  .map((m) => ButtonSegment(
                        value: m.key,
                        label: Text(m.value, style: const TextStyle(fontSize: 12)),
                      ))
                  .toList(),
              selected: {_selectedMode},
              onSelectionChanged: (set) {
                setState(() {
                  _selectedMode = set.first;
                  _narratorText = _narratorPhrases[set.first];
                  _resetSimulation();
                });
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppTheme.accentCyan.withOpacity(0.2);
                  }
                  return AppTheme.background;
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resetSimulation() {
    setState(() {
      _cpuUtilization = 0;
      _currentStage = '';
      _wastedCycles = 0;
      _cpuFreedCycles = 0;
      _stageHistory.clear();
    });
    _progressController.reset();
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

  Widget _buildArchitectureFlow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.panelDecoration,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Data Flow',
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              if (_isAnimating)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentAmber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Animating...',
                    style: GoogleFonts.rajdhani(
                      fontSize: 12,
                      color: AppTheme.accentAmber,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFlowNode('CPU', Icons.memory, AppTheme.accentCyan, _isAnimating && _currentStage.contains('CPU')),
                _buildFlowArrow(),
                _buildFlowNode('I/O\nController', Icons.settings_input_component, AppTheme.accentAmber, _isAnimating && _currentStage.contains('DMA')),
                _buildFlowArrow(),
                _buildFlowNode(_devices[_selectedDevice], _getDeviceIcon(_devices[_selectedDevice]), AppTheme.accentGreen, _isAnimating && _currentStage.contains('Device')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowNode(String label, IconData icon, Color color, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.2) : AppTheme.background,
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
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.rajdhani(
              fontSize: 11,
              color: isActive ? color : AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFlowArrow() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Icon(
        Icons.arrow_forward,
        color: AppTheme.borderColor,
        size: 24,
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
          Expanded(
            child: Text(
              _currentStage.isEmpty ? 'Ready to simulate' : _currentStage,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 14,
                color: _currentStage.isNotEmpty ? AppTheme.accentCyan : AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCPUUtilizationBar() {
    String utilLabel = '';
    if (_cpuUtilization <= 0.3) {
      utilLabel = _cpuUtilLabels['low']!;
    } else if (_cpuUtilization <= 0.7) {
      utilLabel = _cpuUtilLabels['medium']!;
    } else {
      utilLabel = _cpuUtilLabels['high']!;
    }
    
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
          const SizedBox(height: 4),
          Text(
            utilLabel,
            style: GoogleFonts.rajdhani(
              fontSize: 12,
              color: AppTheme.textSecondary,
              fontStyle: FontStyle.italic,
            ),
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

  Widget _buildWastedCounter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentRed),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: AppTheme.accentRed, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wasted Cycles: $_wastedCycles',
                  style: GoogleFonts.rajdhani(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentRed,
                  ),
                ),
                Text(
                  'The CPU wasted $_wastedCycles cycles just waiting! Could have done useful work instead.',
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

  Widget _buildCPUFreedCounter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentGreen),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppTheme.accentGreen, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CPU Freed: $_cpuFreedCycles cycles',
                  style: GoogleFonts.rajdhani(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentGreen,
                  ),
                ),
                Text(
                  'The CPU was free to do other useful work for $_cpuFreedCycles cycles while DMA handled the transfer.',
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

  Widget _buildColorLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.panelDecoration,
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: [
          _buildLegendItem('Green', 'Success'),
          _buildLegendItem('Red', 'Fail/Waste'),
          _buildLegendItem('Amber', 'In Progress'),
          _buildLegendItem('Cyan', 'Active'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String color, String meaning) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color == 'Green' ? AppTheme.accentGreen : color == 'Red' ? AppTheme.accentRed : color == 'Amber' ? AppTheme.accentAmber : AppTheme.accentCyan,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(meaning, style: GoogleFonts.rajdhani(fontSize: 10, color: AppTheme.textSecondary), overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _buildComparisonCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.panelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.compare_arrows, color: AppTheme.accentCyan, size: 20),
              const SizedBox(width: 8),
              Text(
                'Comparison',
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Table(
              border: TableBorder.all(color: AppTheme.borderColor, width: 1),
              columnWidths: const {
                0: FlexColumnWidth(1.2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1.2),
              },
              children: [
                TableRow(
                  children: [
                    _buildTableHeader('Mode'),
                    _buildTableHeader('CPU Efficiency'),
                    _buildTableHeader('Complexity'),
                    _buildTableHeader('Best For'),
                  ],
                ),
                TableRow(
                  children: [
                    _buildTableCell('Programmed I/O', AppTheme.textPrimary),
                    _buildTableCell('Low', AppTheme.accentRed),
                    _buildTableCell('Easy', AppTheme.accentGreen),
                    _buildTableCell('Simple apps', AppTheme.textSecondary),
                  ],
                ),
                TableRow(
                  children: [
                    _buildTableCell('Interrupt', AppTheme.textPrimary),
                    _buildTableCell('Medium', AppTheme.accentAmber),
                    _buildTableCell('Medium', AppTheme.accentAmber),
                    _buildTableCell('Most apps', AppTheme.textSecondary),
                  ],
                ),
                TableRow(
                  children: [
                    _buildTableCell('DMA', AppTheme.textPrimary),
                    _buildTableCell('High', AppTheme.accentGreen),
                    _buildTableCell('Complex', AppTheme.accentRed),
                    _buildTableCell('Large transfers', AppTheme.textSecondary),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Container(
      padding: const EdgeInsets.all(4),
      child: Text(
        text,
        style: GoogleFonts.rajdhani(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppTheme.accentCyan,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildTableCell(String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(4),
      child: Text(
        text,
        style: GoogleFonts.rajdhani(
          fontSize: 10,
          color: color,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
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