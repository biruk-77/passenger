// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Somali (`so`).
class AppLocalizationsSo extends AppLocalizations {
  AppLocalizationsSo([String locale = 'so']) : super(locale);

  @override
  String get pageHomeTitle => 'Bogga Hore';

  @override
  String get whereTo => 'Xaggee?';

  @override
  String get mapSetDestination => 'Taabo si aad u dejiso Meeshaad u Socoto';

  @override
  String get mapSetPickup => 'Taabo si aad u dejiso Goobta Lagaa Qaadayo';

  @override
  String get findingYourLocation => 'Goobtaada ayaa la raadinayaa...';

  @override
  String get cancel => 'Tirtir';

  @override
  String get chatWithDriver => 'La sheekayso Darawalka';

  @override
  String get noMessagesYet => 'Weli farriimo ma jiraan.';

  @override
  String get pageSettingsTitle => 'Dejinta';

  @override
  String get selectLanguage => 'Dooro Luuqada';

  @override
  String get loginWelcomeBack => 'Soo Dhawoow Mar Kale';

  @override
  String get loginWithPhoneSubtitle => 'Ku gal nambarkaaga taleefanka';

  @override
  String get loginWithEmailSubtitle => 'Ku gal iimaylkaaga';

  @override
  String get loginMethodPhone => 'Taleefan';

  @override
  String get loginMethodEmail => 'Iimayl';

  @override
  String get phoneNumber => 'Lambarka Telefoonka';

  @override
  String get email => 'Iimayl';

  @override
  String get password => 'Eraysir';

  @override
  String get errorEnterPhoneNumber => 'Fadlan geli nambarka taleefanka';

  @override
  String get errorInvalidPhoneNumber => 'Geli nambar sax ah oo 9 ama 10 ah';

  @override
  String get errorEnterEmail => 'Fadlan geli iimayl';

  @override
  String get errorInvalidEmail => 'Fadlan geli cinwaan email sax ah.';

  @override
  String get errorEnterPassword => 'Fadlan geli eraysirkaaga';

  @override
  String get sendOtpButton => 'DIR OTP';

  @override
  String get signInButton => 'GAL';

  @override
  String get dontHaveAccount => 'Akoon ma lihid? ';

  @override
  String get register => 'Isdiiwaangeli';

  @override
  String get drawerProfileSettings => 'Dejinta Barta';

  @override
  String get drawerPaymentMethod => 'Habka Lacag Bixinta';

  @override
  String get drawerRideHistory => 'Taariikhda Safarka';

  @override
  String get drawerSupport => 'Taageero';

  @override
  String get drawerSettings => 'Dejinta';

  @override
  String get drawerLogout => 'Ka Bax';

  @override
  String get drawerGuestUser => 'Isticmaale Marti ah';

  @override
  String get drawerWallet => 'Jeebka';

  @override
  String get drawerRating => 'Qiimeynta';

  @override
  String get drawerTrips => 'Safarada';

  @override
  String drawerWalletBalance(String balance) {
    return 'Birr $balance';
  }

  @override
  String appVersion(String versionNumber) {
    return 'Nooca $versionNumber';
  }

  @override
  String get settingsTitle => 'Dejinta';

  @override
  String get settingsSectionAccount => 'AKOONKA';

  @override
  String get settingsEditProfile => 'Wax Ka Beddel Barta';

  @override
  String get settingsEditProfileSubtitle => 'Maamul magacaaga, iimaylkaaga, iyo sawirkaaga';

  @override
  String get settingsSectionPreferences => 'DOOKHYADA';

  @override
  String get settingsLanguage => 'Luuqadda';

  @override
  String get settingsDarkMode => 'Hab Madoow';

  @override
  String get settingsSectionAbout => 'KU SAABSAN';

  @override
  String get settingsHelpSupport => 'Caawinta & Taageerada';

  @override
  String get settingsTermsOfService => 'Shuruudaha Adeegga';

  @override
  String get settingsPrivacyPolicy => 'Siyaasadda Asturnaanta';

  @override
  String get editProfileTitle => 'Tafatir Profile';

  @override
  String get personalInformation => 'Macluumaad Shakhsi';

  @override
  String get fullName => 'Magaca Buuxa';

  @override
  String get emailAddress => 'Cinwaanka Email‑ka';

  @override
  String get emergencyContacts => 'Xiriir Degdeg ah';

  @override
  String contactNumber(Object number) {
    return 'Xiriir #$number';
  }

  @override
  String get contactFullName => 'Magaca Buuxa ee Xiriirka';

  @override
  String get contactPhoneNumber => 'Lambarka Telefoonka ee Xiriirka';

  @override
  String get addContact => 'Kudar Xiriir';

  @override
  String get saveChanges => 'KEYDI ISBADALADA';

  @override
  String get security => 'Amniga';

  @override
  String get changePassword => 'Beddel Eraygasirta ah';

  @override
  String get currentPassword => 'Furaha Hadda Jira';

  @override
  String get newPassword => 'Furaha Cusub';

  @override
  String get confirmNewPassword => 'Xaqiiji Furaha Cusub';

  @override
  String get errorEnterName => 'Fadlan geli magacaaga.';

  @override
  String get errorEnterNameForContact => 'Geli magaca la xiriirka';

  @override
  String get errorEnterPhoneForContact => 'Geli taleefanka la xiriirka';

  @override
  String get errorInvalidPhone => 'Qaabka nambarka taleefanku waa khalad';

  @override
  String get errorEnterCurrentPassword => 'Fadlan geli furaha hadda jira si aad u dejiso mid cusub.';

  @override
  String get errorEnterNewPassword => 'Geli eraygasir cusub';

  @override
  String get errorPasswordTooShort => 'Furaha waa inuu ugu yaraan 6 xaraf noqdaa.';

  @override
  String get errorPasswordsDoNotMatch => 'Furayaasha iskuma ekaan.';

