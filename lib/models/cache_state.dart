class CacheState {
  final int sets;
  final int ways;
  final int blockSize;
  List<List<CacheLine>> cache = [];
  int hits = 0;
  int misses = 0;
  int totalAccesses = 0;
  String lastResult = '';
  String replacementPolicy = 'LRU';

  CacheState({
    this.sets = 4,
    this.ways = 1,
    this.blockSize = 1,
  }) {
    initializeCache();
  }

  void initializeCache() {
    cache = List.generate(
      sets,
      (_) => List.generate(
        ways,
        (_) => CacheLine(),
      ),
    );
  }

  void reset() {
    initializeCache();
    hits = 0;
    misses = 0;
    totalAccesses = 0;
    lastResult = '';
  }

  int getSet(int address) {
    return (address ~/ blockSize) % sets;
  }

  int getTag(int address) {
    return address ~/ (sets * blockSize);
  }

  String access(int address) {
    totalAccesses++;
    final setIndex = getSet(address);
    final tag = getTag(address);
    final set = cache[setIndex];

    for (int i = 0; i < ways; i++) {
      if (set[i].valid && set[i].tag == tag) {
        hits++;
        set[i].lastUsed = totalAccesses;
        lastResult = 'HIT';
        return 'HIT';
      }
    }

    misses++;
    int evictIndex = 0;
    int minLastUsed = set[0].lastUsed;
    for (int i = 1; i < ways; i++) {
      if (set[i].lastUsed < minLastUsed) {
        minLastUsed = set[i].lastUsed;
        evictIndex = i;
      }
    }

    if (set[evictIndex].valid) {
      lastResult = 'MISS - EVICT';
    } else {
      lastResult = 'MISS - FILL';
    }

    set[evictIndex] = CacheLine(
      tag: tag,
      valid: true,
      lastUsed: totalAccesses,
    );

    return lastResult;
  }

  double get hitRate => totalAccesses > 0 ? hits / totalAccesses : 0;

  String get hitRateString => '${(hitRate * 100).toStringAsFixed(1)}%';
}

class CacheLine {
  int? tag;
  bool valid;
  int lastUsed;

  CacheLine({
    this.tag,
    this.valid = false,
    this.lastUsed = 0,
  });

  void reset() {
    tag = null;
    valid = false;
    lastUsed = 0;
  }
}

enum CacheMapping {
  directMapped,
  twoWay,
  fourWay,
}

extension CacheMappingExtension on CacheMapping {
  String get name {
    switch (this) {
      case CacheMapping.directMapped:
        return 'Direct-Mapped';
      case CacheMapping.twoWay:
        return '2-Way Set-Associative';
      case CacheMapping.fourWay:
        return '4-Way Set-Associative';
    }
  }

  int get ways {
    switch (this) {
      case CacheMapping.directMapped:
        return 1;
      case CacheMapping.twoWay:
        return 2;
      case CacheMapping.fourWay:
        return 4;
    }
  }
}