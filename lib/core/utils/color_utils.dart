/// Konversi opacity ke alpha (0.0 - 1.0 ➜ 0 - 255)
int opacityToAlpha(double opacity) {
  return (opacity.clamp(0.0, 1.0) * 255).round();
}

/// Konversi alpha ke opacity (0 - 255 ➜ 0.0 - 1.0)
double alphaToOpacity(int alpha) {
  return (alpha.clamp(0, 255) / 255).toDouble();
}
