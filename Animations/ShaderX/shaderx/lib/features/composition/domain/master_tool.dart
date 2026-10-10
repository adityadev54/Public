/// These proposed tool identities are implementation defaults, not fixed taxonomy.
enum MasterTool {
  stack('Stack', 'Choose ingredients and arrange their order.'),
  fuse('Fuse', 'Control how each layer combines with the ones below.'),
  shape('Shape', 'Transform and distort the selected layer.'),
  flow('Flow', 'Set the timeline and each layer’s temporal offset.');

  final String label, description;
  const MasterTool(this.label, this.description);
}

enum LayerBlend { normal, screen, multiply, difference }
