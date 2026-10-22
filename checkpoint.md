# Raspberry Pi port — status

**Objective:** make TinySPH compile and run on a 64-bit Raspberry Pi.

**Approach:** EGL + GBM + DRM/KMS with OpenGL ES 2.0. No X11, no GLFW, no
raylib, no Broadcom `/opt/vc` stack. Every dependency is a stock Raspberry Pi
OS package (`libdrm`, `libgbm`, `libEGL`, `libGLESv2`, `libfreetype`, OpenMPI).

Validation uses a `debian:13-slim` container built `--platform linux/arm64`,
which matches Raspberry Pi OS Trixie (Debian 13, gcc 14).

Full plan, findings and rationale: `~/.opencode/plan/sph-demo-raspberry-pi-port.md`

## Background

An earlier attempt migrated the graphics stack to raylib with a DRM backend.
That work was left unfinished — particle and UI rendering were never converted,
so the tree still issued raw GL calls while raylib owned the context. It has
been removed in favour of talking to EGL/GBM/DRM directly, because:

- raylib is not packaged in Debian or Raspberry Pi OS, so it had to be built
  from source on every container build and on every Pi
- it was only providing window creation, context setup and input polling —
  all of which `egl_utils.c` already did for the original Pi target
- the raylib build step was itself the reason `docker build` failed

## Progress

- [x] **Step 0** — remove the unfinished raylib/SDL2 migration
- [x] **Step 1** — fix the compile blockers (green build on Debian 13 arm64)
- [ ] **Step 2** — rewrite `egl_utils.c` window creation for GBM/DRM
- [ ] **Step 3** — input: device discovery, event-loop fixes, keyboard + mouse
- [ ] **Step 3b** — resolution-independent UI
- [ ] **Step 4** — decouple the `RASPI` macro
- [ ] **Step 5** — build files (`makefile_pi`)
- [ ] **Step 6** — Dockerfile
- [ ] **Step 7** — verification
- [ ] **Step 8** — docs

## Steps 0–1, completed

**Removed:** `raylib_utils.c/h`, `sdl2_utils.c/h`.

**Reverted** the raylib/SDL2 backend-selection branches in `background_gl.h`,
`dividers_gl.h`, `font_gl.h`, `liquid_gl.h`, `mover_gl.h`, `rectangle_gl.h`,
`particles_gl.h` and `dividers_gl.c`, `liquid_gl.c`, `mover_gl.c`,
`particles_gl.c`, `rectangle_gl.c`. This also removed a latent bug: in four of
those `.c` files the `GLFW` branch had been pointed at `sdl2_utils.h`.

**Fixed:**

- `renderer.c` — call `window_should_close()`, not `should_close()`. The raylib
  work renamed the call site only; `egl_utils.c` and `glfw_utils.c` both still
  define `window_should_close()`, so the rename had broken *every* backend.
  Under gcc 14 this is a hard error, not a warning.
- `ogl_utils.c` — `check()` is no longer `inline`. A C99 `inline` definition
  with no extern declaration emits no external symbol, so any cross-TU call
  would fail to link.
- `ogl_utils.h` — backend selection is now explicit: `GLFW` for desktop, `DRM`
  for the Raspberry Pi path, `#error` if neither is defined.
- `makefile_linux` / `makefile_macos` — restored to the GLFW desktop build.
- `makefile` (legacy 32-bit Pi) — added `-DDRM` to match the new backend
  selection. This file remains non-functional on 64-bit Pi OS; it is slated for
  retirement in Step 5.

## Known-broken, by design, until Step 2

`egl_utils.c` still calls `bcm_host_init()` and the `vc_dispmanx_*` API, which
do not exist on 64-bit Raspberry Pi OS. The DRM backend therefore cannot be
built yet. The desktop GLFW build is the only one that compiles today, and it
is what the Step 1 exit criterion verifies.
