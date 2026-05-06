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
  bool _showCarryPropagation = false;

  final List<String> _operations = ['ADD', 'SUB', 'AND', 'OR', 'XOR', 'NOT', 'SHL', 'SHR'];

  void _calculate() {
    int op1 = _parseValue(_operand1Controller.text);
    int op2 = _operation == 'NOT' || _operation == 'SHL' || _operation == 'SHR' 
        ? 0 
        : _parseValue(_operand2Controller.text);
    
    setState(() {
      _result = ALUResult.calculate(op1, op2, _operation);
      _showCarryPropagation = _operation == 'ADD';
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
            _buildInputPanel(),
            const SizedBox(height: 16),
            _buildOperationSelector(),
            const SizedBox(height: 16),
            _buildCalculateButton(),
            if (_result != null) ...[
              const SizedBox(height: 16),
              _buildResultPanel(),
              if (_showCarryPropagation && _result!.bitOperations.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildCarryPropagationPanel(),
              ],
              const SizedBox(height: 16),
              _buildFlagsPanel(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputPanel() {
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
                    TextField(
                      controller: _operand1Controller,
                      style: GoogleFonts.jetBrainsMono(fontSize: 18),
                      decoration: InputDecoration(
                        hintText: _useBinary ? 'b00000000' : '0-255',
                        prefixText: _useBinary ? 'b' : null,
                      ),
                    ),
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
                    TextField(
                      controller: _operand2Controller,
                      style: GoogleFonts.jetBrainsMono(fontSize: 18),
                      enabled: _operation != 'NOT' && _operation != 'SHL' && _operation != 'SHR',
                      decoration: InputDecoration(
                        hintText: _useBinary ? 'b00000000' : '0-255',
                        prefixText: _useBinary ? 'b' : null,
                      ),
                    ),
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
              return ChoiceChip(
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
          _buildResultRow('Binary', _result!.binaryResult, AppTheme.accentCyan),
          const SizedBox(height: 8),
          _buildResultRow('Decimal', _result!.result.toString(), AppTheme.accentAmber),
          const SizedBox(height: 8),
          _buildResultRow('Hexadecimal', _result!.hexResult, AppTheme.accentGreen),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 100,
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
    );
  }

  Widget _buildCarryPropagationPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.panelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: AppTheme.accentAmber, size: 20),
              const SizedBox(width: 8),
              Text(
                'Carry Propagation (ADD)',
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBinaryDigit(_result!.operand1),
              const SizedBox(width: 8),
              Text(
                '+',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 20,
                  color: AppTheme.accentAmber,
                ),
              ),
              const SizedBox(width: 8),
              _buildBinaryDigit(_result!.operand2),
              const SizedBox(width: 8),
              Text(
                '=',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 20,
                  color: AppTheme.accentAmber,
                ),
              ),
              const SizedBox(width: 8),
              _buildBinaryDigit(_result!.result),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(8, (i) {
                final bit = _result!.bitOperations[7 - i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      if (bit.carry)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.accentRed.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            'C',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              color: AppTheme.accentRed,
                            ),
                          ),
                        ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.accentCyan.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            '${bit.resultBit}',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentCyan,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        '${7 - i}',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBinaryDigit(int value) {
    final binary = value.toRadixString(2).padLeft(8, '0');
    return Column(
      children: [
        Text(
          binary,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFlag('Zero (Z)', _result!.zeroFlag, AppTheme.accentGreen),
              _buildFlag('Carry (C)', _result!.carryFlag, AppTheme.accentAmber),
              _buildFlag('Overflow (V)', _result!.overflowFlag, AppTheme.accentRed),
              _buildFlag('Negative (N)', _result!.negativeFlag, AppTheme.accentCyan),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFlag(String label, bool value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: value ? color.withOpacity(0.2) : AppTheme.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: value ? color : AppTheme.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value ? color : AppTheme.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: value ? color : AppTheme.textSecondary,
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