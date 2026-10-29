#!/usr/bin/env python3
"""Apply the SDL-only Mega Man X handheld rendering patch to checked-out submodules."""
from pathlib import Path
import re, sys
root = Path(sys.argv[1]).resolve()
runner = root / "snesrecomp/runner"
ui = root / "recomp-ui"

def rep(path, old, new, n=1):
    s = path.read_text()
    found = s.count(old)
    if found < n:
        raise SystemExit(f"Patch mismatch in {path}: expected {n}, found {found}: {old[:80]!r}")
    path.write_text(s.replace(old, new, n))

host = runner / "src/desktop/host_main.c"
rep(host, '#ifndef __ANDROID__\nvoid OpenGLRenderer_Create(struct RendererFuncs *funcs);\n#include "opengl.h"   /* snesrecomp_opengl_set_vsync */\n#endif\n', '')
rep(host, '''  RendererApply(RendererChoice());
#ifndef __ANDROID__
  if (g_config.output_method == kOutputMethod_OpenGL) {
    g_win_flags |= SDL_WINDOW_OPENGL;
    snesrecomp_opengl_set_vsync(VSyncInterval());
    OpenGLRenderer_Create(&g_renderer_funcs);
  } else
#endif
  {
    /* Android: always SDL_Renderer (GLES-backed); the desktop-GL presenter
     * is not compiled there. */
    g_renderer_funcs = kSdlRendererFuncs;
  }
''', '''  /* SDL-only handheld build: no OpenGL context or presenter. */
  RendererApply(RendererChoice());
  g_config.output_method = kOutputMethod_SDLSoftware;
  snprintf(g_config.renderer, sizeof(g_config.renderer), "software");
  g_renderer_funcs = kSdlRendererFuncs;
''')
rep(runner / "runner.cmake", '''    if(NOT ANDROID)
        snesrecomp_target_opengl(${target})
    endif()
''', '')

# Explicitly choose software SDL for the first launch.
cfg = root / "config.ini"
if cfg.exists():
    s = cfg.read_text()
    s = re.sub(r'(?m)^OutputMethod\s*=.*$', 'OutputMethod = SDL-Software', s, count=1)
    if re.search(r'(?m)^Renderer\s*=', s):
        s = re.sub(r'(?m)^Renderer\s*=.*$', 'Renderer = software', s, count=1)
    else:
        s = re.sub(r'(?m)^(\[Graphics\]\s*)$', r'\1\nRenderer = software', s, count=1)
    cfg.write_text(s)

# Launcher platform: SDL window + SDL software renderer, no GL context.
ph = ui / "src/common/launcher_platform.h"
rep(ph, '    SDL_GLContext gl;\n', '    SDL_Renderer* renderer;\n')
rep(ph, '    // Physical framebuffer size in pixels — what glViewport uses.\n',
        '    // Physical framebuffer size in pixels — SDL renderer output dimensions.\n')
rep(ph, '// Create the window (RESIZABLE + HIGH_PIXEL_DENSITY) and a GL 3.3 core context.\n// Returns false if SDL/GL initialization fails (caller boots as if skipped).\n',
        '// Create the window and SDL software renderer.\n// Returns false if SDL initialization fails (caller boots as if skipped).\n')
rep(ph, '// Present the current GL framebuffer.\n', '// Present the current SDL renderer backbuffer.\n')
rep(ph, '// Tear down GL context + window and reset GL attributes, so the game runtime\\'s SDL layer starts from a clean slate afterward.\n',
        '// Tear down the SDL renderer + window so the game runtime can continue using SDL.\n')
rep(ph, '// When quit_sdl is false, launcher_platform_close destroys only the launcher window/GL context and leaves SDL initialized for the host. Default is true (standalone launcher harnesses expect a full teardown).\n',
        '// When quit_sdl is false, launcher_platform_close destroys only the launcher renderer/window and leaves SDL initialized for the host. Default is true.\n')

pc = ui / "src/common/launcher_platform_sdl2.c"
rep(pc, '''    // GL dialect. Default: desktop GL 3.3 core (matches the vendored ImGui
    // opengl3 backend + "#version 330"). A host that reuses its OWN ImGui copy
    // compiled for GLES 2 (e.g. gb-recompiled, which renders through ANGLE)
    // defines LNG_GLES2 so the launcher's context MATCHES that backend — a
    // core-profile context with a GLES2 backend has no VAO and crashes.
#ifdef LNG_GLES2
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_ES);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 2);   // ES 2.0, matching the host backend
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 0);
#else
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
#endif
    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
    SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 0);

''', '')
rep(pc, 'Uint32 window_flags = SDL_WINDOW_OPENGL | SDL_WINDOW_RESIZABLE |\n                          SDL_WINDOW_ALLOW_HIGHDPI;',
        'Uint32 window_flags = SDL_WINDOW_RESIZABLE | SDL_WINDOW_ALLOW_HIGHDPI;')
