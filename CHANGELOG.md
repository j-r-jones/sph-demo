# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

Work in progress: porting the demo to 64-bit Raspberry Pi OS. See
`checkpoint.md` for current status.

### Removed

- Unfinished raylib migration (`raylib_utils.c/h`) and the abandoned SDL2
  experiment (`sdl2_utils.c/h`). Neither was ever completed: particle and UI
  rendering still issued raw GL calls while raylib owned the context. raylib is
  not packaged in Debian or Raspberry Pi OS, so it had to be compiled from
  source on every build, and its build step was the immediate cause of
  `docker build` failing.

### Fixed

- `renderer.c` called `should_close()` while every backend defines
  `window_should_close()`. The raylib work renamed only the call site, which
  broke the GLFW and EGL backends as well. Under gcc 14 — the compiler shipped
  by Raspberry Pi OS Trixie — this is a hard error rather than a warning, so the
  project did not compile on a current Pi at all.
- `check()` in `ogl_utils.c` was declared `inline` in a `.c` file with no extern
  declaration. Under C99 inline semantics that emits no external symbol, so any
  cross-translation-unit call would have failed to link.
- Four `*_gl.c` files had their `GLFW` backend branch pointed at
  `sdl2_utils.h` instead of `glfw_utils.h`.
- `makefile_linux` and `makefile_macos` restored to the working GLFW desktop
  build after the raylib edits.

### Changed

- Graphics backend selection in `ogl_utils.h` is now explicit. Define `GLFW`
  for the desktop build or `DRM` for the Raspberry Pi path; building with
  neither is a compile error instead of a silent fallback.
- Build output is `bin/sph` rather than `bin/sph.out`, consistently across the
  makefiles and launch scripts.

### Planned

- Replace the Broadcom `bcm_host` / `dispmanx` window creation in
  `egl_utils.c` with EGL + GBM + DRM/KMS, which is what 64-bit Raspberry Pi OS
  actually provides.
- Rework input: scan `/dev/input/event*` rather than assuming `event0`/`event1`,
  drain event queues properly, support key autorepeat, and add a keyboard quit
  binding. Touchscreen support to follow.
- Make the on-screen UI resolution-independent; it is currently sized for
  1080p and occupies half the screen height on an 800x480 panel.
- Separate the `RASPI` macro's three distinct meanings (ES2 render path, asset
  location, performance tuning).
- Rebase the container on Debian 13 to match Raspberry Pi OS Trixie.
