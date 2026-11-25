defmodule Emerge.UI.Transform do
  require Emerge.Docs.Examples

  alias Emerge.Docs.Examples

  Examples.external_resources(~w(
      ui-transform-translate
      ui-transform-rotate-scale
      ui-transform-alpha
      ui-transform-slot-vs-visual
    ))

  @moduledoc """
  Transform and opacity helpers.

  `Emerge.UI.Transform` changes how an element is painted without changing how a
  row, column, or generic container measures and places that element.

  Use:

  - `move_x/1` and `move_y/1` to offset the painted element in logical pixels
  - `rotate/1` to turn an element around its center
  - `scale/1` to grow or shrink an element around its center
  - `alpha/1` to reduce opacity for the rendered element subtree

  ## Layout vs Paint

  Transforms do not reserve extra layout space. The element keeps its normal
  layout slot, then the transform is applied when rendering.

  This is useful for lifted cards, pressed states, emphasis, decorative tilt,
  and motion styles that should not push siblings around.

  ## Interaction

  Pointer hit testing follows the transformed shape that the user sees on screen,
  not the pre-transform slot. Hover, press, and move handlers stay attached to
  the painted result.

  ## Opacity

  `alpha/1` affects the rendered element subtree. Background, border, text,
  images, and children all inherit that opacity while layout stays unchanged.

  ## Examples

  Translation moves the painted element while the row still keeps its original
  slot:

  #{Examples.code_block!("ui-transform-translate")}

  #{Examples.image_tag!("ui-transform-translate", "Rendered translated transform example")}

  Rotation and scale both happen around the element center:

  #{Examples.code_block!("ui-transform-rotate-scale")}

  #{Examples.image_tag!("ui-transform-rotate-scale", "Rendered rotate and scale transform example")}

  Opacity is useful for de-emphasized branches without changing layout:

  #{Examples.code_block!("ui-transform-alpha")}

  #{Examples.image_tag!("ui-transform-alpha", "Rendered alpha transform example")}

  The faint outline below marks the original slot. The transformed card is what
  the user sees and what pointer hit testing follows:

  #{Examples.code_block!("ui-transform-slot-vs-visual")}

  #{Examples.image_tag!("ui-transform-slot-vs-visual", "Rendered layout slot versus transformed visual example")}
  """

  @type numeric_attr ::
          {:move_x, number()}
          | {:move_y, number()}
          | {:rotate, number()}
          | {:scale, number()}
          | {:alpha, number()}

  @type t :: numeric_attr()

  @doc """
  Move the painted element on the X axis.

  Positive values move right. Negative values move left. The layout slot does
  not move.

  ## Example

  ```elixir
  el(
    [
      width(px(120)),
      height(px(64)),
      Transform.move_x(18),
      Background.color(color(:sky, 600)),
      Border.rounded(12),
      Font.color(color(:white))
    ],
    text("Shifted")
  )
  ```
  """
  @spec move_x(number()) :: {:move_x, number()}
  def move_x(value) when is_number(value), do: {:move_x, value}

  @doc """
  Move the painted element on the Y axis.

  Positive values move down. Negative values move up. The layout slot does not
  move.

  ## Example

  A subtle downward nudge is useful for pressed or resting floating-card states.

  ```elixir
  el(
    [
      width(px(120)),
      height(px(64)),
      Transform.move_y(6),
      Background.color(color(:emerald, 600)),
      Border.rounded(12),
      Font.color(color(:white))
    ],
    text("Lowered")
  )
  ```
  """
  @spec move_y(number()) :: {:move_y, number()}
  def move_y(value) when is_number(value), do: {:move_y, value}

  @doc """
  Rotate the painted element in degrees around its center.

  Rotation does not change the element's layout slot.

  ## Example

  ```elixir
  el(
    [
      width(px(140)),
      height(px(72)),
      Transform.rotate(-8),
      Background.color(color(:violet, 600)),
      Border.rounded(12),
      Font.color(color(:white))
    ],
    text("Tilted note")
  )
  ```
  """
  @spec rotate(number()) :: {:rotate, number()}
  def rotate(value) when is_number(value), do: {:rotate, value}

  @doc """
  Scale the painted element uniformly around its center.

  `1.0` keeps the original size, values above `1.0` enlarge, and values between
  `0.0` and `1.0` shrink.

  ## Example

  ```elixir
  el(
    [
      width(px(140)),
      height(px(72)),
      Transform.scale(1.1),
      Background.color(color(:amber, 500)),
      Border.rounded(12),
      Font.color(color(:slate, 950))
    ],
    text("Emphasized")
  )
  ```
  """
  @spec scale(number()) :: {:scale, number()}
  def scale(value) when is_number(value), do: {:scale, value}

  @doc """
  Set opacity for the rendered element subtree.

  Use values between `0.0` and `1.0`, where `0.0` is fully transparent and
  `1.0` is fully opaque.

  ## Example

  This dims the whole card, including its text and border.

  ```elixir
  el(
    [
      padding(12),
      Transform.alpha(0.45),
      Background.color(color(:white)),
      Border.rounded(12),
      Border.width(1),
      Border.color(color(:slate, 200))
    ],
    text("Archived")
  )
  ```
  """
  @spec alpha(number()) :: {:alpha, number()}
  def alpha(value) when is_number(value), do: {:alpha, value}

  # Rec. 709 luminance weights.
  @luma [0.2126, 0.7152, 0.0722]

  @doc """
  Draw the element subtree through a color matrix: grayscale, a tint or any 4x5 matrix.

    * `:grayscale` or `{:grayscale, amount}` - `amount` from `0.0` (unchanged) to `1.0` (gray)
    * `{:tint, color}` - the luminance of each pixel in that color, such as `color(:sky)` or
      `color_rgb(0, 120, 255)`, as a duotone from black to the color; the alpha of the color is
      ignored
    * a list of 20 numbers - a 4x5 matrix in row-major order: each output channel R, G, B, A is
      the dot product of its row with `[r, g, b, a, 1]`, channels from `0.0` to `1.0`; the last
      value, the offset of the alpha row, is `0`

  Like `alpha/1`, the subtree draws into its own layer, one layer for both; the identity matrix
  draws none.

  ## Example

  ```elixir
  el([Transform.color_matrix(:grayscale)], video([width(fill()), height(fill())], :camera))
  ```
  """
  @spec color_matrix(
          :grayscale
          | {:grayscale, number()}
          | {:tint, {:color_rgb, {0..255, 0..255, 0..255}} | {:color_rgba, tuple()}}
          | [number()]
        ) ::
          {:color_matrix, [number()]}
  def color_matrix(:grayscale), do: color_matrix({:grayscale, 1.0})

  def color_matrix({:grayscale, amount}) when is_number(amount) and amount >= 0 and amount <= 1 do
    rgb_matrix(
      for channel <- 0..2 do
        Enum.with_index(@luma, fn weight, column ->
          weight * amount + if(column == channel, do: 1 - amount, else: 0)
        end)
      end
    )
  end

  def color_matrix({:tint, {:color_rgb, {r, g, b}}}),
    do: rgb_matrix(for channel <- [r, g, b], do: Enum.map(@luma, &(&1 * channel / 255)))

  def color_matrix({:tint, {:color_rgba, {r, g, b, _a}}}),
    do: color_matrix({:tint, {:color_rgb, {r, g, b}}})

  def color_matrix(matrix) when is_list(matrix) and length(matrix) == 20,
    do: {:color_matrix, matrix}

  def color_matrix(other) do
    raise ArgumentError,
          "color_matrix/1 expects :grayscale, {:grayscale, 0..1}, {:tint, color} or 20 numbers, " <>
            "got: #{inspect(other)}"
  end

  # Rows of weights on r, g, b for the color channels; alpha passes through.
  defp rgb_matrix(rows),
    do: {:color_matrix, Enum.flat_map(rows, &(&1 ++ [0, 0])) ++ [0, 0, 0, 1, 0]}
end
