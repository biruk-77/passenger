// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Amharic (`am`).
class AppLocalizationsAm extends AppLocalizations {
  AppLocalizationsAm([String locale = 'am']) : super(locale);

  @override
  String get pageHomeTitle => 'ዋና ገጽ';

  @override
  String get whereTo => 'ወዴት ነው?';

  @override
  String get mapSetDestination => 'መድረሻዎን ለማዘጋጀት መታ ያድርጉ';

  @override
  String get mapSetPickup => 'የመነሻ ቦታዎን ለማዘጋጀት መታ ያድርጉ';

  @override
  String get findingYourLocation => 'አካባቢዎን በማግኘት ላይ...';

  @override
  String get cancel => 'ይቅር';

  @override
  String get chatWithDriver => 'ከሹፌሩ ጋር ይወያዩ';

  @override
  String get noMessagesYet => 'እስካሁን ምንም መልዕክቶች የሉም።';

  @override
  String get pageSettingsTitle => 'ቅንብሮች';

  @override
  String get selectLanguage => 'ቋንቋ ይምረጡ';

  @override
  String get loginWelcomeBack => 'እንኳን በደህና ተመለሱ';

  @override
  String get loginWithPhoneSubtitle => 'በስልክ ቁጥርዎ ይግቡ';

  @override
  String get loginWithEmailSubtitle => 'በኢሜልዎ ይግቡ';

  @override
  String get loginMethodPhone => 'ስልክ';

  @override
  String get loginMethodEmail => 'ኢሜል';

  @override
  String get phoneNumber => 'ስልክ ቁጥር';

  @override
  String get email => 'ኢሜይል';

  @override
  String get password => 'የይለፍ ቃል';

  @override
  String get errorEnterPhoneNumber => 'እባክዎ ስልክ ቁጥር ያስገቡ';

  @override
  String get errorInvalidPhoneNumber => 'ትክክለኛ ባለ 9 ወይም 10 አሃዝ ቁጥር ያስገቡ';

  @override
  String get errorEnterEmail => 'እባክዎ ኢሜል ያስገቡ';

  @override
  String get errorInvalidEmail => 'እባክዎ ትክክለኛ ኢሜይል ያስገቡ';

  @override
  String get errorEnterPassword => 'እባክዎ የይለፍ ቃልዎን ያስገቡ';

  @override
  String get sendOtpButton => 'ኦቲፒ ላክ';

  @override
  String get signInButton => 'ግባ';

  @override
  String get dontHaveAccount => 'አካውንት የለዎትም? ';

  @override
  String get register => 'ይመዝገቡ';

  @override
  String get drawerProfileSettings => 'የመገለጫ ቅንብሮች';

  @override
  String get drawerPaymentMethod => 'የክፍያ ዘዴ';

  @override
  String get drawerRideHistory => 'የጉዞ ታሪክ';

  @override
  String get drawerSupport => 'ድጋፍ';

  @override
  String get drawerSettings => 'ቅንብሮች';

  @override
  String get drawerLogout => 'ውጣ';

  @override
  String get drawerGuestUser => 'እንግዳ ተጠቃሚ';

  @override
  String get drawerWallet => 'ዋሌት';

  @override
  String get drawerRating => 'ደረጃ';

  @override
  String get drawerTrips => 'ጉዞዎች';

  @override
  String drawerWalletBalance(String balance) {
    return 'ብር $balance';
  }

  @override
  String appVersion(String versionNumber) {
    return 'ስሪት $versionNumber';
  }

  @override
  String get settingsTitle => 'ቅንብሮች';

  @override
  String get settingsSectionAccount => 'አካውንት';

  @override
  String get settingsEditProfile => 'መገለጫ አርትዕ';

  @override
  String get settingsEditProfileSubtitle => 'ስምዎን፣ ኢሜልዎን እና ፎቶዎን ያስተዳድሩ';

  @override
  String get settingsSectionPreferences => 'ምርጫዎች';

  @override
  String get settingsLanguage => 'ቋንቋ';

  @override
  String get settingsDarkMode => 'ጨለማ ገጽታ';

  @override
  String get settingsSectionAbout => 'ስለ';

  @override
  String get settingsHelpSupport => 'እገዛ እና ድጋፍ';

  @override
  String get settingsTermsOfService => 'የአገልግሎት ውል';

  @override
  String get settingsPrivacyPolicy => 'የግላዊነት ፖሊሲ';

  @override
  String get editProfileTitle => 'መገለጫ አርትዕ';

  @override
  String get personalInformation => 'የግል መረጃ';

  @override
  String get fullName => 'ሙሉ ስም';

  @override
  String get emailAddress => 'ኢሜይል አድራሻ';

  @override
  String get emergencyContacts => 'የአደጋ ጊዜ እውቂያዎች';

  @override
  String contactNumber(Object number) {
    return 'እውቂያ #$number';
  }

  @override
  String get contactFullName => 'የእውቂያ ሙሉ ስም';

  @override
  String get contactPhoneNumber => 'የእውቂያ ስልክ ቁጥር';

  @override
  String get addContact => 'እውቂያ ጨምር';

  @override
  String get saveChanges => 'ለውጦችን አስቀምጥ';

  @override
  String get security => 'ደህንነት';

  @override
  String get changePassword => 'የይለፍ ቃል ቀይር';

  @override
  String get currentPassword => 'የአሁኑ የይለፍ ቃል';

  @override
  String get newPassword => 'አዲስ የይለፍ ቃል';

  @override
  String get confirmNewPassword => 'አዲስ የይለፍ ቃል አረጋግጥ';

  @override
  String get errorEnterName => 'እባክዎ ስምዎን ያስገቡ';

  @override
  String get errorEnterNameForContact => 'የእውቂያ ስም ያስገቡ';

  @override
  String get errorEnterPhoneForContact => 'የእውቂያ ስልክ ያስገቡ';

  @override
  String get errorInvalidPhone => 'የተሳሳተ የስልክ ቁጥር ቅርጸት';

  @override
  String get errorEnterCurrentPassword => 'አዲስ የይለፍ ቃል ለማዘጋጀት እባክዎ የአሁኑን የይለፍ ቃልዎን ያስገቡ';

  @override
  String get errorEnterNewPassword => 'አዲስ የይለፍ ቃል ያስገቡ';

  @override
  String get errorPasswordTooShort => 'የይለፍ ቃል ቢያንስ 6 ቁምፊዎች መሆን አለበት';

