import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizationcontext.l10n`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @app_title.
  ///
  /// In en, this message translates to:
  /// **'Chinese Chess'**
  String get app_title;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @open_menu.
  ///
  /// In en, this message translates to:
  /// **'Open Menu'**
  String get open_menu;

  /// No description provided for @flip_board.
  ///
  /// In en, this message translates to:
  /// **'Flip Board'**
  String get flip_board;

  /// No description provided for @copy_code.
  ///
  /// In en, this message translates to:
  /// **'Copy Chess Code'**
  String get copy_code;

  /// No description provided for @parse_code.
  ///
  /// In en, this message translates to:
  /// **'Parse Chess Code'**
  String get parse_code;

  /// No description provided for @edit_code.
  ///
  /// In en, this message translates to:
  /// **'Edit Chess'**
  String get edit_code;

  /// No description provided for @new_game.
  ///
  /// In en, this message translates to:
  /// **'New Game'**
  String get new_game;

  /// No description provided for @load_manual.
  ///
  /// In en, this message translates to:
  /// **'Load Chess Manual'**
  String get load_manual;

  /// No description provided for @save_manual.
  ///
  /// In en, this message translates to:
  /// **'Save Chess Manual'**
  String get save_manual;

  /// No description provided for @setting.
  ///
  /// In en, this message translates to:
  /// **'Setting'**
  String get setting;

  /// No description provided for @feature_not_available.
  ///
  /// In en, this message translates to:
  /// **'Feature is not available'**
  String get feature_not_available;

  /// No description provided for @mode_robot.
  ///
  /// In en, this message translates to:
  /// **'Robot Mode'**
  String get mode_robot;

  /// No description provided for @mode_online.
  ///
  /// In en, this message translates to:
  /// **'Online Mode'**
  String get mode_online;

  /// No description provided for @mode_free.
  ///
  /// In en, this message translates to:
  /// **'Free Mode'**
  String get mode_free;

  /// No description provided for @clear_all.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clear_all;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get save;

  /// No description provided for @trusteeship_to_robots.
  ///
  /// In en, this message translates to:
  /// **'Trusteeship to Robots'**
  String get trusteeship_to_robots;

  /// No description provided for @cancel_robots.
  ///
  /// In en, this message translates to:
  /// **'Cancel Trusteeship'**
  String get cancel_robots;

  /// No description provided for @thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get thinking;

  /// No description provided for @current_info.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current_info;

  /// No description provided for @manual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manual;

  /// No description provided for @the_event.
  ///
  /// In en, this message translates to:
  /// **'Event: '**
  String get the_event;

  /// No description provided for @the_site.
  ///
  /// In en, this message translates to:
  /// **'Site: '**
  String get the_site;

  /// No description provided for @the_date.
  ///
  /// In en, this message translates to:
  /// **'Date: '**
  String get the_date;

  /// No description provided for @the_round.
  ///
  /// In en, this message translates to:
  /// **'Round: '**
  String get the_round;

  /// No description provided for @the_red.
  ///
  /// In en, this message translates to:
  /// **'Red: '**
  String get the_red;

  /// No description provided for @the_black.
  ///
  /// In en, this message translates to:
  /// **'Black: '**
  String get the_black;

  /// No description provided for @step_start.
  ///
  /// In en, this message translates to:
  /// **'==Start=='**
  String get step_start;

  /// No description provided for @exit_now.
  ///
  /// In en, this message translates to:
  /// **'Exit Now ?'**
  String get exit_now;

  /// No description provided for @dont_exit.
  ///
  /// In en, this message translates to:
  /// **'Wait a moment'**
  String get dont_exit;

  /// No description provided for @yes_exit.
  ///
  /// In en, this message translates to:
  /// **'Yes exit'**
  String get yes_exit;

  /// No description provided for @click_again_to_exit.
  ///
  /// In en, this message translates to:
  /// **'Click again to Exit'**
  String get click_again_to_exit;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @situation_code.
  ///
  /// In en, this message translates to:
  /// **'Chess Code'**
  String get situation_code;

  /// No description provided for @invalid_code.
  ///
  /// In en, this message translates to:
  /// **'Invalid Chess Code'**
  String get invalid_code;

  /// No description provided for @copy_success.
  ///
  /// In en, this message translates to:
  /// **'Copy Success'**
  String get copy_success;

  /// No description provided for @save_success.
  ///
  /// In en, this message translates to:
  /// **'Save Success'**
  String get save_success;

  /// No description provided for @select_directory_save.
  ///
  /// In en, this message translates to:
  /// **'Select a Directory to Save'**
  String get select_directory_save;

  /// No description provided for @save_filename.
  ///
  /// In en, this message translates to:
  /// **'Filename to Save'**
  String get save_filename;

  /// No description provided for @select_pgn_file.
  ///
  /// In en, this message translates to:
  /// **'Select .PGN file'**
  String get select_pgn_file;

  /// No description provided for @recommend_move.
  ///
  /// In en, this message translates to:
  /// **'Recommend Move'**
  String get recommend_move;

  /// No description provided for @remark.
  ///
  /// In en, this message translates to:
  /// **'Remark'**
  String get remark;

  /// No description provided for @no_remark.
  ///
  /// In en, this message translates to:
  /// **'No remark'**
  String get no_remark;

  /// No description provided for @check.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get check;

  /// No description provided for @checkmate.
  ///
  /// In en, this message translates to:
  /// **'Checkmate'**
  String get checkmate;

  /// No description provided for @long_recheck_loose.
  ///
  /// In en, this message translates to:
  /// **'The same move 3 round to Lose'**
  String get long_recheck_loose;

  /// No description provided for @no_eat_to_draw.
  ///
  /// In en, this message translates to:
  /// **'60 round with no eat to Draw'**
  String get no_eat_to_draw;

  /// No description provided for @trapped.
  ///
  /// In en, this message translates to:
  /// **'Checkmate'**
  String get trapped;

  /// No description provided for @red_loose.
  ///
  /// In en, this message translates to:
  /// **'Loose'**
  String get red_loose;

  /// No description provided for @red_win.
  ///
  /// In en, this message translates to:
  /// **'Win'**
  String get red_win;

  /// No description provided for @red_draw.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get red_draw;

  /// No description provided for @request_draw.
  ///
  /// In en, this message translates to:
  /// **'Asked for a draw'**
  String get request_draw;

  /// No description provided for @agree_to_draw.
  ///
  /// In en, this message translates to:
  /// **'Agree to draw'**
  String get agree_to_draw;

  /// No description provided for @request_retract.
  ///
  /// In en, this message translates to:
  /// **'Asked for a Retract'**
  String get request_retract;

  /// No description provided for @agree_retract.
  ///
  /// In en, this message translates to:
  /// **'Agree to retract'**
  String get agree_retract;

  /// No description provided for @disagree_retract.
  ///
  /// In en, this message translates to:
  /// **'Disagree to retract'**
  String get disagree_retract;

  /// No description provided for @cant_send_check.
  ///
  /// In en, this message translates to:
  /// **'You can\'t send Check'**
  String get cant_send_check;

  /// No description provided for @pls_parry_check.
  ///
  /// In en, this message translates to:
  /// **'Please parry the Check'**
  String get pls_parry_check;

  /// No description provided for @one_more_game.
  ///
  /// In en, this message translates to:
  /// **'New Game'**
  String get one_more_game;

  /// No description provided for @let_me_see.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get let_me_see;

  /// No description provided for @setting_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get setting_title;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
