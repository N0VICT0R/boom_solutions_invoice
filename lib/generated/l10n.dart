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
    return Intl.message(
      'Notes',
      name: 'notes',
      desc: 'Label for notes section',
      args: [],
    );
  }

  /// `No notes yet`
  String get noNotesYet {
    return Intl.message(
      'No notes yet',
      name: 'noNotesYet',
      desc: 'Message shown when there are no notes',
      args: [],
    );
  }

  /// `Success is not the absence of obstacles, but the courage to push through them.`
  String get inspirationalQuotes {
    return Intl.message(
      'Success is not the absence of obstacles, but the courage to push through them.',
      name: 'inspirationalQuotes',
      desc: 'Motivational message shown in the app',
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
      desc: 'Label for cancel button',
      args: [],
    );
  }

  /// `Success`
  String get success {
    return Intl.message(
      'Success',
      name: 'success',
      desc: 'Success status text',
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
  String get token_missing {
    return Intl.message(
      'No API token found. Please log in.',
      name: 'token_missing',
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
  String connection_error(String error) {
    return Intl.message(
      'Connection error: $error',
      name: 'connection_error',
      desc: 'Error message for connection errors',
      args: [error],
    );
  }

  /// `Customer`
  String get customer {
    return Intl.message(
      'Customer',
      name: 'customer',
      desc: 'Label for customer',
      args: [],
    );
  }

  /// `Location services are disabled. Please enable them.`
  String get location_services_disabled {
    return Intl.message(
      'Location services are disabled. Please enable them.',
      name: 'location_services_disabled',
      desc: 'Message shown when location services are disabled',
      args: [],
    );
  }

  /// `Location permissions denied. Please allow location access in settings.`
  String get location_permissions_denied {
    return Intl.message(
      'Location permissions denied. Please allow location access in settings.',
      name: 'location_permissions_denied',
      desc: 'Message shown when location permissions are denied',
      args: [],
    );
  }

  /// `Location permissions are permanently denied. Please enable them in settings.`
  String get location_permissions_denied_forever {
    return Intl.message(
      'Location permissions are permanently denied. Please enable them in settings.',
      name: 'location_permissions_denied_forever',
      desc: 'Message shown when location permissions are permanently denied',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc: 'General error text',
      args: [],
    );
  }

  /// `Error getting location: {message}`
  String error_getting_location(Object message) {
    return Intl.message(
      'Error getting location: $message',
      name: 'error_getting_location',
      desc: 'Error message when unable to get location',
      args: [message],
    );
  }

  /// `Error updating location`
  String get error_updating_location {
    return Intl.message(
      'Error updating location',
      name: 'error_updating_location',
      desc: 'Error message when unable to update location',
      args: [],
    );
  }

  /// `API token is missing. Please log in again.`
  String get no_token {
    return Intl.message(
      'API token is missing. Please log in again.',
      name: 'no_token',
      desc: 'Error message when API token is missing',
      args: [],
    );
  }

  /// `Authentication failed: Invalid or expired token. Please log in again.`
  String get auth_failed {
    return Intl.message(
      'Authentication failed: Invalid or expired token. Please log in again.',
      name: 'auth_failed',
      desc: 'Error message for authentication failure',
      args: [],
    );
  }

  /// `Too many requests: Please wait before trying again.`
  String get too_many_requests {
    return Intl.message(
      'Too many requests: Please wait before trying again.',
      name: 'too_many_requests',
      desc: 'Error message for rate limiting',
      args: [],
    );
  }

  /// `Failed to update location`
  String get failed_to_update_location {
    return Intl.message(
      'Failed to update location',
      name: 'failed_to_update_location',
      desc: 'Error message when location update fails',
      args: [],
    );
  }

  /// `Partner with ID`
  String get partner_not_found {
    return Intl.message(
      'Partner with ID',
      name: 'partner_not_found',
      desc: 'Error message when partner is not found',
      args: [],
    );
  }

  /// `No valid coordinates for partner ID`
  String get no_valid_coordinates {
    return Intl.message(
      'No valid coordinates for partner ID',
      name: 'no_valid_coordinates',
      desc: 'Error message when coordinates are invalid',
      args: [],
    );
  }

  /// `No partners found`
  String get no_partners_found {
    return Intl.message(
      'No partners found',
      name: 'no_partners_found',
      desc: 'Message shown when no partners are found',
      args: [],
    );
  }

  /// `Failed to fetch partner data`
  String get failed_to_fetch_partner_data {
    return Intl.message(
      'Failed to fetch partner data',
      name: 'failed_to_fetch_partner_data',
      desc: 'Error message when partner data fetch fails',
      args: [],
    );
  }

  /// `Unnamed Product`
  String get unnamed_product {
    return Intl.message(
      'Unnamed Product',
      name: 'unnamed_product',
      desc: 'Default name for products without names',
      args: [],
    );
  }

  /// `No valid partnerId provided`
  String get no_valid_partner_id {
    return Intl.message(
      'No valid partnerId provided',
      name: 'no_valid_partner_id',
      desc: 'Error message for invalid partner ID',
      args: [],
    );
  }

  /// `Error: Invalid partner ID`
  String get invalid_partner_id {
    return Intl.message(
      'Error: Invalid partner ID',
      name: 'invalid_partner_id',
      desc: 'Error message for invalid partner ID format',
      args: [],
    );
  }

  /// `Please wait 30 seconds before updating again`
  String get wait_30_seconds {
    return Intl.message(
      'Please wait 30 seconds before updating again',
      name: 'wait_30_seconds',
      desc: 'Message for rate limiting cooldown',
      args: [],
    );
  }

  /// `No data available`
  String get no_data_available {
    return Intl.message(
      'No data available',
      name: 'no_data_available',
      desc: 'Message shown when no data is available',
      args: [],
    );
  }

  /// `Make Payment`
  String get make_payment {
    return Intl.message(
      'Make Payment',
      name: 'make_payment',
      desc: 'Label for payment action',
      args: [],
    );
  }

  /// `Product Distribution`
  String get product_distribution {
    return Intl.message(
      'Product Distribution',
      name: 'product_distribution',
      desc: 'Label for product distribution section',
      args: [],
    );
  }

  /// `Top Product`
  String get top_product {
    return Intl.message(
      'Top Product',
      name: 'top_product',
      desc: 'Label for top product',
      args: [],
    );
  }

  /// `N/A`
  String get na {
    return Intl.message(
      'N/A',
      name: 'na',
      desc: 'Abbreviation for not applicable',
      args: [],
    );
  }

  /// `Total`
  String get total {
    return Intl.message(
      'Total',
      name: 'total',
      desc: 'Label for total amount',
      args: [],
    );
  }

  /// `Percentage`
  String get percentage {
    return Intl.message(
      'Percentage',
      name: 'percentage',
      desc: 'Label for percentage values',
      args: [],
    );
  }

  /// `Amount`
  String get amount {
    return Intl.message(
      'Amount',
      name: 'amount',
      desc: 'Label for monetary amounts',
      args: [],
    );
  }

  /// `Share of Total`
  String get share_of_total {
    return Intl.message(
      'Share of Total',
      name: 'share_of_total',
      desc: 'Label for share of total values',
      args: [],
    );
  }

  /// `No Data`
  String get no_data {
    return Intl.message(
      'No Data',
      name: 'no_data',
      desc: 'Message when no data is present',
      args: [],
    );
  }

  /// `BALANCE`
  String get balance {
    return Intl.message(
      'BALANCE',
      name: 'balance',
      desc: 'Label for balance amounts',
      args: [],
    );
  }

  /// `Dues`
  String get dues {
    return Intl.message(
      'Dues',
      name: 'dues',
      desc: 'Label for due amounts',
      args: [],
    );
  }

  /// `AOV`
  String get aov {
    return Intl.message(
      'AOV',
      name: 'aov',
      desc: 'Label for Average Order Value',
      args: [],
    );
  }

  /// `OCT`
  String get oct {
    return Intl.message(
      'OCT',
      name: 'oct',
      desc: 'Label for October',
      args: [],
    );
  }

  /// `Oldest Due`
  String get oldest_due {
    return Intl.message(
      'Oldest Due',
      name: 'oldest_due',
      desc: 'Label for oldest due amount',
      args: [],
    );
  }

  /// `Last Purchase`
  String get last_purchase {
    return Intl.message(
      'Last Purchase',
      name: 'last_purchase',
      desc: 'Label for last purchase date',
      args: [],
    );
  }

  /// `days`
  String get days {
    return Intl.message(
      'days',
      name: 'days',
      desc: 'Label for number of days',
      args: [],
    );
  }

  /// `Details`
  String get details {
    return Intl.message(
      'Details',
      name: 'details',
      desc: 'Label for details section',
      args: [],
    );
  }

  /// `Statement of Account`
  String get statement_of_account {
    return Intl.message(
      'Statement of Account',
      name: 'statement_of_account',
      desc: 'Label for account statement',
      args: [],
    );
  }

  /// `View transaction history`
  String get view_transaction_history {
    return Intl.message(
      'View transaction history',
      name: 'view_transaction_history',
      desc: 'Label for transaction history action',
      args: [],
    );
  }

  /// `Visit Information`
  String get visit_information {
    return Intl.message(
      'Visit Information',
      name: 'visit_information',
      desc: 'Label for visit information section',
      args: [],
    );
  }

  /// `View customer visit patterns`
  String get view_customer_visit_patterns {
    return Intl.message(
      'View customer visit patterns',
      name: 'view_customer_visit_patterns',
      desc: 'Label for visit patterns action',
      args: [],
    );
  }

  /// `Select Start Date`
  String get select_start_date {
    return Intl.message(
      'Select Start Date',
      name: 'select_start_date',
      desc: 'Label for start date selection',
      args: [],
    );
  }

  /// `Select End Date`
  String get select_end_date {
    return Intl.message(
      'Select End Date',
      name: 'select_end_date',
      desc: 'Label for end date selection',
      args: [],
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

  /// `Cash`
  String get cash {
    return Intl.message(
      'Cash',
      name: 'cash',
      desc: 'Label for cash payment method',
      args: [],
    );
  }

  /// `Card`
  String get card {
    return Intl.message(
      'Card',
      name: 'card',
      desc: 'Label for card payment method',
      args: [],
    );
  }

  /// `Payment Method`
  String get payment_method {
    return Intl.message(
      'Payment Method',
      name: 'payment_method',
      desc: 'Label for payment method selection',
      args: [],
    );
  }

  /// `Please select a payment method`
  String get please_select_payment_method {
    return Intl.message(
      'Please select a payment method',
      name: 'please_select_payment_method',
      desc: 'Message asking user to select payment method',
      args: [],
    );
  }

  /// `Pay All`
  String get pay_all {
    return Intl.message(
      'Pay All',
      name: 'pay_all',
      desc: 'Label for paying full amount',
      args: [],
    );
  }

  /// `INVOICE DATE`
  String get invoice_date {
    return Intl.message(
      'INVOICE DATE',
      name: 'invoice_date',
      desc: 'Label for invoice date',
      args: [],
    );
  }

  /// `DUE DATE`
  String get due_date {
    return Intl.message(
      'DUE DATE',
      name: 'due_date',
      desc: 'Label for due date',
      args: [],
    );
  }

  /// `PENDING`
  String get pending {
    return Intl.message(
      'PENDING',
      name: 'pending',
      desc: 'Status label for pending payments',
      args: [],
    );
  }

  /// `Payment amount`
  String get payment_amount {
    return Intl.message(
      'Payment amount',
      name: 'payment_amount',
      desc: 'Label for payment amount field',
      args: [],
    );
  }

  /// `Max`
  String get max {
    return Intl.message(
      'Max',
      name: 'max',
      desc: 'Label for maximum amount',
      args: [],
    );
  }

  /// `Due Now`
  String get due_now {
    return Intl.message(
      'Due Now',
      name: 'due_now',
      desc: 'Label for amount due immediately',
      args: [],
    );
  }

  /// `Due Later`
  String get due_later {
    return Intl.message(
      'Due Later',
      name: 'due_later',
      desc: 'Label for amount due in future',
      args: [],
    );
  }

  /// `An error occurred`
  String get an_error_occurred {
    return Intl.message(
      'An error occurred',
      name: 'an_error_occurred',
      desc: 'Generic error description',
      args: [],
    );
  }

  /// `Authentication token not found`
  String get auth_token_not_found {
    return Intl.message(
      'Authentication token not found',
      name: 'auth_token_not_found',
      desc: 'Error message for missing authentication',
      args: [],
    );
  }

  /// `Please enter valid amounts for at least one invoice`
  String get please_enter_valid_amounts {
    return Intl.message(
      'Please enter valid amounts for at least one invoice',
      name: 'please_enter_valid_amounts',
      desc: 'Validation message for invoice amounts',
      args: [],
    );
  }

  /// `Payment for`
  String get payment_for {
    return Intl.message(
      'Payment for',
      name: 'payment_for',
      desc: 'Label for payment description',
      args: [],
    );
  }

  /// `invoices`
  String get invoices {
    return Intl.message(
      'invoices',
      name: 'invoices',
      desc: 'Label for invoice items',
      args: [],
    );
  }

  /// `Payment failed`
  String get payment_failed {
    return Intl.message(
      'Payment failed',
      name: 'payment_failed',
      desc: 'Error message for failed payments',
      args: [],
    );
  }

  /// `Location updated successfully`
  String get location_updated_successfully {
    return Intl.message(
      'Location updated successfully',
      name: 'location_updated_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Partner Visits`
  String get partner_visits {
    return Intl.message(
      'Partner Visits',
      name: 'partner_visits',
      desc: 'Label for partner visits section',
      args: [],
    );
  }

  /// `Failed to load visits`
  String get failed_to_load_visits {
    return Intl.message(
      'Failed to load visits',
      name: 'failed_to_load_visits',
      desc: 'Error message when visits cannot be loaded',
      args: [],
    );
  }

  /// `Error fetching visits`
  String get error_fetching_visits {
    return Intl.message(
      'Error fetching visits',
      name: 'error_fetching_visits',
      desc: 'Error message when fetching visits fails',
      args: [],
    );
  }

  /// `Partner Details`
  String get partner_details {
    return Intl.message(
      'Partner Details',
      name: 'partner_details',
      desc: 'Label for partner details section',
      args: [],
    );
  }

  /// `Refresh`
  String get refresh {
    return Intl.message(
      'Refresh',
      name: 'refresh',
      desc: 'Label for refresh action',
      args: [],
    );
  }

  /// `Schedule Visit`
  String get schedule_visit {
    return Intl.message(
      'Schedule Visit',
      name: 'schedule_visit',
      desc: 'Label for scheduling visit action',
      args: [],
    );
  }

  /// `Visits History`
  String get visits_history {
    return Intl.message(
      'Visits History',
      name: 'visits_history',
      desc: 'Label for visits history section',
      args: [],
    );
  }

  /// `Newest First`
  String get newest_first {
    return Intl.message(
      'Newest First',
      name: 'newest_first',
      desc: 'Label for newest first sort option',
      args: [],
    );
  }

  /// `Oldest First`
  String get oldest_first {
    return Intl.message(
      'Oldest First',
      name: 'oldest_first',
      desc: 'Label for oldest first sort option',
      args: [],
    );
  }

  /// `Filter by Date`
  String get filter_by_date {
    return Intl.message(
      'Filter by Date',
      name: 'filter_by_date',
      desc: 'Label for date filter option',
      args: [],
    );
  }

  /// `Filtered by`
  String get filtered_by {
    return Intl.message(
      'Filtered by',
      name: 'filtered_by',
      desc: 'Label showing current filter',
      args: [],
    );
  }

  /// `Select Date`
  String get select_date {
    return Intl.message(
      'Select Date',
      name: 'select_date',
      desc: 'Label for date selection',
      args: [],
    );
  }

  /// `No visits available`
  String get no_visits_available {
    return Intl.message(
      'No visits available',
      name: 'no_visits_available',
      desc: 'Message when no visits are available',
      args: [],
    );
  }

  /// `No notes`
  String get no_notes {
    return Intl.message(
      'No notes',
      name: 'no_notes',
      desc: 'Message when no notes are available',
      args: [],
    );
  }

  /// `Customer Check-in`
  String get app_title {
    return Intl.message(
      'Customer Check-in',
      name: 'app_title',
      desc: '',
      args: [],
    );
  }

  /// `Customer Check-in`
  String get customer_check_in {
    return Intl.message(
      'Customer Check-in',
      name: 'customer_check_in',
      desc: '',
      args: [],
    );
  }

  /// `Add visit notes...`
  String get add_visit_notes {
    return Intl.message(
      'Add visit notes...',
      name: 'add_visit_notes',
      desc: '',
      args: [],
    );
  }

  /// `CHECK IN`
  String get check_in {
    return Intl.message('CHECK IN', name: 'check_in', desc: '', args: []);
  }

  /// `Location not available. Please try again.`
  String get location_not_available {
    return Intl.message(
      'Location not available. Please try again.',
      name: 'location_not_available',
      desc: '',
      args: [],
    );
  }

  /// `Too Far Away`
  String get too_far_away {
    return Intl.message(
      'Too Far Away',
      name: 'too_far_away',
      desc: '',
      args: [],
    );
  }

  /// `You need to be closer to the customer (within 10 km) to check in.`
  String get distance_exceeded {
    return Intl.message(
      'You need to be closer to the customer (within 10 km) to check in.',
      name: 'distance_exceeded',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: 'Label for OK button',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message('Close', name: 'close', desc: '', args: []);
  }

  /// `Failed`
  String get failed {
    return Intl.message(
      'Failed',
      name: 'failed',
      desc: 'Failed status text',
      args: [],
    );
  }

  /// `No message provided`
  String get no_message_provided {
    return Intl.message(
      'No message provided',
      name: 'no_message_provided',
      desc: '',
      args: [],
    );
  }

  /// `Visit Details`
  String get visit_details {
    return Intl.message(
      'Visit Details',
      name: 'visit_details',
      desc: '',
      args: [],
    );
  }

  /// `Processing check-in...`
  String get processing_check_in {
    return Intl.message(
      'Processing check-in...',
      name: 'processing_check_in',
      desc: '',
      args: [],
    );
  }

  /// `Calculating distance...`
  String get calculating_distance {
    return Intl.message(
      'Calculating distance...',
      name: 'calculating_distance',
      desc: '',
      args: [],
    );
  }

  /// `You are within range to check in`
  String get within_range {
    return Intl.message(
      'You are within range to check in',
      name: 'within_range',
      desc: '',
      args: [],
    );
  }

  /// `You need to be within 10 km of the customer`
  String get out_of_range {
    return Intl.message(
      'You need to be within 10 km of the customer',
      name: 'out_of_range',
      desc: '',
      args: [],
    );
  }

  /// `Location permission denied.`
  String get location_permission_denied {
    return Intl.message(
      'Location permission denied.',
      name: 'location_permission_denied',
      desc: '',
      args: [],
    );
  }

  /// `Location permissions permanently denied. Please enable in settings.`
  String get location_permission_permanent_denied {
    return Intl.message(
      'Location permissions permanently denied. Please enable in settings.',
      name: 'location_permission_permanent_denied',
      desc: '',
      args: [],
    );
  }

  /// `Customer location not available in the response.`
  String get customer_location_not_available {
    return Intl.message(
      'Customer location not available in the response.',
      name: 'customer_location_not_available',
      desc: '',
      args: [],
    );
  }

  /// `Customer with ID {partnerId} not found.`
  String customer_not_found(Object partnerId) {
    return Intl.message(
      'Customer with ID $partnerId not found.',
      name: 'customer_not_found',
      desc: '',
      args: [partnerId],
    );
  }

  /// `Customer location data is invalid.`
  String get customer_location_invalid {
    return Intl.message(
      'Customer location data is invalid.',
      name: 'customer_location_invalid',
      desc: '',
      args: [],
    );
  }

  /// `Failed to fetch customer location.`
  String get fetch_customer_error {
    return Intl.message(
      'Failed to fetch customer location.',
      name: 'fetch_customer_error',
      desc: '',
      args: [],
    );
  }

  /// `Error fetching customer location.`
  String get error_fetch_customer {
    return Intl.message(
      'Error fetching customer location.',
      name: 'error_fetch_customer',
      desc: '',
      args: [],
    );
  }

  /// `Error: {message}`
  String submit_error(Object message) {
    return Intl.message(
      'Error: $message',
      name: 'submit_error',
      desc: '',
      args: [message],
    );
  }

  /// `Network error: {message}`
  String network_error(Object message) {
    return Intl.message(
      'Network error: $message',
      name: 'network_error',
      desc: '',
      args: [message],
    );
  }

  /// `Location services are disabled.`
  String get locationServicesDisabled {
    return Intl.message(
      'Location services are disabled.',
      name: 'locationServicesDisabled',
      desc: 'Error message when location services are turned off',
      args: [],
    );
  }

  /// `Location permission denied.`
  String get locationPermissionDenied {
    return Intl.message(
      'Location permission denied.',
      name: 'locationPermissionDenied',
      desc: 'Error message when location permission is denied',
      args: [],
    );
  }

  /// `Location permissions permanently denied.`
  String get locationPermissionsPermanentlyDenied {
    return Intl.message(
      'Location permissions permanently denied.',
      name: 'locationPermissionsPermanentlyDenied',
      desc: 'Error message when location permissions are permanently denied',
      args: [],
    );
  }

  /// `Location not available.`
  String get locationNotAvailable {
    return Intl.message(
      'Location not available.',
      name: 'locationNotAvailable',
      desc: 'Error message when location is not available',
      args: [],
    );
  }

  /// `Customer not found.`
  String get customerNotFound {
    return Intl.message(
      'Customer not found.',
      name: 'customerNotFound',
      desc: 'Error message when customer is not found',
      args: [],
    );
  }

  /// `Unknown Customer`
  String get unknownCustomer {
    return Intl.message(
      'Unknown Customer',
      name: 'unknownCustomer',
      desc: 'Label for unknown customer',
      args: [],
    );
  }

  /// `Failed to fetch customer location`
  String get failedToFetchCustomerLocation {
    return Intl.message(
      'Failed to fetch customer location',
      name: 'failedToFetchCustomerLocation',
      desc: 'Error message when unable to fetch customer location',
      args: [],
    );
  }

  /// `Visit Note`
  String get visitNote {
    return Intl.message(
      'Visit Note',
      name: 'visitNote',
      desc: 'Header title for visit note screen',
      args: [],
    );
  }

  /// `{distance} km`
  String distanceValue(String distance) {
    return Intl.message(
      '$distance km',
      name: 'distanceValue',
      desc: 'Distance value with km unit',
      args: [distance],
    );
  }

  /// `N/A`
  String get notAvailable {
    return Intl.message(
      'N/A',
      name: 'notAvailable',
      desc: 'Text shown when data is not available',
      args: [],
    );
  }

  /// `Add notes...`
  String get addNotes {
    return Intl.message(
      'Add notes...',
      name: 'addNotes',
      desc: 'Hint text for notes input field',
      args: [],
    );
  }

  /// `Check In`
  String get checkIn {
    return Intl.message(
      'Check In',
      name: 'checkIn',
      desc: 'Label for check-in button',
      args: [],
    );
  }

  /// `Distance Warning`
  String get distanceWarning {
    return Intl.message(
      'Distance Warning',
      name: 'distanceWarning',
      desc: 'Title for distance warning dialog',
      args: [],
    );
  }

  /// `You are more than 10 km away. Proceed with check-in?`
  String get distanceWarningMessage {
    return Intl.message(
      'You are more than 10 km away. Proceed with check-in?',
      name: 'distanceWarningMessage',
      desc: 'Warning message when user is far from customer location',
      args: [],
    );
  }

  /// `Proceed`
  String get proceed {
    return Intl.message(
      'Proceed',
      name: 'proceed',
      desc: 'Label for proceed button',
      args: [],
    );
  }

  /// `No message provided`
  String get noMessageProvided {
    return Intl.message(
      'No message provided',
      name: 'noMessageProvided',
      desc: 'Text shown when no message is provided',
      args: [],
    );
  }

  /// `Visit Details:`
  String get visitDetails {
    return Intl.message(
      'Visit Details:',
      name: 'visitDetails',
      desc: 'Header for visit details section',
      args: [],
    );
  }

  /// `Partner`
  String get partner {
    return Intl.message(
      'Partner',
      name: 'partner',
      desc: 'Label for partner field',
      args: [],
    );
  }

  /// `DATE`
  String get date {
    return Intl.message(
      'DATE',
      name: 'date',
      desc: 'Label for date field',
      args: [],
    );
  }

  /// `User`
  String get user {
    return Intl.message(
      'User',
      name: 'user',
      desc: 'Label for user field',
      args: [],
    );
  }

  /// `Switch Language`
  String get switch_language {
    return Intl.message(
      'Switch Language',
      name: 'switch_language',
      desc: '',
      args: [],
    );
  }

  /// `Change Language To`
  String get languageTitle {
    return Intl.message(
      'Change Language To',
      name: 'languageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Search inventory...`
  String get searchInventory {
    return Intl.message(
      'Search inventory...',
      name: 'searchInventory',
      desc: '',
      args: [],
    );
  }

  /// `Inventory`
  String get inventory {
    return Intl.message('Inventory', name: 'inventory', desc: '', args: []);
  }

  /// `Location`
  String get location {
    return Intl.message('Location', name: 'location', desc: '', args: []);
  }

  /// `Items`
  String get items {
    return Intl.message('Items', name: 'items', desc: '', args: []);
  }

  /// `PRODUCT`
  String get product {
    return Intl.message('PRODUCT', name: 'product', desc: '', args: []);
  }

  /// `QTY`
  String get quantity {
    return Intl.message('QTY', name: 'quantity', desc: '', args: []);
  }

  /// `AVAILABLE`
  String get available {
    return Intl.message('AVAILABLE', name: 'available', desc: '', args: []);
  }

  /// `PRICE`
  String get price {
    return Intl.message('PRICE', name: 'price', desc: '', args: []);
  }

  /// `No inventory items found`
  String get noInventoryItems {
    return Intl.message(
      'No inventory items found',
      name: 'noInventoryItems',
      desc: '',
      args: [],
    );
  }

  /// `No matching items found`
  String get noMatchingItems {
    return Intl.message(
      'No matching items found',
      name: 'noMatchingItems',
      desc: '',
      args: [],
    );
  }

  /// `Error Loading Data`
  String get errorLoadingDataTitle {
    return Intl.message(
      'Error Loading Data',
      name: 'errorLoadingDataTitle',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load inventory data. Status: {status}`
  String errorLoadingData(Object status) {
    return Intl.message(
      'Failed to load inventory data. Status: $status',
      name: 'errorLoadingData',
      desc: 'Error message for failed data loading with status code',
      args: [status],
    );
  }

  /// `Error: {message}`
  String errorGeneric(Object message) {
    return Intl.message(
      'Error: $message',
      name: 'errorGeneric',
      desc: 'Generic error message with error details',
      args: [message],
    );
  }

  /// `Selected: {name}`
  String selectedProduct(Object name) {
    return Intl.message(
      'Selected: $name',
      name: 'selectedProduct',
      desc: 'Message shown when a product is selected',
      args: [name],
    );
  }

  /// `Partners Map`
  String get appTitle {
    return Intl.message('Partners Map', name: 'appTitle', desc: '', args: []);
  }

  /// `No partners found.`
  String get noPartnersFound {
    return Intl.message(
      'No partners found.',
      name: 'noPartnersFound',
      desc: '',
      args: [],
    );
  }

  /// `Statement Summary`
  String get statementSummary {
    return Intl.message(
      'Statement Summary',
      name: 'statementSummary',
      desc: '',
      args: [],
    );
  }

  /// `Transactions`
  String get transactions {
    return Intl.message(
      'Transactions',
      name: 'transactions',
      desc: '',
      args: [],
    );
  }

  /// `Date Range`
  String get dateRange {
    return Intl.message('Date Range', name: 'dateRange', desc: '', args: []);
  }

  /// `Currency`
  String get currency {
    return Intl.message('Currency', name: 'currency', desc: '', args: []);
  }

  /// `Ending Balance`
  String get endingBalance {
    return Intl.message(
      'Ending Balance',
      name: 'endingBalance',
      desc: '',
      args: [],
    );
  }

  /// `DEBIT`
  String get debit {
    return Intl.message('DEBIT', name: 'debit', desc: '', args: []);
  }

  /// `CREDIT`
  String get credit {
    return Intl.message('CREDIT', name: 'credit', desc: '', args: []);
  }

  /// `Partners Map`
  String get partnersMap {
    return Intl.message(
      'Partners Map',
      name: 'partnersMap',
      desc: '',
      args: [],
    );
  }

  /// `Reference`
  String get reference {
    return Intl.message('Reference', name: 'reference', desc: '', args: []);
  }

  /// `You haven't sold anything yet.`
  String get noSalesInThisTime {
    return Intl.message(
      'You haven\'t sold anything yet.',
      name: 'noSalesInThisTime',
      desc: '',
      args: [],
    );
  }

  /// `PDF Viewer`
  String get pdfViewerTitle {
    return Intl.message(
      'PDF Viewer',
      name: 'pdfViewerTitle',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load PDF`
  String get failedToLoadPdf {
    return Intl.message(
      'Failed to load PDF',
      name: 'failedToLoadPdf',
      desc: '',
      args: [],
    );
  }

  /// `Invalid or empty file`
  String get invalidOrEmptyFile {
    return Intl.message(
      'Invalid or empty file',
      name: 'invalidOrEmptyFile',
      desc: '',
      args: [],
    );
  }

  /// `PDF file is too small or corrupted.`
  String get pdfFileTooSmall {
    return Intl.message(
      'PDF file is too small or corrupted.',
      name: 'pdfFileTooSmall',
      desc: '',
      args: [],
    );
  }

  /// `PDF file does not exist.`
  String get pdfFileNotFound {
    return Intl.message(
      'PDF file does not exist.',
      name: 'pdfFileNotFound',
      desc: '',
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
