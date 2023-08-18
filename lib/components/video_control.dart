import 'package:flutter/material.dart';

typedef ValueChangedCallback = void Function(double value);
typedef ControlTakenCallback = void Function(bool taken);
typedef StartTappedCallback = void Function();
typedef EndTappedCallback = void Function();
typedef DragTappedCallback = void Function();

class VideoControl extends StatefulWidget {
  final double? width;
  final double height;
  final Widget? startChild;
  final Widget? endChild;
  final Widget? dragChild;
  final bool startDisabled;
  final bool endDisabled;
  final bool dragDisabled;
  final ValueChangedCallback? onChanged;
  final ControlTakenCallback? onControlTaken;
  final StartTappedCallback? onStartTapped;
  final EndTappedCallback? onEndTapped;
  final DragTappedCallback? onDragTapped;
  final Color? backgroundColor;
  final BorderRadius backgroundBorderRadius;
  final List<BoxShadow> boxShadow;

  const VideoControl(
      {this.startChild,
      this.endChild,
      this.dragChild,
      this.width,
      this.height = 42,
      this.onChanged,
      this.onControlTaken,
      this.onStartTapped,
      this.onEndTapped,
      this.onDragTapped,
      this.backgroundColor,
      this.backgroundBorderRadius =
          const BorderRadius.all(Radius.circular(100.0)),
      this.boxShadow = const [
        BoxShadow(
          color: Colors.black26,
          spreadRadius: 1,
          blurRadius: 1,
          offset: Offset(0, 1),
        )
      ],
      this.startDisabled = false,
      this.endDisabled = false,
      this.dragDisabled = false,
      super.key});

  @override
  State createState() => _VideoControlState();

  Widget _standardBackgroundBuilder(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).cardColor,
        borderRadius: backgroundBorderRadius,
        boxShadow: boxShadow,
      ),
    );
  }

  Widget _standardChildBuilder(BuildContext context, IconData icon) {
    return Padding(
        padding: const EdgeInsets.all(9),
        child: DecoratedBox(
            decoration: BoxDecoration(
                color: backgroundColor ?? Theme.of(context).cardColor,
                borderRadius: backgroundBorderRadius),
            child: Icon(icon, color: Theme.of(context).primaryColor)));
  }

  Widget _stateChildBuilder(BuildContext context, GlobalKey key,
      AlignmentGeometry align, Widget? child, IconData standardChildIcon) {
    return Align(
        alignment: align,
        child: Container(
            key: key,
            child: child ?? _standardChildBuilder(context, standardChildIcon)));
  }
}

