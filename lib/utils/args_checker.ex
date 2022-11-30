defmodule SurrealEx.ArgsChecker do

  def apply(args, filters) when is_list(filters) do
    init = {:ok, args}

    filters
    |> Enum.reduce(init, fn check_fn, acc ->
      case check_fn.(args) do
        {:ok, _} -> acc
        {:error, err_msg} ->
          case acc do
            {:ok, _} -> {:error, [err_msg]}
            {:error, messages} -> {:error, messages ++ [err_msg]}
          end
      end
    end)
  end
  def apply(args, filters) do
    #  Info message or Exception.
    {:ok, args}
  end

  def greater_than(field, value_x) do
    fn(args) ->
      val = args[field]
      cond do
        is_number(val) && val > value_x -> {:ok, nil}
        true -> {:error, "'#{field}' should be greater than #{value_x}"}
      end
    end
  end

  def greater_or_equal_than(field, value_x) do
    fn(args) ->
      val = args[field]
      cond do
        is_number(val) && val >= value_x -> {:ok, nil}
        true -> {:error, "'#{field}' should be greater or equal than #{value_x}"}
      end
    end
  end

  def less_than(field, value_x) do
    fn(args) ->
      val = args[field]
      cond do
        is_number(val) && val < value_x -> {:ok, nil}
        true -> {:error, "'#{field}' should be less than #{value_x}"}
      end
    end
  end

  def less_or_equal_than(field, value_x) do
    fn(args) ->
      val = args[field]
      cond do
        is_number(val) && val <= value_x -> {:ok, nil}
        true -> {:error, "'#{field}' should be less or equal than #{value_x}"}
      end
    end
  end



  def eq(field, value_x) do
    fn(args) ->
      val = args[field]
      cond do
        val == value_x -> {:ok, nil}
        true -> {:error, "'#{field}' should be equal #{value_x}"}
      end
    end
  end

  def required(field) do
    fn(args) ->
      case args[field] do
        nil -> {:error, "'#{field}' is required"}
        _ -> {:ok, nil}
      end
    end
  end

  def should_be(field, type) do
    fn (args) ->
      cond do
        type == :number && !is_number(args[field]) ->
          {:error, "'#{field}' should be number"}
        type == :float && !is_float(args[field]) ->
          {:error, "'#{field}' should be float"}
        type == :string && !is_bitstring(args[field]) ->
          {:error, "'#{field}' should be string"}
        type == :boolean && !is_boolean(args[field]) ->
          {:error, "'#{field}' should be boolean"}
        type == :list && !is_list(args[field]) ->
          {:error, "'#{field}' should be list"}
        true -> {:ok, nil}
      end
    end
  end







end