  @override
  String get errorPasswordsDoNotMatch => 'የይለፍ ቃላት አይዛመዱም';

  @override
  String get profileUpdateSuccess => 'መገለጫ በተሳካ ሁኔታ ተዘምኗል!';

  @override
  String get profileUpdateFailed => 'መገለጫ ማዘመን አልተሳካም';

  @override
  String get passwordUpdateSuccess => 'የይለፍ ቃል በተሳካ ሁኔታ ተቀይሯል!';

  @override
  String get passwordUpdateFailed => 'የይለፍ ቃል መቀየር አልተሳካም።';

  @override
  String get authWelcome => 'እንኳን በደህና መጡ';

  @override
  String get authSignInToContinue => 'ለመቀጠል ወደ አካውንትዎ ይግቡ';

  @override
  String get authCreateAccount => 'አካውንት ይፍጠሩ';

  @override
  String get authGetStarted => 'እንጀምር';

  @override
  String get authFullName => 'ሙሉ ስም';

  @override
  String get authPhoneNumber => 'ስልክ ቁጥር';

  @override
  String get authPassword => 'የይለፍ ቃል';

  @override
  String get authSignIn => 'ይግቡ';

  @override
  String get authRegister => 'አካውንት ይፍጠሩ';

  @override
  String get authNoAccount => 'አካውንት የለዎትም? ';

  @override
  String get authHaveAccount => 'አካውንት አለዎት? ';

  @override
  String get authErrorEnterFullName => 'እባክዎ ሙሉ ስምዎን ያስገቡ';

  @override
  String get authErrorEnterPhone => 'እባክዎ ስልክ ቁጥር ያስገቡ';

  @override
  String get authErrorInvalidPhone => 'እባክዎ ትክክለኛ ስልክ ቁጥር ያስገቡ';

  @override
  String get authErrorEnterPassword => 'እባክዎ የይለፍ ቃል ያስገቡ';

  @override
  String get authErrorPasswordShort => 'የይለፍ ቃል ቢያንስ 6 ቁምፊዎች መሆን አለበት';

  @override
  String get authSwitchToRegister => 'ይመዝገቡ';

  @override
  String get authSwitchToSignIn => 'ይግቡ';

  @override
  String get registerCreateAccount => 'አካውንት ይፍጠሩ';

  @override
  String get registerGetStarted => 'እንጀምር';

  @override
  String get registerFullName => 'ሙሉ ስም';

  @override
  String get registerPhoneNumber => 'ስልክ ቁጥር';

  @override
  String get registerPassword => 'የይለፍ ቃል';

  @override
  String get registerButton => 'አካውንት ይፍጠሩ';

  @override
  String get registerHaveAccount => 'አካውንት አለዎት? ';

  @override
  String get registerSignIn => 'ይግቡ';

  @override
  String get registerErrorEnterFullName => 'እባክዎ ሙሉ ስምዎን ያስገቡ';

  @override
  String get registerErrorEnterPhone => 'እባክዎ ስልክ ቁጥር ያስገቡ';

  @override
  String get registerErrorInvalidPhone => 'እባክዎ ትክክለኛ ስልክ ቁጥር ያስገቡ';

  @override
  String get registerErrorEnterPassword => 'እባክዎ የይለፍ ቃል ያስገቡ';

  @override
  String get registerErrorPasswordShort => 'የይለፍ ቃል ቢያንስ 6 ቁምፊዎች መሆን አለበት';

  @override
  String get historyScreenTitle => 'የጉዞ ታሪክ';

  @override
  String get historyLoading => 'በመጫን ላይ...';

  @override
  String get historyErrorTitle => 'ስህተት አጋጥሟል';

  @override
  String get historyErrorMessage => 'ያልተጠበቀ ስህተት ተከስቷል። እባክዎ የበይነመረብ ግንኙነትዎን ያረጋግጡ።';

  @override
  String get historyRetryButton => 'እንደገና ሞክር';

  @override
  String get historyEmptyTitle => 'እስካሁን ምንም ጉዞ የለም';

  @override
  String get historyEmptyMessage => 'ያጠናቀቋቸው ጉዞዎች እዚህ ይታያሉ።';

  @override
  String get historyCardFrom => 'ከ';

  @override
  String get historyCardTo => 'ወደ';

  @override
  String get historyCardFare => 'ዋጋ:';

  @override
  String get historyCardUnknownLocation => 'ቦታው አይታወቅም';

  @override
  String get historyStatusCompleted => 'ተጠናቋል';

  @override
  String get historyStatusCanceled => 'ተሰርዟል';

  @override
  String get historyStatusPending => 'በመጠባበቅ ላይ';

  @override
  String get currencySymbol => 'ብር';

  @override
  String get discoveryWhereTo => 'ወዴት እንሂድ?';

  @override
  String get discoverySearchDestination => 'መድረሻ ይፈልጉ';

  @override
  String get discoveryHome => 'ቤት';

  @override
  String get discoveryWork => 'ሥራ';

  @override
  String get discoveryAddHome => 'ቤት ያክሉ';

  @override
  String get discoveryAddWork => 'ሥራ ያክሉ';

  @override
  String get discoveryFavoritePlaces => 'ተወዳጅ ቦታዎች';

  @override
  String get discoveryAddFavoritePrompt => 'ተወዳጅ መድረሻ ለማከል \'+\' ይንኩ።';

  @override
  String get discoveryRecentTrips => 'የቅርብ ጊዜ ጉዞዎች';

  @override
  String get discoveryRecentTripRemoved => 'የቅርብ ጊዜ ጉዞ ተወግዷል።';

  @override
  String get discoveryClearAll => 'ሁሉንም አጽዳ';

  @override
  String get discoveryMenuChangeAddress => 'አድራሻ ይቀይሩ';

  @override
  String get discoveryMenuRemove => 'አስወግድ';

  @override
  String get searchingContactingDrivers => 'በአቅራቢያ ያሉ ሹፌሮችን በማነጋገር ላይ';

  @override
  String get searchingPleaseWait => 'እባክዎ መጓጓዣ እስክናገኝልዎ ድረስ ይጠብቁ።';

  @override
  String get searchingDetailFrom => 'ከ';

  @override
  String get searchingDetailTo => 'ወደ';

  @override
  String get searchingDetailVehicle => 'ተሽከርካሪ';

