defmodule ExLTTB do
  @moduledoc """
  Documentation for ExLTTB.
  """

  alias ExLTTB.Point

  def lttb(_sample_list, threshold) when threshold < 2 do
    {:error, :invalid_threshold}
  end

  def lttb([first_sample | _tail] = sample_list, threshold) when threshold == 2 and length(sample_list) >= 2 do
    {:ok, [first_sample, List.last(sample_list)]}
  end

  def lttb(sample_list, threshold) when threshold > length(sample_list) do
    {:ok, sample_list}
  end

  def make_buckets(sample_list, buckets_number) when buckets_number > length(sample_list) do
    Enum.map(sample_list, fn el -> [el] end)
  end

  def make_buckets([first_sample, second_sample | tail] = sample_list, buckets_number) do
    # We subtract 2 since the first and last buckets are fixed,
    # containing the first and last sample
    avg = (length(sample_list) - 2) / (buckets_number -  2)

    # The acc is populated from right to left and reversed at the end
    do_make_buckets(tail, 1, avg, avg, [[second_sample], [first_sample]])
  end

  def average_point(points) do
    {x_sum, y_sum} = Enum.reduce(points, {0, 0}, fn %Point{x: x, y: y}, {x_sum, y_sum} -> {x_sum + x, y_sum + y} end)
    len = length(points)

    %Point{x: x_sum / len, y: y_sum / len}
  end

  defp triangle_area(%Point{x: x1, y: y1}, %Point{x: x2, y: y2}, %Point{x: x3, y: y3}) do
    abs((x1 - x3) * (y2 - y1) - (x1 - x2) * (y3 - y1)) / 2
  end

  defp do_make_buckets([head | []], _current_index, _avg, _avg_acc, buckets_acc) do
    Enum.reverse([[head] | buckets_acc])
  end

  defp do_make_buckets([head | tail], current_index, avg, avg_acc, [bucket_head | bucket_tail] = buckets_acc) do
    next_index =  current_index + 1
    if Float.floor(avg_acc) > current_index do
      do_make_buckets(tail, next_index, avg, avg_acc, [[head | bucket_head] | bucket_tail])
    else
      do_make_buckets(tail, next_index, avg,  avg_acc + avg, [[head] | buckets_acc])
    end
  end
end
