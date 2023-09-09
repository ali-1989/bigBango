import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/api/generator.dart';

import 'package:app/structures/models/examModels/examModel.dart';
import 'package:app/structures/models/mediaModel.dart';
import 'package:app/structures/models/vocabModels/idiomInReadingModel.dart';
import 'package:app/structures/models/vocabModels/vocabInReadingModel.dart';
import 'package:app/system/extensions.dart';

class ReadingModel {
  String id = '';
  String title = '';
  String titleTranslation = '';
  int order = 0;
  MediaModel? media;
  List<SegmentOfReadingModel> segments = [];
  List<IdiomInReadingModel> clickableIdioms = [];
  List<VocabInReadingModel> clickableVocabsOrg = [];
  List<ExamModel> exerciseList = [];

  ///----------------- local
  List<VocabInReadingModel> clickableVocabsScope = [];
  List<ReadingTextSplitHolder> textSplits = [];
  List<ReadingTextSplitHolder> translateSplits = [];

  ReadingModel();

  ReadingModel.fromMap(Map map) {
    id = map['id'];
    title = map['title'];
    titleTranslation = map['translation']?? '';
    order = map['order']?? 0;

    if(map['voice'] is Map) {
      media = MediaModel.fromMap(map['voice']);
    }

    if(map['segments'] is List) {
      for(final itm in map['segments']){
        final s = SegmentOfReadingModel.fromMap(itm);
        segments.add(s);
      }
    }

    if(map['vocabularies'] is List) {
      for(final itm in map['vocabularies']){
        final s = VocabInReadingModel.fromMap(itm);
        clickableVocabsOrg.add(s);
      }

      clickableVocabsScope.addAll(clickableVocabsOrg);
    }

    if(map['idioms'] is List) {
      for(final itm in map['idioms']){
        final s = IdiomInReadingModel.fromMap(itm);
        clickableIdioms.add(s);
      }
    }

    if(map['exercises'] is List) {
      for(final itm in map['exercises']){
        //final s = ReadingExerciseModel.fromMap(itm);
        final s = ExamModel.fromMap(itm);
        exerciseList.add(s);
      }
    }

    _splits();
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map['id'] = id;
    map['title'] = title;
    map['translation'] = titleTranslation;
    map['voice'] = media?.toMap();
    map['segments'] = segments.map((e) => e.toMap()).toList();
    map['vocabularies'] = clickableVocabsOrg.map((e) => e.toMap()).toList();
    map['idioms'] = clickableIdioms.map((e) => e.toMap()).toList();
    map['exerciseCategories'] = exerciseList.map((e) => e.toMap()).toList();

    return map;
  }

  List<InlineSpan> genTranslateSpans(String segmentId, TextStyle normalStyle, TextStyle readStyle){
    List<InlineSpan> res = [];

    for(final i in translateSplits) {
      final st = TextSpan(text: i.text, style: i.segmentId == segmentId ? readStyle : normalStyle);
      res.add(st);
    }

    return res;
  }

  List<InlineSpan> genSpans(String segmentId, TextStyle normalStyle, TextStyle readStyle, TextStyle clickableStyle, Function(ReadingTextSplitHolder) onTap){
    List<InlineSpan> res = [];

    for(final i in textSplits) {
      if(i.isClickable){
        final st = TextSpan(text: i.text, style: clickableStyle, recognizer: TapGestureRecognizer()..onTap = () async {
          onTap.call(i);
        },);

        res.add(st);
      }
      else {
        final st = TextSpan(text: i.text, style: i.segmentId == segmentId ? readStyle : normalStyle);

        res.add(st);
      }
    }

    return res;
  }

