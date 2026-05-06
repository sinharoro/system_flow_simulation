// ===== FILE: lib/screens/alu_demo_screen.dart =====
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/alu_result.dart';

class ALUDemoScreen extends StatefulWidget {
  const ALUDemoScreen({super.key});

  @override
  State<ALUDemoScreen> createState() => _ALUDemoScreenState();
}

class _ALUDemoScreenState extends State<ALUDemoScreen> {
  final TextEditingController _operand1Controller = TextEditingController(text: '5');
  final TextEditingController _operand2Controller = TextEditingController(text: '3');
  String _operation = 'ADD';
  ALUResult? _result;
  bool _useBinary = false;

  final List<String> _operations = ['ADD', 'SUB', 'AND', 'OR', 'XOR', 'NOT', 'SHL', 'SHR'];

  final List<Map<String, dynamic>> _presetExamples = [
    {'op1': '5', 'op2': '3', 'op': 'ADD'},
    {'op1': '15', 'op2': '9', 'op': 'AND'},
    {'op1': '7', 'op2': '3', 'op': 'XOR'},
    {'op1': '5', 'op2': '', 'op': 'NOT'},
  ];

  void _calculate() {
    int op1 = _parseValue(_operand1Controller.text);
    int op2 = _operation == 'NOT' || _operation == 'SHL' || _operation == 'SHR' 
        ? 0 
        : _parseValue(_operand2Controller.text);
    
    setState(() {
      _result = ALUResult.calculate(op1, op2, _operation);
    });
  }

