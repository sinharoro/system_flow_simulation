// ===== FILE: lib/screens/cpu_cycle_screen.dart =====
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/instruction.dart';
import '../widgets/speed_slider.dart';

class CPUCycleScreen extends StatefulWidget {
  const CPUCycleScreen({super.key});

  @override
  State<CPUCycleScreen> createState() => _CPUCycleScreenState();
}

class _CPUCycleScreenState extends State<CPUCycleScreen> {
  final TextEditingController _programController = TextEditingController(
    text: 'LOAD 5\nADD 6\nSTORE 7\nLOAD 7\nHALT',
  );
  
  CPUState _cpuState = CPUState();
  bool _autoRun = false;
  Timer? _autoRunTimer;
  int _currentStep = 0;
  String _phase = 'IDLE';
  String _narratorText = 'Press Step to start execution';
  List<Instruction> _instructions = [];
  int _speedMs = 1000;
  int _previousPC = 0;
  int _previousIR = 0;
  int _previousMAR = 0;
  int _previousMDR = 0;
  int _previousACC = 0;
  int _memoryCellHighlighted = -1;

  static const Map<String, String> _narratorPhrases = {
    'FETCH': 'The CPU is going to pick up the next instruction from memory. It\'s like looking at your to-do list to see what task comes next.',
    'DECODE': 'The CPU reads the instruction and figures out what it means — like reading a recipe step before cooking.',
    'EXECUTE': 'The CPU is doing the actual work — performing the calculation or operation.',
    'STORE': 'The result is being saved so it can be used later.',
    'IDLE': 'Press Step or Auto Run to start execution.',
    'HALT': 'Program execution complete! All instructions have been processed.',
  };

  @override
  void initState() {
    super.initState();
    _parseProgram();
  }

  void _parseProgram() {
    final lines = _programController.text.split('\n');
    _instructions = lines
        .map((line) => Instruction.parse(line))
        .whereType<Instruction>()
        .toList();
    _cpuState.loadProgram(_instructions);
  }

  void _step() {
    if (_instructions.isEmpty) {
      setState(() {
        _narratorText = 'No instructions to execute';
      });
      return;
    }

    _savePreviousValues();
    
    setState(() {
      switch (_currentStep % 4) {
        case 0:
          _phase = 'FETCH';
          _cpuState.mar = _cpuState.pc;
          _cpuState.mdr = _cpuState.memory[_cpuState.pc];
          _memoryCellHighlighted = _cpuState.pc;
          _narratorText = _narratorPhrases['FETCH']!;
          break;
        case 1:
          _phase = 'DECODE';
          _cpuState.ir = _cpuState.mdr;
          _cpuState.pc++;
          _narratorText = _narratorPhrases['DECODE']!;
          break;
        case 2:
          _phase = 'EXECUTE';
          _executeInstruction();
          _narratorText = _narratorPhrases['EXECUTE']!;
          break;
        case 3:
          _phase = 'STORE';
          _narratorText = _narratorPhrases['STORE']!;
          _cpuState.programCounter++;
          _memoryCellHighlighted = -1;
          if (_cpuState.programCounter >= _instructions.length) {
            _phase = 'HALT';
            _narratorText = _narratorPhrases['HALT']!;
            _autoRun = false;
            _autoRunTimer?.cancel();
          }
          break;
      }
      _currentStep++;
    });
  }

  void _savePreviousValues() {
    _previousPC = _cpuState.pc;
    _previousIR = _cpuState.ir;
    _previousMAR = _cpuState.mar;
    _previousMDR = _cpuState.mdr;
    _previousACC = _cpuState.acc;
  }

  void _executeInstruction() {
    if (_cpuState.programCounter >= _instructions.length) return;
    
    final instr = _instructions[_cpuState.programCounter];
    switch (instr.type) {
      case InstructionType.LOAD:
        _cpuState.acc = _cpuState.memory[instr.address ?? 0];
        break;
      case InstructionType.ADD:
        _cpuState.acc += _cpuState.memory[instr.address ?? 0];
        break;
      case InstructionType.SUB:
        _cpuState.acc -= _cpuState.memory[instr.address ?? 0];
        break;
      case InstructionType.STORE:
        if (instr.address != null && instr.address! < _cpuState.memory.length) {
          _cpuState.memory[instr.address!] = _cpuState.acc;
        }
        break;
      case InstructionType.JMP:
        _cpuState.pc = instr.address ?? 0;
        break;
      case InstructionType.HALT:
        _autoRun = false;
        _autoRunTimer?.cancel();
        break;
    }
  }

