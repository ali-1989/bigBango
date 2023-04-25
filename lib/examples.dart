import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/structures/enums/walletAmountType.dart';
import 'package:app/structures/models/mediaModel.dart';
import 'package:app/structures/models/transactionWalletModel.dart';
import 'package:app/structures/models/withdrawalModel.dart';

class Examples {
  Examples._();


  static List<MediaModel> genAttachment(){
    final res = <MediaModel>[];

    final f = MediaModel();
    f.fileLocation = 'https://bigbangofiles.nicode.org/2022/12/3c42e5fdab0a4d43910640f6f681083a.PNG';
    f.fileType = 1;

    res.add(f);
    //......................
    final s = MediaModel();
    s.fileLocation = 'https://bigbangofiles.nicode.org/2022/12/fe200adb45a34cb1a2f907fd232d535f.jpg';
    s.fileType = 1;

    res.add(s);
    //......................
    final x = MediaModel();
    x.fileLocation = 'https://bigbangofiles.nicode.org/2022/12/79405d11f5464a1795934e6e8c65f5a3.jpg';
    x.fileType = 1;

    res.add(x);
    //......................
    return res;
  }

  void buildTransaction(){
    final x = TransactionWalletModel();
    x.id = 'abc';
    x.amount = 12000;
    x.description = 'fvnhaj o,f';
    x.amountType = WalletAmountType.removable;
    x.date = DateHelper.getNow();

    //transactionList.add(x);

    final x2 = TransactionWalletModel();
    x2.id = 'efg';
    x2.amount = -200;
    x2.description = 'برئاشت خوب';
    x2.amountType = WalletAmountType.unermovable;
    x2.date = DateHelper.getNow();

    //transactionList.add(x2);

    final w1 = WithdrawalModel();
    w1.id = 'efg';
    w1.amount = 200000;
    w1.description = 'برئاشت خوب';
    w1.date = DateHelper.getNow();

    //withdrawalList.add(w1);
  }
}



/*
void gotoExam(LessonModel model){

    ExamModel ee = ExamModel();
    ee.question = 'gggggg ** ffff ** ssss ** dddd';
    ee.id = 'fdfff fgfg ffgg';
    ee.quizType = QuizType.recorder;

    ee.choices = [
      ExamChoiceModel()..text = 'yes'..order=2,
      ExamChoiceModel()..text = 'no'..order = 1,
      ExamChoiceModel()..text = 'ok'..order = 0,
    ];

    ee.doSplitQuestion();
    ExamInjector examComponentInjector = ExamInjector();
    examComponentInjector.lessonModel = model;
    examComponentInjector.segmentModel = model.grammarModel!;
    examComponentInjector.examList.add(ee);

    final component = ExamSelectWordComponent(injector: examComponentInjector);

    final pageInjector = ExamPageInjector();
    pageInjector.lessonModel = model;
    pageInjector.segment = model.grammarModel!;
    pageInjector.examPage = component;
    pageInjector.description = 'ddd dff dfdf';
    final examPage = ExamPage(injector: pageInjector);

    AppRoute.pushPage(context, examPage);
  }
 */
