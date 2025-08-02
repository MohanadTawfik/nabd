import 'package:flutter/foundation.dart';

/// Configuration class for controlling animations throughout the app
/// This allows for easy enabling/disabling of animations that might cause performance issues
class AnimationConfig {
  /// Whether animations are enabled in the app
  /// Set to false to disable animations that might cause performance issues
  static bool animationsEnabled = false;
  
  /// Whether staggered animations are enabled
  /// These can be particularly performance-intensive on lower-end devices
  static bool staggeredAnimationsEnabled = false;
  
  /// Whether complex animations like shimmer effects are enabled
  static bool complexAnimationsEnabled = false;
  
  /// Whether transition animations between screens are enabled
  static bool pageTransitionsEnabled = false;
  
  /// Duration for standard animations when enabled
  static Duration get standardDuration => Duration.zero;
  
  /// Duration for staggered animations when enabled
  static Duration get staggeredDuration => Duration.zero;
  
  /// Initialize animation settings based on device capabilities
  static void initialize() {
    // Disable staggered animations on lower-end devices
    // This is a simple heuristic and could be refined based on actual performance testing
    if (kDebugMode) {
      print('Initializing animation settings');
    }
    
    // All animations are disabled to maximize stability and performance.
    animationsEnabled = false;
    staggeredAnimationsEnabled = false;
    complexAnimationsEnabled = false;
    pageTransitionsEnabled = false;
  }
}