  @override
  String searchingDetailVehicleValue(Object name, Object price) {
    return '$name • ገምት. $price ብር';
  }

  @override
  String get searchingCancelButton => 'ፍለጋን ሰርዝ';

  @override
  String get planningPanelDistance => 'ርቀት';

  @override
  String get planningPanelDuration => 'የሚፈጀው ጊዜ';

  @override
  String get planningPanelConfirmButton => 'ጉዞውን ያረጋግጡ';

  @override
  String get planningPanelNoRidesAvailable => 'ምንም አይነት የጉዞ አማራጭ የለም።';

  @override
  String get planningPanelRideOptionsError => 'የጉዞ አማራጮችን መጫን አልተቻለም።';

  @override
  String planningPanelPrice(String price) {
    return 'ብር: $price';
  }

  @override
  String get planningPanelSelectRide => 'መኪና ይምረጡ';

  @override
  String get planningPanelConfirmRide => 'ጉዞን ያረጋግጡ';

  @override
  String get registerErrorPhoneInvalid => 'እባኮትን ትክክለኛ ስልክ ቁጥር ያስገቡ';

  @override
  String get optional => 'አማራጭ';

  @override
  String get registerConfirmPassword => 'የይለፍ ቃል ያረጋግጡ';

  @override
  String get registerErrorEnterConfirmPassword => 'እባኮትን የይለፍ ቃል አረጋግጥ ያስገቡ';

  @override
  String get registerErrorPasswordMismatch => 'የይለፍ ቃሎች አይዛመዱም';

  @override
  String get phone => 'ስልክ';

  @override
  String get registerGetOtp => 'GET OTP';

  @override
  String get registerErrorEnterEmail => 'Please enter your email';

  @override
  String get registerErrorInvalidEmail => 'Please enter a valid email address';

  @override
  String get driverOnWayEnRouteToDestination => 'ወደ መድረሻ በመጓዝ ላይ';

  @override
  String get driverOnWayDriverArriving => 'ሹፌርዎ እየመጣ ነው';

  @override
  String get driverOnWayBookingId => 'የቦታ ማስያዣ ቁጥር:';

  @override
  String get driverOnWayDriverId => 'የሹፌር መለያ:';

  @override
  String get driverOnWayPickup => 'መነሻ:';

  @override
  String get driverOnWayDropoff => 'መድረሻ:';

  @override
  String get driverOnWayCall => 'ይደውሉ';

  @override
  String get driverOnWayChat => 'ይፃፉ';

  @override
  String get driverOnWayCancelRide => 'ጉዞ ሰርዝ';

  @override
  String get driverOnWayDriverNotAvailable => 'ሹፌር የለም';

  @override
  String get driverOnWayNotAvailable => 'የለም';

  @override
  String get driverOnWayColorNotAvailable => 'ቀለም የለም';

  @override
  String get driverOnWayModelNotAvailable => 'ሞዴል የለም';

  @override
  String get driverOnWayPlateNotAvailable => 'ሰሌዳ ቁጥር የለም';

  @override
  String get driverOnWayVehicleUnknown => 'ያልታወቀ';

  @override
  String get ongoingTripEnjoyRide => 'ጉዞዎን ይደሰቱ!';

  @override
  String get ongoingTripOnYourWay => 'ወደ መድረሻዎ መንገድ ላይ ነዎት።';

  @override
  String get ongoingTripDriverOnWay => 'ሹፌሩ በመንገድ ላይ ነው';

  @override
  String ongoingTripDriverArrivingIn(String eta) {
    return 'ሹፌርዎ በግምት በ $eta ውስጥ ይደርሳል';
  }

  @override
  String get ongoingTripYourDriver => 'የእርስዎ ሹፌር';

  @override
  String get ongoingTripStandardCar => 'የተለመደ መኪና';

  @override
  String get ongoingTripPlatePlaceholder => '...';

  @override
  String get ongoingTripDefaultColor => 'ጥቁር';

  @override
  String get ongoingTripCall => 'ይደውሉ';

  @override
  String get ongoingTripChat => 'ይወያዩ';

  @override
  String get ongoingTripCancel => 'ይቅር';

  @override
  String get postTripCompleted => 'ጉዞ ተጠናቋል!';

  @override
  String get postTripYourDriver => 'የእርስዎ ሹፌር';

  @override
  String get postTripRateExperience => 'ልምድዎን ደረጃ ይስጡ';

  @override
  String get postTripAddComment => 'ዝርዝር አስተያየት ያክሉ (በፍላጎት)';

  @override
  String get postTripSubmitFeedback => 'አስተያየት ያስገቡ';

  @override
  String get postTripSkip => 'ዝለል';

  @override
  String get postTripShowAppreciation => 'አድናቆትዎን ያሳዩ?';

  @override
  String get postTripOther => 'ሌላ';

  @override
  String get postTripFinalFare => 'የመጨረሻ ዋጋ';

  @override
  String get postTripDistance => 'ርቀት';

  @override
  String get postTripTagExcellentService => 'ምርጥ አገልግሎት';

  @override
  String get postTripTagCleanCar => 'ንጹህ መኪና';

  @override
  String get postTripTagSafeDriver => 'ጥንቁቅ ሹፌር';

  @override
  String get postTripTagGoodConversation => 'ጥሩ ውይይት';

  @override
  String get postTripTagFriendlyAttitude => 'ወዳጃዊ አመለካከት';

  @override
  String get driverInfoWindowVehicleStandard => 'የተለመደ';

  @override
  String get driverInfoWindowAvailable => 'ይገኛል';

  @override
  String get driverInfoWindowOnTrip => 'በጉዞ ላይ';

  @override
  String get driverInfoWindowSelect => 'ምረጥ';

  @override
  String get notificationRideConfirmedTitle => 'ጉዞዎ ተረጋግጧል!';

  @override
  String notificationRideConfirmedBody(String driverName) {
    return 'ሹፌር $driverName በመንገድ ላይ ነው።';
  }

  @override
  String get notificationDriverArrivedTitle => 'ሹፌርዎ ደርሷል!';

  @override
  String get notificationDriverArrivedBody => 'እባክዎ ሹፌርዎን በመነሻ ቦታ ያግኙት።';

  @override
  String get notificationTripStartedTitle => 'ጉዞዎ ተጀምሯል';

  @override
  String get notificationTripStartedBody => 'ጉዞዎን ይደሰቱ! ደህንነቱ የተጠበቀ ጉዞ እንመኛለን።';

