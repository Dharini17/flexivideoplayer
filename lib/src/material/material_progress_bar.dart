import 'package:flexivideoplayer/src/flexi_progress_colors.dart';
import 'package:flexivideoplayer/src/progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MaterialVideoProgressBar extends StatelessWidget {
  MaterialVideoProgressBar(
    this.controller, {
    this.height = kToolbarHeight,
    FlexiProgressColors? colors,
    this.onDragEnd,
    this.onDragStart,
    this.onDragUpdate,
    Key? key,
  })  : colors = colors ?? FlexiProgressColors(),
        super(key: key);

  final double height;
  final VideoPlayerController controller;
  final FlexiProgressColors colors;
  final Function()? onDragStart;
  final Function()? onDragEnd;
  final Function()? onDragUpdate;

  @override
  Widget build(BuildContext context) {
    return VideoProgressBar(
      controller,
      barHeight: 10,
      handleHeight: 6,
      drawShadow: true,
      colors: colors,
      onDragEnd: onDragEnd,
      onDragStart: onDragStart,
      onDragUpdate: onDragUpdate,
    );
  }
}
