#flexivideoplayer

Advanced video player based on video_player and Flexi with some customized controls

<table>
   <tr>
      <td>
         <img width="250px" src="https://raw.githubusercontent.com/Dharini17/flexivideoplayer/master/assets/potrait.png">
      </td>
      <td>
         <img width="250px" src="https://raw.githubusercontent.com/Dharini17/flexivideoplayer/master/assets/landscap.png">
      </td>
    </tr>	
</table>

## Features

- Fullscreen video support
- Fullscreen brightness manage support
- Fullscreen volume manage support

## Installation

In your `pubspec.yaml` file within your Flutter Project:

```yaml
dependencies:
  flexivideoplayer: <latest_version>
```

## Usage


```dart

import 'package:flexivideoplayer/flexivideoplayer.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FlexiDemo extends StatefulWidget {
  const FlexiDemo({
    Key? key,
    this.title = 'Flexi Video Player Demo',
  }) : super(key: key);

  final String title;

  @override
  State<StatefulWidget> createState() {
    return _FlexiDemoState();
  }
}

class _FlexiDemoState extends State<FlexiDemo> {
  TargetPlatform? _platform;
  late VideoPlayerController _videoPlayerController1;
  FlexiController? _FlexiController;
  int? bufferDelay;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  @override
  void dispose() {
    _videoPlayerController1.dispose();
    _FlexiController?.dispose();
    super.dispose();
  }


  Future<void> initializePlayer() async {
    _videoPlayerController1 =
        VideoPlayerController.network("https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4");

    await _videoPlayerController1.initialize();
    _createFlexiController();

  }

  void _createFlexiController() {

    final subtitles = [

      Subtitle(
        index: 0,
        start: const Duration(seconds: 0),
        end: Duration(seconds: _videoPlayerController1.value.duration.inSeconds),
        text: 'Whats up? :)',

      ),
    ];

    _FlexiController = FlexiController(

      allowedScreenSleep: false,
      videoPlayerController: _videoPlayerController1,
      autoPlay: true,
      looping: true,
      progressIndicatorDelay:
      bufferDelay != null ? Duration(milliseconds: bufferDelay!) : null,

      additionalOptions: (context) {
        return <OptionItem>[
          OptionItem(
            onTap: toggleVideo,
            iconData: Icons.live_tv_sharp,
            title: 'Toggle Video Src',
          ),
        ];
      },
      subtitle: Subtitles(subtitles),
      subtitleBuilder: (context, dynamic subtitle) => Container(
        padding: const EdgeInsets.all(10.0),
        child: subtitle is InlineSpan
            ? RichText(
          text: subtitle,
        )
            : Text(
          subtitle.toString(),
          style: const TextStyle(color: Colors.white),
        ),
      ),

      hideControlsTimer: const Duration(seconds: 3),

      // Try playing around with some of these other options:
      isBrignessOptionDisplay: true,
      isVolumnOptionDisplay: true,

      cupertinoProgressColors: FlexiProgressColors(
        playedColor: Colors.red,
        handleColor: Colors.red,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.white.withOpacity(0.5),
      ),

    );
  }


  Future<void> toggleVideo() async {

    await initializePlayer();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: widget.title,

      home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(widget.title,style: TextStyle(fontSize: 14,color: Colors.black),),
          ) ,
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                AspectRatio(aspectRatio: 16/9,
                  child: _FlexiController != null &&
                      _FlexiController!
                          .videoPlayerController.value.isInitialized
                      ? Flexi(
                    controller: _FlexiController!,
                  )
                      : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CircularProgressIndicator(),
                        SizedBox(height: 20),
                        Text('Loading'),
                      ]
                  ),
                ),


              ],
            ),
          )
      ),
    );
  }
}

class DelaySlider extends StatefulWidget {
  const DelaySlider({Key? key, required this.delay, required this.onSave})
      : super(key: key);

  final int? delay;
  final void Function(int?) onSave;
  @override
  State<DelaySlider> createState() => _DelaySliderState();
}

class _DelaySliderState extends State<DelaySlider> {
  int? delay;
  bool saved = false;

  @override
  void initState() {
    super.initState();
    delay = widget.delay;
  }

  @override
  Widget build(BuildContext context) {
    const int max = 1000;
    return ListTile(
      title: Text(
        "Progress indicator delay ${delay != null ? "${delay.toString()} MS" : ""}",
      ),
      subtitle: Slider(
        value: delay != null ? (delay! / max) : 0,
        onChanged: (value) async {
          delay = (value * max).toInt();
          setState(() {
            saved = false;
          });
        },
      ),
      trailing: IconButton(
        icon: const Icon(Icons.save),
        onPressed: saved
            ? null
            : () {
          widget.onSave(delay);
          setState(() {
            saved = true;
          });
        },
      ),
    );
  }
}

```

## Additional information

This plugin is still in development.Please feel free to share if any bug found.Thank You.
# flexivideoplayer
# flexivideoplayer
