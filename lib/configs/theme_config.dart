import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DayPlannerTheme {

  @required late Brightness brightness;

  @required late Color background;

  @required late Color primary;
  @required late Color secondary;
  @required late Color tertiary;
  @required late Color quaternary;
  @required late Color quinary;

  @required late Color lightKey;
  @required late Color darkKey;

  @required late Color cancelled;
  @required late Color disabled;

  // Pour appeler les couleurs de la palette: Theme.of(context).extension<Palette>()!.color
  Palette themePalette() => Palette(background: background, primary: primary, secondary: secondary, tertiary: tertiary, quaternary: quaternary, quinary: quinary,
      lightKey: lightKey, darkKey: darkKey, cancelled: cancelled, disabled: disabled);

  ThemeData getThemeData() => ThemeData(
      brightness: brightness,
      dialogBackgroundColor: background,

      buttonTheme: ButtonThemeData(buttonColor: quaternary, textTheme: ButtonTextTheme.normal),
      disabledColor: darkKey,

      fontFamily: GoogleFonts.quicksand().fontFamily,

      outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(darkKey),
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      return secondary.withOpacity(0.7);
                    } else if (states.contains(MaterialState.disabled)) {
                      return disabled;
                    }
                    return secondary;
                  }),
              side: MaterialStateProperty.all(BorderSide(color: quinary)),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)
                  )
              ),
            textStyle: MaterialStateProperty.all(TextStyle(fontFamily: GoogleFonts.roboto().fontFamily))
          )),

      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(lightKey),
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      return tertiary.withOpacity(0.7);
                    } else if (states.contains(MaterialState.disabled)) {
                      return disabled;
                    }
                    return tertiary;
                  }),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))
              )
          )
      ),

      sliderTheme: SliderThemeData(
          activeTickMarkColor: lightKey,
          activeTrackColor: tertiary,
          valueIndicatorTextStyle: TextStyle(color: lightKey),
          thumbColor: tertiary
      ),

      dropdownMenuTheme: DropdownMenuThemeData(
          menuStyle: MenuStyle(backgroundColor: MaterialStateProperty.all(lightKey)),
      ),

      timePickerTheme: TimePickerThemeData(
        backgroundColor: background
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: secondary,
        contentTextStyle: TextStyle(color: darkKey),
      ),

      colorScheme:
        ColorScheme(
          brightness: brightness,

          background: background,
          onBackground: lightKey,

          primary: quinary,
          onPrimary: primary,

          secondary: secondary, // AppBar
          onSecondary: secondary,

          error: lightKey, // Error
          onError: cancelled,

          surface: quaternary,
          onSurface: quinary, // Texte et icônes

        )
  ).copyWith(extensions: <ThemeExtension<dynamic>>[
    themePalette()
  ]);
}


class DayPlannerLight extends DayPlannerTheme {

  @override
  Brightness brightness = Brightness.light;

  @override
  Color background = const Color(0xFFFFF4F3);

  @override
  Color primary = const Color(0xFFFBBBAD);

  @override
  Color secondary = const Color(0xFFEE8695);

  @override
  Color tertiary = const Color(0xFF4A7A96);

  @override
  Color quaternary = const Color(0xFF333F58);

  @override
  Color quinary = const Color(0xFF292831);

  @override
  Color lightKey = Colors.white;

  @override
  Color darkKey = Colors.black;

  @override
  Color cancelled = Colors.redAccent;

  @override
  Color disabled = Colors.grey;

}

class DayPlannerDark extends DayPlannerTheme {

  @override
  Brightness brightness = Brightness.dark;

  @override
  Color background = const Color(0xFF212529);

  @override
  Color primary = const Color(0xFF051923);

  @override
  Color secondary = const Color(0xFF003554);

  @override
  Color tertiary = const Color(0xFF006494);

  @override
  Color quaternary = const Color(0xFF0582CA);

  @override
  Color quinary = const Color(0xFF00A6FB);

  @override
  Color lightKey = Colors.black;

  @override
  Color darkKey = Colors.white;

  @override
  Color cancelled = Colors.red;

  @override
  Color disabled = Colors.grey;

}


class Palette extends ThemeExtension<Palette> {

  Color background;

  Color primary;
  Color secondary;
  Color tertiary;
  Color quaternary;
  Color quinary;

  Color lightKey;
  Color darkKey;

  Color cancelled;
  Color disabled;

  Palette({
    required this.background,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.quaternary,
    required this.quinary,
    required this.lightKey,
    required this.darkKey,
    required this.cancelled,
    required this.disabled
  });

  @override
  Palette copyWith({
    Color? background, Color? primary, Color? secondary, Color? tertiary, Color? quaternary, Color? quinary,
    Color? lightKey, Color? darkKey, Color? cancelled, Color? disabled}) {

    return Palette(
        background: background ?? this.background,
        primary: primary ?? this.primary,
        secondary: secondary ?? this.secondary,
        tertiary: tertiary ?? this.tertiary,
        quaternary: quaternary ?? this.quaternary,
        quinary: quinary ?? this.quinary,
        lightKey: lightKey ?? this.lightKey,
        darkKey: darkKey ?? this.darkKey,
        cancelled: cancelled ?? this.cancelled,
        disabled: disabled ?? this.disabled
    );
  }

  @override
  ThemeExtension<Palette> lerp(covariant ThemeExtension<Palette>? other, double t) {
    if (other is! Palette) {
      return this;
    }

    return Palette(
        background: Color.lerp(background, other.background, t)!,
        primary: Color.lerp(primary, other.primary, t)!,
        secondary: Color.lerp(secondary, other.secondary, t)!,
        tertiary: Color.lerp(tertiary, other.tertiary, t)!,
        quaternary: Color.lerp(quaternary, other.quaternary, t)!,
        quinary: Color.lerp(quinary, other.quinary, t)!,
        lightKey: Color.lerp(lightKey, other.lightKey, t)!,
        darkKey: Color.lerp(darkKey, other.darkKey, t)!,
        cancelled: Color.lerp(cancelled, other.cancelled, t)!,
        disabled: Color.lerp(disabled, other.disabled, t)!
    );
  }
}