import 'package:flutter/material.dart';

import 'package:app/tools/routeTools.dart';

class AppMessages {
  AppMessages._();

  static const _noText = 'NaT';

  static BuildContext _getContext(){
    return RouteTools.getTopContext()!;
  }
  static String get ok {
    return 'بله';
  }

  static String get yes {
    return 'بله';
  }

  static String get no {
    return 'نه';
  }

  static String get select {
    return 'انتخاب';
  }

  static String get name {
    return 'نام';
  }

  static String get family {
    return 'فامیلی';
  }

  static String get age {
    return 'سن';
  }

  static String get gender {
    return 'جنسیت';
  }

  static String get man {
    return 'مرد';
  }

  static String get woman {
    return 'زن';
  }

  static String get notice {
    return 'توجه';
  }

  static String get send {
    return 'ارسال';
  }

  static String get next {
    return 'بعدی';
  }

  static String get home {
    return 'خانه';
  }

  static String get contactUs {
    return 'ارتباط با ما';
  }

  static String get aboutUs {
    return 'درباره ما';
  }

  static String get userName {
    return 'نام کاربری';
  }

  static String get password {
    return 'رمز ورود';
  }

  static String get pay {
    return 'پرداخت';
  }
  
  static String get register {
    return 'ثبت';
  }

  static String get logout {
    return 'خروج از حساب کاربری';
  }

  static String get exit {
    return 'خروج';
  }

  static String get search {
    return 'جستجو';
  }

  static String get later {
    return 'بعدا';
  }

  static String get update {
    return 'بروز رسانه';
  }

  static String get validation {
    return 'اعتبار سنجی';
  }

  static String get resendOtpCode {
    return 'ارسال مجدد';
  }

  static String get otpCodeIsResend {
    return '';
  }

  static String get otpCodeIsInvalid {
    return '';
  }

  static String get pleaseWait {
    return 'لطفا منتظر بمانید';
  }

  static String get countrySelection {
    return '';
  }

  static String get doYouWantLogoutYourAccount {
    return 'آیا از حساب کاربری خارج می شوید؟';
  }
  
  static String get newAppVersionIsOk {
    return 'نسخه ی جدید برنامه آماده شده است';
  }

  static String get terms {
    return 'سیاست حفظ حریم خصوصی';
  }

  static String get mobileNumber {
    return 'شماره موبایل';
  }

  static String get loginBtn {
    return 'ورود';
  }

  static String get back {
    return 'بازگشت';
  }

  static String get errorOccur {
    return 'خطایی رخ داده';
  }

  static String get tryAgain {
    return 'تلاش مجدد';
  }

  static String get tokenIsIncorrectOrExpire {
    return 'توکن صحیح نیست';
  }

  static String get enterCountryCode {
    return 'کد کشور را وارد کنید';
  }

  static String get databaseError {
    return 'خطای دیتابیس';
  }

  static String get userNameOrPasswordIncorrect {
    return 'نام کاربری یا رمز اشتباه است';
  }

  static String get errorOccurredInSubmittedParameters {
    return '';
  }

  static String get wantToLeave {
    return 'آیا می خواهید خارج شوید';
  }

  static String get dataNotFound {
    return 'داده ای یافت نشد';
  }

  static String get requestDataIsNotJson {
    return 'داده از نوع جیسان نیست';
  }

  static String get netConnectionIsDisconnect {
    return 'اینترنت شما قطع است';
  }

  static String get errorCommunicatingServer {
    return 'ارتباط با سرور برقرار نشد';
  }

  static String get serverNotRespondProperly {
    return 'سرور پاسخ مناسبی نمی دهد';
  }

  static String get accountIsBlock {
    return '';
  }

  static String get operationCannotBePerformed {
    return '';
  }

  static String get operationSuccess {
    return 'عملیات با موفقیت انجام شد';
  }

  static String get operationFailed {
    return 'عملیات انجام نشد';
  }

  static String get operationFailedTryAgain {
    return 'عملیات انجام نشد دوباره تلاش کنید';
  }

  static String get operationCanceled {
    return 'عملیات لغو شد';
  }
  
  static String get sorryYouDoNotHaveAccess {
    return 'متاسفانه شما اجازه ی دسترسی ندارید';
  }

  static String get thereAreNoResults {
    return 'نتیجه ای یافت نشد';
  }
  //---------------------------------------------------------
  static String get loginDescription {
    return 'ورود به حساب کاربری';
  }

