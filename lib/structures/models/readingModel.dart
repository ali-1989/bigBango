import 'package:app/structures/models/vocabModels/idiomInReadingModel.dart';
import 'package:app/structures/models/vocabModels/vocabInReadingModel.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:app/structures/models/mediaModel.dart';

class ReadingModel {
  String id = '';
  String title = '';
  String titleTranslation = '';
  int order = 0;
  MediaModel? media;
  List<SegmentOfReadingModel> segments = [];
  List<IdiomInReadingModel> clickableIdioms = [];
  List<VocabInReadingModel> clickableVocabs = [];
  ///------------------------------------
  List<ReadingTextSplitHolder> textSplits = [];
  List<ReadingTextSplitHolder> translateSplits = [];
  //List<InlineSpan> spans = [];
  //List<InlineSpan> spansTranslate = [];

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
        clickableVocabs.add(s);
      }
    }

    if(map['idioms'] is List) {
      for(final itm in map['idioms']){
        final s = IdiomInReadingModel.fromMap(itm);
        clickableIdioms.add(s);
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
    map['vocabularies'] = clickableIdioms.map((e) => e.toMap()).toList();
    map['idioms'] = clickableIdioms.map((e) => e.toMap()).toList();

    return map;
  }

  List<InlineSpan> genTranslateSpans(String segmentId, TextStyle normalStyle, TextStyle readStyle){
    List<InlineSpan> res = [];

    for(final i in translateSplits) {
      final st = TextSpan(text: '${i.text} ', style: i.segmentId == segmentId ? readStyle : normalStyle);
      res.add(st);
    }

    return res;
  }

  List<InlineSpan> genSpans(String segmentId, TextStyle normalStyle, TextStyle readStyle, TextStyle clickableStyle){
    List<InlineSpan> res = [];

    for(final i in textSplits) {
      final st = TextSpan(text: '${i.text} ', style: i.segmentId == segmentId ? readStyle : normalStyle);
      res.add(st);
    }

    return res;
  }

  void _splits(){
    translateSplits.clear();
    textSplits.clear();

    for(int i=0; i < segments.length; i++) {
      final segment = segments[i];
      final tsh = ReadingTextSplitHolder();
      tsh.segmentId = segment.id;
      tsh.text = segment.translation?? '';
      tsh.order = i;

      translateSplits.add(tsh);
    }

    ///-----------------------------------------------------
    int c = 0;
    List<ReadingTextSplitHolder> temp = [];

    for(final segment in segments) {
      final txt = segment.text!;

      for(final idm in clickableIdioms){
        if(txt.contains(idm.content)){
            final splits = txt.split(idm.content);

            for(final x in splits){

              final tsh = ReadingTextSplitHolder();
              tsh.segmentId = segment.id;
              tsh.text = x;
              tsh.order = c++;

              if(x == idm.content){
                tsh.isClickable = true;
                tsh.idiom = idm;
              }

              temp.add(tsh);
            }
        }
        else {
          final tsh = ReadingTextSplitHolder();
          tsh.segmentId = segment.id;
          tsh.text = txt;
          tsh.order = c++;

          temp.add(tsh);
        }
      }


      for(final holder in temp){
        if(holder.isClickable){
          textSplits.add(holder);
        }
        else {
          for (final voc in clickableVocabs) {
            if (holder.text.contains(voc.word)) {
              final splits = holder.text.split(voc.word);

              for (final x in splits) {
                final tsh = ReadingTextSplitHolder();
                tsh.segmentId = segment.id;
                tsh.text = x;
                tsh.order = c++;

                if(x == holder.text){
                  tsh.isClickable = true;
                  tsh.vocab = voc;
                }

                textSplits.add(tsh);
              }
            }
            else {
              /*final tsh = ReadingTextSplitHolder();
              tsh.segmentId = segment.id;
              tsh.text = holder.text;
              tsh.order = c++;*/
              textSplits.add(holder);
            }
          }
        }
      }
    }
  }

  /*void prepareSpan(int readIndex, TextStyle normalStyle, TextStyle readStyle, TextStyle clickableStyle){
    for(int i=0; i<segments.length; i++){
      final k = segments[i];

      final st = TextSpan(text: '${k.translation} ', style: i == readIndex ? readStyle : normalStyle);
      spansTranslate.add(st);

      bool containVocabClickable = false;
      bool containIdiomClickable = false;

      for(final w in clickableVocabs){
        if(k.text!.contains(w.word)){
          containVocabClickable = true;
          break;
        }
      }

      for(final w in clickableIdioms){
        if(k.text!.contains(w.content)){
          containIdiomClickable = true;
          break;
        }
      }

      if(!containVocabClickable && !containIdiomClickable) {
        final s = TextSpan(text: '${k.text} ', style: i == readIndex ? readStyle : normalStyle);
        spans.add(s);
      }
      else {
        if(containIdiomClickable) {

        }

        if(containIdiomClickable) {
          final splits = k.text!.split(' ');
          final List<InlineSpan> subSpan = [];

          for(final k in splits){
            final s = TextSpan(text: '$k ', style: i == readIndex ? readStyle : normalStyle);
            subSpan.add(s);
          }

          for(final w in clickableVocabs){
            for(final ss in subSpan){
              if(ss.toPlainText() == w.word){
                var idx = spans.indexOf(ss);
                spans.removeAt(idx);

                final s = TextSpan(text: '${w.word} ',
                  style: clickableStyle,
                  recognizer: TapGestureRecognizer()..onTap = (){
                    print('==== tap vocab');
                  },
                );
                spans.insert(idx, s);
              }
            }
          }

          spans.addAll(subSpan);
        }
      }
    }
  }*/
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
}