class _VideoControlState extends State<VideoControl>
    with TickerProviderStateMixin {
  final containerKey = GlobalKey();
  final dragKey = GlobalKey();
  final startKey = GlobalKey();
  final endKey = GlobalKey();
  AnimationController? _translateAnimation;
  bool _tappedInner = false;
  bool _draggingInner = false;
  double _currentDragOffset = 0;
  Matrix4 _transform = Matrix4.identity();

  @override
  initState() {
    super.initState();
    _translateAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0,
      upperBound: 1,
    );
    _translateAnimation!.addListener(() {
      _currentDragOffset = _consolidateOffset(_currentDragOffset) *
          (1 - _translateAnimation!.value);

      _reportChange();
      _updateTransformation(_currentDragOffset);
    });
  }

  _dragHandler(Offset delta) {
    _translateAnimation?.stop();
    _currentDragOffset += delta.dx;

    _reportChange();
    _updateTransformation(_consolidateOffset(_currentDragOffset));
  }

  _tapUpHandler() {
    _translateAnimation!.forward(from: 0);
  }

  _containerTapDownHandler(Offset localPosition) {
    _translateAnimation?.stop();
    final containerWidth = containerKey.currentContext!.size!.width;
    final currentOffset = localPosition.dx - containerWidth / 2;

    _currentDragOffset = currentOffset;

    _reportChange();
    _updateTransformation(_consolidateOffset(currentOffset));
  }

  _reportChange() {
    if (widget.onChanged != null) {
      final currentOffset = _consolidateOffset(_currentDragOffset);
      final containerWidth = containerKey.currentContext!.size!.width;
      final dragWidth = dragKey.currentContext!.size!.width;
      final startWidth = startKey.currentContext!.size!.width;
      final endWidth = endKey.currentContext!.size!.width;
      final value = currentOffset /
          ((containerWidth - dragWidth - startWidth - endWidth) / 2);

      widget.onChanged!(value);
    }
  }

  double _consolidateOffset(double offset) {
    final containerWidth = containerKey.currentContext!.size!.width;
    final dragWidth = dragKey.currentContext!.size!.width;
    final startWidth = startKey.currentContext!.size!.width;
    final endWidth = endKey.currentContext!.size!.width;
    final absoluteOffset = offset + containerWidth / 2;

    return absoluteOffset < (dragWidth / 2 + startWidth)
        ? -(containerWidth / 2 - startWidth) + dragWidth / 2
        : absoluteOffset > containerWidth - dragWidth / 2 - endWidth
            ? containerWidth / 2 - dragWidth / 2 - endWidth
            : offset;
  }

  _updateTransformation(double offset) {
    setState(() {
      _transform = Matrix4.identity()..translate(offset);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _translateAnimation?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.width ?? double.infinity;

    return SizedBox(
        width: width,
        height: widget.height,
        key: containerKey,
        child: GestureDetector(
            onHorizontalDragStart: (details) {
              if (!_draggingInner) {
                _containerTapDownHandler(details.localPosition);
              }
            },
            onHorizontalDragUpdate: (details) {
              if (!_draggingInner) {
                _dragHandler(details.delta);
              }
            },
            onHorizontalDragEnd: (details) {
              if (!_draggingInner) {
                _tapUpHandler();
              }
            },
            onTapDown: (details) {
              if (!_tappedInner) {
                _containerTapDownHandler(details.localPosition);
              }
            },
            onTapUp: (details) {
              if (!_tappedInner) {
                _tapUpHandler();
              }
            },
            child: Stack(
              fit: StackFit.passthrough,
              children: <Widget>[
                widget._standardBackgroundBuilder(context),
                GestureDetector(
                    onTapDown: (_) => _tappedInner = true,
                    onTapUp: (_) => _tappedInner = true,
                    onTap: () {
                      if (widget.onStartTapped != null) {
                        widget.onStartTapped!();
                      }
                    },
                    child: widget._stateChildBuilder(
                        context,
                        startKey,
                        Alignment.centerLeft,
                        widget.startChild,
                        Icons.arrow_left)),
                GestureDetector(
                    onTapDown: (_) => _tappedInner = true,
                    onTapUp: (_) => _tappedInner = true,
                    onTap: () {
                      if (widget.onEndTapped != null) {
                        widget.onEndTapped!();
                      }
                    },
                    child: widget._stateChildBuilder(
                        context,
                        endKey,
                        Alignment.centerRight,
                        widget.endChild,
                        Icons.arrow_right)),
                GestureDetector(
                    onHorizontalDragStart: (details) {
                      _draggingInner = true;
                      _tappedInner = true;
                    },
                    onHorizontalDragUpdate: (details) {
                      if (_draggingInner) {
                        _dragHandler(details.delta);
                      }
                    },
                    onHorizontalDragEnd: (details) {
                      _draggingInner = false;
                      _tappedInner = false;
                      _tapUpHandler();
                    },
                    onTapDown: (details) {
                      _tappedInner = true;
                    },
                    onTapUp: (details) {
                      _tappedInner = false;
                      _tapUpHandler();
                    },
                    onTap: () {
                      if (widget.onDragTapped != null) {
                        widget.onDragTapped!();
                      }
                    },
                    child: Transform(
                        transform: _transform,
                        child: widget._stateChildBuilder(
                            context,
                            dragKey,
                            Alignment.center,
                            widget.dragChild,
                            Icons.pause_circle))),
              ],
            )));
  }
}
