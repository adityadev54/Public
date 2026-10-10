import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/kin_theme.dart';
import '../core/kin_radius.dart';
import '../core/kin_spacing.dart';

/// A geographic coordinate.
class KinLatLng {
  final double latitude;
  final double longitude;

  const KinLatLng(this.latitude, this.longitude);
}

/// A marker pin on the map.
class KinMapMarker {
  final KinLatLng position;
  final String? label;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const KinMapMarker({
    required this.position,
    this.label,
    this.icon = Icons.location_on_rounded,
    this.color,
    this.onTap,
  });
}

/// A polyline overlay on the map.
class KinMapPolyline {
  final List<KinLatLng> points;
  final Color color;
  final double strokeWidth;

  const KinMapPolyline({
    required this.points,
    this.color = const Color(0xFF3478F6),
    this.strokeWidth = 3,
  });
}

/// Controller for programmatic map manipulation.
class KinMapController extends ChangeNotifier {
  KinLatLng _center;
  double _zoom;

  KinMapController({
    KinLatLng center = const KinLatLng(0, 0),
    double zoom = 2,
  })  : _center = center,
        _zoom = zoom;

  KinLatLng get center => _center;
  double get zoom => _zoom;

  void moveTo(KinLatLng center, {double? zoom}) {
    _center = center;
    if (zoom != null) _zoom = zoom.clamp(1.0, 18.0);
    notifyListeners();
  }

  void zoomIn() {
    _zoom = (_zoom + 1).clamp(1.0, 18.0);
    notifyListeners();
  }

  void zoomOut() {
    _zoom = (_zoom - 1).clamp(1.0, 18.0);
    notifyListeners();
  }
}

/// A lightweight, pure-Flutter interactive map widget.
///
/// Renders a Mercator grid with pan/zoom gestures, markers, polylines,
/// and optional zoom controls. No external map SDK required.
///
/// For production tile-based maps, wrap a tile provider (e.g. OpenStreetMap)
/// or use `KinMap` as a styled overlay container.
class KinMap extends StatefulWidget {
  final KinMapController? controller;
  final KinLatLng initialCenter;
  final double initialZoom;
  final List<KinMapMarker> markers;
  final List<KinMapPolyline> polylines;
  final bool showZoomControls;
  final bool showGrid;
  final bool interactive;
  final double? height;
  final BorderRadius? borderRadius;
  final ValueChanged<KinLatLng>? onTap;

  const KinMap({
    super.key,
    this.controller,
    this.initialCenter = const KinLatLng(37.7749, -122.4194),
    this.initialZoom = 4,
    this.markers = const [],
    this.polylines = const [],
    this.showZoomControls = true,
    this.showGrid = true,
    this.interactive = true,
    this.height = 280,
    this.borderRadius,
    this.onTap,
  });

  @override
  State<KinMap> createState() => _KinMapState();
}

