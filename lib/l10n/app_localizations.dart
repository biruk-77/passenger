import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_en.dart';
import 'app_localizations_om.dart';
import 'app_localizations_so.dart';
import 'app_localizations_ti.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
    Locale('am'),
    Locale('en'),
    Locale('om'),
    Locale('so'),
    Locale('ti')
  ];

  /// No description provided for @pageHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get pageHomeTitle;

  /// No description provided for @whereTo.
  ///
  /// In en, this message translates to:
  /// **'Where to?'**
  String get whereTo;

  /// No description provided for @mapSetDestination.
  ///
  /// In en, this message translates to:
  /// **'Tap to set your Destination'**
  String get mapSetDestination;

  /// No description provided for @mapSetPickup.
  ///
  /// In en, this message translates to:
  /// **'Tap to set your Pickup'**
  String get mapSetPickup;

  /// No description provided for @findingYourLocation.
  ///
  /// In en, this message translates to:
  /// **'Finding your location...'**
  String get findingYourLocation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @chatWithDriver.
  ///
  /// In en, this message translates to:
  /// **'Chat with Driver'**
  String get chatWithDriver;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet.'**
  String get noMessagesYet;

  /// No description provided for @pageSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get pageSettingsTitle;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginWelcomeBack;

  /// No description provided for @loginWithPhoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your phone number'**
  String get loginWithPhoneSubtitle;

  /// No description provided for @loginWithEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your email'**
  String get loginWithEmailSubtitle;

  /// No description provided for @loginMethodPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get loginMethodPhone;

  /// No description provided for @loginMethodEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginMethodEmail;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @errorEnterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a phone number'**
  String get errorEnterPhoneNumber;

  /// No description provided for @errorInvalidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 9 or 10-digit number'**
  String get errorInvalidPhoneNumber;

  /// No description provided for @errorEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email'**
  String get errorEnterEmail;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email.'**
  String get errorInvalidEmail;

  /// No description provided for @errorEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get errorEnterPassword;

  /// No description provided for @sendOtpButton.
  ///
  /// In en, this message translates to:
  /// **'SEND OTP'**
  String get sendOtpButton;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'SIGN IN'**
  String get signInButton;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @drawerProfileSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile Settings'**
  String get drawerProfileSettings;

  /// No description provided for @drawerPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get drawerPaymentMethod;

  /// No description provided for @drawerRideHistory.
  ///
  /// In en, this message translates to:
  /// **'Ride History'**
  String get drawerRideHistory;

  /// No description provided for @drawerSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get drawerSupport;

  /// No description provided for @drawerSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get drawerSettings;

  /// No description provided for @drawerLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get drawerLogout;

  /// No description provided for @drawerGuestUser.
  ///
  /// In en, this message translates to:
  /// **'Guest User'**
  String get drawerGuestUser;

  /// No description provided for @drawerWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get drawerWallet;

  /// No description provided for @drawerRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get drawerRating;

  /// No description provided for @drawerTrips.
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get drawerTrips;

  /// No description provided for @drawerWalletBalance.
  ///
  /// In en, this message translates to:
  /// **'Birr {balance}'**
  String drawerWalletBalance(String balance);

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {versionNumber}'**
  String appVersion(String versionNumber);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get settingsSectionAccount;

  /// No description provided for @settingsEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get settingsEditProfile;

  /// No description provided for @settingsEditProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your name, email, and photo'**
  String get settingsEditProfileSubtitle;

  /// No description provided for @settingsSectionPreferences.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get settingsSectionPreferences;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'ABOUT'**
  String get settingsSectionAbout;

  /// No description provided for @settingsHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get settingsHelpSupport;

  /// No description provided for @settingsTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settingsTermsOfService;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @emergencyContacts.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contacts'**
  String get emergencyContacts;

  /// No description provided for @contactNumber.
  ///
  /// In en, this message translates to:
  /// **'Contact #{number}'**
  String contactNumber(Object number);

  /// No description provided for @contactFullName.
  ///
  /// In en, this message translates to:
  /// **'Contact\'s Full Name'**
  String get contactFullName;

  /// No description provided for @contactPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Contact\'s Phone Number'**
  String get contactPhoneNumber;

  /// No description provided for @addContact.
  ///
  /// In en, this message translates to:
  /// **'Add Contact'**
  String get addContact;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'SAVE CHANGES'**
  String get saveChanges;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @errorEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name.'**
  String get errorEnterName;

  /// No description provided for @errorEnterNameForContact.
  ///
  /// In en, this message translates to:
  /// **'Enter name for contact'**
  String get errorEnterNameForContact;

  /// No description provided for @errorEnterPhoneForContact.
  ///
  /// In en, this message translates to:
  /// **'Enter phone for contact'**
  String get errorEnterPhoneForContact;

  /// No description provided for @errorInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number format'**
  String get errorInvalidPhone;

  /// No description provided for @errorEnterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your current password to set a new one.'**
  String get errorEnterCurrentPassword;

  /// No description provided for @errorEnterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter a new password'**
  String get errorEnterNewPassword;

  /// No description provided for @errorPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get errorPasswordTooShort;

  /// No description provided for @errorPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get errorPasswordsDoNotMatch;

  /// No description provided for @profileUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdateSuccess;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Profile update failed.'**
  String get profileUpdateFailed;

  /// No description provided for @passwordUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully!'**
  String get passwordUpdateSuccess;

  /// No description provided for @passwordUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update password.'**
  String get passwordUpdateFailed;

  /// No description provided for @authWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get authWelcome;

  /// No description provided for @authSignInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account to continue'**
  String get authSignInToContinue;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an Account'**
  String get authCreateAccount;

  /// No description provided for @authGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get you started'**
  String get authGetStarted;

  /// No description provided for @authFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get authFullName;

  /// No description provided for @authPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get authPhoneNumber;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSignIn;

  /// No description provided for @authRegister.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authRegister;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get authNoAccount;

  /// No description provided for @authHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get authHaveAccount;

  /// No description provided for @authErrorEnterFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get authErrorEnterFullName;

  /// No description provided for @authErrorEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a phone number'**
  String get authErrorEnterPhone;

  /// No description provided for @authErrorInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get authErrorInvalidPhone;

  /// No description provided for @authErrorEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get authErrorEnterPassword;

  /// No description provided for @authErrorPasswordShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get authErrorPasswordShort;

  /// No description provided for @authSwitchToRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authSwitchToRegister;

  /// No description provided for @authSwitchToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSwitchToSignIn;

  /// No description provided for @registerCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an Account'**
  String get registerCreateAccount;

  /// No description provided for @registerGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get you started'**
  String get registerGetStarted;

  /// No description provided for @registerFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get registerFullName;

  /// No description provided for @registerPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get registerPhoneNumber;

  /// No description provided for @registerPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registerPassword;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerButton;

  /// No description provided for @registerHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get registerHaveAccount;

  /// No description provided for @registerSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get registerSignIn;

  /// No description provided for @registerErrorEnterFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get registerErrorEnterFullName;

  /// No description provided for @registerErrorEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a phone number'**
  String get registerErrorEnterPhone;

  /// No description provided for @registerErrorInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get registerErrorInvalidPhone;

  /// No description provided for @registerErrorEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get registerErrorEnterPassword;

  /// No description provided for @registerErrorPasswordShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get registerErrorPasswordShort;

  /// No description provided for @historyScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Ride History'**
  String get historyScreenTitle;

  /// No description provided for @historyLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get historyLoading;

  /// No description provided for @historyErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something Went Wrong'**
  String get historyErrorTitle;

  /// No description provided for @historyErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please check your connection.'**
  String get historyErrorMessage;

  /// No description provided for @historyRetryButton.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get historyRetryButton;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Rides Yet'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Your completed trips will appear here.'**
  String get historyEmptyMessage;

  /// No description provided for @historyCardFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get historyCardFrom;

  /// No description provided for @historyCardTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get historyCardTo;

  /// No description provided for @historyCardFare.
  ///
  /// In en, this message translates to:
  /// **'Fare:'**
  String get historyCardFare;

  /// No description provided for @historyCardUnknownLocation.
  ///
  /// In en, this message translates to:
  /// **'Unknown Location'**
  String get historyCardUnknownLocation;

  /// No description provided for @historyStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED'**
  String get historyStatusCompleted;

  /// No description provided for @historyStatusCanceled.
  ///
  /// In en, this message translates to:
  /// **'CANCELED'**
  String get historyStatusCanceled;

  /// No description provided for @historyStatusPending.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get historyStatusPending;

  /// No description provided for @currencySymbol.
  ///
  /// In en, this message translates to:
  /// **'Birr'**
  String get currencySymbol;

  /// No description provided for @discoveryWhereTo.
  ///
  /// In en, this message translates to:
  /// **'Where to?'**
  String get discoveryWhereTo;

  /// No description provided for @discoverySearchDestination.
  ///
  /// In en, this message translates to:
  /// **'Search destination'**
  String get discoverySearchDestination;

  /// No description provided for @discoveryHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get discoveryHome;

  /// No description provided for @discoveryWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get discoveryWork;

  /// No description provided for @discoveryAddHome.
  ///
  /// In en, this message translates to:
  /// **'Add Home'**
  String get discoveryAddHome;

  /// No description provided for @discoveryAddWork.
  ///
  /// In en, this message translates to:
  /// **'Add Work'**
  String get discoveryAddWork;

  /// No description provided for @discoveryFavoritePlaces.
  ///
  /// In en, this message translates to:
  /// **'Favorite Places'**
  String get discoveryFavoritePlaces;

  /// No description provided for @discoveryAddFavoritePrompt.
  ///
  /// In en, this message translates to:
  /// **'Tap the \'+\' to add a favorite destination.'**
  String get discoveryAddFavoritePrompt;

  /// No description provided for @discoveryRecentTrips.
  ///
  /// In en, this message translates to:
  /// **'Recent Trips'**
  String get discoveryRecentTrips;

  /// No description provided for @discoveryRecentTripRemoved.
  ///
  /// In en, this message translates to:
  /// **'Recent trip removed.'**
  String get discoveryRecentTripRemoved;

  /// No description provided for @discoveryClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get discoveryClearAll;

  /// No description provided for @discoveryMenuChangeAddress.
  ///
  /// In en, this message translates to:
  /// **'Change Address'**
  String get discoveryMenuChangeAddress;

  /// No description provided for @discoveryMenuRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get discoveryMenuRemove;

  /// No description provided for @searchingContactingDrivers.
  ///
  /// In en, this message translates to:
  /// **'Contacting Nearby Drivers'**
  String get searchingContactingDrivers;

  /// No description provided for @searchingPleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait while we find a ride for you.'**
  String get searchingPleaseWait;

  /// No description provided for @searchingDetailFrom.
  ///
  /// In en, this message translates to:
  /// **'FROM'**
  String get searchingDetailFrom;

  /// No description provided for @searchingDetailTo.
  ///
  /// In en, this message translates to:
  /// **'TO'**
  String get searchingDetailTo;

  /// No description provided for @searchingDetailVehicle.
  ///
  /// In en, this message translates to:
  /// **'VEHICLE'**
  String get searchingDetailVehicle;

  /// No description provided for @searchingDetailVehicleValue.
  ///
  /// In en, this message translates to:
  /// **'{name} • Est. {price} Birr'**
  String searchingDetailVehicleValue(Object name, Object price);

  /// No description provided for @searchingCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel Search'**
  String get searchingCancelButton;

  /// No description provided for @planningPanelDistance.
  ///
  /// In en, this message translates to:
  /// **'DISTANCE'**
  String get planningPanelDistance;

  /// No description provided for @planningPanelDuration.
  ///
  /// In en, this message translates to:
  /// **'DURATION'**
  String get planningPanelDuration;

  /// No description provided for @planningPanelConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get planningPanelConfirmButton;

  /// No description provided for @planningPanelNoRidesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No ride options available.'**
  String get planningPanelNoRidesAvailable;

  /// No description provided for @planningPanelRideOptionsError.
  ///
  /// In en, this message translates to:
  /// **'Could not load ride options.'**
  String get planningPanelRideOptionsError;

  /// Displays the price for a ride option.
  ///
  /// In en, this message translates to:
  /// **'Birr: {price}'**
  String planningPanelPrice(String price);

  /// No description provided for @planningPanelSelectRide.
  ///
  /// In en, this message translates to:
  /// **'Select a Ride'**
  String get planningPanelSelectRide;

  /// No description provided for @planningPanelConfirmRide.
  ///
  /// In en, this message translates to:
  /// **'Confirm Ride'**
  String get planningPanelConfirmRide;

  /// No description provided for @registerErrorPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get registerErrorPhoneInvalid;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get optional;

  /// No description provided for @registerConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get registerConfirmPassword;

  /// No description provided for @registerErrorEnterConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter confirm password'**
  String get registerErrorEnterConfirmPassword;

  /// No description provided for @registerErrorPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get registerErrorPasswordMismatch;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @registerGetOtp.
  ///
  /// In en, this message translates to:
  /// **'GET OTP'**
  String get registerGetOtp;

  /// No description provided for @registerErrorEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get registerErrorEnterEmail;

  /// No description provided for @registerErrorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get registerErrorInvalidEmail;

  /// No description provided for @driverOnWayEnRouteToDestination.
  ///
  /// In en, this message translates to:
  /// **'En Route to Destination'**
  String get driverOnWayEnRouteToDestination;

  /// No description provided for @driverOnWayDriverArriving.
  ///
  /// In en, this message translates to:
  /// **'Your Driver is Arriving'**
  String get driverOnWayDriverArriving;

  /// No description provided for @driverOnWayBookingId.
  ///
  /// In en, this message translates to:
  /// **'Booking ID:'**
  String get driverOnWayBookingId;

  /// No description provided for @driverOnWayDriverId.
  ///
  /// In en, this message translates to:
  /// **'Driver ID:'**
  String get driverOnWayDriverId;

  /// No description provided for @driverOnWayPickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup:'**
  String get driverOnWayPickup;

  /// No description provided for @driverOnWayDropoff.
  ///
  /// In en, this message translates to:
  /// **'Dropoff:'**
  String get driverOnWayDropoff;

  /// No description provided for @driverOnWayCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get driverOnWayCall;

  /// No description provided for @driverOnWayChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get driverOnWayChat;

  /// No description provided for @driverOnWayCancelRide.
  ///
  /// In en, this message translates to:
  /// **'Cancel Ride'**
  String get driverOnWayCancelRide;

  /// No description provided for @driverOnWayDriverNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Driver N/A'**
  String get driverOnWayDriverNotAvailable;

  /// No description provided for @driverOnWayNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get driverOnWayNotAvailable;

  /// No description provided for @driverOnWayColorNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Color N/A'**
  String get driverOnWayColorNotAvailable;

  /// No description provided for @driverOnWayModelNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Model N/A'**
  String get driverOnWayModelNotAvailable;

  /// No description provided for @driverOnWayPlateNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'PLATE N/A'**
  String get driverOnWayPlateNotAvailable;

  /// No description provided for @driverOnWayVehicleUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get driverOnWayVehicleUnknown;

  /// No description provided for @ongoingTripEnjoyRide.
  ///
  /// In en, this message translates to:
  /// **'Enjoy your ride!'**
  String get ongoingTripEnjoyRide;

  /// No description provided for @ongoingTripOnYourWay.
  ///
  /// In en, this message translates to:
  /// **'You are on your way to the destination.'**
  String get ongoingTripOnYourWay;

  /// No description provided for @ongoingTripDriverOnWay.
  ///
  /// In en, this message translates to:
  /// **'Driver is on the way'**
  String get ongoingTripDriverOnWay;

  /// No description provided for @ongoingTripDriverArrivingIn.
  ///
  /// In en, this message translates to:
  /// **'Your driver will arrive in approximately {eta}'**
  String ongoingTripDriverArrivingIn(String eta);

  /// No description provided for @ongoingTripYourDriver.
  ///
  /// In en, this message translates to:
  /// **'Your Driver'**
  String get ongoingTripYourDriver;

  /// No description provided for @ongoingTripStandardCar.
  ///
  /// In en, this message translates to:
  /// **'Standard Car'**
  String get ongoingTripStandardCar;

  /// No description provided for @ongoingTripPlatePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'...'**
  String get ongoingTripPlatePlaceholder;

  /// No description provided for @ongoingTripDefaultColor.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get ongoingTripDefaultColor;

  /// No description provided for @ongoingTripCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get ongoingTripCall;

  /// No description provided for @ongoingTripChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get ongoingTripChat;

  /// No description provided for @ongoingTripCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get ongoingTripCancel;

  /// No description provided for @postTripCompleted.
  ///
  /// In en, this message translates to:
  /// **'Trip Completed!'**
  String get postTripCompleted;

  /// No description provided for @postTripYourDriver.
  ///
  /// In en, this message translates to:
  /// **'Your Driver'**
  String get postTripYourDriver;

  /// No description provided for @postTripRateExperience.
  ///
  /// In en, this message translates to:
  /// **'Rate your experience'**
  String get postTripRateExperience;

  /// No description provided for @postTripAddComment.
  ///
  /// In en, this message translates to:
  /// **'Add a detailed comment (optional)'**
  String get postTripAddComment;

  /// No description provided for @postTripSubmitFeedback.
  ///
  /// In en, this message translates to:
  /// **'Submit Feedback'**
  String get postTripSubmitFeedback;

  /// No description provided for @postTripSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get postTripSkip;

  /// No description provided for @postTripShowAppreciation.
  ///
  /// In en, this message translates to:
  /// **'Show your appreciation?'**
  String get postTripShowAppreciation;

  /// No description provided for @postTripOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get postTripOther;

  /// No description provided for @postTripFinalFare.
  ///
  /// In en, this message translates to:
  /// **'Final Fare'**
  String get postTripFinalFare;

  /// No description provided for @postTripDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get postTripDistance;

  /// No description provided for @postTripTagExcellentService.
  ///
  /// In en, this message translates to:
  /// **'Excellent Service'**
  String get postTripTagExcellentService;

  /// No description provided for @postTripTagCleanCar.
  ///
  /// In en, this message translates to:
  /// **'Clean Car'**
  String get postTripTagCleanCar;

  /// No description provided for @postTripTagSafeDriver.
  ///
  /// In en, this message translates to:
  /// **'Safe Driver'**
  String get postTripTagSafeDriver;

  /// No description provided for @postTripTagGoodConversation.
  ///
  /// In en, this message translates to:
  /// **'Good Conversation'**
  String get postTripTagGoodConversation;

  /// No description provided for @postTripTagFriendlyAttitude.
  ///
  /// In en, this message translates to:
  /// **'Friendly Attitude'**
  String get postTripTagFriendlyAttitude;

  /// No description provided for @driverInfoWindowVehicleStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get driverInfoWindowVehicleStandard;

  /// No description provided for @driverInfoWindowAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get driverInfoWindowAvailable;

  /// No description provided for @driverInfoWindowOnTrip.
  ///
  /// In en, this message translates to:
  /// **'On Trip'**
  String get driverInfoWindowOnTrip;

  /// No description provided for @driverInfoWindowSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get driverInfoWindowSelect;

  /// No description provided for @notificationRideConfirmedTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Ride is Confirmed!'**
  String get notificationRideConfirmedTitle;

  /// No description provided for @notificationRideConfirmedBody.
  ///
  /// In en, this message translates to:
  /// **'Driver {driverName} is on the way.'**
  String notificationRideConfirmedBody(String driverName);

  /// No description provided for @notificationDriverArrivedTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Driver Has Arrived!'**
  String get notificationDriverArrivedTitle;

  /// No description provided for @notificationDriverArrivedBody.
  ///
  /// In en, this message translates to:
  /// **'Please meet your driver at the pickup location.'**
  String get notificationDriverArrivedBody;

  /// No description provided for @notificationTripStartedTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Trip Has Started'**
  String get notificationTripStartedTitle;

  /// No description provided for @notificationTripStartedBody.
  ///
  /// In en, this message translates to:
  /// **'Enjoy your ride! We wish you a safe journey.'**
  String get notificationTripStartedBody;

  /// No description provided for @notificationTripCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip Completed!'**
  String get notificationTripCompletedTitle;

  /// No description provided for @notificationTripCompletedBody.
  ///
  /// In en, this message translates to:
  /// **'Thank you for riding with us. We hope to see you again soon.'**
  String get notificationTripCompletedBody;

  /// No description provided for @notificationRideCanceledTitle.
  ///
  /// In en, this message translates to:
  /// **'Ride Canceled'**
  String get notificationRideCanceledTitle;

  /// No description provided for @notificationRideCanceledBody.
  ///
  /// In en, this message translates to:
  /// **'Your ride request has been canceled.'**
  String get notificationRideCanceledBody;

  /// No description provided for @notificationRequestSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Ride Requested'**
  String get notificationRequestSentTitle;

  /// No description provided for @notificationRequestSentBody.
  ///
  /// In en, this message translates to:
  /// **'We have received your request and are now searching for nearby drivers.'**
  String get notificationRequestSentBody;

  /// No description provided for @notificationNewMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'New Message from {driverName}'**
  String notificationNewMessageTitle(String driverName);

  /// No description provided for @notificationNoDriversTitle.
  ///
  /// In en, this message translates to:
  /// **'No Drivers Available'**
  String get notificationNoDriversTitle;

  /// No description provided for @notificationNoDriversBody.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find a driver nearby. Please try again in a moment.'**
  String get notificationNoDriversBody;

  /// No description provided for @notificationBookingErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking Error'**
  String get notificationBookingErrorTitle;

  /// No description provided for @arrived.
  ///
  /// In en, this message translates to:
  /// **'Arrived'**
  String get arrived;

  /// No description provided for @editProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep your personal information up to date.'**
  String get editProfileSubtitle;

  /// Notification body when searching for a driver, including the search radius.
  ///
  /// In en, this message translates to:
  /// **'Searching for drivers within a {radius} km radius.'**
  String notificationSearchingBody(String radius);

  /// No description provided for @notificationDriverNearbyTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver is Nearby'**
  String get notificationDriverNearbyTitle;

  /// No description provided for @notificationDriverNearbyBody.
  ///
  /// In en, this message translates to:
  /// **'Your driver is now less than {distance} meters away.'**
  String notificationDriverNearbyBody(String distance);

  /// No description provided for @notificationDriverVeryCloseTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver is Very Close'**
  String get notificationDriverVeryCloseTitle;

  /// No description provided for @notificationDriverVeryCloseBody.
  ///
  /// In en, this message translates to:
  /// **'Get ready! Your driver is almost here.'**
  String get notificationDriverVeryCloseBody;

  /// No description provided for @offlineOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline Order'**
  String get offlineOrderTitle;

  /// No description provided for @offlineRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Ride via SMS'**
  String get offlineRequestTitle;

  /// No description provided for @offlineRequestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No internet? No problem. Enter your locations below and we will call you back to confirm your booking.'**
  String get offlineRequestSubtitle;

  /// No description provided for @pickupLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Pickup Location'**
  String get pickupLocationHint;

  /// No description provided for @destinationLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Destination'**
  String get destinationLocationHint;

  /// No description provided for @pickupValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a pickup location'**
  String get pickupValidationError;

  /// No description provided for @destinationValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a destination'**
  String get destinationValidationError;

  /// No description provided for @prepareSmsButton.
  ///
  /// In en, this message translates to:
  /// **'Prepare SMS Request'**
  String get prepareSmsButton;

  /// No description provided for @smsCouldNotOpenError.
  ///
  /// In en, this message translates to:
  /// **'Could not open your SMS application.'**
  String get smsCouldNotOpenError;

  /// No description provided for @smsGenericError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while creating the SMS.'**
  String get smsGenericError;

  /// No description provided for @step1Title.
  ///
  /// In en, this message translates to:
  /// **'Enter Locations'**
  String get step1Title;

  /// No description provided for @step1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us where to pick you up and where you\'re going.'**
  String get step1Subtitle;

  /// No description provided for @step2Title.
  ///
  /// In en, this message translates to:
  /// **'Prepare SMS'**
  String get step2Title;

  /// No description provided for @step2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll create a text message with your details.'**
  String get step2Subtitle;

  /// No description provided for @step3Title.
  ///
  /// In en, this message translates to:
  /// **'Await Our Call'**
  String get step3Title;

  /// No description provided for @step3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Our team will call you shortly to confirm your ride.'**
  String get step3Subtitle;

  /// No description provided for @smsOfflineLogin.
  ///
  /// In en, this message translates to:
  /// **'No internet? Order by SMS'**
  String get smsOfflineLogin;

  /// No description provided for @smsLaunchSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'SMS App Opened'**
  String get smsLaunchSuccessTitle;

  /// No description provided for @smsLaunchSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Please review the message and press \'Send\' to submit your request.'**
  String get smsLaunchSuccessMessage;

  /// No description provided for @smsCapabilityError.
  ///
  /// In en, this message translates to:
  /// **'This device is not capable of sending SMS messages.'**
  String get smsCapabilityError;

  /// No description provided for @smsLaunchError.
  ///
  /// In en, this message translates to:
  /// **'Could not open the SMS application. Please check your device settings.'**
  String get smsLaunchError;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'offline SMS'**
  String get offline;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'FINISH'**
  String get finish;

  /// No description provided for @completeProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'One Last Step'**
  String get completeProfileTitle;

  /// No description provided for @completeProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile to continue.'**
  String get completeProfileSubtitle;

  /// No description provided for @errorEnterregex.
  ///
  /// In en, this message translates to:
  /// **'check special characters or lower and upper case.'**
  String get errorEnterregex;

  /// No description provided for @mySubscriptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Subscriptions'**
  String get mySubscriptionsTitle;

  /// No description provided for @noSubscriptionsFound.
  ///
  /// In en, this message translates to:
  /// **'No subscriptions found.'**
  String get noSubscriptionsFound;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get statusActive;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get statusPending;

  /// No description provided for @statusInactive.
  ///
  /// In en, this message translates to:
  /// **'INACTIVE'**
  String get statusInactive;

  /// No description provided for @contractDetails.
  ///
  /// In en, this message translates to:
  /// **'Contract Details'**
  String get contractDetails;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @cost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get cost;

  /// No description provided for @routeInformation.
  ///
  /// In en, this message translates to:
  /// **'Route Information'**
  String get routeInformation;

  /// No description provided for @pickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get pickup;

  /// No description provided for @dropoff.
  ///
  /// In en, this message translates to:
  /// **'Dropoff'**
  String get dropoff;

  /// No description provided for @rideSchedule.
  ///
  /// In en, this message translates to:
  /// **'Ride Schedule'**
  String get rideSchedule;

  /// No description provided for @pickupTime.
  ///
  /// In en, this message translates to:
  /// **'Pickup Time'**
  String get pickupTime;

  /// No description provided for @contractTypeIndividual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get contractTypeIndividual;

  /// No description provided for @contractTypeInstitutional.
  ///
  /// In en, this message translates to:
  /// **'Institutional'**
  String get contractTypeInstitutional;

  /// No description provided for @drawerMySubscriptions.
  ///
  /// In en, this message translates to:
  /// **'My Subscriptions'**
  String get drawerMySubscriptions;

  /// No description provided for @saveLocationAs.
  ///
  /// In en, this message translates to:
  /// **'SAVE LOCATION AS'**
  String get saveLocationAs;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @work.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get work;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @goToDestination.
  ///
  /// In en, this message translates to:
  /// **'GO TO DESTINATION'**
  String get goToDestination;

  /// No description provided for @saveAsHome.
  ///
  /// In en, this message translates to:
  /// **'SAVE AS HOME'**
  String get saveAsHome;

  /// No description provided for @saveAsWork.
  ///
  /// In en, this message translates to:
  /// **'SAVE AS WORK'**
  String get saveAsWork;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'ADD TO FAVORITES'**
  String get addToFavorites;

  /// No description provided for @confirmLocation.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM LOCATION'**
  String get confirmLocation;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocation;

  /// No description provided for @selectedLocation.
  ///
  /// In en, this message translates to:
  /// **'Selected Location'**
  String get selectedLocation;

  /// No description provided for @locationNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Current location not available. Ensure permissions are granted.'**
  String get locationNotAvailable;

  /// No description provided for @selectPickupAndDestination.
  ///
  /// In en, this message translates to:
  /// **'Please select both pickup and destination.'**
  String get selectPickupAndDestination;

  /// No description provided for @clearRecentPlacesQuestion.
  ///
  /// In en, this message translates to:
  /// **'Clear recent places?'**
  String get clearRecentPlacesQuestion;

  /// No description provided for @actionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get actionCannotBeUndone;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @setRoute.
  ///
  /// In en, this message translates to:
  /// **'Set Route'**
  String get setRoute;

  /// No description provided for @selectLocation.
  ///
  /// In en, this message translates to:
  /// **'Select Location'**
  String get selectLocation;

  /// No description provided for @pickupLocation.
  ///
  /// In en, this message translates to:
  /// **'Pickup Location'**
  String get pickupLocation;

  /// No description provided for @destination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// No description provided for @setOnMap.
  ///
  /// In en, this message translates to:
  /// **'Set on Map'**
  String get setOnMap;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @savedPlaces.
  ///
  /// In en, this message translates to:
  /// **'Saved Places'**
  String get savedPlaces;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @addHome.
  ///
  /// In en, this message translates to:
  /// **'Add Home'**
  String get addHome;

  /// No description provided for @addWork.
  ///
  /// In en, this message translates to:
  /// **'Add Work'**
  String get addWork;

  /// No description provided for @setPickup.
  ///
  /// In en, this message translates to:
  /// **'Set as Pickup'**
  String get setPickup;

  /// No description provided for @setDestination.
  ///
  /// In en, this message translates to:
  /// **'Set as Destination'**
  String get setDestination;

  /// No description provided for @confirmPickup.
  ///
  /// In en, this message translates to:
  /// **'Confirm Pickup'**
  String get confirmPickup;

  /// No description provided for @confirmDestination.
  ///
  /// In en, this message translates to:
  /// **'Confirm Destination'**
  String get confirmDestination;

  /// No description provided for @discoverySetHome.
  ///
  /// In en, this message translates to:
  /// **'Set as Home'**
  String get discoverySetHome;

  /// No description provided for @discoverySetWork.
  ///
  /// In en, this message translates to:
  /// **'Set as Work'**
  String get discoverySetWork;

  /// No description provided for @discoveryAddFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add Favorite'**
  String get discoveryAddFavorite;

  /// No description provided for @setAsPickupLocation.
  ///
  /// In en, this message translates to:
  /// **'Set as Pickup Location'**
  String get setAsPickupLocation;

  /// No description provided for @setAsDestination.
  ///
  /// In en, this message translates to:
  /// **'Set as Destination'**
  String get setAsDestination;

  /// No description provided for @updateRoute.
  ///
  /// In en, this message translates to:
  /// **'Update Route'**
  String get updateRoute;

  /// No description provided for @setPickupFirst.
  ///
  /// In en, this message translates to:
  /// **'Set Pickup First'**
  String get setPickupFirst;

  /// No description provided for @saveHome.
  ///
  /// In en, this message translates to:
  /// **'Save Home'**
  String get saveHome;

  /// No description provided for @saveWork.
  ///
  /// In en, this message translates to:
  /// **'Save Work'**
  String get saveWork;

  /// No description provided for @addFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add Favorite'**
  String get addFavorite;

  /// No description provided for @setYourRoute.
  ///
  /// In en, this message translates to:
  /// **'Set Your Route'**
  String get setYourRoute;

  /// No description provided for @whereWouldYouLikeToGo.
  ///
  /// In en, this message translates to:
  /// **'Where would you like to go?'**
  String get whereWouldYouLikeToGo;

  /// No description provided for @changeAddress.
  ///
  /// In en, this message translates to:
  /// **'Change Address'**
  String get changeAddress;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @itemRemovedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'{itemType} removed successfully'**
  String itemRemovedSuccessfully(String itemType);

  /// No description provided for @homeAddress.
  ///
  /// In en, this message translates to:
  /// **'Home Address'**
  String get homeAddress;

  /// No description provided for @workAddress.
  ///
  /// In en, this message translates to:
  /// **'Work Address'**
  String get workAddress;

  /// No description provided for @favoritePlace.
  ///
  /// In en, this message translates to:
  /// **'Favorite Place'**
  String get favoritePlace;

  /// No description provided for @placeOptions.
  ///
  /// In en, this message translates to:
  /// **'Place Options'**
  String get placeOptions;

  /// No description provided for @clearAllDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear All Data?'**
  String get clearAllDataTitle;

  /// No description provided for @clearAllDataContent.
  ///
  /// In en, this message translates to:
  /// **'This will remove all your home, work, favorites, and recent places. This action cannot be undone.'**
  String get clearAllDataContent;

  /// No description provided for @clearEverything.
  ///
  /// In en, this message translates to:
  /// **'Clear Everything'**
  String get clearEverything;

  /// No description provided for @allDataCleared.
  ///
  /// In en, this message translates to:
  /// **'All data cleared successfully'**
  String get allDataCleared;

  /// No description provided for @searchErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Failed'**
  String get searchErrorTitle;

  /// No description provided for @searchErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again.'**
  String get searchErrorMessage;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No Results Found'**
  String get noResultsFound;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearch;

  /// No description provided for @pickOnMap.
  ///
  /// In en, this message translates to:
  /// **'Pick on Map'**
  String get pickOnMap;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @addYourHomeAddress.
  ///
  /// In en, this message translates to:
  /// **'Add your home address'**
  String get addYourHomeAddress;

  /// No description provided for @addYourWorkAddress.
  ///
  /// In en, this message translates to:
  /// **'Add your work address'**
  String get addYourWorkAddress;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @recentTrips.
  ///
  /// In en, this message translates to:
  /// **'Recent Trips'**
  String get recentTrips;

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No Favorites Yet'**
  String get noFavoritesYet;

  /// No description provided for @addFavoritesMessage.
  ///
  /// In en, this message translates to:
  /// **'Add your frequently visited places for quick access'**
  String get addFavoritesMessage;

  /// No description provided for @noRecentTrips.
  ///
  /// In en, this message translates to:
  /// **'No Recent Trips'**
  String get noRecentTrips;

  /// No description provided for @recentTripsMessage.
  ///
  /// In en, this message translates to:
  /// **'Your recent destinations will appear here'**
  String get recentTripsMessage;

  /// No description provided for @recentTripsCount.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =0{No recent trips} =1{1 recent trip} other{{count} recent trips}}'**
  String recentTripsCount(int count);

  /// No description provided for @recentsCleared.
  ///
  /// In en, this message translates to:
  /// **'Recent trips cleared'**
  String get recentsCleared;

  /// No description provided for @recentTripRemoved.
  ///
  /// In en, this message translates to:
  /// **'Recent trip removed'**
  String get recentTripRemoved;

  /// No description provided for @searching.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get searching;

  /// No description provided for @yourCurrentPosition.
  ///
  /// In en, this message translates to:
  /// **'Your current position'**
  String get yourCurrentPosition;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use Current Location'**
  String get useCurrentLocation;

  /// No description provided for @planYourRoute.
  ///
  /// In en, this message translates to:
  /// **'Plan Your Route'**
  String get planYourRoute;

  /// No description provided for @planningPanelVehicleSelection.
  ///
  /// In en, this message translates to:
  /// **'VEHICLE SELECTION'**
  String get planningPanelVehicleSelection;

  /// No description provided for @planningPanelEngageButton.
  ///
  /// In en, this message translates to:
  /// **'ENGAGE'**
  String get planningPanelEngageButton;

  /// No description provided for @planningPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Ride'**
  String get planningPanelTitle;

  /// No description provided for @noRidesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No rides available in this area.'**
  String get noRidesAvailable;

  /// No description provided for @vehicleTaglineStandard.
  ///
  /// In en, this message translates to:
  /// **'The perfect everyday essential.'**
  String get vehicleTaglineStandard;

  /// No description provided for @vehicleTaglineComfort.
  ///
  /// In en, this message translates to:
  /// **'Extra comfort for a relaxing ride.'**
  String get vehicleTaglineComfort;

  /// No description provided for @vehicleTaglineVan.
  ///
  /// In en, this message translates to:
  /// **'Room for the whole crew.'**
  String get vehicleTaglineVan;

  /// No description provided for @vehicleTaglineDefault.
  ///
  /// In en, this message translates to:
  /// **'A great choice for your trip.'**
  String get vehicleTaglineDefault;

  /// No description provided for @fareCalculating.
  ///
  /// In en, this message translates to:
  /// **'Calculating...'**
  String get fareCalculating;

  /// No description provided for @ride.
  ///
  /// In en, this message translates to:
  /// **'RIDE'**
  String get ride;

  /// No description provided for @confirmButtonRequesting.
  ///
  /// In en, this message translates to:
  /// **'REQUESTING...'**
  String get confirmButtonRequesting;

  /// No description provided for @confirmButtonRequest.
  ///
  /// In en, this message translates to:
  /// **'REQUEST'**
  String get confirmButtonRequest;

  /// No description provided for @postTripAddCompliment.
  ///
  /// In en, this message translates to:
  /// **'Add a compliment'**
  String get postTripAddCompliment;

  /// No description provided for @driverOnWayEnjoyYourRide.
  ///
  /// In en, this message translates to:
  /// **'Enjoy your ride!'**
  String get driverOnWayEnjoyYourRide;

  /// No description provided for @driverOnWayMeetAtPickup.
  ///
  /// In en, this message translates to:
  /// **'Please meet them at the pickup location.'**
  String get driverOnWayMeetAtPickup;

  /// No description provided for @ongoingTripTitle.
  ///
  /// In en, this message translates to:
  /// **'On Trip'**
  String get ongoingTripTitle;

  /// No description provided for @tripDuration.
  ///
  /// In en, this message translates to:
  /// **'Trip Duration'**
  String get tripDuration;

  /// No description provided for @safetyAndTools.
  ///
  /// In en, this message translates to:
  /// **'Safety & Tools'**
  String get safetyAndTools;

  /// No description provided for @shareTrip.
  ///
  /// In en, this message translates to:
  /// **'Share Trip'**
  String get shareTrip;

  /// No description provided for @emergencySOS.
  ///
  /// In en, this message translates to:
  /// **'SOS'**
  String get emergencySOS;

  /// No description provided for @emergencyDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency Assistance'**
  String get emergencyDialogTitle;

  /// No description provided for @emergencyDialogContent.
  ///
  /// In en, this message translates to:
  /// **'This will contact local emergency services. Are you sure you want to proceed?'**
  String get emergencyDialogContent;

  /// No description provided for @emergencyDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get emergencyDialogCancel;

  /// No description provided for @emergencyDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Call Now'**
  String get emergencyDialogConfirm;

  /// No description provided for @phoneNumberNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Driver\'s phone number is not available.'**
  String get phoneNumberNotAvailable;

  /// No description provided for @couldNotLaunch.
  ///
  /// In en, this message translates to:
  /// **'Could not launch {url}'**
  String couldNotLaunch(Object url);

  /// A tag to show that a price has been reduced
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @myTripsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'My Contract Trips'**
  String get myTripsScreenTitle;

  /// No description provided for @myTripsScreenRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get myTripsScreenRefresh;

  /// Prefix for the error message shown on the My Trips screen
  ///
  /// In en, this message translates to:
  /// **'Error: {errorMessage}'**
  String myTripsScreenErrorPrefix(String errorMessage);

  /// No description provided for @myTripsScreenRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get myTripsScreenRetry;

  /// No description provided for @myTripsScreenNoTrips.
  ///
  /// In en, this message translates to:
  /// **'No contract trips found.'**
  String get myTripsScreenNoTrips;

  /// No description provided for @myTripsScreenTripIdPrefix.
  ///
  /// In en, this message translates to:
  /// **'Trip ID: '**
  String get myTripsScreenTripIdPrefix;

  /// No description provided for @myTripsScreenFromPrefix.
  ///
  /// In en, this message translates to:
  /// **'From: '**
  String get myTripsScreenFromPrefix;

  /// No description provided for @myTripsScreenToPrefix.
  ///
  /// In en, this message translates to:
  /// **'To: '**
  String get myTripsScreenToPrefix;

  /// No description provided for @myTripsScreenPickupPrefix.
  ///
  /// In en, this message translates to:
  /// **'Pickup: '**
  String get myTripsScreenPickupPrefix;

  /// No description provided for @myTripsScreenDropoffPrefix.
  ///
  /// In en, this message translates to:
  /// **'Dropoff: '**
  String get myTripsScreenDropoffPrefix;

  /// No description provided for @myTripsScreenFarePrefix.
  ///
  /// In en, this message translates to:
  /// **'Fare: ETB '**
  String get myTripsScreenFarePrefix;

  /// No description provided for @myTripsScreenRatingPrefix.
  ///
  /// In en, this message translates to:
  /// **'Rating: '**
  String get myTripsScreenRatingPrefix;

  /// No description provided for @myTripsScreenNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get myTripsScreenNotAvailable;

  /// No description provided for @tripStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED'**
  String get tripStatusCompleted;

  /// No description provided for @tripStatusStarted.
  ///
  /// In en, this message translates to:
  /// **'STARTED'**
  String get tripStatusStarted;

  /// No description provided for @tripStatusPending.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get tripStatusPending;

  /// No description provided for @tripStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'CANCELLED'**
  String get tripStatusCancelled;

  /// No description provided for @drawerMyTrips.
  ///
  /// In en, this message translates to:
  /// **'My Trips'**
  String get drawerMyTrips;

  /// No description provided for @drawerAvailableContracts.
  ///
  /// In en, this message translates to:
  /// **'Available Contracts'**
  String get drawerAvailableContracts;

  /// No description provided for @drawerMyTransactions.
  ///
  /// In en, this message translates to:
  /// **'My Transactions'**
  String get drawerMyTransactions;

  /// No description provided for @drawerLogoutForgetDevice.
  ///
  /// In en, this message translates to:
  /// **'Logout & Forget Device'**
  String get drawerLogoutForgetDevice;

  /// No description provided for @contractPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Contract Rides'**
  String get contractPanelTitle;

  /// No description provided for @contractPanelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your premium travel experience'**
  String get contractPanelSubtitle;

  /// No description provided for @contractPanelActiveSubscriptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Active Subscriptions'**
  String get contractPanelActiveSubscriptionsTitle;

  /// No description provided for @contractPanelActiveSubscriptionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your current premium rides'**
  String get contractPanelActiveSubscriptionsSubtitle;

  /// No description provided for @contractPanelErrorLoadSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Unable to load your subscriptions'**
  String get contractPanelErrorLoadSubscriptions;

  /// No description provided for @contractPanelEmptySubscriptions.
  ///
  /// In en, this message translates to:
  /// **'No active subscriptions found'**
  String get contractPanelEmptySubscriptions;

  /// No description provided for @contractPanelEmptySubscriptionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your first premium ride below'**
  String get contractPanelEmptySubscriptionsSubtitle;

  /// No description provided for @contractPanelNewContractsTitle.
  ///
  /// In en, this message translates to:
  /// **'New Contracts'**
  String get contractPanelNewContractsTitle;

  /// No description provided for @contractPanelNewContractsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade your travel experience'**
  String get contractPanelNewContractsSubtitle;

  /// No description provided for @contractPanelErrorLoadContracts.
  ///
  /// In en, this message translates to:
  /// **'Unable to load contract types'**
  String get contractPanelErrorLoadContracts;

  /// No description provided for @contractPanelEmptyContracts.
  ///
  /// In en, this message translates to:
  /// **'No contracts available'**
  String get contractPanelEmptyContracts;

  /// No description provided for @contractPanelEmptyContractsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check back later for new offers'**
  String get contractPanelEmptyContractsSubtitle;

  /// No description provided for @contractPanelRetryButton.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get contractPanelRetryButton;

  /// Discount text with a placeholder for the percentage value.
  ///
  /// In en, this message translates to:
  /// **'{discountValue}% OFF'**
  String contractPanelDiscountOff(String discountValue);

  /// No description provided for @contractPickerTitlePickup.
  ///
  /// In en, this message translates to:
  /// **'Select Pickup Location'**
  String get contractPickerTitlePickup;

  /// No description provided for @contractPickerTitleDestination.
  ///
  /// In en, this message translates to:
  /// **'Select Destination'**
  String get contractPickerTitleDestination;

  /// No description provided for @contractPickerHintPickup.
  ///
  /// In en, this message translates to:
  /// **'Search for pickup...'**
  String get contractPickerHintPickup;

  /// No description provided for @contractPickerHintDestination.
  ///
  /// In en, this message translates to:
  /// **'Search for destination...'**
  String get contractPickerHintDestination;

  /// No description provided for @contractPickerNoRecents.
  ///
  /// In en, this message translates to:
  /// **'No recent searches found.'**
  String get contractPickerNoRecents;

  /// No description provided for @contractPickerRecentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get contractPickerRecentsTitle;

  /// No description provided for @contractPickerNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results found.'**
  String get contractPickerNoResults;

  /// No description provided for @contractDriverLoading.
  ///
  /// In en, this message translates to:
  /// **'Locating your contract driver...'**
  String get contractDriverLoading;

  /// No description provided for @contractDriverTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Contract Driver'**
  String get contractDriverTypeLabel;

  /// No description provided for @contractDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Contract Details'**
  String get contractDetailsTitle;

  /// No description provided for @contractDetailsSubscriptionId.
  ///
  /// In en, this message translates to:
  /// **'Subscription ID'**
  String get contractDetailsSubscriptionId;

  /// No description provided for @contractDetailsContractType.
  ///
  /// In en, this message translates to:
  /// **'Contract Type'**
  String get contractDetailsContractType;

  /// No description provided for @contractDetailsScheduledRide.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Ride'**
  String get contractDetailsScheduledRide;

  /// No description provided for @contractDetailsTimeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Time Remaining'**
  String get contractDetailsTimeRemaining;

  /// No description provided for @contractExpired.
  ///
  /// In en, this message translates to:
  /// **'Contract Expired'**
  String get contractExpired;

  /// No description provided for @contractTimeLeftDays.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{{count} day left} other{{count} days left}}'**
  String contractTimeLeftDays(int count);

  /// No description provided for @contractTimeLeftHours.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{{count} hour left} other{{count} hours left}}'**
  String contractTimeLeftHours(int count);

  /// No description provided for @contractTimeLeftMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{{count} minute left} other{{count} minutes left}}'**
  String contractTimeLeftMinutes(int count);

  /// No description provided for @confirmRideTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Your Ride'**
  String get confirmRideTitle;

  /// No description provided for @bookingUnderContract.
  ///
  /// In en, this message translates to:
  /// **'Booking under: {contractType}'**
  String bookingUnderContract(Object contractType);

  /// No description provided for @tripSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'TRIP SUMMARY'**
  String get tripSummaryTitle;

  /// No description provided for @assignedDriver.
  ///
  /// In en, this message translates to:
  /// **'Assigned Driver'**
  String get assignedDriver;

  /// No description provided for @driverContact.
  ///
  /// In en, this message translates to:
  /// **'Driver Contact'**
  String get driverContact;

  /// No description provided for @vehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get vehicle;

  /// No description provided for @plateNumber.
  ///
  /// In en, this message translates to:
  /// **'Plate No.'**
  String get plateNumber;

  /// No description provided for @contractPrice.
  ///
  /// In en, this message translates to:
  /// **'Contract Price'**
  String get contractPrice;

  /// No description provided for @tripDistance.
  ///
  /// In en, this message translates to:
  /// **'Trip Distance'**
  String get tripDistance;

  /// No description provided for @paymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Payment Status'**
  String get paymentStatus;

  /// No description provided for @subscriptionStatus.
  ///
  /// In en, this message translates to:
  /// **'Subscription Status'**
  String get subscriptionStatus;

  /// No description provided for @validity.
  ///
  /// In en, this message translates to:
  /// **'Validity'**
  String get validity;

  /// No description provided for @driverPending.
  ///
  /// In en, this message translates to:
  /// **'Driver Pending'**
  String get driverPending;

  /// No description provided for @negotiated.
  ///
  /// In en, this message translates to:
  /// **'Negotiated'**
  String get negotiated;

  /// No description provided for @confirmTodaysPickup.
  ///
  /// In en, this message translates to:
  /// **'Confirm Today\'s Pickup'**
  String get confirmTodaysPickup;

  /// No description provided for @exploreContracts.
  ///
  /// In en, this message translates to:
  /// **'Explore Contracts'**
  String get exploreContracts;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @rideSubscriptionFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Ride Subscription'**
  String get rideSubscriptionFallbackTitle;

  /// No description provided for @basePrice.
  ///
  /// In en, this message translates to:
  /// **'Base Price'**
  String get basePrice;

  /// No description provided for @minimumFare.
  ///
  /// In en, this message translates to:
  /// **'Minimum Fare'**
  String get minimumFare;

  /// No description provided for @maxPassengers.
  ///
  /// In en, this message translates to:
  /// **'Max Passengers'**
  String get maxPassengers;

  /// No description provided for @featureWifi.
  ///
  /// In en, this message translates to:
  /// **'WiFi'**
  String get featureWifi;

  /// No description provided for @featureAC.
  ///
  /// In en, this message translates to:
  /// **'A/C'**
  String get featureAC;

  /// No description provided for @featurePremiumSeats.
  ///
  /// In en, this message translates to:
  /// **'Premium Seats'**
  String get featurePremiumSeats;

  /// No description provided for @featurePrioritySupport.
  ///
  /// In en, this message translates to:
  /// **'Priority Support'**
  String get featurePrioritySupport;

  /// No description provided for @availableContractsTitle.
  ///
  /// In en, this message translates to:
  /// **'Available Contracts'**
  String get availableContractsTitle;

  /// No description provided for @noContractsAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'No Contracts Available'**
  String get noContractsAvailableTitle;

  /// No description provided for @noContractsAvailableMessage.
  ///
  /// In en, this message translates to:
  /// **'Please check back later for new subscription offers.'**
  String get noContractsAvailableMessage;

  /// No description provided for @failedToLoadContractsTitle.
  ///
  /// In en, this message translates to:
  /// **'Failed to Load Contracts'**
  String get failedToLoadContractsTitle;

  /// No description provided for @failedToLoadContractsMessage.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again.'**
  String get failedToLoadContractsMessage;

  /// No description provided for @baseRate.
  ///
  /// In en, this message translates to:
  /// **'Base Rate'**
  String get baseRate;

  /// No description provided for @selectAndPickRoute.
  ///
  /// In en, this message translates to:
  /// **'Select & Pick Route'**
  String get selectAndPickRoute;

  /// No description provided for @myTransactions.
  ///
  /// In en, this message translates to:
  /// **'My Transactions'**
  String get myTransactions;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'An Error Occurred'**
  String get errorPrefix;

  /// No description provided for @currentWalletBalance.
  ///
  /// In en, this message translates to:
  /// **'Current Wallet Balance'**
  String get currentWalletBalance;

  /// No description provided for @transactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistory;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No Transactions Yet'**
  String get noTransactionsYet;

  /// No description provided for @yourRecentTransactionsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your recent transactions will appear here.'**
  String get yourRecentTransactionsWillAppearHere;

  /// No description provided for @transactionStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get transactionStatusCompleted;

  /// No description provided for @transactionStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get transactionStatusPending;

  /// No description provided for @transactionStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get transactionStatusFailed;

  /// No description provided for @subscriptionDetails.
  ///
  /// In en, this message translates to:
  /// **'Subscription Details'**
  String get subscriptionDetails;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @financials.
  ///
  /// In en, this message translates to:
  /// **'Financials'**
  String get financials;

  /// No description provided for @baseFare.
  ///
  /// In en, this message translates to:
  /// **'Base Fare'**
  String get baseFare;

  /// No description provided for @finalFare.
  ///
  /// In en, this message translates to:
  /// **'Final Fare'**
  String get finalFare;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @passengerDetails.
  ///
  /// In en, this message translates to:
  /// **'Passenger Details'**
  String get passengerDetails;

  /// No description provided for @identifiers.
  ///
  /// In en, this message translates to:
  /// **'Identifiers'**
  String get identifiers;

  /// No description provided for @subscriptionId.
  ///
  /// In en, this message translates to:
  /// **'Subscription ID'**
  String get subscriptionId;

  /// No description provided for @contractId.
  ///
  /// In en, this message translates to:
  /// **'Contract ID'**
  String get contractId;

  /// No description provided for @passengerId.
  ///
  /// In en, this message translates to:
  /// **'Passenger ID'**
  String get passengerId;

  /// No description provided for @driverId.
  ///
  /// In en, this message translates to:
  /// **'Driver ID'**
  String get driverId;

  /// No description provided for @notAssigned.
  ///
  /// In en, this message translates to:
  /// **'Not Assigned'**
  String get notAssigned;

  /// No description provided for @callDriver.
  ///
  /// In en, this message translates to:
  /// **'Call Driver'**
  String get callDriver;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'days left'**
  String get daysLeft;

  /// No description provided for @expiresToday.
  ///
  /// In en, this message translates to:
  /// **'Har\'a Xumurama'**
  String get expiresToday;

  /// No description provided for @statusExpired.
  ///
  /// In en, this message translates to:
  /// **'Xumurameera'**
  String get statusExpired;

  /// No description provided for @daysLeftSingular.
  ///
  /// In en, this message translates to:
  /// **'Guyyaan {count} hafe'**
  String daysLeftSingular(int count);

  /// No description provided for @daysLeftPlural.
  ///
  /// In en, this message translates to:
  /// **'Guyyoonni {count} hafan'**
  String daysLeftPlural(int count);

  /// No description provided for @newSubscriptionRequest.
  ///
  /// In en, this message translates to:
  /// **'New Subscription Request'**
  String get newSubscriptionRequest;

  /// No description provided for @subscribingTo.
  ///
  /// In en, this message translates to:
  /// **'Subscribing to: {contractType}'**
  String subscribingTo(String contractType);

  /// No description provided for @reviewRequestPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your route and select the desired duration for your subscription.'**
  String get reviewRequestPrompt;

  /// No description provided for @yourRoute.
  ///
  /// In en, this message translates to:
  /// **'Your Route'**
  String get yourRoute;

  /// No description provided for @dropoffLocation.
  ///
  /// In en, this message translates to:
  /// **'Dropoff Location'**
  String get dropoffLocation;

  /// No description provided for @subscriptionDuration.
  ///
  /// In en, this message translates to:
  /// **'Subscription Duration'**
  String get subscriptionDuration;

  /// No description provided for @selectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Tap to select date range'**
  String get selectDateRange;

  /// No description provided for @pleaseSelectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Please select a start and end date.'**
  String get pleaseSelectDateRange;

  /// No description provided for @proceedToPayment.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Payment'**
  String get proceedToPayment;

  /// No description provided for @requestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Request Submitted!'**
  String get requestSubmitted;

  /// No description provided for @approvalNotificationPrompt.
  ///
  /// In en, this message translates to:
  /// **'Your subscription request has been sent for administrative approval. You will be notified once it is active.'**
  String get approvalNotificationPrompt;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @paymentScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Payment'**
  String get paymentScreenTitle;

  /// No description provided for @paymentConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Your Payment'**
  String get paymentConfirmTitle;

  /// No description provided for @paymentTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount: ETB {amount}'**
  String paymentTotalAmount(Object amount);

  /// No description provided for @paymentSelectGateway.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred payment gateway or upload a bank receipt.'**
  String get paymentSelectGateway;

  /// No description provided for @paymentPreferredMethod.
  ///
  /// In en, this message translates to:
  /// **'PREFERRED METHOD'**
  String get paymentPreferredMethod;

  /// No description provided for @paymentOtherGateways.
  ///
  /// In en, this message translates to:
  /// **'OTHER GATEWAYS'**
  String get paymentOtherGateways;

  /// No description provided for @paymentChooseGateway.
  ///
  /// In en, this message translates to:
  /// **'CHOOSE A GATEWAY'**
  String get paymentChooseGateway;

  /// No description provided for @paymentViewMoreOptions.
  ///
  /// In en, this message translates to:
  /// **'View More Options'**
  String get paymentViewMoreOptions;

  /// No description provided for @paymentPayWith.
  ///
  /// In en, this message translates to:
  /// **'Pay with {methodName}'**
  String paymentPayWith(Object methodName);

  /// No description provided for @paymentSelectAGateway.
  ///
  /// In en, this message translates to:
  /// **'Select a Gateway'**
  String get paymentSelectAGateway;

  /// No description provided for @paymentOr.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get paymentOr;

  /// No description provided for @paymentUploadBankReceipt.
  ///
  /// In en, this message translates to:
  /// **'Upload Bank Receipt'**
  String get paymentUploadBankReceipt;

  /// No description provided for @paymentManualUploadTitle.
  ///
  /// In en, this message translates to:
  /// **'Manual Payment Upload'**
  String get paymentManualUploadTitle;

  /// No description provided for @paymentManualUploadSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the bank transaction reference and upload a screenshot of your receipt.'**
  String get paymentManualUploadSubtitle;

  /// No description provided for @paymentTxnReferenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Transaction Reference'**
  String get paymentTxnReferenceLabel;

  /// No description provided for @paymentTxnReferenceRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get paymentTxnReferenceRequired;

  /// No description provided for @paymentTapToSelectReceipt.
  ///
  /// In en, this message translates to:
  /// **'Tap to select receipt image'**
  String get paymentTapToSelectReceipt;

  /// No description provided for @paymentSubmitForReview.
  ///
  /// In en, this message translates to:
  /// **'Submit for Review'**
  String get paymentSubmitForReview;

  /// No description provided for @paymentErrorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading payment methods: {error}'**
  String paymentErrorLoading(Object error);

  /// No description provided for @paymentNoMethodsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No payment methods available.'**
  String get paymentNoMethodsAvailable;

  /// No description provided for @paymentSuccessDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirmation Sent!'**
  String get paymentSuccessDialogTitle;

  /// No description provided for @paymentSuccessDialogContent.
  ///
  /// In en, this message translates to:
  /// **'A request has been sent to your phone. Please enter your PIN to approve the payment.'**
  String get paymentSuccessDialogContent;

  /// No description provided for @paymentErrorDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Error'**
  String get paymentErrorDialogTitle;

  /// No description provided for @paymentManualSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload Successful'**
  String get paymentManualSuccessTitle;

  /// No description provided for @paymentManualSuccessContent.
  ///
  /// In en, this message translates to:
  /// **'Your payment proof has been submitted and is pending review.'**
  String get paymentManualSuccessContent;

  /// No description provided for @paymentOkButton.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get paymentOkButton;

  /// No description provided for @paymentErrorSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String paymentErrorSnackbar(Object message);

  /// Title for the section where users apply a pre-paid plan.
  ///
  /// In en, this message translates to:
  /// **'Apply a Ride Plan'**
  String get contractsSectionTitle;

  /// Explanation of what a ride plan is.
  ///
  /// In en, this message translates to:
  /// **'Use a pre-paid weekly or monthly plan to get special rates for this trip.'**
  String get contractsSectionDescription;

  /// Title for the panel when a contract trip is ongoing
  ///
  /// In en, this message translates to:
  /// **'Trip Details'**
  String get tripDetails;

  /// Button text for the passenger to confirm they have arrived at their destination
  ///
  /// In en, this message translates to:
  /// **'Confirm Drop Off'**
  String get confirmDropoff;

  /// Title for the OTP verification screen
  ///
  /// In en, this message translates to:
  /// **'Enter Code'**
  String get enterCode;

  /// Subtitle on the OTP screen, showing the user's phone number
  ///
  /// In en, this message translates to:
  /// **'We sent a verification code to\n{phoneNumber}'**
  String otpScreenSubtitle(String phoneNumber);

  /// Text for the button to submit the OTP code
  ///
  /// In en, this message translates to:
  /// **'VERIFY'**
  String get verifyButton;

  /// Text for the button to request a new OTP code
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive code? Resend'**
  String get didNotReceiveCodeResend;

  /// Countdown timer text for the resend OTP button
  ///
  /// In en, this message translates to:
  /// **'Resend code in {seconds}s'**
  String resendCodeIn(int seconds);

  /// Error message when the entered OTP is not 6 digits long
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 6-digit code.'**
  String get enterValidOtp;

  /// Snackbar message shown when a new OTP is being sent
  ///
  /// In en, this message translates to:
  /// **'Resending OTP...'**
  String get resendingOtp;

  /// No description provided for @mapLayersTitle.
  ///
  /// In en, this message translates to:
  /// **'Map Layers'**
  String get mapLayersTitle;

  /// No description provided for @mapLayersDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get mapLayersDark;

  /// No description provided for @mapLayersLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get mapLayersLight;

  /// No description provided for @mapLayersSatellite.
  ///
  /// In en, this message translates to:
  /// **'Satellite'**
  String get mapLayersSatellite;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @above.
  ///
  /// In en, this message translates to:
  /// **'Above'**
  String get above;

  /// No description provided for @moreFilters.
  ///
  /// In en, this message translates to:
  /// **'More Filters'**
  String get moreFilters;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// No description provided for @anyDate.
  ///
  /// In en, this message translates to:
  /// **'Any Date'**
  String get anyDate;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// No description provided for @sortNewestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest First'**
  String get sortNewestFirst;

  /// No description provided for @sortOldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Oldest First'**
  String get sortOldestFirst;

  /// No description provided for @sortAmountHighest.
  ///
  /// In en, this message translates to:
  /// **'Amount (High to Low)'**
  String get sortAmountHighest;

  /// No description provided for @sortAmountLowest.
  ///
  /// In en, this message translates to:
  /// **'Amount (Low to High)'**
  String get sortAmountLowest;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyFilters;

  /// No description provided for @transactionID.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get transactionID;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @bookingID.
  ///
  /// In en, this message translates to:
  /// **'Booking ID'**
  String get bookingID;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @noMatchingTransactions.
  ///
  /// In en, this message translates to:
  /// **'No Transactions Match Your Filters'**
  String get noMatchingTransactions;

  /// No description provided for @tryAdjustingFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting or clearing your search filters to see results.'**
  String get tryAdjustingFilters;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @lastDay.
  ///
  /// In en, this message translates to:
  /// **'Last day'**
  String get lastDay;

  /// No description provided for @dayLeft.
  ///
  /// In en, this message translates to:
  /// **'day left'**
  String get dayLeft;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['am', 'en', 'om', 'so', 'ti'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am': return AppLocalizationsAm();
    case 'en': return AppLocalizationsEn();
    case 'om': return AppLocalizationsOm();
    case 'so': return AppLocalizationsSo();
    case 'ti': return AppLocalizationsTi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
