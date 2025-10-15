// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tigrinya (`ti`).
class AppLocalizationsTi extends AppLocalizations {
  AppLocalizationsTi([String locale = 'ti']) : super(locale);

  @override
  String get pageHomeTitle => 'መበገሲ';

  @override
  String get whereTo => 'ናበይ?';

  @override
  String get mapSetDestination => 'በፅሒ ቦታኻ ንምምዳብ ጠውቕ';

  @override
  String get mapSetPickup => 'መበገሲ ቦታኻ ንምምዳብ ጠውቕ';

  @override
  String get findingYourLocation => 'ቦታኻ ይድለ አሎ...';

  @override
  String get cancel => 'ሰርዝ';

  @override
  String get chatWithDriver => 'ምስ መራሕ መኪና ተዛረብ';

  @override
  String get noMessagesYet => 'ክሳብ ሕጂ ዝኾነ መልእኽቲ የለን።';

  @override
  String get pageSettingsTitle => 'መዳለዊ';

  @override
  String get selectLanguage => 'ቋንቋ ምረጽ';

  @override
  String get loginWelcomeBack => 'እንቋዕ ብደሓን ተመለስካ';

  @override
  String get loginWithPhoneSubtitle => 'ብቁጽሪ ተሌፎንካ እተው';

  @override
  String get loginWithEmailSubtitle => 'ብኢመይልካ እተው';

  @override
  String get loginMethodPhone => 'ስልኪ';

  @override
  String get loginMethodEmail => 'ኢመይል';

  @override
  String get phoneNumber => 'ቁጽሪ ስልኪ';

  @override
  String get email => 'ኢሜይል';

  @override
  String get password => 'መሕለፊ ቃል';

  @override
  String get errorEnterPhoneNumber => 'በጃኻ ቁጽሪ ስልኪ ኣእቱ';

  @override
  String get errorInvalidPhoneNumber => 'ቅኑዕ ናይ 9 ወይ 10 ኣሃዛት ቁጽሪ ኣእቱ';

  @override
  String get errorEnterEmail => 'በጃኻ ኢመይል ኣእቱ';

  @override
  String get errorInvalidEmail => 'ትክክለኛ ኢሜይል አድራሻ ኣብልት።';

  @override
  String get errorEnterPassword => 'በጃኻ መሕለፊ ቃልካ ኣእቱ';

  @override
  String get sendOtpButton => 'ኦቲፒ ስደድ';

  @override
  String get signInButton => 'እተው';

  @override
  String get dontHaveAccount => 'ኣካውንት የብልካን? ';

  @override
  String get register => 'ተመዝገብ';

  @override
  String get drawerProfileSettings => 'መዳለዊ ፕሮፋይል';

  @override
  String get drawerPaymentMethod => 'ኣገባብ ክፍሊት';

  @override
  String get drawerRideHistory => 'ታሪኽ ጉዕዞ';

  @override
  String get drawerSupport => 'ሓገዝ';

  @override
  String get drawerSettings => 'መዳለዊ';

  @override
  String get drawerLogout => 'ውጻእ';

  @override
  String get drawerGuestUser => 'ጋሻ ተጠቃሚ';

  @override
  String get drawerWallet => 'ቦርሳ';

  @override
  String get drawerRating => 'ደረጃ';

  @override
  String get drawerTrips => 'ጉዕዞታት';

  @override
  String drawerWalletBalance(String balance) {
    return 'ብር $balance';
  }

  @override
  String appVersion(String versionNumber) {
    return 'ቨርዥን $versionNumber';
  }

  @override
  String get settingsTitle => 'መዳለዊ';

  @override
  String get settingsSectionAccount => 'ኣካውንት';

  @override
  String get settingsEditProfile => 'ፕሮፋይል ኣመሓድር';

  @override
  String get settingsEditProfileSubtitle => 'ስምካ፣ ኢመይልካን ስእልኻን ኣመሓድር';

  @override
  String get settingsSectionPreferences => 'ምርጫታት';

  @override
  String get settingsLanguage => 'ቋንቋ';

  @override
  String get settingsDarkMode => 'ጸልማት ሞድ';

  @override
  String get settingsSectionAbout => 'ብዛዕባ';

  @override
  String get settingsHelpSupport => 'ሓገዝን ደገፍን';

  @override
  String get settingsTermsOfService => 'ውዕል ኣገልግሎት';

  @override
  String get settingsPrivacyPolicy => 'ፖሊሲ ብሕትውና';

  @override
  String get editProfileTitle => 'ፕሮፋይል ኣምሃር';

  @override
  String get personalInformation => 'ውልቂ መረዳእታ';

  @override
  String get fullName => 'ሙሉ ስም';

  @override
  String get emailAddress => 'ኢሜይል አድራሻ';

  @override
  String get emergencyContacts => 'ኣዋጅ መገዲያታት';

  @override
  String contactNumber(Object number) {
    return 'መገዲያ #$number';
  }

  @override
  String get contactFullName => 'ሙሉ ስም መገዲያ';

  @override
  String get contactPhoneNumber => 'ቁጽሪ ስልኪ መገዲያ';

  @override
  String get addContact => 'መገዲያ ጨምር';

  @override
  String get saveChanges => 'ምቕዳም ለውጢ';

  @override
  String get security => 'ዓደጋን መከላከል';

  @override
  String get changePassword => 'መሕለፊ ቃል ቀይር';

  @override
  String get currentPassword => 'አሁን ያለው ሚስጥር ቃል';

  @override
  String get newPassword => 'አዲስ ሚስጥር ቃል';

  @override
  String get confirmNewPassword => 'አዲስ ሚስጥር ቃል ድጋፍ';

  @override
  String get errorEnterName => 'እባክክልካ ስምካ ኣብልት።';

  @override
  String get errorEnterNameForContact => 'ስም ተዳዋሊ ኣእቱ';

  @override
  String get errorEnterPhoneForContact => 'ስልኪ ተዳዋሊ ኣእቱ';

  @override
  String get errorInvalidPhone => 'ጌጋ ቅርጺ ቁጽሪ ስልኪ';

  @override
  String get errorEnterCurrentPassword => 'ናብ አዲሱ ሚስጥር ቃል ለመቀየር አሁን ያለው አስተውሉ።';

  @override
  String get errorEnterNewPassword => 'ሓድሽ መሕለፊ ቃል ኣእቱ';

  @override
  String get errorPasswordTooShort => 'ሚስጥር ቃል ቢያንስ 6 ፊደላት ይወድብ ዘንተ።';

  @override
  String get errorPasswordsDoNotMatch => 'ሚስጥር ቃሎች ኣብ መኳስ ኣይተመሳሰሉን።';

  @override
  String get profileUpdateSuccess => 'ፕሮፋይል ተራእዩ ብትኽክል!';

