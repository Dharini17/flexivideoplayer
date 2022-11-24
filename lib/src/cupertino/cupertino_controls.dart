import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flexivideoplayer/src/animated_play_pause.dart';
import 'package:flexivideoplayer/src/center_play_button.dart';
import 'package:flexivideoplayer/src/flexi_player.dart';
import 'package:flexivideoplayer/src/flexi_progress_colors.dart';
import 'package:flexivideoplayer/src/cupertino/cupertino_progress_bar.dart';
import 'package:flexivideoplayer/src/cupertino/widgets/cupertino_options_dialog.dart';
import 'package:flexivideoplayer/src/helpers/utils.dart';
import 'package:flexivideoplayer/src/models/option_item.dart';
import 'package:flexivideoplayer/src/models/subtitle_model.dart';
import 'package:flexivideoplayer/src/notifiers/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:video_player/video_player.dart';
import 'package:volume_controller/volume_controller.dart';

class CupertinoControls extends StatefulWidget {
  const CupertinoControls({
    required this.backgroundColor,
    required this.iconColor,
    this.showPlayButton = true,
    Key? key,
  }) : super(key: key);

  final Color backgroundColor;
  final Color iconColor;
  final bool showPlayButton;


  @override
  State<StatefulWidget> createState() {
    return _CupertinoControlsState();
  }
}