  @override
  String get profileUpdateSuccess => 'Profile‑ka si guul leh ayaa loo cusbooneysiiyay!';

  @override
  String get profileUpdateFailed => 'Cusboonaysiinta profile‑ka waa ku guul darreysatay.';

  @override
  String get passwordUpdateSuccess => 'Eraygasirta si guul leh ayaa loo beddelay!';

  @override
  String get passwordUpdateFailed => 'Beddelidda eraygasirtu way fashilantay.';

  @override
  String get authWelcome => 'Soo Dhawoow';

  @override
  String get authSignInToContinue => 'Soo gal akoonkaaga si aad u sii wadato';

  @override
  String get authCreateAccount => 'Samee Akoon';

  @override
  String get authGetStarted => 'Aan ku bilowno';

  @override
  String get authFullName => 'Magaca oo Dhamaystiran';

  @override
  String get authPhoneNumber => 'Lambarka Taleefanka';

  @override
  String get authPassword => 'Eraygasir';

  @override
  String get authSignIn => 'Soo Gal';

  @override
  String get authRegister => 'Samee Akoon';

  @override
  String get authNoAccount => 'Akoon ma lihid? ';

  @override
  String get authHaveAccount => 'Horey ma u lahayd akoon? ';

  @override
  String get authErrorEnterFullName => 'Fadlan geli magacaaga oo buuxa';

  @override
  String get authErrorEnterPhone => 'Fadlan geli nambarka taleefanka';

  @override
  String get authErrorInvalidPhone => 'Fadlan geli nambar taleefan oo sax ah';

  @override
  String get authErrorEnterPassword => 'Fadlan geli eraygasir';

  @override
  String get authErrorPasswordShort => 'Eraygasirtu waa inuu ahaadaa ugu yaraan 6 xaraf';

  @override
  String get authSwitchToRegister => 'Isdiiwaangeli';

  @override
  String get authSwitchToSignIn => 'Soo Gal';

  @override
  String get registerCreateAccount => 'Samee Akoon';

  @override
  String get registerGetStarted => 'Aan ku bilowno';

  @override
  String get registerFullName => 'Magaca oo Dhamaystiran';

  @override
  String get registerPhoneNumber => 'Lambarka Taleefanka';

  @override
  String get registerPassword => 'Eraygasir';

  @override
  String get registerButton => 'Samee Akoon';

  @override
  String get registerHaveAccount => 'Horey ma u lahayd akoon? ';

  @override
  String get registerSignIn => 'Soo Gal';

  @override
  String get registerErrorEnterFullName => 'Fadlan geli magacaaga oo buuxa';

  @override
  String get registerErrorEnterPhone => 'Fadlan geli nambarka taleefanka';

  @override
  String get registerErrorInvalidPhone => 'Fadlan geli nambar taleefan oo sax ah';

  @override
  String get registerErrorEnterPassword => 'Fadlan geli eraygasir';

  @override
  String get registerErrorPasswordShort => 'Eraygasirtu waa inuu ahaadaa ugu yaraan 6 xaraf';

  @override
  String get historyScreenTitle => 'Taariikhda Safarka';

  @override
  String get historyLoading => 'Waanu soo deynaynaa...';

  @override
  String get historyErrorTitle => 'Khalad ayaa dhacay';

  @override
  String get historyErrorMessage => 'Khalad lama filaan ah ayaa dhacay. Fadlan hubi xiriirkaaga internetka.';

  @override
  String get historyRetryButton => 'Isku day mar kale';

  @override
  String get historyEmptyTitle => 'Weli Safar Ma Jiro';

  @override
  String get historyEmptyMessage => 'Safarada aad dhammaysay halkan ayay ka muuqan doonaan.';

  @override
  String get historyCardFrom => 'Ka';

  @override
  String get historyCardTo => 'Ku';

  @override
  String get historyCardFare => 'Qiimaha:';

  @override
  String get historyCardUnknownLocation => 'Goob aan la aqoon';

  @override
  String get historyStatusCompleted => 'DHAMMAYSTIRAN';

  @override
  String get historyStatusCanceled => 'LAGA NOQDAY';

  @override
  String get historyStatusPending => 'SUGAYA';

  @override
  String get currencySymbol => 'Birr';

  @override
  String get discoveryWhereTo => 'Xaggee aadaynaa?';

  @override
  String get discoverySearchDestination => 'Raadi meeshaad u socoto';

  @override
  String get discoveryHome => 'Guri';

  @override
  String get discoveryWork => 'Shaqo';

  @override
  String get discoveryAddHome => 'Guri ku dar';

  @override
  String get discoveryAddWork => 'Shaqo ku dar';

  @override
  String get discoveryFavoritePlaces => 'Goobaha aad jeceshahay';

  @override
  String get discoveryAddFavoritePrompt => 'Taabo \'+\' si aad ugu darto meel aad jeceshahay.';

  @override
  String get discoveryRecentTrips => 'Safaradii u dambeeyay';

  @override
  String get discoveryRecentTripRemoved => 'Safarkii dhowaa waa la saaray.';

  @override
  String get discoveryClearAll => 'Wada tirtir';

  @override
  String get discoveryMenuChangeAddress => 'Beddel Ciwaanka';

  @override
  String get discoveryMenuRemove => 'Ka saar';

  @override
  String get searchingContactingDrivers => 'La xidhiidhida Darawallada u dhow';

  @override
  String get searchingPleaseWait => 'Fadlan sug inta aan kuu helayno gaadiid.';

  @override
  String get searchingDetailFrom => 'KA';

  @override
  String get searchingDetailTo => 'KU';

  @override
  String get searchingDetailVehicle => 'GAARI';

  @override
  String searchingDetailVehicleValue(Object name, Object price) {
    return '$name • Qiy. $price Birr';
  }

