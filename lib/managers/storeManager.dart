// ignore_for_file: file_names

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';

import 'package:app/structures/enums/appEvents.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/lessonModels/storeModel.dart';
import 'package:app/tools/app/appSnack.dart';

class StoreManager {
	StoreManager._();

	static DateTime? _lastUpdateTime;
	static final List<StoreModel> _storeList = [];

	static void init(){
		EventNotifierService.addListener(AppEvents.languageLevelChanged, languageLevelChanged);
	}

	static void languageLevelChanged({data}){
		_lastUpdateTime = null;
	}

	static bool isUpdated({Duration duration = const Duration(minutes: 30)}) {
		var now = DateTime.now();
		now = now.subtract(duration);

		return _lastUpdateTime != null && _lastUpdateTime!.isAfter(now);
	}

	static void setUpdate({DateTime? dt}) {
		_lastUpdateTime = dt?? DateTime.now();
	}

	static void setUnUpdate() {
		_lastUpdateTime = null;
	}
	///=========================================================================================
	static List<StoreModel> getStoreLessonList() => _storeList;

	static StoreModel? getById(int id) {
		try {
			return _storeList.firstWhere((element) => element.id == id);
		}
		catch (e) {
			return null;
		}
	}

	static StoreModel addItem(StoreModel item) {
		final existItem = getById(item.id);

		if (existItem == null) {
			_storeList.add(item);
			return item;
		}
		else {
			existItem.matchBy(item);
			return existItem;
		}
	}

	static List<StoreModel> addItemsFromMap(List? itemList) {
		final res = <StoreModel>[];

		if (itemList != null) {
			for (final row in itemList) {
				final itm = StoreModel.fromMap(row);
				addItem(itm);

				res.add(itm);
			}
		}

		return res;
	}

	static Future removeItem(int id) async {
		_storeList.removeWhere((element) => element.id == id);
	}

	/*void sortList(bool asc) async {
		_storeList.sort((StoreModel p1, StoreModel p2) {
			final d1 = p1.chatSortTime;
			final d2 = p2.chatSortTime;

			if (d1 == null) {
				return asc ? 1 : 1;
			}

			if (d2 == null) {
				return asc ? 1 : 1;
			}

			return asc ? d1.compareTo(d2) : d2.compareTo(d1);
		});
	}*/

	///-----------------------------------------------------------------------------------------
	static Future<bool> requestLessonStores({BuildContext? context}) async {
		final requester = Requester();
		final res = Completer<bool>();

		requester.httpRequestEvents.onFailState = (req, response) async {
			if(context == null || !(context as Element).mounted){
				res.complete(false);
				return;
			}

			String msg = 'خطایی رخ داده است';

			if(response != null && response.data != null){
				final js = JsonHelper.jsonToMap(response.data)?? {};
				msg = js['message']?? msg;
			}

			AppSnack.showInfo(context, msg);
		};

		requester.httpRequestEvents.onStatusOk = (req, jsData) async {
			setUpdate();
			final data = jsData['data'];

			if(data is List){
				addItemsFromMap(data);
			}

			res.complete(true);
		};

		requester.methodType = MethodType.get;
		requester.prepareUrl(pathUrl: '/shop/lessons');
		requester.request(context);

		return res.future;
	}

}

