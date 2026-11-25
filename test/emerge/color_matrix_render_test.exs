defmodule Emerge.ColorMatrixRenderTest do
  # The macOS render host links to the first test process that starts it.
  use ExUnit.Case, async: false
  use Emerge.UI

  alias EmergeSkia.TreeRenderer

  defp pixel(tree) do
    <<r, g, b, a, _rest::binary>> =
      TreeRenderer.render_to_pixels(
        tree,
        [otp_app: :emerge, width: 20, height: 20, scale: 1.0],
        5_000
      )

    {r, g, b, a}
  end

  test "grayscale and tint change the drawn colors" do
    red = fn attrs ->
      el([width(fill()), height(fill()), Background.color(color_rgb(255, 0, 0))] ++ attrs, none())
    end

    assert {255, 0, 0, 255} = pixel(red.([]))
    assert {r, g, b, 255} = pixel(red.([Transform.color_matrix(:grayscale)]))
    assert r == g and g == b and r in 50..60
    assert {r, g, b, 255} = pixel(red.([Transform.color_matrix({:tint, color_rgb(0, 0, 255)})]))
    assert r == 0 and g == 0 and b in 50..60
  end

  test "alpha and a color matrix draw in one layer; identity draws none" do
    red = fn attrs ->
      el([width(fill()), height(fill()), Background.color(color_rgb(255, 0, 0))] ++ attrs, none())
    end

    # Premultiplied: gray at half alpha.
    assert {r, g, b, a} = pixel(red.([Transform.alpha(0.5), Transform.color_matrix(:grayscale)]))
    assert r == g and g == b and r in 26..28 and a in 127..128
    assert {255, 0, 0, 255} = pixel(red.([Transform.color_matrix({:grayscale, 0.0})]))
  end
end