  @override
  String get notificationTripCompletedTitle => 'ጉዞ ተጠናቋል!';

  @override
  String get notificationTripCompletedBody => 'ከእኛ ጋር ስለተጓዙ እናመሰግናለን። በቅርቡ እንደገና እንደምናይዎት ተስፋ እናደርጋለን።';

  @override
  String get notificationRideCanceledTitle => 'ጉዞ ተሰርዟል';

  @override
  String get notificationRideCanceledBody => 'የጉዞ ጥያቄዎ ተሰርዟል።';

  @override
  String get notificationRequestSentTitle => 'የጉዞ ጥያቄ ቀርቧል';

  @override
  String get notificationRequestSentBody => 'ጥያቄዎን ተቀብለናል እና በአቅራቢያ ያሉ ሹፌሮችን እየፈለግን ነው።';

  @override
  String notificationNewMessageTitle(String driverName) {
    return 'ከ$driverName አዲስ መልዕክት';
  }

  @override
  String get notificationNoDriversTitle => 'ምንም ሹፌር አልተገኘም';

  @override
  String get notificationNoDriversBody => 'በአቅራቢያዎ ሹፌር ማግኘት አልቻልንም። እባክዎ ከትንሽ ጊዜ በኋላ እንደገና ይሞክሩ።';

  @override
  String get notificationBookingErrorTitle => 'የቡኪንግ ስህተት';

  @override
  String get arrived => 'ደርሷል';

  @override
  String get editProfileSubtitle => 'የግል መረጃዎን ወቅታዊ ያድርጉ';

  @override
  String notificationSearchingBody(String radius) {
    return 'በ $radius ኪ.ሜ ራዲየስ ውስጥ ሹፌሮችን በመፈለግ ላይ።';
  }

  @override
  String get notificationDriverNearbyTitle => 'ሹፌሩ በአቅራቢያ ነው።';

  @override
  String notificationDriverNearbyBody(String distance) {
    return 'ሹፌርዎ አሁን ከ $distance ሜትር ባነሰ ርቀት ላይ ነው።';
  }

  @override
  String get notificationDriverVeryCloseTitle => 'ሹፌሩ በጣም ቀርቧል';

  @override
  String get notificationDriverVeryCloseBody => 'ይዘጋጁ! ሹፌርዎ ሊደርስ ነው።';

  @override
  String get offlineOrderTitle => 'ከመስመር ውጭ ትዕዛዝ';

  @override
  String get offlineRequestTitle => 'በኤስኤምኤስ поездка ይጠይቁ';

  @override
  String get offlineRequestSubtitle => 'ኢንተርኔት የለም? ችግር የለም። ከታች ያሉትን ቦታዎች ያስገቡ እና ትዕዛዝዎን ለማረጋገጥ ተመልሰን እንደውልዎታለን።';

  @override
  String get pickupLocationHint => 'የመነሻ ቦታ ያስገቡ';

  @override
  String get destinationLocationHint => 'መድረሻ ያስገቡ';

  @override
  String get pickupValidationError => 'እባክዎ የመነሻ ቦታ ያስገቡ';

  @override
  String get destinationValidationError => 'እባክዎ መድረሻ ያስገቡ';

  @override
  String get prepareSmsButton => 'የኤስኤምኤስ ጥያቄ አዘጋጅ';

  @override
  String get smsCouldNotOpenError => 'የእርስዎን የኤስኤምኤስ መተግበሪያ መክፈት አልተቻለም።';

  @override
  String get smsGenericError => 'ኤስኤምኤስ ሲፈጥሩ ስህተት ተፈጥሯል።';

  @override
  String get step1Title => 'ቦታዎችን ያስገቡ';

  @override
  String get step1Subtitle => 'የት እንደምንወስድዎት እና ወዴት እንደሚሄዱ ይንገሩን።';

  @override
  String get step2Title => 'ኤስኤምኤስ አዘጋጅ';

  @override
  String get step2Subtitle => 'ከእርስዎ ዝርዝሮች ጋር የጽሑፍ መልእክት እንፈጥራለን።';

  @override
  String get step3Title => 'የእኛን ጥሪ ይጠብቁ';

  @override
  String get step3Subtitle => 'ጉዞዎን ለማረጋገጥ ቡድናችን በቅርቡ ይደውልልዎታል።';

  @override
  String get smsOfflineLogin => 'ኢንተርኔት የለም? በኤስኤምኤስ ይዘዙ';

  @override
  String get smsLaunchSuccessTitle => 'የኤስኤምኤስ መተግበሪያ ተከፍቷል';

  @override
  String get smsLaunchSuccessMessage => 'እባክዎ መልዕክቱን ይከልሱ እና ጥያቄዎን ለማስገባት \'שלח\' የሚለውን ይጫኑ።';

  @override
  String get smsCapabilityError => 'ይህ መሳሪያ የኤስኤምኤስ መልዕክቶችን መላክ አይችልም።';

  @override
  String get smsLaunchError => 'የኤስኤምኤስ መተግበሪያውን መክፈት አልተቻለም። እባክዎ የመሣሪያዎን ቅንብሮች ያረጋግጡ።';

  @override
  String get offline => 'ኦፍላይን ኤስኤምኤስ';

  @override
  String get skip => 'ዝለል';

  @override
  String get finish => 'ጨርስ';

  @override
  String get completeProfileTitle => 'አንድ የመጨረሻ ደረጃ';

  @override
  String get completeProfileSubtitle => 'ለመቀጠል መገለጫዎን ይሙሉ';

  @override
  String get mySubscriptionsTitle => 'የእኔ ምዝገባዎች';

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
  String get contractDetails => 'የውል ዝርዝሮች';

  @override
  String get status => 'ሁኔታ';

  @override
  String get duration => 'Duration';

  @override
  String get cost => 'Cost';

  @override
  String get routeInformation => 'የመንገድ መረጃ';

  @override
  String get pickup => 'መነሻ';

  @override
  String get dropoff => 'መድረሻ';

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
  String get saveLocationAs => 'ቦታውን ያስቀምጡ እንደ';

  @override
  String get home => 'ቤት';

  @override
  String get work => 'ሥራ';

  @override
  String get favorite => 'ተወዳጅ';

  @override
  String get goToDestination => 'ወደ መድረሻ ይሂዱ';