  @override
  String get searchingCancelButton => 'Baadhitaanka Jooji';

  @override
  String get planningPanelDistance => 'MASAAFO';

  @override
  String get planningPanelDuration => 'WAQTIGA';

  @override
  String get planningPanelConfirmButton => 'Xaqiiji';

  @override
  String get planningPanelNoRidesAvailable => 'Gaariba ma jiraan';

  @override
  String get planningPanelRideOptionsError => 'Lama soo rari karin doorashooyinka.';

  @override
  String planningPanelPrice(String price) {
    return 'Birr: $price';
  }

  @override
  String get planningPanelSelectRide => 'Dooro Gaari';

  @override
  String get planningPanelConfirmRide => 'Xaqiiji Safarka';

  @override
  String get registerErrorPhoneInvalid => 'Fadlan geli lambarka taleefanka saxda ah';

  @override
  String get optional => 'ikhtiyaari ah';

  @override
  String get registerConfirmPassword => 'Xaqiiji erayga sirta ah';

  @override
  String get registerErrorEnterConfirmPassword => 'Fadlan geli xaqiijinta erayga sirta ah';

  @override
  String get registerErrorPasswordMismatch => 'Erayada sirta ah isma waafaqaan';

  @override
  String get phone => 'Telefoon';

  @override
  String get registerGetOtp => 'HEL KOODKA OTP';

  @override
  String get registerErrorEnterEmail => 'Fadlan geli iimaylkaaga';

  @override
  String get registerErrorInvalidEmail => 'Fadlan geli ciwaan iimayl oo sax ah';

  @override
  String get driverOnWayEnRouteToDestination => 'Wuxuu ku sii jeedaa Goobta';

  @override
  String get driverOnWayDriverArriving => 'Darawalkaagu Wuu Soo Socdaa';

  @override
  String get driverOnWayBookingId => 'Aqoonsiga Booska:';

  @override
  String get driverOnWayDriverId => 'Aqoonsiga Darawalka:';

  @override
  String get driverOnWayPickup => 'Goobta lagaa qaadayo:';

  @override
  String get driverOnWayDropoff => 'Goobta aad ku degeyso:';

  @override
  String get driverOnWayCall => 'Wac';

  @override
  String get driverOnWayChat => 'Fariin';

  @override
  String get driverOnWayCancelRide => 'Jooji Safarka';

  @override
  String get driverOnWayDriverNotAvailable => 'Darawal L/H';

  @override
  String get driverOnWayNotAvailable => 'L/H';

  @override
  String get driverOnWayColorNotAvailable => 'Midab L/H';

  @override
  String get driverOnWayModelNotAvailable => 'Model L/H';

  @override
  String get driverOnWayPlateNotAvailable => 'TAARIKO L/H';

  @override
  String get driverOnWayVehicleUnknown => 'Lama Yaqaan';

  @override
  String get ongoingTripEnjoyRide => 'Ku raaxayso safarkaaga!';

  @override
  String get ongoingTripOnYourWay => 'Waxa aad ku sii jeeddaa meeshaad u socotay.';

  @override
  String get ongoingTripDriverOnWay => 'Darawalku wuu soo socdaa';

  @override
  String ongoingTripDriverArrivingIn(String eta) {
    return 'Darawalkaagu wuxuu imaan doonaa qiyaastii $eta';
  }

  @override
  String get ongoingTripYourDriver => 'Darawalkaaga';

  @override
  String get ongoingTripStandardCar => 'Gaari Caadi ah';

  @override
  String get ongoingTripPlatePlaceholder => '...';

  @override
  String get ongoingTripDefaultColor => 'Madow';

  @override
  String get ongoingTripCall => 'Wac';

  @override
  String get ongoingTripChat => 'Sheekayso';

  @override
  String get ongoingTripCancel => 'Jooji';

  @override
  String get postTripCompleted => 'Safarkii Wuu Dhamaaday!';

  @override
  String get postTripYourDriver => 'Darawalkaaga';

  @override
  String get postTripRateExperience => 'Qiimee waayo-aragnimadaada';

  @override
  String get postTripAddComment => 'Ku dar faallo faahfaahsan (ikhtiyaari)';

  @override
  String get postTripSubmitFeedback => 'Gudbi Ra\'yiga';

  @override
  String get postTripSkip => 'Ka bood';

  @override
  String get postTripShowAppreciation => 'Muuji mahadnaqaaga?';

  @override
  String get postTripOther => 'Kale';

  @override
  String get postTripFinalFare => 'Qiimaha Ugu Dambeeya';

  @override
  String get postTripDistance => 'Masaafada';

  @override
  String get postTripTagExcellentService => 'Adeeg Wacan';

  @override
  String get postTripTagCleanCar => 'Gaari Nadiif ah';

  @override
  String get postTripTagSafeDriver => 'Darawal Ammaan ah';

  @override
  String get postTripTagGoodConversation => 'Sheeko Wacan';

  @override
  String get postTripTagFriendlyAttitude => 'Dabeecad Wanaagsan';

  @override
  String get driverInfoWindowVehicleStandard => 'Caadi ah';

  @override
  String get driverInfoWindowAvailable => 'Diyaar ah';

  @override
  String get driverInfoWindowOnTrip => 'Safar ku jira';

  @override
  String get driverInfoWindowSelect => 'Dooro';

  @override
  String get notificationRideConfirmedTitle => 'Safarkaagii Waa La Xaqiijiyay!';

  @override
  String notificationRideConfirmedBody(String driverName) {
    return 'Darawal $driverName wuu soo socdaa.';
  }

  @override
  String get notificationDriverArrivedTitle => 'Darawalkaagii Wuu Yimid!';

  @override
  String get notificationDriverArrivedBody => 'Fadlan darawalkaaga kula kulan goobta lagaa qaadayo.';

