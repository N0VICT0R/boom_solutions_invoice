// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ar locale. All the
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
  String get localeName => 'ar';

  static String m0(message) => "فشل إضافة العميل: ${message}";

  static String m1(error) => "خطأ في الاتصال: ${error}";

  static String m2(field) => "${field} يجب أن يكون رقمًا صالحًا";

  static String m3(error) => "خطأ في الشبكة: ${error}";

  static String m4(percentage) => "${percentage}% من الهدف";

  static String m5(count) => "${count} شركاء";

  static String m6(field) => "${field} مطلوب";

  static String m7(period) => "المحدد: ${period}";

  static String m8(statusCode) => "خطأ في الخادم: HTTP ${statusCode}";

  static String m9(sign, diff) => "مقارنة بالمتوسط: ${sign}${diff}%";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "addCustomer": MessageLookupByLibrary.simpleMessage("إضافة عميل"),
    "add_customer": MessageLookupByLibrary.simpleMessage("إضافة عميل"),
    "address": MessageLookupByLibrary.simpleMessage("العنوان"),
    "addressLabel": MessageLookupByLibrary.simpleMessage("العنوان"),
    "amount": MessageLookupByLibrary.simpleMessage("المبلغ"),
    "an_error_occurred": MessageLookupByLibrary.simpleMessage("حدث خطأ"),
    "aov": MessageLookupByLibrary.simpleMessage("متوسط قيمة الطلب"),
    "apiToken": MessageLookupByLibrary.simpleMessage(" أدخل الرمز الخاص بك  "),
    "api_error": m0,
    "auth_failed": MessageLookupByLibrary.simpleMessage(
      "فشل المصادقة: رمز غير صالح أو منتهي الصلاحية. يرجى تسجيل الدخول مرة أخرى.",
    ),
    "auth_token_not_found": MessageLookupByLibrary.simpleMessage(
      "لم يتم العثور على رمز المصادقة",
    ),
    "authenticationError": MessageLookupByLibrary.simpleMessage(
      "خطأ في المصادقة.",
    ),
    "balance": MessageLookupByLibrary.simpleMessage("الرصيد"),
    "billion": MessageLookupByLibrary.simpleMessage("مليار"),
    "cancel": MessageLookupByLibrary.simpleMessage("إلغاء"),
    "cancelButton": MessageLookupByLibrary.simpleMessage("إلغاء"),
    "card": MessageLookupByLibrary.simpleMessage("بطاقة"),
    "cash": MessageLookupByLibrary.simpleMessage("نقدًا"),
    "checkInternetConnection": MessageLookupByLibrary.simpleMessage(
      "تحقق من اتصالك بالإنترنت أو حاول مرة أخرى لاحقًا.",
    ),
    "city": MessageLookupByLibrary.simpleMessage("المدينة"),
    "collections": MessageLookupByLibrary.simpleMessage("التحصيلات"),
    "completedToday": MessageLookupByLibrary.simpleMessage("تم اليوم"),
    "connection_error": m1,
    "contactAdmin": MessageLookupByLibrary.simpleMessage(
      "يرجى التواصل مع مسؤول النظام للحصول على رمز API جديد.",
    ),
    "country": MessageLookupByLibrary.simpleMessage("الدولة"),
    "countryLabel": MessageLookupByLibrary.simpleMessage("الدولة"),
    "customer": MessageLookupByLibrary.simpleMessage("عميل"),
    "customer_added": MessageLookupByLibrary.simpleMessage(
      "تمت إضافة العميل بنجاح!",
    ),
    "customers": MessageLookupByLibrary.simpleMessage("العملاء"),
    "customersTitle": MessageLookupByLibrary.simpleMessage("العملاء"),
    "darkModeTitle": MessageLookupByLibrary.simpleMessage("الوضع المظلم"),
    "dashboard": MessageLookupByLibrary.simpleMessage("لوحة التحكم"),
    "day": MessageLookupByLibrary.simpleMessage("يوم"),
    "days": MessageLookupByLibrary.simpleMessage("أيام"),
    "defaultUserEmail": MessageLookupByLibrary.simpleMessage(
      "لا يوجد بريد إلكتروني",
    ),
    "defaultUserInitial": MessageLookupByLibrary.simpleMessage("م"),
    "defaultUserName": MessageLookupByLibrary.simpleMessage("مستخدم"),
    "details": MessageLookupByLibrary.simpleMessage("التفاصيل"),
    "due_date": MessageLookupByLibrary.simpleMessage("تاريخ الاستحقاق"),
    "due_later": MessageLookupByLibrary.simpleMessage("المدفوع لاحقًا"),
    "due_now": MessageLookupByLibrary.simpleMessage("المدفوع الآن"),
    "dues": MessageLookupByLibrary.simpleMessage("المستحقات"),
    "editProfileTitle": MessageLookupByLibrary.simpleMessage(
      "تعديل الملف الشخصي",
    ),
    "emailLabel": MessageLookupByLibrary.simpleMessage("البريد الإلكتروني"),
    "enterYourEmail": MessageLookupByLibrary.simpleMessage(
      "أدخل بريدك الإلكتروني",
    ),
    "error": MessageLookupByLibrary.simpleMessage("خطأ"),
    "error_fetching_visits": MessageLookupByLibrary.simpleMessage(
      "خطأ أثناء جلب الزيارات",
    ),
    "error_getting_location": MessageLookupByLibrary.simpleMessage(
      "خطأ في الحصول على الموقع الحالي",
    ),
    "error_updating_location": MessageLookupByLibrary.simpleMessage(
      "خطأ في تحديث الموقع",
    ),
    "failedToLoadCustomers": MessageLookupByLibrary.simpleMessage(
      "يرجى تحميل العملاء",
    ),
    "failed_to_fetch_partner_data": MessageLookupByLibrary.simpleMessage(
      "فشل في جلب بيانات الشريك",
    ),
    "failed_to_load_visits": MessageLookupByLibrary.simpleMessage(
      "فشل في تحميل الزيارات",
    ),
    "failed_to_update_location": MessageLookupByLibrary.simpleMessage(
      "فشل في تحديث الموقع",
    ),
    "field_required": MessageLookupByLibrary.simpleMessage("هذا العنصر مطلوب"),
    "filter_by_date": MessageLookupByLibrary.simpleMessage("تصفية حسب التاريخ"),
    "filtered_by": MessageLookupByLibrary.simpleMessage("تم التصفية حسب"),
    "forgotApiToken": MessageLookupByLibrary.simpleMessage(
      "هل نسيت رمز API الخاص بك؟",
    ),
    "inspirationalQuotes": MessageLookupByLibrary.simpleMessage(
      "النجاح ليس غياب العقبات، بل الشجاعة لتخطيها.\nالحد الوحيد لإدراكنا للمستقبل هو شكوكنا في الحاضر.\nوقتك محدود، فلا تهدره في عيش حياة شخص آخر.\nالمستقبل ملك لأولئك الذين يؤمنون بجمال أحلامهم.\nافعل ما تستطيع، بما لديك، حيثما كنت.\nكل لحظة هي بداية جديدة.\nأفضل طريقة للتنبؤ بالمستقبل هي صنعه.\nابقَ جائعًا، ابقَ أحمقًا.\nستفوتك 100% من الفرص التي لا تأخذها.\nاحلم كبيرًا، اعمل بجد، ركز.",
    ),
    "invalid_number": m2,
    "invalid_partner_id": MessageLookupByLibrary.simpleMessage(
      "خطأ: معرف شريك غير صالح",
    ),
    "invoice_date": MessageLookupByLibrary.simpleMessage("تاريخ الفاتورة"),
    "invoices": MessageLookupByLibrary.simpleMessage("فواتير"),
    "last_purchase": MessageLookupByLibrary.simpleMessage("آخر عملية شراء"),
    "location_permissions_denied": MessageLookupByLibrary.simpleMessage(
      "تم رفض أذونات الموقع. يرجى السماح بالوصول إلى الموقع في الإعدادات.",
    ),
    "location_permissions_denied_forever": MessageLookupByLibrary.simpleMessage(
      "تم رفض أذونات الموقع بشكل دائم. يرجى تمكينها في الإعدادات.",
    ),
    "location_services_disabled": MessageLookupByLibrary.simpleMessage(
      "خدمات الموقع معطلة. يرجى تمكينها في الإعدادات.",
    ),
    "location_updated_successfully": MessageLookupByLibrary.simpleMessage(
      "تم تحديث الموقع بنجاح",
    ),
    "loginLabel": MessageLookupByLibrary.simpleMessage("تسجيل الدخول"),
    "logoutButton": MessageLookupByLibrary.simpleMessage("تسجيل الخروج"),
    "logoutDialogMessage": MessageLookupByLibrary.simpleMessage(
      "هل أنت متأكد أنك تريد تسجيل الخروج؟",
    ),
    "logoutDialogTitle": MessageLookupByLibrary.simpleMessage("تسجيل الخروج"),
    "logoutErrorMessage": MessageLookupByLibrary.simpleMessage(
      "فشل في إكمال تسجيل الخروج",
    ),
    "logoutErrorTitle": MessageLookupByLibrary.simpleMessage(
      "خطأ في تسجيل الخروج",
    ),
    "logoutSuccessMessage": MessageLookupByLibrary.simpleMessage(
      "تم تسجيل الخروج بنجاح",
    ),
    "logoutSuccessTitle": MessageLookupByLibrary.simpleMessage(
      "تم تسجيل الخروج",
    ),
    "logoutTitle": MessageLookupByLibrary.simpleMessage("تسجيل الخروج"),
    "make_payment": MessageLookupByLibrary.simpleMessage("إجراء دفعة"),
    "max": MessageLookupByLibrary.simpleMessage("الحد الأقصى"),
    "million": MessageLookupByLibrary.simpleMessage("مليون"),
    "mobile": MessageLookupByLibrary.simpleMessage("الموبايل"),
    "mobileLabel": MessageLookupByLibrary.simpleMessage("الجوال"),
    "month": MessageLookupByLibrary.simpleMessage("شهر"),
    "na": MessageLookupByLibrary.simpleMessage("غير متوفر"),
    "name": MessageLookupByLibrary.simpleMessage("الاسم"),
    "nearbyCustomers": MessageLookupByLibrary.simpleMessage("العملاء القريبون"),
    "networkError": m3,
    "newCustomers": MessageLookupByLibrary.simpleMessage("عملاء جدد"),
    "newest_first": MessageLookupByLibrary.simpleMessage("الأحدث أولاً"),
    "noCustomersFound": MessageLookupByLibrary.simpleMessage(
      "لم يتم العثور على عملاء",
    ),
    "noDataAvailable": MessageLookupByLibrary.simpleMessage(
      "لا توجد بيانات متاحة",
    ),
    "noNotesYet": MessageLookupByLibrary.simpleMessage("لا توجد ملاحظات بعد"),
    "noUserData": MessageLookupByLibrary.simpleMessage(
      "لا توجد بيانات مستخدم متاحة",
    ),
    "no_data": MessageLookupByLibrary.simpleMessage("لا توجد بيانات"),
    "no_data_available": MessageLookupByLibrary.simpleMessage(
      "لا توجد بيانات متاحة",
    ),
    "no_notes": MessageLookupByLibrary.simpleMessage("لا توجد ملاحظات"),
    "no_partners_found": MessageLookupByLibrary.simpleMessage(
      "لم يتم العثور على شركاء",
    ),
    "no_token": MessageLookupByLibrary.simpleMessage(
      "رمز API مفقود. يرجى تسجيل الدخول مرة أخرى.",
    ),
    "no_valid_coordinates": MessageLookupByLibrary.simpleMessage(
      "لا توجد إحداثيات صالحة لمعرف الشريك",
    ),
    "no_valid_partner_id": MessageLookupByLibrary.simpleMessage(
      "لم يتم توفير معرف شريك صالح",
    ),
    "no_visits_available": MessageLookupByLibrary.simpleMessage(
      "لا توجد زيارات متاحة",
    ),
    "notes": MessageLookupByLibrary.simpleMessage("ملاحظات"),
    "notificationsTitle": MessageLookupByLibrary.simpleMessage("الإشعارات"),
    "oct": MessageLookupByLibrary.simpleMessage("دورة الطلب"),
    "odoo": MessageLookupByLibrary.simpleMessage("أودو"),
    "ofTarget": m4,
    "oldest_due": MessageLookupByLibrary.simpleMessage("أقدم مستحق"),
    "oldest_first": MessageLookupByLibrary.simpleMessage("الأقدم أولاً"),
    "partnerIdLabel": MessageLookupByLibrary.simpleMessage("معرف الشريك"),
    "partner_details": MessageLookupByLibrary.simpleMessage("تفاصيل الشريك"),
    "partner_not_found": MessageLookupByLibrary.simpleMessage(
      "لم يتم العثور على الشريك بمعرف",
    ),
    "partner_visits": MessageLookupByLibrary.simpleMessage("زيارات الشريك"),
    "partners": m5,
    "pay_all": MessageLookupByLibrary.simpleMessage("ادفع الكل"),
    "payment_amount": MessageLookupByLibrary.simpleMessage("مبلغ الدفع"),
    "payment_failed": MessageLookupByLibrary.simpleMessage("فشل الدفع"),
    "payment_for": MessageLookupByLibrary.simpleMessage("الدفع لـ"),
    "payment_method": MessageLookupByLibrary.simpleMessage("طريقة الدفع"),
    "payment_terms": MessageLookupByLibrary.simpleMessage("شروط الدفع"),
    "pending": MessageLookupByLibrary.simpleMessage("قيد الانتظار"),
    "percentage": MessageLookupByLibrary.simpleMessage("النسبة المئوية"),
    "phone": MessageLookupByLibrary.simpleMessage("الهاتف"),
    "phoneLabel": MessageLookupByLibrary.simpleMessage("الهاتف"),
    "pleaseLoginAgain": MessageLookupByLibrary.simpleMessage(
      "يرجى تسجيل الدخول مرة أخرى.",
    ),
    "please_enter_valid_amounts": MessageLookupByLibrary.simpleMessage(
      "يرجى إدخال مبالغ صالحة لفاتورة واحدة على الأقل",
    ),
    "please_fill_fields": MessageLookupByLibrary.simpleMessage(
      "يرجى ملء جميع الحقول المطلوبة",
    ),
    "please_select_payment_method": MessageLookupByLibrary.simpleMessage(
      "يرجى اختيار طريقة دفع",
    ),
    "product_distribution": MessageLookupByLibrary.simpleMessage(
      "توزيع المنتج",
    ),
    "profileTitle": MessageLookupByLibrary.simpleMessage("الملف الشخصي"),
    "quarter": MessageLookupByLibrary.simpleMessage("ربع سنة"),
    "quickActions": MessageLookupByLibrary.simpleMessage("إجراءات سريعة"),
    "refresh": MessageLookupByLibrary.simpleMessage("تحديث"),
    "required_field": m6,
    "retry": MessageLookupByLibrary.simpleMessage("إعادة المحاولة"),
    "retryButton": MessageLookupByLibrary.simpleMessage("إعادة المحاولة"),
    "salesOverview": MessageLookupByLibrary.simpleMessage("المبيعات"),
    "salesTarget": MessageLookupByLibrary.simpleMessage("هدف المبيعات"),
    "save": MessageLookupByLibrary.simpleMessage("حفظ"),
    "schedule_visit": MessageLookupByLibrary.simpleMessage("جدولة زيارة"),
    "searchCustomersHint": MessageLookupByLibrary.simpleMessage(
      "البحث عن العملاء...",
    ),
    "securityTitle": MessageLookupByLibrary.simpleMessage("الأمان"),
    "select_date": MessageLookupByLibrary.simpleMessage("اختر التاريخ"),
    "select_end_date": MessageLookupByLibrary.simpleMessage(
      "اختر تاريخ الانتهاء",
    ),
    "select_start_date": MessageLookupByLibrary.simpleMessage(
      "اختر تاريخ البدء",
    ),
    "selected": m7,
    "serverError": m8,
    "sessionExpired": MessageLookupByLibrary.simpleMessage(
      "انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى.",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("الإعدادات"),
    "settingsTitle": MessageLookupByLibrary.simpleMessage("الإعدادات"),
    "share_of_total": MessageLookupByLibrary.simpleMessage("حصة من الإجمالي"),
    "signIn": MessageLookupByLibrary.simpleMessage("تسجيل الدخول"),
    "sortByName": MessageLookupByLibrary.simpleMessage("فرز حسب الاسم"),
    "state": MessageLookupByLibrary.simpleMessage("الولاية"),
    "statement_of_account": MessageLookupByLibrary.simpleMessage("كشف الحساب"),
    "stock": MessageLookupByLibrary.simpleMessage("المخزون"),
    "storeIdLabel": MessageLookupByLibrary.simpleMessage("معرف المتجر"),
    "storeLabel": MessageLookupByLibrary.simpleMessage("المتجر"),
    "success": MessageLookupByLibrary.simpleMessage("نجاح"),
    "switch_language": MessageLookupByLibrary.simpleMessage("تبديل اللغة"),
    "thisMonth": MessageLookupByLibrary.simpleMessage("هذا الشهر"),
    "thousand": MessageLookupByLibrary.simpleMessage("ألف"),
    "too_many_requests": MessageLookupByLibrary.simpleMessage(
      "طلبات كثيرة جدًا: يرجى الانتظار قبل المحاولة مرة أخرى.",
    ),
    "top_product": MessageLookupByLibrary.simpleMessage("أفضل منتج"),
    "total": MessageLookupByLibrary.simpleMessage("الإجمالي"),
    "trillion": MessageLookupByLibrary.simpleMessage("تريليون"),
    "unnamed_product": MessageLookupByLibrary.simpleMessage("منتج غير مسمى"),
    "view_customer_visit_patterns": MessageLookupByLibrary.simpleMessage(
      "عرض أنماط زيارة العميل",
    ),
    "view_transaction_history": MessageLookupByLibrary.simpleMessage(
      "عرض سجل المعاملات",
    ),
    "visit_information": MessageLookupByLibrary.simpleMessage(
      "معلومات الزيارة",
    ),
    "visits": MessageLookupByLibrary.simpleMessage("الزيارات"),
    "visits_history": MessageLookupByLibrary.simpleMessage("سجل الزيارات"),
    "vsAverage": m9,
    "wait_30_seconds": MessageLookupByLibrary.simpleMessage(
      "يرجى الانتظار 30 ثانية قبل التحديث مرة أخرى",
    ),
    "welcomeBack": MessageLookupByLibrary.simpleMessage("مرحبًا "),
    "year": MessageLookupByLibrary.simpleMessage("سنة"),
    "youAreOffline": MessageLookupByLibrary.simpleMessage("أنت غير متصل"),
  };
}