  @override
  String get profileUpdateFailed => 'ፕሮፋይል መርዳኢ ኣልተሳነጠሉ።';

  @override
  String get passwordUpdateSuccess => 'መሕለፊ ቃል ብዓወት ተቐይሩ!';

  @override
  String get passwordUpdateFailed => 'መሕለፊ ቃል ምቅያር ኣይተሳኸዐን።';

  @override
  String get authWelcome => 'እንቋዕ ብደሓን መጻእካ';

  @override
  String get authSignInToContinue => 'ንኽትቅጽል ናብ ኣካውንትካ እተው';

  @override
  String get authCreateAccount => 'ኣካውንት ፍጠር';

  @override
  String get authGetStarted => 'ንምጅማር';

  @override
  String get authFullName => 'ሙሉእ ስም';

  @override
  String get authPhoneNumber => 'ቁጽሪ ስልኪ';

  @override
  String get authPassword => 'መሕለፊ ቃል';

  @override
  String get authSignIn => 'እተው';

  @override
  String get authRegister => 'ኣካውንት ፍጠር';

  @override
  String get authNoAccount => 'ኣካውንት የብልካን? ';

  @override
  String get authHaveAccount => 'ድሮ ኣካውንት ኣለካ? ';

  @override
  String get authErrorEnterFullName => 'በጃኻ ሙሉእ ስምካ ኣእቱ';

  @override
  String get authErrorEnterPhone => 'በጃኻ ቁጽሪ ስልኪ ኣእቱ';

  @override
  String get authErrorInvalidPhone => 'በጃኻ ቅኑዕ ቁጽሪ ስልኪ ኣእቱ';

  @override
  String get authErrorEnterPassword => 'በጃኻ መሕለፊ ቃል ኣእቱ';

  @override
  String get authErrorPasswordShort => 'መሕለፊ ቃል እንተ ወሓደ 6 ፊደላት ክኸውን ኣለዎ';

  @override
  String get authSwitchToRegister => 'ተመዝገብ';

  @override
  String get authSwitchToSignIn => 'እተው';

  @override
  String get registerCreateAccount => 'ኣካውንት ፍጠር';

  @override
  String get registerGetStarted => 'ንምጅማር';

  @override
  String get registerFullName => 'ሙሉእ ስም';

  @override
  String get registerPhoneNumber => 'ቁጽሪ ስልኪ';

  @override
  String get registerPassword => 'መሕለፊ ቃል';

  @override
  String get registerButton => 'ኣካውንት ፍጠር';

  @override
  String get registerHaveAccount => 'ድሮ ኣካውንት ኣለካ? ';

  @override
  String get registerSignIn => 'እተው';

  @override
  String get registerErrorEnterFullName => 'በጃኻ ሙሉእ ስምካ ኣእቱ';

  @override
  String get registerErrorEnterPhone => 'በጃኻ ቁጽሪ ስልኪ ኣእቱ';

  @override
  String get registerErrorInvalidPhone => 'በጃኻ ቅኑዕ ቁጽሪ ስልኪ ኣእቱ';

  @override
  String get registerErrorEnterPassword => 'በጃኻ መሕለፊ ቃል ኣእቱ';

  @override
  String get registerErrorPasswordShort => 'መሕለፊ ቃል እንተ ወሓደ 6 ፊደላት ክኸውን ኣለዎ';

  @override
  String get historyScreenTitle => 'ታሪኽ ጉዕዞ';

  @override
  String get historyLoading => 'ይፅዕን ኣሎ...';

  @override
  String get historyErrorTitle => 'ጌጋ ኣጋጢሙ';

  @override
  String get historyErrorMessage => 'ዘይተጸበናዮ ጌጋ ኣጋጢሙ። በጃኹም ናይ ኢንተርነት መርበብኩም ኣረጋግፁ።';

  @override
  String get historyRetryButton => 'እንደገና ፍተን';

  @override
  String get historyEmptyTitle => 'ክሳብ ሕጂ ዝኾነ ጉዕዞ የለን';

  @override
  String get historyEmptyMessage => 'ዝዛዘምክምዎም ጉዕዞታት ኣብዚ ክርኣዩ እዮም።';

  @override
  String get historyCardFrom => 'ካብ';

  @override
  String get historyCardTo => 'ናብ';

  @override
  String get historyCardFare => 'ዋጋ:';

  @override
  String get historyCardUnknownLocation => 'ዘይፍለጥ ቦታ';

  @override
  String get historyStatusCompleted => 'ተዛዚሙ';

  @override
  String get historyStatusCanceled => 'ተሰሪዙ';

  @override
  String get historyStatusPending => 'ይፅበ';

  @override
  String get currencySymbol => 'ብር';

  @override
  String get discoveryWhereTo => 'ናበይ ንኺድ?';

  @override
  String get discoverySearchDestination => 'በፅሒ ቦታ ድለ';

  @override
  String get discoveryHome => 'ገዛ';

  @override
  String get discoveryWork => 'ስራሕ';

  @override
  String get discoveryAddHome => 'ገዛ ወስኽ';

  @override
  String get discoveryAddWork => 'ስራሕ ወስኽ';

  @override
  String get discoveryFavoritePlaces => 'ዝፈትውዎም ቦታታት';

  @override
  String get discoveryAddFavoritePrompt => 'ዝፈትውዎ መዕረፊ ንምውሳኽ \'+\' ጠውቑ።';

  @override
  String get discoveryRecentTrips => 'ናይ ቀረባ ግዜ ጉዕዞታት';

  @override
  String get discoveryRecentTripRemoved => 'ናይ ቀረባ ግዜ ጉዕዞ ተሰሪዙ።';

  @override
  String get discoveryClearAll => 'ኩሉ ኣፅሪ';

  @override
  String get discoveryMenuChangeAddress => 'ኣድራሻ ቀይር';

  @override
  String get discoveryMenuRemove => 'ኣልግስ';

  @override
  String get searchingContactingDrivers => 'ናይ ቀረባ መራሕቲ ምውካስ';

  @override
  String get searchingPleaseWait => 'ክሳብ ንዓኻትኩም መጓዓዝያ እንረኽበልኩም በጃኹም ተጸበዩ።';

  @override
  String get searchingDetailFrom => 'ካብ';

  @override
  String get searchingDetailTo => 'ናብ';

  @override
  String get searchingDetailVehicle => 'መኪና';

  @override
  String searchingDetailVehicleValue(Object name, Object price) {
    return '$name • ግምት. $price ብር';
  }

  @override
  String get searchingCancelButton => 'ምድላይ ሰርዝ';

  @override
  String get planningPanelDistance => 'ርሕቐት';

  @override
  String get planningPanelDuration => 'ግዜ';

  @override
  String get planningPanelConfirmButton => 'ኣረጋግጽ';

