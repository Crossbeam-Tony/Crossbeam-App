import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/onboarding_provider.dart';
import '../../services/theme_service.dart';
import '../../models/app_theme.dart';
import '../../models/theme_config.dart';
import '../../widgets/mini_honeycomb.dart';
import '../../components/hex_toggle.dart';

class ThemeSelectionPage extends StatefulWidget {
  const ThemeSelectionPage({Key? key}) : super(key: key);

  @override
  State<ThemeSelectionPage> createState() => _ThemeSelectionPageState();
}

class _ThemeSelectionPageState extends State<ThemeSelectionPage> {
  List<AppTheme> _themesForCurrentMode = [];
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load themes for current mode and preserve existing theme selection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<OnboardingProvider>();
      // Only set default theme if none is selected
      if (provider.themeSlug.isEmpty) {
        provider.setTheme('crossbeam', provider.isDarkMode);
      }
    });
    _loadThemesForCurrentMode();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  TextStyle _getHeaderStyle(BuildContext context, String themeName) {
    // Get the base style
    final baseStyle = Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ) ??
        const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        );

    // Reduce font size for themes that use larger fonts
    switch (themeName.toLowerCase()) {
      case 'cyberpunk':
      case 'synthwave':
      case 'midnight':
        // Orbitron and Space Mono are larger fonts
        return baseStyle.copyWith(fontSize: 20);
      case 'retro':
        // Courier Prime can be larger
        return baseStyle.copyWith(fontSize: 20);
      case 'shoplight':
      case 'sunset':
        // Merriweather and Playfair Display are larger
        return baseStyle.copyWith(fontSize: 20);
      default:
        // Default size for other fonts
        return baseStyle;
    }
  }

  Future<void> _loadThemesForCurrentMode() async {
    final themeService = context.read<ThemeService>();
    final provider = context.read<OnboardingProvider>();
    final isDark = provider.isDarkMode;

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final themes =
          await themeService.fetchThemesByMode(isDark ? 'dark' : 'light');
      if (mounted) {
        setState(() {
          _themesForCurrentMode = themes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _themesForCurrentMode = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<OnboardingProvider, ThemeService>(
      builder: (context, provider, themeService, _) {
        final isDark = themeService.isDarkMode;
        return Column(
          children: [
            // Header row
            Container(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 0.0, bottom: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'Choose Your Theme',
                      style: _getHeaderStyle(context, provider.themeSlug),
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Hexagon toggle switch
                  HexToggle(
                    width: 60,
                    height: 28,
                    value: isDark,
                    activeColor: Theme.of(context).colorScheme.primary,
                    inactiveColor: Theme.of(context).colorScheme.onSurface,
                    onChanged: (val) {
                      // Simply switch the current theme to the new mode
                      provider.setTheme(provider.themeSlug, val);

                      // Reload themes for new mode - only if still mounted
                      if (mounted) {
                        _loadThemesForCurrentMode();
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Subheader
            Container(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 0.0, bottom: 4.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Pick a theme that reflects your style',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Theme Cards List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _themesForCurrentMode.length,
                      key: const PageStorageKey('theme_selection_list'),
                      itemBuilder: (context, index) {
                        final theme = _themesForCurrentMode[index];

                        return Selector<OnboardingProvider, bool>(
                          selector: (context, provider) =>
                              theme.name == provider.themeSlug,
                          builder: (context, isSelected, child) {
                            return ThemeCard(
                              key: ValueKey(theme.name),
                              theme: theme,
                              isSelected: isSelected,
                              onTap: () {
                                context
                                    .read<OnboardingProvider>()
                                    .setTheme(theme.name, isDark);
                              },
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class ThemeCard extends StatefulWidget {
  final AppTheme theme;
  final bool isSelected;
  final VoidCallback onTap;

  const ThemeCard({
    Key? key,
    required this.theme,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  State<ThemeCard> createState() => _ThemeCardState();
}

class _ThemeCardState extends State<ThemeCard> {
  ThemeConfig? _enhancedTheme;

  @override
  void initState() {
    super.initState();
    // Temporarily disabled to prevent theme changing on scroll
    // _loadEnhancedTheme();
  }

  Future<void> _loadEnhancedTheme() async {
    // Only load enhanced theme if we don't already have it
    if (_enhancedTheme != null) return;

    final themeService = context.read<ThemeService>();
    final provider = context.read<OnboardingProvider>();
    final isDark = provider.isDarkMode;

    try {
      final enhancedTheme =
          await themeService.fetchEnhancedTheme(widget.theme.name, isDark);
      if (mounted) {
        setState(() {
          _enhancedTheme = enhancedTheme;
        });
      }
    } catch (e) {
      // Fallback to basic theme if enhanced theme fails to load
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildCardWithEffects();
  }

  Widget _buildCardWithEffects() {
    final theme = widget.theme;
    final enhancedTheme = _enhancedTheme;

    // Base card content
    Widget cardContent = Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: widget.isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
        side: widget.isSelected
            ? BorderSide(color: theme.primary, width: 2)
            : BorderSide.none,
      ),
      color: theme.background,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(5),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Theme name and selection indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      theme.name
                          .split('-')
                          .map((word) =>
                              word[0].toUpperCase() +
                              word.substring(1).toLowerCase())
                          .join(' '),
                      style: _getThemeFont(theme.name).copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.onSurface,
                      ),
                    ),
                  ),
                  if (widget.isSelected)
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(28, 28),
                            painter: HexCheckPainter(
                              color: theme.primary,
                              borderColor: theme.primary.withOpacity(0.7),
                              borderWidth: 2.0,
                            ),
                          ),
                          Icon(
                            Icons.check,
                            color: theme.onPrimary,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // MiniHoneycomb widget showing theme colors
              Center(
                child: MiniHoneycomb(
                  background: theme.background,
                  surface: theme.surface,
                  primary: theme.primary,
                  onPrimary: theme.onPrimary,
                  text: theme.onSurface, // Using onSurface as the text color
                  border: theme.divider,
                  error: theme.error,
                  cellSize: 80,
                  isDarkMode: theme.mode == 'dark',
                ),
              ),
              const SizedBox(height: 8),

              // Color chips
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildRectangularColorChip(
                              'Primary', theme.primary, theme.onPrimary),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildRectangularColorChip(
                              'Surface', theme.surface, theme.onSurface),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildRectangularColorChip(
                              'Background', theme.background, theme.onSurface),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildRectangularColorChip(
                              'Divider', theme.divider, theme.onSurface),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Theme description and font preview
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: theme.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTypographyPreview(context, theme),
                    const SizedBox(height: 8),
                    _buildThemeDescription(context, theme),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Apply effects based on enhanced theme
    if (enhancedTheme != null && enhancedTheme.effects != 'flat') {
      return _applyThemeEffects(cardContent, enhancedTheme);
    }

    return cardContent;
  }

  Widget _applyThemeEffects(Widget child, ThemeConfig theme) {
    switch (theme.effects) {
      case 'neon-glow':
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: theme.primary.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        );
      case 'scanline':
        return Stack(
          children: [
            child,
            // Add scanline overlay effect
            Positioned.fill(
              child: CustomPaint(
                painter: ScanlinePainter(),
              ),
            ),
          ],
        );
      default:
        return child;
    }
  }

  Widget _buildHexColorChip(String label, Color color, Color textColor) {
    return SizedBox(
      height: 28,
      child: CustomPaint(
        painter: FlatTopHexPainter(
          color: color,
          borderColor: color.withOpacity(0.3),
          borderWidth: 1.0,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRectangularColorChip(
      String label, Color color, Color textColor) {
    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.0,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildThemeDescription(BuildContext context, AppTheme theme) {
    String description = _getThemeDescription(theme.name);
    final googleFont = _getThemeFont(theme.name);

    return Text(
      description,
      style: googleFont.copyWith(
        fontSize: 14,
        color: theme.onSurface,
        height: 1.4,
      ),
    );
  }

  String _getThemeDescription(String themeName) {
    switch (themeName.toLowerCase()) {
      case 'prompt':
        return 'A clean, modern interface with vibrant green accents. Features crisp whites and deep blacks for maximum readability, with energetic lime green highlights that pop against the neutral background.';
      case 'retro-heat':
        return 'Warm, nostalgic tones inspired by vintage aesthetics. Rich reds and warm backgrounds create a cozy, inviting atmosphere with subtle orange undertones that evoke classic design eras.';
      case 'high-contrast':
        return 'Bold, accessible design with maximum contrast. Sharp black and white elements create clear visual distinctions, with bright blue accents that stand out for easy navigation and readability.';
      case 'tactical':
        return 'Professional and precise with a military-inspired color palette. Clean lines and muted tones feature sophisticated grays with subtle blue undertones for a serious, focused appearance.';
      case 'road-rash':
        return 'Edgy and rebellious with bold reds and dark accents. Deep reds contrast against light backgrounds, creating a high-energy aesthetic with strong visual impact and dynamic color relationships.';
      case 'shoplight':
        return 'Warm, inviting tones reminiscent of cozy workshop lighting. Earthy browns and warm whites create a comfortable, familiar feel with subtle orange highlights that mimic natural lighting.';
      case 'night-ops':
        return 'Stealthy dark theme with subtle contrasts. Deep blacks and muted grays provide a sophisticated backdrop, with minimal color accents that maintain focus without visual distraction.';
      case 'bone-white':
        return 'Minimalist and clean with warm off-whites and subtle orange accents. Soft, neutral backgrounds with gentle orange highlights create a calm, uncluttered aesthetic that promotes clarity.';
      case 'panther':
        return 'Sleek and sophisticated with deep blacks and subtle grays. A premium feel that\'s both powerful and refined, featuring elegant dark tones with minimal, purposeful color accents.';
      case 'iron-frost':
        return 'Cool, metallic tones with a frosty blue palette. Modern and industrial with sophisticated gray backgrounds and crisp blue accents that create a tech-forward, professional aesthetic.';
      case 'harvest-clay':
        return 'Rich, earthy tones inspired by autumn harvests. Warm oranges and deep browns create a grounded, natural feeling with organic color relationships that evoke the changing seasons.';
      case 'urban-fog':
        return 'Muted, sophisticated grays with subtle blue undertones. A calm, focused environment with refined neutral tones and gentle blue accents that create a professional, urban aesthetic.';
      case 'gold-rush':
        return 'Luxurious and vibrant with golden yellows and rich backgrounds. Bold and optimistic with warm golden tones that create a premium, energetic feel with strong visual presence.';
      case 'red-white-blue':
        return 'Classic patriotic colors with a modern twist. Clean, trustworthy design featuring traditional red, white, and blue elements arranged in a contemporary, accessible layout.';
      case 'cyberpunk':
        return 'Futuristic neon aesthetics with purple and cyan accents. Vibrant purple backgrounds with electric blue highlights create a high-tech, otherworldly appearance with strong visual impact.';
      case 'earth-tone':
        return 'Natural, organic colors inspired by the earth. Browns, greens, and warm neutrals create a grounded, peaceful feeling with natural color relationships that promote calm and focus.';
      case 'synthwave':
        return 'Retro-futuristic with vibrant purples and electric blues. Inspired by 80s aesthetics and synth music culture, featuring bold purple backgrounds with neon blue accents for a nostalgic yet modern feel.';
      case 'marine':
        return 'Ocean-inspired blues and clean whites. Refreshing and calming with various shades of blue that mimic the sea, creating a tranquil, open feeling with crisp white highlights.';
      case 'crossbeam':
        return 'Our signature theme with muted orange accents. Balanced, professional design featuring sophisticated neutral backgrounds with carefully calibrated orange highlights that are uniquely Crossbeam.';
      default:
        return 'A carefully crafted theme designed for optimal user experience and visual appeal, featuring harmonious color relationships and thoughtful design elements.';
    }
  }

  TextStyle _getThemeFont(String themeName) {
    // Map theme names to fonts (you can expand this based on your database)
    switch (themeName.toLowerCase()) {
      case 'prompt':
        return GoogleFonts.inter();
      case 'retro-heat':
      case 'bone-white':
      case 'harvest-clay':
      case 'earth-tone':
        return GoogleFonts.lora();
      case 'high-contrast':
      case 'panther':
      case 'iron-frost':
        return GoogleFonts.roboto();
      case 'road-rash':
      case 'night-ops':
        return GoogleFonts.roboto();
      case 'shoplight':
        return GoogleFonts.merriweather();
      case 'marine':
        return GoogleFonts.openSans();
      case 'cyberpunk':
      case 'synthwave':
        return GoogleFonts.orbitron();
      default:
        return GoogleFonts.inter();
    }
  }

  Widget _buildTypographyPreview(BuildContext context, AppTheme theme) {
    final googleFont = _getThemeFont(theme.name);

    return Text(
      'Typography Preview',
      style: googleFont.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: theme.onSurface.withOpacity(0.7),
      ),
    );
  }
}

class HexGaugePainter extends CustomPainter {
  final bool isActive;
  final Gradient gradient;
  final Color activeColor;
  final Color inactiveColor;

  HexGaugePainter({
    required this.isActive,
    required this.gradient,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final double w = size.width, h = size.height;
    final double r = w / 2;
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * pi / 180;
      final x = w / 2 + r * 0.95 * cos(angle);
      final y = h / 2 + r * 0.95 * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
    final border = Paint()
      ..color = isActive ? activeColor : inactiveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ThemeHexPainter extends CustomPainter {
  final Color background;
  final Color border;
  final double borderWidth;
  final Gradient gradient;
  final bool isSelected;
  ThemeHexPainter(
      {required this.background,
      required this.border,
      required this.borderWidth,
      required this.gradient,
      required this.isSelected});
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final double w = size.width, h = size.height;
    final double r = w / 2;
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * pi / 180;
      final x = w / 2 + r * 0.95 * cos(angle);
      final y = h / 2 + r * 0.95 * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    final fill = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fill);
    final borderPaint = Paint()
      ..color = border
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawPath(path, borderPaint);
    if (isSelected) {
      final overlay = Paint()
        ..color = Colors.white.withOpacity(0.08)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, overlay);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class HexNavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isDark;
  const HexNavButton(
      {Key? key,
      required this.icon,
      required this.label,
      this.onTap,
      required this.isDark})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        size: const Size(56, 56),
        painter: ThemeHexPainter(
          background: isDark ? Color(0xFF23262B) : Colors.white,
          border: Color(0xFFFF9800),
          borderWidth: 3.0,
          gradient: LinearGradient(
            colors: isDark
                ? [Color(0xFF23262B), Color(0xFF181A20)]
                : [Colors.white, Color(0xFFF5F5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          isSelected: false,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Color(0xFFFF9800), size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Color(0xFFFF9800),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// HexSwitch class removed - replaced with HexToggle

class FlatTopHexPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final double borderWidth;

  FlatTopHexPainter({
    required this.color,
    required this.borderColor,
    this.borderWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final double w = size.width, h = size.height;

    // Create a flat-top hexagon
    // The hexagon will be wider than tall (flat-top orientation)
    final double hexHeight = h * 0.8; // Use 80% of container height
    final double hexWidth = w * 0.95; // Use 95% of container width

    // Calculate the points for a flat-top hexagon
    final double centerX = w / 2;
    final double centerY = h / 2;

    // Top edge (flat)
    final double topLeftX = centerX - hexWidth / 2;
    final double topLeftY = centerY - hexHeight / 2;
    final double topRightX = centerX + hexWidth / 2;
    final double topRightY = centerY - hexHeight / 2;

    // Right edge (angled)
    final double rightX = centerX + hexWidth / 2;
    final double rightY = centerY;

    // Bottom edge (flat)
    final double bottomRightX = centerX + hexWidth / 2;
    final double bottomRightY = centerY + hexHeight / 2;
    final double bottomLeftX = centerX - hexWidth / 2;
    final double bottomLeftY = centerY + hexHeight / 2;

    // Left edge (angled)
    final double leftX = centerX - hexWidth / 2;
    final double leftY = centerY;

    // Draw the hexagon path
    path.moveTo(topLeftX, topLeftY);
    path.lineTo(topRightX, topRightY);
    path.lineTo(rightX, rightY);
    path.lineTo(bottomRightX, bottomRightY);
    path.lineTo(bottomLeftX, bottomLeftY);
    path.lineTo(leftX, leftY);
    path.close();

    // Fill the hexagon
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Draw the border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class HexCheckPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final double borderWidth;

  HexCheckPainter({
    required this.color,
    required this.borderColor,
    this.borderWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final double w = size.width, h = size.height;
    final double r = w / 2 - borderWidth;

    // Create a proper hexagon (not flat-top)
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * pi / 180;
      final x = w / 2 + r * cos(angle);
      final y = h / 2 + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Fill the hexagon
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Draw the border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Custom painter for scanline effect
class ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..strokeWidth = 1.0;

    // Draw horizontal scanlines
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
