import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoLogoWidget extends StatefulWidget {
  const VideoLogoWidget({super.key});

  @override
  State<VideoLogoWidget> createState() => _VideoLogoWidgetState();
}

class _VideoLogoWidgetState extends State<VideoLogoWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/logos/vid-icon.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.setVolume(0.0);
        _controller.play();
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final short = MediaQuery.sizeOf(context).shortestSide;
    final side = (short * 0.082).clamp(28.0, 40.0);
    final radius = (side * 0.28).clamp(6.0, 10.0);
    final loader = (side * 0.45).clamp(14.0, 20.0);

    return Container(
      width: side,
      height: side,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
      ),
      clipBehavior: Clip.hardEdge,
      child: _controller.value.isInitialized
          ? FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            )
          : Center(
              child: SizedBox(
                width: loader,
                height: loader,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ),
    );
  }
}
