// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get pageHomeTitle => 'Home';

  @override
  String get whereTo => 'Where to?';

  @override
  String get mapSetDestination => 'Tap to set your Destination';

  @override
  String get mapSetPickup => 'Tap to set your Pickup';

  @override
  String get findingYourLocation => 'Finding your location...';

  @override
  String get cancel => 'Cancel';

  @override
  String get chatWithDriver => 'Chat with Driver';

  @override
  String get noMessagesYet => 'No messages yet.';

  @override
  String get pageSettingsTitle => 'Settings';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get loginWelcomeBack => 'Welcome Back';

  @override
  String get loginWithPhoneSubtitle => 'Sign in with your phone number';

  @override
  String get loginWithEmailSubtitle => 'Sign in with your email';

  @override
  String get loginMethodPhone => 'Phone';

  @override
  String get loginMethodEmail => 'Email';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get errorEnterPhoneNumber => 'Please enter a phone number';

  @override
  String get errorInvalidPhoneNumber => 'Enter a valid 9 or 10-digit number';

  @override
  String get errorEnterEmail => 'Please enter an email';

  @override
  String get errorInvalidEmail => 'Please enter a valid email.';

  @override
  String get errorEnterPassword => 'Please enter your password';

  @override
  String get sendOtpButton => 'SEND OTP';

  @override
  String get signInButton => 'SIGN IN';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get register => 'Register';

  @override
  String get drawerProfileSettings => 'Profile Settings';

  @override
  String get drawerPaymentMethod => 'Payment Method';

  @override
  String get drawerRideHistory => 'Ride History';

  @override
  String get drawerSupport => 'Support';

  @override
  String get drawerSettings => 'Settings';

  @override
  String get drawerLogout => 'Logout';

  @override
  String get drawerGuestUser => 'Guest User';

  @override
  String get drawerWallet => 'Wallet';

  @override
  String get drawerRating => 'Rating';

  @override
  String get drawerTrips => 'Trips';

  @override
  String drawerWalletBalance(String balance) {
    return 'Birr $balance';
  }

  @override
  String appVersion(String versionNumber) {
    return 'Version $versionNumber';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionAccount => 'ACCOUNT';

  @override
  String get settingsEditProfile => 'Edit Profile';

  @override
  String get settingsEditProfileSubtitle => 'Manage your name, email, and photo';

  @override
  String get settingsSectionPreferences => 'PREFERENCES';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsSectionAbout => 'ABOUT';

  @override
  String get settingsHelpSupport => 'Help & Support';

  @override
  String get settingsTermsOfService => 'Terms of Service';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get fullName => 'Full Name';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get emergencyContacts => 'Emergency Contacts';

  @override
  String contactNumber(Object number) {
    return 'Contact #$number';
  }

  @override
  String get contactFullName => 'Contact\'s Full Name';

  @override
  String get contactPhoneNumber => 'Contact\'s Phone Number';

  @override
  String get addContact => 'Add Contact';

  @override
  String get saveChanges => 'SAVE CHANGES';

  @override
  String get security => 'Security';

  @override
  String get changePassword => 'Change Password';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get errorEnterName => 'Please enter your name.';

  @override
  String get errorEnterNameForContact => 'Enter name for contact';

  @override
  String get errorEnterPhoneForContact => 'Enter phone for contact';

  @override
  String get errorInvalidPhone => 'Invalid phone number format';

  @override
  String get errorEnterCurrentPassword => 'Please enter your current password to set a new one.';

  @override
  String get errorEnterNewPassword => 'Enter a new password';

  @override
  String get errorPasswordTooShort => 'Password must be at least 6 characters.';

  @override
  String get errorPasswordsDoNotMatch => 'Passwords do not match.';

  @override
  String get profileUpdateSuccess => 'Profile updated successfully!';

  @override
  String get profileUpdateFailed => 'Profile update failed.';

  @override
  String get passwordUpdateSuccess => 'Password updated successfully!';

  @override
  String get passwordUpdateFailed => 'Failed to update password.';

  @override
  String get authWelcome => 'Welcome';

  @override
  String get authSignInToContinue => 'Sign in to your account to continue';

  @override
  String get authCreateAccount => 'Create an Account';

  @override
  String get authGetStarted => 'Let\'s get you started';

  @override
  String get authFullName => 'Full Name';

  @override
  String get authPhoneNumber => 'Phone Number';

  @override
  String get authPassword => 'Password';

  @override
  String get authSignIn => 'Sign In';

  @override
  String get authRegister => 'Create Account';

  @override
  String get authNoAccount => 'Don\'t have an account? ';

  @override
  String get authHaveAccount => 'Already have an account? ';

  @override
  String get authErrorEnterFullName => 'Please enter your full name';

  @override
  String get authErrorEnterPhone => 'Please enter a phone number';

  @override
  String get authErrorInvalidPhone => 'Please enter a valid phone number';

  @override
  String get authErrorEnterPassword => 'Please enter a password';

  @override
  String get authErrorPasswordShort => 'Password must be at least 6 characters';

  @override
  String get authSwitchToRegister => 'Register';

  @override
  String get authSwitchToSignIn => 'Sign In';

  @override
  String get registerCreateAccount => 'Create an Account';

  @override
  String get registerGetStarted => 'Let\'s get you started';

  @override
  String get registerFullName => 'Full Name';

  @override
  String get registerPhoneNumber => 'Phone Number';

  @override
  String get registerPassword => 'Password';

  @override
  String get registerButton => 'Create Account';

  @override
  String get registerHaveAccount => 'Already have an account? ';

  @override
  String get registerSignIn => 'Sign In';

  @override
  String get registerErrorEnterFullName => 'Please enter your full name';

  @override
  String get registerErrorEnterPhone => 'Please enter a phone number';

  @override
  String get registerErrorInvalidPhone => 'Please enter a valid phone number';

  @override
  String get registerErrorEnterPassword => 'Please enter a password';

  @override
  String get registerErrorPasswordShort => 'Password must be at least 6 characters';

  @override
  String get historyScreenTitle => 'Ride History';

  @override
  String get historyLoading => 'Loading...';

  @override
  String get historyErrorTitle => 'Something Went Wrong';

  @override
  String get historyErrorMessage => 'An unexpected error occurred. Please check your connection.';

  @override
  String get historyRetryButton => 'Try Again';

  @override
  String get historyEmptyTitle => 'No Rides Yet';

  @override
  String get historyEmptyMessage => 'Your completed trips will appear here.';

  @override
  String get historyCardFrom => 'From';

  @override
  String get historyCardTo => 'To';

  @override
  String get historyCardFare => 'Fare:';

  @override
  String get historyCardUnknownLocation => 'Unknown Location';

  @override
  String get historyStatusCompleted => 'COMPLETED';

  @override
  String get historyStatusCanceled => 'CANCELED';

  @override
  String get historyStatusPending => 'PENDING';

  @override
  String get currencySymbol => 'Birr';

  @override
  String get discoveryWhereTo => 'Where to?';

  @override
  String get discoverySearchDestination => 'Search destination';

  @override
  String get discoveryHome => 'Home';

  @override
  String get discoveryWork => 'Work';

  @override
  String get discoveryAddHome => 'Add Home';

  @override
  String get discoveryAddWork => 'Add Work';

  @override
  String get discoveryFavoritePlaces => 'Favorite Places';

  @override
  String get discoveryAddFavoritePrompt => 'Tap the \'+\' to add a favorite destination.';

  @override
  String get discoveryRecentTrips => 'Recent Trips';

  @override
  String get discoveryRecentTripRemoved => 'Recent trip removed.';

  @override
  String get discoveryClearAll => 'Clear All';

  @override
  String get discoveryMenuChangeAddress => 'Change Address';

  @override
  String get discoveryMenuRemove => 'Remove';

  @override
  String get searchingContactingDrivers => 'Contacting Nearby Drivers';

  @override
  String get searchingPleaseWait => 'Please wait while we find a ride for you.';

  @override
  String get searchingDetailFrom => 'FROM';

  @override
  String get searchingDetailTo => 'TO';

  @override
  String get searchingDetailVehicle => 'VEHICLE';

  @override
  String searchingDetailVehicleValue(Object name, Object price) {
    return '$name • Est. $price Birr';
  }

  @override
  String get searchingCancelButton => 'Cancel Search';

  @override
  String get planningPanelDistance => 'DISTANCE';

  @override
  String get planningPanelDuration => 'DURATION';

  @override
  String get planningPanelConfirmButton => 'Confirm';

  @override
  String get planningPanelNoRidesAvailable => 'No ride options available.';

  @override
  String get planningPanelRideOptionsError => 'Could not load ride options.';

  @override
  String planningPanelPrice(String price) {
    return 'Birr: $price';
  }

  @override
  String get planningPanelSelectRide => 'Select a Ride';

  @override
  String get planningPanelConfirmRide => 'Confirm Ride';

  @override
  String get registerErrorPhoneInvalid => 'Please enter a valid phone number';

  @override
  String get optional => 'optional';

  @override
  String get registerConfirmPassword => 'Confirm Password';

  @override
  String get registerErrorEnterConfirmPassword => 'Please enter confirm password';

  @override
  String get registerErrorPasswordMismatch => 'Passwords do not match';

  @override
  String get phone => 'Phone';

  @override
  String get registerGetOtp => 'GET OTP';

  @override
  String get registerErrorEnterEmail => 'Please enter your email';

  @override
  String get registerErrorInvalidEmail => 'Please enter a valid email address';

  @override
  String get driverOnWayEnRouteToDestination => 'En Route to Destination';

  @override
  String get driverOnWayDriverArriving => 'Your Driver is Arriving';

  @override
  String get driverOnWayBookingId => 'Booking ID:';

  @override
  String get driverOnWayDriverId => 'Driver ID:';

  @override
  String get driverOnWayPickup => 'Pickup:';

  @override
  String get driverOnWayDropoff => 'Dropoff:';

  @override
  String get driverOnWayCall => 'Call';

  @override
  String get driverOnWayChat => 'Chat';

  @override
  String get driverOnWayCancelRide => 'Cancel Ride';

  @override
  String get driverOnWayDriverNotAvailable => 'Driver N/A';

  @override
  String get driverOnWayNotAvailable => 'N/A';

  @override
  String get driverOnWayColorNotAvailable => 'Color N/A';

  @override
  String get driverOnWayModelNotAvailable => 'Model N/A';

  @override
  String get driverOnWayPlateNotAvailable => 'PLATE N/A';

  @override
  String get driverOnWayVehicleUnknown => 'Unknown';

  @override
  String get ongoingTripEnjoyRide => 'Enjoy your ride!';

  @override
  String get ongoingTripOnYourWay => 'You are on your way to the destination.';

  @override
  String get ongoingTripDriverOnWay => 'Driver is on the way';

  @override
  String ongoingTripDriverArrivingIn(String eta) {
    return 'Your driver will arrive in approximately $eta';
  }

  @override
  String get ongoingTripYourDriver => 'Your Driver';

  @override
  String get ongoingTripStandardCar => 'Standard Car';

  @override
  String get ongoingTripPlatePlaceholder => '...';

  @override
  String get ongoingTripDefaultColor => 'Black';

  @override
  String get ongoingTripCall => 'Call';

  @override
  String get ongoingTripChat => 'Chat';

  @override
  String get ongoingTripCancel => 'Cancel';

  @override
  String get postTripCompleted => 'Trip Completed!';

  @override
  String get postTripYourDriver => 'Your Driver';

  @override
  String get postTripRateExperience => 'Rate your experience';

  @override
  String get postTripAddComment => 'Add a detailed comment (optional)';

  @override
  String get postTripSubmitFeedback => 'Submit Feedback';

  @override
  String get postTripSkip => 'Skip';

  @override
  String get postTripShowAppreciation => 'Show your appreciation?';

  @override
  String get postTripOther => 'Other';

  @override
  String get postTripFinalFare => 'Final Fare';

  @override
  String get postTripDistance => 'Distance';

  @override
  String get postTripTagExcellentService => 'Excellent Service';

  @override
  String get postTripTagCleanCar => 'Clean Car';

  @override
  String get postTripTagSafeDriver => 'Safe Driver';

  @override
  String get postTripTagGoodConversation => 'Good Conversation';

  @override
  String get postTripTagFriendlyAttitude => 'Friendly Attitude';

  @override
  String get driverInfoWindowVehicleStandard => 'Standard';

  @override
  String get driverInfoWindowAvailable => 'Available';

  @override
  String get driverInfoWindowOnTrip => 'On Trip';

  @override
  String get driverInfoWindowSelect => 'Select';

  @override
  String get notificationRideConfirmedTitle => 'Your Ride is Confirmed!';

  @override
  String notificationRideConfirmedBody(String driverName) {
    return 'Driver $driverName is on the way.';
  }

  @override
  String get notificationDriverArrivedTitle => 'Your Driver Has Arrived!';

  @override
  String get notificationDriverArrivedBody => 'Please meet your driver at the pickup location.';

  @override
  String get notificationTripStartedTitle => 'Your Trip Has Started';

  @override
  String get notificationTripStartedBody => 'Enjoy your ride! We wish you a safe journey.';

  @override
  String get notificationTripCompletedTitle => 'Trip Completed!';

  @override
  String get notificationTripCompletedBody => 'Thank you for riding with us. We hope to see you again soon.';

  @override
  String get notificationRideCanceledTitle => 'Ride Canceled';

  @override
  String get notificationRideCanceledBody => 'Your ride request has been canceled.';

  @override
  String get notificationRequestSentTitle => 'Ride Requested';

  @override
  String get notificationRequestSentBody => 'We have received your request and are now searching for nearby drivers.';

  @override
  String notificationNewMessageTitle(String driverName) {
    return 'New Message from $driverName';
  }

  @override
  String get notificationNoDriversTitle => 'No Drivers Available';

  @override
  String get notificationNoDriversBody => 'We couldn\'t find a driver nearby. Please try again in a moment.';

  @override
  String get notificationBookingErrorTitle => 'Booking Error';

  @override
  String get arrived => 'Arrived';

  @override
  String get editProfileSubtitle => 'Keep your personal information up to date.';

  @override
  String notificationSearchingBody(String radius) {
    return 'Searching for drivers within a $radius km radius.';
  }

  @override
  String get notificationDriverNearbyTitle => 'Driver is Nearby';

  @override
  String notificationDriverNearbyBody(String distance) {
    return 'Your driver is now less than $distance meters away.';
  }

  @override
  String get notificationDriverVeryCloseTitle => 'Driver is Very Close';

  @override
  String get notificationDriverVeryCloseBody => 'Get ready! Your driver is almost here.';

  @override
  String get offlineOrderTitle => 'Offline Order';

  @override
  String get offlineRequestTitle => 'Request Ride via SMS';

  @override
  String get offlineRequestSubtitle => 'No internet? No problem. Enter your locations below and we will call you back to confirm your booking.';

  @override
  String get pickupLocationHint => 'Enter Pickup Location';

  @override
  String get destinationLocationHint => 'Enter Destination';

  @override
  String get pickupValidationError => 'Please enter a pickup location';

  @override
  String get destinationValidationError => 'Please enter a destination';

  @override
  String get prepareSmsButton => 'Prepare SMS Request';

  @override
  String get smsCouldNotOpenError => 'Could not open your SMS application.';

  @override
  String get smsGenericError => 'An error occurred while creating the SMS.';

  @override
  String get step1Title => 'Enter Locations';

  @override
  String get step1Subtitle => 'Tell us where to pick you up and where you\'re going.';

  @override
  String get step2Title => 'Prepare SMS';

  @override
  String get step2Subtitle => 'We\'ll create a text message with your details.';

  @override
  String get step3Title => 'Await Our Call';

  @override
  String get step3Subtitle => 'Our team will call you shortly to confirm your ride.';

  @override
  String get smsOfflineLogin => 'No internet? Order by SMS';

  @override
  String get smsLaunchSuccessTitle => 'SMS App Opened';

  @override
  String get smsLaunchSuccessMessage => 'Please review the message and press \'Send\' to submit your request.';

  @override
  String get smsCapabilityError => 'This device is not capable of sending SMS messages.';

  @override
  String get smsLaunchError => 'Could not open the SMS application. Please check your device settings.';

  @override
  String get offline => 'offline SMS';

  @override
  String get skip => 'Skip';

  @override
  String get finish => 'FINISH';

  @override
  String get completeProfileTitle => 'One Last Step';

  @override
  String get completeProfileSubtitle => 'Complete your profile to continue.';

  @override
  String get errorEnterregex => 'check special characters or lower and upper case.';

  @override
  String get mySubscriptionsTitle => 'My Subscriptions';

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
  String get contractDetails => 'Contract Details';

  @override
  String get status => 'Status';

  @override
  String get duration => 'Duration';

  @override
  String get cost => 'Cost';

  @override
  String get routeInformation => 'Route Information';

  @override
  String get pickup => 'Pickup';

  @override
  String get dropoff => 'Dropoff';

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
  String get saveLocationAs => 'SAVE LOCATION AS';

  @override
  String get home => 'Home';

  @override
  String get work => 'Work';

  @override
  String get favorite => 'Favorite';

  @override
  String get goToDestination => 'GO TO DESTINATION';

  @override
  String get saveAsHome => 'SAVE AS HOME';

  @override
  String get saveAsWork => 'SAVE AS WORK';

  @override
  String get addToFavorites => 'ADD TO FAVORITES';

  @override
  String get confirmLocation => 'CONFIRM LOCATION';

  @override
  String get currentLocation => 'Current Location';

  @override
  String get selectedLocation => 'Selected Location';

  @override
  String get locationNotAvailable => 'Current location not available. Ensure permissions are granted.';

  @override
  String get selectPickupAndDestination => 'Please select both pickup and destination.';

  @override
  String get clearRecentPlacesQuestion => 'Clear recent places?';

  @override
  String get actionCannotBeUndone => 'This action cannot be undone.';

  @override
  String get clear => 'Clear';

  @override
  String get setRoute => 'Set Route';

  @override
  String get selectLocation => 'Select Location';

  @override
  String get pickupLocation => 'Pickup Location';

  @override
  String get destination => 'Destination';

  @override
  String get setOnMap => 'Set on Map';

  @override
  String get current => 'Current';

  @override
  String get savedPlaces => 'Saved Places';

  @override
  String get recent => 'Recent';

  @override
  String get addHome => 'Add Home';

  @override
  String get addWork => 'Add Work';

  @override
  String get setPickup => 'Set as Pickup';

  @override
  String get setDestination => 'Set as Destination';

  @override
  String get confirmPickup => 'Confirm Pickup';

  @override
  String get confirmDestination => 'Confirm Destination';

  @override
  String get discoverySetHome => 'Set as Home';

  @override
  String get discoverySetWork => 'Set as Work';

  @override
  String get discoveryAddFavorite => 'Add Favorite';

  @override
  String get setAsPickupLocation => 'Set as Pickup Location';

  @override
  String get setAsDestination => 'Set as Destination';

  @override
  String get updateRoute => 'Update Route';

  @override
  String get setPickupFirst => 'Set Pickup First';

  @override
  String get saveHome => 'Save Home';

  @override
  String get saveWork => 'Save Work';

  @override
  String get addFavorite => 'Add Favorite';

  @override
  String get setYourRoute => 'Set Your Route';

  @override
  String get whereWouldYouLikeToGo => 'Where would you like to go?';

  @override
  String get changeAddress => 'Change Address';

  @override
  String get remove => 'Remove';

  @override
  String itemRemovedSuccessfully(String itemType) {
    return '$itemType removed successfully';
  }

  @override
  String get homeAddress => 'Home Address';

  @override
  String get workAddress => 'Work Address';

  @override
  String get favoritePlace => 'Favorite Place';

  @override
  String get placeOptions => 'Place Options';

  @override
  String get clearAllDataTitle => 'Clear All Data?';

  @override
  String get clearAllDataContent => 'This will remove all your home, work, favorites, and recent places. This action cannot be undone.';

  @override
  String get clearEverything => 'Clear Everything';

  @override
  String get allDataCleared => 'All data cleared successfully';

  @override
  String get searchErrorTitle => 'Search Failed';

  @override
  String get searchErrorMessage => 'Please check your internet connection and try again.';

  @override
  String get noResultsFound => 'No Results Found';

  @override
  String get tryDifferentSearch => 'Try a different search term';

  @override
  String get pickOnMap => 'Pick on Map';

  @override
  String get clearAll => 'Clear All';

  @override
  String get add => 'Add';

  @override
  String get addYourHomeAddress => 'Add your home address';

  @override
  String get addYourWorkAddress => 'Add your work address';

  @override
  String get favorites => 'Favorites';

  @override
  String get recentTrips => 'Recent Trips';

  @override
  String get noFavoritesYet => 'No Favorites Yet';

  @override
  String get addFavoritesMessage => 'Add your frequently visited places for quick access';

  @override
  String get noRecentTrips => 'No Recent Trips';

  @override
  String get recentTripsMessage => 'Your recent destinations will appear here';

  @override
  String recentTripsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recent trips',
      one: '1 recent trip',
      zero: 'No recent trips',
    );
    return '$_temp0';
  }

  @override
  String get recentsCleared => 'Recent trips cleared';

  @override
  String get recentTripRemoved => 'Recent trip removed';

  @override
  String get searching => 'Searching...';

  @override
  String get yourCurrentPosition => 'Your current position';

  @override
  String get useCurrentLocation => 'Use Current Location';

  @override
  String get planYourRoute => 'Plan Your Route';

  @override
  String get planningPanelVehicleSelection => 'VEHICLE SELECTION';

  @override
  String get planningPanelEngageButton => 'ENGAGE';

  @override
  String get planningPanelTitle => 'Choose Your Ride';

  @override
  String get noRidesAvailable => 'No rides available in this area.';

  @override
  String get vehicleTaglineStandard => 'The perfect everyday essential.';

  @override
  String get vehicleTaglineComfort => 'Extra comfort for a relaxing ride.';

  @override
  String get vehicleTaglineVan => 'Room for the whole crew.';

  @override
  String get vehicleTaglineDefault => 'A great choice for your trip.';

  @override
  String get fareCalculating => 'Calculating...';

  @override
  String get ride => 'RIDE';

  @override
  String get confirmButtonRequesting => 'REQUESTING...';

  @override
  String get confirmButtonRequest => 'REQUEST';

  @override
  String get postTripAddCompliment => 'Add a compliment';

  @override
  String get driverOnWayEnjoyYourRide => 'Enjoy your ride!';

  @override
  String get driverOnWayMeetAtPickup => 'Please meet them at the pickup location.';

  @override
  String get ongoingTripTitle => 'On Trip';

  @override
  String get tripDuration => 'Trip Duration';

  @override
  String get safetyAndTools => 'Safety & Tools';

  @override
  String get shareTrip => 'Share Trip';

  @override
  String get emergencySOS => 'SOS';

  @override
  String get emergencyDialogTitle => 'Emergency Assistance';

  @override
  String get emergencyDialogContent => 'This will contact local emergency services. Are you sure you want to proceed?';

  @override
  String get emergencyDialogCancel => 'Cancel';

  @override
  String get emergencyDialogConfirm => 'Call Now';

  @override
  String get phoneNumberNotAvailable => 'Driver\'s phone number is not available.';

  @override
  String couldNotLaunch(Object url) {
    return 'Could not launch $url';
  }

  @override
  String get discount => 'Discount';

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
  String get drawerMyTrips => 'My Trips';

  @override
  String get drawerAvailableContracts => 'Available Contracts';

  @override
  String get drawerMyTransactions => 'My Transactions';

  @override
  String get drawerLogoutForgetDevice => 'Logout & Forget Device';

  @override
  String get contractPanelTitle => 'Contract Rides';

  @override
  String get contractPanelSubtitle => 'Your premium travel experience';

  @override
  String get contractPanelActiveSubscriptionsTitle => 'Active Subscriptions';

  @override
  String get contractPanelActiveSubscriptionsSubtitle => 'Your current premium rides';

  @override
  String get contractPanelErrorLoadSubscriptions => 'Unable to load your subscriptions';

  @override
  String get contractPanelEmptySubscriptions => 'No active subscriptions found';

  @override
  String get contractPanelEmptySubscriptionsSubtitle => 'Create your first premium ride below';

  @override
  String get contractPanelNewContractsTitle => 'New Contracts';

  @override
  String get contractPanelNewContractsSubtitle => 'Upgrade your travel experience';

  @override
  String get contractPanelErrorLoadContracts => 'Unable to load contract types';

  @override
  String get contractPanelEmptyContracts => 'No contracts available';

  @override
  String get contractPanelEmptyContractsSubtitle => 'Check back later for new offers';

  @override
  String get contractPanelRetryButton => 'Try Again';

  @override
  String contractPanelDiscountOff(String discountValue) {
    return '$discountValue% OFF';
  }

  @override
  String get contractPickerTitlePickup => 'Select Pickup Location';

  @override
  String get contractPickerTitleDestination => 'Select Destination';

  @override
  String get contractPickerHintPickup => 'Search for pickup...';

  @override
  String get contractPickerHintDestination => 'Search for destination...';

  @override
  String get contractPickerNoRecents => 'No recent searches found.';

  @override
  String get contractPickerRecentsTitle => 'Recent Searches';

  @override
  String get contractPickerNoResults => 'No results found.';

  @override
  String get contractDriverLoading => 'Locating your contract driver...';

  @override
  String get contractDriverTypeLabel => 'Contract Driver';

  @override
  String get contractDetailsTitle => 'Contract Details';

  @override
  String get contractDetailsSubscriptionId => 'Subscription ID';

  @override
  String get contractDetailsContractType => 'Contract Type';

  @override
  String get contractDetailsScheduledRide => 'Scheduled Ride';

  @override
  String get contractDetailsTimeRemaining => 'Time Remaining';

  @override
  String get contractExpired => 'Contract Expired';

  @override
  String contractTimeLeftDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left',
      one: '$count day left',
    );
    return '$_temp0';
  }

  @override
  String contractTimeLeftHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours left',
      one: '$count hour left',
    );
    return '$_temp0';
  }

  @override
  String contractTimeLeftMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes left',
      one: '$count minute left',
    );
    return '$_temp0';
  }

  @override
  String get confirmRideTitle => 'Confirm Your Ride';

  @override
  String bookingUnderContract(Object contractType) {
    return 'Booking under: $contractType';
  }

  @override
  String get tripSummaryTitle => 'TRIP SUMMARY';

  @override
  String get assignedDriver => 'Assigned Driver';

  @override
  String get driverContact => 'Driver Contact';

  @override
  String get vehicle => 'Vehicle';

  @override
  String get plateNumber => 'Plate No.';

  @override
  String get contractPrice => 'Contract Price';

  @override
  String get tripDistance => 'Trip Distance';

  @override
  String get paymentStatus => 'Payment Status';

  @override
  String get subscriptionStatus => 'Subscription Status';

  @override
  String get validity => 'Validity';

  @override
  String get driverPending => 'Driver Pending';

  @override
  String get negotiated => 'Negotiated';

  @override
  String get confirmTodaysPickup => 'Confirm Today\'s Pickup';

  @override
  String get exploreContracts => 'Explore Contracts';

  @override
  String get refresh => 'Refresh';

  @override
  String get retry => 'Retry';

  @override
  String get rideSubscriptionFallbackTitle => 'Ride Subscription';

  @override
  String get basePrice => 'Base Price';

  @override
  String get minimumFare => 'Minimum Fare';

  @override
  String get maxPassengers => 'Max Passengers';

  @override
  String get featureWifi => 'WiFi';

  @override
  String get featureAC => 'A/C';

  @override
  String get featurePremiumSeats => 'Premium Seats';

  @override
  String get featurePrioritySupport => 'Priority Support';

  @override
  String get availableContractsTitle => 'Available Contracts';

  @override
  String get noContractsAvailableTitle => 'No Contracts Available';

  @override
  String get noContractsAvailableMessage => 'Please check back later for new subscription offers.';

  @override
  String get failedToLoadContractsTitle => 'Failed to Load Contracts';

  @override
  String get failedToLoadContractsMessage => 'Please check your internet connection and try again.';

  @override
  String get baseRate => 'Base Rate';

  @override
  String get selectAndPickRoute => 'Select & Pick Route';

  @override
  String get myTransactions => 'My Transactions';

  @override
  String get errorPrefix => 'An Error Occurred';

  @override
  String get currentWalletBalance => 'Current Wallet Balance';

  @override
  String get transactionHistory => 'Transaction History';

  @override
  String get noTransactionsYet => 'No Transactions Yet';

  @override
  String get yourRecentTransactionsWillAppearHere => 'Your recent transactions will appear here.';

  @override
  String get transactionStatusCompleted => 'Completed';

  @override
  String get transactionStatusPending => 'Pending';

  @override
  String get transactionStatusFailed => 'Failed';

  @override
  String get subscriptionDetails => 'Subscription Details';

  @override
  String get payment => 'Payment';

  @override
  String get distance => 'Distance';

  @override
  String get financials => 'Financials';

  @override
  String get baseFare => 'Base Fare';

  @override
  String get finalFare => 'Final Fare';

  @override
  String get name => 'Name';

  @override
  String get passengerDetails => 'Passenger Details';

  @override
  String get identifiers => 'Identifiers';

  @override
  String get subscriptionId => 'Subscription ID';

  @override
  String get contractId => 'Contract ID';

  @override
  String get passengerId => 'Passenger ID';

  @override
  String get driverId => 'Driver ID';

  @override
  String get notAssigned => 'Not Assigned';

  @override
  String get callDriver => 'Call Driver';

  @override
  String get daysLeft => 'Guyyoota Hafan';

  @override
  String get expiresToday => 'Har\'a Xumurama';

  @override
  String get statusExpired => 'Xumurameera';

  @override
  String daysLeftSingular(int count) {
    return 'Guyyaan $count hafe';
  }

  @override
  String daysLeftPlural(int count) {
    return 'Guyyoonni $count hafan';
  }

  @override
  String get newSubscriptionRequest => 'New Subscription Request';

  @override
  String subscribingTo(String contractType) {
    return 'Subscribing to: $contractType';
  }

  @override
  String get reviewRequestPrompt => 'Please confirm your route and select the desired duration for your subscription.';

  @override
  String get yourRoute => 'Your Route';

  @override
  String get dropoffLocation => 'Dropoff Location';

  @override
  String get subscriptionDuration => 'Subscription Duration';

  @override
  String get selectDateRange => 'Tap to select date range';

  @override
  String get pleaseSelectDateRange => 'Please select a start and end date.';

  @override
  String get proceedToPayment => 'Proceed to Payment';

  @override
  String get requestSubmitted => 'Request Submitted!';

  @override
  String get approvalNotificationPrompt => 'Your subscription request has been sent for administrative approval. You will be notified once it is active.';

  @override
  String get done => 'Done';

  @override
  String get paymentScreenTitle => 'Complete Your Payment';

  @override
  String get paymentConfirmTitle => 'Confirm Your Payment';

  @override
  String paymentTotalAmount(Object amount) {
    return 'Total Amount: ETB $amount';
  }

  @override
  String get paymentSelectGateway => 'Select your preferred payment gateway or upload a bank receipt.';

  @override
  String get paymentPreferredMethod => 'PREFERRED METHOD';

  @override
  String get paymentOtherGateways => 'OTHER GATEWAYS';

  @override
  String get paymentChooseGateway => 'CHOOSE A GATEWAY';

  @override
  String get paymentViewMoreOptions => 'View More Options';

  @override
  String paymentPayWith(Object methodName) {
    return 'Pay with $methodName';
  }

  @override
  String get paymentSelectAGateway => 'Select a Gateway';

  @override
  String get paymentOr => 'OR';

  @override
  String get paymentUploadBankReceipt => 'Upload Bank Receipt';

  @override
  String get paymentManualUploadTitle => 'Manual Payment Upload';

  @override
  String get paymentManualUploadSubtitle => 'Enter the bank transaction reference and upload a screenshot of your receipt.';

  @override
  String get paymentTxnReferenceLabel => 'Transaction Reference';

  @override
  String get paymentTxnReferenceRequired => 'This field is required';

  @override
  String get paymentTapToSelectReceipt => 'Tap to select receipt image';

  @override
  String get paymentSubmitForReview => 'Submit for Review';

  @override
  String paymentErrorLoading(Object error) {
    return 'Error loading payment methods: $error';
  }

  @override
  String get paymentNoMethodsAvailable => 'No payment methods available.';

  @override
  String get paymentSuccessDialogTitle => 'Confirmation Sent!';

  @override
  String get paymentSuccessDialogContent => 'A request has been sent to your phone. Please enter your PIN to approve the payment.';

  @override
  String get paymentErrorDialogTitle => 'Payment Error';

  @override
  String get paymentManualSuccessTitle => 'Upload Successful';

  @override
  String get paymentManualSuccessContent => 'Your payment proof has been submitted and is pending review.';

  @override
  String get paymentOkButton => 'OK';

  @override
  String paymentErrorSnackbar(Object message) {
    return 'Error: $message';
  }

  @override
  String get contractsSectionTitle => 'Apply a Ride Plan';

  @override
  String get contractsSectionDescription => 'Use a pre-paid weekly or monthly plan to get special rates for this trip.';

  @override
  String get tripDetails => 'Trip Details';

  @override
  String get confirmDropoff => 'Confirm Drop Off';

  @override
  String get enterCode => 'Enter Code';

  @override
  String otpScreenSubtitle(String phoneNumber) {
    return 'We sent a verification code to\n$phoneNumber';
  }

  @override
  String get verifyButton => 'VERIFY';

  @override
  String get didNotReceiveCodeResend => 'Didn\'t receive code? Resend';

  @override
  String resendCodeIn(int seconds) {
    return 'Resend code in ${seconds}s';
  }

  @override
  String get enterValidOtp => 'Please enter a valid 6-digit code.';

  @override
  String get resendingOtp => 'Resending OTP...';

  @override
  String get mapLayersTitle => 'Map Layers';

  @override
  String get mapLayersDark => 'Dark';

  @override
  String get mapLayersLight => 'Light';

  @override
  String get mapLayersSatellite => 'Satellite';

  @override
  String get all => 'All';

  @override
  String get paid => 'Paid';

  @override
  String get pending => 'Pending';

  @override
  String get above => 'Above';

  @override
  String get moreFilters => 'More Filters';

  @override
  String get dateRange => 'Date Range';

  @override
  String get anyDate => 'Any Date';

  @override
  String get sortBy => 'Sort By';

  @override
  String get sortNewestFirst => 'Newest First';

  @override
  String get sortOldestFirst => 'Oldest First';

  @override
  String get sortAmountHighest => 'Amount (High to Low)';

  @override
  String get sortAmountLowest => 'Amount (Low to High)';

  @override
  String get applyFilters => 'Apply';

  @override
  String get transactionID => 'Transaction ID';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get bookingID => 'Booking ID';

  @override
  String get date => 'Date';

  @override
  String get noMatchingTransactions => 'No Transactions Match Your Filters';

  @override
  String get tryAdjustingFilters => 'Try adjusting or clearing your search filters to see results.';
}
