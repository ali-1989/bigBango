import 'package:flutter/material.dart';

import 'package:app/system/extensions.dart';
import 'package:app/tools/route_tools.dart';

class AppMessages {
  AppMessages._();

  static const _noText = 'NaT';

  static BuildContext _getContext(){
    return RouteTools.getTopContext()!;
  }
  
  static String httpMessage(String? cause) {
    if(cause == null){
      return errorOccur;
    }

    return _getContext().tInMap('httpCodes', cause)?? errorOccur;
  }

  static String operationMessage(String key) {
    return _getContext().tInMap('operationSection', key)?? _noText;
  }

  static String loginMessage(String key) {
    return _getContext().tInMap('loginSection', key)?? _noText;
  }

  static String registerMessage(String key) {
    return _getContext().tInMap('registerSection', key)?? _noText;
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

  static String get back {
     return 'برگشت';
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

  static String get save {
    return _getContext().t('save')?? _noText;
  }

  static String get downloadNewVersion {
    return _getContext().t('downloadNewVersion')?? _noText;
  }

  static String get directDownload {
    return _getContext().t('directDownload')?? _noText;
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
    return loginMessage('otpCodeIsInvalid');
  }

  static String get doYouWantLogoutYourAccount {
    return loginMessage('doYouWantLogoutYourAccount');
  }

  static String get loginWithGoogle {
    return loginMessage('loginWithGoogle');
  }

  static String get countrySelection {
    return '';
  }

  static String get newAppVersionIsOk {
    return 'نسخه ی جدید برنامه آماده شده است';
  }

  static String get pleaseWait {
    return _getContext().t('pleaseWait')?? _noText;
  }

  static String get termPolice {
    return 'سیاست حفظ حریم خصوصی';
  }

  static String get mobileNumber {
    return 'شماره موبایل';
  }

  static String get loginBtn {
    return 'ورود';
  }

  static String get otherNumber {
    return registerMessage('otherNumber');
  }

  static String get enterVerifyCodeDesc {
    return registerMessage('validationDescription');
  }

 static String get pleaseEnterAPassword {
    return registerMessage('selectPassword');
  }

  static String get errorOccur {
    return _getContext().t('errorOccur')?? _noText;
  }

  static String get errorOccurTryAgain {
    return _getContext().t('errorOccurTryAgain')?? _noText;
  }

  static String get wantToLeave {
    return _getContext().tC('wantToLeave')?? _noText;
  }

  static String get e404 {
    return _getContext().tC('thisPageNotFound')?? _noText;
  }

  static String get tryAgain {
    return _getContext().t('tryAgain')?? _noText;
  }

  static String get tokenIsIncorrectOrExpire {
    return 'توکن صحیح نیست';
  }

  static String get databaseError {
    return httpMessage('databaseError');
  }

  static String get userNameOrPasswordIncorrect {
    return 'نام کاربری یا رمز اشتباه است';
  }

  static String get errorOccurredInSubmittedParameters {
    return httpMessage('errorOccurredInSubmittedParameters');
  }

  static String get dataNotFound {
    return httpMessage('dataNotFound');
  }

  static String get thisRequestNotDefined {
    return httpMessage('thisRequestNotDefined');
  }

  static String get informationWasSend {
    return httpMessage('informationWasSend');
  }

  static String get errorUploadingData {
    return httpMessage('errorUploadingData');
  }

  static String get netConnectionIsDisconnect {
    return 'اینترنت شما قطع است';
  }

  static String get errorCommunicatingServer {
    return httpMessage('errorCommunicatingServer');
  }

  static String get serverNotRespondProperly {
    return httpMessage('serverNotRespondProperly');
  }

  static String get accountIsBlock {
    return httpMessage('accountIsBlock');
  }

  static String get operationCannotBePerformed {
    return operationMessage('operationCannotBePerformed');
  }

  static String get operationSuccess {
    return operationMessage('successOperation');
  }

  static String get operationFailed {
    return operationMessage('operationFailed');
  }

  static String get operationFailedTryAgain {
    return operationMessage('operationFailedTryAgain');
  }

  static String get operationCanceled {
    return operationMessage('operationCanceled');
  }

  static String get sorryYouDoNotHaveAccess {
     return 'متاسفانه شما اجازه ی دسترسی ندارید';
  }

  static String get youMustRegister {
    return _getContext().tC('youMustRegister')?? _noText;
  }

  static String get thereAreNoResults {
    return 'نتیجه ای یافت نشد';
  }
  
  static String get requestDataIsNotJson {
    return 'داده از نوع جیسان نیست';
  }
  
  static String get enterCountryCode {
    return 'کد کشور را وارد کنید';
  }

  static String get unKnow {
    return _getContext().t('unknown')?? _noText;
  }

  static String get open {
    return _getContext().t('open')?? _noText;
  }

  static String get close {
    return _getContext().t('close')?? _noText;
  }

  ///-----------------------------------------------------------------------------------
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