class _CupertinoControlsState extends State<CupertinoControls>
    with SingleTickerProviderStateMixin {
  late PlayerNotifier notifier;
  late VideoPlayerValue _latestValue;
  double? _latestVolume;
  Timer? _hideTimer;
  final marginSize = 5.0;
  Timer? _expandCollapseTimer;
  Timer? _initTimer;
  bool _dragging = false;
  Duration? _subtitlesPosition;
  bool _subtitleOn = false;
  Timer? _bufferingDisplayTimer;
  bool _displayBufferingIndicator = false;

  late VideoPlayerController controller;

  Duration varDuration = Duration(milliseconds: 500);

  // We know that _chewieController is set in didChangeDependencies
  FlexiController get chewieController => _chewieController!;
  FlexiController? _chewieController;

  //custom value parameters ----------

  double _volumeListenerValue = 0;
  double _getVolume = 0;
  double _setVolumeValue = 0;

  bool isPhone = true;

  @override
  void initState() {
    super.initState();



    notifier = Provider.of<PlayerNotifier>(context, listen: false);

    //set volumn value
    // Listen to system volume change
    VolumeController().listener((volume) {
      setState(() => _volumeListenerValue = volume);
    });

    VolumeController().getVolume().then((volume) => _setVolumeValue = volume);
    VolumeController().showSystemUI = false;
  }

  Future<void> setBrightness(double brightness) async {
    try {
      await ScreenBrightness().setScreenBrightness(brightness);
    } catch (e) {
      debugPrint(e.toString());
      throw 'Failed to set brightness';
    }
  }

  @override
  Widget build(BuildContext context) {

    isPhone =  MediaQuery.of(context).size.width >= 768 ? false : true;

    if (_latestValue.hasError) {
      return chewieController.errorBuilder != null
          ? chewieController.errorBuilder!(
              context,
              chewieController.videoPlayerController.value.errorDescription!,
            )
          : const Center(
              child: Icon(
                CupertinoIcons.exclamationmark_circle,
                color: Colors.white,
                size: 42,
              ),
            );
    }

    final backgroundColor = widget.backgroundColor;
    final iconColor = widget.iconColor;
    final orientation = MediaQuery.of(context).orientation;
    final barHeight = orientation == Orientation.portrait ? 30.0 : 47.0;
    final buttonPadding = orientation == Orientation.portrait ? 16.0 : 24.0;

    return MouseRegion(
      onHover: (_) => _cancelAndRestartTimer(),
      child: GestureDetector(
        onTap: () => _cancelAndRestartTimer(),
        child: AbsorbPointer(
          absorbing: notifier.hideStuff,

          child: Stack(
            children: [

              Positioned(
                top: 0,left: 0,right: 0,bottom: 0,
                  child:Container(
                    color: Colors.black.withOpacity(notifier.hideStuff ? 0.0 : 0.8,),
                    child: Column(
                      children: [

                        _buildTopBar(
                          backgroundColor,
                          iconColor,
                          barHeight,
                          buttonPadding,
                        ),


                        Expanded(
                            child:
                            Center(
                                child:
                            _displayBufferingIndicator ?
                                          CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      )

                                :
                                _buildHitArea(),
                        )
                        ),

                        if (_subtitleOn)
                          Transform.translate(
                            offset: Offset(
                              0.0,
                              notifier.hideStuff ? barHeight * 0.8 : 0.0,
                            ),
                            child: _buildSubtitles(chewieController.subtitle!),
                          ),
                        _buildBottomBar(backgroundColor, iconColor, barHeight),

                      ],
                    ),
                  )
              ),

              // if (_displayBufferingIndicator)
              //   const Center(
              //     child: CircularProgressIndicator(
              //       strokeWidth: 2,
              //       color: Colors.white,
              //     ),
              //   )
              // else
              //   _buildHitArea(),

              // Column(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: <Widget>[
                  // _buildTopBar(
                  //   backgroundColor,
                  //   iconColor,
                  //   barHeight,
                  //   buttonPadding,
                  // ),
                  // const Spacer(),
                  // if (_subtitleOn)
                  //   Transform.translate(
                  //     offset: Offset(
                  //       0.0,
                  //       notifier.hideStuff ? barHeight * 0.8 : 0.0,
                  //     ),
                  //     child: _buildSubtitles(chewieController.subtitle!),
                  //   ),
                  // _buildBottomBar(backgroundColor, iconColor, barHeight),
              //   ],
              // ),
            ],
          ),
           //working code
           /* child: Stack(
              children: [
                if (_displayBufferingIndicator)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else
                  _buildHitArea(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _buildTopBar(
                      backgroundColor,
                      iconColor,
                      barHeight,
                      buttonPadding,
                    ),
                    const Spacer(),
                    if (_subtitleOn)
                      Transform.translate(
                        offset: Offset(
                          0.0,
                          notifier.hideStuff ? barHeight * 0.8 : 0.0,
                        ),
                        child: _buildSubtitles(chewieController.subtitle!),
                      ),
                    _buildBottomBar(backgroundColor, iconColor, barHeight),
                  ],
                ),
              ],
            ),*/

        ),
      ),
    );
  }

  @override
  void dispose() {
    _dispose();
    VolumeController().removeListener();
    super.dispose();
  }

  void _dispose() {
    controller.removeListener(_updateState);
    _hideTimer?.cancel();
    _expandCollapseTimer?.cancel();
    _initTimer?.cancel();
  }

  @override
  void didChangeDependencies() {
    final oldController = _chewieController;
    _chewieController = FlexiController.of(context);
    controller = chewieController.videoPlayerController;

    if (oldController != chewieController) {
      _dispose();
      _initialize();
    }

    super.didChangeDependencies();
  }

  GestureDetector _buildOptionsButton(
    Color iconColor,
    double barHeight,
  ) {
    final options = <OptionItem>[];

    if (chewieController.additionalOptions != null &&
        chewieController.additionalOptions!(context).isNotEmpty) {
      options.addAll(chewieController.additionalOptions!(context));
    }

    return GestureDetector(
      onTap: () async {
        _hideTimer?.cancel();

        if (chewieController.optionsBuilder != null) {
          await chewieController.optionsBuilder!(context, options);
        } else {
          await showCupertinoModalPopup<OptionItem>(
            context: context,
            semanticsDismissible: true,
            useRootNavigator: chewieController.useRootNavigator,
            builder: (context) => CupertinoOptionsDialog(
              options: options,
              cancelButtonText:
                  chewieController.optionsTranslation?.cancelButtonText,
            ),
          );
          if (_latestValue.isPlaying) {
            _startHideTimer();
          }
        }
      },
      child:
      AnimatedOpacity(
        opacity: notifier.hideStuff ? 0.0 : 1.0,
        duration: varDuration,
      child:
      Container(
        height: barHeight,
        color: Colors.transparent,
        padding: const EdgeInsets.only(left: 4.0, right: 8.0),
        margin: const EdgeInsets.only(right: 6.0),
        child: Icon(
          Icons.more_vert,
          color: iconColor,
          size: 18,
        ),
      ),
    )
    );
  }

  Widget _buildSubtitles(Subtitles subtitles) {
    if (!_subtitleOn) {
      return const SizedBox();
    }
    if (_subtitlesPosition == null) {
      return const SizedBox();
    }

    final currentSubtitle = subtitles.getByPosition(_subtitlesPosition!);
    if (currentSubtitle.isEmpty) {
      return const SizedBox();
    }

    if (chewieController.subtitleBuilder != null) {
      return chewieController.subtitleBuilder!(
        context,
        currentSubtitle.first!.text,
      );
    }

    return Padding(
      padding: EdgeInsets.only(left: marginSize, right: marginSize),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: const Color(0x96000000),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          currentSubtitle.first!.text.toString(),
          style: const TextStyle(
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildBottomBar(
    Color backgroundColor,
    Color iconColor,
    double barHeight,
  ) {
    return SafeArea(
      bottom: chewieController.isFullScreen,
      child: AnimatedOpacity(
        opacity: notifier.hideStuff ? 0.0 : 1.0,
        duration: varDuration,
        child: Container(
          color: Colors.transparent,
          alignment: Alignment.bottomCenter,
          margin: EdgeInsets.all(marginSize),
          padding: EdgeInsets.only(left: 10,right: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(
                sigmaX: 10.0,
                sigmaY: 10.0,
              ),
              child: Container(
                height: barHeight,
                color: backgroundColor,
                child: chewieController.isLive
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          _buildPlayPause(controller, iconColor, barHeight),
                          _buildLive(iconColor),
                        ],
                      )
                    : Row(
                        children: <Widget>[

                         // _buildSkipBack(iconColor, barHeight),
                          //_buildPlayPause(controller, iconColor, barHeight),
                         // _buildSkipForward(iconColor, barHeight),
                          SizedBox(width: 10,),
                          _buildPosition(iconColor),
                          _buildProgressBar(),
                          _buildRemaining(iconColor),
                          _buildSubtitleToggle(iconColor, barHeight),

                          if (chewieController.allowPlaybackSpeedChanging)
                            _buildSpeedButton(controller, iconColor, barHeight),

                          // if (chewieController.additionalOptions != null &&
                          //     chewieController
                          //         .additionalOptions!(context).isNotEmpty)
                          //   _buildOptionsButton(iconColor, barHeight),

                          _buildExpandButton(iconColor, barHeight),
                          
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLive(Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Text(
        'LIVE',
        style: TextStyle(color: iconColor, fontSize: 12.0),
      ),
    );
  }


  GestureDetector _buildExpandButton( Color iconColor,
      double barHeight,){

    return GestureDetector(
      onTap: _onExpandCollapse,
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        padding: const EdgeInsets.only(left: 4.0, right: 8.0),
        margin: const EdgeInsets.only(right: 6.0),
        child: Icon(
          chewieController.isFullScreen
                              ? Icons.fullscreen_exit_rounded
                              : Icons.fullscreen,
          color: iconColor,
          size: 18,
        ),
      ),
    );
  }

  // GestureDetector _buildExpandButton_old(
  //   Color backgroundColor,
  //   Color iconColor,
  //   double barHeight,
  //   double buttonPadding,
  // ) {
  //   return GestureDetector(
  //     onTap: _onExpandCollapse,
  //     child: AnimatedOpacity(
  //       opacity: notifier.hideStuff ? 0.0 : 1.0,
  //       duration: const Duration(milliseconds: 300),
  //       child: ClipRRect(
  //         borderRadius: BorderRadius.circular(10.0),
  //         child: BackdropFilter(
  //           filter: ui.ImageFilter.blur(sigmaX: 10.0),
  //           child: Container(
  //             height: barHeight,
  //             padding: EdgeInsets.only(
  //               left: buttonPadding,
  //               right: buttonPadding,
  //             ),
  //             color: backgroundColor,
  //             child: Center(
  //               child: Icon(
  //                 chewieController.isFullScreen
  //                     ? CupertinoIcons.arrow_down_right_arrow_up_left
  //                     : CupertinoIcons.arrow_up_left_arrow_down_right,
  //                 color: iconColor,
  //                 size: 16,
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  GestureDetector _buildBackButton(
      Color backgroundColor,
      Color iconColor,
      double barHeight,
      double buttonPadding,
      ) {
    return GestureDetector(
      onTap: (){
        Navigator.pop(context);
      },
      child: Padding(
        padding: EdgeInsets.only(left: 10),
        child:AnimatedOpacity(
          opacity: notifier.hideStuff ? 0.0 : 1.0,
          duration: varDuration,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(  sigmaX: 10.0,
                sigmaY: 10.0,),
              child: Container(
                height: barHeight,
                padding: EdgeInsets.only(
                  left: 15,//buttonPadding,
                  right: 15,//buttonPadding,
                ),
                color: backgroundColor,
                child: Center(
                  child: Icon(
                    CupertinoIcons.back,
                    color: iconColor,
                    size: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      )
    );
  }

  Widget _buildHitArea() {

    final bool isFinished = _latestValue.position >= _latestValue.duration;
    final bool showPlayButton =
        widget.showPlayButton && !_latestValue.isPlaying && !_dragging;

    return
      AnimatedOpacity(
        opacity: notifier.hideStuff ? 0.0 : 1.0,
        duration: varDuration,
      child:
      GestureDetector(
      onTap: _latestValue.isPlaying
          ? _cancelAndRestartTimer
          : () {
              _hideTimer?.cancel();

              setState(() {
                notifier.hideStuff = false;
              });
            },
      child:Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          //device brightness
          _chewieController!.isBrignessOptionDisplay && _chewieController!.isFullScreen ?
          Container(
            //(MediaQuery.of(context).orientation) == Orientation.portrait ? 50.0 : 47.0,
           padding: _chewieController!.isFullScreen && !isPhone ? EdgeInsets.only(top: (MediaQuery.of(context).size.width/6),bottom: (MediaQuery.of(context).size.width/6)) : EdgeInsets.zero,
            child:Column(
              children: [
                Icon(Icons.brightness_6,color: widget.iconColor,size: 18,),
                Expanded(
                  child: RotatedBox(
                      quarterTurns: 3,
                      child:

                     FutureBuilder<double>(
                          future: ScreenBrightness().current,
                          builder: (context, snapshot) {
                            double currentBrightness = 0;
                            if (snapshot.hasData) {
                              currentBrightness = snapshot.data!;
                            }

                            return StreamBuilder<double>(
                              stream: ScreenBrightness().onCurrentBrightnessChanged,
                              builder: (context, snapshot) {
                                double changedBrightness = currentBrightness;
                                if (snapshot.hasData) {
                                  changedBrightness = snapshot.data!;
                                }

                                return  SliderTheme(
                                  child: Slider(
                                    value: changedBrightness,
                                    activeColor: Colors.white,
                                    inactiveColor: widget.iconColor,
                                    onChanged: (value) {
                                      setBrightness(value);
                                    },
                                  ),
                                  data: SliderTheme.of(context).copyWith(
                                      trackHeight: 3,
                                      thumbColor: Colors.transparent,
                                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 0.0)),
                                );
                                //   Column(
                                //   mainAxisSize: MainAxisSize.min,
                                //   children: [
                                //     // FutureBuilder<bool>(
                                //     //   future: ScreenBrightness().hasChanged,
                                //     //   builder: (context, snapshot) {
                                //     //     return Text(
                                //     //         'Brightness has changed via plugin: ${snapshot.data}');
                                //     //   },
                                //     // ),
                                //     // Text('Current brightness: $changedBrightness'),
                                //     Slider.adaptive(
                                //       value: changedBrightness,
                                //       onChanged: (value) {
                                //         setBrightness(value);
                                //       },
                                //     ),
                                //     // ElevatedButton(
                                //     //   onPressed: () {
                                //     //     resetBrightness();
                                //     //   },
                                //     //   child: const Text('reset brightness'),
                                //     // ),
                                //   ],
                                // );
                              },
                            );
                          },
                        ),

                      // SliderTheme(
                      //   child: Slider(
                      //     value: changedBrightness,
                      //     activeColor: Colors.white,
                      //     inactiveColor: widget.iconColor,
                      //     onChanged: (value) {
                      //       setBrightness(value);
                      //     },
                      //   ),
                      //   data: SliderTheme.of(context).copyWith(
                      //       trackHeight: 3,
                      //       thumbColor: Colors.transparent,
                      //       thumbShape: RoundSliderThumbShape(enabledThumbRadius: 0.0)),
                      // ),

                  ),
                )
              ],
            )
          ) : SizedBox(),

          _buildSkipBack(widget.iconColor, (MediaQuery.of(context).orientation) == Orientation.portrait ? 30.0 : 47.0),
          CenterPlayButton(
            backgroundColor: widget.backgroundColor,
            iconColor: widget.iconColor,
            isFinished: isFinished,
            isPlaying: controller.value.isPlaying,
            show: showPlayButton,
            onPressed: _playPause,
            isPhone: isPhone,
          ),
          _buildSkipForward(widget.iconColor, (MediaQuery.of(context).orientation) == Orientation.portrait  ? 30.0 : 47.0),

          //device volumn
          _chewieController!.isVolumnOptionDisplay && _chewieController!.isFullScreen  ?
          Container(
            // height: (MediaQuery.of(context).orientation) == Orientation.portrait ? 50.0 : 47.0,
              padding: _chewieController!.isFullScreen && !isPhone ? EdgeInsets.only(top: (MediaQuery.of(context).size.width/6),bottom: (MediaQuery.of(context).size.width/6)) : EdgeInsets.zero,
              child:Column(
                children: [
                  if (chewieController.allowMuting)
                    _buildMuteNewButton(
                        controller,
                        widget.backgroundColor,
                        widget.iconColor,
                        MediaQuery.of(context).orientation == Orientation.portrait ? 30.0 : 47.0,
                        MediaQuery.of(context).orientation == Orientation.portrait ? 16.0 : 24.0,
                    ),
                  Expanded(
                    child: RotatedBox(
                        quarterTurns: 3,
                        child: SliderTheme(
                          child: Slider(

                            max: 1,
                            min: 0,
                            activeColor: Colors.white,
                            inactiveColor: widget.iconColor,
                            onChanged: (double value) {
                              setState(() {
                                _setVolumeValue = value;
                                VolumeController().setVolume(_setVolumeValue);
                              });
                            },
                            value: _setVolumeValue,
                          ),
                          data: SliderTheme.of(context).copyWith(
                              trackHeight: 3,
                              thumbColor: Colors.transparent,
                              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 0.0)),
                        ),
                    ),
                  )
                ],
              )
          ) : SizedBox(),
        ],
      )

      // CenterPlayButton(
      //   backgroundColor: widget.backgroundColor,
      //   iconColor: widget.iconColor,
      //   isFinished: isFinished,
      //   isPlaying: controller.value.isPlaying,
      //   show: showPlayButton,
      //   onPressed: _playPause,
      // ),
    ));
  }

  GestureDetector _buildMuteNewButton(
      VideoPlayerController controller,
      Color backgroundColor,
      Color iconColor,
      double barHeight,
      double buttonPadding,
      ) {
    return

      GestureDetector(
        onTap: () {
          _cancelAndRestartTimer();

          if (_latestValue.volume == 0) {
            controller.setVolume(_latestVolume ?? 0.5);
          } else {
            _latestVolume = controller.value.volume;
            controller.setVolume(0.0);
          }
        },
        child:  Container(
          height: barHeight,
          padding: EdgeInsets.only(
            left: buttonPadding,
            right: buttonPadding,
          ),
          child: Icon(

            // _latestValue.volume > 0
            _setVolumeValue != 0
                ? Icons.volume_up : Icons.volume_off,
            color: iconColor,
            size: 20,
          ),
        ),
      );
  }

  GestureDetector _buildMuteButton(
    VideoPlayerController controller,
    Color backgroundColor,
    Color iconColor,
    double barHeight,
    double buttonPadding,
  ) {
    return

      GestureDetector(
      onTap: () {
        _cancelAndRestartTimer();

        if (_latestValue.volume == 0) {
          controller.setVolume(_latestVolume ?? 0.5);
        } else {
          _latestVolume = controller.value.volume;
          controller.setVolume(0.0);
        }
      },
      child:  AnimatedOpacity(
        opacity: notifier.hideStuff ? 0.0 : 1.0,
        duration: varDuration,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10.0),
            child: ColoredBox(
              color: backgroundColor,
              child: Container(
                height: barHeight,
                padding: EdgeInsets.only(
                  left: buttonPadding,
                  right: buttonPadding,
                ),
                child: Icon(
                  _latestValue.volume > 0 ? Icons.volume_up : Icons.volume_off,
                  color: iconColor,
                  size: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector _buildPlayPause(
    VideoPlayerController controller,
    Color iconColor,
    double barHeight,
  ) {
    return GestureDetector(
      onTap: _playPause,
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        padding: const EdgeInsets.only(
          left: 6.0,
          right: 6.0,
        ),
        child: AnimatedPlayPause(
          color: widget.iconColor,
          playing: controller.value.isPlaying,
        ),
      ),
    );
  }

  Widget _buildPosition(Color iconColor) {
    final position = _latestValue.position;

    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Text(
        formatDuration(position),
        style: TextStyle(
          color: iconColor,
          fontSize: 12.0,
        ),
      ),
    );
  }

  Widget _buildRemaining(Color iconColor) {
    final position = _latestValue.duration - _latestValue.position;

    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Text(
        '-${formatDuration(position)}',
        style: TextStyle(color: iconColor, fontSize: 12.0),
      ),
    );
  }

  Widget _buildSubtitleToggle(Color iconColor, double barHeight) {
    //if don't have subtitle hiden button
    if (chewieController.subtitle?.isEmpty ?? true) {
      return const SizedBox();
    }
    return GestureDetector(
      onTap: _subtitleToggle,
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        margin: const EdgeInsets.only(right: 10.0),
        padding: const EdgeInsets.only(
          left: 6.0,
          right: 6.0,
        ),
        child: Icon(
          Icons.subtitles,
          color: _subtitleOn ? iconColor : Colors.grey[700],
          size: 16.0,
        ),
      ),
    );
  }

  void _subtitleToggle() {
    setState(() {
      _subtitleOn = !_subtitleOn;
    });
  }

  GestureDetector _buildSkipBack(Color iconColor, double barHeight) {
    return GestureDetector(
      onTap: _skipBack,
      child: Container(
        height: barHeight + (!isPhone ? 10 : 0),
        color: Colors.transparent,
        margin: const EdgeInsets.only(left: 10.0),
        padding: const EdgeInsets.only(
          left: 6.0,
          right: 6.0,
        ),
        child: Icon(
          CupertinoIcons.gobackward_10,
          color: iconColor,
          size: 22.0 + (!isPhone ? 5 : 0),
        ),
      ),
    );
  }

  GestureDetector _buildSkipForward(Color iconColor, double barHeight) {
    return GestureDetector(
      onTap: _skipForward,
      child: Container(
        height: barHeight + (!isPhone ? 10 : 0),
        color: Colors.transparent,
        padding: const EdgeInsets.only(
          left: 6.0,
          right: 8.0,
        ),
        margin: const EdgeInsets.only(
          right: 8.0,
        ),
        child: Icon(
          CupertinoIcons.goforward_10,
          color: iconColor,
          size: 22.0 + (!isPhone ? 5 : 0),
        ),
      ),
    );
  }

  GestureDetector _buildSpeedButton(
    VideoPlayerController controller,
    Color iconColor,
    double barHeight,
  ) {
    return GestureDetector(
      onTap: () async {
        _hideTimer?.cancel();

        final chosenSpeed = await showCupertinoModalPopup<double>(
          context: context,
          semanticsDismissible: true,
          useRootNavigator: chewieController.useRootNavigator,
          builder: (context) => _PlaybackSpeedDialog(
            speeds: chewieController.playbackSpeeds,
            selected: _latestValue.playbackSpeed,
          ),
        );

        if (chosenSpeed != null) {
          controller.setPlaybackSpeed(chosenSpeed);
        }

        if (_latestValue.isPlaying) {
          _startHideTimer();
        }
      },
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        padding: const EdgeInsets.only(
          left: 6.0,
          right: 8.0,
        ),
        margin: const EdgeInsets.only(
          right: 8.0,
        ),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.skewY(0.0)
            ..rotateX(math.pi)
            ..rotateZ(math.pi * 0.8),
          child: Icon(
            Icons.speed,
            color: iconColor,
            size: 18.0,
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(
    Color backgroundColor,
    Color iconColor,
    double barHeight,
    double buttonPadding,
  ) {
    return Container(
      height: barHeight,
      margin: EdgeInsets.only(
        top: marginSize,
        right: marginSize,
        left: marginSize,
        bottom: 5,
      ),
      child: Row(
        children: <Widget>[

          if (chewieController.isFullScreen)
            _buildBackButton(
              backgroundColor,
              iconColor,
              barHeight,
              buttonPadding,
            ),

          // if (chewieController.allowFullScreen)
          //   _buildExpandButton(
          //     backgroundColor,
          //     iconColor,
          //     barHeight,
          //     buttonPadding,
          //   ),

          const Spacer(),
          if (chewieController.additionalOptions != null &&
              chewieController
                  .additionalOptions!(context).isNotEmpty)
            _buildOptionsButton(iconColor, barHeight),
          //mute button - old position
          // if (chewieController.allowMuting)
          //   _buildMuteButton(
          //     controller,
          //     backgroundColor,
          //     iconColor,
          //     barHeight,
          //     buttonPadding,
          //   ),
        ],
      ),
    );
  }

  void _cancelAndRestartTimer() {
    _hideTimer?.cancel();

    setState(() {
      notifier.hideStuff = false;

      _startHideTimer();
    });
  }

  Future<void> _initialize() async {
    _subtitleOn = chewieController.subtitle?.isNotEmpty ?? false;
    controller.addListener(_updateState);

    _updateState();

    if (controller.value.isPlaying || chewieController.autoPlay) {
      _startHideTimer();
    }

    if (chewieController.showControlsOnInitialize) {
      _initTimer = Timer(const Duration(seconds: 2), () {
        setState(() {
          notifier.hideStuff = true;
        });
      });
    }
  }

  void _onExpandCollapse() {
    setState(() {
      notifier.hideStuff = true;

      chewieController.toggleFullScreen();
      _expandCollapseTimer = Timer(const Duration(seconds: 2), () {
        setState(() {
          _cancelAndRestartTimer();
        });
      });
    });
  }

  Widget _buildProgressBar() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: CupertinoVideoProgressBar(
          controller,
          onDragStart: () {
            setState(() {
              _dragging = true;
            });

            _hideTimer?.cancel();
          },
          onDragEnd: () {
            setState(() {
              _dragging = false;
            });

            _startHideTimer();
          },
          colors: chewieController.cupertinoProgressColors ??
              FlexiProgressColors(
                playedColor: const Color.fromARGB(
                  120,
                  255,
                  255,
                  255,
                ),
                handleColor: const Color.fromARGB(
                  255,
                  255,
                  255,
                  255,
                ),
                bufferedColor: const Color.fromARGB(
                  60,
                  255,
                  255,
                  255,
                ),
                backgroundColor: const Color.fromARGB(
                  20,
                  255,
                  255,
                  255,
                ),
              ),
        ),
      ),
    );
  }

  void _playPause() {
    final isFinished = _latestValue.position >= _latestValue.duration;

    setState(() {
      if (controller.value.isPlaying) {
        notifier.hideStuff = false;
        _hideTimer?.cancel();
        controller.pause();
      } else {
        _cancelAndRestartTimer();

        if (!controller.value.isInitialized) {
          controller.initialize().then((_) {
            controller.play();
          });
        } else {
          if (isFinished) {
            controller.seekTo(Duration.zero);
          }
          controller.play();
        }
      }
    });
  }

  void _skipBack() {
    _cancelAndRestartTimer();
    final beginning = Duration.zero.inMilliseconds;
    final skip =
        (_latestValue.position - const Duration(seconds: 10)).inMilliseconds;
    controller.seekTo(Duration(milliseconds: math.max(skip, beginning)));
  }

  void _skipForward() {
    _cancelAndRestartTimer();
    final end = _latestValue.duration.inMilliseconds;
    final skip =
        (_latestValue.position + const Duration(seconds: 10)).inMilliseconds;
    controller.seekTo(Duration(milliseconds: math.min(skip, end)));
  }

  void _startHideTimer() {
    final hideControlsTimer = chewieController.hideControlsTimer.isNegative
        ? FlexiController.defaultHideControlsTimer
        : chewieController.hideControlsTimer;
    _hideTimer = Timer(hideControlsTimer, () {
      setState(() {
        notifier.hideStuff = true;
      });
    });
  }

  void _bufferingTimerTimeout() {
    _displayBufferingIndicator = true;
    if (mounted) {
      setState(() {});
    }
  }

  void _updateState() {
    if (!mounted) return;

    // display the progress bar indicator only after the buffering delay if it has been set
    if (chewieController.progressIndicatorDelay != null) {
      if (controller.value.isBuffering) {
        _bufferingDisplayTimer ??= Timer(
          chewieController.progressIndicatorDelay!,
          _bufferingTimerTimeout,
        );
      } else {
        _bufferingDisplayTimer?.cancel();
        _bufferingDisplayTimer = null;
        _displayBufferingIndicator = false;
      }
    } else {
      _displayBufferingIndicator = controller.value.isBuffering;
    }

    setState(() {
      _latestValue = controller.value;
      _subtitlesPosition = controller.value.position;
    });
  }
}

class _PlaybackSpeedDialog extends StatelessWidget {
  const _PlaybackSpeedDialog({
    Key? key,
    required List<double> speeds,
    required double selected,
  })  : _speeds = speeds,
        _selected = selected,
        super(key: key);

  final List<double> _speeds;
  final double _selected;

  @override
  Widget build(BuildContext context) {
    final selectedColor = Colors.black;//CupertinoTheme.of(context).primaryColor;

    return CupertinoActionSheet(
      actions: _speeds
          .map(
            (e) => CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).pop(e);
              },
              child: Padding(
                padding: EdgeInsets.only(left: 15,right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // if (e == _selected)


                    Expanded(child: Text(e.toString(),style: TextStyle(color:selectedColor),textAlign: TextAlign.start,),
                    ),
                    SizedBox(width: 15,),
                    Icon(Icons.check, size: 20.0, color: e == _selected ? selectedColor : Colors.transparent),

                  ],
                ),
              )
            ),
          )
          .toList(),
    );
  }
}
