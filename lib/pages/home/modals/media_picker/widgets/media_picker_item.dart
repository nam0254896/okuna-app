import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class OBMediaPickerItem extends StatefulWidget {
  final AssetEntity mediaAsset;
  final ValueChanged<AssetEntity> onPressed;

  const OBMediaPickerItem({Key key, @required this.mediaAsset, this.onPressed})
      : super(key: key);

  @override
  OBMediaPickerItemState createState() {
    return OBMediaPickerItemState();
  }
}

class OBMediaPickerItemState extends State<OBMediaPickerItem> {
  bool _needsBootstrap;
  Uint8List _thumbnailData;
  AssetType _type;
  Duration _duration;

  @override
  void initState() {
    super.initState();
    _type = widget.mediaAsset.type;
    _needsBootstrap = true;
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      _bootstrap();
      _needsBootstrap = false;
    }

    return _thumbnailData == null
        ? const SizedBox()
        : GestureDetector(
            onTap: _onPressed,
            child: Image.memory(
              _thumbnailData,
              fit: BoxFit.cover,
            ),
          );
  }

  void _onPressed() {
    if (widget.onPressed != null) widget.onPressed(widget.mediaAsset);
  }

  void _bootstrap() async {
    List<dynamic> results = await Future.wait([
      widget.mediaAsset.thumbData,
      widget.mediaAsset.videoDuration,
    ]);

    Uint8List thumbnailBytes = results[0];
    Duration duration = results[1];

    setState(() {
      _thumbnailData = thumbnailBytes;
      _duration = duration;
    });
  }
}
