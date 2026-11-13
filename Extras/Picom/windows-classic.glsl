#version 330
// Windows Classic — shader do picom (extra opcional) para o tema
// Openbox Windows-Classic.
//
// O Openbox desenha bordas de uma cor só e relevos de 1 px. Este shader
// redesenha, sobre a janela já composta, o relevo 3D do tema Clássico:
//
//  Moldura (EDGE_RAISED), 2 px por fora:
//    externa: #D4D0C8 (cima/esq.)  #404040 (baixo/dir.)
//    interna: #FFFFFF (cima/esq.)  #808080 (baixo/dir.)
//
//  Botões do título (2 px, como no XP):
//    O Openbox pinta a sombra do Bevel1 com uma cor "marcadora"
//    (#817E7A, gerada por ".bg.shadow: 101" no themerc). O shader troca essa linha por
//    #404040 e pinta de #808080 a linha de face (#D4D0C8) vizinha a ela.
//    Funciona nos estados normal (sombra embaixo/dir.) e pressionado
//    (sombra em cima/esq.).
//
// Só é aplicado a janelas cujo _NET_FRAME_EXTENTS indique a moldura do
// tema, e aos menus do próprio Openbox (regra em picom.conf).

in vec2 texcoord;
uniform sampler2D tex;
vec4 default_post_processing(vec4 c);

// Altura máxima da área de título (borda 4 + título 18 + folga)
const int TITLE_LIMIT = 26;

const vec3 FACE   = vec3(212.0, 208.0, 200.0) / 255.0; // ButtonFace
const vec3 LIGHT  = vec3(212.0, 208.0, 200.0) / 255.0; // ButtonLight
const vec3 HILITE = vec3(1.0);                          // ButtonHilight
const vec3 SHADOW = vec3(128.0) / 255.0;                // ButtonShadow
const vec3 DKSHAD = vec3(64.0) / 255.0;                 // ButtonDkShadow
const vec3 MARKER = vec3(129.0, 126.0, 122.0) / 255.0;  // sombra do Openbox

bool same(vec3 a, vec3 b) { return all(lessThan(abs(a - b), vec3(1.5 / 255.0))); }

vec3 at(ivec2 p, ivec2 size) {
    return texelFetch(tex, clamp(p, ivec2(0), size - 1), 0).rgb;
}

vec4 window_shader() {
    ivec2 size = textureSize(tex, 0);
    ivec2 p = ivec2(texcoord);
    vec4 c = texelFetch(tex, p, 0);
    int r = size.x - 1 - p.x;   // distância até a borda direita
    int b = size.y - 1 - p.y;   // distância até a borda inferior

    // Moldura 3D: as linhas de baixo/direita cobrem as de cima/esquerda
    // nos cantos, igual ao DrawEdge do Windows.
    if (r == 0 || b == 0)           c.rgb = DKSHAD;
    else if (p.x == 0 || p.y == 0)  c.rgb = LIGHT;
    else if (r == 1 || b == 1)      c.rgb = SHADOW;
    else if (p.x == 1 || p.y == 1)  c.rgb = HILITE;
    else if (p.y < TITLE_LIMIT) {
        // Botões do título
        if (same(c.rgb, MARKER)) {
            c.rgb = DKSHAD;
        } else if (same(c.rgb, FACE)) {
            if (same(at(p + ivec2(1, 0), size), MARKER) ||
                same(at(p + ivec2(0, 1), size), MARKER) ||
                same(at(p - ivec2(1, 0), size), MARKER) ||
                same(at(p - ivec2(0, 1), size), MARKER))
                c.rgb = SHADOW;
        }
    }
    return default_post_processing(c);
}
