import 'package:flutter/material.dart';

/// Design tokens from the design brief (docs/design.md).
abstract final class KaghazColors {
  static const canvas = Color(0xFFF4F2EE);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFECE9E3);
  static const outline = Color(0xFFDDD8CF);
  static const textPrimary = Color(0xFF1F2024);
  static const textSecondary = Color(0xFF6B6A67);
  static const accent = Color(0xFF3B5BDB);
  static const accentSoft = Color(0xFFE6EBFF);
  static const danger = Color(0xFFD64545);
  static const pageLine = Color(0xFFE3E6EC);
  static const pageDot = Color(0xFFC9CED8);

  static const darkCanvas = Color(0xFF121316);
  static const darkSurface = Color(0xFF1C1D21);
  static const darkSurfaceMuted = Color(0xFF26282D);
  static const darkOutline = Color(0xFF33353B);
  static const darkTextPrimary = Color(0xFFEDEDEF);
  static const darkTextSecondary = Color(0xFF9A9BA1);
  static const darkAccent = Color(0xFF7C93FF);
  static const darkAccentSoft = Color(0xFF262F55);

  /// Notebook cover and folder colours.
  static const covers = [
    Color(0xFF3B5BDB),
    Color(0xFF1C7ED6),
    Color(0xFF0CA678),
    Color(0xFF2F9E44),
    Color(0xFFF2B705),
    Color(0xFFE8590C),
    Color(0xFFD6336C),
    Color(0xFF7048E8),
    Color(0xFF495057),
    Color(0xFFA0785A),
  ];

  static const pens = [
    Color(0xFF1F2024),
    Color(0xFF1C64F2),
    Color(0xFFE03131),
    Color(0xFF2F9E44),
    Color(0xFF7048E8),
    Color(0xFFE8590C),
    Color(0xFFF2B705),
    Color(0xFF0CA678),
    Color(0xFFD6336C),
    Color(0xFF495057),
  ];

  static const highlighters = [
    Color(0xFFFFE066),
    Color(0xFF8CE99A),
    Color(0xFF74C0FC),
    Color(0xFFFFA8A8),
    Color(0xFFFFC078),
  ];
}

/// Extra colours that Material's scheme has no slot for.
class KaghazTheme extends ThemeExtension<KaghazTheme> {
  const KaghazTheme({
    required this.canvas,
    required this.accentSoft,
    required this.textSecondary,
  });

  final Color canvas;
  final Color accentSoft;
  final Color textSecondary;

  static KaghazTheme of(BuildContext context) =>
      Theme.of(context).extension<KaghazTheme>()!;

  @override
  KaghazTheme copyWith({Color? canvas, Color? accentSoft, Color? textSecondary}) =>
      KaghazTheme(
        canvas: canvas ?? this.canvas,
        accentSoft: accentSoft ?? this.accentSoft,
        textSecondary: textSecondary ?? this.textSecondary,
      );

  @override
  KaghazTheme lerp(KaghazTheme? other, double t) {
    if (other == null) return this;
    return KaghazTheme(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
    );
  }
}

ThemeData buildTheme(Brightness brightness) {
  final light = brightness == Brightness.light;
  final accent = light ? KaghazColors.accent : KaghazColors.darkAccent;
  final accentSoft = light ? KaghazColors.accentSoft : KaghazColors.darkAccentSoft;
  final surface = light ? KaghazColors.surface : KaghazColors.darkSurface;
  final muted = light ? KaghazColors.surfaceMuted : KaghazColors.darkSurfaceMuted;
  final outline = light ? KaghazColors.outline : KaghazColors.darkOutline;
  final text = light ? KaghazColors.textPrimary : KaghazColors.darkTextPrimary;
  final textSecondary =
      light ? KaghazColors.textSecondary : KaghazColors.darkTextSecondary;
  final canvas = light ? KaghazColors.canvas : KaghazColors.darkCanvas;

  final scheme = ColorScheme.fromSeed(seedColor: accent, brightness: brightness)
      .copyWith(
    primary: accent,
    onPrimary: light ? Colors.white : const Color(0xFF0E1330),
    primaryContainer: accentSoft,
    onPrimaryContainer: accent,
    secondaryContainer: accentSoft,
    onSecondaryContainer: accent,
    surface: surface,
    onSurface: text,
    onSurfaceVariant: textSecondary,
    surfaceContainerLowest: surface,
    surfaceContainerLow: surface,
    surfaceContainer: muted,
    surfaceContainerHigh: muted,
    surfaceContainerHighest: muted,
    outline: textSecondary,
    outlineVariant: outline,
    error: KaghazColors.danger,
  );

  final base = ThemeData(
    colorScheme: scheme,
    fontFamily: 'Vazirmatn',
    scaffoldBackgroundColor: canvas,
    dividerColor: outline,
  );
  final t = base.textTheme;
  return base.copyWith(
    extensions: [
      KaghazTheme(canvas: canvas, accentSoft: accentSoft, textSecondary: textSecondary),
    ],
    textTheme: t.copyWith(
      headlineSmall: t.headlineSmall?.copyWith(fontSize: 28, height: 36 / 28, fontWeight: FontWeight.w700),
      titleLarge: t.titleLarge?.copyWith(fontSize: 20, height: 28 / 20, fontWeight: FontWeight.w600),
      titleMedium: t.titleMedium?.copyWith(fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w600),
      bodyMedium: t.bodyMedium?.copyWith(fontSize: 14, height: 22 / 14),
      bodySmall: t.bodySmall?.copyWith(fontSize: 12, height: 16 / 12, color: textSecondary),
      labelLarge: t.labelLarge?.copyWith(fontSize: 13, height: 18 / 13, fontWeight: FontWeight.w500),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 52,
      shape: Border(bottom: BorderSide(color: outline)),
      titleTextStyle: t.titleLarge?.copyWith(
        fontFamily: 'Vazirmatn',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: text,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: surface,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: outline),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: outline),
      ),
    ),
    menuTheme: MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(surface),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: outline),
        )),
      ),
    ),
    drawerTheme: DrawerThemeData(backgroundColor: surface),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      width: 420,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      actionTextColor: light ? KaghazColors.darkAccent : accent,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accent,
      foregroundColor: scheme.onPrimary,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: text,
        side: BorderSide(color: outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: accent, width: 1.5),
      ),
    ),
  );
}

/// Shadow for floating elements: toolbar, popovers, dragged items.
const floatingShadow = [
  BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 4)),
];

const _persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

/// Replaces Latin digits with Persian ones for display.
String fa(Object value) => value.toString().replaceAllMapped(
      RegExp(r'[0-9]'),
      (m) => _persianDigits[int.parse(m[0]!)],
    );

String relativeDate(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'همین الان';
  if (diff.inHours < 1) return '${fa(diff.inMinutes)} دقیقه پیش';
  if (diff.inDays < 1) return '${fa(diff.inHours)} ساعت پیش';
  if (diff.inDays == 1) return 'دیروز';
  if (diff.inDays < 7) return '${fa(diff.inDays)} روز پیش';
  if (diff.inDays < 30) return '${fa(diff.inDays ~/ 7)} هفته پیش';
  return fa('${date.year}/${date.month}/${date.day}');
}
