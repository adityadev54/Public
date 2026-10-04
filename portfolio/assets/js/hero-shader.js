(() => {
  const PARTICLE_COUNT = 24000;

  const vertexSource = `
    precision highp float;
    attribute vec2 a_portrait;
    attribute vec2 a_galaxy;
    attribute vec3 a_color;
    attribute float a_seed;
    uniform vec2 u_resolution;
    uniform vec2 u_pointer;
    uniform float u_progress;
    uniform float u_time;
    uniform float u_speed;
    uniform float u_core;
    uniform float u_twinkle;
    uniform float u_lightMode;
    varying vec3 v_color;
    varying float v_alpha;
    varying float v_seed;

    float ease(float value) {
      return value * value * (3.0 - 2.0 * value);
    }

    void main() {
      float progress = ease(u_progress);
      float radius = length(a_galaxy);
      float rotation = u_time * u_speed * progress;
      float c = cos(rotation);
      float s = sin(rotation);
      vec2 galaxy = mat2(c, -s, s, c) * a_galaxy;

      float burst = sin(3.14159265 * progress);
      vec2 tangent = normalize(vec2(-galaxy.y, galaxy.x) + .0001);
      vec2 position = mix(a_portrait, galaxy, progress);
      position += tangent * burst * (.035 + a_seed * .045);
      position += (u_pointer - .5) * .07 * (1.0 - progress * .55);

      float aspect = u_resolution.y / u_resolution.x;
      gl_Position = vec4(position.x * aspect, position.y, 0.0, 1.0);
      float sparkle = .65 + .35 * sin(u_time * (1.0 + u_twinkle * .8) + a_seed * 49.0);
      float coreGlow = 1.0 + (1.0 - smoothstep(0.0, .36, radius)) * u_core;
      gl_PointSize = (1.25 + sparkle * u_twinkle * .28 + burst * 1.15) * coreGlow;

      vec3 darkGalaxy = mix(vec3(.20, .96, .54), vec3(.24, .69, 1.0), smoothstep(.12, .92, radius));
      darkGalaxy = mix(vec3(.93, 1.0, .70), darkGalaxy, smoothstep(0.0, .34, radius));
      vec3 lightGalaxy = mix(vec3(.01, .42, .24), vec3(.04, .27, .66), smoothstep(.12, .92, radius));
      lightGalaxy = mix(vec3(.30, .43, .03), lightGalaxy, smoothstep(0.0, .34, radius));
      vec3 galaxyColor = mix(darkGalaxy, lightGalaxy, u_lightMode);
      vec3 portraitColor = mix(a_color, a_color * .48, u_lightMode);
      v_color = mix(portraitColor, galaxyColor, progress);
      v_alpha = mix(.72 + sparkle * .28, .55 + sparkle * .45, progress);
      v_seed = a_seed;
    }
  `;

  const fragmentSource = `
    precision mediump float;
    varying vec3 v_color;
    varying float v_alpha;
    varying float v_seed;
    void main() {
      float distanceToCenter = length(gl_PointCoord - .5);
      float particle = 1.0 - smoothstep(.20, .5, distanceToCenter);
      float halo = 1.0 - smoothstep(.0, .5, distanceToCenter);
      vec3 color = v_color + v_color * halo * (.28 + v_seed * .18);
      gl_FragColor = vec4(color, particle * v_alpha);
    }
  `;

  const clamp = value => Math.max(0, Math.min(1, value));
  const fract = value => value - Math.floor(value);
  const random = seed => fract(Math.sin(seed * 91.3458 + 13.87) * 47453.5453);

  const compile = (gl, type, source) => {
    const shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
      throw new Error(gl.getShaderInfoLog(shader) || 'Shader compilation failed.');
    }
    return shader;
  };

  const makeProgram = gl => {
    const program = gl.createProgram();
    gl.attachShader(program, compile(gl, gl.VERTEX_SHADER, vertexSource));
    gl.attachShader(program, compile(gl, gl.FRAGMENT_SHADER, fragmentSource));
    gl.linkProgram(program);
    if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
      throw new Error(gl.getProgramInfoLog(program) || 'Shader linking failed.');
    }
    return program;
  };

  const samplePortrait = image => {
    const size = 420;
    const surface = document.createElement('canvas');
    surface.width = size;
    surface.height = size;
    const context = surface.getContext('2d', { willReadFrequently: true });
    context.clearRect(0, 0, size, size);
    context.drawImage(image, 0, 0, size, size);
    const pixels = context.getImageData(0, 0, size, size).data;
    const candidates = [];

    for (let y = 0; y < size; y += 2) {
      for (let x = 0; x < size; x += 2) {
        const offset = (y * size + x) * 4;
        const alpha = pixels[offset + 3] / 255;
        if (alpha < .16) continue;
        const light = (pixels[offset] * .299 + pixels[offset + 1] * .587 + pixels[offset + 2] * .114) / 255;
        if (random(offset) > .34 + alpha * .42 + light * .25) continue;
        candidates.push({
          x: (x / size - .5) * 1.72,
          y: (.5 - y / size) * 1.72,
          r: pixels[offset] / 255,
          g: pixels[offset + 1] / 255,
          b: pixels[offset + 2] / 255
        });
      }
    }

    if (!candidates.length) throw new Error('The portrait has no visible pixels to sample.');
    const positions = new Float32Array(PARTICLE_COUNT * 2);
    const colors = new Float32Array(PARTICLE_COUNT * 3);
    const seeds = new Float32Array(PARTICLE_COUNT);

    for (let index = 0; index < PARTICLE_COUNT; index += 1) {
      const seed = random(index + 1);
      const point = candidates[Math.floor(seed * candidates.length) % candidates.length];
      positions[index * 2] = point.x + (random(index + 111) - .5) * .007;
      positions[index * 2 + 1] = point.y + (random(index + 733) - .5) * .007;
      colors[index * 3] = point.r;
      colors[index * 3 + 1] = point.g;
      colors[index * 3 + 2] = point.b;
      seeds[index] = seed;
    }
    return { positions, colors, seeds };
  };

  const makeGalaxy = settings => {
    const positions = new Float32Array(PARTICLE_COUNT * 2);
    const radiusScale = settings.radius / 72;
    const thickness = settings.thickness / 10;

    for (let index = 0; index < PARTICLE_COUNT; index += 1) {
      const radialSeed = random(index + 19);
      const angleSeed = random(index + 211);
      const widthSeed = random(index + 919) - .5;
      const radius = Math.pow(radialSeed, .72) * .9 * radiusScale;
      const arm = index % Math.round(settings.arms);
      const armAngle = arm / Math.round(settings.arms) * Math.PI * 2;
      const spiral = radius * 5.2;
      const spread = widthSeed * (.05 + radius * thickness * .38);
      const angle = armAngle + spiral + spread + angleSeed * .035;
      const diskNoise = (random(index + 1237) - .5) * thickness * .12;
      positions[index * 2] = Math.cos(angle) * (radius + diskNoise);
      positions[index * 2 + 1] = Math.sin(angle) * (radius + diskNoise) * (.88 + thickness * .11);
    }
    return positions;
  };

  const bindAttribute = (gl, program, name, values, size, usage = gl.STATIC_DRAW) => {
    const buffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
    gl.bufferData(gl.ARRAY_BUFFER, values, usage);
    const location = gl.getAttribLocation(program, name);
    gl.enableVertexAttribArray(location);
    gl.vertexAttribPointer(location, size, gl.FLOAT, false, 0, 0);
    return buffer;
  };

  const init = async figure => {
    const image = figure.querySelector('img');
    const canvas = figure.querySelector('canvas');
    const reducedMotion = matchMedia('(prefers-reduced-motion: reduce)').matches;
    const settings = Object.freeze({
      arms: 4,
      speed: .35,
      radius: 60,
      thickness: 4,
      core: 1.5,
      twinkle: 2
    });
    let gl;
    let program;
    let progress = 0;
    let target = 0;
    let manualUntil = 0;
    let pointer = { x: .5, y: .5 };

    try {
      if (image.decode) await image.decode();
      gl = canvas.getContext('webgl', { alpha: true, antialias: false, premultipliedAlpha: true });
      if (!gl) throw new Error('WebGL is unavailable.');
      program = makeProgram(gl);
      gl.useProgram(program);
      const portrait = samplePortrait(image);
      bindAttribute(gl, program, 'a_portrait', portrait.positions, 2);
      bindAttribute(gl, program, 'a_galaxy', makeGalaxy(settings), 2);
      bindAttribute(gl, program, 'a_color', portrait.colors, 3);
      bindAttribute(gl, program, 'a_seed', portrait.seeds, 1);
      gl.enable(gl.BLEND);
      gl.blendFunc(gl.SRC_ALPHA, gl.ONE);
      figure.classList.add('is-ready');
    } catch (error) {
      console.warn('Galaxy particle shader unavailable; using the source portrait.', error);
      figure.classList.add('shader-fallback');
      return;
    }

    const uniforms = {
      resolution: gl.getUniformLocation(program, 'u_resolution'),
      pointer: gl.getUniformLocation(program, 'u_pointer'),
      progress: gl.getUniformLocation(program, 'u_progress'),
      time: gl.getUniformLocation(program, 'u_time'),
      speed: gl.getUniformLocation(program, 'u_speed'),
      core: gl.getUniformLocation(program, 'u_core'),
      twinkle: gl.getUniformLocation(program, 'u_twinkle'),
      lightMode: gl.getUniformLocation(program, 'u_lightMode')
    };
    let lightMode = null;

    const resize = () => {
      const bounds = figure.getBoundingClientRect();
      const scale = Math.min(devicePixelRatio || 1, 2);
      const width = Math.max(1, Math.round(bounds.width * scale));
      const height = Math.max(1, Math.round(bounds.height * scale));
      if (canvas.width === width && canvas.height === height) return;
      canvas.width = width;
      canvas.height = height;
      gl.viewport(0, 0, width, height);
    };

    canvas.addEventListener('pointermove', event => {
      const bounds = canvas.getBoundingClientRect();
      pointer.x = clamp((event.clientX - bounds.left) / bounds.width);
      pointer.y = 1 - clamp((event.clientY - bounds.top) / bounds.height);
    });
    canvas.addEventListener('pointerdown', () => {
      target = progress > .5 ? 0 : 1;
      manualUntil = performance.now() + 5000;
    });

    const render = now => {
      if (now > manualUntil) {
        const heroTop = figure.closest('.personal-hero')?.offsetTop || 0;
        target = clamp(((window.scrollY || 0) - heroTop) / Math.max(420, innerHeight * .58));
      }
      progress += (target - progress) * (reducedMotion ? 1 : .055);
      const hero = figure.closest('.personal-hero');
      hero?.style.setProperty('--galaxy-progress', progress.toFixed(4));
      hero?.classList.toggle('galaxy-active', progress > .24);
      resize();
      gl.clearColor(0, 0, 0, 0);
      gl.clear(gl.COLOR_BUFFER_BIT);
      gl.useProgram(program);
      gl.uniform2f(uniforms.resolution, canvas.width, canvas.height);
      gl.uniform2f(uniforms.pointer, pointer.x, pointer.y);
      gl.uniform1f(uniforms.progress, progress);
      gl.uniform1f(uniforms.time, reducedMotion ? 0 : now * .001);
      gl.uniform1f(uniforms.speed, settings.speed);
      gl.uniform1f(uniforms.core, settings.core);
      gl.uniform1f(uniforms.twinkle, settings.twinkle);
      const nextLightMode = document.documentElement.dataset.theme === 'light' ? 1 : 0;
      if (nextLightMode !== lightMode) {
        lightMode = nextLightMode;
        gl.blendFunc(gl.SRC_ALPHA, lightMode ? gl.ONE_MINUS_SRC_ALPHA : gl.ONE);
      }
      gl.uniform1f(uniforms.lightMode, lightMode);
      gl.drawArrays(gl.POINTS, 0, PARTICLE_COUNT);
      requestAnimationFrame(render);
    };
    requestAnimationFrame(render);
  };

  document.addEventListener('DOMContentLoaded', () => {
    document.querySelectorAll('[data-hero-shader]').forEach(figure => init(figure));
  });
})();