  int _parseValue(String text) {
    if (_useBinary && text.toLowerCase().startsWith('b')) {
      return int.parse(text.substring(1), radix: 2);
    }
    return int.tryParse(text) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ALU Operation Demo'),
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
            _buildInputPanel(),
            const SizedBox(height: 16),
            _buildOperationSelector(),
            const SizedBox(height: 16),
            _buildPresetExamples(),
            const SizedBox(height: 16),
            _buildCalculateButton(),
            if (_result != null) ...[
              const SizedBox(height: 16),
              _buildResultPanel(),
              if (_operation == 'ADD') ...[
                const SizedBox(height: 16),
                _buildColumnAdditionVisualization(),
              ],
              const SizedBox(height: 16),
              _buildFlagsPanel(),
            ],
            const SizedBox(height: 16),
            _buildColorLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildNarratorPanel() {
    String explainText = _operation == 'ADD' 
        ? 'The ALU adds two numbers together, bit by bit, carrying over to the next position when needed.'
        : _operation == 'SUB'
            ? 'The ALU subtracts one number from another using two\'s complement arithmetic.'
            : _operation == 'AND'
                ? 'The ALU checks each bit: the result is 1 only if BOTH bits are 1.'
                : _operation == 'OR'
                    ? 'The ALU checks each bit: the result is 1 if EITHER bit is 1.'
                    : _operation == 'XOR'
                        ? 'The ALU checks each bit: the result is 1 if the bits are DIFFERENT.'
                        : _operation == 'NOT'
                            ? 'The ALU flips every bit: 0 becomes 1, 1 becomes 0.'
                            : 'The ALU shifts bits left or right, basically multiplying or dividing by 2.';
    
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
                  'The ALU (Arithmetic Logic Unit) is the CPU\'s calculator. Type two numbers, pick an operation, and watch it compute the result in binary.',
                  style: GoogleFonts.rajdhani(
                    fontSize: 15,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  explainText,
                  style: GoogleFonts.rajdhani(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputPanel() {
    final op1 = _parseValue(_operand1Controller.text);
    final op2 = _parseValue(_operand2Controller.text);
    final op1Binary = op1.toRadixString(2).padLeft(8, '0');
    final op2Binary = op2.toRadixString(2).padLeft(8, '0');
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.panelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.input, color: AppTheme.accentCyan, size: 20),
              const SizedBox(width: 8),
              Text(
                'Operands',
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Text(
                    'Binary',
                    style: GoogleFonts.rajdhani(
                      fontSize: 12,
                      color: _useBinary ? AppTheme.accentCyan : AppTheme.textSecondary,
                    ),
                  ),
                  Switch(
                    value: _useBinary,
                    onChanged: (v) => setState(() => _useBinary = v),
                    activeTrackColor: AppTheme.accentCyan.withAlpha(128),
                    thumbColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return AppTheme.accentCyan;
                      }
                      return AppTheme.textSecondary;
                    }),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Operand 1',
                      style: GoogleFonts.rajdhani(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => _showOperandTooltip(1, op1, op1Binary),
                      child: TextField(
                        controller: _operand1Controller,
                        style: GoogleFonts.jetBrainsMono(fontSize: 18),
                        decoration: InputDecoration(
                          hintText: _useBinary ? 'b00000000' : '0-255',
                          prefixText: _useBinary ? 'b' : null,
                          suffixIcon: const Icon(Icons.help_outline, size: 16),
                        ),
                      ),
                    ),
                    if (_operand1Controller.text.isNotEmpty && !_useBinary) ...[
                      const SizedBox(height: 4),
                      Text(
                        '$op1 in binary is $op1Binary',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Operand 2',
                      style: GoogleFonts.rajdhani(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: _operation == 'NOT' || _operation == 'SHL' || _operation == 'SHR'
                          ? null
                          : () => _showOperandTooltip(2, op2, op2Binary),
                      child: TextField(
                        controller: _operand2Controller,
                        style: GoogleFonts.jetBrainsMono(fontSize: 18),
                        enabled: _operation != 'NOT' && _operation != 'SHL' && _operation != 'SHR',
                        decoration: InputDecoration(
                          hintText: _useBinary ? 'b00000000' : '0-255',
                          prefixText: _useBinary ? 'b' : null,
                          suffixIcon: _operation != 'NOT' && _operation != 'SHL' && _operation != 'SHR'
                              ? const Icon(Icons.help_outline, size: 16)
                              : null,
                        ),
                      ),
                    ),
                    if (_operand2Controller.text.isNotEmpty && !_useBinary && _operation != 'NOT' && _operation != 'SHL' && _operation != 'SHR') ...[
                      const SizedBox(height: 4),
                      Text(
                        '$op2 in binary is $op2Binary',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOperationSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.panelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.functions, color: AppTheme.accentAmber, size: 20),
              const SizedBox(width: 8),
              Text(
                'Operation',
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _operations.map((op) {
              final isSelected = _operation == op;
              return GestureDetector(
                onTap: () => _showOperationTooltip(op),
                child: ChoiceChip(
                  label: Text(op),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _operation = op),
                  selectedColor: AppTheme.accentCyan.withOpacity(0.3),
                  labelStyle: GoogleFonts.jetBrainsMono(
                    fontSize: 14,
                    color: isSelected ? AppTheme.accentCyan : AppTheme.textSecondary,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppTheme.accentCyan : AppTheme.borderColor,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetExamples() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.panelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Try These Examples',
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presetExamples.map((example) {
              return ActionChip(
                label: Text(
                  example['op'] == 'NOT' 
                      ? 'NOT ${example['op1']}'
                      : '${example['op1']} ${example['op']} ${example['op2']}',
                ),
                onPressed: () {
                  setState(() {
                    _operand1Controller.text = example['op1'];
                    _operand2Controller.text = example['op2'] ?? '3';
                    _operation = example['op'];
                    _calculate();
                  });
                },
                backgroundColor: AppTheme.background,
                labelStyle: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  color: AppTheme.accentCyan,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _calculate,
        icon: const Icon(Icons.calculate),
        label: const Text('Calculate'),
      ),
    );
  }

  Widget _buildResultPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glowCyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.output, color: AppTheme.accentCyan, size: 20),
              const SizedBox(width: 8),
              Text(
                'Result',
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accentCyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildResultRow('Binary', _result!.binaryResult, _result!.result, AppTheme.accentCyan),
          const SizedBox(height: 8),
          _buildResultRow('Decimal', _result!.result.toString(), _result!.result, AppTheme.accentAmber),
          const SizedBox(height: 8),
          _buildResultRow('Hex', _result!.hexResult, _result!.result, AppTheme.accentGreen),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, int decimalValue, Color color) {
    String plainEnglish = '';
    if (label == 'Binary') {
      final onBits = <String>[];
      for (int i = 0; i < value.length; i++) {
        if (value[i] == '1') {
          onBits.add('${7 - i}');
        }
      }
      if (onBits.isEmpty) {
        plainEnglish = 'All bits are OFF (value = 0)';
      } else {
        plainEnglish = 'Read right to left: bit(s) ${onBits.join(', ')} ${onBits.length == 1 ? 'is' : 'are'} ON, all others OFF.';
      }
    } else if (label == 'Hex') {
      plainEnglish = 'Each hex digit represents 4 binary bits.';
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(
                label,
                style: GoogleFonts.rajdhani(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                value,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        if (plainEnglish.isNotEmpty) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 80),
            child: Text(
              plainEnglish,
              style: GoogleFonts.rajdhani(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildColumnAdditionVisualization() {
    if (_result == null || _result!.bitOperations.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final op1Bin = _result!.operand1.toRadixString(2).padLeft(8, '0');
    final op2Bin = _result!.operand2.toRadixString(2).padLeft(8, '0');
    final resultBin = _result!.binaryResult;
    final carries = <String>[];
    
    for (int i = 0; i < 8; i++) {
      final bitOp = _result!.bitOperations[7 - i];
      if (bitOp.carry) {
        carries.add('1');
      } else {
        carries.add('0');
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.panelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.view_column, color: AppTheme.accentAmber, size: 20),
              const SizedBox(width: 8),
              Text(
                'Column-by-Column Addition',
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: List.generate(8, (i) {
                    return Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.accentCyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppTheme.accentCyan.withOpacity(0.3)),
                      ),
                      child: Center(
                        child: Text(
                          op1Bin[i],
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentCyan,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '+',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 20,
                        color: AppTheme.accentAmber,
                      ),
                    ),
                    ...List.generate(8, (i) {
                      return Container(
                        width: 32,
                        height: 32,
                        margin: const EdgeInsets.only(left: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accentAmber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppTheme.accentAmber.withOpacity(0.3)),
                        ),
                        child: Center(
                          child: Text(
                            op2Bin[i],
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentAmber,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: List.generate(8, (i) {
                    final carryBit = carries[7 - i];
                    final hasCarry = carryBit == '1';
                    return Container(
                      width: 32,
                      height: 24,
                      margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        color: hasCarry 
                            ? AppTheme.accentRed.withOpacity(0.3) 
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Center(
                        child: hasCarry
                            ? Text(
                                'C',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accentRed,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    );
                  }),
                ),
                Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: AppTheme.borderColor,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: List.generate(8, (i) {
                    final bit = resultBin[i];
                    return Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.accentCyan.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppTheme.accentCyan),
                      ),
                      child: Center(
                        child: Text(
                          bit,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentCyan,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Red = Carry bit (the addition overflowed to the next column)',
            style: GoogleFonts.rajdhani(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            'Cyan row = result bit for each column',
            style: GoogleFonts.rajdhani(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlagsPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.panelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag, color: AppTheme.accentGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                'Status Flags',
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildFlagCard('Zero (Z)', _result!.zeroFlag, 'Result = 0', 'Result is exactly zero')),
              const SizedBox(width: 8),
              Expanded(child: _buildFlagCard('Carry (C)', _result!.carryFlag, 'Overflowed 8 bits', 'The addition was too big for 8 bits')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildFlagCard('Overflow (V)', _result!.overflowFlag, 'Signed overflow', 'Sign bit changed unexpectedly')),
              const SizedBox(width: 8),
              Expanded(child: _buildFlagCard('Negative (N)', _result!.negativeFlag, 'Result < 128', 'The most significant bit is 1')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFlagCard(String label, bool value, String condition, String plainMeaning) {
    return GestureDetector(
      onTap: () => _showFlagTooltip(label, value, condition, plainMeaning),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: value ? AppTheme.accentGreen.withOpacity(0.1) : AppTheme.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: value ? AppTheme.accentGreen : AppTheme.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: value ? AppTheme.accentGreen : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.rajdhani(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: value ? AppTheme.accentGreen : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value ? condition : 'OFF',
              style: GoogleFonts.rajdhani(
                fontSize: 11,
                color: value ? AppTheme.textPrimary : AppTheme.textSecondary,
              ),
            ),
            Text(
              plainMeaning,
              style: GoogleFonts.rajdhani(
                fontSize: 10,
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
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
          _buildLegendItem('Cyan', 'Active', AppTheme.accentCyan),
          _buildLegendItem('Amber', 'Operand', AppTheme.accentAmber),
          _buildLegendItem('Red', 'Carry', AppTheme.accentRed),
          _buildLegendItem('Green', 'Flag ON', AppTheme.accentGreen),
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

  void _showOperandTooltip(int operandNum, int value, String binary) {
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
              'Operand $operandNum',
              style: GoogleFonts.rajdhani(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentCyan,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$value in binary is $binary',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 14,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'In computers, numbers are stored as binary (base-2) — only 0s and 1s. Each position represents a power of 2.',
              style: GoogleFonts.rajdhani(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOperationTooltip(String op) {
    final Map<String, String> opInfo = {
      'ADD': 'Adds two numbers together. If the result exceeds 255, the Carry flag is set.',
      'SUB': 'Subtracts operand 2 from operand 1 using two\'s complement.',
      'AND': 'Bitwise AND - result is 1 only if both bits are 1.',
      'OR': 'Bitwise OR - result is 1 if either bit is 1.',
      'XOR': 'Exclusive OR - result is 1 if bits are different.',
      'NOT': 'Bitwise NOT - flips every bit (0 becomes 1, 1 becomes 0).',
      'SHL': 'Shift Left - moves all bits left, effectively multiplying by 2.',
      'SHR': 'Shift Right - moves all bits right, effectively dividing by 2.',
    };
    
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
              op,
              style: GoogleFonts.rajdhani(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentCyan,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              opInfo[op]!,
              style: GoogleFonts.rajdhani(
                fontSize: 14,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFlagTooltip(String label, bool value, String condition, String plainMeaning) {
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
              label,
              style: GoogleFonts.rajdhani(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: value ? AppTheme.accentGreen : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Condition: $condition',
              style: GoogleFonts.rajdhani(
                fontSize: 14,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              plainMeaning,
              style: GoogleFonts.rajdhani(
                fontSize: 14,
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
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
              'ALU Operations',
              style: GoogleFonts.rajdhani(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentCyan,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoItem('ADD', 'Binary addition with carry propagation'),
            _buildInfoItem('SUB', 'Binary subtraction with borrow'),
            _buildInfoItem('AND', 'Bitwise AND - 1 only if both bits are 1'),
            _buildInfoItem('OR', 'Bitwise OR - 1 if either bit is 1'),
            _buildInfoItem('XOR', 'Exclusive OR - 1 if bits are different'),
            _buildInfoItem('NOT', 'Bitwise NOT - inverts all bits'),
            _buildInfoItem('SHL', 'Shift Left - multiply by 2'),
            _buildInfoItem('SHR', 'Shift Right - divide by 2'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String op, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accentAmber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              op,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                color: AppTheme.accentAmber,
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