class _KinMapState extends State<KinMap> {
  late KinMapController _ctrl;
  bool _ownCtrl = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _ctrl = widget.controller!;
    } else {
      _ctrl = KinMapController(
        center: widget.initialCenter,
        zoom: widget.initialZoom,
      );
      _ownCtrl = true;
    }
    _ctrl.addListener(_onUpdate);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onUpdate);
    if (_ownCtrl) _ctrl.dispose();
    super.dispose();
  }

  void _onUpdate() => setState(() {});

  // Mercator projection helpers
  Offset _latLngToPixel(KinLatLng ll, Size size) {
    final scale = math.pow(2, _ctrl.zoom).toDouble();
    final centerX = (_ctrl.center.longitude + 180) / 360;
    final centerY = (1 -
            math.log(math.tan(_ctrl.center.latitude * math.pi / 180) +
                    1 / math.cos(_ctrl.center.latitude * math.pi / 180)) /
                math.pi) /
        2;

    final px = (ll.longitude + 180) / 360;
    final py = (1 -
            math.log(math.tan(ll.latitude * math.pi / 180) +
                    1 / math.cos(ll.latitude * math.pi / 180)) /
                math.pi) /
        2;

    final dx = (px - centerX) * 256 * scale;
    final dy = (py - centerY) * 256 * scale;

    return Offset(size.width / 2 + dx, size.height / 2 + dy);
  }

  KinLatLng _pixelToLatLng(Offset pixel, Size size) {
    final scale = math.pow(2, _ctrl.zoom).toDouble();
    final centerX = (_ctrl.center.longitude + 180) / 360;
    final centerY = (1 -
            math.log(math.tan(_ctrl.center.latitude * math.pi / 180) +
                    1 / math.cos(_ctrl.center.latitude * math.pi / 180)) /
                math.pi) /
        2;

    final px = centerX + (pixel.dx - size.width / 2) / (256 * scale);
    final py = centerY + (pixel.dy - size.height / 2) / (256 * scale);

    final lng = px * 360 - 180;
    final n = math.pi - 2 * math.pi * py;
    final lat = 180 / math.pi * math.atan(0.5 * (math.exp(n) - math.exp(-n)));

    return KinLatLng(lat, lng);
  }

  double _lastScale = 1.0;

  void _onScaleStart(ScaleStartDetails d) {
    _lastScale = 1.0;
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    if (!widget.interactive) return;
    final scale = math.pow(2, _ctrl.zoom).toDouble();

    // Pan
    final dLng = -d.focalPointDelta.dx / (256 * scale) * 360;
    final dLat = d.focalPointDelta.dy / (256 * scale) * 180;
    var newLat = (_ctrl.center.latitude + dLat).clamp(-85.0, 85.0);
    var newLng = _ctrl.center.longitude + dLng;

    // Pinch zoom
    double newZoom = _ctrl.zoom;
    if (d.scale != _lastScale) {
      newZoom = (_ctrl.zoom + (d.scale - _lastScale)).clamp(1.0, 18.0);
      _lastScale = d.scale;
    }

    _ctrl.moveTo(KinLatLng(newLat, newLng), zoom: newZoom);
  }

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = widget.borderRadius ?? KinRadius.lgAll;

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1A1A2E)
              : const Color(0xFFE8EEF4),
          borderRadius: radius,
          border: Border.all(
            color: theme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: GestureDetector(
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          onTapUp: widget.onTap != null
              ? (d) {
                  final size = context.size!;
                  final ll = _pixelToLatLng(d.localPosition, size);
                  widget.onTap!(ll);
                }
              : null,
          behavior: HitTestBehavior.opaque,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              return Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  // Grid background
                  if (widget.showGrid)
                    CustomPaint(
                      size: size,
                      painter: _MapGridPainter(
                        center: _ctrl.center,
                        zoom: _ctrl.zoom,
                        gridColor: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.06),
                        landColor: isDark
                            ? const Color(0xFF2A2A4A)
                            : const Color(0xFFD4DDE8),
                      ),
                    ),

                  // Polylines
                  if (widget.polylines.isNotEmpty)
                    CustomPaint(
                      size: size,
                      painter: _PolylinePainter(
                        polylines: widget.polylines,
                        project: (ll) => _latLngToPixel(ll, size),
                      ),
                    ),

                  // Markers
                  for (final marker in widget.markers)
                    Builder(builder: (context) {
                      final pos = _latLngToPixel(marker.position, size);
                      if (pos.dx < -30 ||
                          pos.dx > size.width + 30 ||
                          pos.dy < -30 ||
                          pos.dy > size.height + 30) {
                        return const SizedBox.shrink();
                      }
                      return Positioned(
                        left: pos.dx - 14,
                        top: pos.dy - 28,
                        child: _MarkerWidget(
                          marker: marker,
                          theme: theme,
                        ),
                      );
                    }),

                  // Zoom controls
                  if (widget.showZoomControls)
                    Positioned(
                      right: KinSpacing.sm,
                      bottom: KinSpacing.sm,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ZoomButton(
                            icon: Icons.add_rounded,
                            onTap: _ctrl.zoomIn,
                            theme: theme,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 4),
                          _ZoomButton(
                            icon: Icons.remove_rounded,
                            onTap: _ctrl.zoomOut,
                            theme: theme,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),

                  // Coordinate label
                  Positioned(
                    left: KinSpacing.sm,
                    bottom: KinSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.black : Colors.white)
                            .withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${_ctrl.center.latitude.toStringAsFixed(2)}°, ${_ctrl.center.longitude.toStringAsFixed(2)}°  z${_ctrl.zoom.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 9,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: theme.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MarkerWidget extends StatelessWidget {
  final KinMapMarker marker;
  final KinTheme theme;

  const _MarkerWidget({required this.marker, required this.theme});

  @override
  Widget build(BuildContext context) {
    final color = marker.color ?? theme.primary;
    return GestureDetector(
      onTap: marker.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(marker.icon, size: 28, color: color),
          if (marker.label != null)
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                marker.label!,
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final KinTheme theme;
  final bool isDark;

  const _ZoomButton({
    required this.icon,
    required this.onTap,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.outline.withValues(alpha: 0.15),
          ),
        ),
        child: Icon(icon, size: 16, color: theme.onSurface),
      ),
    );
  }
}

/// Renders a Mercator grid with latitude/longitude lines.
class _MapGridPainter extends CustomPainter {
  final KinLatLng center;
  final double zoom;
  final Color gridColor;
  final Color landColor;

  _MapGridPainter({
    required this.center,
    required this.zoom,
    required this.gridColor,
    required this.landColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final scale = math.pow(2, zoom).toDouble();
    final centerX = (center.longitude + 180) / 360;
    final centerY = (1 -
            math.log(math.tan(center.latitude * math.pi / 180) +
                    1 / math.cos(center.latitude * math.pi / 180)) /
                math.pi) /
        2;

    // Grid interval based on zoom
    double interval;
    if (zoom < 3) {
      interval = 30;
    } else if (zoom < 6) {
      interval = 10;
    } else if (zoom < 9) {
      interval = 5;
    } else {
      interval = 1;
    }

    // Longitude lines
    for (double lng = -180; lng <= 180; lng += interval) {
      final px = (lng + 180) / 360;
      final x = size.width / 2 + (px - centerX) * 256 * scale;
      if (x >= -1 && x <= size.width + 1) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      }
    }

    // Latitude lines
    for (double lat = -80; lat <= 80; lat += interval) {
      final rad = lat * math.pi / 180;
      final py =
          (1 - math.log(math.tan(rad) + 1 / math.cos(rad)) / math.pi) / 2;
      final y = size.height / 2 + (py - centerY) * 256 * scale;
      if (y >= -1 && y <= size.height + 1) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      }
    }

    // Equator (thicker)
    final eqPy = 0.5;
    final eqY = size.height / 2 + (eqPy - centerY) * 256 * scale;
    if (eqY >= 0 && eqY <= size.height) {
      canvas.drawLine(
        Offset(0, eqY),
        Offset(size.width, eqY),
        paint..strokeWidth = 1.0,
      );
      paint.strokeWidth = 0.5;
    }

    // Prime meridian (thicker)
    final pmPx = 0.5;
    final pmX = size.width / 2 + (pmPx - centerX) * 256 * scale;
    if (pmX >= 0 && pmX <= size.width) {
      canvas.drawLine(
        Offset(pmX, 0),
        Offset(pmX, size.height),
        paint..strokeWidth = 1.0,
      );
    }
  }

  @override
  bool shouldRepaint(_MapGridPainter old) =>
      center.latitude != old.center.latitude ||
      center.longitude != old.center.longitude ||
      zoom != old.zoom;
}

/// Paints polylines on the map.
class _PolylinePainter extends CustomPainter {
  final List<KinMapPolyline> polylines;
  final Offset Function(KinLatLng) project;

  _PolylinePainter({required this.polylines, required this.project});

  @override
  void paint(Canvas canvas, Size size) {
    for (final pl in polylines) {
      if (pl.points.length < 2) continue;
      final path = Path();
      final first = project(pl.points.first);
      path.moveTo(first.dx, first.dy);
      for (int i = 1; i < pl.points.length; i++) {
        final p = project(pl.points[i]);
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = pl.color
          ..strokeWidth = pl.strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  @override
  bool shouldRepaint(_PolylinePainter old) => true;
}
