import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:iris_pic_editor/pic_editor.dart';
import 'package:iris_tools/api/helpers/fileHelper.dart';
import 'package:iris_tools/features/overlayDialog.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/customCard.dart';
import 'package:iris_tools/widgets/icon/circularIcon.dart';
import 'package:iris_tools/widgets/irisImageView.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/enums/enums.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appDecoration.dart';
import 'package:app/tools/app/appDialogIris.dart';
import 'package:app/tools/app/appDirectories.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/tools/permissionTools.dart';
import 'package:app/tools/routeTools.dart';
import 'package:app/views/components/fullScreenImage.dart';
import 'package:app/views/states/emptyData.dart';

class AttachmentFileTicketComponent extends StatefulWidget {
  final List<File> files;

  const AttachmentFileTicketComponent({
    required this.files,
    Key? key,
  }) : super(key: key);

  @override
  State<AttachmentFileTicketComponent> createState() => _AttachmentFileTicketComponentState();
}
///==================================================================================================
class _AttachmentFileTicketComponentState extends StateBase<AttachmentFileTicketComponent> {
  final ScrollController srlCtr = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Assist(
        controller: assistCtr,
        builder: (_, ctr, data) {

          return Card(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: sh *3/4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 5),
                        Stack(
                          children: [
                            const SizedBox(
                              height: 22,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('فایل های پیوست پیام'),
                                ],
                              ),
                            ),

                            Positioned(
                              left: 10,
                                child: GestureDetector(
                                  onTap: (){
                                    RouteTools.popTopView(context: context);
                                  },
                                  child: CustomCard(
                                      color: Colors.grey.shade200,
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
                                      radius: 4,
                                      child: const Icon(AppIcons.close, size: 10)
                                  ),
                                ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),
                        const Divider(color: Colors.grey, indent: 20, endIndent: 20),
                        const SizedBox(height: 10),

                        Expanded(
                          child: Builder(
                            builder: (_){
                              if(widget.files.isEmpty){
                                return const EmptyData(message: 'فایلی انتخاب نشده است',);
                              }

                              return ListView.builder(
                                itemCount: widget.files.length,
                                controller: srlCtr,
                                itemBuilder: listBuilder,
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                Positioned(
                  bottom: 10,
                    left: 10,
                    child: FloatingActionButton(
                      backgroundColor: AppDecoration.red,
                      onPressed: addFileDialog,
                      mini: true,
                      child: const Icon(AppIcons.add, color: Colors.white),
                    )
                ),
              ],
            ),
          );
        }
    );
  }

  Widget listBuilder(_, idx) {
    final itm = widget.files[idx];

    return Padding(
      key: ValueKey('$idx'),
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: ColoredBox(
          color: Colors.grey.shade200,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: AspectRatio(
              aspectRatio: 3/2,
              child: Center(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: GestureDetector(
                        onTap: (){
                          showFullScreen(itm.path);
                        },
                        child: Hero(
                          tag: 'heroTag',
                          child: IrisImageView(
                            beforeLoadWidget: const Icon(AppIcons.media),
                            imagePath: itm.path,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                        top: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: (){
                            removeImage(itm);
                          },
                          child: CircularIcon(
                            backColor: Colors.grey.withAlpha(100),
                            icon: AppIcons.delete,
                            itemColor: Colors.red,
                          ),
                        )
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void addFileDialog() async {
    List<Widget> widgets = [];
    widgets.add(
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: (){
            onSelectAvatar(1);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Icon(AppIcons.camera, size: 20),
                const SizedBox(width: 12),
                const Text('دوربین').bold(),
              ],
            ),
          ),
        ));

    widgets.add(
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: (){
            onSelectAvatar(2);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Icon(AppIcons.picture, size:20),
                const SizedBox(width: 12),
                const Text('گالری').bold(),
              ],
            ),
          ),
        ));

    AppSheet.showSheetMenu(
      context,
      widgets,
      'changeAvatar',
    );
  }

  void onSelectAvatar(int state) async {
    AppSheet.closeSheet(context);

    XFile? image;

    if(state == 1){
      image = await selectImageFromCamera();
    }
    else {
      image = await selectImageFromGallery();
    }

    if(image == null){
      return;
    }

    String? path = await editImage(image.path);

    if(path != null){
      widget.files.add(File(path));
      assistCtr.updateHead();
      Future.delayed(const Duration(milliseconds: 700), (){
        srlCtr.animateTo(srlCtr.position.maxScrollExtent, curve: Curves.linear, duration: const Duration(milliseconds: 600));
      });
    }
  }

  Future<XFile?> selectImageFromCamera() async {
    final hasPermission = await PermissionTools.requestStoragePermission();

    if(hasPermission != PermissionStatus.granted) {
      return null;
    }

    final pick = await ImagePicker().pickImage(source: ImageSource.camera);

    if(pick == null) {
      return null;
    }

    return pick;
  }

  Future<XFile?> selectImageFromGallery() async {
    final hasPermission = await PermissionTools.requestStoragePermission();

    if(hasPermission != PermissionStatus.granted) {
      return null;
    }

    final pick = await ImagePicker().pickImage(source: ImageSource.gallery);

    if(pick == null) {
      return null;
    }

    return pick;
  }

  Future<String?> editImage(String imgPath) async {
    final comp = Completer<String?>();

    final editOptions = EditOptions.byFile(imgPath);
    editOptions.cropBoxInitSize = const Size(200, 170);

    void onOk(EditOptions op) async {
      final pat = AppDirectories.getSavePathByPath(SavePathType.anyOnInternal, imgPath)!;

      FileHelper.createNewFileSync(pat);
      FileHelper.writeBytesSync(pat, editOptions.imageBytes!);

      comp.complete(pat);
    }

    editOptions.callOnResult = onOk;
    final ov = OverlayScreenView(content: PicEditor(editOptions), backgroundColor: Colors.black);
    OverlayDialog().show(context, ov).then((value){
      if(!comp.isCompleted){
        comp.complete(null/*imgPath*/);
      }
    });

    return comp.future;
  }

  void removeImage(File itm) {
    bool yesFn(ctx){
      widget.files.removeWhere((element) => element.path == itm.path);
      assistCtr.updateHead();
      return false;
    }

    AppDialogIris.instance.showYesNoDialog(
        context,
      yesFn: yesFn,
      desc: 'آیا این مورد حذف شود؟',
    );
  }

  void showFullScreen(String pathOrUrl) {
    final view = FullScreenImage(
        heroTag: 'heroTag',
        imageObj: File(pathOrUrl),
        imageType: ImageType.file,
      appBarColor: Colors.black,
    );

    AppNavigator.pushNextPageExtra(context, view, name: 'FullScreenImage');
  }
}