  @override
  String get planningPanelNoRidesAvailable => 'መኪና የለን';

  @override
  String get planningPanelRideOptionsError => 'ናይ ጉዕዞ ኣማራጽታት ምጽዓን ኣይተኻእለን።';

  @override
  String planningPanelPrice(String price) {
    return 'ብር: $price';
  }

  @override
  String get planningPanelSelectRide => 'መኪና ምረጽ';

  @override
  String get planningPanelConfirmRide => 'ጉዞ ኣረጋግጽ';

  @override
  String get registerErrorPhoneInvalid => 'በጃኹም ትኽክለኛ ቁጽሪ ተሌፎን ኣእትዉ';

  @override
  String get optional => 'ኣማራጺ';

  @override
  String get registerConfirmPassword => 'ቃል መሕለፍ ኣረጋግጽ';

  @override
  String get registerErrorEnterConfirmPassword => 'በጃኹም ቃል መሕለፍ ኣረጋግጽ ኣእትዉ';

  @override
  String get registerErrorPasswordMismatch => 'ቃላት መሕለፍ ኣይተዛመዱን';

  @override
  String get phone => 'ስልኪ';

  @override
  String get registerGetOtp => 'ናይ ኦቲፒ ኮድ ረኸብ';

  @override
  String get registerErrorEnterEmail => 'በጃኹም ኢመይልኩም የእትዉ';

  @override
  String get registerErrorInvalidEmail => 'በጃኹም ቅኑዕ ኣድራሻ ኢመይል የእትዉ';

  @override
  String get driverOnWayEnRouteToDestination => 'ናብ መድረሻ ኣብ ጉዕዞ';

  @override
  String get driverOnWayDriverArriving => 'ሾፌርካ ይመጽእ ኣሎ';

  @override
  String get driverOnWayBookingId => 'መፍለይ ቁጽሪ ምሕዝነት:';

  @override
  String get driverOnWayDriverId => 'መፍለይ ሾፌር:';

  @override
  String get driverOnWayPickup => 'መበገሲ:';

  @override
  String get driverOnWayDropoff => 'መዕረፊ:';

  @override
  String get driverOnWayCall => 'ደውል';

  @override
  String get driverOnWayChat => 'ጸሓፍ';

  @override
  String get driverOnWayCancelRide => 'ጉዕዞ ስረዝ';

  @override
  String get driverOnWayDriverNotAvailable => 'ሾፌር የለን';

  @override
  String get driverOnWayNotAvailable => 'የለን';

  @override
  String get driverOnWayColorNotAvailable => 'ሕብሪ የለን';

  @override
  String get driverOnWayModelNotAvailable => 'ሞዴል የለን';

  @override
  String get driverOnWayPlateNotAvailable => 'ሰሌዳ የለን';

  @override
  String get driverOnWayVehicleUnknown => 'ዘይፍለጥ';

  @override
  String get ongoingTripEnjoyRide => 'ብጉዕዞኻ ተሓጎስ!';

  @override
  String get ongoingTripOnYourWay => 'ናብ መዕረፊ ቦታኻ ኣብ መንገድኻ ኣለኻ።';

  @override
  String get ongoingTripDriverOnWay => 'ሾፌር ኣብ መንገድኻ ኣሎ';

  @override
  String ongoingTripDriverArrivingIn(String eta) {
    return 'ሾፌርካ ብግምት ኣብ $eta ክበጽሕ እዩ';
  }

  @override
  String get ongoingTripYourDriver => 'ናታትካ ሾፌር';

  @override
  String get ongoingTripStandardCar => 'ልሙድ መኪና';

  @override
  String get ongoingTripPlatePlaceholder => '...';

  @override
  String get ongoingTripDefaultColor => 'ጸሊም';

  @override
  String get ongoingTripCall => 'ደውል';

  @override
  String get ongoingTripChat => 'ተዛረብ';

  @override
  String get ongoingTripCancel => 'ስረዝ';

  @override
  String get postTripCompleted => 'ጉዕዞ ተዛዚሙ!';

  @override
  String get postTripYourDriver => 'ናታትካ ሾፌር';

  @override
  String get postTripRateExperience => 'ተመክሮኻ ደረጃ ሃብ';

  @override
  String get postTripAddComment => 'ዝርዝር ርእይቶ ወስኽ (ኣማራጺ)';

  @override
  String get postTripSubmitFeedback => 'ርእይቶኻ ኣቕርብ';

  @override
  String get postTripSkip => 'ዘለዎ';

  @override
  String get postTripShowAppreciation => 'ናእዳኻ ግለጽ?';

  @override
  String get postTripOther => 'ካልእ';

  @override
  String get postTripFinalFare => 'ናይ መወዳእታ ዋጋ';

  @override
  String get postTripDistance => 'ርሕቐት';

  @override
  String get postTripTagExcellentService => 'ሉዑል ኣገልግሎት';

  @override
  String get postTripTagCleanCar => 'ጽሩይ መኪና';

  @override
  String get postTripTagSafeDriver => 'ጥንቁቕ ሾፌር';

  @override
  String get postTripTagGoodConversation => 'ጽቡቕ ዕላል';

  @override
  String get postTripTagFriendlyAttitude => 'ጽቡቕ ኣረኣእያ';

  @override
  String get driverInfoWindowVehicleStandard => 'ልሙድ';

  @override
  String get driverInfoWindowAvailable => 'ይርከብ';

  @override
  String get driverInfoWindowOnTrip => 'ኣብ ጉዕዞ';

  @override
  String get driverInfoWindowSelect => 'ምረጽ';

  @override
  String get notificationRideConfirmedTitle => 'ጉዕዞኻ ተረጋጊጹ!';

  @override
  String notificationRideConfirmedBody(String driverName) {
    return 'ሾፌር $driverName ኣብ መንገድኻ ኣሎ።';
  }

  @override
  String get notificationDriverArrivedTitle => 'ሾፌርካ በጺሑ!';

  @override
  String get notificationDriverArrivedBody => 'በጃኹም ኣብ መበገሲ ቦታ ምስ ሾፌርኩም ተራኸቡ።';

  @override
  String get notificationTripStartedTitle => 'ጉዕዞኻ ተጀሚሩ';

  @override
  String get notificationTripStartedBody => 'ብጉዕዞኻ ተሓጎስ! ድሕንነቱ ዝተሓለወ ጉዕዞ ንምነየልኩም።';

  @override
  String get notificationTripCompletedTitle => 'ጉዕዞ ተዛዚሙ!';

  @override
  String get notificationTripCompletedBody => 'Thank you for riding with us. We hope to see you again soon.';

  @override
  String get notificationRideCanceledTitle => 'ጉዕዞ ተሰሪዙ';

  @override
  String get notificationRideCanceledBody => 'ናይ ጉዕዞ ሕቶኻ ተሰሪዙ።';

