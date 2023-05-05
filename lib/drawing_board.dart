// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paint_app/file_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_paint_app/draw_line_painter.dart';

import 'const.dart';
import 'data/colors.dart';

class DrawingBoard extends StatefulWidget {
  final Color themeColor;
  Function(Color color) onColorChange;
  DrawingBoard({
    Key? key,
    required this.onColorChange,
    required this.themeColor,
  }) : super(key: key);

  @override
  State<DrawingBoard> createState() => _DrawingBoardState();
}

class _DrawingBoardState extends State<DrawingBoard> with TickerProviderStateMixin {
  late AnimationController _animationController;

  final GlobalKey _drawAreaKey = GlobalKey();
  Size _drawSize = const Size(0, 0);

  late Color selectedColor;
  double strokeWidth = 5;

  List<DrawingPoint> drawingPointList = [];
  List<DrawingPoint> undoPointList = [];

  bool isSaving = false;

  double contextHeight = 0;
  double contextWidth = 0;

  int fileNumber = 0;
  String fileName = "image";
  String fileType = "png";
  String fileNameSeparete = "_";

  bool _isOpen = false;

  late final SharedPreferences? prefs;
  List<File> fileList = [];

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs != null) {
      fileNumber = prefs!.getInt("count") ?? 0;
      prefs!.setInt("count", 0);
      print("prefsten alınan deger: ${prefs!.getInt("count")}");
    }
  }

  @override
  void initState() {
    super.initState();
    initSharedPref();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      RenderBox? renderBoxDrawArea;
      if (_drawAreaKey.currentContext?.findRenderObject() != null) {
        renderBoxDrawArea = _drawAreaKey.currentContext!.findRenderObject() as RenderBox;
        _drawSize = renderBoxDrawArea.size;
        print("addposframeCallback den _drawSize alındı $_drawSize");
      } else {
        print("addposframeCallback den _drawSize alınamadı");
      }
    });

    selectedColor = widget.themeColor;
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  }

  var menuItems = [];

  @override
  Widget build(BuildContext context) {
    contextHeight = MediaQuery.of(context).size.height;
    contextWidth = MediaQuery.of(context).size.width;
    //   print("contextWidth: $contextWidth");
    //   print("contextHeight: $contextHeight");

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            _paintArea(),
            Positioned(
              top: 0,
              left: 10.w,
              right: 10.w,
              child: _buildMenuBar(),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: _colorSelectBar(),
    );
  }

  Container _buildMenuBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        color: selectedColor == Colors.white ? Colors.black26 : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSlider(),
          _undoButton(),
          _redoButton(),
          _buildPopUpColorChose(),
          _buildPopUpMenu(),
        ],
      ),
    );
  }

  Widget _paintArea() {
    //383,
    return Padding(
      padding: EdgeInsets.only(top: 50.h, left: 10.w, right: 10.w, bottom: 5.h),
      child: GestureDetector(
        onPanStart: (details) {
          print("onPanStart");

          // DrawingPainter drawPaint = DrawingPainter();
          Offset onPanPosition = details.localPosition;

          if (onPanPosition.dx > 1 &&
              onPanPosition.dx < _drawSize.width - 1 &&
              onPanPosition.dy > 1 &&
              onPanPosition.dy < _drawSize.height - 1) {
            Paint paint = Paint()
              ..color = selectedColor
              ..strokeWidth = strokeWidth
              ..isAntiAlias = true
              ..strokeCap = StrokeCap.round
              ..style = PaintingStyle.stroke;

            // drawPaint.addPoint(DrawingPoint(offset: onPanPosition, paint: paint));

            print("point eklendi");
            drawingPointList.add(DrawingPoint(offset: onPanPosition, paint: paint));
            setState(() {

            });
          }
        },
        onPanUpdate: (details) {
          print("onPanUpdate");
          Offset onPanPosition = details.localPosition;

          if (onPanPosition.dx > 1 &&
              onPanPosition.dx < _drawSize.width - 1 &&
              onPanPosition.dy > 1 &&
              onPanPosition.dy < _drawSize.height - 1) {
            Paint paint = Paint()
              ..color = selectedColor
              ..strokeWidth = strokeWidth
              ..isAntiAlias = true
              ..strokeCap = StrokeCap.round
              ..style = PaintingStyle.stroke;

            // drawPaint.addPoint(DrawingPoint(offset: onPanPosition, paint: paint));
            drawingPointList.add(DrawingPoint(offset: onPanPosition, paint: paint));
            setState(() {

            });
          }
        },
        onPanEnd: (details) {
          // print("onPanEnd");
          // drawPaint.addPoint(DrawingPoint());
          drawingPointList.add(DrawingPoint());
        //  setState(() {});
        },
        onPanCancel: () {
          //  print("onPanCancel");
        },
        child: Container(
          key: _drawAreaKey,
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [
            BoxShadow(
                color: selectedColor == Colors.white ? Colors.grey : selectedColor,
                blurRadius: 6,
                spreadRadius: 1,
                blurStyle: BlurStyle.normal),
          ]
              // border: Border.all(width: 2, color: Colors.black38),
              ),
          child: RepaintBoundary(
            child: CustomPaint(
                isComplex: true,
                willChange: false,
                painter: DrawingPainter(drawingPointList: drawingPointList, drawSize: _drawSize),
                size: Size(contextWidth, 703)),
          ),
        ),
      ),
    );
  }

  Widget _buildPopUpColorChose() {
    return PopupMenuButton(
      icon: Icon(
        Icons.color_lens_rounded,
        size: 34.sp,
      ),
      itemBuilder: (context) {
        return [
          ...Cons.colors.map((color) => PopupMenuItem(
                onTap: () {
                  setState(() {
                    selectedColor = color;
                    widget.onColorChange(color);
                  });
                },
                child: _buildPopColorContainer(color),
              ))
        ];
      },
    );
  }

  Widget _buildPopColorContainer(Color color) {
    bool isSelected = selectedColor == color;
    return Container(
      height: isSelected ? 50.sp : 35.sp,
      width: isSelected ? 50.sp : 35.sp,
      margin: EdgeInsets.all(3.sp),
      decoration: BoxDecoration(
        border: Border.all(color: color == Colors.white ? Colors.black12 : Colors.white, width: 3.sp),
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Future<void> _saveDrawImage() async {
    setState(() {
      isSaving = !isSaving;
    });
    var recorder = ui.PictureRecorder();
    var canvas = Canvas(recorder);

    var painter = DrawingPainter(drawingPointList: drawingPointList, drawSize: _drawSize);
    painter.paint(canvas, _drawSize);

    var picture = recorder.endRecording();
    var image = await picture.toImage(_drawSize.width.toInt(), _drawSize.height.toInt());
    var bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    String filePath = (await pathProvider.getApplicationDocumentsDirectory()).path;

    bool result = false;
    if (!result) {
      fileNumber++;
    }

    String fullFileName = "${fileName}_$fileNumber.$fileType";
    String fullPath = "$filePath/$fullFileName";
    File file = File(fullPath);

    if (bytes != null) {
      result = fileListCheck(filePath, fullFileName);

      if (result) {
        fileNumber++;
        fullFileName = "${fileName}_$fileNumber.$fileType";
        print("new file name: $fullFileName");
        _saveDrawImage();
      } else {
        print("kayıt edildi" + fullFileName);
        await file.writeAsBytes(bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
        prefs?.setInt("count", fileNumber);
      }
      // ignore: use_build_context_synchronously
      Cons.snackShow(context, "${getFileName(file.path)} kaydedildi ");
    } else {
      // ignore: use_build_context_synchronously
      Cons.snackShow(context, "not found data");
    }

    setState(() {
      isSaving = !isSaving;
    });
  }

  String getFileName(String path) => path.split("/").last;

  String getFileNumber(String path) => path.split("/").last.split(".").first.split("_").last;

  bool fileListCheck(String filePath, String fileName) {
    print("--------------directoryFileListPrint-----------");
    final directory = Directory(filePath);
    List<FileSystemEntity> files = directory.listSync();

    var fileNameList = [];
    for (FileSystemEntity file in files) {
      // print(getFileName(file.path));
      fileNameList.add(getFileName(file.path));
    }
    return fileNameList.contains(fileName);
  }

  void _openImage(File file) {
    OpenFile.open(file.path);
  }

  void _openImageListShowBottomSheet() async {
    await _loadSavedImageFile();

    if (fileList.isEmpty) {
      // ignore: use_build_context_synchronously
      Cons.snackShow(context, "Kayıtlı resim bulunamadı", duration: const Duration(seconds: 1));
      return;
    }
    // ignore: use_build_context_synchronously
    showModalBottomSheet(
      context: context,
      constraints: BoxConstraints(maxHeight: (contextHeight / 2).h),
      elevation: 4,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(8.sp),
          child: Column(
            children: [
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    height: 4.h,
                    width: 100.w,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20.r)),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Expanded(
                child: _buildImageFileList(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageFileList(BuildContext context) {
    return SlidableAutoCloseBehavior(
      closeWhenOpened: false,
      child: ListView.builder(
          itemCount: fileList.length,
          itemBuilder: (context, index) {
            File file = fileList[index];
            return Card(
              child: Slidable(
                closeOnScroll: false,
                direction: Axis.horizontal,
                dragStartBehavior: DragStartBehavior.start,
                enabled: true,
                key: ValueKey(file.path),
                startActionPane: ActionPane(
                  //openThreshold: 0.15,
                  //closeThreshold: 0.15,
                  dragDismissible: true,
                  extentRatio: 0.3,
                  motion: const StretchMotion(),

                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        _onShare(file.path);
                      },
                      backgroundColor: const Color(0xFF21B7CA),
                      foregroundColor: Colors.white,
                      icon: Icons.share,
                      label: 'Paylaş',
                    ),
                  ],
                ),
                endActionPane: ActionPane(
                    extentRatio: 0.3,
                    motion: const StretchMotion(),
                    dismissible: DismissiblePane(
                      onDismissed: () {
                        _deleteFile(file, index);
                      },
                    ),
                    children: [
                      Builder(builder: (context) {
                        return SlidableAction(
                          onPressed: (context) {
                            var slidableController = Slidable.of(context)!;
                            slidableController.dismiss(ResizeRequest(const Duration(milliseconds: 300), () {
                              _deleteFile(file, index);
                            }));
                          },
                          autoClose: false,
                          backgroundColor: Color(0xFFFE4A49),
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Sil',
                        );
                      }),
                    ]),
                child: Builder(builder: (context) {
                  return ListTile(
                    onTap: () {
                      _openImage(file);
                      _openDraw();
                    },
                    leading: Container(
                        decoration: BoxDecoration(border: Border.all(color: Colors.black26, width: 1.sp)),
                        child: Image.file(file)),
                    title: Text(
                      getFileName(file.path),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    subtitle: Row(
                      children: [
                        FutureBuilder<DateTime>(
                          future: file.lastModified(),
                          initialData: DateTime.now(),
                          builder: (context, snapshot) {
                            if (snapshot.data != null) {
                              var year = snapshot.data?.year;
                              var month = snapshot.data?.month;
                              var day = snapshot.data?.day;
                              var date = "$day-$month-$year";

                              return Text(
                                date,
                                style: Theme.of(context).textTheme.bodySmall,
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                        const Text(" "),
                        FutureBuilder<int>(
                          future: file.length(),
                          initialData: 0,
                          builder: (context, snapshot) {
                            if (snapshot.data != null) {
                              String? size = double.tryParse("${(snapshot.data ?? 0) / 1024}")?.toStringAsFixed(1);

                              return Text(
                                "$size" "kb",
                                style: Theme.of(context).textTheme.bodySmall,
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ],
                    ),
                  );
                }),
              ),
            );
          }),
    );
  }

  PopupMenuButton<dynamic> _buildPopUpMenu() {
    return PopupMenuButton(
      offset: Offset(-20.w, 50.h),
      child: AnimatedIcon(
        progress: _animationController,
        icon: AnimatedIcons.menu_close,
        color: Theme.of(context).primaryColor,
        size: 40.sp,
      ),
      onOpened: () {
        setState(() {
          if (_isOpen) {
            _isOpen = !_isOpen;
            _animationController.reverse();
          } else {
            _isOpen = !_isOpen;
            _animationController.forward();
          }
        });
      },
      onCanceled: () {
        setState(() {
          if (_isOpen) {
            _isOpen = !_isOpen;
            _animationController.reverse();
          } else {
            _isOpen = !_isOpen;
            _animationController.forward();
          }
        });
      },
      onSelected: (value) {
        print("value");
      },
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            onTap: () {
              print("Aç");
              _openImageListShowBottomSheet();
            },
            child: Row(
              children: [
                Container(
                    padding: EdgeInsets.all(6.sp),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      color: selectedColor == Colors.white ? Colors.black26 : null,
                    ),
                    child: const Icon(Icons.folder_open)),
                SizedBox(width: 20.w),
                Text(
                  "Aç",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          PopupMenuItem(
            onTap: () {
              print("Kaydet");
              _saveDrawImage();
            },
            child: Row(
              children: [
                Container(
                    padding: EdgeInsets.all(6.sp),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      color: selectedColor == Colors.white ? Colors.black26 : null,
                    ),
                    child: const Icon(Icons.save)),
                SizedBox(width: 20.w),
                Text(
                  "Kaydet",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          PopupMenuItem(
            onTap: () {
              print("Temizle");

              setState(() {
                drawingPointList.clear();
                undoPointList.clear();
              });
            },
            child: Row(
              children: [
                Container(
                    padding: EdgeInsets.all(6.sp),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      color: selectedColor == Colors.white ? Colors.black26 : null,
                    ),
                    child: const Icon(Icons.clear)),
                SizedBox(width: 20.w),
                Text(
                  "Temizle",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ];
      },
    );
  }

  Expanded _buildSlider() {
    return Expanded(
      child: Slider(
        thumbColor: Theme.of(context).primaryColor,
        activeColor: Theme.of(context).primaryColor,
        overlayColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
        inactiveColor: Theme.of(context).primaryColor.withOpacity(0.25),
        value: strokeWidth,
        max: 25,
        min: 1,
        onChanged: (value) {
          setState(() {
            strokeWidth = value;
          });
        },
      ),
    );
  }

  void _deleteFile(File file, int index) async {
    await file.delete();

    fileList.removeWhere(
      (element) {
        return element.path == file.path;
      },
    );

    if (fileList.isEmpty) {
      Navigator.pop(context);
      fileNumber = 0;
      prefs?.setInt("count", fileNumber);
    }
  }

  void _openDraw() {}

  _undoButton() {
    return IconButton(
        iconSize: 34.sp,
        onPressed: drawingPointList.isEmpty == true
            ? null
            : () {
                if (drawingPointList.isNotEmpty) {
                  undoPointList.add(drawingPointList.last);
                  drawingPointList.removeLast();
                }

                var reverseDraw = drawingPointList.reversed.toList();
                var lastPoint = false;
                for (var draw in reverseDraw) {
                  if (draw.offset != null && lastPoint == false) {
                    drawingPointList.removeWhere((element) => element.offset == draw.offset);

                    undoPointList.add(draw);
                  }
                  if (draw.offset == null) {
                    lastPoint = true;
                  }
                }
                setState(() {});
              },
        icon: const Icon(Icons.undo));
  }

  _redoButton() {
    return IconButton(
        onPressed: undoPointList.isEmpty
            ? null
            : () {
                setState(() {
                  var reverseList = undoPointList.reversed.toList();
                  int count = 0;
                  bool nullPoint = false;
                  for (var draw in reverseList) {
                    if (draw.offset != null && nullPoint == false) {
                      undoPointList.removeWhere((element) => element.offset == draw.offset);

                      drawingPointList.add(draw);
                    }

                    if (draw.offset == null) {
                      nullPoint = true;

                      if (count == 0) {
                        drawingPointList.add(undoPointList.last);
                        undoPointList.removeLast();
                        count++;
                      }
                    }
                  }
                });
              },
        icon: Icon(
          Icons.redo_outlined,
          size: 34.sp,
        ));
  }

  Future<void> _loadSavedImageFile() async {
    Directory directory = await pathProvider.getApplicationDocumentsDirectory();

    List<FileSystemEntity> files = directory.listSync();
    fileList = [];

    for (FileSystemEntity fileEntity in files) {
      File file = File(fileEntity.path);
      fileList.add(file);
    }

    fileList.sort(
      (a, b) {
        int? aa = int.tryParse(getFileNumber(a.path)) ?? 0;
        int? bb = int.tryParse(getFileNumber(b.path)) ?? 0;
        return aa.compareTo(bb);
      },
    );

    // fileList = fileList.reversed.toList();
  }

  void _onShare(String filePath) {
    //Share.shareWithResult("deneme");
    Share.shareFiles([filePath], text: 'Great picture');
    // Share.shareXFiles([XFile(filePath)], text: getFileName(filePath));
  }
}
