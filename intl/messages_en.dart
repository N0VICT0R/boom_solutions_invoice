// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(message) => "Failed to add customer: ${message}";

  static String m1(error) => "Connection error: ${error}";

  static String m2(field) => "${field} must be a valid number";

  static String m3(error) => "Network error: ${error}";

  static String m4(percentage) => "${percentage}% of target";

  static String m5(count) => "${count} partners";

  static String m6(field) => "${field} is required";

  static String m7(period) => "Selected: ${period}";

  static String m8(statusCode) => "Server error: HTTP ${statusCode}";

  static String m9(sign, diff) => "vs Average: ${sign}${diff}%";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "addCustomer": MessageLookupByLibrary.simpleMessage("Add customer"),
    "add_customer": MessageLookupByLibrary.simpleMessage("Add Customer"),
    "address": MessageLookupByLibrary.simpleMessage("Address"),
    "addressLabel": MessageLookupByLibrary.simpleMessage("Address"),
    "apiToken": MessageLookupByLibrary.simpleMessage("API Token"),
    "api_error": m0,
    "authenticationError": MessageLookupByLibrary.simpleMessage(
      "Authentication error.",
    ),
    "billion": MessageLookupByLibrary.simpleMessage("B"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cancelButton": MessageLookupByLibrary.simpleMessage("Cancel"),
    "checkConnection": MessageLookupByLibrary.simpleMessage(
      "Check your internet connection or try again later.",
    ),
    "checkInternetConnection": MessageLookupByLibrary.simpleMessage(
      "Check your internet connection or try again later.",
    ),
    "city": MessageLookupByLibrary.simpleMessage("City"),
    "cityLabel": MessageLookupByLibrary.simpleMessage("City"),
    "collections": MessageLookupByLibrary.simpleMessage("Collections"),
    "completedToday": MessageLookupByLibrary.simpleMessage("Completed today"),
    "connection_error": m1,
    "contactAdmin": MessageLookupByLibrary.simpleMessage(
      "Contact your system administrator for a new API token.",
    ),
    "country": MessageLookupByLibrary.simpleMessage("Country"),
    "countryLabel": MessageLookupByLibrary.simpleMessage("Country"),
    "customer_added": MessageLookupByLibrary.simpleMessage(
      "Customer added successfully!",
    ),
    "customers": MessageLookupByLibrary.simpleMessage("Customers"),
    "customersTitle": MessageLookupByLibrary.simpleMessage("Customers"),
    "darkModeTitle": MessageLookupByLibrary.simpleMessage("Dark Mode"),
    "dashboard": MessageLookupByLibrary.simpleMessage("Dashboard"),
    "day": MessageLookupByLibrary.simpleMessage("Day"),
    "defaultUserEmail": MessageLookupByLibrary.simpleMessage("No email"),
    "defaultUserInitial": MessageLookupByLibrary.simpleMessage("U"),
    "defaultUserName": MessageLookupByLibrary.simpleMessage("User"),
    "editProfileTitle": MessageLookupByLibrary.simpleMessage("Edit Profile"),
    "emailLabel": MessageLookupByLibrary.simpleMessage("Email"),
    "enterYourEmail": MessageLookupByLibrary.simpleMessage("Enter your email"),
    "error": MessageLookupByLibrary.simpleMessage("Error"),
    "failedToLoadCustomers": MessageLookupByLibrary.simpleMessage(
      "Failed to load customers",
    ),
    "field_required": MessageLookupByLibrary.simpleMessage(
      "This field is required",
    ),
    "forgotApiToken": MessageLookupByLibrary.simpleMessage(
      "Forgot your API Token?",
    ),
    "inspirationalQuotes": MessageLookupByLibrary.simpleMessage(
      "Success is not the absence of obstacles, but the courage to push through them.",
    ),
    "invalid_number": m2,
    "loginLabel": MessageLookupByLibrary.simpleMessage("Login"),
    "logoutButton": MessageLookupByLibrary.simpleMessage("Logout"),
    "logoutDialogMessage": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to logout?",
    ),
    "logoutDialogTitle": MessageLookupByLibrary.simpleMessage("Logout"),
    "logoutErrorMessage": MessageLookupByLibrary.simpleMessage(
      "Failed to complete logout",
    ),
    "logoutErrorTitle": MessageLookupByLibrary.simpleMessage("Logout Error"),
    "logoutSuccessMessage": MessageLookupByLibrary.simpleMessage(
      "You have been successfully logged out",
    ),
    "logoutSuccessTitle": MessageLookupByLibrary.simpleMessage("Logged Out"),
    "logoutTitle": MessageLookupByLibrary.simpleMessage("Logout"),
    "million": MessageLookupByLibrary.simpleMessage("M"),
    "mobile": MessageLookupByLibrary.simpleMessage("Mobile"),
    "mobileLabel": MessageLookupByLibrary.simpleMessage("Mobile"),
    "month": MessageLookupByLibrary.simpleMessage("Month"),
    "name": MessageLookupByLibrary.simpleMessage("Name"),
    "nearbyCustomers": MessageLookupByLibrary.simpleMessage("Nearby Customers"),
    "networkError": m3,
    "newCustomers": MessageLookupByLibrary.simpleMessage("New Customers"),
    "noCustomersFound": MessageLookupByLibrary.simpleMessage(
      "No customers found",
    ),
    "noDataAvailable": MessageLookupByLibrary.simpleMessage(
      "No data available",
    ),
    "noNotesYet": MessageLookupByLibrary.simpleMessage("No notes yet"),
    "noUserData": MessageLookupByLibrary.simpleMessage(
      "No user data available",
    ),
    "no_token": MessageLookupByLibrary.simpleMessage(
      "No API token found. Please log in.",
    ),
    "notes": MessageLookupByLibrary.simpleMessage("Notes"),
    "notificationsTitle": MessageLookupByLibrary.simpleMessage("Notifications"),
    "odoo": MessageLookupByLibrary.simpleMessage("Odoo"),
    "ofTarget": m4,
    "partnerIdLabel": MessageLookupByLibrary.simpleMessage("Partner ID"),
    "partners": m5,
    "payment_terms": MessageLookupByLibrary.simpleMessage("Payment Terms"),
    "phone": MessageLookupByLibrary.simpleMessage("Phone"),
    "phoneLabel": MessageLookupByLibrary.simpleMessage("Phone"),
    "pleaseLoginAgain": MessageLookupByLibrary.simpleMessage(
      "Please log in again.",
    ),
    "please_fill_fields": MessageLookupByLibrary.simpleMessage(
      "Please fill all required fields",
    ),
    "profileTitle": MessageLookupByLibrary.simpleMessage("Profile"),
    "quarter": MessageLookupByLibrary.simpleMessage("Quarter"),
    "quickActions": MessageLookupByLibrary.simpleMessage("Quick Actions"),
    "required_field": m6,
    "retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "retryButton": MessageLookupByLibrary.simpleMessage("Retry"),
    "salesOverview": MessageLookupByLibrary.simpleMessage("Sales Overview"),
    "salesTarget": MessageLookupByLibrary.simpleMessage("Sales Target"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "searchCustomersHint": MessageLookupByLibrary.simpleMessage(
      "Search customers...",
    ),
    "securityTitle": MessageLookupByLibrary.simpleMessage("Security"),
    "selected": m7,
    "serverError": m8,
    "sessionExpired": MessageLookupByLibrary.simpleMessage(
      "Session expired. Please log in again.",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "settingsTitle": MessageLookupByLibrary.simpleMessage("Settings"),
    "signIn": MessageLookupByLibrary.simpleMessage("Sign In"),
    "sortByName": MessageLookupByLibrary.simpleMessage("Sort by name"),
    "state": MessageLookupByLibrary.simpleMessage("State"),
    "stateLabel": MessageLookupByLibrary.simpleMessage("State"),
    "stock": MessageLookupByLibrary.simpleMessage("Stock"),
    "storeIdLabel": MessageLookupByLibrary.simpleMessage("Store ID"),
    "storeLabel": MessageLookupByLibrary.simpleMessage("Store"),
    "success": MessageLookupByLibrary.simpleMessage("Success"),
    "thisMonth": MessageLookupByLibrary.simpleMessage("This month"),
    "thousand": MessageLookupByLibrary.simpleMessage("k"),
    "toggleTheme": MessageLookupByLibrary.simpleMessage("Toggle theme"),
    "trillion": MessageLookupByLibrary.simpleMessage("T"),
    "visits": MessageLookupByLibrary.simpleMessage("Visits"),
    "vsAverage": m9,
    "welcomeBack": MessageLookupByLibrary.simpleMessage("Welcome Back"),
    "year": MessageLookupByLibrary.simpleMessage("Year"),
    "youAreOffline": MessageLookupByLibrary.simpleMessage("You Are Offline"),
  };
}
