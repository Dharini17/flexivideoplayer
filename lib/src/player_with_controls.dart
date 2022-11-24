import 'package:flexivideoplayer/src/flexi_player.dart';
import 'package:flexivideoplayer/src/helpers/adaptive_controls.dart';
import 'package:flexivideoplayer/src/notifiers/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class PlayerWithControls extends StatelessWidget {
  const PlayerWithControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FlexiController flexiController = FlexiController.of(context);

    double calculateAspectRatio(BuildContext context) {
      final size = MediaQuery.of(context).size;
      final width = size.width;
      final height = size.height;

      return width > height ? width / height : height / width;
    }

    Widget buildControls(
      BuildContext context,
      FlexiController flexiController,
    ) {
      return flexiController.showControls
          ? flexiController.customControls ?? const AdaptiveControls()
          : const SizedBox();
    }

    Widget buildPlayerWithControls(
      FlexiController flexiController,
      BuildContext context,
    ) {
      return Stack(
        children: <Widget>[
          if (flexiController.placeholder != null)
            flexiController.placeholder!,
          InteractiveViewer(
            transformationController: flexiController.transformationController,
            maxScale: flexiController.maxScale,
            panEnabled: flexiController.zoomAndPan,
            scaleEnabled: flexiController.zoomAndPan,
            child: Center(
              child: AspectRatio(
                aspectRatio: flexiController.aspectRatio ??
                    flexiController.videoPlayerController.value.aspectRatio,
                child: VideoPlayer(flexiController.videoPlayerController),
              ),
            ),
          ),
          if (flexiController.overlay != null) flexiController.overlay!,
          if (Theme.of(context).platform != TargetPlatform.iOS)
            Consumer<PlayerNotifier>(
              builder: (
                BuildContext context,
                PlayerNotifier notifier,
                Widget? widget,
              ) =>
                  Visibility(
                visible: !notifier.hideStuff,
                child: AnimatedOpacity(
                  opacity: notifier.hideStuff ? 0.0 : 0.8,
                  duration: const Duration(
                    milliseconds: 250,
                  ),
                  child: const DecoratedBox(
                    decoration: BoxDecoration(color: Colors.black54),
                    child: SizedBox(),
                  ),
                ),
              ),
            ),
          if (!flexiController.isFullScreen)
            buildControls(context, flexiController)
          else
            SafeArea(
              bottom: false,
              child: buildControls(context, flexiController),
            ),
        ],
      );
    }

    return Center(
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: AspectRatio(
          aspectRatio: calculateAspectRatio(context),
          child: buildPlayerWithControls(flexiController, context),
        ),
      ),
    );
  }
}