rep(pc, '''    p->gl = SDL_GL_CreateContext(p->window);
    if (!p->gl) {
        fprintf(stderr, "[launcher] SDL_GL_CreateContext failed: %s\\\\n", SDL_GetError());
        SDL_DestroyWindow(p->window);
        p->window = NULL;
        if (s_quit_sdl) SDL_Quit();
        return false;
    }

    SDL_GL_MakeCurrent(p->window, p->gl);
    SDL_GL_SetSwapInterval(1);
''', '''    p->renderer = SDL_CreateRenderer(p->window, -1, SDL_RENDERER_SOFTWARE);
    if (!p->renderer) {
        fprintf(stderr, "[launcher] SDL_CreateRenderer(software) failed: %s\\\\n", SDL_GetError());
        SDL_DestroyWindow(p->window);
        p->window = NULL;
        if (s_quit_sdl) SDL_Quit();
        return false;
    }
    SDL_SetRenderDrawBlendMode(p->renderer, SDL_BLENDMODE_BLEND);
    launcher_texture_set_renderer(p->renderer);
''')
rep(pc, '    SDL_GL_GetDrawableSize(p->window, &p->pixel_w, &p->pixel_h);',
        '    if (p->renderer) SDL_GetRendererOutputSize(p->renderer, &p->pixel_w, &p->pixel_h);')
rep(pc, '    if (p && p->window) SDL_GL_SwapWindow(p->window);',
        '    if (p && p->renderer) SDL_RenderPresent(p->renderer);')
rep(pc, '''    if (p->gl)     { SDL_GL_DeleteContext(p->gl); p->gl = NULL; }
    if (p->window) { SDL_DestroyWindow(p->window); p->window = NULL; }
    SDL_GL_ResetAttributes();   // leave a clean slate for the game's SDL usage
''', '''    if (p->renderer) {
        launcher_texture_set_renderer(NULL);
        SDL_DestroyRenderer(p->renderer);
        p->renderer = NULL;
    }
    if (p->window) { SDL_DestroyWindow(p->window); p->window = NULL; }
''')

# SDL texture-backed launcher artwork; uintptr_t preserves pointer width.
gh = ui / "src/common/launcher_gl.h"
rep(gh, '#include <stdbool.h>\n', '#include <stdbool.h>\n#include <stdint.h>\n#include "launcher_sdlcompat.h"\n')
rep(gh, '    unsigned int id;   // GL texture name (0 = not loaded)\n',
        '    uintptr_t id;     // SDL_Texture pointer encoded as an integer (0 = not loaded)\n')
rep(gh, 'LauncherTexture launcher_texture_load(const char* path);\n',
        'void launcher_texture_set_renderer(SDL_Renderer* renderer);\nLauncherTexture launcher_texture_load(const char* path);\n')

gc = ui / "src/common/launcher_gl.c"
gc.write_text(r'''// launcher_gl.c — SDL texture loader (stb_image + SDL_Renderer).
#include "launcher_gl.h"
#include <stdint.h>
#include <stdlib.h>
#include "launcher_sdlcompat.h"
#define STBI_WINDOWS_UTF8
#define STBI_MAX_DIMENSIONS 8192
#define STB_IMAGE_STATIC
#define STB_IMAGE_IMPLEMENTATION
#define STBI_ONLY_TGA
#define STBI_ONLY_PNG
#define STBI_ONLY_JPEG
#include "third_party/stb_image.h"
static SDL_Renderer *s_renderer;
void launcher_texture_set_renderer(SDL_Renderer *renderer) { s_renderer = renderer; }
unsigned char* launcher_image_load_rgba(const char* path, int* w, int* h) {
    int iw = 0, ih = 0, comp = 0;
    if (!path || !path[0]) return NULL;
    unsigned char* pixels = stbi_load(path, &iw, &ih, &comp, 4);
    if (!pixels) return NULL;
    if (iw <= 0 || ih <= 0) { stbi_image_free(pixels); return NULL; }
    if (w) *w = iw; if (h) *h = ih;
    return pixels;
}
void launcher_image_free(unsigned char* pixels) { if (pixels) stbi_image_free(pixels); }
static LauncherTexture load_impl(const char* path, int colorkey_tol) {
    LauncherTexture t = { 0, 0, 0 };
    int w = 0, h = 0, comp = 0;
    if (!s_renderer || !path || !stbi_info(path, &w, &h, &comp) ||
        w <= 0 || h <= 0 || (uint64_t)w * (uint64_t)h > 16u * 1024u * 1024u) return t;
    unsigned char *pixels = stbi_load(path, &w, &h, &comp, 4);
    if (!pixels) return t;
    if (colorkey_tol >= 0) {
        const unsigned char kr = pixels[0], kg = pixels[1], kb = pixels[2];
        for (int i = 0; i < w * h; ++i) {
            unsigned char *p = pixels + i * 4;
            int dr = abs((int)p[0] - kr), dg = abs((int)p[1] - kg), db = abs((int)p[2] - kb);
            if (dr <= colorkey_tol && dg <= colorkey_tol && db <= colorkey_tol) p[3] = 0;
        }
    }
    SDL_Surface *surface = SDL_CreateRGBSurfaceWithFormatFrom(pixels, w, h, 32, w * 4, SDL_PIXELFORMAT_RGBA32);
    SDL_Texture *texture = surface ? SDL_CreateTextureFromSurface(s_renderer, surface) : NULL;
    if (surface) SDL_FreeSurface(surface);
    stbi_image_free(pixels);
    if (!texture) return t;
    SDL_SetTextureBlendMode(texture, SDL_BLENDMODE_BLEND);
#if SDL_VERSION_ATLEAST(2, 0, 12)
    SDL_SetTextureScaleMode(texture, SDL_ScaleModeLinear);
#endif
    t.id = (uintptr_t)texture; t.w = w; t.h = h;
    return t;
}
LauncherTexture launcher_texture_load(const char* path) { return load_impl(path, -1); }
LauncherTexture launcher_texture_load_colorkey(const char* path, int tolerance) {
    return load_impl(path, tolerance < 0 ? 0 : tolerance);
}
void launcher_texture_free(LauncherTexture* t) {
    if (t && t->id) { SDL_DestroyTexture((SDL_Texture *)(uintptr_t)t->id); t->id = 0; }
}
''')

