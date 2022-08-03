// ignore_for_file: curly_braces_in_flow_control_structures, unnecessary_null_comparison

/// A custom implementation of Flutter's MouseRegion that uses a translucent hit test behavior,
/// available in Flutter versions prior to 3.0.0.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// A widget that tracks the movement of mice.
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=1oF3pI5umck}
///
/// [TranslucentMouseRegion] is used
/// when it is needed to compare the list of objects that a mouse pointer is
/// hovering over between this frame and the last frame. This means entering
/// events, exiting events, and mouse cursors.
///
/// To listen to general pointer events, use [Listener], or more preferably,
/// [GestureDetector].
///
/// ## Layout behavior
///
/// _See [BoxConstraints] for an introduction to box layout models._
///
/// If it has a child, this widget defers to the child for sizing behavior. If
/// it does not have a child, it grows to fit the parent instead.
///
/// {@tool dartpad}
/// This example makes a [Container] react to being entered by a mouse
/// pointer, showing a count of the number of entries and exits.
///
/// ** See code in examples/api/lib/widgets/basic/mouse_region.0.dart **
/// {@end-tool}
///
/// See also:
///
///  * [Listener], a similar widget that tracks pointer events when the pointer
///    has buttons pressed.
class TranslucentMouseRegion extends SingleChildRenderObjectWidget {
  /// Creates a widget that forwards mouse events to callbacks.
  ///
  /// By default, all callbacks are empty, [cursor] is [MouseCursor.defer], and
  /// [opaque] is true. The [cursor] must not be null.
  const TranslucentMouseRegion({
    Key? key,
    this.onEnter,
    this.onExit,
    this.onHover,
    this.cursor = MouseCursor.defer,
    this.opaque = true,
    this.hitTestBehavior = HitTestBehavior.translucent,
    Widget? child,
  })  : assert(cursor != null),
        assert(opaque != null),
        super(key: key, child: child);

  /// Triggered when a mouse pointer has entered this widget.
  ///
  /// This callback is triggered when the pointer, with or without buttons
  /// pressed, has started to be contained by the region of this widget. More
  /// specifically, the callback is triggered by the following cases:
  ///
  ///  * This widget has appeared under a pointer.
  ///  * This widget has moved to under a pointer.
  ///  * A new pointer has been added to somewhere within this widget.
  ///  * An existing pointer has moved into this widget.
  ///
  /// This callback is not always matched by an [onExit]. If the [TranslucentMouseRegion]
  /// is unmounted while being hovered by a pointer, the [onExit] of the widget
  /// callback will never called. For more details, see [onExit].
  ///
  /// {@template flutter.widgets.TranslucentMouseRegion.onEnter.triggerTime}
  /// The time that this callback is triggered is always between frames: either
  /// during the post-frame callbacks, or during the callback of a pointer
  /// event.
  /// {@endtemplate}
  ///
  /// See also:
  ///
  ///  * [onExit], which is triggered when a mouse pointer exits the region.
  ///  * [MouseTrackerAnnotation.onEnter], which is how this callback is
  ///    internally implemented.
  final PointerEnterEventListener? onEnter;

  /// Triggered when a pointer moves into a position within this widget without
  /// buttons pressed.
  ///
  /// Usually this is only fired for pointers which report their location when
  /// not down (e.g. mouse pointers). Certain devices also fire this event on
  /// single taps in accessibility mode.
  ///
  /// This callback is not triggered by the movement of the widget.
  ///
  /// The time that this callback is triggered is during the callback of a
  /// pointer event, which is always between frames.
  ///
  /// See also:
  ///
  ///  * [Listener.onPointerHover], which does the same job. Prefer using
  ///    [Listener.onPointerHover], since hover events are similar to other regular
  ///    events.
  final PointerHoverEventListener? onHover;