  @override
  String get notificationRequestSentTitle => 'ናይ ጉዕዞ ሕቶ ቀሪቡ';

  @override
  String get notificationRequestSentBody => 'ሕቶኹም ተቐቢልናዮ ኣለና፣ ሕጂ ድማ ኣብ ቀረባ ዝርከቡ ሾፌራት ንደሊ ኣለና።';

  @override
  String notificationNewMessageTitle(String driverName) {
    return 'ካብ $driverName ዝመጸ ሓድሽ መልእኽቲ';
  }

  @override
  String get notificationNoDriversTitle => 'ሾፌር ኣይተረኸበን';

  @override
  String get notificationNoDriversBody => 'ኣብ ቀረባ ሾፌር ክንረክብ ኣይከኣልናን። በጃኹም ድሕሪ ቁሩብ ግዜ ደጊምኩም ፈትኑ።';

  @override
  String get notificationBookingErrorTitle => 'ናይ ቡኪንግ ጌጋ';

  @override
  String get arrived => 'በጺሑ';

  @override
  String get editProfileSubtitle => 'መረጋጋታት መረጋገጽታትካ ዘይብሉ እያ።';

  @override
  String notificationSearchingBody(String radius) {
    return 'ኣብ ውሽጢ $radius ኪ.ሜ ራድየስ ንዝርከቡ መራሕቲ ንደሊ ኣለና።';
  }

  @override
  String get notificationDriverNearbyTitle => 'መራሕ ማኪና ኣብ ቀረባ ኣሎ';

  @override
  String notificationDriverNearbyBody(String distance) {
    return 'መራሕ ማኪናኹም ሕጂ ካብ $distance ሜትሮ ንታሕቲ ርሒቑ ኣሎ።';
  }

  @override
  String get notificationDriverVeryCloseTitle => 'መራሕ ማኪና ኣዝዩ ቀሪቡ ኣሎ';

  @override
  String get notificationDriverVeryCloseBody => 'ተዳለዉ! መራሕ ማኪናኹም ክበጽሕ እዩ።';

  @override
  String get offlineOrderTitle => 'ካብ መስመር ወጻኢ ትእዛዝ';

  @override
  String get offlineRequestTitle => 'ብ SMS መገሻ ሕተት';

  @override
  String get offlineRequestSubtitle => 'ኢንተርነት የብልካን? ጸገም የለን። ኣብ ታሕቲ ቦታታትካ የእትው እሞ ንትእዛዝካ ንምርግጋጽ ክንድውለልካ ኢና።';

  @override
  String get pickupLocationHint => 'መበገሲ ቦታ የእትው';

  @override
  String get destinationLocationHint => 'በጺሕ ቦታ የእትው';

  @override
  String get pickupValidationError => 'በጃኻ መበገሲ ቦታ የእትው';

  @override
  String get destinationValidationError => 'በጃኻ በጺሕ ቦታ የእትው';

  @override
  String get prepareSmsButton => 'ናይ SMS ሕቶ ኣዳሉ።';

  @override
  String get smsCouldNotOpenError => 'ናይ SMS መተግበሪኻ ክኸፍት ኣይከኣለን።';

  @override
  String get smsGenericError => 'SMS ክትፈጥር እንከለኻ ጌጋ ኣጋጢሙ።';

  @override
  String get step1Title => 'ቦታታት የእትው';

  @override
  String get step1Subtitle => 'ኣበይ ከም እንወስደካን ናበይ ከም ትኸይድን ንገረና።';

  @override
  String get step2Title => 'SMS ኣዳሉ።';

  @override
  String get step2Subtitle => 'ብዝርዝርካ ናይ ጽሑፍ መልእኽቲ ክንፈጥር ኢና።';

  @override
  String get step3Title => 'ጻውዒትና ተጸበ።';

  @override
  String get step3Subtitle => 'ጉዕዞኻ ንምርግጋጽ ጋንታና ድሕሪ ቀረባ እዋን ክድውለልካ እዩ።';

  @override
  String get smsOfflineLogin => 'ኢንተርነት የብልካን? ብ SMS እዘዝ';

  @override
  String get smsLaunchSuccessTitle => 'ናይ SMS መተግበሪ ተኸፊቱ';

  @override
  String get smsLaunchSuccessMessage => 'በጃኻ ነቲ መልእኽቲ ርኣዮ እሞ ሕቶኻ ንምእታው \'ሰደድ\' ጽቐጥ።';

  @override
  String get smsCapabilityError => 'እዚ መሳርሒ እዚ ናይ SMS መልእኽትታት ክሰድድ ኣይክእልን እዩ።';

  @override
  String get smsLaunchError => 'ነቲ ናይ SMS መተግበሪ ክኸፍቶ ኣይከኣለን። በጃኻ ናይ መሳርሒኻ ቅጥዕታት ርአ።';

  @override
  String get offline => 'ኦፍላይን ኤስኤምኤስ';

  @override
  String get skip => 'ኣልቦ';

  @override
  String get finish => 'ጨርሓ';

  @override
  String get completeProfileTitle => 'መወዳእታ ኣንደበት';

  @override
  String get completeProfileSubtitle => 'መረጋጋት ሓላፍነታትካ ኣብ ፕሮፋይል ኣብሎ ኣብ ቀጺሉ መድረስ።';

  @override
  String get mySubscriptionsTitle => 'ምዝገባታተይ';

  @override
  String get noSubscriptionsFound => 'No subscriptions found.';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get statusActive => 'ACTIVE';

  @override
  String get statusPending => 'PENDING';

  @override
  String get statusInactive => 'INACTIVE';

  @override
  String get contractDetails => 'ዝርዝራት ውዕል';

  @override
  String get status => 'ኩነታት';

  @override
  String get duration => 'Duration';

  @override
  String get cost => 'Cost';

  @override
  String get routeInformation => 'ሓበሬታ መስመር';

  @override
  String get pickup => 'መበገሲ';

  @override
  String get dropoff => 'መዓረፊ';

  @override
  String get rideSchedule => 'Ride Schedule';

  @override
  String get pickupTime => 'Pickup Time';

  @override
  String get contractTypeIndividual => 'Individual';

  @override
  String get contractTypeInstitutional => 'Institutional';

  @override
  String get drawerMySubscriptions => 'My Subscriptions';

  @override
  String get saveLocationAs => 'ቦታ ከምዚ ኢልካ ኣቐምጥ';

  @override
  String get home => 'ገዛ';

  @override
  String get work => 'ስራሕ';

  @override
  String get favorite => 'ተመራጺ';

  @override
  String get goToDestination => 'ናብ መድረሻ ኺድ';

  @override
  String get saveAsHome => 'ከም ገዛ ኣቐምጦ';

