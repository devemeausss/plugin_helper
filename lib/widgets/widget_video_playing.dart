import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plugin_helper/index.dart';

class WidgetVideoPlaying extends StatefulWidget {
  final VideoPlayerController controller;
  final bool isInitial;
  final bool autoplay;
  final Widget loader;
  final double safeViewBottom;
  final Color progressBarColor;
  final TextStyle durationStyle;
  final TextStyle positionStyle;
  final Widget? playIcon, pauseIcon, closeIcon;
  const WidgetVideoPlaying(
      {super.key,
      required this.controller,
      this.isInitial = false,
      this.autoplay = true,
      required this.loader,
      required this.safeViewBottom,
      required this.progressBarColor,
      required this.durationStyle,
      required this.positionStyle,
      this.playIcon,
      this.pauseIcon,
      this.closeIcon});

  @override
  State<WidgetVideoPlaying> createState() => _WidgetVideoPlayingState();
}

class _WidgetVideoPlayingState extends State<WidgetVideoPlaying> {
  bool _isControl = false;

  @override
  void initState() {
    _initial();
    super.initState();
  }

  _initial() async {
    try {
      if (widget.isInitial) {
        await widget.controller.initialize();
      }
      if (widget.autoplay) {
        widget.controller.play();
      }
    } catch (e) {
      toast(MyPluginMessageRequire.cannotPlayVideo);
    }
  }

  @override
  void dispose() {
    widget.controller.pause();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
      child: GestureDetector(
        onTap: () {
          if (!mounted) return;
          setState(() {
            _isControl = !_isControl;
          });
        },
        child: Container(
          color: Colors.black,
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              ValueListenableBuilder(
                  valueListenable: widget.controller,
                  builder: (context, VideoPlayerValue value, child) {
                    if (value.isInitialized) {
                      return SizedBox.expand(
                          child: FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: widget.controller.value.size.width,
                          height: widget.controller.value.size.height,
                          child: VideoPlayer(widget.controller),
                        ),
                      ));
                    }
                    return widget.loader;
                  }),
              ValueListenableBuilder(
                  valueListenable: widget.controller,
                  builder: (context, VideoPlayerValue value, child) {
                    double widthPosition = value.position.inHours > 0 ? 55 : 40;
                    double widthDuration = value.duration.inHours > 0 ? 55 : 40;
                    double paddingBottom = widget.safeViewBottom;
                    return Positioned(
                        child: Align(
                            alignment: Alignment.bottomCenter,
                            child: AnimatedOpacity(
                              opacity: _isControl ? 1 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: Padding(
                                padding: EdgeInsets.only(
                                    bottom: paddingBottom, left: 10, right: 10),
                                child: Container(
                                  width: double.infinity,
                                  height: 60,
                                  decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(10)),
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      IconControl(
                                        onPress: () async {
                                          if (!_isControl) {
                                            return;
                                          }
                                          if (value.isPlaying) {
                                            await widget.controller.pause();
                                          } else {
                                            widget.controller.play();
                                          }
                                        },
                                        icon: value.isPlaying
                                            ? (widget.pauseIcon ??
                                                const Icon(
                                                  Icons.pause,
                                                  size: 30,
                                                ))
                                            : (widget.playIcon ??
                                                const Icon(
                                                  Icons.play_arrow_rounded,
                                                  size: 30,
                                                )),
                                      ),
                                      Expanded(
                                          child: Row(
                                        children: [
                                          SizedBox(
                                            width: widthPosition,
                                            child: Text(
                                              value.position.videoDuration,
                                              style: widget.positionStyle,
                                            ),
                                          ),
                                          8.w,
                                          Expanded(
                                            child: ProgressBar(
                                              progress: value.position,
                                              buffered: Duration.zero,
                                              total: value.duration,
                                              progressBarColor:
                                                  widget.progressBarColor,
                                              baseBarColor: Colors.white
                                                  .withOpacity(0.24),
                                              bufferedBarColor: Colors.white
                                                  .withOpacity(0.24),
                                              thumbColor: Colors.white,
                                              barHeight: 3.0,
                                              thumbRadius: 5.0,
                                              timeLabelLocation:
                                                  TimeLabelLocation.none,
                                              onSeek: (duration) {
                                                widget.controller
                                                    .seekTo(duration);
                                              },
                                            ),
                                          ),
                                          8.w,
                                          SizedBox(
                                            width: widthDuration,
                                            child: Text(
                                              value.duration.videoDuration,
                                              style: widget.durationStyle,
                                            ),
                                          ),
                                        ],
                                      )),
                                      IconControl(
                                        onPress: () async {
                                          if (!_isControl) {
                                            return;
                                          }
                                          Navigator.pop(context);
                                          if (widget
                                              .controller.value.isPlaying) {
                                            await widget.controller.pause();
                                          }
                                          widget.controller.seekTo(
                                              const Duration(milliseconds: 0));
                                        },
                                        icon: widget.closeIcon ??
                                            const Icon(
                                              Icons.close,
                                              size: 20,
                                            ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )));
                  })
            ],
          ),
        ),
      ),
    );
  }
}

class IconControl extends StatelessWidget {
  final Function() onPress;
  final Widget icon;
  const IconControl({super.key, required this.onPress, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: IconButton(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          color: Colors.white.withOpacity(0.7),
          icon: icon,
          onPressed: onPress,
        ));
  }
}