  /// Triggered when a mouse pointer has exited this widget when the widget is
  /// still mounted.
  ///
  /// This callback is triggered when the pointer, with or without buttons
  /// pressed, has stopped being contained by the region of this widget, except
  /// when the exit is caused by the disappearance of this widget. More
  /// specifically, this callback is triggered by the following cases:
  ///
  ///  * A pointer that is hovering this widget has moved away.
  ///  * A pointer that is hovering this widget has been removed.
  ///  * This widget, which is being hovered by a pointer, has moved away.
  ///
  /// And is __not__ triggered by the following case:
  ///
  ///  * This widget, which is being hovered by a pointer, has disappeared.
  ///
  /// This means that a [TranslucentMouseRegion.onExit] might not be matched by a
  /// [TranslucentMouseRegion.onEnter].
  ///
  /// This restriction aims to prevent a common misuse: if [State.setState] is
  /// called during [TranslucentMouseRegion.onExit] without checking whether the widget is
  /// still mounted, an exception will occur. This is because the callback is
  /// triggered during the post-frame phase, at which point the widget has been
  /// unmounted. Since [State.setState] is exclusive to widgets, the restriction
  /// is specific to [TranslucentMouseRegion], and does not apply to its lower-level
  /// counterparts, [RenderTranslucentMouseRegion] and [MouseTrackerAnnotation].
  ///
  /// There are a few ways to mitigate this restriction:
  ///
  ///  * If the hover state is completely contained within a widget that
  ///    unconditionally creates this [TranslucentMouseRegion], then this will not be a
  ///    concern, since after the [TranslucentMouseRegion] is unmounted the state is no
  ///    longer used.
  ///  * Otherwise, the outer widget very likely has access to the variable that
  ///    controls whether this [TranslucentMouseRegion] is present. If so, call [onExit] at
  ///    the event that turns the condition from true to false.
  ///  * In cases where the solutions above won't work, you can always
  ///    override [State.dispose] and call [onExit], or create your own widget
  ///    using [RenderTranslucentMouseRegion].
  ///
  /// {@tool dartpad}
  /// The following example shows a blue rectangular that turns yellow when
  /// hovered. Since the hover state is completely contained within a widget
  /// that unconditionally creates the `TranslucentMouseRegion`, you can ignore the
  /// aforementioned restriction.
  ///
  /// ** See code in examples/api/lib/widgets/basic/mouse_region.on_exit.0.dart **
  /// {@end-tool}
  ///
  /// {@tool dartpad}
  /// The following example shows a widget that hides its content one second
  /// after being hovered, and also exposes the enter and exit callbacks.
  /// Because the widget conditionally creates the `TranslucentMouseRegion`, and leaks the
  /// hover state, it needs to take the restriction into consideration. In this
  /// case, since it has access to the event that triggers the disappearance of
  /// the `TranslucentMouseRegion`, it simply trigger the exit callback during that event
  /// as well.
  ///
  /// ** See code in examples/api/lib/widgets/basic/mouse_region.on_exit.1.dart **
  /// {@end-tool}
  ///
  /// {@macro flutter.widgets.TranslucentMouseRegion.onEnter.triggerTime}
  ///
  /// See also:
  ///
  ///  * [onEnter], which is triggered when a mouse pointer enters the region.
  ///  * [RenderTranslucentMouseRegion] and [MouseTrackerAnnotation.onExit], which are how
  ///    this callback is internally implemented, but without the restriction.
  final PointerExitEventListener? onExit;

  /// The mouse cursor for mouse pointers that are hovering over the region.
  ///
  /// When a mouse enters the region, its cursor will be changed to the [cursor].
  /// When the mouse leaves the region, the cursor will be decided by the region
  /// found at the new location.
  ///
  /// The [cursor] defaults to [MouseCursor.defer], deferring the choice of
  /// cursor to the next region behind it in hit-test order.
  final MouseCursor cursor;

  /// Whether this widget should prevent other [TranslucentMouseRegion]s visually behind it
  /// from detecting the pointer.
  ///
  /// This changes the list of regions that a pointer hovers, thus affecting how
  /// their [onHover], [onEnter], [onExit], and [cursor] behave.
  ///
  /// If [opaque] is true, this widget will absorb the mouse pointer and
  /// prevent this widget's siblings (or any other widgets that are not
  /// ancestors or descendants of this widget) from detecting the mouse
  /// pointer even when the pointer is within their areas.
  ///
  /// If [opaque] is false, this object will not affect how [TranslucentMouseRegion]s
  /// behind it behave, which will detect the mouse pointer as long as the
  /// pointer is within their areas.
  ///
  /// This defaults to true.
  final bool opaque;

  /// How to behave during hit testing.
  ///
  /// This defaults to [HitTestBehavior.opaque] if null.
  final HitTestBehavior? hitTestBehavior;