  @override
  String get saveAsWork => 'ከም ስራሕ ኣቐምጦ';

  @override
  String get addToFavorites => 'ናብ ተመራጽቲ ወስኽ';

  @override
  String get confirmLocation => 'ቦታ ኣረጋግጽ';

  @override
  String get currentLocation => 'እዚ ዘለኹዎ ቦታ';

  @override
  String get selectedLocation => 'እቲ ዝተመርጸ ቦታ';

  @override
  String get locationNotAvailable => 'ዘለኻዮ ቦታ ኣይርከብን። ፍቓድካ ኣረጋግጽ።';

  @override
  String get selectPickupAndDestination => 'መብጽዓን መድረስን ምረጽ።';

  @override
  String get clearRecentPlacesQuestion => 'ቀዳሞት ቦታታት ደምሲስካ?';

  @override
  String get actionCannotBeUndone => 'እዚ ተግባር ክቕየር ኣይክእልን።';

  @override
  String get clear => 'ኣጽሪ';

  @override
  String get setRoute => 'መንገዲ ኣስምር';

  @override
  String get selectLocation => 'ቦታ ምረጽ';

  @override
  String get pickupLocation => 'መበገሲ ቦታ';

  @override
  String get destination => 'መዕረፊ';

  @override
  String get setOnMap => 'ኣብ ካርታ ኣስምር';

  @override
  String get current => 'ሕጂ ዘሎ';

  @override
  String get savedPlaces => 'ዝተቐመጡ ቦታታት';

  @override
  String get recent => 'ቀዳሞት';

  @override
  String get addHome => 'ቤትካ ኣስምር';

  @override
  String get addWork => 'ስራሕካ ኣስምር';

  @override
  String get setPickup => 'መበገሲ ኣድርግ';

  @override
  String get setDestination => 'መወዳእታ ኣድርግ';

  @override
  String get confirmPickup => 'ኣነሳሲ ኣረጋግጽ';

  @override
  String get confirmDestination => 'መድረሻ ኣረጋግጽ';

  @override
  String get discoverySetHome => 'ገዛ ኣድርግ';

  @override
  String get discoverySetWork => 'ስራሕ ኣድርግ';

  @override
  String get discoveryAddFavorite => 'ተዓዊቱ ኣክል';

  @override
  String get setAsPickupLocation => 'ቦታ ኣነሳሲ ኣድርግ';

  @override
  String get setAsDestination => 'መድረሻ ኣድርግ';

  @override
  String get updateRoute => 'መንገዲ ኣዘምን';

  @override
  String get setPickupFirst => 'ኣነሳሲ ቀዳማይ ኣድርግ';

  @override
  String get saveHome => 'ገዛ ኣቐምጥ';

  @override
  String get saveWork => 'ስራሕ ኣቐምጥ';

  @override
  String get addFavorite => 'ዝፈትዎ ወስኽ';

  @override
  String get setYourRoute => 'መንገድኻ ኣዳሉ';

  @override
  String get whereWouldYouLikeToGo => 'ናበይ ክትከይድ ትደሊ?';

  @override
  String get changeAddress => 'ኣድራሻ ቀይር';

  @override
  String get remove => 'ኣልግስ';

  @override
  String itemRemovedSuccessfully(String itemType) {
    return '$itemType ብዓወት ተኣልጊሱ';
  }

  @override
  String get homeAddress => 'ኣድራሻ ገዛ';

  @override
  String get workAddress => 'ኣድራሻ ስራሕ';

  @override
  String get favoritePlace => 'ዝፈቱ ቦታ';

  @override
  String get placeOptions => 'ኣማራጺታት ቦታ';

  @override
  String get clearAllDataTitle => 'ኩሉ ዳታ ክጠፍእ\'ዶ?';

  @override
  String get clearAllDataContent => 'እዚ ንኹሉ ገዛ፣ ስራሕ፣ ዝፈትዉዎምን ናይ ቀረባ ግዜ ቦታታትን ከልግሶ እዩ። እዚ ስጉምቲ እዚ ክምለስ ኣይክእልን እዩ።';

  @override
  String get clearEverything => 'ኩሉ ኣጥፍእ';

  @override
  String get allDataCleared => 'ኩሉ ዳታ ብዓወት ጸሪዩ';

  @override
  String get searchErrorTitle => 'ምድላይ ኣይተሳኸዐን';

  @override
  String get searchErrorMessage => 'በጃኹም ናይ ኢንተርነት ምትእስሳርኩም ኣረጋጊጽኩም እንደገና ፈትኑ።';

  @override
  String get noResultsFound => 'ዝኾነ ውጽኢት ኣይተረኽበን';

  @override
  String get tryDifferentSearch => 'ኻልእ ናይ ምድላይ ቃል ፈትን';

  @override
  String get pickOnMap => 'ካብ ካርታ ምረጽ';

  @override
  String get clearAll => 'ኩሉ ኣጥፍእ';

  @override
  String get add => 'ወስኽ';

  @override
  String get addYourHomeAddress => 'ኣድራሻ ገዛኹም ኣእትዉ';

  @override
  String get addYourWorkAddress => 'ኣድራሻ ስራሕኩም ኣእትዉ';

  @override
  String get favorites => 'ዝተፈተዉ';

  @override
  String get recentTrips => 'ናይ ቀረባ ግዜ ጉዕዞታት';

  @override
  String get noFavoritesYet => 'ገና ዝኾነ ዝተፈተወ የለን';

  @override
  String get addFavoritesMessage => 'ቐልጢፍካ ንምርካብ እቶም ብተደጋጋሚ ትበጽሖም ቦታታት ወስኽ።';

  @override
  String get noRecentTrips => 'ናይ ቀረባ ግዜ ጉዕዞ የለን';

  @override
  String get recentTripsMessage => 'ናይ ቀረባ ግዜ መዓርፎኻታትካ ኣብዚ ክረኣዩ እዮም።';