  /*void _splitsOld(){
    translateSplits.clear();
    textSplits.clear();

    /// translate
    for(int i=0; i < segments.length; i++) {
      final segment = segments[i];
      final tsh = ReadingTextSplitHolder();
      tsh.segmentId = segment.id;
      tsh.text = segment.translation?? '';
      tsh.order = i;

      translateSplits.add(tsh);
    }

    ///------- text
    int c = 0;
    List<ReadingTextSplitHolder> txtTemp = [];
    for(final segment in segments) {
      final txt = segment.text!;
      txtTemp.clear();

      for(final idm in clickableIdioms){
        if(txt.contains(idm.content)){
            final splits = splitForIdiom(txt, idm.content);

            for(final x in splits){
              final tsh = ReadingTextSplitHolder();
              tsh.segmentId = segment.id;
              tsh.text = x;
              tsh.order = c++;

              if(x == idm.content){
                tsh.isClickable = true;
                tsh.idiom = idm;
              }

              txtTemp.add(tsh);
            }
        }
        else {
          final tsh = ReadingTextSplitHolder();
          tsh.segmentId = segment.id;
          tsh.text = txt;
          tsh.order = c++;

          txtTemp.add(tsh);
        }
      }

      if(clickableIdioms.isEmpty){
        final tsh = ReadingTextSplitHolder();
        tsh.segmentId = segment.id;
        tsh.text = txt;
        tsh.order = c++;

        txtTemp.add(tsh);
      }

      for(final holder in txtTemp){
        if(holder.isClickable){
          textSplits.add(holder);
        }
        else {
          final vIndex = getVocabIndex(holder.text, clickableVocabsScope);

          if(vIndex.isEmpty){
            final tsh = ReadingTextSplitHolder();
            tsh.segmentId = segment.id;
            tsh.text = holder.text;
            tsh.order = c++;

            textSplits.add(tsh);
          }
          else {
            for(final x in vIndex){
              clickableVocabsScope.removeWhere((element) => element.id == x.vocab.id);
            }

            bool notVocab = false;
            int lastIdx = 0;

            for (int i=0; i< holder.text.length; i++) {
              var d = vIndex.firstWhereSafe((element) => element.start == i);

              if(d == null){
                notVocab = true;
                continue;
              }

              if(notVocab){
                final tsh = ReadingTextSplitHolder();
                tsh.segmentId = segment.id;
                tsh.text = holder.text.substring(lastIdx, d.start);
                tsh.order = c++;

                textSplits.add(tsh);

                notVocab = false;
              }

              final tsh = ReadingTextSplitHolder();
              tsh.segmentId = segment.id;
              tsh.text = d.vocab.word;
              tsh.order = c++;
              tsh.isClickable = true;
              tsh.vocab = d.vocab;

              textSplits.add(tsh);

              i += d.vocab.word.length;
              lastIdx = i;
              //i--;
            }

            if(notVocab){
              final tsh = ReadingTextSplitHolder();
              tsh.segmentId = segment.id;
              tsh.text = holder.text.substring(lastIdx);
              tsh.order = c++;
              textSplits.add(tsh);

              notVocab = false;
            }
          }
        }
      }
    }
  }*/

