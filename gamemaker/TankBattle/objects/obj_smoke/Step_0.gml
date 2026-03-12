// =============================================================================
// obj_smoke - Step Event
// =============================================================================

life += delta_time / 1000;
var t = life / max_life;

image_alpha = 0.4 * (1 - t);
image_xscale = 0.3 + t * 0.5;
image_yscale = image_xscale;

if (life >= max_life) {
    instance_destroy();
}
