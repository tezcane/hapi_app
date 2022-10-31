import 'package:flare_dart/math/mat2d.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_controller.dart';

/// When quickly navigating [EventDetatilsUI] the heart animation had lingering
/// particles around the heart in the "unfavorite" state. This fixes it.
class HeartController extends FlareController {
  HeartController(this._animation);
  final String _animation;

  late ActorAnimation _actor;
  double _duration = 0; // needs init

  bool _showParticles = false; // needs init

  @override
  void initialize(FlutterActorArtboard artboard) {
    _actor = artboard.getAnimation(_animation);

    // Comment below to show particles at init/hero transition:
    _showParticles = false;
    // if (_animation == 'Favorite') _showParticles = true;
    // if (_animation == 'Unfavorite') _showParticles = false;
  }

  @override
  bool advance(FlutterActorArtboard artboard, double elapsed) {
    // get particle nodes around heart:
    ActorNode hideNode1 = artboard.getNode('Particles');
//  ActorNode hideNode2 = artboard.getNode('Ellipse Particle');

    // Show/hide particles based on setting:
    if (_showParticles) {
      hideNode1.opacity = 1;
//    hideNode2.opacity = 1;
    } else {
      hideNode1.opacity = 0;
//    hideNode2.opacity = 0;
    }

    // play animation as normal:
    _duration += elapsed;
    _actor.apply(_duration, artboard, 0);
    return true;
  }

  @override
  void setViewTransform(Mat2D viewTransform) {}

  /// Show/Hide Particle, must call before FlareActor() is called in build().
  showParticles(bool showParticles) => _showParticles = showParticles;
}
