// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Welcome Back`
  String get welcomeBack {
    return Intl.message(
      'Welcome Back',
      name: 'welcomeBack',
      desc: 'Welcome message displayed on the authentication screen',
      args: [],
    );
  }

  /// `Check your internet connection or try again later.`
  String get checkConnection {
    return Intl.message(
      'Check your internet connection or try again later.',
      name: 'checkConnection',
      desc: 'Error message when there is no internet connection',
      args: [],
    );
  }

  /// `Enter your email`
  String get enterYourEmail {
    return Intl.message(
      'Enter your email',
      name: 'enterYourEmail',
      desc: 'Hint text for the email input field',
      args: [],
    );
  }

  /// `API Token`
  String get apiToken {
    return Intl.message(
      'API Token',
      name: 'apiToken',
      desc: 'Hint text for the API token input field',
      args: [],
    );
  }

  /// `Sign In`
  String get signIn {
    return Intl.message(
      'Sign In',
      name: 'signIn',
      desc: 'Text for the sign-in button',
      args: [],
    );
  }

  /// `Forgot your API Token?`
  String get forgotApiToken {
    return Intl.message(
      'Forgot your API Token?',
      name: 'forgotApiToken',
      desc: 'Text for the link to recover a forgotten API token',
      args: [],
    );
  }

  /// `Contact your system administrator for a new API token.`
  String get contactAdmin {
    return Intl.message(
      'Contact your system administrator for a new API token.',
      name: 'contactAdmin',
      desc:
          'SnackBar message shown when the user clicks the forgot API token link',
      args: [],
    );
  }

  /// `Sales Overview`
  String get salesOverview {
    return Intl.message(
      'Sales Overview',
      name: 'salesOverview',
      desc: 'Title for the sales chart section',
      args: [],
    );
  }

  /// `No data available`
  String get noDataAvailable {
    return Intl.message(
      'No data available',
      name: 'noDataAvailable',
      desc: 'Message shown when no sales data is available',
      args: [],
    );
  }

  /// `Day`
  String get day {
    return Intl.message(
      'Day',
      name: 'day',
      desc: 'Time range option for daily sales data',
      args: [],
    );
  }

  /// `Month`
  String get month {
    return Intl.message(
      'Month',
      name: 'month',
      desc: 'Time range option for monthly sales data',
      args: [],
    );
  }

  /// `Quarter`
  String get quarter {
    return Intl.message(
      'Quarter',
      name: 'quarter',
      desc: 'Time range option for quarterly sales data',
      args: [],
    );
  }

  /// `Year`
  String get year {
    return Intl.message(
      'Year',
      name: 'year',
      desc: 'Time range option for yearly sales data',
      args: [],
    );
  }

  /// `Please log in again.`
  String get pleaseLoginAgain {
    return Intl.message(
      'Please log in again.',
      name: 'pleaseLoginAgain',
      desc: 'Error message when user is not logged in',
      args: [],
    );
  }

  /// `Session expired. Please log in again.`
  String get sessionExpired {
    return Intl.message(
      'Session expired. Please log in again.',
      name: 'sessionExpired',
      desc: 'Error message when session token is invalid',
      args: [],
    );
  }

  /// `Authentication error.`
  String get authenticationError {
    return Intl.message(
      'Authentication error.',
      name: 'authenticationError',
      desc: 'Error message when authentication fails',
      args: [],
    );
  }

  /// `Server error: HTTP {statusCode}`
  String serverError(Object statusCode) {
    return Intl.message(
      'Server error: HTTP $statusCode',
      name: 'serverError',
      desc: 'Error message for server errors with HTTP status code',
      args: [statusCode],
    );
  }

  /// `Network error: {error}`
  String networkError(Object error) {
    return Intl.message(
      'Network error: $error',
      name: 'networkError',
      desc: 'Error message for network-related errors',
      args: [error],
    );
  }

  /// `Selected: {period}`
  String selected(Object period) {
    return Intl.message(
      'Selected: $period',
      name: 'selected',
      desc: 'Label for the selected sales period in the chart',
      args: [period],
    );
  }

  /// `vs Average: {sign}{diff}%`
  String vsAverage(Object sign, Object diff) {
    return Intl.message(
      'vs Average: $sign$diff%',
      name: 'vsAverage',
      desc: 'Label showing the difference from average sales',
      args: [sign, diff],
    );
  }

  /// `Quick Actions`
  String get quickActions {
    return Intl.message(
      'Quick Actions',
      name: 'quickActions',
      desc: 'Title for the quick actions section',
      args: [],
    );
  }

  /// `Nearby Customers`
  String get nearbyCustomers {
    return Intl.message(
      'Nearby Customers',
      name: 'nearbyCustomers',
      desc: 'Label for the nearby customers action button',
      args: [],
    );
  }

  /// `Stock`
  String get stock {
    return Intl.message(
      'Stock',
      name: 'stock',
      desc: 'Label for the stock action button',
      args: [],
    );
  }

  /// `Dashboard`
  String get dashboard {
    return Intl.message(
      'Dashboard',
      name: 'dashboard',
      desc: 'Label for the dashboard navigation item',
      args: [],
    );
  }

  /// `Customers`
  String get customers {
    return Intl.message(
      'Customers',
      name: 'customers',
      desc: 'Label for the customers navigation item',
      args: [],
    );
  }

  /// `Odoo`
  String get odoo {
    return Intl.message(
      'Odoo',
      name: 'odoo',
      desc: 'Label for the Odoo navigation item',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: 'Label for the settings navigation item',
      args: [],
    );
  }

  /// `You Are Offline`
  String get youAreOffline {
    return Intl.message(
      'You Are Offline',
      name: 'youAreOffline',
      desc: 'Message shown when the app is offline',
      args: [],
    );
  }

  /// `Check your internet connection or try again later.`
  String get checkInternetConnection {
    return Intl.message(
      'Check your internet connection or try again later.',
      name: 'checkInternetConnection',
      desc: 'Error message when there is no internet connection',
      args: [],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message(
      'Retry',
      name: 'retry',
      desc: 'Label for the retry action button',
      args: [],
    );
  }

  /// `Sales Target`
  String get salesTarget {
    return Intl.message(
      'Sales Target',
      name: 'salesTarget',
      desc: 'Title for the sales target metric card',
      args: [],
    );
  }

  /// `Collections`
  String get collections {
    return Intl.message(
      'Collections',
      name: 'collections',
      desc: 'Title for the collections metric card',
      args: [],
    );
  }

  /// `Visits`
  String get visits {
    return Intl.message(
      'Visits',
      name: 'visits',
      desc: 'Title for the visits metric card',
      args: [],
    );
  }

  /// `New Customers`
  String get newCustomers {
    return Intl.message(
      'New Customers',
      name: 'newCustomers',
      desc: 'Title for the new customers metric card',
      args: [],
    );
  }

  /// `{percentage}% of target`
  String ofTarget(Object percentage) {
    return Intl.message(
      '$percentage% of target',
      name: 'ofTarget',
      desc: 'Subtitle showing the percentage of sales target achieved',
      args: [percentage],
    );
  }

  /// `{count} partners`
  String partners(Object count) {
    return Intl.message(
      '$count partners',
      name: 'partners',
      desc: 'Subtitle showing the number of partners',
      args: [count],
    );
  }

  /// `Completed today`
  String get completedToday {
    return Intl.message(
      'Completed today',
      name: 'completedToday',
      desc: 'Subtitle for visits completed today',
      args: [],
    );
  }

  /// `This month`
  String get thisMonth {
    return Intl.message(
      'This month',
      name: 'thisMonth',
      desc: 'Subtitle for new customers this month',
      args: [],
    );
  }

  /// `k`
  String get thousand {
    return Intl.message(
      'k',
      name: 'thousand',
      desc: 'Suffix for thousand',
      args: [],
    );
  }

  /// `M`
  String get million {
    return Intl.message(
      'M',
      name: 'million',
      desc: 'Suffix for million',
      args: [],
    );
  }

  /// `B`
  String get billion {
    return Intl.message(
      'B',
      name: 'billion',
      desc: 'Suffix for billion',
      args: [],
    );
  }

  /// `T`
  String get trillion {
    return Intl.message(
      'T',
      name: 'trillion',
      desc: 'Suffix for trillion',
      args: [],
    );
  }

  /// `Notes`
  String get notes {
    return Intl.message('Notes', name: 'notes', desc: '', args: []);
  }

  /// `No notes yet`
  String get noNotesYet {
    return Intl.message('No notes yet', name: 'noNotesYet', desc: '', args: []);
  }

  /// `Success is not the absence of obstacles, but the courage to push through them.`
  String get inspirationalQuotes {
    return Intl.message(
      'Success is not the absence of obstacles, but the courage to push through them.',
      name: 'inspirationalQuotes',
      desc: '',
      args: [],
    );
  }

  /// `Customers`
  String get customersTitle {
    return Intl.message(
      'Customers',
      name: 'customersTitle',
      desc: 'Title for the customers list screen in the app bar',
      args: [],
    );
  }

  /// `Search customers...`
  String get searchCustomersHint {
    return Intl.message(
      'Search customers...',
      name: 'searchCustomersHint',
      desc: 'Hint text for the search input field',
      args: [],
    );
  }

  /// `Sort by name`
  String get sortByName {
    return Intl.message(
      'Sort by name',
      name: 'sortByName',
      desc: 'Tooltip or accessibility label for the sort button',
      args: [],
    );
  }

  /// `Failed to load customers`
  String get failedToLoadCustomers {
    return Intl.message(
      'Failed to load customers',
      name: 'failedToLoadCustomers',
      desc: 'Error message when customer loading fails',
      args: [],
    );
  }

  /// `No customers found`
  String get noCustomersFound {
    return Intl.message(
      'No customers found',
      name: 'noCustomersFound',
      desc: 'Message displayed when no customers are available',
      args: [],
    );
  }

  /// `Retry`
  String get retryButton {
    return Intl.message(
      'Retry',
      name: 'retryButton',
      desc: 'Text for the retry button in error or empty states',
      args: [],
    );
  }

  /// `Add customer`
  String get addCustomer {
    return Intl.message(
      'Add customer',
      name: 'addCustomer',
      desc: 'Tooltip or accessibility label for the add customer button',
      args: [],
    );
  }

  /// `Toggle theme`
  String get toggleTheme {
    return Intl.message(
      'Toggle theme',
      name: 'toggleTheme',
      desc: 'Tooltip for the theme toggle button',
      args: [],
    );
  }

  /// `Address`
  String get addressLabel {
    return Intl.message(
      'Address',
      name: 'addressLabel',
      desc: 'Label for the address field in customer card',
      args: [],
    );
  }

  /// `City`
  String get cityLabel {
    return Intl.message(
      'City',
      name: 'cityLabel',
      desc: 'Label for the city field in customer card',
      args: [],
    );
  }

  /// `State`
  String get stateLabel {
    return Intl.message(
      'State',
      name: 'stateLabel',
      desc: 'Label for the state field in customer card',
      args: [],
    );
  }

  /// `Country`
  String get countryLabel {
    return Intl.message(
      'Country',
      name: 'countryLabel',
      desc: 'Label for the country field in customer card',
      args: [],
    );
  }

  /// `Phone`
  String get phoneLabel {
    return Intl.message(
      'Phone',
      name: 'phoneLabel',
      desc: 'Label for the phone field in customer card',
      args: [],
    );
  }

  /// `Mobile`
  String get mobileLabel {
    return Intl.message(
      'Mobile',
      name: 'mobileLabel',
      desc: 'Label for the mobile field in customer card',
      args: [],
    );
  }

  /// `Settings`
  String get settingsTitle {
    return Intl.message(
      'Settings',
      name: 'settingsTitle',
      desc: 'Title for the settings screen in the app bar',
      args: [],
    );
  }

  /// `Dark Mode`
  String get darkModeTitle {
    return Intl.message(
      'Dark Mode',
      name: 'darkModeTitle',
      desc: 'Title for the theme settings card',
      args: [],
    );
  }

  /// `Edit Profile`
  String get editProfileTitle {
    return Intl.message(
      'Edit Profile',
      name: 'editProfileTitle',
      desc: 'Title for the edit profile settings item',
      args: [],
    );
  }

  /// `Security`
  String get securityTitle {
    return Intl.message(
      'Security',
      name: 'securityTitle',
      desc: 'Title for the security settings item',
      args: [],
    );
  }

  /// `Notifications`
  String get notificationsTitle {
    return Intl.message(
      'Notifications',
      name: 'notificationsTitle',
      desc: 'Title for the notifications settings item',
      args: [],
    );
  }

  /// `Logout`
  String get logoutTitle {
    return Intl.message(
      'Logout',
      name: 'logoutTitle',
      desc: 'Title for the logout settings item',
      args: [],
    );
  }

  /// `Logout`
  String get logoutDialogTitle {
    return Intl.message(
      'Logout',
      name: 'logoutDialogTitle',
      desc: 'Title for the logout confirmation dialog',
      args: [],
    );
  }

  /// `Are you sure you want to logout?`
  String get logoutDialogMessage {
    return Intl.message(
      'Are you sure you want to logout?',
      name: 'logoutDialogMessage',
      desc: 'Message in the logout confirmation dialog',
      args: [],
    );
  }

  /// `Cancel`
  String get cancelButton {
    return Intl.message(
      'Cancel',
      name: 'cancelButton',
      desc: 'Button text to cancel logout',
      args: [],
    );
  }

  /// `Logout`
  String get logoutButton {
    return Intl.message(
      'Logout',
      name: 'logoutButton',
      desc: 'Button text to confirm logout',
      args: [],
    );
  }

  /// `Logged Out`
  String get logoutSuccessTitle {
    return Intl.message(
      'Logged Out',
      name: 'logoutSuccessTitle',
      desc: 'Title for the success snackbar after logout',
      args: [],
    );
  }

  /// `You have been successfully logged out`
  String get logoutSuccessMessage {
    return Intl.message(
      'You have been successfully logged out',
      name: 'logoutSuccessMessage',
      desc: 'Message for the success snackbar after logout',
      args: [],
    );
  }

  /// `Logout Error`
  String get logoutErrorTitle {
    return Intl.message(
      'Logout Error',
      name: 'logoutErrorTitle',
      desc: 'Title for the error snackbar during logout',
      args: [],
    );
  }

  /// `Failed to complete logout`
  String get logoutErrorMessage {
    return Intl.message(
      'Failed to complete logout',
      name: 'logoutErrorMessage',
      desc: 'Message for the error snackbar during logout',
      args: [],
    );
  }

  /// `U`
  String get defaultUserInitial {
    return Intl.message(
      'U',
      name: 'defaultUserInitial',
      desc: 'Default initial for user avatar when no name',
      args: [],
    );
  }

  /// `User`
  String get defaultUserName {
    return Intl.message(
      'User',
      name: 'defaultUserName',
      desc: 'Default name when no user data',
      args: [],
    );
  }

  /// `No email`
  String get defaultUserEmail {
    return Intl.message(
      'No email',
      name: 'defaultUserEmail',
      desc: 'Default email when no user data',
      args: [],
    );
  }

  /// `Profile`
  String get profileTitle {
    return Intl.message(
      'Profile',
      name: 'profileTitle',
      desc: 'Title for the profile screen in the app bar',
      args: [],
    );
  }

  /// `No user data available`
  String get noUserData {
    return Intl.message(
      'No user data available',
      name: 'noUserData',
      desc: 'Message when no user data is available',
      args: [],
    );
  }

  /// `Email`
  String get emailLabel {
    return Intl.message(
      'Email',
      name: 'emailLabel',
      desc: 'Label for email in profile details',
      args: [],
    );
  }

  /// `Login`
  String get loginLabel {
    return Intl.message(
      'Login',
      name: 'loginLabel',
      desc: 'Label for login in profile details',
      args: [],
    );
  }

  /// `Store`
  String get storeLabel {
    return Intl.message(
      'Store',
      name: 'storeLabel',
      desc: 'Label for store name in profile details',
      args: [],
    );
  }

  /// `Store ID`
  String get storeIdLabel {
    return Intl.message(
      'Store ID',
      name: 'storeIdLabel',
      desc: 'Label for store ID in profile details',
      args: [],
    );
  }

  /// `Partner ID`
  String get partnerIdLabel {
    return Intl.message(
      'Partner ID',
      name: 'partnerIdLabel',
      desc: 'Label for partner ID in profile details',
      args: [],
    );
  }

  /// `Add Customer`
  String get add_customer {
    return Intl.message(
      'Add Customer',
      name: 'add_customer',
      desc: 'Button text for adding a new customer',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: 'Label for the name field',
      args: [],
    );
  }

  /// `Address`
  String get address {
    return Intl.message(
      'Address',
      name: 'address',
      desc: 'Label for the address field',
      args: [],
    );
  }

  /// `City`
  String get city {
    return Intl.message(
      'City',
      name: 'city',
      desc: 'Label for the city field',
      args: [],
    );
  }

  /// `State`
  String get state {
    return Intl.message(
      'State',
      name: 'state',
      desc: 'Label for the state field',
      args: [],
    );
  }

  /// `Country`
  String get country {
    return Intl.message(
      'Country',
      name: 'country',
      desc: 'Label for the country field',
      args: [],
    );
  }

  /// `Phone`
  String get phone {
    return Intl.message(
      'Phone',
      name: 'phone',
      desc: 'Label for the phone field',
      args: [],
    );
  }

  /// `Mobile`
  String get mobile {
    return Intl.message(
      'Mobile',
      name: 'mobile',
      desc: 'Label for the mobile field',
      args: [],
    );
  }

  /// `Payment Terms`
  String get payment_terms {
    return Intl.message(
      'Payment Terms',
      name: 'payment_terms',
      desc: 'Label for the payment terms field',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: 'Button text to save customer',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: 'Button text to cancel action',
      args: [],
    );
  }

  /// `Success`
  String get success {
    return Intl.message(
      'Success',
      name: 'success',
      desc: 'Title for success dialogs or snackbars',
      args: [],
    );
  }

  /// `Customer added successfully!`
  String get customer_added {
    return Intl.message(
      'Customer added successfully!',
      name: 'customer_added',
      desc: 'Message shown when a customer is added successfully',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc: 'Title for error dialogs or snackbars',
      args: [],
    );
  }

  /// `{field} is required`
  String required_field(Object field) {
    return Intl.message(
      '$field is required',
      name: 'required_field',
      desc: 'Validation message for required fields',
      args: [field],
    );
  }

  /// `{field} must be a valid number`
  String invalid_number(Object field) {
    return Intl.message(
      '$field must be a valid number',
      name: 'invalid_number',
      desc: 'Validation message for invalid number fields',
      args: [field],
    );
  }

  /// `Please fill all required fields`
  String get please_fill_fields {
    return Intl.message(
      'Please fill all required fields',
      name: 'please_fill_fields',
      desc: 'Message prompting user to fill all required fields',
      args: [],
    );
  }

  /// `No API token found. Please log in.`
  String get no_token {
    return Intl.message(
      'No API token found. Please log in.',
      name: 'no_token',
      desc: 'Error message when API token is missing',
      args: [],
    );
  }

  /// `Failed to add customer: {message}`
  String api_error(Object message) {
    return Intl.message(
      'Failed to add customer: $message',
      name: 'api_error',
      desc: 'Error message when API returns an error while adding customer',
      args: [message],
    );
  }

  /// `Connection error: {error}`
  String connection_error(Object error) {
    return Intl.message(
      'Connection error: $error',
      name: 'connection_error',
      desc: 'Error message for connection errors',
      args: [error],
    );
  }

  /// `This field is required`
  String get field_required {
    return Intl.message(
      'This field is required',
      name: 'field_required',
      desc: 'Validation message shown when a field is required',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
