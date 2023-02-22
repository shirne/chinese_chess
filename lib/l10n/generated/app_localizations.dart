import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
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

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Chinese Chess'**
  String get appTitle;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @openMenu.
  ///
  /// In en, this message translates to:
  /// **'Open Menu'**
  String get openMenu;

  /// No description provided for @flipBoard.
  ///
  /// In en, this message translates to:
  /// **'Flip Board'**
  String get flipBoard;

  /// No description provided for @copyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy Chess Code'**
  String get copyCode;

  /// No description provided for @parseCode.
  ///
  /// In en, this message translates to:
  /// **'Parse Chess Code'**
  String get parseCode;

  /// No description provided for @editCode.
  ///
  /// In en, this message translates to:
  /// **'Edit Chess'**
  String get editCode;

  /// No description provided for @newGame.
  ///
  /// In en, this message translates to:
  /// **'New Game'**
  String get newGame;

  /// No description provided for @loadManual.
  ///
  /// In en, this message translates to:
  /// **'Load Chess Manual'**
  String get loadManual;

  /// No description provided for @saveManual.
  ///
  /// In en, this message translates to:
  /// **'Save Chess Manual'**
  String get saveManual;

  /// No description provided for @setting.
  ///
  /// In en, this message translates to:
  /// **'Setting'**
  String get setting;

  /// No description provided for @featureNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Feature is not available'**
  String get featureNotAvailable;

  /// No description provided for @modeRobot.
  ///
  /// In en, this message translates to:
  /// **'Robot Mode'**
  String get modeRobot;

  /// No description provided for @modeOnline.
  ///
  /// In en, this message translates to:
  /// **'Online Mode'**
  String get modeOnline;

  /// No description provided for @modeFree.
  ///
  /// In en, this message translates to:
  /// **'Free Mode'**
  String get modeFree;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get save;

  /// No description provided for @trusteeshipToRobots.
  ///
  /// In en, this message translates to:
  /// **'Trusteeship to Robots'**
  String get trusteeshipToRobots;

  /// No description provided for @cancelRobots.
  ///
  /// In en, this message translates to:
  /// **'Cancel Trusteeship'**
  String get cancelRobots;

  /// No description provided for @thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get thinking;

  /// No description provided for @currentInfo.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get currentInfo;

  /// No description provided for @manual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manual;

  /// No description provided for @theEvent.
  ///
  /// In en, this message translates to:
  /// **'Event: '**
  String get theEvent;

  /// No description provided for @theSite.
  ///
  /// In en, this message translates to:
  /// **'Site: '**
  String get theSite;

  /// No description provided for @theDate.
  ///
  /// In en, this message translates to:
  /// **'Date: '**
  String get theDate;

  /// No description provided for @theRound.
  ///
  /// In en, this message translates to:
  /// **'Round: '**
  String get theRound;

  /// No description provided for @theRed.
  ///
  /// In en, this message translates to:
  /// **'Red: '**
  String get theRed;

  /// No description provided for @theBlack.
  ///
  /// In en, this message translates to:
  /// **'Black: '**
  String get theBlack;

  /// No description provided for @stepStart.
  ///
  /// In en, this message translates to:
  /// **'==Start=='**
  String get stepStart;

  /// No description provided for @exitNow.
  ///
  /// In en, this message translates to:
  /// **'Exit Now ?'**
  String get exitNow;

  /// No description provided for @dontExit.
  ///
  /// In en, this message translates to:
  /// **'Wait a moment'**
  String get dontExit;

  /// No description provided for @yesExit.
  ///
  /// In en, this message translates to:
  /// **'Yes exit'**
  String get yesExit;

  /// No description provided for @clickAgainToExit.
  ///
  /// In en, this message translates to:
  /// **'Click again to Exit'**
  String get clickAgainToExit;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @situationCode.
  ///
  /// In en, this message translates to:
  /// **'Chess Code'**
  String get situationCode;

  /// No description provided for @invalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid Chess Code'**
  String get invalidCode;

  /// No description provided for @copySuccess.
  ///
  /// In en, this message translates to:
  /// **'Copy Success'**
  String get copySuccess;

  /// No description provided for @saveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Save Success'**
  String get saveSuccess;

  /// No description provided for @selectDirectorySave.
  ///
  /// In en, this message translates to:
  /// **'Select a Directory to Save'**
  String get selectDirectorySave;

  /// No description provided for @saveFilename.
  ///
  /// In en, this message translates to:
  /// **'Filename to Save'**
  String get saveFilename;

  /// No description provided for @selectPgnFile.
  ///
  /// In en, this message translates to:
  /// **'Select .PGN file'**
  String get selectPgnFile;

  /// No description provided for @recommendMove.
  ///
  /// In en, this message translates to:
  /// **'Recommend Move'**
  String get recommendMove;

  /// No description provided for @remark.
  ///
  /// In en, this message translates to:
  /// **'Remark'**
  String get remark;

  /// No description provided for @noRemark.
  ///
  /// In en, this message translates to:
  /// **'No remark'**
  String get noRemark;

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

  /// No description provided for @longRecheckLoose.
  ///
  /// In en, this message translates to:
  /// **'The same move 3 round to Lose'**
  String get longRecheckLoose;

  /// No description provided for @noEatToDraw.
  ///
  /// In en, this message translates to:
  /// **'60 round with no eat to Draw'**
  String get noEatToDraw;

  /// No description provided for @trapped.
  ///
  /// In en, this message translates to:
  /// **'Checkmate'**
  String get trapped;

  /// No description provided for @redLoose.
  ///
  /// In en, this message translates to:
  /// **'Loose'**
  String get redLoose;

  /// No description provided for @redWin.
  ///
  /// In en, this message translates to:
  /// **'Win'**
  String get redWin;

  /// No description provided for @redDraw.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get redDraw;

  /// No description provided for @requestDraw.
  ///
  /// In en, this message translates to:
  /// **'Asked for a draw'**
  String get requestDraw;

  /// No description provided for @agreeToDraw.
  ///
  /// In en, this message translates to:
  /// **'Agree to draw'**
  String get agreeToDraw;

  /// No description provided for @requestRetract.
  ///
  /// In en, this message translates to:
  /// **'Asked for a Retract'**
  String get requestRetract;

  /// No description provided for @agreeRetract.
  ///
  /// In en, this message translates to:
  /// **'Agree to retract'**
  String get agreeRetract;

  /// No description provided for @disagreeRetract.
  ///
  /// In en, this message translates to:
  /// **'Disagree to retract'**
  String get disagreeRetract;

  /// No description provided for @cantSendCheck.
  ///
  /// In en, this message translates to:
  /// **'You can\'t send Check'**
  String get cantSendCheck;

  /// No description provided for @plsParryCheck.
  ///
  /// In en, this message translates to:
  /// **'Please parry the Check'**
  String get plsParryCheck;

  /// No description provided for @oneMoreGame.
  ///
  /// In en, this message translates to:
  /// **'New Game'**
  String get oneMoreGame;

  /// No description provided for @letMeSee.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get letMeSee;

  /// No description provided for @settingTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingTitle;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
