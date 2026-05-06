class ALUResult {
  final int operand1;
  final int operand2;
  final String operation;
  final int result;
  final bool zeroFlag;
  final bool carryFlag;
  final bool overflowFlag;
  final bool negativeFlag;
  final String binaryResult;
  final String hexResult;
  final List<BitOperation> bitOperations;

  ALUResult({
    required this.operand1,
    required this.operand2,
    required this.operation,
    required this.result,
    required this.zeroFlag,
    required this.carryFlag,
    required this.overflowFlag,
    required this.negativeFlag,
    required this.binaryResult,
    required this.hexResult,
    this.bitOperations = const [],
  });

  static ALUResult calculate(int a, int b, String op) {
    int result = 0;
    bool carry = false;
    bool overflow = false;
    List<BitOperation> bitOps = [];

    switch (op) {
      case 'ADD':
        result = a + b;
        carry = result > 255;
        overflow = ((a ^ result) & (b ^ result) & 0x80) != 0;
        for (int i = 0; i < 8; i++) {
          int bitA = (a >> i) & 1;
          int bitB = (b >> i) & 1;
          int sum = bitA + bitB + (i == 0 ? 0 : (result >> (i - 1)) & 1);
          bitOps.add(BitOperation(
            position: i,
            bitA: bitA,
            bitB: bitB,
            carry: sum > 1,
            resultBit: (result >> i) & 1,
          ));
        }
        break;
      case 'SUB':
        result = a - b;
        overflow = ((a ^ b) & (a ^ result) & 0x80) != 0;
        break;
      case 'AND':
        result = a & b;
        break;
      case 'OR':
        result = a | b;
        break;
      case 'XOR':
        result = a ^ b;
        break;
      case 'NOT':
        result = (~a) & 0xFF;
        break;
      case 'SHL':
        result = (a << 1) & 0xFF;
        carry = (a & 0x80) != 0;
        break;
      case 'SHR':
        result = a >> 1;
        carry = (a & 1) != 0;
        break;
    }

    return ALUResult(
      operand1: a,
      operand2: b,
      operation: op,
      result: result & 0xFF,
      zeroFlag: (result & 0xFF) == 0,
      carryFlag: carry,
      overflowFlag: overflow,
      negativeFlag: (result & 0x80) != 0,
      binaryResult: toBinaryString(result & 0xFF),
      hexResult: toHexString(result & 0xFF),
      bitOperations: bitOps,
    );
  }

  static String toBinaryString(int value) {
    return value.toRadixString(2).padLeft(8, '0');
  }

  static String toHexString(int value) {
    return '0x${value.toRadixString(16).toUpperCase().padLeft(2, '0')}';
  }
}

class BitOperation {
  final int position;
  final int bitA;
  final int bitB;
  final bool carry;
  final int resultBit;

  BitOperation({
    required this.position,
    required this.bitA,
    required this.bitB,
    required this.carry,
    required this.resultBit,
  });
}