# Use the official ImGui SDL_Renderer2 backend for the launcher UI.
imgui = ui / "src/common/backends/imgui/launcher_imgui.cpp"
rep(imgui, '#include "imgui_impl_opengl3.h"\n', '#include "imgui_impl_sdlrenderer2.h"\n')
rep(imgui, 'LNG_ImplSDL_InitForOpenGL', 'LNG_ImplSDL_InitForSDLRenderer')
rep(imgui, 'ImGui_ImplSDL3_InitForOpenGL', 'ImGui_ImplSDL3_InitForSDLRenderer')
rep(imgui, 'ImGui_ImplSDL2_InitForOpenGL', 'ImGui_ImplSDL2_InitForSDLRenderer')
rep(imgui, '''    LNG_ImplSDL_InitForSDLRenderer(p->window, p->gl);
#ifdef LNG_GLES2
    ImGui_ImplOpenGL3_Init("#version 100");   // GLES 2 GLSL (host ANGLE backend)
#else
    ImGui_ImplOpenGL3_Init("#version 330");
#endif
    launcher_boot_timing_mark("rui:imgui_gl_ready");''',
'''    LNG_ImplSDL_InitForSDLRenderer(p->window, p->renderer);
    ImGui_ImplSDLRenderer2_Init(p->renderer);
    launcher_boot_timing_mark("rui:imgui_sdlrenderer_ready");''')
for a,b in [
('ImGui_ImplOpenGL3_DestroyFontsTexture()', 'ImGui_ImplSDLRenderer2_DestroyFontsTexture()'),
('ImGui_ImplOpenGL3_CreateFontsTexture()', 'ImGui_ImplSDLRenderer2_CreateFontsTexture()'),
('ImGui_ImplOpenGL3_NewFrame()', 'ImGui_ImplSDLRenderer2_NewFrame()'),
('ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData())', 'ImGui_ImplSDLRenderer2_RenderDrawData(ImGui::GetDrawData(), p->renderer)'),
('ImGui_ImplOpenGL3_Shutdown()', 'ImGui_ImplSDLRenderer2_Shutdown()')]:
    rep(imgui, a, b)
rep(imgui, '''        glViewport(0, 0, p->pixel_w, p->pixel_h);
        const LngColor bg = th->background;
        glClearColor(bg.r, bg.g, bg.b, bg.a);
        glClear(GL_COLOR_BUFFER_BIT);
''', '''        const LngColor bg = th->background;
        SDL_SetRenderDrawColor(p->renderer, (Uint8)(bg.r * 255.0f),
            (Uint8)(bg.g * 255.0f), (Uint8)(bg.b * 255.0f),
            (Uint8)(bg.a * 255.0f));
        SDL_RenderClear(p->renderer);
''')

# The launcher compiles the SDL renderer backend instead of ImGui OpenGL3.
cm = ui / "recomp_ui.cmake"
rep(cm, 'include("${RECOMP_UI_ROOT}/cmake/recomp_gl.cmake")\n', '')
rep(cm, '${RUI_IMGUI}/backends/imgui_impl_opengl3.cpp',
        '${RUI_IMGUI}/backends/imgui_impl_sdlrenderer2.cpp')
old = re.search(r'    # OpenGL: the ImGui GL3 backend.*?    endif\(\)\n\n    # ---- color emoji providers', cm.read_text(), re.S)
if not old: raise SystemExit("Patch mismatch: could not find recomp-ui OpenGL link block")
s = cm.read_text()
s = s[:old.start()] + '''    # SDL_Renderer is the only presentation backend; no OpenGL/EGL is linked.
    if(WIN32)
        target_link_libraries(${TGT} PRIVATE ws2_32)
    else()
        target_link_libraries(${TGT} PRIVATE ${CMAKE_DL_LIBS})
    endif()

    # ---- color emoji providers''' + s[old.end():]
cm.write_text(s)
print("SDL-only patch applied: gameplay, launcher, ImGui, artwork textures, and link dependencies.")
