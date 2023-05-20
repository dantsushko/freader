

import 'package:flutter/material.dart';

import '../data/database/database.dart';
class NoAnimationPageTransitionsBuilder extends PageTransitionsBuilder {
  const NoAnimationPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
ThemeData themeFromDB(ThemeEntry theme) => ThemeData(
      textTheme: ThemeData.light().textTheme.copyWith(
            bodyLarge: TextStyle(color: Color(theme.textColor)),
            bodyMedium: TextStyle(color: Color(theme.textColor)),
            bodySmall: TextStyle(color: Color(theme.textColor)),
            displayLarge: TextStyle(color: Color(theme.textColor)),
            displayMedium: TextStyle(color: Color(theme.textColor)),
            displaySmall: TextStyle(color: Color(theme.textColor)),
            headlineLarge: TextStyle(color: Color(theme.textColor)),
            headlineMedium: TextStyle(color: Color(theme.textColor)),
            headlineSmall: TextStyle(color: Color(theme.textColor)),
            titleLarge: TextStyle(color: Color(theme.textColor)),
            titleSmall: TextStyle(color: Color(theme.textColor)),
            titleMedium: TextStyle(color: Color(theme.textColor)),
            labelLarge: TextStyle(color: Color(theme.secondaryTextColor)),
            labelMedium: TextStyle(color: Color(theme.secondaryTextColor)),
            labelSmall: TextStyle(color: Color(theme.secondaryTextColor)),
          ),
          // tooltipTheme: TooltipThemeData(
          //   textStyle: TextStyle(color: Color(theme.backgroundColor)),
          //   decoration: BoxDecoration(
          //     color: Color(theme.controlColor),
          //     borderRadius: BorderRadius.circular(8),
          //   ),
          // ),
    //  pageTransitionsTheme: const PageTransitionsTheme(builders: {
    //     TargetPlatform.iOS: NoAnimationPageTransitionsBuilder(),
    //     TargetPlatform.android: NoAnimationPageTransitionsBuilder(),
    //   },),
    textSelectionTheme: TextSelectionThemeData(selectionColor: Color(theme.highlightColor)),
      colorScheme: convertToColorScheme(theme),
      dividerColor: Color(theme.separatorColor), //divider
      brightness: Brightness.light,
      cardColor: Color(theme.controlColor),
      scaffoldBackgroundColor: Color(theme.backgroundColor),
      primaryColor: Color(theme.accentColor),
      iconTheme: IconThemeData(color: Color(theme.backgroundColor)),
      listTileTheme: ThemeData.light().listTileTheme.copyWith(
            tileColor: Color(theme.controlColor),
            textColor: Color(theme.textColor),
            style: ListTileStyle.list,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
      bottomSheetTheme: ThemeData.light().bottomSheetTheme.copyWith(
            backgroundColor: Color(theme.backgroundColor),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
      appBarTheme: ThemeData.light().appBarTheme.copyWith(
          iconTheme: IconThemeData(color: Color(theme.accentColor)),
          backgroundColor: Color(theme.backgroundColor),
          centerTitle: true,
          elevation: 1,
          titleTextStyle: TextStyle(color: Color(theme.textColor), fontWeight: FontWeight.bold),),
      bottomNavigationBarTheme: ThemeData.light().bottomNavigationBarTheme.copyWith(
          unselectedItemColor: Color(theme.secondaryTextColor),
           elevation: 1,
          backgroundColor: Color(theme.backgroundColor),),
    );
ColorScheme convertToColorScheme(ThemeEntry theme) => ColorScheme(
      brightness: Brightness.light,
      primary: Color(theme.accentColor), // accent
      onPrimary: Color(theme.backgroundColor),
      secondary: Color(theme.accentColor),
      onSecondary: Color(theme.backgroundColor),
      surface: Color(theme.backgroundColor),
      background: Color(theme.backgroundColor), // background
      onBackground: Color(theme.separatorColor),
      error: Color(theme.accentColor),
      onError: Color(theme.backgroundColor),
      onSurface: Color(theme.backgroundColor),
      tertiary: Color(theme.controlColor),
    );