  static String get loginDescription2 {
    return 'برای ورود به اپلیکیشن شماره همراه خود را وارد کنید';
  }

  static String get checkAndContinue {
    return 'بررسی و ادامه';
  }

  static String get loginDescription3 {
    return 'چرا بیگ بنگو؟';
  }

  static String get otpDescription {
    return 'ایجاد حساب کاربری';
  }

  static String get otpDescriptionChangeNumber {
    return 'تغییر شماره';
  }

  static String get otpDescriptionMobile {
    return 'کد ارسال شده به شماره ی';
  }

  static String get otpDescriptionMobile2 {
    return 'را وارد کنید';
  }

  static String get otpResend {
    return 'ارسال مجدد کد';
  }

  static String get registerFormDescription {
    return 'لطفا اطلاعات زیر را به دقت تکمیل فرمایید';
  }

  static String get registerFormEnterNameHint {
    return 'نام خود را وارد کنید';
  }

  static String get registerFormEnterFamilyHint {
    return 'نام خانوادگی خود را وارد کنید';
  }

  static String get registerFormEnterEmailHint {
    return 'ایمیل (پست الکترونیک) خود را وارد کنید';
  }

  static String get registerFormEnterInviteHint {
    return 'شماره موبایل معرف را درصورت وجود وارد کنید';
  }

  static String get birthdate {
    return 'تاریخ تولد';
  }

  static String get selectLevelDescription {
    return 'در این قسمت سطح آموزشی شما تعیین می‌‌شود. پیشنهاد ما به تازه‌‌کاران شروع از سطح پایه می‌‌باشد در صورتی که این گزینه برای شما مناسب نمی‌‌باشد می‌‌توانید سطح خود را به صورت آنلاین یا از طریق ارتباط با پشتیبان‌‌های بیگ‌‌بنگو تعیین کنید';
  }

  static String get supportDescription {
    return 'به منظور تعیین سطح توسط پشتیبان، زمان مورد نظر خود را انتخاب کنید. لازم به ذکر است سطح پیش‌فرض شما پس از این مرحله، سطح پایه می‌باشد که پس از پشتیبانی می‌توانید دقیق‌تر انتخاب کنید';
  }

  static String get onlineDetectLevelDescription {
    return 'برای تعیین سطح به صورت آنلاین باید به سوالات زیر پاسخ دهید.در آخر باتوجه به پاسخ های شما سطح شما مشخص خواهد شد.';
  }

  static String get selectLanguageLevelDescription1 {
    return 'در این قسمت سطح آموزشی شما تعیین می‌‌شود. پیشنهاد ما به تازه‌‌کاران شروع از سطح پایه می‌‌باشد';
  }

  static String get selectLevelTitle {
    return 'تعییــن سطــح';
  }

  static String get selectLevelTerm1 {
    return 'این سطح قابل تغییر است';
  }

  static String get supportTimeTitle {
    return 'بازه زمانی';
  }

  static String get selectLevelOnline {
    return 'تعیین سطح آنلاین';
  }

  static String get chooseTheCorrectAnswer {
    return 'choose the correct answer';
  }

  static String get supportOfLesson {
    return 'پشتیبانی از درس';
  }

  static String get mustEnterMobileNumber {
    return 'لطفا شماره موبایل خود را به درستی وارد کنید';
  }

  static String get enterYourName {
    return 'لطفا نام خود را وارد کنید';
  }

  static String get yourNameIsLittle {
    return 'نام کوتاه است';
  }

  static String get enterYourFamily {
    return 'لطفا نام خانوادگی خود را وارد کنید';
  }

  static String get yourFamilyIsLittle {
    return 'نام خانوادگی کوتاه است';
  }

  static String get emailFormatInCorrect {
    return 'قالب ایمیل درست نیست';
  }

  static String get inviteCodeInCorrect {
    return 'این کد معرف درست نیست';
  }

  static String get birthdateNotDefined {
    return 'تاریخ تولد را وارد کنید';
  }

  static String get genderNotDefined {
    return 'جنسیت خود را انتخاب کنید';
  }

  static String get cityNotDefined {
    return 'شهر خود را انتخاب کنید';
  }

  static String get emailNotCorrect {
    return 'ایمیل معتبر نیست';
  }

  static String get youFinishedThis {
    return 'این بخش را به پایان رساندید';
  }

  static String get greetingForYou {
    return 'تبریک بابت تلاشت';
  }
}