  void _toggleAutoRun() {
    setState(() {
      _autoRun = !_autoRun;
      if (_autoRun) {
        _autoRunTimer = Timer.periodic(Duration(milliseconds: _speedMs), (_) {
          if (_phase != 'HALT' && _phase != 'IDLE') {
            _step();
          } else {
            _autoRun = false;
            _autoRunTimer?.cancel();
          }
        });
      } else {
        _autoRunTimer?.cancel();
      }
    });
  }

  void _reset() {
    setState(() {
      _cpuState.reset();
      _parseProgram();
      _currentStep = 0;
      _phase = 'IDLE';
      _narratorText = 'Press Step or Auto Run to start execution.';
      _autoRun = false;
      _autoRunTimer?.cancel();
      _memoryCellHighlighted = -1;
      _previousPC = 0;
      _previousIR = 0;
      _previousMAR = 0;
      _previousMDR = 0;
      _previousACC = 0;
    });
  }

  @override
  void dispose() {
    _autoRunTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CPU Instruction Cycle'),
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
            _buildStepLabel(),
            const SizedBox(height: 16),
            _buildClockPulse(),
            const SizedBox(height: 16),
            _buildPhaseIndicator(),
            const SizedBox(height: 16),
            _buildRegistersPanel(),
            const SizedBox(height: 16),
            _buildProgramView(),
            const SizedBox(height: 16),
            _buildMemoryView(),
            const SizedBox(height: 16),
            _buildSpeedSlider(),
            const SizedBox(height: 16),
            _buildControls(),
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

  Widget _buildStepLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: AppTheme.panelDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (i) {
          final stepNum = i + 1;
          final isActive = _phase == ['FETCH', 'DECODE', 'EXECUTE', 'STORE'][i];
          final isPast = _currentStep > (i + 1);
          return Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive 
                      ? AppTheme.accentAmber 
                      : isPast 
                          ? AppTheme.accentGreen 
                          : AppTheme.background,
                  border: Border.all(
                    color: isActive || isPast 
                        ? (isActive ? AppTheme.accentAmber : AppTheme.accentGreen) 
                        : AppTheme.borderColor,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$stepNum',
                    style: GoogleFonts.rajdhani(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isActive || isPast ? Colors.white : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
              if (i < 3) ...[
                const SizedBox(width: 4),
                Container(
                  width: 30,
                  height: 2,
                  color: isPast ? AppTheme.accentGreen : AppTheme.borderColor,
                ),
                const SizedBox(width: 4),
              ],
            ],
          );
        }),
      ),
    );
  }

  Widget _buildClockPulse() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.panelDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Clock: ',
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _phase != 'IDLE' && _phase != 'HALT' 
                  ? AppTheme.accentCyan 
                  : AppTheme.textSecondary,
              boxShadow: _phase != 'IDLE' && _phase != 'HALT'
                  ? [
                      BoxShadow(
                        color: AppTheme.accentCyan.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
          ).animate(onPlay: (c) => c.repeat()).shimmer(
            duration: 1000.ms,
            color: AppTheme.accentCyan.withOpacity(0.3),
          ),
          const SizedBox(width: 16),
          Text(
            'Cycle: $_currentStep',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 14,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseIndicator() {
    final phases = ['FETCH', 'DECODE', 'EXECUTE', 'STORE'];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.panelDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: phases.map((p) {
          final isActive = _phase == p;
          return GestureDetector(
            onTap: () => _showTermTooltip(p),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: isActive
                  ? AppTheme.glowCyan
                  : BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
              child: Text(
                p,
                style: GoogleFonts.rajdhani(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isActive ? AppTheme.accentCyan : AppTheme.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRegistersPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.panelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CPU Registers',
            style: GoogleFonts.rajdhani(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildRegisterCard(
                  label: 'PC',
                  plainName: 'Program Counter',
                  analogy: 'your bookmark',
                  value: _cpuState.pc.toString(),
                  oldValue: _previousPC.toString(),
                  isActive: _phase == 'FETCH',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRegisterCard(
                  label: 'IR',
                  plainName: 'Instruction Register',
                  analogy: 'the current task',
                  value: _cpuState.ir.toString(),
                  oldValue: _previousIR.toString(),
                  isActive: _phase == 'DECODE',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRegisterCard(
                  label: 'MAR',
                  plainName: 'Memory Address Register',
                  analogy: 'the address you\'re looking up',
                  value: _cpuState.mar.toString(),
                  oldValue: _previousMAR.toString(),
                  isActive: _phase == 'FETCH',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildRegisterCard(
                  label: 'MDR',
                  plainName: 'Memory Data Register',
                  analogy: 'what you found at that address',
                  value: _cpuState.mdr.toString(),
                  oldValue: _previousMDR.toString(),
                  isActive: _phase == 'FETCH',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRegisterCard(
                  label: 'ACC',
                  plainName: 'Accumulator',
                  analogy: 'your running total/scratchpad',
                  value: _cpuState.acc.toString(),
                  oldValue: _previousACC.toString(),
                  isActive: _phase == 'EXECUTE' || _phase == 'STORE',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterCard({
    required String label,
    required String plainName,
    required String analogy,
    required String value,
    required String oldValue,
    required bool isActive,
  }) {
    final hasChanged = value != oldValue && _currentStep > 0 && _phase != 'IDLE';
    return GestureDetector(
      onTap: () => _showTermBottomSheet(label, plainName, analogy),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.accentCyan.withOpacity(0.1) : AppTheme.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? AppTheme.accentCyan : AppTheme.borderColor,
            width: isActive ? 2 : 1,
          ),
          boxShadow: isActive ? AppTheme.glowCyan.boxShadow : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isActive ? AppTheme.accentCyan : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.help_outline,
                  size: 12,
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (hasChanged)
              Row(
                children: [
                  Text(
                    oldValue,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 16,
                      color: AppTheme.accentRed,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const Icon(Icons.arrow_forward, size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    value,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentGreen,
                    ),
                  ),
                ],
              )
            else
              Text(
                value,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramView() {
    final currentInstrIndex = _cpuState.programCounter;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.panelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.code, color: AppTheme.accentCyan, size: 20),
              const SizedBox(width: 8),
              Text(
                'Assembly Program',
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(_instructions.length, (i) {
            final instr = _instructions[i];
            final isCurrent = i == currentInstrIndex && (_phase == 'FETCH' || _phase == 'DECODE');
            final isPast = i < currentInstrIndex;
            return Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isCurrent 
                    ? AppTheme.accentAmber.withOpacity(0.2) 
                    : isPast 
                        ? AppTheme.accentGreen.withOpacity(0.1) 
                        : AppTheme.background,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isCurrent 
                      ? AppTheme.accentAmber 
                      : isPast 
                          ? AppTheme.accentGreen 
                          : AppTheme.borderColor,
                  width: isCurrent ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '${i + 1}.',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    instr.display,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 14,
                      color: isCurrent 
                          ? AppTheme.accentAmber 
                          : isPast 
                              ? AppTheme.accentGreen 
                              : AppTheme.textPrimary,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMemoryView() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.panelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Memory (16 cells)',
            style: GoogleFonts.rajdhani(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(16, (i) {
              final isHighlighted = i == _memoryCellHighlighted;
              return GestureDetector(
                onTap: () => _showMemoryCellTooltip(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 50,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isHighlighted 
                        ? AppTheme.accentCyan.withOpacity(0.2) 
                        : AppTheme.background,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isHighlighted ? AppTheme.accentCyan : AppTheme.borderColor,
                      width: isHighlighted ? 2 : 1,
                    ),
                    boxShadow: isHighlighted
                        ? [
                            BoxShadow(
                              color: AppTheme.accentCyan.withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$i',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        '${_cpuState.memory[i]}',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          color: isHighlighted ? AppTheme.accentCyan : AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          if (_memoryCellHighlighted >= 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentCyan.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppTheme.accentCyan, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Currently reading Cell $_memoryCellHighlighted, which contains the value ${_cpuState.memory[_memoryCellHighlighted]}',
                    style: GoogleFonts.rajdhani(
                      fontSize: 13,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSpeedSlider() {
    return SpeedSlider(
      speedMs: _speedMs,
      onSpeedChanged: (speed) {
        setState(() {
          _speedMs = speed;
          if (_autoRun) {
            _autoRunTimer?.cancel();
            _autoRunTimer = Timer.periodic(Duration(milliseconds: _speedMs), (_) {
              if (_phase != 'HALT' && _phase != 'IDLE') {
                _step();
              } else {
                _autoRun = false;
                _autoRunTimer?.cancel();
              }
            });
          }
        });
      },
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: _phase == 'HALT' ? null : _step,
          icon: const Icon(Icons.skip_next),
          label: const Text('Step'),
        ),
        OutlinedButton.icon(
          onPressed: _toggleAutoRun,
          icon: Icon(_autoRun ? Icons.pause : Icons.play_arrow),
          label: Text(_autoRun ? 'Pause' : 'Auto Run'),
          style: OutlinedButton.styleFrom(
            backgroundColor: _autoRun ? AppTheme.accentAmber.withOpacity(0.2) : null,
          ),
        ),
        OutlinedButton.icon(
          onPressed: _reset,
          icon: const Icon(Icons.refresh),
          label: const Text('Reset'),
        ),
      ],
    );
  }

  Widget _buildColorLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.panelDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem('Green', 'Success/Hit'),
          _buildLegendItem('Red', 'Fail/Miss'),
          _buildLegendItem('Amber', 'In Progress'),
          _buildLegendItem('Cyan', 'Active'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String color, String meaning) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color == 'Green' ? AppTheme.accentGreen : 
                   color == 'Red' ? AppTheme.accentRed : 
                   color == 'Amber' ? AppTheme.accentAmber : AppTheme.accentCyan,
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

  void _showTermBottomSheet(String term, String plainName, String analogy) {
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
              term,
              style: GoogleFonts.rajdhani(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentCyan,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '($plainName)',
              style: GoogleFonts.rajdhani(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: AppTheme.accentAmber, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$term is like $analogy.',
                    style: GoogleFonts.rajdhani(
                      fontSize: 16,
                      color: AppTheme.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTermTooltip(String term) {
    final Map<String, Map<String, String>> termInfo = {
      'FETCH': {'name': 'Fetch Phase', 'analogy': 'looking up what task to do next on your to-do list'},
      'DECODE': {'name': 'Decode Phase', 'analogy': 'reading a recipe and understanding the steps'},
      'EXECUTE': {'name': 'Execute Phase', 'analogy': 'actually cooking the meal'},
      'STORE': {'name': 'Store Phase', 'analogy': 'putting the finished dish in the fridge to save it'},
    };
    final info = termInfo[term]!;
    _showTermBottomSheet(term, info['name']!, info['analogy']!);
  }

  void _showMemoryCellTooltip(int cell) {
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
              'Memory Cell $cell',
              style: GoogleFonts.rajdhani(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentCyan,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This memory cell holds the value ${_cpuState.memory[cell]}. In a real computer, this would be a location in RAM where instructions or data are stored.',
              style: GoogleFonts.rajdhani(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
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
              'CPU Instruction Cycle',
              style: GoogleFonts.rajdhani(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentCyan,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoItem('FETCH', 'The instruction is fetched from memory into the IR register'),
            _buildInfoItem('DECODE', 'The CPU interprets the instruction opcode to determine what operation to perform'),
            _buildInfoItem('EXECUTE', 'The ALU performs the operation using operands from registers or memory'),
            _buildInfoItem('STORE', 'The result is written back to memory or a register'),
            const SizedBox(height: 16),
            Text(
              'Instruction Set: LOAD, ADD, SUB, STORE, JMP, HALT',
              style: GoogleFonts.rajdhani(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accentCyan.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              title,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                color: AppTheme.accentCyan,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              desc,
              style: GoogleFonts.rajdhani(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}