  @override
  String get saveAsHome => 'እንደ ቤት ያስቀምጡ';

  @override
  String get saveAsWork => 'እንደ ሥራ ያስቀምጡ';

  @override
  String get addToFavorites => 'ወደ ተወዳጆች ያክሉ';

  @override
  String get confirmLocation => 'ቦታውን ያረጋግጡ';

  @override
  String get currentLocation => 'አሁን ያለሁበት ቦታ';

  @override
  String get selectedLocation => 'የተመረጠ ቦታ';

  @override
  String get locationNotAvailable => 'አሁን ያለበት ቦታ የለም። ፈቃዶችን ያረጋግጡ።';

  @override
  String get selectPickupAndDestination => 'የመጫኛ እና መድረሻ ቦታ ይምረጡ።';

  @override
  String get clearRecentPlacesQuestion => 'የቅርብ ጊዜ ቦታዎችን ያጽዱ?';

  @override
  String get actionCannotBeUndone => 'ይህ እርምጃ ሊቀለበስ አይችልም።';

  @override
  String get clear => 'አጽዳ';

  @override
  String get setRoute => 'መንገድ ያስቀምጡ';

  @override
  String get selectLocation => 'ቦታ ይምረጡ';

  @override
  String get pickupLocation => 'መነሻ ቦታ';

  @override
  String get destination => 'መድረሻ';

  @override
  String get setOnMap => 'በካርታ ላይ አስቀምጥ';

  @override
  String get current => 'አሁን ያለ';

  @override
  String get savedPlaces => 'የተቀመጡ ቦታዎች';

  @override
  String get recent => 'የቅርብ ጊዜ';

  @override
  String get addHome => 'ቤት ጨምር';

  @override
  String get addWork => 'ሥራ ጨምር';

  @override
  String get setPickup => 'መበገሲ ኣድርግ';

  @override
  String get setDestination => 'መወዳእታ ኣድርግ';

  @override
  String get confirmPickup => 'መንኮራኩሩን አረጋግጥ';

  @override
  String get confirmDestination => 'መድረሻውን አረጋግጥ';

  @override
  String get discoverySetHome => 'ቤት አድርግ';

  @override
  String get discoverySetWork => 'ስራ አድርግ';

  @override
  String get discoveryAddFavorite => 'ተወዳጅ አክል';

  @override
  String get setAsPickupLocation => 'መነሻ';

  @override
  String get setAsDestination => 'መድረሻ አድርግ';

  @override
  String get updateRoute => 'መንገድ አዘምን';

  @override
  String get setPickupFirst => 'መነሻ ';

  @override
  String get saveHome => 'ቤት አስቀምጥ';

  @override
  String get saveWork => 'ስራ አስቀምጥ';

  @override
  String get addFavorite => 'ተወዳጅ አክል';

  @override
  String get setYourRoute => 'መንገድዎን ያዘጋጁ';

  @override
  String get whereWouldYouLikeToGo => 'የት መሄድ ይፈልጋሉ?';

  @override
  String get changeAddress => 'አድራሻ ቀይር';

  @override
  String get remove => 'አስወግድ';

  @override
  String itemRemovedSuccessfully(String itemType) {
    return '$itemType በተሳካ ሁኔታ ተወግዷል';
  }

  @override
  String get homeAddress => 'የቤት አድራሻ';

  @override
  String get workAddress => 'የሥራ አድራሻ';

  @override
  String get favoritePlace => 'ተወዳጅ ቦታ';

  @override
  String get placeOptions => 'የቦታ አማራጮች';

  @override
  String get clearAllDataTitle => 'ሁሉንም ውሂብ ለማጥፋት ይፈልጋሉ?';

  @override
  String get clearAllDataContent => 'ይህ ሁሉንም ቤት፣ ስራ፣ ተወዳጆች እና የቅርብ ጊዜ ቦታዎችዎን ያስወግዳል። ይህ እርምጃ ሊቀለበስ አይችልም።';

  @override
  String get clearEverything => 'ሁሉንም አጥፋ';

  @override
  String get allDataCleared => 'ሁሉም ውሂብ በተሳካ ሁኔታ ተጠርጓል';

  @override
  String get searchErrorTitle => 'ፍለጋ አልተሳካም';

  @override
  String get searchErrorMessage => 'እባክዎ የበይነመረብ ግንኙነትዎን ያረጋግጡ እና እንደገና ይሞክሩ።';

  @override
  String get noResultsFound => 'ምንም ውጤት አልተገኘም';

  @override
  String get tryDifferentSearch => 'የተለየ የፍለጋ ቃል ይሞክሩ';

  @override
  String get pickOnMap => 'ካርታ ላይ ምረጥ';

  @override
  String get clearAll => 'ሁሉንም አጥፋ';

  @override
  String get add => 'አክል';

  @override
  String get addYourHomeAddress => 'የቤት አድራሻዎን ያስገቡ';

  @override
  String get addYourWorkAddress => 'የሥራ አድራሻዎን ያስገቡ';

  @override
  String get favorites => 'ተወዳጆች';

  @override
  String get recentTrips => 'የቅርብ ጊዜ ጉዞዎች';

  @override
  String get noFavoritesYet => 'እስካሁን ምንም ተወዳጆች የሉም';

  @override
  String get addFavoritesMessage => 'በፍጥነት ለመድረስ በብዛት የሚጎበኟቸውን ቦታዎች ያክሉ።';

  @override
  String get noRecentTrips => 'የቅርብ ጊዜ ጉዞዎች የሉም';

  @override
  String get recentTripsMessage => 'የቅርብ ጊዜ መዳረሻዎችዎ እዚህ ይታያሉ።';

