enum InstructionType { LOAD, ADD, SUB, STORE, JMP, HALT }

class Instruction {
  final InstructionType type;
  final int? address;
  final int? value;

  Instruction({
    required this.type,
    this.address,
    this.value,
  });

  String get mnemonic {
    switch (type) {
      case InstructionType.LOAD:
        return 'LOAD';
      case InstructionType.ADD:
        return 'ADD';
      case InstructionType.SUB:
        return 'SUB';
      case InstructionType.STORE:
        return 'STORE';
      case InstructionType.JMP:
        return 'JMP';
      case InstructionType.HALT:
        return 'HALT';
    }
  }

  String get display {
    if (address != null) {
      return '$mnemonic $address';
    } else if (value != null) {
      return '$mnemonic #$value';
    }
    return mnemonic;
  }

  static Instruction? parse(String line) {
    final parts = line.trim().toUpperCase().split(RegExp(r'\s+'));
    if (parts.isEmpty) return null;

    switch (parts[0]) {
      case 'LOAD':
        if (parts.length >= 2) {
          return Instruction(type: InstructionType.LOAD, address: int.tryParse(parts[1]));
        }
        break;
      case 'ADD':
        if (parts.length >= 2) {
          return Instruction(type: InstructionType.ADD, address: int.tryParse(parts[1]));
        }
        break;
      case 'SUB':
        if (parts.length >= 2) {
          return Instruction(type: InstructionType.SUB, address: int.tryParse(parts[1]));
        }
        break;
      case 'STORE':
        if (parts.length >= 2) {
          return Instruction(type: InstructionType.STORE, address: int.tryParse(parts[1]));
        }
        break;
      case 'JMP':
        if (parts.length >= 2) {
          return Instruction(type: InstructionType.JMP, address: int.tryParse(parts[1]));
        }
        break;
      case 'HALT':
        return Instruction(type: InstructionType.HALT);
    }
    return null;
  }
}

class CPUState {
  int pc = 0;
  int ir = 0;
  int mar = 0;
  int mdr = 0;
  int acc = 0;
  List<int> memory = List.filled(16, 0);
  List<Instruction> program = [];
  int currentCycle = 0;
  String currentPhase = 'FETCH';
  bool isRunning = false;
  int programCounter = 0;

  void reset() {
    pc = 0;
    ir = 0;
    mar = 0;
    mdr = 0;
    acc = 0;
    memory = List.filled(16, 0);
    currentCycle = 0;
    currentPhase = 'FETCH';
    isRunning = false;
    programCounter = 0;
  }

  void loadProgram(List<Instruction> instructions) {
    program = instructions;
    for (int i = 0; i < instructions.length && i < memory.length; i++) {
      memory[i] = instructions[i].type.index;
    }
  }
}