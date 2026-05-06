import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/instruction.dart';
import '../widgets/register_box.dart';

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
  String _explanation = 'Press Step to start execution';
  List<Instruction> _instructions = [];

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
        _explanation = 'No instructions to execute';
      });
      return;
    }

    setState(() {
      switch (_currentStep % 4) {
        case 0:
          _phase = 'FETCH';
          _cpuState.mar = _cpuState.pc;
          _cpuState.mdr = _cpuState.memory[_cpuState.pc];
          _explanation = 'FETCH: MAR ← PC, MDR ← Memory[PC]';
          break;
        case 1:
          _phase = 'DECODE';
          _cpuState.ir = _cpuState.mdr;
          _cpuState.pc++;
          _explanation = 'DECODE: IR ← MDR, PC ← PC + 1';
          break;
        case 2:
          _phase = 'EXECUTE';
          _executeInstruction();
          _explanation = 'EXECUTE: Performing ${_instructions[_cpuState.programCounter].mnemonic}';
          break;
        case 3:
          _phase = 'STORE';
          _explanation = 'STORE: Result written to accumulator';
          _cpuState.programCounter++;
          if (_cpuState.programCounter >= _instructions.length) {
            _phase = 'HALT';
            _explanation = 'Program execution complete';
            _autoRun = false;
            _autoRunTimer?.cancel();
          }
          break;
      }
      _currentStep++;
    });
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
        _autoRunTimer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
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
      _explanation = 'Press Step to start execution';
      _autoRun = false;
      _autoRunTimer?.cancel();
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
            _buildClockPulse(),
            const SizedBox(height: 16),
            _buildPhaseIndicator(),
            const SizedBox(height: 16),
            _buildExplanationPanel(),
            const SizedBox(height: 16),
            _buildRegistersPanel(),
            const SizedBox(height: 16),
            _buildProgramEditor(),
            const SizedBox(height: 16),
            _buildMemoryView(),
            const SizedBox(height: 16),
            _buildControls(),
          ],
        ),
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
          return Container(
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
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExplanationPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.panelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: AppTheme.accentAmber, size: 20),
              const SizedBox(width: 8),
              Text(
                'Current Operation',
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
            _explanation,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 14,
              color: AppTheme.accentCyan,
            ),
          ),
        ],
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
                child: RegisterBox(
                  label: 'PC',
                  value: _cpuState.pc.toString(),
                  isActive: _phase == 'FETCH',
                  color: AppTheme.accentCyan,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RegisterBox(
                  label: 'IR',
                  value: _cpuState.ir.toString(),
                  isActive: _phase == 'DECODE',
                  color: AppTheme.accentAmber,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RegisterBox(
                  label: 'MAR',
                  value: _cpuState.mar.toString(),
                  isActive: _phase == 'FETCH',
                  color: AppTheme.accentGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: RegisterBox(
                  label: 'MDR',
                  value: _cpuState.mdr.toString(),
                  isActive: _phase == 'FETCH',
                  color: AppTheme.accentRed,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RegisterBox(
                  label: 'ACC',
                  value: _cpuState.acc.toString(),
                  isActive: _phase == 'EXECUTE' || _phase == 'STORE',
                  color: AppTheme.accentCyan,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgramEditor() {
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
          const SizedBox(height: 8),
          Text(
            'Available instructions: LOAD, ADD, SUB, STORE, JMP, HALT',
            style: GoogleFonts.rajdhani(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _programController,
            maxLines: 5,
            style: GoogleFonts.jetBrainsMono(fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Enter instructions (one per line)',
            ),
            onChanged: (_) => _parseProgram(),
          ),
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
            'Memory (16 bytes)',
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
              return Container(
                width: 50,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppTheme.borderColor),
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
                        color: AppTheme.accentCyan,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
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