  @override
  String get notificationTripStartedTitle => 'Safarkaagii Wuu Bilaabmay';

  @override
  String get notificationTripStartedBody => 'Ku raaxayso safarkaaga! Waxaan kuu rajaynaynaa safar nabdoon.';

  @override
  String get notificationTripCompletedTitle => 'Safarkii Wuu Dhamaaday!';

  @override
  String get notificationTripCompletedBody => 'Thank you for riding with us. We hope to see you again soon.';

  @override
  String get notificationRideCanceledTitle => 'Safarkii Waa la Joojiyay';

  @override
  String get notificationRideCanceledBody => 'Codsigaagii safarka waa la joojiyay.';

  @override
  String get notificationRequestSentTitle => 'Codsiga Safarka Waa La Diray';

  @override
  String get notificationRequestSentBody => 'Waan helnay codsigaaga, haddana waxaan raadineynaa darawallo kuu dhow.';

  @override
  String notificationNewMessageTitle(String driverName) {
    return 'Farriin Cusub oo ka timid $driverName';
  }

  @override
  String get notificationNoDriversTitle => 'Darawallo Lama Helin';

  @override
  String get notificationNoDriversBody => 'Waanu weynay darawal agagaarka jooga. Fadlan xoogaa ka dib mar kale isku day.';

  @override
  String get notificationBookingErrorTitle => 'Cillad Dalabka';

  @override
  String get arrived => 'Soo Gaadhay';

  @override
  String get editProfileSubtitle => 'Xaqiiji in macluumaadkaaga gaarka ah uu casri yahay.';

  @override
  String notificationSearchingBody(String radius) {
    return 'Waxaan ka dhex raadineynaa darawallada raadiyaha ah $radius km.';
  }

  @override
  String get notificationDriverNearbyTitle => 'Darawalku Waa Dhow Yahay';

  @override
  String notificationDriverNearbyBody(String distance) {
    return 'Darawalkaagu hadda waxa uu u jiraa wax ka yar $distance mitir.';
  }

  @override
  String get notificationDriverVeryCloseTitle => 'Darawalku Aad ayuu u Dhow Yahay';

  @override
  String get notificationDriverVeryCloseBody => 'Is diyaari! Darawalkaagu waa ku soo dhow yahay.';

  @override
  String get offlineOrderTitle => 'Dalabka Khadka Ka Baxsan';

  @override
  String get offlineRequestTitle => 'Ku Dalbo Rakaab SMS ahaan';

  @override
  String get offlineRequestSubtitle => 'Interneed malihid? Dhib malahan Geli meelahaaga hoose waxaanan dib kuugu soo wici doonaa si aan u xaqiijino dalabkaaga.';

  @override
  String get pickupLocationHint => 'Geli Goobta Lagaa Qaadayo';

  @override
  String get destinationLocationHint => 'Geli Meesha Loo Socdo';

  @override
  String get pickupValidationError => 'Fadlan geli goobta lagaa qaadayo';

  @override
  String get destinationValidationError => 'Fadlan geli meesha loo socdo';

  @override
  String get prepareSmsButton => 'Diyaari Codsiga SMS';

  @override
  String get smsCouldNotOpenError => 'Lama furi karin barnaamijkaaga SMS-ka.';

  @override
  String get smsGenericError => 'Cilad ayaa timid markii la abuurayay SMS-ka.';

  @override
  String get step1Title => 'Geli Goobaha';

  @override
  String get step1Subtitle => 'Noo sheeg meesha aan kaa soo qaadno iyo meesha aad u socoto.';

  @override
  String get step2Title => 'Diyaari SMS';

  @override
  String get step2Subtitle => 'Waxaanu abuuri doonaa fariin qoraal ah oo faahfaahintaada wadata.';

  @override
  String get step3Title => 'Sug Wicitaankayaga';

  @override
  String get step3Subtitle => 'Kooxdayadu waxay kugula soo xiriiri doontaa goor dhow si loo xaqiijiyo safarkaaga.';

  @override
  String get smsOfflineLogin => 'Interneed malihid? Ku dalbo SMS';

  @override
  String get smsLaunchSuccessTitle => 'Appka SMS waa la furay';

  @override
  String get smsLaunchSuccessMessage => 'Fadlan dib u eeg fariinta oo riix \'Dir\' si aad u gudbiso codsigaaga.';

  @override
  String get smsCapabilityError => 'Qalabkani ma awoodo inuu diro fariimaha SMS.';

  @override
  String get smsLaunchError => 'Lama furi karin barnaamijka SMS-ka. Fadlan hubi dejinta qalabkaaga.';

  @override
  String get offline => 'Fariin Offline';

  @override
  String get skip => 'Ka Boos';

  @override
  String get finish => 'DHAMEE';

  @override
  String get completeProfileTitle => 'Tallaabada Ugu Dambeysa';

  @override
  String get completeProfileSubtitle => 'Buuxi profile‑kaaga si aad u sii wadato.';

  @override
  String get mySubscriptionsTitle => 'Rukunimadayda';

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
  String get contractDetails => 'Faahfaahinta Heshiiska';

  @override
  String get status => 'Xaalad';

  @override
  String get duration => 'Duration';

  @override
  String get cost => 'Cost';

  @override
  String get routeInformation => 'Macluumaadka Jidka';

  @override
  String get pickup => 'Goobta Lagaa Qaadayo';

  @override
  String get dropoff => 'Goobta Lagu Degayo';

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
  String get saveLocationAs => 'MEESHAN U KAYDI SIDA';

  @override
  String get home => 'Guri';

  @override
  String get work => 'Shaqo';

  @override
  String get favorite => 'Jecel';

  @override
  String get goToDestination => 'TAG HALKAAD U SOCOTO';

  @override
  String get saveAsHome => 'U KAYDI SIDA GURI';

  @override
  String get saveAsWork => 'U KAYDI SIDA SHAQO';

