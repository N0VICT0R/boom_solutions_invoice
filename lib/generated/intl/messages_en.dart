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

  static String m15(partnerId) => "Customer with ID ${partnerId} not found.";

  static String m2(distance) => "${distance} km";

  static String m3(message) => "Error: ${message}";

  static String m4(status) =>
      "Failed to load inventory data. Status: ${status}";

  static String m5(message) => "Error getting location: ${message}";

  static String m6(field) => "${field} must be a valid number";

  static String m7(error) => "Network error: ${error}";

  static String m16(message) => "Network error: ${message}";

  static String m8(percentage) => "${percentage}% of target";

  static String m9(count) => "${count} partners";

  static String m10(field) => "${field} is required";

  static String m11(period) => "Selected: ${period}";

  static String m12(name) => "Selected: ${name}";

  static String m13(statusCode) => "Server error: HTTP ${statusCode}";

  static String m17(message) => "Error: ${message}";

  static String m14(sign, diff) => "vs Average: ${sign}${diff}%";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "addCustomer": MessageLookupByLibrary.simpleMessage("Add customer"),
    "addNotes": MessageLookupByLibrary.simpleMessage("Add notes..."),
    "add_customer": MessageLookupByLibrary.simpleMessage("Add Customer"),
    "add_visit_notes": MessageLookupByLibrary.simpleMessage(
      "Add visit notes...",
    ),
    "address": MessageLookupByLibrary.simpleMessage("Address"),
    "addressLabel": MessageLookupByLibrary.simpleMessage("Address"),
    "amount": MessageLookupByLibrary.simpleMessage("Amount"),
    "an_error_occurred": MessageLookupByLibrary.simpleMessage(
      "An error occurred",
    ),
    "aov": MessageLookupByLibrary.simpleMessage("AOV"),
    "apiToken": MessageLookupByLibrary.simpleMessage("API Token"),
    "api_error": m0,
    "appTitle": MessageLookupByLibrary.simpleMessage("Partners Map"),
    "app_title": MessageLookupByLibrary.simpleMessage("Customer Check-in"),
    "auth_failed": MessageLookupByLibrary.simpleMessage(
      "Authentication failed: Invalid or expired token. Please log in again.",
    ),
    "auth_token_not_found": MessageLookupByLibrary.simpleMessage(
      "Authentication token not found",
    ),
    "authenticationError": MessageLookupByLibrary.simpleMessage(
      "Authentication error.",
    ),
    "available": MessageLookupByLibrary.simpleMessage("AVAILABLE"),
    "balance": MessageLookupByLibrary.simpleMessage("BALANCE"),
    "billion": MessageLookupByLibrary.simpleMessage("B"),
    "calculating_distance": MessageLookupByLibrary.simpleMessage(
      "Calculating distance...",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cancelButton": MessageLookupByLibrary.simpleMessage("Cancel"),
    "card": MessageLookupByLibrary.simpleMessage("Card"),
    "cash": MessageLookupByLibrary.simpleMessage("Cash"),
    "checkConnection": MessageLookupByLibrary.simpleMessage(
      "Check your internet connection or try again later.",
    ),
    "checkIn": MessageLookupByLibrary.simpleMessage("Check In"),
    "checkInternetConnection": MessageLookupByLibrary.simpleMessage(
      "Check your internet connection or try again later.",
    ),
    "check_in": MessageLookupByLibrary.simpleMessage("CHECK IN"),
    "city": MessageLookupByLibrary.simpleMessage("City"),
    "cityLabel": MessageLookupByLibrary.simpleMessage("City"),
    "close": MessageLookupByLibrary.simpleMessage("Close"),
    "collections": MessageLookupByLibrary.simpleMessage("Collections"),
    "completedToday": MessageLookupByLibrary.simpleMessage("Completed today"),
    "connection_error": m1,
    "contactAdmin": MessageLookupByLibrary.simpleMessage(
      "Contact your system administrator for a new API token.",
    ),
    "country": MessageLookupByLibrary.simpleMessage("Country"),
    "countryLabel": MessageLookupByLibrary.simpleMessage("Country"),
    "credit": MessageLookupByLibrary.simpleMessage("CREDIT"),
    "currency": MessageLookupByLibrary.simpleMessage("Currency"),
    "currentBalance": MessageLookupByLibrary.simpleMessage("Current Balance"),
    "customer": MessageLookupByLibrary.simpleMessage("Customer"),
    "customerNotFound": MessageLookupByLibrary.simpleMessage(
      "Customer not found.",
    ),
    "customer_added": MessageLookupByLibrary.simpleMessage(
      "Customer added successfully!",
    ),
    "customer_check_in": MessageLookupByLibrary.simpleMessage(
      "Customer Check-in",
    ),
    "customer_location_invalid": MessageLookupByLibrary.simpleMessage(
      "Customer location data is invalid.",
    ),
    "customer_location_not_available": MessageLookupByLibrary.simpleMessage(
      "Customer location not available in the response.",
    ),
    "customer_not_found": m15,
    "customers": MessageLookupByLibrary.simpleMessage("Customers"),
    "customersTitle": MessageLookupByLibrary.simpleMessage("Customers"),
    "darkModeTitle": MessageLookupByLibrary.simpleMessage("Dark Mode"),
    "dashboard": MessageLookupByLibrary.simpleMessage("Dashboard"),
    "dataLoadError": MessageLookupByLibrary.simpleMessage(
      "Failed to load data. Please try again.",
    ),
    "date": MessageLookupByLibrary.simpleMessage("DATE"),
    "dateRange": MessageLookupByLibrary.simpleMessage("Date Range"),
    "day": MessageLookupByLibrary.simpleMessage("Day"),
    "days": MessageLookupByLibrary.simpleMessage("days"),
    "debit": MessageLookupByLibrary.simpleMessage("DEBIT"),
    "defaultUserEmail": MessageLookupByLibrary.simpleMessage("No email"),
    "defaultUserInitial": MessageLookupByLibrary.simpleMessage("U"),
    "defaultUserName": MessageLookupByLibrary.simpleMessage("User"),
    "details": MessageLookupByLibrary.simpleMessage("Details"),
    "distanceValue": m2,
    "distanceWarning": MessageLookupByLibrary.simpleMessage("Distance Warning"),
    "distanceWarningMessage": MessageLookupByLibrary.simpleMessage(
      "You are more than 10 km away. Proceed with check-in?",
    ),
    "distance_exceeded": MessageLookupByLibrary.simpleMessage(
      "You need to be closer to the customer (within 10 km) to check in.",
    ),
    "due_date": MessageLookupByLibrary.simpleMessage("DUE DATE"),
    "due_later": MessageLookupByLibrary.simpleMessage("Due Later"),
    "due_now": MessageLookupByLibrary.simpleMessage("Due Now"),
    "dues": MessageLookupByLibrary.simpleMessage("Dues"),
    "editProfileTitle": MessageLookupByLibrary.simpleMessage("Edit Profile"),
    "emailLabel": MessageLookupByLibrary.simpleMessage("Email"),
    "endingBalance": MessageLookupByLibrary.simpleMessage("Ending Balance"),
    "enterYourEmail": MessageLookupByLibrary.simpleMessage("Enter your email"),
    "error": MessageLookupByLibrary.simpleMessage("Error"),
    "errorGeneric": m3,
    "errorLoadingData": m4,
    "errorLoadingDataTitle": MessageLookupByLibrary.simpleMessage(
      "Error Loading Data",
    ),
    "error_fetch_customer": MessageLookupByLibrary.simpleMessage(
      "Error fetching customer location.",
    ),
    "error_fetching_visits": MessageLookupByLibrary.simpleMessage(
      "Error fetching visits",
    ),
    "error_getting_location": m5,
    "error_updating_location": MessageLookupByLibrary.simpleMessage(
      "Error updating location",
    ),
    "failed": MessageLookupByLibrary.simpleMessage("Failed"),
    "failedToFetchCustomerLocation": MessageLookupByLibrary.simpleMessage(
      "Failed to fetch customer location",
    ),
    "failedToLoadCustomers": MessageLookupByLibrary.simpleMessage(
      "Failed to load customers",
    ),
    "failedToLoadPdf": MessageLookupByLibrary.simpleMessage(
      "Failed to load PDF",
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
    "fetch_customer_error": MessageLookupByLibrary.simpleMessage(
      "Failed to fetch customer location.",
    ),
    "field_required": MessageLookupByLibrary.simpleMessage(
      "This field is required",
    ),
    "filter_by_date": MessageLookupByLibrary.simpleMessage("Filter by Date"),
    "filtered_by": MessageLookupByLibrary.simpleMessage("Filtered by"),
    "forgotApiToken": MessageLookupByLibrary.simpleMessage(
      "Forgot your API Token?",
    ),
    "hideBalance": MessageLookupByLibrary.simpleMessage("Hide Balance"),
    "inspirationalQuotes": MessageLookupByLibrary.simpleMessage(
      "Success is not the absence of obstacles, but the courage to push through them.",
    ),
    "invalidOrEmptyFile": MessageLookupByLibrary.simpleMessage(
      "Invalid or empty file",
    ),
    "invalid_number": m6,
    "invalid_partner_id": MessageLookupByLibrary.simpleMessage(
      "Error: Invalid partner ID",
    ),
    "invalid_payment_method": MessageLookupByLibrary.simpleMessage(
      "Invalid payment method",
    ),
    "inventory": MessageLookupByLibrary.simpleMessage("Inventory"),
    "invoice_date": MessageLookupByLibrary.simpleMessage("INVOICE DATE"),
    "invoices": MessageLookupByLibrary.simpleMessage("invoices"),
    "items": MessageLookupByLibrary.simpleMessage("Items"),
    "languageTitle": MessageLookupByLibrary.simpleMessage("Change Language To"),
    "last_purchase": MessageLookupByLibrary.simpleMessage("Last Purchase"),
    "location": MessageLookupByLibrary.simpleMessage("Location"),
    "locationError": MessageLookupByLibrary.simpleMessage(
      "Failed to get location. Please try again.",
    ),
    "locationNotAvailable": MessageLookupByLibrary.simpleMessage(
      "Location not available.",
    ),
    "locationPermissionDenied": MessageLookupByLibrary.simpleMessage(
      "Location permission denied. Please enable it in settings.",
    ),
    "locationPermissionDeniedForever": MessageLookupByLibrary.simpleMessage(
      "Location permission permanently denied. Please enable it in device settings.",
    ),
    "locationPermissionsPermanentlyDenied":
        MessageLookupByLibrary.simpleMessage(
          "Location permissions permanently denied.",
        ),
    "locationServicesDisabled": MessageLookupByLibrary.simpleMessage(
      "Location services are disabled.",
    ),
    "location_already_set": MessageLookupByLibrary.simpleMessage(
      "This partner already has a set location. Do you want to update it?",
    ),
    "location_exists": MessageLookupByLibrary.simpleMessage("Location Exists"),
    "location_not_available": MessageLookupByLibrary.simpleMessage(
      "Location not available. Please try again.",
    ),
    "location_permission_denied": MessageLookupByLibrary.simpleMessage(
      "Location permission denied.",
    ),
    "location_permission_permanent_denied":
        MessageLookupByLibrary.simpleMessage(
          "Location permissions permanently denied. Please enable in settings.",
        ),
    "location_permissions_denied": MessageLookupByLibrary.simpleMessage(
      "Location permissions denied. Please allow location access in settings.",
    ),
    "location_permissions_denied_forever": MessageLookupByLibrary.simpleMessage(
      "Location permissions are permanently denied. Please enable them in settings.",
    ),
    "location_services_disabled": MessageLookupByLibrary.simpleMessage(
      "Location services are disabled. Please enable them.",
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
    "networkError": m7,
    "network_error": m16,
    "newCustomers": MessageLookupByLibrary.simpleMessage("New Customers"),
    "newest_first": MessageLookupByLibrary.simpleMessage("Newest First"),
    "noCustomersFound": MessageLookupByLibrary.simpleMessage(
      "No customers found",
    ),
    "noDataAvailable": MessageLookupByLibrary.simpleMessage(
      "No data available",
    ),
    "noInventoryItems": MessageLookupByLibrary.simpleMessage(
      "No inventory items found",
    ),
    "noMatchingItems": MessageLookupByLibrary.simpleMessage(
      "No matching items found",
    ),
    "noMessageProvided": MessageLookupByLibrary.simpleMessage(
      "No message provided",
    ),
    "noNotesYet": MessageLookupByLibrary.simpleMessage("No notes yet"),
    "noPartnersFound": MessageLookupByLibrary.simpleMessage(
      "No partners found.",
    ),
    "noSalesInThisTime": MessageLookupByLibrary.simpleMessage(
      "You haven\'t sold anything yet.",
    ),
    "noUserData": MessageLookupByLibrary.simpleMessage(
      "No user data available",
    ),
    "no_data": MessageLookupByLibrary.simpleMessage("No Data"),
    "no_data_available": MessageLookupByLibrary.simpleMessage(
      "No data available",
    ),
    "no_journal_id": MessageLookupByLibrary.simpleMessage(
      "No journal ID found",
    ),
    "no_message_provided": MessageLookupByLibrary.simpleMessage(
      "No message provided",
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
    "notAvailable": MessageLookupByLibrary.simpleMessage("N/A"),
    "notes": MessageLookupByLibrary.simpleMessage("Notes"),
    "notesRequired": MessageLookupByLibrary.simpleMessage("Notes are required"),
    "notificationsTitle": MessageLookupByLibrary.simpleMessage("Notifications"),
    "oct": MessageLookupByLibrary.simpleMessage("OCT"),
    "odoo": MessageLookupByLibrary.simpleMessage("Odoo"),
    "ofTarget": m8,
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "oldest_due": MessageLookupByLibrary.simpleMessage("Oldest Due"),
    "oldest_first": MessageLookupByLibrary.simpleMessage("Oldest First"),
    "out_of_range": MessageLookupByLibrary.simpleMessage(
      "You need to be within 10 km of the customer",
    ),
    "partner": MessageLookupByLibrary.simpleMessage("Partner"),
    "partnerIdLabel": MessageLookupByLibrary.simpleMessage("Partner ID"),
    "partner_details": MessageLookupByLibrary.simpleMessage("Partner Details"),
    "partner_not_found": MessageLookupByLibrary.simpleMessage(
      "Partner with ID",
    ),
    "partner_visits": MessageLookupByLibrary.simpleMessage("Partner Visits"),
    "partners": m9,
    "partnersMap": MessageLookupByLibrary.simpleMessage("Partners Map"),
    "pay_all": MessageLookupByLibrary.simpleMessage("Pay All"),
    "payment_amount": MessageLookupByLibrary.simpleMessage("Payment amount"),
    "payment_failed": MessageLookupByLibrary.simpleMessage("Payment failed"),
    "payment_for": MessageLookupByLibrary.simpleMessage("Payment for"),
    "payment_method": MessageLookupByLibrary.simpleMessage("Payment Method"),
    "payment_successful": MessageLookupByLibrary.simpleMessage(
      "Payment successfully",
    ),
    "payment_terms": MessageLookupByLibrary.simpleMessage("Payment Terms"),
    "pdfFileNotFound": MessageLookupByLibrary.simpleMessage(
      "PDF file does not exist.",
    ),
    "pdfFileTooSmall": MessageLookupByLibrary.simpleMessage(
      "PDF file is too small or corrupted.",
    ),
    "pdfViewerTitle": MessageLookupByLibrary.simpleMessage("PDF Viewer"),
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
    "price": MessageLookupByLibrary.simpleMessage("PRICE"),
    "proceed": MessageLookupByLibrary.simpleMessage("Proceed"),
    "processing_check_in": MessageLookupByLibrary.simpleMessage(
      "Processing check-in...",
    ),
    "product": MessageLookupByLibrary.simpleMessage("PRODUCT"),
    "product_distribution": MessageLookupByLibrary.simpleMessage(
      "Product Distribution",
    ),
    "profileTitle": MessageLookupByLibrary.simpleMessage("Profile"),
    "quantity": MessageLookupByLibrary.simpleMessage("QTY"),
    "quarter": MessageLookupByLibrary.simpleMessage("Quarter"),
    "quickActions": MessageLookupByLibrary.simpleMessage("Quick Actions"),
    "reference": MessageLookupByLibrary.simpleMessage("Reference"),
    "refresh": MessageLookupByLibrary.simpleMessage("Refresh"),
    "required_field": m10,
    "retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "retryButton": MessageLookupByLibrary.simpleMessage("Retry"),
    "salesOverview": MessageLookupByLibrary.simpleMessage("Sales Overview"),
    "salesTarget": MessageLookupByLibrary.simpleMessage("Sales Target"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "schedule_visit": MessageLookupByLibrary.simpleMessage("Schedule Visit"),
    "searchCustomersHint": MessageLookupByLibrary.simpleMessage(
      "Search customers...",
    ),
    "searchInventory": MessageLookupByLibrary.simpleMessage(
      "Search inventory...",
    ),
    "securityTitle": MessageLookupByLibrary.simpleMessage("Security"),
    "select_date": MessageLookupByLibrary.simpleMessage("Select Date"),
    "select_end_date": MessageLookupByLibrary.simpleMessage("Select End Date"),
    "select_start_date": MessageLookupByLibrary.simpleMessage(
      "Select Start Date",
    ),
    "selected": m11,
    "selectedProduct": m12,
    "serverError": m13,
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
    "statementSummary": MessageLookupByLibrary.simpleMessage(
      "Statement Summary",
    ),
    "statement_of_account": MessageLookupByLibrary.simpleMessage(
      "Statement of Account",
    ),
    "stock": MessageLookupByLibrary.simpleMessage("Stock"),
    "storeIdLabel": MessageLookupByLibrary.simpleMessage("Store ID"),
    "storeLabel": MessageLookupByLibrary.simpleMessage("Store"),
    "submit_error": m17,
    "success": MessageLookupByLibrary.simpleMessage("Success"),
    "switch_language": MessageLookupByLibrary.simpleMessage("Switch Language"),
    "thisMonth": MessageLookupByLibrary.simpleMessage("This month"),
    "thousand": MessageLookupByLibrary.simpleMessage("k"),
    "toggleRouteMode": MessageLookupByLibrary.simpleMessage(
      "Toggle Route Mode",
    ),
    "toggleTheme": MessageLookupByLibrary.simpleMessage("Toggle theme"),
    "token_missing": MessageLookupByLibrary.simpleMessage(
      "No API token found. Please log in.",
    ),
    "too_far_away": MessageLookupByLibrary.simpleMessage("Too Far Away"),
    "too_many_requests": MessageLookupByLibrary.simpleMessage(
      "Too many requests: Please wait before trying again.",
    ),
    "top_product": MessageLookupByLibrary.simpleMessage("Top Product"),
    "total": MessageLookupByLibrary.simpleMessage("Total"),
    "transactions": MessageLookupByLibrary.simpleMessage("Transactions"),
    "trillion": MessageLookupByLibrary.simpleMessage("T"),
    "unknownCustomer": MessageLookupByLibrary.simpleMessage("Unknown Customer"),
    "unnamed_product": MessageLookupByLibrary.simpleMessage("Unnamed Product"),
    "update": MessageLookupByLibrary.simpleMessage("Update"),
    "user": MessageLookupByLibrary.simpleMessage("User"),
    "view_customer_visit_patterns": MessageLookupByLibrary.simpleMessage(
      "View customer visit patterns",
    ),
    "view_transaction_history": MessageLookupByLibrary.simpleMessage(
      "View transaction history",
    ),
    "visitDetails": MessageLookupByLibrary.simpleMessage("Visit Details:"),
    "visitNote": MessageLookupByLibrary.simpleMessage("Visit Note"),
    "visit_details": MessageLookupByLibrary.simpleMessage("Visit Details"),
    "visit_information": MessageLookupByLibrary.simpleMessage(
      "Visit Information",
    ),
    "visits": MessageLookupByLibrary.simpleMessage("Visits"),
    "visits_history": MessageLookupByLibrary.simpleMessage("Visits History"),
    "vsAverage": m14,
    "wait_30_seconds": MessageLookupByLibrary.simpleMessage(
      "Please wait 30 seconds before updating again",
    ),
    "welcomeBack": MessageLookupByLibrary.simpleMessage("Welcome Back"),
    "within_range": MessageLookupByLibrary.simpleMessage(
      "You are within range to check in",
    ),
    "year": MessageLookupByLibrary.simpleMessage("Year"),
    "youAreOffline": MessageLookupByLibrary.simpleMessage("You Are Offline"),
  };
}
