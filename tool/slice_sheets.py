#!/usr/bin/env python3
"""Fatiador de sprite sheets do Educa Games.

Segmenta uma folha de sprites detectando faixas (linhas/colunas) sem conteudo,
recorta cada sprite, remove o fundo branco por flood-fill a partir das bordas
(preservando brancos internos) e salva PNGs com transparencia.

Uso: python3 tool/slice_sheets.py
"""
import os
from PIL import Image, ImageDraw

ASSETS = os.path.join(os.path.dirname(__file__), "..", "assets")

# (arquivo de origem, pasta de saida, prefixo, qtd esperada)
SHEETS = [
    ("avatars/sheets/boys_12.png", "avatars/base/boys", "boy", 12),
    ("avatars/sheets/girls_12.png", "avatars/base/girls", "girl", 12),
    ("cosmetics/sheets/glasses_30.png", "cosmetics/glasses", "glasses", 30),
    ("cosmetics/sheets/hats_36.png", "cosmetics/hats", "hat", 36),
]

BG_TOL = 18          # tolerancia de "quase branco" para o fundo
MIN_BAND = 12        # tamanho minimo (px) de uma faixa com conteudo
GAP = 6              # gap minimo (px) de espaco vazio que separa sprites


def is_bg(px, tol=BG_TOL):
    return px[0] >= 255 - tol and px[1] >= 255 - tol and px[2] >= 255 - tol


def content_mask(img):
    """Retorna lista de bools por pixel: True = conteudo (nao-fundo)."""
    px = img.load()
    w, h = img.size
    mask = bytearray(w * h)
    for y in range(h):
        row = y * w
        for x in range(w):
            p = px[x, y]
            mask[row + x] = 0 if is_bg(p) else 1
    return mask, w, h


def bands(profile, min_band=MIN_BAND, gap=GAP):
    """Dado um perfil 1D (qtd de conteudo por linha/coluna), retorna faixas
    (inicio, fim) separadas por trechos vazios de pelo menos `gap`."""
    out = []
    n = len(profile)
    i = 0
    while i < n:
        if profile[i] > 0:
            j = i
            empty = 0
            last = i
            while j < n:
                if profile[j] > 0:
                    last = j
                    empty = 0
                else:
                    empty += 1
                    if empty >= gap:
                        break
                j += 1
            if last - i + 1 >= min_band:
                out.append((i, last + 1))
            i = j + 1
        else:
            i += 1
    return out


def col_profile(mask, w, h, y0, y1):
    prof = [0] * w
    for y in range(y0, y1):
        row = y * w
        for x in range(w):
            prof[x] += mask[row + x]
    return prof


def remove_bg(tile):
    """Flood-fill transparente a partir dos 4 cantos."""
    tile = tile.convert("RGBA")
    w, h = tile.size
    # Usa um RGB auxiliar para floodfill com cor sentinela.
    rgb = tile.convert("RGB")
    seen = Image.new("L", (w, h), 0)
    sentinel = (255, 0, 255)
    for corner in [(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)]:
        if is_bg(rgb.getpixel(corner)):
            ImageDraw.floodfill(rgb, corner, sentinel, thresh=BG_TOL + 12)
    px_rgb = rgb.load()
    px_t = tile.load()
    for y in range(h):
        for x in range(w):
            if px_rgb[x, y] == sentinel:
                r, g, b, _ = px_t[x, y]
                px_t[x, y] = (r, g, b, 0)
    return tile


def trim(tile):
    bbox = tile.getbbox()
    return tile.crop(bbox) if bbox else tile


def slice_sheet(src, outdir, prefix, expected):
    path = os.path.normpath(os.path.join(ASSETS, src))
    img = Image.open(path).convert("RGB")
    mask, w, h = content_mask(img)

    # Perfil por linha -> faixas de linhas (rows com conteudo).
    row_prof = [sum(mask[y * w:(y + 1) * w]) for y in range(h)]
    row_bands = bands(row_prof)

    sprites = []  # (y0,x0) ordenado
    for (ry0, ry1) in row_bands:
        cprof = col_profile(mask, w, h, ry0, ry1)
        for (cx0, cx1) in bands(cprof):
            tile = img.crop((cx0, ry0, cx1, ry1))
            tile = remove_bg(tile)
            tile = trim(tile)
            # ignora ruidos minusculos
            if tile.size[0] >= MIN_BAND and tile.size[1] >= MIN_BAND:
                sprites.append((ry0, cx0, tile))

    outpath = os.path.normpath(os.path.join(ASSETS, outdir))
    os.makedirs(outpath, exist_ok=True)
    for i, (_, _, tile) in enumerate(sprites, 1):
        tile.save(os.path.join(outpath, f"{prefix}_{i:02d}.png"))

    status = "OK" if len(sprites) == expected else "VERIFICAR"
    print(f"[{status}] {src}: {len(sprites)} sprites (esperado {expected}) -> {outdir}")
    return len(sprites)


if __name__ == "__main__":
    for sheet in SHEETS:
        slice_sheet(*sheet)
