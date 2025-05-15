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
    "amount": MessageLookupByLibrary.simpleMessage("Amount"),
    "an_error_occurred": MessageLookupByLibrary.simpleMessage(
      "An error occurred",
    ),
    "aov": MessageLookupByLibrary.simpleMessage("AOV"),
    "apiToken": MessageLookupByLibrary.simpleMessage("API Token"),
    "api_error": m0,
    "auth_failed": MessageLookupByLibrary.simpleMessage(
      "Authentication failed: Invalid or expired token. Please log in again.",
    ),
    "auth_token_not_found": MessageLookupByLibrary.simpleMessage(
      "Authentication token not found",
    ),
    "authenticationError": MessageLookupByLibrary.simpleMessage(
      "Authentication error.",
    ),
    "balance": MessageLookupByLibrary.simpleMessage("Balance"),
    "billion": MessageLookupByLibrary.simpleMessage("B"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cancelButton": MessageLookupByLibrary.simpleMessage("Cancel"),
    "card": MessageLookupByLibrary.simpleMessage("Card"),
    "cash": MessageLookupByLibrary.simpleMessage("Cash"),
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
    "customer": MessageLookupByLibrary.simpleMessage("Customer"),
    "customer_added": MessageLookupByLibrary.simpleMessage(
      "Customer added successfully!",
    ),
    "customers": MessageLookupByLibrary.simpleMessage("Customers"),
    "customersTitle": MessageLookupByLibrary.simpleMessage("Customers"),
    "darkModeTitle": MessageLookupByLibrary.simpleMessage("Dark Mode"),
    "dashboard": MessageLookupByLibrary.simpleMessage("Dashboard"),
    "day": MessageLookupByLibrary.simpleMessage("Day"),
    "days": MessageLookupByLibrary.simpleMessage("days"),
    "defaultUserEmail": MessageLookupByLibrary.simpleMessage("No email"),
    "defaultUserInitial": MessageLookupByLibrary.simpleMessage("U"),
    "defaultUserName": MessageLookupByLibrary.simpleMessage("User"),
    "details": MessageLookupByLibrary.simpleMessage("Details"),
    "due_date": MessageLookupByLibrary.simpleMessage("DUE DATE"),
    "due_later": MessageLookupByLibrary.simpleMessage("Due Later"),
    "due_now": MessageLookupByLibrary.simpleMessage("Due Now"),
    "dues": MessageLookupByLibrary.simpleMessage("Dues"),
    "editProfileTitle": MessageLookupByLibrary.simpleMessage("Edit Profile"),
    "emailLabel": MessageLookupByLibrary.simpleMessage("Email"),
    "enterYourEmail": MessageLookupByLibrary.simpleMessage("Enter your email"),
    "error": MessageLookupByLibrary.simpleMessage("Error"),
    "error_fetching_visits": MessageLookupByLibrary.simpleMessage(
      "Error fetching visits",
    ),
    "error_getting_location": MessageLookupByLibrary.simpleMessage(
      "Error getting current location",
    ),
    "error_updating_location": MessageLookupByLibrary.simpleMessage(
      "Error updating location",
    ),
    "failedToLoadCustomers": MessageLookupByLibrary.simpleMessage(
      "Failed to load customers",
    ),
    "failed_to_fetch_partner_data": MessageLookupByLibrary.simpleMessage(
      "Failed to fetch partner data",
    ),
    "failed_to_load_visits": MessageLookupByLibrary.simpleMessage(
      "Failed to load visits",
    ),
    "failed_to_update_location": MessageLookupByLibrary.simpleMessage(
      "Failed to update location",
    ),
    "field_required": MessageLookupByLibrary.simpleMessage(
      "This field is required",
    ),
    "filter_by_date": MessageLookupByLibrary.simpleMessage("Filter by Date"),
    "filtered_by": MessageLookupByLibrary.simpleMessage("Filtered by"),
    "forgotApiToken": MessageLookupByLibrary.simpleMessage(
      "Forgot your API Token?",
    ),
    "inspirationalQuotes": MessageLookupByLibrary.simpleMessage(
      "Success is not the absence of obstacles, but the courage to push through them.",
    ),
    "invalid_number": m2,
    "invalid_partner_id": MessageLookupByLibrary.simpleMessage(
      "Error: Invalid partner ID",
    ),
    "invoice_date": MessageLookupByLibrary.simpleMessage("INVOICE DATE"),
    "invoices": MessageLookupByLibrary.simpleMessage("invoices"),
    "last_purchase": MessageLookupByLibrary.simpleMessage("Last Purchase"),
    "location_permissions_denied": MessageLookupByLibrary.simpleMessage(
      "Location permissions denied. Please allow location access in settings.",
    ),
    "location_permissions_denied_forever": MessageLookupByLibrary.simpleMessage(
      "Location permissions are permanently denied. Please enable them in settings.",
    ),
    "location_services_disabled": MessageLookupByLibrary.simpleMessage(
      "Location services are disabled. Please enable them in settings.",
    ),
    "location_updated_successfully": MessageLookupByLibrary.simpleMessage(
      "Location updated successfully",
    ),
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
    "make_payment": MessageLookupByLibrary.simpleMessage("Make Payment"),
    "max": MessageLookupByLibrary.simpleMessage("Max"),
    "million": MessageLookupByLibrary.simpleMessage("M"),
    "mobile": MessageLookupByLibrary.simpleMessage("Mobile"),
    "mobileLabel": MessageLookupByLibrary.simpleMessage("Mobile"),
    "month": MessageLookupByLibrary.simpleMessage("Month"),
    "na": MessageLookupByLibrary.simpleMessage("N/A"),
    "name": MessageLookupByLibrary.simpleMessage("Name"),
    "nearbyCustomers": MessageLookupByLibrary.simpleMessage("Nearby Customers"),
    "networkError": m3,
    "newCustomers": MessageLookupByLibrary.simpleMessage("New Customers"),
    "newest_first": MessageLookupByLibrary.simpleMessage("Newest First"),
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
    "no_data": MessageLookupByLibrary.simpleMessage("No Data"),
    "no_data_available": MessageLookupByLibrary.simpleMessage(
      "No data available",
    ),
    "no_notes": MessageLookupByLibrary.simpleMessage("No notes"),
    "no_partners_found": MessageLookupByLibrary.simpleMessage(
      "No partners found",
    ),
    "no_token": MessageLookupByLibrary.simpleMessage(
      "API token is missing. Please log in again.",
    ),
    "no_valid_coordinates": MessageLookupByLibrary.simpleMessage(
      "No valid coordinates for partner ID",
    ),
    "no_valid_partner_id": MessageLookupByLibrary.simpleMessage(
      "No valid partnerId provided",
    ),
    "no_visits_available": MessageLookupByLibrary.simpleMessage(
      "No visits available",
    ),
    "notes": MessageLookupByLibrary.simpleMessage("Notes"),
    "notificationsTitle": MessageLookupByLibrary.simpleMessage("Notifications"),
    "oct": MessageLookupByLibrary.simpleMessage("OCT"),
    "odoo": MessageLookupByLibrary.simpleMessage("Odoo"),
    "ofTarget": m4,
    "oldest_due": MessageLookupByLibrary.simpleMessage("Oldest Due"),
    "oldest_first": MessageLookupByLibrary.simpleMessage("Oldest First"),
    "partnerIdLabel": MessageLookupByLibrary.simpleMessage("Partner ID"),
    "partner_details": MessageLookupByLibrary.simpleMessage("Partner Details"),
    "partner_not_found": MessageLookupByLibrary.simpleMessage(
      "Partner with ID",
    ),
    "partner_visits": MessageLookupByLibrary.simpleMessage("Partner Visits"),
    "partners": m5,
    "pay_all": MessageLookupByLibrary.simpleMessage("Pay All"),
    "payment_amount": MessageLookupByLibrary.simpleMessage("Payment amount"),
    "payment_failed": MessageLookupByLibrary.simpleMessage("Payment failed"),
    "payment_for": MessageLookupByLibrary.simpleMessage("Payment for"),
    "payment_method": MessageLookupByLibrary.simpleMessage("Payment Method"),
    "payment_terms": MessageLookupByLibrary.simpleMessage("Payment Terms"),
    "pending": MessageLookupByLibrary.simpleMessage("PENDING"),
    "percentage": MessageLookupByLibrary.simpleMessage("Percentage"),
    "phone": MessageLookupByLibrary.simpleMessage("Phone"),
    "phoneLabel": MessageLookupByLibrary.simpleMessage("Phone"),
    "pleaseLoginAgain": MessageLookupByLibrary.simpleMessage(
      "Please log in again.",
    ),
    "please_enter_valid_amounts": MessageLookupByLibrary.simpleMessage(
      "Please enter valid amounts for at least one invoice",
    ),
    "please_fill_fields": MessageLookupByLibrary.simpleMessage(
      "Please fill all required fields",
    ),
    "please_select_payment_method": MessageLookupByLibrary.simpleMessage(
      "Please select a payment method",
    ),
    "product_distribution": MessageLookupByLibrary.simpleMessage(
      "Product Distribution",
    ),
    "profileTitle": MessageLookupByLibrary.simpleMessage("Profile"),
    "quarter": MessageLookupByLibrary.simpleMessage("Quarter"),
    "quickActions": MessageLookupByLibrary.simpleMessage("Quick Actions"),
    "refresh": MessageLookupByLibrary.simpleMessage("Refresh"),
    "required_field": m6,
    "retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "retryButton": MessageLookupByLibrary.simpleMessage("Retry"),
    "salesOverview": MessageLookupByLibrary.simpleMessage("Sales Overview"),
    "salesTarget": MessageLookupByLibrary.simpleMessage("Sales Target"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "schedule_visit": MessageLookupByLibrary.simpleMessage("Schedule Visit"),
    "searchCustomersHint": MessageLookupByLibrary.simpleMessage(
      "Search customers...",
    ),
    "securityTitle": MessageLookupByLibrary.simpleMessage("Security"),
    "select_date": MessageLookupByLibrary.simpleMessage("Select Date"),
    "select_end_date": MessageLookupByLibrary.simpleMessage("Select End Date"),
    "select_start_date": MessageLookupByLibrary.simpleMessage(
      "Select Start Date",
    ),
    "selected": m7,
    "serverError": m8,
    "sessionExpired": MessageLookupByLibrary.simpleMessage(
      "Session expired. Please log in again.",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "settingsTitle": MessageLookupByLibrary.simpleMessage("Settings"),
    "share_of_total": MessageLookupByLibrary.simpleMessage("Share of Total"),
    "signIn": MessageLookupByLibrary.simpleMessage("Sign In"),
    "sortByName": MessageLookupByLibrary.simpleMessage("Sort by name"),
    "state": MessageLookupByLibrary.simpleMessage("State"),
    "stateLabel": MessageLookupByLibrary.simpleMessage("State"),
    "statement_of_account": MessageLookupByLibrary.simpleMessage(
      "Statement of Account",
    ),
    "stock": MessageLookupByLibrary.simpleMessage("Stock"),
    "storeIdLabel": MessageLookupByLibrary.simpleMessage("Store ID"),
    "storeLabel": MessageLookupByLibrary.simpleMessage("Store"),
    "success": MessageLookupByLibrary.simpleMessage("Success"),
    "switch_language": MessageLookupByLibrary.simpleMessage("Switch Language"),
    "thisMonth": MessageLookupByLibrary.simpleMessage("This month"),
    "thousand": MessageLookupByLibrary.simpleMessage("k"),
    "toggleTheme": MessageLookupByLibrary.simpleMessage("Toggle theme"),
    "token_missing": MessageLookupByLibrary.simpleMessage(
      "No API token found. Please log in.",
    ),
    "too_many_requests": MessageLookupByLibrary.simpleMessage(
      "Too many requests: Please wait before trying again.",
    ),
    "top_product": MessageLookupByLibrary.simpleMessage("Top Product"),
    "total": MessageLookupByLibrary.simpleMessage("Total"),
    "trillion": MessageLookupByLibrary.simpleMessage("T"),
    "unnamed_product": MessageLookupByLibrary.simpleMessage("Unnamed Product"),
    "view_customer_visit_patterns": MessageLookupByLibrary.simpleMessage(
      "View customer visit patterns",
    ),
    "view_transaction_history": MessageLookupByLibrary.simpleMessage(
      "View transaction history",
    ),
    "visit_information": MessageLookupByLibrary.simpleMessage(
      "Visit Information",
    ),
    "visits": MessageLookupByLibrary.simpleMessage("Visits"),
    "visits_history": MessageLookupByLibrary.simpleMessage("Visits History"),
    "vsAverage": m9,
    "wait_30_seconds": MessageLookupByLibrary.simpleMessage(
      "Please wait 30 seconds before updating again",
    ),
    "welcomeBack": MessageLookupByLibrary.simpleMessage("Welcome Back"),
    "year": MessageLookupByLibrary.simpleMessage("Year"),
    "youAreOffline": MessageLookupByLibrary.simpleMessage("You Are Offline"),
  };
}
