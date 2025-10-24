import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../main.dart'; // Import main.dart to find AuthWrapper

class VideoSplashScreen extends StatefulWidget {
  const VideoSplashScreen({super.key});

  @override
  State<VideoSplashScreen> createState() => _VideoSplashScreenState();
}

class _VideoSplashScreenState extends State<VideoSplashScreen>
    with WidgetsBindingObserver {
  late VideoPlayerController _controller;
  bool _navigated = false;
  bool _isDisposed = false;
  bool _videoCompleted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeVideo();
  }

  void _initializeVideo() {
    _controller = VideoPlayerController.asset('assets/icon/intro.mp4')
      ..initialize().then((_) {
        if (!_isDisposed && mounted) {
          setState(() {});
          _controller.play();
          _controller.setLooping(false);
        }
      }).catchError((error) {
        // If video fails to load, navigate immediately
        if (!_isDisposed && mounted) {
          _navigateToAuthWrapper();
        }
      });

    _controller.addListener(_videoListener);

    // Add a timeout to prevent infinite waiting
    Future.delayed(const Duration(seconds: 10), () {
      if (!_navigated && !_isDisposed && mounted) {
        _navigateToAuthWrapper();
      }
    });
  }

  void _videoListener() {
    if (_isDisposed || !mounted) return;

    if (_controller.value.isInitialized &&
        !_controller.value.isPlaying &&
        _controller.value.position >= _controller.value.duration &&
        !_videoCompleted) {
      _videoCompleted = true;
      _navigateToAuthWrapper();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isDisposed) return;

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // Pause video when app goes to background
        if (_controller.value.isInitialized && _controller.value.isPlaying) {
          _controller.pause();
        }
        break;
      case AppLifecycleState.resumed:
        // Resume video when app comes back to foreground
        if (_controller.value.isInitialized && !_controller.value.isPlaying && !_videoCompleted) {
          _controller.play();
        }
        break;
      case AppLifecycleState.detached:
        // Navigate immediately if app is being terminated
        if (!_navigated) {
          _navigateToAuthWrapper();
        }
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _navigateToAuthWrapper() {
    if (_navigated || _isDisposed || !mounted) return;
    _navigated = true;

    // Use a post-frame callback to ensure navigation happens after the current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const AuthWrapper(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 700),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
      ),
    );
  }
}