  @override
  String recentTripsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count የቅርብ ጊዜ ጉዞዎች',
      one: '1 የቅርብ ጊዜ ጉዞ',
      zero: 'የቅርብ ጊዜ ጉዞዎች የሉም',
    );
    return '$_temp0';
  }

  @override
  String get recentsCleared => 'የቅርብ ጊዜ ጉዞዎች ተጠርገዋል';

  @override
  String get recentTripRemoved => 'የቅርብ ጊዜ ጉዞ ተወግዷል';

  @override
  String get searching => 'በመፈለግ ላይ...';

  @override
  String get yourCurrentPosition => 'የአሁኑ አካባቢዎ';

  @override
  String get useCurrentLocation => 'የአሁኑን አካባቢ ይጠቀሙ';

  @override
  String get planYourRoute => 'መንገድዎን ያቅዱ';

  @override
  String get planningPanelVehicleSelection => 'የተሽከርካሪ ምርጫ';

  @override
  String get planningPanelEngageButton => 'አስጀምር';

  @override
  String get planningPanelTitle => 'ጉዞዎን ይምረጡ';

  @override
  String get noRidesAvailable => 'በዚህ አካባቢ ምንም የሚገኝ ጉዞ የለም።';

  @override
  String get vehicleTaglineStandard => 'ለትዕለት ተስማሚ ምርጫ።';

  @override
  String get vehicleTaglineComfort => 'ለተመቸ ጉዞ ተጨማሪ ምቾት።';

  @override
  String get vehicleTaglineVan => 'ለሁሉም የሚሆን ሰፊ ቦታ።';

  @override
  String get vehicleTaglineDefault => 'ለጉዞዎ ምርጥ ምርጫ።';

  @override
  String get fareCalculating => 'ዋጋ በማስላት ላይ...';

  @override
  String get ride => 'ጉዞ';

  @override
  String get confirmButtonRequesting => 'እየተጠየቀ ነው...';

  @override
  String get confirmButtonRequest => 'ይጠይቁ';

  @override
  String get postTripAddCompliment => 'ምስጋና ጨምር';

  @override
  String get driverOnWayEnjoyYourRide => 'ጉዞዎን ይደሰቱ!';

  @override
  String get driverOnWayMeetAtPickup => 'እባክዎ መነሻ ቦታ ላይ ይጠብቁ።';

  @override
  String get ongoingTripTitle => 'በጉዞ ላይ';

  @override
  String get tripDuration => 'የጉዞ ቆይታ';

  @override
  String get safetyAndTools => 'ደህንነት እና መሳሪያዎች';

  @override
  String get shareTrip => 'ጉዞ አጋራ';

  @override
  String get emergencySOS => 'የአደጋ ጊዜ ጥሪ';

  @override
  String get emergencyDialogTitle => 'የአደጋ ጊዜ እርዳታ';

  @override
  String get emergencyDialogContent => 'ይህ የአካባቢውን የድንገተኛ አደጋ አገልግሎት ያገናኛል። ለመቀጠል እርግጠኛ ነዎት?';

  @override
  String get emergencyDialogCancel => 'ይቅር';

  @override
  String get emergencyDialogConfirm => 'አሁን ይደውሉ';

  @override
  String get phoneNumberNotAvailable => 'የሹፌሩ ስልክ ቁጥር የለም።';

  @override
  String couldNotLaunch(Object url) {
    return '$url መክፈት አልተቻለም';
  }

  @override
  String get discount => 'ቅናሽ';

  @override
  String get myTripsScreenTitle => 'የእኔ የኮንትራት ጉዞዎች';

  @override
  String get myTripsScreenRefresh => 'አድስ';

  @override
  String myTripsScreenErrorPrefix(String errorMessage) {
    return 'ስህተት፡ $errorMessage';
  }

  @override
  String get myTripsScreenRetry => 'እንደገና ሞክር';

  @override
  String get myTripsScreenNoTrips => 'ምንም የኮንትራት ጉዞዎች አልተገኙም።';

  @override
  String get myTripsScreenTripIdPrefix => 'የጉዞ መለያ፡ ';

  @override
  String get myTripsScreenFromPrefix => 'ከ፡ ';

  @override
  String get myTripsScreenToPrefix => 'ወደ፡ ';

  @override
  String get myTripsScreenPickupPrefix => 'መነሻ ሰዓት፡ ';

  @override
  String get myTripsScreenDropoffPrefix => 'መድረሻ ሰዓት፡ ';

  @override
  String get myTripsScreenFarePrefix => 'ዋጋ፡ ብር ';

  @override
  String get myTripsScreenRatingPrefix => 'ደረጃ፡ ';

  @override
  String get myTripsScreenNotAvailable => 'አልተገኘም';

  @override
  String get tripStatusCompleted => 'ተጠናቋል';

  @override
  String get tripStatusStarted => 'ተጀምሯል';

  @override
  String get tripStatusPending => 'በመጠባበቅ ላይ';

  @override
  String get tripStatusCancelled => 'ተሰርዟል';

  @override
  String get drawerMyTrips => 'የእኔ ጉዞዎች';

  @override
  String get drawerAvailableContracts => 'የሚገኙ ውሎች';

  @override
  String get drawerMyTransactions => 'የኔ ግብይቶች';

  @override
  String get drawerLogoutForgetDevice => 'ውጣ እና መሳሪያውን እርሳ';

  @override
  String get contractPanelTitle => 'የኮንትራት ጉዞዎች';

  @override
  String get contractPanelSubtitle => 'የእርስዎ ልዩ የጉዞ ልምድ';

  @override
  String get contractPanelActiveSubscriptionsTitle => 'በስራ ላይ ያሉ ምዝገባዎች';

  @override
  String get contractPanelActiveSubscriptionsSubtitle => 'የአሁኑ ልዩ ጉዞዎችዎ';

  @override
  String get contractPanelErrorLoadSubscriptions => 'የእርስዎን ምዝገባዎች መጫን አልተቻለም';

  @override
  String get contractPanelEmptySubscriptions => 'ምንም በስራ ላይ ያለ ምዝገባ አልተገኘም';

  @override
  String get contractPanelEmptySubscriptionsSubtitle => 'የመጀመሪያውን ልዩ ጉዞዎን ከታች ይፍጠሩ';

  @override
  String get contractPanelNewContractsTitle => 'አዲስ ውሎች';

  @override
  String get contractPanelNewContractsSubtitle => 'የጉዞ ልምድዎን ያሻሽሉ';

  @override
  String get contractPanelErrorLoadContracts => 'የውል አይነቶችን መጫን አልተቻለም';

  @override
  String get contractPanelEmptyContracts => 'ምንም የሚገኝ ውል የለም';

  @override
  String get contractPanelEmptyContractsSubtitle => 'ለአዲስ ቅናሾች ቆይተው ይመልከቱ';

  @override
  String get contractPanelRetryButton => 'እንደገና ይሞክሩ';

  @override
  String contractPanelDiscountOff(String discountValue) {
    return '$discountValue% ቅናሽ';
  }

  @override
  String get contractPickerTitlePickup => 'መነሻ ቦታ ይምረጡ';

  @override
  String get contractPickerTitleDestination => 'መድረሻ ቦታ ይምረጡ';

  @override
  String get contractPickerHintPickup => 'መነሻ ቦታ ይፈልጉ...';

  @override
  String get contractPickerHintDestination => 'መድረሻ ቦታ ይፈልጉ...';

  @override
  String get contractPickerNoRecents => 'በቅርብ ጊዜ የተደረጉ ፍለጋዎች የሉም።';

  @override
  String get contractPickerRecentsTitle => 'የቅርብ ጊዜ ፍለጋዎች';

  @override
  String get contractPickerNoResults => 'ምንም ውጤት አልተገኘም።';

  @override
  String get contractDriverLoading => 'የኮንትራት ሹፌርዎን በማግኘት ላይ...';

  @override
  String get contractDriverTypeLabel => 'የኮንትራት ሹፌር';

  @override
  String get contractDetailsTitle => 'የኮንትራት ዝርዝሮች';

  @override
  String get contractDetailsSubscriptionId => 'የምዝገባ መለያ';

  @override
  String get contractDetailsContractType => 'የኮንትራት አይነት';

  @override
  String get contractDetailsScheduledRide => 'የታቀደ ጉዞ';

  @override
  String get contractDetailsTimeRemaining => 'የቀረው ጊዜ';

  @override
  String get contractExpired => 'ኮንትራቱ አብቅቷል';

  @override
  String contractTimeLeftDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ቀናት ቀሩት',
      one: '$count ቀን ቀረው',
    );
    return '$_temp0';
  }

  @override
  String contractTimeLeftHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ሰዓታት ቀሩት',
      one: '$count ሰዓት ቀረው',
    );
    return '$_temp0';
  }

  @override
  String contractTimeLeftMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ደቂቃዎች ቀሩት',
      one: '$count ደቂቃ ቀረው',
    );
    return '$_temp0';
  }

  @override
  String get confirmRideTitle => 'ጉዞዎን ያረጋግጡ';

  @override
  String bookingUnderContract(Object contractType) {
    return 'የሚይዙት በ: $contractType ውል ነው';
  }

  @override
  String get tripSummaryTitle => 'የጉዞ ማጠቃለያ';

  @override
  String get assignedDriver => 'የተመደበ ሹፌር';

  @override
  String get driverContact => 'የሹፌር ስልክ';

  @override
  String get vehicle => 'ተሽከርካሪ';

  @override
  String get plateNumber => 'የሰሌዳ ቁጥር';

  @override
  String get contractPrice => 'የውል ዋጋ';

  @override
  String get tripDistance => 'የጉዞ ርቀት';

  @override
  String get paymentStatus => 'የክፍያ ሁኔታ';

  @override
  String get subscriptionStatus => 'የምዝገባ ሁኔታ';

  @override
  String get validity => 'የአገልግሎት ጊዜ';

  @override
  String get driverPending => 'ሹፌር በመጠባበቅ ላይ';

  @override
  String get negotiated => 'በስምምነት';

  @override
  String get confirmTodaysPickup => 'የዛሬን ጉዞ ያረጋግጡ';

  @override
  String get exploreContracts => 'ውሎችን ያስሱ';

  @override
  String get refresh => 'አድስ';

  @override
  String get retry => 'እንደገና ሞክር';

  @override
  String get rideSubscriptionFallbackTitle => 'የጉዞ ምዝገባ';

  @override
  String get basePrice => 'የመነሻ ዋጋ';

  @override
  String get minimumFare => 'ዝቅተኛ ክፍያ';

  @override
  String get maxPassengers => 'ከፍተኛ የተሳፋሪ ብዛት';

  @override
  String get featureWifi => 'ዋይፋይ';

  @override
  String get featureAC => 'ኤሲ';

  @override
  String get featurePremiumSeats => 'ፕሪሚየም መቀመጫዎች';

  @override
  String get featurePrioritySupport => 'ቅድሚያ የሚሰጥ ድጋፍ';

  @override
  String get availableContractsTitle => 'ያሉ ውሎች';

  @override
  String get noContractsAvailableTitle => 'ምንም ውል የለም';

  @override
  String get noContractsAvailableMessage => 'እባክዎ ለአዲስ የደንበኝነት ምዝገባ ቅናሾች ቆይተው እንደገና ይሞክሩ።';

  @override
  String get failedToLoadContractsTitle => 'ውሎችን መጫን አልተቻለም';

  @override
  String get failedToLoadContractsMessage => 'እባክዎ የበይነመረብ ግንኙነትዎን ያረጋግጡ እና እንደገና ይሞክሩ።';

  @override
  String get baseRate => 'የመነሻ ዋጋ';

  @override
  String get selectAndPickRoute => 'መርጠው መንገድ ይምረጡ';

  @override
  String get myTransactions => 'የእኔ እንቅስቃሴዎች';

  @override
  String get errorPrefix => 'ስህተት';

  @override
  String get currentWalletBalance => 'የአሁኑ የኪስ ቦርሳ ቀሪ ሂሳብ';

  @override
  String get transactionHistory => 'የእንቅስቃሴ ታሪክ';

  @override
  String get noTransactionsYet => 'እስካሁን ምንም እንቅስቃሴ የለም';

  @override
  String get yourRecentTransactionsWillAppearHere => 'የቅርብ ጊዜ እንቅስቃሴዎችዎ እዚህ ይታያሉ።';

  @override
  String get transactionStatusCompleted => 'ተጠናቋል';

  @override
  String get transactionStatusPending => 'በመጠባበቅ ላይ';

  @override
  String get transactionStatusFailed => 'አልተሳካም';

  @override
  String get subscriptionDetails => 'የምዝገባ ዝርዝሮች';

  @override
  String get payment => 'ክፍያ';

  @override
  String get distance => 'ርቀት';

  @override
  String get financials => 'ፋይናንስ';

  @override
  String get baseFare => 'የመሠረት ዋጋ';

  @override
  String get finalFare => 'የመጨረሻ ዋጋ';

  @override
  String get name => 'ስም';

  @override
  String get passengerDetails => 'የተሳፋሪ ዝርዝሮች';

  @override
  String get identifiers => 'መለያዎች';

  @override
  String get subscriptionId => 'የምዝገባ መለያ';

  @override
  String get contractId => 'የኮንትራት መለያ';

  @override
  String get passengerId => 'የተሳፋሪ መለያ';

  @override
  String get driverId => 'የሹፌር መለያ';

  @override
  String get notAssigned => 'አልተመደበም';

  @override
  String get callDriver => 'ወደ ሹፌሩ ይደውሉ';

  @override
  String get daysLeft => 'የቀሩ ቀናት';

  @override
  String get expiresToday => 'ዛሬ ጊዜው ያልፍበታል';

  @override
  String get statusExpired => 'ጊዜው አልፎበታል';

  @override
  String daysLeftSingular(int count) {
    return '$count ቀን ቀረው';
  }

  @override
  String daysLeftPlural(int count) {
    return '$count ቀናት ቀሩት';
  }

  @override
  String get newSubscriptionRequest => 'አዲስ የምዝገባ ጥያቄ';

  @override
  String subscribingTo(String contractType) {
    return 'ለ $contractType በመመዝገብ ላይ';
  }

  @override
  String get reviewRequestPrompt => 'እባክዎ መንገድዎን ያረጋግጡ እና የሚፈልጉትን የምዝገባ ጊዜ ይምረጡ።';

  @override
  String get yourRoute => 'የእርስዎ መንገድ';

  @override
  String get dropoffLocation => 'መድረሻ ቦታ';

  @override
  String get subscriptionDuration => 'የምዝገባ ጊዜ';

  @override
  String get selectDateRange => 'የቀን ክልል ለመምረጥ ይንኩ';

  @override
  String get pleaseSelectDateRange => 'እባክዎ የመነሻ እና የመድረሻ ቀን ይምረጡ።';

  @override
  String get proceedToPayment => 'ወደ ክፍያ ይቀጥሉ';

  @override
  String get requestSubmitted => 'ጥያቄው ገብቷል!';

  @override
  String get approvalNotificationPrompt => 'የምዝገባ ጥያቄዎ አስተዳደራዊ ይሁንታ ለማግኘት ተልኳል። ገቢር ሲሆን ይነገርዎታል።';

  @override
  String get done => 'ተከናውኗል';

  @override
  String get paymentScreenTitle => 'ክፍያዎን ያጠናቅቁ';

  @override
  String get paymentConfirmTitle => 'ክፍያዎን ያረጋግጡ';

  @override
  String paymentTotalAmount(Object amount) {
    return 'አጠቃላይ መጠን: ETB $amount';
  }

  @override
  String get paymentSelectGateway => 'የሚመርጡትን የክፍያ መግቢያ ይምረጡ ወይም የባንክ ደረሰኝ ይስቀሉ';

  @override
  String get paymentPreferredMethod => 'ተመራጭ ዘዴ';

  @override
  String get paymentOtherGateways => 'ሌሎች የክፍያ መግቢያዎች';

  @override
  String get paymentChooseGateway => 'የክፍያ መግቢያ ይምረጡ';

  @override
  String get paymentViewMoreOptions => 'ተጨማሪ አማራጮችን ይመልከቱ';

  @override
  String paymentPayWith(Object methodName) {
    return 'በ $methodName ይክፈሉ';
  }

  @override
  String get paymentSelectAGateway => 'የክፍያ መግቢያ ይምረጡ';

  @override
  String get paymentOr => 'ወይም';

  @override
  String get paymentUploadBankReceipt => 'የባንክ ደረሰኝ ይስቀሉ';

  @override
  String get paymentManualUploadTitle => 'የባንክ ደረሰኝ መስቀያ';

  @override
  String get paymentManualUploadSubtitle => 'የባንክ የግብይት ቁጥር ያስገቡ እና የደረሰኝዎን ፎቶ ይስቀሉ';

  @override
  String get paymentTxnReferenceLabel => 'የግብይት ቁጥር';

  @override
  String get paymentTxnReferenceRequired => 'ይህንን መሙላት ያስፈልጋል';

  @override
  String get paymentTapToSelectReceipt => 'ደረሰኝ ለመምረጥ ይጫኑ';

  @override
  String get paymentSubmitForReview => 'ለግምገማ አስገባ';

  @override
  String paymentErrorLoading(Object error) {
    return 'የክፍያ አማራጮችን መጫን አልተቻለም: $error';
  }

  @override
  String get paymentNoMethodsAvailable => 'ምንም የክፍያ አማራጮች የሉም';

  @override
  String get paymentSuccessDialogTitle => 'ማረጋገጫ ተልኳል!';

  @override
  String get paymentSuccessDialogContent => 'ወደ ስልክዎ ጥያቄ ተልኳል። እባክዎ ክፍያውን ለማጽደቅ ፒንዎን ያስገቡ።';

  @override
  String get paymentErrorDialogTitle => 'የክፍያ ስህተት';

  @override
  String get paymentManualSuccessTitle => 'በተሳካ ሁኔታ ተሰቅሏል';

  @override
  String get paymentManualSuccessContent => 'የክፍያ ማረጋገጫዎ ቀርቧል እና ግምገማ ላይ ነው።';

  @override
  String get paymentOkButton => 'እሺ';

  @override
  String paymentErrorSnackbar(Object message) {
    return 'ስህተት: $message';
  }

  @override
  String get contractsSectionTitle => 'የጉዞ ፕላን ይጠቀሙ';

  @override
  String get contractsSectionDescription => 'ለዚህ ጉዞ ልዩ ዋጋ ለማግኘት የቅድመ ክፍያ ሳምንታዊ ወይም ወርሃዊ ፕላን ይጠቀሙ።';

  @override
  String get tripDetails => 'Trip Details';

  @override
  String get confirmDropoff => 'Confirm Drop Off';

  @override
  String get enterCode => 'ኮዱን ያስገቡ';

  @override
  String otpScreenSubtitle(String phoneNumber) {
    return 'የማረጋገጫ ኮድ ወደ\n$phoneNumber ልከናል';
  }

  @override
  String get verifyButton => 'አረጋግጥ';

  @override
  String get didNotReceiveCodeResend => 'ኮድ አልደረሰዎትም? እንደገና ይላኩ';

  @override
  String resendCodeIn(int seconds) {
    return 'በ $seconds ሰከንድ ውስጥ እንደገና ይላኩ';
  }

  @override
  String get enterValidOtp => 'እባክዎ ትክክለኛ ባለ 6-አሃዝ ኮድ ያስገቡ።';

  @override
  String get resendingOtp => 'ኮዱን እንደገና በመላክ ላይ...';
}