  @override
  String get addToFavorites => 'KU DAR KUWA LA JECEL YAHAY';

  @override
  String get confirmLocation => 'XAQIIJI GOOBTA';

  @override
  String get currentLocation => 'Goobta Hadda';

  @override
  String get selectedLocation => 'Goobta La Doortay';

  @override
  String get locationNotAvailable => 'Goobta hadda lama hayo. Fadlan hubi ogolaanshaha.';

  @override
  String get selectPickupAndDestination => 'Dooro meesha aad ka raacayso iyo meesha aad ku degayso.';

  @override
  String get clearRecentPlacesQuestion => 'Tirtir goobihii dhowaa?';

  @override
  String get actionCannotBeUndone => 'Talaabadan dib looma celin karo.';

  @override
  String get clear => 'Nadiifi';

  @override
  String get setRoute => 'Dejinta Waddada';

  @override
  String get selectLocation => 'Dooro Goob';

  @override
  String get pickupLocation => 'Goobta Lagaa Qaadayo';

  @override
  String get destination => 'Meesha Aad Ku Socoto';

  @override
  String get setOnMap => 'Ku Deji Khariidadda';

  @override
  String get current => 'Hadda';

  @override
  String get savedPlaces => 'Goobaha La Keydiyay';

  @override
  String get recent => 'Kuwii Dhowaa';

  @override
  String get addHome => 'Ku Dar Guriga';

  @override
  String get addWork => 'Ku Dar Shaqada';

  @override
  String get setPickup => 'Ka Dhig Goob Raac';

  @override
  String get setDestination => 'Ka Dhig Meel Degmo';

  @override
  String get confirmPickup => 'Qaado Xaqiiji';

  @override
  String get confirmDestination => 'Goobta Loo Socdo Xaqiiji';

  @override
  String get discoverySetHome => 'Guri Dhig';

  @override
  String get discoverySetWork => 'Shaqo Dhig';

  @override
  String get discoveryAddFavorite => 'Kudar Jecel';

  @override
  String get setAsPickupLocation => 'Goob Qaadasho Dhig';

  @override
  String get setAsDestination => 'Goob Loo Socdo Dhig';

  @override
  String get updateRoute => 'Jidka Cusbooneysii';

  @override
  String get setPickupFirst => 'Qaado Marka Hore';

  @override
  String get saveHome => 'Guri Kaydi';

  @override
  String get saveWork => 'Shaqo Kaydi';

  @override
  String get addFavorite => 'Ku dar kuwa la jecel yahay';

  @override
  String get setYourRoute => 'Jidkaaga Deji';

  @override
  String get whereWouldYouLikeToGo => 'Xagee jeclaan lahayd inaad aado?';

  @override
  String get changeAddress => 'Beddel Cinwaanka';

  @override
  String get remove => 'Ka saar';

  @override
  String itemRemovedSuccessfully(String itemType) {
    return '$itemType si guul leh ayaa looga saaray';
  }

  @override
  String get homeAddress => 'Cinwaanka Guriga';

  @override
  String get workAddress => 'Cinwaanka Shaqada';

  @override
  String get favoritePlace => 'Goobta la Jecel yahay';

  @override
  String get placeOptions => 'Kala Doorashada Goobta';

  @override
  String get clearAllDataTitle => 'Dhammaan Xogta la Tirtiro?';

  @override
  String get clearAllDataContent => 'Tani waxay meesha ka saari doontaa dhammaan gurigaaga, shaqadaada, meelaha aad jeceshahay, iyo meelihii dhowaa. Tallaabadan lama celin karo.';

  @override
  String get clearEverything => 'Tirtir Wax Walba';

  @override
  String get allDataCleared => 'Dhammaan xogta si guul leh ayaa loo nadiifiyey';

  @override
  String get searchErrorTitle => 'Raadinta Waa Fashilantay';

  @override
  String get searchErrorMessage => 'Fadlan hubi xiriirkaaga internetka oo mar kale isku day.';

  @override
  String get noResultsFound => 'Wax Natiijo Ah Lama Helin';

  @override
  String get tryDifferentSearch => 'Isku day eray raadin kale';

  @override
  String get pickOnMap => 'Ka Dooro Khariidada';

  @override
  String get clearAll => 'Tirtir Dhammaan';

  @override
  String get add => 'Ku dar';

  @override
  String get addYourHomeAddress => 'Geli cinwaanka gurigaaga';

  @override
  String get addYourWorkAddress => 'Geli cinwaanka shaqadaada';

  @override
  String get favorites => 'Kuwa la Jecel yahay';

  @override
  String get recentTrips => 'Safaradii Dhowaa';

  @override
  String get noFavoritesYet => 'Weli ma jiraan wax la jecel yahay';

  @override
  String get addFavoritesMessage => 'Ku dar meelaha aad inta badan booqato si aad dhaqso ugu gasho.';

  @override
  String get noRecentTrips => 'Ma jiraan safaro dhowaan';

  @override
  String get recentTripsMessage => 'Meelahaagii ugu dambeeyay halkan ayay ka soo muuqan doonaan.';

