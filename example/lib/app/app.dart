import 'package:flexivideoplayer/flexivideoplayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class FlexiDemo extends StatefulWidget {
   FlexiDemo({
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
  bool isSourceError = false;

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

    setState(() {
      isSourceError = false;
    });
    try {
      _videoPlayerController1 =
          VideoPlayerController.network(
              "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4");

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

        aspectRatio: 16 / 9,
        deviceOrientationsOnEnterFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight
        ],
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
        allowFullScreen: true,
        fullScreenByDefault: true,
        allowedScreenSleep: false,
        videoPlayerController: _videoPlayerController1,
        autoPlay: true,
        looping: true,
        errorBuilder: (context, errorMessage) {
          print("Error find : $errorMessage");

          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
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
        subtitleBuilder: (context, dynamic subtitle) =>
            Container(
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
    catch(exception){

      setState(() {
        isSourceError = true;
      });
      print("exception : $exception");
    }
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

             Container(
               color: Colors.black,
               child:  AspectRatio(aspectRatio: 16/9,
                 child:

                 isSourceError ?

                        Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children:  [
                         Icon(CupertinoIcons.exclamationmark_circle,color: Colors.white,size: 30,),
                         SizedBox(height: 10),
                         Text('This video is unavailable',style: TextStyle(color: Colors.white,fontSize: 15),),

                         InkWell(
                           onTap: (){

                             initializePlayer();
                           },
                           child: Container(
                             height: 30,width: 100,alignment: Alignment.center,
                             child: Text("Reload again",style: TextStyle(color: Colors.red,fontSize: 13),),
                           ),
                         )
                       ]
                   )

                     :

                 _FlexiController != null ?
                 // &&
                 //        _FlexiController!
                 //            .videoPlayerController.value.isInitialized
                 //        ?
                 Flexi(
                   controller: _FlexiController!,
                 )
                     : Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: const [
                       CircularProgressIndicator(strokeWidth: 2,color: Colors.red,),
                       SizedBox(height: 20),
                       Text('Loading',style: TextStyle(color: Colors.white,fontSize: 15),),
                     ]
                 ),
               ),
             )


            ],
          ),
        )
      ),
    );
  }
}