  void _splits(){
    translateSplits.clear();
    textSplits.clear();

    /// translate
    for(int i=0; i < segments.length; i++) {
      final segment = segments[i];
      final tsh = ReadingTextSplitHolder();
      tsh.segmentId = segment.id;
      tsh.text = segment.translation?? '';
      tsh.order = i;

      translateSplits.add(tsh);
    }

    ///------- text
    final twoDList = <List<ReadingTextSplitHolder>>[];
    var inSideList = <ReadingTextSplitHolder>[];


    for(final segment in segments) {
      inSideList = <ReadingTextSplitHolder>[];
      final txt = segment.text!;

      /// if there is not any idioms, all of text will be a sentence
      if(clickableIdioms.isEmpty){
        final tsh = ReadingTextSplitHolder();
        tsh.segmentId = segment.id;
        tsh.text = txt;

        inSideList.add(tsh);
      }
      else {
        final splits = splitForIdiom(txt, clickableIdioms);
        final idiomHolders = <ReadingTextSplitHolder>[];

        if(splits.isEmpty){
          final tsh = ReadingTextSplitHolder();
          tsh.segmentId = segment.id;
          tsh.text = txt;

          idiomHolders.add(tsh);
        }
        else {
          bool notVocab = false;
          int lastIdx = 0;

          for (int i=0; i< txt.length; i++) {
            var findIdiom = splits.firstWhereSafe((idiom) => idiom.start == i);

            if(findIdiom != null) {
              if (notVocab) {
                final tsh = ReadingTextSplitHolder();
                tsh.segmentId = segment.id;
                tsh.text = txt.substring(lastIdx, findIdiom.start);

                idiomHolders.add(tsh);
                notVocab = false;
              }

              final tsh = ReadingTextSplitHolder();
              tsh.segmentId = segment.id;
              tsh.text = findIdiom.idiom.content;
              tsh.isClickable = true;
              tsh.idiom = findIdiom.idiom;

              idiomHolders.add(tsh);

              i += findIdiom.idiom.content.length;
              lastIdx = i;
            }

            else {
              notVocab = true;
            }
          }
        }

        inSideList.addAll(idiomHolders);
      }

      ///===================================
      for(var k=0; k < inSideList.length; k++){
        final sentence = inSideList[k];

        if(sentence.isClickable){
          continue;
        }

        final vocabList = splitForVocab(sentence.text, clickableVocabsScope);

        if(vocabList.isEmpty){
          continue;
        }

        /// So that each word can be clicked in only one section
        for(final x in vocabList){
          clickableVocabsScope.removeWhere((element) => element.id == x.vocab.id);
        }

        inSideList.removeAt(k);
        final vocabHolders = <ReadingTextSplitHolder>[];

        bool notVocab = false;
        int lastIdx = 0;

        for (int i=0; i< sentence.text.length; i++) {
          var findVocab = vocabList.firstWhereSafe((vocab) => vocab.start == i);

          if(findVocab != null) {
            if (notVocab) {
              final tsh = ReadingTextSplitHolder();
              tsh.segmentId = segment.id;
              tsh.text = sentence.text.substring(lastIdx, findVocab.start);

              vocabHolders.add(tsh);
              notVocab = false;
            }

            final tsh = ReadingTextSplitHolder();
            tsh.segmentId = segment.id;
            tsh.text = findVocab.vocab.word;

            tsh.isClickable = true;
            tsh.vocab = findVocab.vocab;

            vocabHolders.add(tsh);

            i += findVocab.vocab.word.length;
           lastIdx = i;
          }
          else {
            notVocab = true;
          }
        }

        if(notVocab){
          final tsh = ReadingTextSplitHolder();
          tsh.segmentId = segment.id;
          tsh.text = sentence.text.substring(lastIdx);

          vocabHolders.add(tsh);
        }

        inSideList.insertAll(k, vocabHolders);
      }


      twoDList.add(inSideList);
    }

    for(final lis in twoDList){
      textSplits.addAll(lis);
    }
  }

  List<IdiomIndexModel> splitForIdiom(String txt, List<IdiomInReadingModel> idiomList){
    final List<IdiomIndexModel> res = [];

    for(final idiom in idiomList){
      int c = 0;

      while(true){
        if(c + idiom.content.length > txt.length){
          break;
        }

        var t = txt.substring(c, c + idiom.content.length);

        if(t == idiom.content || t.toLowerCase() == idiom.content.toLowerCase()){
          final m = IdiomIndexModel();
          m.start = c;
          m.end = c + idiom.content.length;
          m.idiom = idiom;

          res.add(m);
          break;
        }
        else {
          c++;
        }
      }
    }

    List<String> remove = [];

    for(final k1 in res){
      for(final k2 in res){
        if(k1.id == k2.id){
          continue;
        }

        if(k2.start >= k1.start && k2.start < k1.end){
          if(k1.idiom.content.length < k2.idiom.content.length){
            remove.add(k1.id);
          }
          else {
            remove.add(k2.id);
          }
        }
      }
    }

    for(final r in remove){
      res.removeWhere((element) => element.id == r);
    }

    res.sort((e1, e2){
      if(e1.start < e2.start){
        return 1;
      }

      return -1;
    });

    return res;
  }

