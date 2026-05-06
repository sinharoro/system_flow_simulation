import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class CacheRow extends StatelessWidget {
  final int setIndex;
  final List<CacheLineData> lines;
  final int? lastUsedWay;

  const CacheRow({
    super.key,
    required this.setIndex,
    required this.lines,
    this.lastUsedWay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              'Set $setIndex',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: lines.asMap().entries.map((entry) {
                final index = entry.key;
                final line = entry.value;
                final isLastUsed = index == lastUsedWay;
                
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: line.isValid
                          ? (isLastUsed
                              ? AppTheme.accentAmber.withOpacity(0.1)
                              : AppTheme.accentGreen.withOpacity(0.1))
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: line.isValid
                            ? (isLastUsed ? AppTheme.accentAmber : AppTheme.accentGreen)
                            : AppTheme.borderColor,
                        width: isLastUsed ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Way $index',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 8,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        if (line.isValid)
                          Text(
                            'Tag: ${line.tag}',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              color: AppTheme.accentCyan,
                            ),
                          )
                        else
                          Text(
                            '-',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class CacheLineData {
  final int? tag;
  final bool isValid;

  CacheLineData({this.tag, this.isValid = false});
}