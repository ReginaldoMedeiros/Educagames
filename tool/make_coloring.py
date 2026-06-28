#!/usr/bin/env python3
"""Gera páginas de colorir (line-art) a partir da arte colorida existente.

Para cada PNG de origem (personagem com fundo transparente), produz um contorno
preto grosso sobre fundo TRANSPARENTE — pronto pra sobrepor a uma camada de
pintura no app (cores entram por trás, linhas pretas ficam por cima).

Uso: python3 tool/make_coloring.py
"""
import os
from PIL import Image, ImageFilter, ImageOps, ImageChops

ASSETS = os.path.join(os.path.dirname(__file__), "..", "assets")
OUT = os.path.normpath(os.path.join(ASSETS, "games", "coloring"))


def line_art(src_path, size=720, thickness=2):
    im = Image.open(src_path).convert("RGBA")
    # fundo branco para o cálculo de bordas
    white = Image.new("RGBA", im.size, (255, 255, 255, 255))
    flat = Image.alpha_composite(white, im).convert("L")

    # bordas internas (detalhes do desenho)
    edges = flat.filter(ImageFilter.FIND_EDGES)
    edges = ImageOps.invert(edges)            # bordas ficam escuras
    edges = edges.point(lambda p: 0 if p < 110 else 255)  # threshold -> P&B

    # contorno externo a partir do canal alpha (silhueta do personagem)
    alpha = im.split()[3]
    a_edges = alpha.filter(ImageFilter.FIND_EDGES).point(lambda p: 255 if p > 40 else 0)
    a_edges = ImageOps.invert(a_edges)        # contorno preto sobre branco

    # combina (mínimo = mantém o que for preto em qualquer um)
    lines = ImageChops.darker(edges, a_edges)

    # engrossa as linhas (amigável pra criança)
    for _ in range(thickness):
        lines = lines.filter(ImageFilter.MinFilter(3))

    # limita ao interior do personagem + uma folga, e quadra a imagem
    lines = lines.convert("L")
    out = lines.resize((size, size))

    # branco -> transparente; preto -> preto opaco
    rgba = Image.new("RGBA", out.size, (0, 0, 0, 0))
    px_src = out.load()
    px = rgba.load()
    for y in range(out.height):
        for x in range(out.width):
            v = px_src[x, y]
            if v < 128:
                px[x, y] = (30, 30, 30, 255)
    return rgba


def collect_sources():
    srcs = []
    for folder in ("avatars/base/boys", "avatars/base/girls"):
        d = os.path.normpath(os.path.join(ASSETS, folder))
        for f in sorted(os.listdir(d)):
            if f.endswith(".png"):
                srcs.append(os.path.join(d, f))
    mascot = os.path.normpath(
        os.path.join(ASSETS, "branding/mascot/mestre_corujao.png"))
    if os.path.exists(mascot):
        srcs.append(mascot)
    return srcs


if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    srcs = collect_sources()
    for i, s in enumerate(srcs, 1):
        la = line_art(s)
        la.save(os.path.join(OUT, f"coloring_{i:02d}.png"))
    print(f"gerados {len(srcs)} desenhos de colorir em assets/games/coloring/")