  List<VocabIndexModel> splitForVocab(String txt, List<VocabInReadingModel> vocabList){
    final List<VocabIndexModel> res = [];

    for(final k in vocabList){
      int c = 0;

      while(true){
        if(c + k.word.length > txt.length){
          break;
        }

        var t = txt.substring(c, c + k.word.length);

        if(t == k.word || t.toLowerCase() == k.word.toLowerCase()){
          final m = VocabIndexModel();
          m.start = c;
          m.end = c + k.word.length;
          m.vocab = k;

          res.add(m);
          break;
        }
        else {
          c++;
        }
      }
    }

    List<String> remove = [];

    for(final k1 in res){
      for(final k2 in res){
        if(k1.id == k2.id){
          continue;
        }
        if(k2.start >= k1.start && k2.start < k1.end){
          if(k1.vocab.word.length < k2.vocab.word.length){
            remove.add(k1.id);
          }
          else {
            remove.add(k2.id);
          }
        }
      }
    }

    for(final r in remove){
      res.removeWhere((element) => element.id == r);
    }

    res.sort((e1, e2){
      if(e1.start < e2.start){
        return 1;
      }

      return -1;
    });

    return res;
  }
}
///=====================================================================================
class SegmentOfReadingModel {
  String id = '';
  Duration? start;
  Duration? end;
  String? text;
  String? translation;

  SegmentOfReadingModel.fromMap(Map map) {
    id = map['id'];
    //start = Duration(milliseconds: ((DateHelper.tsToSystemDate('1970-01-01 ${map['start']}.0')?.millisecondsSinceEpoch)?? 0) +12600000);
    start = Duration(milliseconds: map['startMilliSeconds']);
    end = Duration(milliseconds: map['endMilliSeconds']);
    text = map['text'];
    translation = map['translation'];
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map['id'] = id;
    map['startMilliSeconds'] = start?.inMilliseconds;
    map['endMilliSeconds'] = end?.inMilliseconds;
    map['text'] = text;
    map['translation'] = translation;

    return map;
  }
}
///=====================================================================================
class ReadingTextSplitHolder {
  late String segmentId;
  late String text;
  bool isClickable = false;
  int order = 0;
  VocabInReadingModel? vocab;
  IdiomInReadingModel? idiom;

  ReadingTextSplitHolder();

  @override
  String toString(){
    return '[$text]';
  }
}
///=====================================================================================
class VocabIndexModel {
  String id;
  late int start;
  late int end;
  late VocabInReadingModel vocab;

  VocabIndexModel() : id = Generator.generateKey(6);

  @override
  String toString(){
    return 'W:${vocab.word} [$start, $end] ';
  }
}
///=====================================================================================
class IdiomIndexModel {
  String id;
  late int start;
  late int end;
  late IdiomInReadingModel idiom;

  IdiomIndexModel() : id = Generator.generateKey(6);

  @override
  String toString(){
    return 'idiom:${idiom.content} [$start, $end] ';
  }
}

/*List<String> splitForIdiom(String txt, String spl){
    final List<String> res = [];

    if(txt.length < spl.length){
      return res;
    }

    if(txt.length == spl.length){
      res.add(spl);
      return res;
    }

    int pointer = 0;
    int startIdx = -1;

    while(true){
      if(pointer + spl.length > txt.length){
        break;
      }

      var t = txt.substring(pointer, pointer + spl.length);

      if(t == spl){
        startIdx = pointer;
        break;
      }

      pointer++;
    }

    if(startIdx > -1){
      if(startIdx == 0){
        res.add(txt.substring(0, spl.length));
        res.add(txt.substring(spl.length));
      }
      else {
        res.add(txt.substring(0, startIdx));
        res.add(txt.substring(startIdx+1, startIdx + spl.length));

        if(startIdx + spl.length < txt.length) {
          res.add(txt.substring(startIdx + spl.length));
        }
      }
    }

    return res;
  }*/