  @override
  RenderMouseRegion createRenderObject(BuildContext context) {
    return RenderMouseRegion(
      onEnter: onEnter,
      onHover: onHover,
      onExit: onExit,
      cursor: cursor,
      opaque: opaque,
      hitTestBehavior: hitTestBehavior,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderMouseRegion renderObject) {
    renderObject
      ..onEnter = onEnter
      ..onHover = onHover
      ..onExit = onExit
      ..cursor = cursor
      ..opaque = opaque
      ..hitTestBehavior = hitTestBehavior;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    final List<String> listeners = <String>[];
    if (onEnter != null) listeners.add('enter');
    if (onExit != null) listeners.add('exit');
    if (onHover != null) listeners.add('hover');
    properties.add(
        IterableProperty<String>('listeners', listeners, ifEmpty: '<none>'));
    properties.add(
        DiagnosticsProperty<MouseCursor>('cursor', cursor, defaultValue: null));
    properties
        .add(DiagnosticsProperty<bool>('opaque', opaque, defaultValue: true));
  }
}

/// Calls callbacks in response to pointer events that are exclusive to mice.
///
/// It responds to events that are related to hovering, i.e. when the mouse
/// enters, exits (with or without pressing buttons), or moves over a region
/// without pressing buttons.
///
/// It does not respond to common events that construct gestures, such as when
/// the pointer is pressed, moved, then released or canceled. For these events,
/// use [RenderPointerListener].
///
/// If it has a child, it defers to the child for sizing behavior.
///
/// If it does not have a child, it grows to fit the parent-provided constraints.
///
/// See also:
///
///  * [MouseRegion], a widget that listens to hover events using
///    [RenderMouseRegion].
class RenderMouseRegion extends RenderProxyBoxWithHitTestBehavior
    implements MouseTrackerAnnotation {
  /// Creates a render object that forwards pointer events to callbacks.
  ///
  /// All parameters are optional. By default this method creates an opaque
  /// mouse region with no callbacks and cursor being [MouseCursor.defer]. The
  /// [cursor] must not be null.
  RenderMouseRegion({
    this.onEnter,
    this.onHover,
    this.onExit,
    MouseCursor cursor = MouseCursor.defer,
    bool validForMouseTracker = true,
    bool opaque = true,
    RenderBox? child,
    HitTestBehavior? hitTestBehavior = HitTestBehavior.opaque,
  })  : assert(opaque != null),
        assert(cursor != null),
        _cursor = cursor,
        _validForMouseTracker = validForMouseTracker,
        _opaque = opaque,
        super(
            behavior: hitTestBehavior ?? HitTestBehavior.opaque, child: child);

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    return super.hitTest(result, position: position) && _opaque;
  }

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (onHover != null && event is PointerHoverEvent) return onHover!(event);
  }

  /// Whether this object should prevent [RenderMouseRegion]s visually behind it
  /// from detecting the pointer, thus affecting how their [onHover], [onEnter],
  /// and [onExit] behave.
  ///
  /// If [opaque] is true, this object will absorb the mouse pointer and
  /// prevent this object's siblings (or any other objects that are not
  /// ancestors or descendants of this object) from detecting the mouse
  /// pointer even when the pointer is within their areas.
  ///
  /// If [opaque] is false, this object will not affect how [RenderMouseRegion]s
  /// behind it behave, which will detect the mouse pointer as long as the
  /// pointer is within their areas.
  ///
  /// This defaults to true.
  bool get opaque => _opaque;
  bool _opaque;
  set opaque(bool value) {
    if (_opaque != value) {
      _opaque = value;
      // Trigger [MouseTracker]'s device update to recalculate mouse states.
      markNeedsPaint();
    }
  }

  /// How to behave during hit testing.
  ///
  /// This defaults to [HitTestBehavior.opaque] if null.
  HitTestBehavior? get hitTestBehavior => behavior;
  set hitTestBehavior(HitTestBehavior? value) {
    final HitTestBehavior newValue = value ?? HitTestBehavior.opaque;
    if (behavior != newValue) {
      behavior = newValue;
      // Trigger [MouseTracker]'s device update to recalculate mouse states.
      markNeedsPaint();
    }
  }

  @override
  PointerEnterEventListener? onEnter;

  /// Triggered when a pointer has moved onto or within the region without
  /// buttons pressed.
  ///
  /// This callback is not triggered by the movement of the object.
  PointerHoverEventListener? onHover;

  @override
  PointerExitEventListener? onExit;

  @override
  MouseCursor get cursor => _cursor;
  MouseCursor _cursor;
  set cursor(MouseCursor value) {
    if (_cursor != value) {
      _cursor = value;
      // A repaint is needed in order to trigger a device update of
      // [MouseTracker] so that this new value can be found.
      markNeedsPaint();
    }
  }

  @override
  bool get validForMouseTracker => _validForMouseTracker;
  bool _validForMouseTracker;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _validForMouseTracker = true;
  }

  @override
  void detach() {
    // It's possible that the renderObject be detached during mouse events
    // dispatching, set the [MouseTrackerAnnotation.validForMouseTracker] false to prevent
    // the callbacks from being called.
    _validForMouseTracker = false;
    super.detach();
  }

  @override
  Size computeSizeForNoChild(BoxConstraints constraints) {
    return constraints.biggest;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagsSummary<Function?>(
      'listeners',
      <String, Function?>{
        'enter': onEnter,
        'hover': onHover,
        'exit': onExit,
      },
      ifEmpty: '<none>',
    ));
    properties.add(DiagnosticsProperty<MouseCursor>('cursor', cursor,
        defaultValue: MouseCursor.defer));
    properties
        .add(DiagnosticsProperty<bool>('opaque', opaque, defaultValue: true));
    properties.add(FlagProperty('validForMouseTracker',
        value: validForMouseTracker,
        defaultValue: true,
        ifFalse: 'invalid for MouseTracker'));
  }
}