  @override
  String recentTripsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count safaro dhowaan',
      one: '1 safar dhowaan',
      zero: 'Ma jiraan safaro dhowaan',
    );
    return '$_temp0';
  }

  @override
  String get recentsCleared => 'Safaradii dhowaa waa la nadiifiyey';

  @override
  String get recentTripRemoved => 'Safarkii dhowaa waa la saaray';

  @override
  String get searching => 'Raadinayaa...';

  @override
  String get yourCurrentPosition => 'Goobtaada Hadda';

  @override
  String get useCurrentLocation => 'Isticmaal Goobta Hadda';

  @override
  String get planYourRoute => 'Qorshee Jidkaaga';

  @override
  String get planningPanelVehicleSelection => 'DOORASHADA GAARIGA';

  @override
  String get planningPanelEngageButton => 'BILOW';

  @override
  String get planningPanelTitle => 'Dooro Safarkaaga';

  @override
  String get noRidesAvailable => 'Gaadiid lagama heli karo aaggan.';

  @override
  String get vehicleTaglineStandard => 'Xulashada maalinlaha ah ee ugu fiican.';

  @override
  String get vehicleTaglineComfort => 'Raaxo dheeri ah oo safar degan.';

  @override
  String get vehicleTaglineVan => 'Qol ku filan qof walba.';

  @override
  String get vehicleTaglineDefault => 'Doorasho weyn oo safarkaaga ah.';

  @override
  String get fareCalculating => 'Qiimaha waa la xisaabinayaa...';

  @override
  String get ride => 'SAFAR';

  @override
  String get confirmButtonRequesting => 'CODSI SOCODA...';

  @override
  String get confirmButtonRequest => 'CODSO';

  @override
  String get postTripAddCompliment => 'Kudar ammaan';

  @override
  String get driverOnWayEnjoyYourRide => 'Ku raaxayso safarkaaga!';

  @override
  String get driverOnWayMeetAtPickup => 'Fadlan kula kulan goobta lagaa qaadayo.';

  @override
  String get ongoingTripTitle => 'Safar ku jira';

  @override
  String get tripDuration => 'Muddada Safarka';

  @override
  String get safetyAndTools => 'Badbaadada & Qalabka';

  @override
  String get shareTrip => 'La Wadaag Safarka';

  @override
  String get emergencySOS => 'Gurmad Degdeg ah';

  @override
  String get emergencyDialogTitle => 'Caawinta Degdegga ah';

  @override
  String get emergencyDialogContent => 'Tani waxay la xiriiri doontaa adeegyada gurmadka degdegga ah ee deegaanka. Ma hubtaa inaad sii wadato?';

  @override
  String get emergencyDialogCancel => 'Iska daa';

  @override
  String get emergencyDialogConfirm => 'Hadda Wac';

  @override
  String get phoneNumberNotAvailable => 'Lambarka taleefanka darawalka lama heli karo.';

  @override
  String couldNotLaunch(Object url) {
    return 'Lama furi karin $url';
  }

  @override
  String get discount => 'Qiimo Dhimis';

  @override
  String get myTripsScreenTitle => 'My Contract Trips';

  @override
  String get myTripsScreenRefresh => 'Refresh';

  @override
  String myTripsScreenErrorPrefix(String errorMessage) {
    return 'Error: $errorMessage';
  }

  @override
  String get myTripsScreenRetry => 'Retry';

  @override
  String get myTripsScreenNoTrips => 'No contract trips found.';

  @override
  String get myTripsScreenTripIdPrefix => 'Trip ID: ';

  @override
  String get myTripsScreenFromPrefix => 'From: ';

  @override
  String get myTripsScreenToPrefix => 'To: ';

  @override
  String get myTripsScreenPickupPrefix => 'Pickup: ';

  @override
  String get myTripsScreenDropoffPrefix => 'Dropoff: ';

  @override
  String get myTripsScreenFarePrefix => 'Fare: ETB ';

  @override
  String get myTripsScreenRatingPrefix => 'Rating: ';

  @override
  String get myTripsScreenNotAvailable => 'N/A';

  @override
  String get tripStatusCompleted => 'COMPLETED';

  @override
  String get tripStatusStarted => 'STARTED';

  @override
  String get tripStatusPending => 'PENDING';

  @override
  String get tripStatusCancelled => 'CANCELLED';

  @override
  String get drawerMyTrips => 'Safaradayda';

  @override
  String get drawerAvailableContracts => 'Heshiisyo la heli karo';

  @override
  String get drawerMyTransactions => 'Xawilaadahayga';

  @override
  String get drawerLogoutForgetDevice => 'Ka bax oo Qalabka iska Ilow';

  @override
  String get contractPanelTitle => 'Safarada Qandaraaska';

  @override
  String get contractPanelSubtitle => 'Waayo-aragnimadaada safarka ee heerka sare ah';

  @override
  String get contractPanelActiveSubscriptionsTitle => 'Rukun-nimooyinka Firfircoon';

  @override
  String get contractPanelActiveSubscriptionsSubtitle => 'Safaradaada gaarka ah ee hadda';

  @override
  String get contractPanelErrorLoadSubscriptions => 'Lama soo rari karin rukun-nimooyinkaaga';

  @override
  String get contractPanelEmptySubscriptions => 'Lama helin rukun-nimo firfircoon';

  @override
  String get contractPanelEmptySubscriptionsSubtitle => 'Hoos ka samee safarkaaga gaarka ah ee ugu horreeya';

  @override
  String get contractPanelNewContractsTitle => 'Heshiisyo Cusub';

  @override
  String get contractPanelNewContractsSubtitle => 'Horumari waayo-aragnimadaada safarka';

  @override
  String get contractPanelErrorLoadContracts => 'Lama soo rari karin noocyada heshiisyada';

  @override
  String get contractPanelEmptyContracts => 'Ma jiraan heshiisyo la heli karo';

  @override
  String get contractPanelEmptyContractsSubtitle => 'Dib u soo hubi hadhow si aad u hesho dalabyo cusub';

  @override
  String get contractPanelRetryButton => 'Isku day Mar kale';

  @override
  String contractPanelDiscountOff(String discountValue) {
    return '$discountValue% QIIMO DHIMIS';
  }

  @override
  String get contractPickerTitlePickup => 'Dooro Goobta Lagaa Qaadayo';

  @override
  String get contractPickerTitleDestination => 'Dooro Goobta Loo Socdo';

  @override
  String get contractPickerHintPickup => 'Raadi goobta lagaa qaadayo...';

  @override
  String get contractPickerHintDestination => 'Raadi goobta loo socdo...';

  @override
  String get contractPickerNoRecents => 'Ma jiro baaritaano dhowaan la sameeyay.';

  @override
  String get contractPickerRecentsTitle => 'Baaritaanadii Ugu Dambeeyay';

  @override
  String get contractPickerNoResults => 'Natiijo Lama Helin.';

  @override
  String get contractDriverLoading => 'Raadinta darawalkaaga heshiiska...';

  @override
  String get contractDriverTypeLabel => 'Darawalka Heshiiska';

  @override
  String get contractDetailsTitle => 'Faahfaahinta Heshiiska';

  @override
  String get contractDetailsSubscriptionId => 'Aqoonsiga Rukunka';

  @override
  String get contractDetailsContractType => 'Nooca Heshiiska';

  @override
  String get contractDetailsScheduledRide => 'Safar la Qorsheeyay';

  @override
  String get contractDetailsTimeRemaining => 'Waqtiga Harsan';

  @override
  String get contractExpired => 'Heshiisku Wuu Dhacay';

  @override
  String contractTimeLeftDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count maalmood ayaa harsan',
      one: '$count maalin ayaa hartay',
    );
    return '$_temp0';
  }

  @override
  String contractTimeLeftHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saacadood ayaa harsan',
      one: '$count saac ayaa hartay',
    );
    return '$_temp0';
  }

  @override
  String contractTimeLeftMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count daqiiqadood ayaa harsan',
      one: '$count daqiiqo ayaa hartay',
    );
    return '$_temp0';
  }

  @override
  String get confirmRideTitle => 'Xaqiiji Safarkaaga';

  @override
  String bookingUnderContract(Object contractType) {
    return 'Waxaad ku dalbanaysaa heshiiska: $contractType';
  }

  @override
  String get tripSummaryTitle => 'SOO KOOBIDDA SAFARKA';

  @override
  String get assignedDriver => 'Darawalka Loo Xilsaaray';

  @override
  String get driverContact => 'Telefoonka Darawalka';

  @override
  String get vehicle => 'Gaadhi';

  @override
  String get plateNumber => 'Lambarka Taarikada';

  @override
  String get contractPrice => 'Qiimaha Heshiiska';

  @override
  String get tripDistance => 'Masaafada Safarka';

  @override
  String get paymentStatus => 'Xaaladda Bixinta';

  @override
  String get subscriptionStatus => 'Xaaladda Rukunka';

  @override
  String get validity => 'Muddada uu Shaqaynayo';

  @override
  String get driverPending => 'Darawal ayaa la sugayaa';

  @override
  String get negotiated => 'Waa lagu heshiiyey';

  @override
  String get confirmTodaysPickup => 'Xaqiiji Safarka Maanta';

  @override
  String get exploreContracts => 'Baadh Heshiisyada';

  @override
  String get refresh => 'Dib u Cusboonaysii';

  @override
  String get retry => 'Isku day mar kale';

  @override
  String get rideSubscriptionFallbackTitle => 'Rukun Safar';

  @override
  String get basePrice => 'Qiimaha Salka';

  @override
  String get minimumFare => 'Lacagta Ugu Yar';

  @override
  String get maxPassengers => 'Tirada Rakaabka Ugu Badan';

  @override
  String get featureWifi => 'WiFi';

  @override
  String get featureAC => 'Qaboojiye';

  @override
  String get featurePremiumSeats => 'Kuraas Tayo Sare Leh';

  @override
  String get featurePrioritySupport => 'Taageero Degdeg Ah';

  @override
  String get availableContractsTitle => 'Heshiisyada La Heli Karo';

  @override
  String get noContractsAvailableTitle => 'Ma Jiro Heshiis La Heli Karo';

  @override
  String get noContractsAvailableMessage => 'Fadlan dib ugu soo noqo si aad u hesho dalabyo cusub oo rukunimo.';

  @override
  String get failedToLoadContractsTitle => 'Lagu Guul Daraystay Soo Dejinta Heshiisyada';

  @override
  String get failedToLoadContractsMessage => 'Fadlan hubi xiriirkaaga internetka oo isku day mar kale.';

  @override
  String get baseRate => 'Qiimaha Salka';

  @override
  String get selectAndPickRoute => 'Dooro & Dooro Waddo';

  @override
  String get myTransactions => 'Dhaqdhaqaaqyadayda';

  @override
  String get errorPrefix => 'Cilad';

  @override
  String get currentWalletBalance => 'Hadhaaga Jeebka Hadda';

  @override
  String get transactionHistory => 'Taariikhda Dhaqdhaqaaqa';

  @override
  String get noTransactionsYet => 'Weli wax dhaqdhaqaaq ah ma jiro';

  @override
  String get yourRecentTransactionsWillAppearHere => 'Dhaqdhaqaaqyadaadii u dambeeyay halkan ayay ka soo muuqan doonaan.';

  @override
  String get transactionStatusCompleted => 'DHAMMAYSTIRAN';

  @override
  String get transactionStatusPending => 'LA SUGAYO';

  @override
  String get transactionStatusFailed => 'GUULDARRAYSTAY';

  @override
  String get subscriptionDetails => 'Faahfaahinta Rukunka';

  @override
  String get payment => 'Lacag Bixinta';

  @override
  String get distance => 'Masaafo';

  @override
  String get financials => 'Maaliyadda';

  @override
  String get baseFare => 'Qiimaha Aasaasiga ah';

  @override
  String get finalFare => 'Qiimaha Ugu Dambeeya';

  @override
  String get name => 'Magac';

  @override
  String get passengerDetails => 'Faahfaahinta Rakaabka';

  @override
  String get identifiers => 'Aqoonsiyada';

  @override
  String get subscriptionId => 'Aqoonsiga Rukunka';

  @override
  String get contractId => 'Aqoonsiga Heshiiska';

  @override
  String get passengerId => 'Aqoonsiga Rakaabka';

  @override
  String get driverId => 'Aqoonsiga Darawalka';

  @override
  String get notAssigned => 'Lama Meelayn';

  @override
  String get callDriver => 'Wac Darawalka';

  @override
  String get daysLeft => 'Maalmaha Hadhay';

  @override
  String get expiresToday => 'Maanta ayuu Dhacayaa';

  @override
  String get statusExpired => 'Wuu Dhacay';

  @override
  String daysLeftSingular(int count) {
    return '$count maalin ayaa hadhay';
  }

  @override
  String daysLeftPlural(int count) {
    return '$count maalmood ayaa hadhay';
  }

  @override
  String get newSubscriptionRequest => 'New Subscription Request';

  @override
  String subscribingTo(String contractType) {
    return 'Subscribing to: $contractType';
  }

  @override
  String get reviewRequestPrompt => 'Fadlan xaqiiji jidkaaga oo dooro muddada aad rabto in rukankaagu socdo.';

  @override
  String get yourRoute => 'Jidkaaga';

  @override
  String get dropoffLocation => 'Goobta Lagu Degayo';

  @override
  String get subscriptionDuration => 'Muddada Rukunka';

  @override
  String get selectDateRange => 'Taabo si aad u doorato taariikhda';

  @override
  String get pleaseSelectDateRange => 'Fadlan dooro taariikhda bilowga iyo dhamaadka.';

  @override
  String get proceedToPayment => 'U gudub Bixinta';

  @override
  String get requestSubmitted => 'Codsiga waa la Gudbiyay!';

  @override
  String get approvalNotificationPrompt => 'Codsigaaga rukunnimada waxaa loo diray ansixinta maamulka. Waa lagu soo ogeysiin doonaa marka la hawlgeliyo.';

  @override
  String get done => 'La Qabtay';

  @override
  String get paymentScreenTitle => 'Dhameystir Bixintaada';

  @override
  String get paymentConfirmTitle => 'Xaqiiji Bixintaada';

  @override
  String paymentTotalAmount(Object amount) {
    return 'Wadarta Guud: ETB $amount';
  }

  @override
  String get paymentSelectGateway => 'Dooro habka lacag bixinta aad doorbidayso ama soo geli rasiidhka bangiga';

  @override
  String get paymentPreferredMethod => 'HABKA LA DOORBIDAY';

  @override
  String get paymentOtherGateways => 'HABABKA KALE EE BIXINTA';

  @override
  String get paymentChooseGateway => 'DOORO HABKA BIXINTA';

  @override
  String get paymentViewMoreOptions => 'Eeg Ikhtiyaaro Dheeraad ah';

  @override
  String paymentPayWith(Object methodName) {
    return 'Ku bixi $methodName';
  }

  @override
  String get paymentSelectAGateway => 'Dooro Habka Bixinta';

  @override
  String get paymentOr => 'AMA';

  @override
  String get paymentUploadBankReceipt => 'Soo Geli Rasiidhka Bangiga';

  @override
  String get paymentManualUploadTitle => 'Soo Gelinta Rasiidhka';

  @override
  String get paymentManualUploadSubtitle => 'Geli tixraaca macaamilka bangiga oo soo geli sawirka rasiidhkaaga';

  @override
  String get paymentTxnReferenceLabel => 'Tixraaca Macaamilka';

  @override
  String get paymentTxnReferenceRequired => 'Goobtan waa qasab';

  @override
  String get paymentTapToSelectReceipt => 'Taabo si aad u doorato rasiidhka';

  @override
  String get paymentSubmitForReview => 'U Gudbi Dib u Eegis';

  @override
  String paymentErrorLoading(Object error) {
    return 'Cilad ku timid soo dejinta hababka lacag bixinta: $error';
  }

  @override
  String get paymentNoMethodsAvailable => 'Ma jiraan habab lacag bixineed oo diyaar ah';

  @override
  String get paymentSuccessDialogTitle => 'Xaqiijin La Diray!';

  @override
  String get paymentSuccessDialogContent => 'Codsiga waxaa loo diray taleefankaaga. Fadlan geli PIN-kaaga si aad u ansixiso bixinta.';

  @override
  String get paymentErrorDialogTitle => 'Cilad Bixineed';

  @override
  String get paymentManualSuccessTitle => 'Si Guul ah Loo Soo Geliyey';

  @override
  String get paymentManualSuccessContent => 'Caddaynta lacag bixintaada waa la gudbiyey waxaana lagu hayaa dib u eegis.';

  @override
  String get paymentOkButton => 'OK';

  @override
  String paymentErrorSnackbar(Object message) {
    return 'Cilad: $message';
  }

  @override
  String get contractsSectionTitle => 'Codso Qorshe Safar';

  @override
  String get contractsSectionDescription => 'Isticmaal qorshe todobaadle ah ama bille ah oo horay loo bixiyay si aad u hesho qiimayaal gaar ah safarkan.';

  @override
  String get tripDetails => 'Faahfaahinta Safarka';

  @override
  String get confirmDropoff => 'Xaqiiji Gaaritaanka';

  @override
  String get enterCode => 'Geli Koodka';

  @override
  String otpScreenSubtitle(String phoneNumber) {
    return 'Waxaan koodka xaqiijinta u dirnay\n$phoneNumber';
  }

  @override
  String get verifyButton => 'XAQIIJI';

  @override
  String get didNotReceiveCodeResend => 'Kood ma helin? Dib u dir';

  @override
  String resendCodeIn(int seconds) {
    return 'Dib u dir koodka $seconds ilbiriqsi gudahood';
  }

  @override
  String get enterValidOtp => 'Fadlan geli kood lix-god ah oo sax ah.';

  @override
  String get resendingOtp => 'Koodka dib baa loo dirayaa...';
}
