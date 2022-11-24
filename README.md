#flexivideoplayer

Advanced video player based on video_player and Flexi with some customized controls

<table>
   <tr>
      <td>
         <img width="250px" src="https://raw.githubusercontent.com/Dharini17/flexivideoplayer/assets/potrait.png">
      </td>
      <td>
         <img width="250px" src="https://raw.githubusercontent.com/Dharini17/flexivideoplayer/assets/landscap.png">
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

  late VideoPlayerController _videoPlayerController1;
  FlexiController? _FlexiController;


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

    final subtitles = [

      Subtitle(
        index: 0,
        start: const Duration(seconds: 0),
        end: Duration(seconds: _videoPlayerController1.value.duration.inSeconds),
        text: 'Whats up? :)',

      ),
    ];

    _FlexiController = FlexiController(

      deviceOrientationsOnEnterFullScreen: [DeviceOrientation.landscapeLeft,DeviceOrientation.landscapeRight],
      deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
      allowFullScreen: true,
      fullScreenByDefault: true,
      allowedScreenSleep: false,
      videoPlayerController: _videoPlayerController1,
      autoPlay: true,
      looping: true,

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
    setState(() {});
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
                  child:
                  _FlexiController != null
                      &&
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


```

## Additional information

This plugin is still in development.Please feel free to share if any bug found.Thank You.