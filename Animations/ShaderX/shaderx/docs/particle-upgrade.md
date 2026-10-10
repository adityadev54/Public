# Particle depth and full-screen studies

The retained renderer now covers Kinetic sculpture, Braided knot, Chambered shell, Ribbon orbit, Ember flock, Woven field, Copper storm and Prism rain. Each layer owns up to 2,400 particles with persistent position and velocity. Integration remains on the CPU; points, velocity trails and shard paths are batched for drawing. This is not GPU compute.

Sculptures retain their target geometry but gain subtle breathing relief, distinct palettes, depth-dependent size and moving trails. Touch coordinates account for canvas aspect, layer scale and rotation. Ember flock uses coherent lateral currents; Woven field (the retained orbital_dust.v1 ID) follows interlaced strands, with no circular orbit. Copper storm uses crossed turbulent currents, and Prism rain uses downward advection with local stirring. Touch pushes strands and grains apart rather than applying orbital spin; release leaves momentum. Full-screen fields wrap at the canvas edges. Deterministic dispersed seeds avoid visible grid/diagonal arrangements.

Glass tide is a continuous GLSL surface with moving wave normals, warm reflection bands and touch ripples. It fills its viewport and has Wave height and Caustic light controls. It is a procedural material study, not a fluid solver or real scene refraction.

Paper fragments, Graphite bloom and Petal assembly remain procedural fragment effects. Shader registry entries for retained fields supply procedural fallbacks; the interactive viewport uses the retained renderer. Existing recipe IDs and parameter schemas remain compatible. Full-screen themes reuse the existing studio and its focus gesture.

Validation covers retained momentum, distinct field dynamics, finite state, render captures, shader controls and app flows. Device performance has not been benchmarked; capacity remains bounded and repaint honors composition frame rate.