  @override
  String recentTripsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ናይ ቀረባ ግዜ ጉዕዞታት',
      one: '1 ናይ ቀረባ ግዜ ጉዕዞ',
      zero: 'ናይ ቀረባ ግዜ ጉዕዞ የለን',
    );
    return '$_temp0';
  }

  @override
  String get recentsCleared => 'ናይ ቀረባ ግዜ ጉዕዞታት ጸሪዮም';

  @override
  String get recentTripRemoved => 'ናይ ቀረባ ግዜ ጉዕዞ ተኣልጊሱ';

  @override
  String get searching => 'ይድለ ኣሎ...';

  @override
  String get yourCurrentPosition => 'ናይ ሕጂ ቦታኻ';

  @override
  String get useCurrentLocation => 'ናይ ሕጂ ቦታ ተጠቐም';

  @override
  String get planYourRoute => 'መንገድኻ ውጠኑ';

  @override
  String get planningPanelVehicleSelection => 'ምርጫ ተሽከርካሪ';

  @override
  String get planningPanelEngageButton => 'ጀምር';

  @override
  String get planningPanelTitle => 'ጉዕዞኻ ምረጽ';

  @override
  String get noRidesAvailable => 'ኣብዚ ከባቢ ዝርከብ መጓዓዝያ የለን።';

  @override
  String get vehicleTaglineStandard => 'እቲ ፍጹም መዓልታዊ ኣድላዪ።';

  @override
  String get vehicleTaglineComfort => 'ተወሳኺ ምቾት ንምዝንጋዕ ጉዕዞ።';

  @override
  String get vehicleTaglineVan => 'ንኹሎም ሰራሕተኛታት ዝኸውን ክፍሊ።';

  @override
  String get vehicleTaglineDefault => 'ንጉዕዞኻ ጽቡቕ ምርጫ።';

  @override
  String get fareCalculating => 'ዋጋ ይስላዕ ኣሎ...';

  @override
  String get ride => 'ጉዕዞ';

  @override
  String get confirmButtonRequesting => 'ይሕተት ኣሎ...';

  @override
  String get confirmButtonRequest => ' ሕተት';

  @override
  String get postTripAddCompliment => 'ምስጋና ወስኽ';

  @override
  String get driverOnWayEnjoyYourRide => 'ጉዕዞኻ/ኺ የሐጉስካ/ኪ!';

  @override
  String get driverOnWayMeetAtPickup => 'በጃኹም ኣብ መበገሲ ቦታ ተራኸቡ።';

  @override
  String get ongoingTripTitle => 'ኣብ ጉዕዞ';

  @override
  String get tripDuration => 'ናይ ጉዕዞ ግዜ';

  @override
  String get safetyAndTools => 'ድሕነትን መሳርሒታትን';

  @override
  String get shareTrip => 'ጉዕዞ ኣካፍል';

  @override
  String get emergencySOS => 'ናይ ህጹጽ ረድኤት';

  @override
  String get emergencyDialogTitle => 'ናይ ህጹጽ ረድኤት';

  @override
  String get emergencyDialogContent => 'እዚ ምስ ናይ ከባቢ ህጹጽ ረድኤት ኣገልግሎታት የራኽበካ። ክትቅጽል ከም ዝደለኻ ርግጸኛ ዲኻ?';

  @override
  String get emergencyDialogCancel => 'ሰርዝ';

  @override
  String get emergencyDialogConfirm => 'ሕጂ ደውል';

  @override
  String get phoneNumberNotAvailable => 'ቁጽሪ ተሌፎን ናይቲ መራሕ ማኪና የለን።';

  @override
  String couldNotLaunch(Object url) {
    return '$url ክኽፈት ኣይተኻእለን';
  }

  @override
  String get discount => 'ቅናሽ';

  @override
  String get myTripsScreenTitle => 'ናይ ውዕል ጉዕዞታተይ';

  @override
  String get myTripsScreenRefresh => 'ሓድስ';

  @override
  String myTripsScreenErrorPrefix(String errorMessage) {
    return 'ጌጋ: $errorMessage';
  }

  @override
  String get myTripsScreenRetry => 'ደጊምካ ፈትን';

  @override
  String get myTripsScreenNoTrips => 'ዝኾነ ናይ ውዕል ጉዕዞታት ኣይተረኽበን።';

  @override
  String get myTripsScreenTripIdPrefix => 'መለለዪ ጉዕዞ: ';

  @override
  String get myTripsScreenFromPrefix => 'ካብ: ';

  @override
  String get myTripsScreenToPrefix => 'ናብ: ';

  @override
  String get myTripsScreenPickupPrefix => 'ዝውሰደሉ ሰዓት: ';

  @override
  String get myTripsScreenDropoffPrefix => 'ዝራገፈሉ ሰዓት: ';

  @override
  String get myTripsScreenFarePrefix => 'ዋጋ: ብር ';

  @override
  String get myTripsScreenRatingPrefix => 'ደረጃ: ';

  @override
  String get myTripsScreenNotAvailable => 'የለን';

  @override
  String get tripStatusCompleted => 'ተዛዚሙ';

  @override
  String get tripStatusStarted => 'ተጀሚሩ';

  @override
  String get tripStatusPending => 'ይጽበ';

  @override
  String get tripStatusCancelled => 'ተሰሪዙ';

  @override
  String get drawerMyTrips => 'ጉዕዞታተይ';

  @override
  String get drawerAvailableContracts => 'ዝርከቡ ውዕላት';

  @override
  String get drawerMyTransactions => 'ግብይታተይ';

  @override
  String get drawerLogoutForgetDevice => 'ውጻእ እሞ ነቲ መሳርሒ ረስዓዮ';

  @override
  String get contractPanelTitle => 'ጉዕዞታት ውዕል';

  @override
  String get contractPanelSubtitle => 'ናይ ብሉጽ ተሞክሮ ጉዕዞኻ';

  @override
  String get contractPanelActiveSubscriptionsTitle => 'ንጡፋት ምዝገባታት';

  @override
  String get contractPanelActiveSubscriptionsSubtitle => 'ናይ ሕጂ ብሉጻት ጉዕዞታትካ';

  @override
  String get contractPanelErrorLoadSubscriptions => 'ነቲ ምዝገባታትካ ክጽዕኖ ኣይከኣለን';

  @override
  String get contractPanelEmptySubscriptions => 'ንጡፍ ምዝገባ ኣይተረኽበን';

  @override
  String get contractPanelEmptySubscriptionsSubtitle => 'ነቲ ናይ መጀመርታ ብሉጽ ጉዕዞኻ ኣብ ታሕቲ ፍጠሮ';

  @override
  String get contractPanelNewContractsTitle => 'ሓደሽቲ ውዕላት';

  @override
  String get contractPanelNewContractsSubtitle => 'ነቲ ተሞክሮ ጉዕዞኻ ኣመሓይሾ';

  @override
  String get contractPanelErrorLoadContracts => 'ዓይነታት ውዕላት ክጽዕኖ ኣይከኣለን';

  @override
  String get contractPanelEmptyContracts => 'ዝርከብ ውዕል የለን';

  @override
  String get contractPanelEmptyContractsSubtitle => 'ንሓደሽቲ ምቕራባት ጸኒሕካ ተመለስ';

  @override
  String get contractPanelRetryButton => 'ደጊምካ ፈትን';

  @override
  String contractPanelDiscountOff(String discountValue) {
    return '$discountValue% ቅናሽ';
  }

  @override
  String get contractPickerTitlePickup => 'መበገሲ ቦታ ምረፅ';

  @override
  String get contractPickerTitleDestination => 'መድረሻ ቦታ ምረፅ';

  @override
  String get contractPickerHintPickup => 'መበገሲ ቦታ ድለ...';

  @override
  String get contractPickerHintDestination => 'መድረሻ ቦታ ድለ...';

  @override
  String get contractPickerNoRecents => 'ቅርብ ግዜ ዝተገበረ ፍለጋ የለን።';

  @override
  String get contractPickerRecentsTitle => 'ቅርብ ግዜ ዝተገበሩ ፍለጋታት';

  @override
  String get contractPickerNoResults => 'ዝኾነ ውጽኢት ኣይተረኽበን።';

  @override
  String get contractDriverLoading => 'ናይ ኮንትራት ሾፌርካ/ኺ እናተረኽበ...';

  @override
  String get contractDriverTypeLabel => 'ናይ ኮንትራት ሾፌር';

  @override
  String get contractDetailsTitle => 'ናይ ኮንትራት ዝርዝራት';

  @override
  String get contractDetailsSubscriptionId => 'መፍለዪ ምዝገባ';

  @override
  String get contractDetailsContractType => 'ዓይነት ኮንትራት';

  @override
  String get contractDetailsScheduledRide => 'ዝተመደበ ጉዕዞ';

  @override
  String get contractDetailsTimeRemaining => 'ዝተረፈ ግዜ';

  @override
  String get contractExpired => 'ኮንትራት ተዛዚሙ';

  @override
  String contractTimeLeftDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count መዓልታት ተሪፈን',
      one: '$count መዓልቲ ተሪፉ',
    );
    return '$_temp0';
  }

  @override
  String contractTimeLeftHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ሰዓታት ተሪፈን',
      one: '$count ሰዓት ተሪፉ',
    );
    return '$_temp0';
  }

  @override
  String contractTimeLeftMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ደቓይቕ ተሪፈን',
      one: '$count ደቒቕ ተሪፉ',
    );
    return '$_temp0';
  }

  @override
  String get confirmRideTitle => 'ጉዕዞኹም ኣረጋግጹ';

  @override
  String bookingUnderContract(Object contractType) {
    return 'ብመሰረት ውዕል ትሓዙ ኣለኹም: $contractType';
  }

  @override
  String get tripSummaryTitle => 'ጽማቕ ጉዕዞ';

  @override
  String get assignedDriver => 'ዝተመደበ መራሕ ማኪና';

  @override
  String get driverContact => 'ቁጽሪ ስልኪ መራሕ ማኪና';

  @override
  String get vehicle => 'ተሽከርካሪት';

  @override
  String get plateNumber => 'ቁጽሪ ሰሌዳ';

  @override
  String get contractPrice => 'ዋጋ ውዕል';

  @override
  String get tripDistance => 'ርሕቀት ጉዕዞ';

  @override
  String get paymentStatus => 'ኩነታት ክፍሊት';

  @override
  String get subscriptionStatus => 'ኩነታት ምዝገባ';

  @override
  String get validity => 'እዋን ኣገልግሎት';

  @override
  String get driverPending => 'መራሕ ማኪና ይጽበ';

  @override
  String get negotiated => 'ብምስምማዕ';

  @override
  String get confirmTodaysPickup => 'ናይ ሎሚ ጉዕዞ ኣረጋግጽ';

  @override
  String get exploreContracts => 'ውዕላት መርምር';

  @override
  String get refresh => 'ሓድስ';

  @override
  String get retry => 'እንደገና ፈትን';

  @override
  String get rideSubscriptionFallbackTitle => 'ናይ ጉዕዞ ምዝገባ';

  @override
  String get basePrice => 'መበገሲ ዋጋ';

  @override
  String get minimumFare => 'ዝተሓተ ክፍሊት';

  @override
  String get maxPassengers => 'ዝለዓለ ቁጽሪ ተጓዓዝቲ';

  @override
  String get featureWifi => 'ዋይፋይ';

  @override
  String get featureAC => 'ኤሲ';

  @override
  String get featurePremiumSeats => 'ፍሉይ መናበሪ';

  @override
  String get featurePrioritySupport => 'ቀዳምነት ደገፍ';

  @override
  String get availableContractsTitle => 'ዘለዉ ውዕላት';

  @override
  String get noContractsAvailableTitle => 'ዝርከብ ውዕል የለን';

  @override
  String get noContractsAvailableMessage => 'ሓደሽቲ ናይ ምዝገባ Teklifler ንምርካብ በጃኹም ደሓር ተመሊስኩም ፈትሹ።';

  @override
  String get failedToLoadContractsTitle => 'ውዕላት ምጽዓን ኣይተኻእለን';

  @override
  String get failedToLoadContractsMessage => 'በጃኹም ናይ ኢንተርነት መራኸቢኹም ኣረጋጊጽኩም እንደገና ፈትኑ።';

  @override
  String get baseRate => 'መበገሲ ዋጋ';

  @override
  String get selectAndPickRoute => 'መርጽ እሞ መስመር ምረጽ';

  @override
  String get myTransactions => 'ናይ ኣታዊን ወጻእን';

  @override
  String get errorPrefix => 'ጌጋ';

  @override
  String get currentWalletBalance => 'ናይ ሕጂ ናይ ቦርሳኻ ሚዛን';

  @override
  String get transactionHistory => 'ታሪኽ ኣታዊን ወጻእን';

  @override
  String get noTransactionsYet => 'ክሳብ ሕጂ ዝኾነ ምንቅስቓስ የለን';

  @override
  String get yourRecentTransactionsWillAppearHere => 'ናይ ቀረባ ግዜ ምንቅስቓሳትካ ኣብዚ ክቐርብ እዩ።';

  @override
  String get transactionStatusCompleted => 'ተዛዚሙ';

  @override
  String get transactionStatusPending => 'ይጽበ';

  @override
  String get transactionStatusFailed => 'ኣይተሳኸዐን';

  @override
  String get subscriptionDetails => 'ዝርዝር ምዝገባ';

  @override
  String get payment => 'ክፍሊት';

  @override
  String get distance => 'ርሕቀት';

  @override
  String get financials => 'ፋይናንስ';

  @override
  String get baseFare => 'መበገሲ ዋጋ';

  @override
  String get finalFare => 'ናይ መወዳእታ ዋጋ';

  @override
  String get name => 'ሽም';

  @override
  String get passengerDetails => 'ዝርዝር ተጓዓዛይ';

  @override
  String get identifiers => 'መለለይቲ';

  @override
  String get subscriptionId => 'መለለዪ ምዝገባ';

  @override
  String get contractId => 'መለለዪ ውዕል';

  @override
  String get passengerId => 'መለለዪ ተጓዓዛይ';

  @override
  String get driverId => 'መለለዪ መራሕ ማኪና';

  @override
  String get notAssigned => 'ኣይተመደበን';

  @override
  String get callDriver => 'ናብ መራሕ ማኪና ደውል';

  @override
  String get daysLeft => 'ዝተረፉ መዓልታት';

  @override
  String get expiresToday => 'ሎሚ የብቅዕ';

  @override
  String get statusExpired => 'ኣብቂዑ';

  @override
  String daysLeftSingular(int count) {
    return '$count መዓልቲ ተሪፉ';
  }

  @override
  String daysLeftPlural(int count) {
    return '$count መዓልታት ተሪፈን';
  }

  @override
  String get newSubscriptionRequest => 'New Subscription Request';

  @override
  String subscribingTo(String contractType) {
    return 'Subscribing to: $contractType';
  }

  @override
  String get reviewRequestPrompt => 'በጃኹም መስመርኩም ኣረጋግጹን ዝደለኹምዎ ናይ ምዝገባ ግዜ ምረጹን።';

  @override
  String get yourRoute => 'ናትካ መስመር';

  @override
  String get dropoffLocation => 'መዓረፊ ቦታ';

  @override
  String get subscriptionDuration => 'ናይ ምዝገባ ግዜ';

  @override
  String get selectDateRange => 'ናይ ዕለት ክልል ንምምራጽ ጠውቕ';

  @override
  String get pleaseSelectDateRange => 'በጃኹም ናይ መጀመርታን መወዳእታን ዕለት ምረጹ።';

  @override
  String get proceedToPayment => 'ናብ ክፍሊት ቀጽል';

  @override
  String get requestSubmitted => 'ሕቶ ቀሪቡ\'ሎ!';

  @override
  String get approvalNotificationPrompt => 'ናይ ምዝገባ ሕቶኹም ንምሕደራ ፍቓድ ተላኢኹ ኣሎ። ንቑሕ ምስ ኮነ ክሕበረካ እዩ።';

  @override
  String get done => 'ተዛዚሙ';

  @override
  String get paymentScreenTitle => 'ክፍሊትካ/ኪ ኣጻንቅቕ/ኺ';

  @override
  String get paymentConfirmTitle => 'ክፍሊትካ/ኺ ኣረጋግጽ/ጺ';

  @override
  String paymentTotalAmount(Object amount) {
    return 'ጠቕላላ ድምር: ETB $amount';
  }

  @override
  String get paymentSelectGateway => 'ዝመረጽካዮ/ክዮ መዋፈሪ ክፍሊት ምረጽ/ጺ ወይ ድማ ናይ ባንኪ መረዳእታ ስቐል/ሊ';

  @override
  String get paymentPreferredMethod => 'ዝተመረጸ ኣገባብ';

  @override
  String get paymentOtherGateways => 'ካልኦት መዋፈሪታት';

  @override
  String get paymentChooseGateway => 'መዋፈሪ ምረጽ/ጺ';

  @override
  String get paymentViewMoreOptions => 'ተወሳኺ ኣማራጺታት ርአ/ኢ';

  @override
  String paymentPayWith(Object methodName) {
    return 'ብ $methodName ክፈል/ሊ';
  }

  @override
  String get paymentSelectAGateway => 'መዋፈሪ ምረጽ/ጺ';

  @override
  String get paymentOr => 'ወይ';

  @override
  String get paymentUploadBankReceipt => 'ናይ ባንኪ መረዳእታ ስቐል/ሊ';

  @override
  String get paymentManualUploadTitle => 'መረዳእታ ምስቃል';

  @override
  String get paymentManualUploadSubtitle => 'ናይ ባንኪ መለለዪ ቁጽሪ ግብሪት ኣእትው/ዊ እሞ ስእሊ መረዳእታኻ/ኺ ስቐል/ሊ';

  @override
  String get paymentTxnReferenceLabel => 'መለለዪ ቁጽሪ ግብሪት';

  @override
  String get paymentTxnReferenceRequired => 'እዚ ዓውዲ\'ዚ ክመልእ ኣለዎ';

  @override
  String get paymentTapToSelectReceipt => 'መረዳእታ ንምምራጽ ጠውቕ/ኺ';

  @override
  String get paymentSubmitForReview => 'ንምርመራ ኣቕርብ/ቢ';

  @override
  String paymentErrorLoading(Object error) {
    return 'ኣማራጺታት ክፍሊት ምጽዓን ኣይተኻእለን: $error';
  }

  @override
  String get paymentNoMethodsAvailable => 'ዘሎ ኣማራጺ ክፍሊት የለን';

  @override
  String get paymentSuccessDialogTitle => 'መረጋገጺ ተላኢኹ!';

  @override
  String get paymentSuccessDialogContent => 'ናብ ስልክኻ/ኺ ሕቶ ተላኢኹ ኣሎ። በጃኻ/ኺ ክፍሊት ንምጽዳቕ ፒን ቁጽርኻ/ኺ ኣእትው/ዊ።';

  @override
  String get paymentErrorDialogTitle => 'ጌጋ ክፍሊት';

  @override
  String get paymentManualSuccessTitle => 'ብዓወት ተሰቒሉ';

  @override
  String get paymentManualSuccessContent => 'መረጋገጺ ክፍሊትካ/ኺ ቀሪቡ ኣብ ግምገማ ይርከብ።';

  @override
  String get paymentOkButton => 'ሕራይ';

  @override
  String paymentErrorSnackbar(Object message) {
    return 'ጌጋ: $message';
  }

  @override
  String get contractsSectionTitle => 'ናይ ጉዕዞ ፕላን ተጠቐም';

  @override
  String get contractsSectionDescription => 'ነዚ ጉዕዞ\'ዚ ፍሉይ ዋጋ ንምርካብ፡ እቲ ብቕድሚት ዝተኸፍለ ናይ ሰሙን ወይ ወርሒ ፕላን ተጠቐም ።';

  @override
  String get tripDetails => 'ዝርዝራት ጉዕዞ';

  @override
  String get confirmDropoff => 'ምብጻሕ ኣረጋግጽ';

  @override
  String get enterCode => 'ኮድ ኣእትው';

  @override
  String otpScreenSubtitle(String phoneNumber) {
    return 'ናብ\n$phoneNumber ናይ መረጋገጺ ኮድ ልኢኽና ኣለና';
  }

  @override
  String get verifyButton => 'ኣረጋግጽ';

  @override
  String get didNotReceiveCodeResend => 'ኮድ ኣይበጽሓካን? እንደገና ስደድ';

  @override
  String resendCodeIn(int seconds) {
    return 'ኣብ ውሽጢ $seconds ካልኢት እንደገና ስደድ';
  }

  @override
  String get enterValidOtp => 'በጃኻ ትኽክለኛ ናይ 6-ቁጽሪ ኮድ ኣእትው።';

  @override
  String get resendingOtp => 'ኮድ እንደገና ይስደድ ኣሎ...';
}
