"""Dev 13: bake the shared tileable terrain detail texture (assets/textures/terrain/snow_detail.png).
R = fine grain + wind streaks (anisotropic, along +X), G = broad irregular patches / drifts, B = sparkle mask.
FFT-filtered white noise is periodic, so the texture tiles seamlessly. Deterministic seed."""
import numpy as np
from PIL import Image

N = 512
rng = np.random.default_rng(20261115)
fx = np.fft.fftfreq(N)[None, :]
fy = np.fft.fftfreq(N)[:, None]


def filtered(sigma_x, sigma_y):
    noise = np.fft.fft2(rng.standard_normal((N, N)))
    g = np.exp(-((fx / sigma_x) ** 2 + (fy / sigma_y) ** 2))
    out = np.real(np.fft.ifft2(noise * g))
    return (out - out.mean()) / out.std()


grain = filtered(0.35, 0.35)          # fine grain
streak = filtered(0.01, 0.12)         # long along X, narrow across: wind streaks
patch = filtered(0.012, 0.012) + 0.5 * filtered(0.03, 0.03)  # broad patches / drift transitions
r = 0.5 + 0.10 * grain + 0.16 * streak
g = 0.5 + 0.22 * patch / patch.std()
b = (grain > 2.6).astype(float)
img = np.stack([np.clip(c, 0, 1) for c in (r, g, b)], -1)
Image.fromarray((img * 255).astype(np.uint8), "RGB").save("assets/textures/terrain/snow_detail.png")
print("ok", img.mean(axis=(0, 1)))
