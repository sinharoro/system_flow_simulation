import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CPU Instruction Cycle Simulation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.memory,
                    size: 80,
                    color: AppTheme.accentCyan,
                  ).animate().fadeIn(duration: 600.ms).scale(),
                  const SizedBox(height: 16),
                  Text(
                    'CPU Architecture Simulator',
                    style: GoogleFonts.rajdhani(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 8),
                  Text(
                    'Interactive Computer Architecture Education',
                    style: GoogleFonts.rajdhani(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Select a Module',
              style: GoogleFonts.rajdhani(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildModuleCard(
              context,
              icon: Icons.memory,
              title: 'CPU Instruction Cycle',
              description: 'Learn how the CPU processes instructions through Fetch, Decode, Execute, and Store phases.',
              index: 1,
              color: AppTheme.accentCyan,
            ),
            _buildModuleCard(
              context,
              icon: Icons.layers,
              title: 'Memory Hierarchy',
              description: 'Explore the pyramid from Registers to SSD/HDD with latency and size information.',
              index: 2,
              color: AppTheme.accentAmber,
            ),
            _buildModuleCard(
              context,
              icon: Icons.calculate,
              title: 'ALU Operation Demo',
              description: 'Perform binary arithmetic and logic operations with step-by-step visualization.',
              index: 3,
              color: AppTheme.accentGreen,
            ),
            _buildModuleCard(
              context,
              icon: Icons.input,
              title: 'I/O Process Simulation',
              description: 'Compare Programmed I/O, Interrupt-Driven, and DMA transfer modes.',
              index: 4,
              color: AppTheme.accentRed,
            ),
            _buildModuleCard(
              context,
              icon: Icons.storage,
              title: 'Cache Memory Tool',
              description: 'Simulate Direct-Mapped, 2-Way, and 4-Way Set-Associative caches with LRU eviction.',
              index: 5,
              color: AppTheme.accentCyan,
            ),
            _buildModuleCard(
              context,
              icon: Icons.account_tree,
              title: 'System Flow Diagram',
              description: 'Interactive system bus visualization with data, address, and control buses.',
              index: 6,
              color: AppTheme.accentAmber,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.panelDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppTheme.accentCyan, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Quick Tips',
                        style: GoogleFonts.rajdhani(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Use the Step button for manual control\n'
                    '• Toggle Auto Run for continuous animation\n'
                    '• Adjust speed with the slider at the bottom\n'
                    '• Tap any info icon for explanations',
                    style: GoogleFonts.rajdhani(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required int index,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Navigate to $title using bottom nav'), duration: const Duration(seconds: 1)),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.rajdhani(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.rajdhani(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).slideX(begin: -0.1);
  }
}