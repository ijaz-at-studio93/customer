import 'dart:async';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:logger/logger.dart';

class ExtendedCachedNetworkImage extends StatefulWidget {
  const ExtendedCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.placeholder,
    this.errorWidget,
    this.fit,
    this.cacheKey,
    this.height,
    this.width,
    this.imageBuilder,
    this.placeholderFadeInDuration,
    this.alignment = Alignment.center,
    this.retryImageLoadLimit = 3,
    this.memoryManagementLevel = MemoryManagementLevel.normal,
    this.logger,
    this.initialRetryDelay = const Duration(milliseconds: 500),
  });

  final String imageUrl;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, dynamic)? errorWidget;
  final BoxFit? fit;
  final String? cacheKey;
  final double? height;
  final double? width;
  final Widget Function(BuildContext, ImageProvider<Object>)? imageBuilder;
  final Duration? placeholderFadeInDuration;
  final Alignment alignment;
  final int retryImageLoadLimit;
  final MemoryManagementLevel memoryManagementLevel;
  final Logger? logger;
  final Duration initialRetryDelay;

  @override
  ExtendedCachedNetworkImageState createState() =>
      ExtendedCachedNetworkImageState();
}

enum MemoryManagementLevel {
  normal,
  aggressive,
  minimal,
}

class ExtendedCachedNetworkImageState extends State<ExtendedCachedNetworkImage>
    with SingleTickerProviderStateMixin {
  /// URLs that have been successfully loaded at least once in this app session.
  /// Survives widget disposal so returning to a screen skips the placeholder.
  static final Set<String> _previouslyLoadedUrls = {};

  int retryCount = 0;
  late String currentImageUrl = widget.imageUrl;
  final bool _isImageLoaded = false;
  bool _isRetrying = false;
  bool _hasExhaustedRetries = false;
  late Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  late Logger _logger;

  @override
  void initState() {
    super.initState();
    _logger = widget.logger ?? Logger();
    currentImageUrl = widget.imageUrl;
    _connectivity = Connectivity();
    _setupConnectivityListener();
    _logInfo('Initializing image widget with URL: $currentImageUrl');
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  // @override
  // void didUpdateWidget(covariant ExtendedCachedNetworkImage oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (widget.imageUrl != oldWidget.imageUrl) {
  //     _logInfo(
  //       'Image URL changed from ${oldWidget.imageUrl} to ${widget.imageUrl}',
  //     );
  //     setState(() {
  //       currentImageUrl = widget.imageUrl;
  //       _isImageLoaded = false;
  //       retryCount = 0;
  //       _isRetrying = false;
  //       _hasExhaustedRetries = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final alreadyCached = _previouslyLoadedUrls.contains(widget.imageUrl);

    return CachedNetworkImage(
      imageUrl: currentImageUrl,
      fit: widget.fit ?? BoxFit.cover,
      height: widget.height,
      width: widget.width,
      memCacheHeight: _getMemoryCacheHeight(),
      memCacheWidth: _getMemoryCacheWidth(),
      maxWidthDiskCache:
          widget.memoryManagementLevel == MemoryManagementLevel.minimal
              ? 600
              : null,
      maxHeightDiskCache:
          widget.memoryManagementLevel == MemoryManagementLevel.minimal
              ? 800
              : null,
      fadeInDuration:
          alreadyCached ? Duration.zero : Duration(milliseconds: 100),
      fadeOutDuration: Duration.zero,
      imageBuilder: (context, imageProvider) {
        _previouslyLoadedUrls.add(widget.imageUrl);
        return widget.imageBuilder?.call(context, imageProvider) ??
            Image(
              image: imageProvider,
              fit: widget.fit ?? BoxFit.cover,
              alignment: widget.alignment,
            );
      },
      placeholder: alreadyCached
          ? (context, url) =>
              SizedBox(height: widget.height, width: widget.width)
          : widget.placeholder,
      placeholderFadeInDuration: widget.placeholderFadeInDuration,
      errorWidget: (context, url, error) {
        _logError('Error loading image $url', error);

        if (!_hasExhaustedRetries && retryCount < widget.retryImageLoadLimit) {
          if (!_isRetrying) {
            _isRetrying = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _retryImageLoad();
            });
          }

          return widget.placeholder?.call(context, widget.imageUrl) ??
              Container(
                color: Colors.transparent,
                height: 20,
                width: 20,
              );
        } else {
          _hasExhaustedRetries = true;
          return widget.errorWidget?.call(
                context,
                widget.imageUrl,
                error,
              ) ??
              const Icon(Icons.error, size: 40);
        }
      },
    );
  }

  void _setupConnectivityListener() {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((resultList) {
      if (resultList.isNotEmpty) {
        final result = resultList.first;
        if (result == ConnectivityResult.none) {
          _logInfo('Device is offline');
        } else {
          if (!_isImageLoaded && _hasExhaustedRetries) {
            _logInfo('Connection restored, retrying image load');
            setState(() {
              retryCount = 0;
              _hasExhaustedRetries = false;
              _isRetrying = false;
            });
            _retryImageLoad();
          }
          _logInfo('Device is online');
        }
      }
    });
  }

  void _logInfo(String message) {
    // _logger.info(message);
  }

  void _logError(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message);
  }

  void _retryImageLoad() async {
    if (retryCount < widget.retryImageLoadLimit && !_isImageLoaded && mounted) {
      // Calculate exponential backoff delay (initial delay * 2^retryCount)
      final exponentialDelay = Duration(
        milliseconds:
            (widget.initialRetryDelay.inMilliseconds * pow(2, retryCount))
                .toInt()
                .clamp(
                  widget.initialRetryDelay.inMilliseconds,
                  10000, // Max 10 seconds
                ),
      );
      _logInfo('Waiting ${exponentialDelay.inMilliseconds}ms before retry');
      await Future.delayed(exponentialDelay);

      if (mounted) {
        setState(() {
          retryCount++;
          _isRetrying = false;
          if (retryCount >= 2) {
            currentImageUrl = '${widget.imageUrl}?$retryCount';
          } else {
            currentImageUrl = widget.imageUrl;
          }
          _logInfo(
            'Retrying image load attempt $retryCount for $currentImageUrl',
          );
        });
      }
    } else if (mounted && retryCount >= widget.retryImageLoadLimit) {
      setState(() {
        _hasExhaustedRetries = true;
        _isRetrying = false;
      });
    }
  }

  int? _getMemoryCacheWidth() {
    switch (widget.memoryManagementLevel) {
      case MemoryManagementLevel.normal:
        return null;
      case MemoryManagementLevel.aggressive:
        if (widget.width != null) {
          final width = widget.width!;
          if (width.isFinite && width > 0) {
            return (width * 2).toInt();
          }
        }
        return 500;
      case MemoryManagementLevel.minimal:
        if (widget.width != null) {
          final width = widget.width!;
          if (width.isFinite && width > 0) {
            return width.toInt();
          }
        }
        return 300;
    }
  }

  int? _getMemoryCacheHeight() {
    switch (widget.memoryManagementLevel) {
      case MemoryManagementLevel.normal:
        return null;
      case MemoryManagementLevel.aggressive:
        if (widget.height != null) {
          final height = widget.height!;
          if (height.isFinite && height > 0) {
            return (height * 2).toInt();
          }
        }
        return 500;
      case MemoryManagementLevel.minimal:
        if (widget.height != null) {
          final height = widget.height!;
          if (height.isFinite && height > 0) {
            return height.toInt();
          }
        }
        return 300;
    }
  }
}
