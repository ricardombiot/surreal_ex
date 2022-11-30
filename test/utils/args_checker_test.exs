defmodule SurrealExTest.ArgsChecker do
  use ExUnit.Case

  alias SurrealEx.ArgsChecker

  test "Helper for checks fields before query" do
    args = %{ max_price: -100 }

    result = ArgsChecker.apply(args, [])
    assert result == {:ok, args}

    result = ArgsChecker.apply(args, [
      ArgsChecker.required(:min_price),
      ArgsChecker.should_be(:min_price, :float),
      ArgsChecker.should_be(:max_price, :float)
    ])

    assert result == {:error, ["'min_price' is required", "'min_price' should be float", "'max_price' should be float"]}

    result = ArgsChecker.apply(args, [
      ArgsChecker.greater_than(:max_price, 0.0)
    ])
    assert result == {:error, ["'max_price' should be greater than 0.0"]}
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

  describe "Test:Helpers::Comparison" do
    test "greater_than" do
      args = %{ example_field: "a" }
      assert ArgsChecker.greater_than(:example_field, 0).(args) == {:error, "'example_field' should be greater than 0"}
      args = %{ example_field: 0 }
      assert ArgsChecker.greater_than(:example_field, 0).(args) == {:error, "'example_field' should be greater than 0"}
      args = %{ example_field: 1 }
      assert ArgsChecker.greater_than(:example_field, 0).(args) == {:ok, nil}
      args = %{ example_field: -1 }
      assert ArgsChecker.greater_than(:example_field, 0).(args) == {:error, "'example_field' should be greater than 0"}
    end

    test "greater_or_equal_than" do
      args = %{ example_field: "a" }
      assert ArgsChecker.greater_or_equal_than(:example_field, 0).(args) == {:error, "'example_field' should be greater or equal than 0"}
      args = %{ example_field: 0 }
      assert ArgsChecker.greater_or_equal_than(:example_field, 0).(args) == {:ok, nil}
      args = %{ example_field: 1 }
      assert ArgsChecker.greater_or_equal_than(:example_field, 0).(args) == {:ok, nil}
      args = %{ example_field: -1 }
      assert ArgsChecker.greater_or_equal_than(:example_field, 0).(args) == {:error, "'example_field' should be greater or equal than 0"}
    end

    test "less_than" do
      args = %{ example_field: "a" }
      assert ArgsChecker.less_than(:example_field, 0).(args) == {:error, "'example_field' should be less than 0"}
      args = %{ example_field: 0 }
      assert ArgsChecker.less_than(:example_field, 0).(args) == {:error, "'example_field' should be less than 0"}
      args = %{ example_field: 1 }
      assert ArgsChecker.less_than(:example_field, 0).(args) == {:error, "'example_field' should be less than 0"}
      args = %{ example_field: -1 }
      assert ArgsChecker.less_than(:example_field, 0).(args) == {:ok, nil}
    end

    test "less_or_equal_than" do
      args = %{ example_field: "a" }
      assert ArgsChecker.less_or_equal_than(:example_field, 0).(args) == {:error, "'example_field' should be less or equal than 0"}
      args = %{ example_field: 0 }
      assert ArgsChecker.less_or_equal_than(:example_field, 0).(args) == {:ok, nil}
      args = %{ example_field: 1 }
      assert ArgsChecker.less_or_equal_than(:example_field, 0).(args) == {:error, "'example_field' should be less or equal than 0"}
      args = %{ example_field: -1 }
      assert ArgsChecker.less_or_equal_than(:example_field, 0).(args) == {:ok, nil}
    end

    test "eq" do
      args = %{ example_field: "a" }
      assert ArgsChecker.eq(:example_field, 0).(args) == {:error, "'example_field' should be equal 0"}
      args = %{ example_field: 0 }
      assert ArgsChecker.eq(:example_field, 0).(args) == {:ok, nil}
      args = %{ example_field: 1 }
      assert ArgsChecker.eq(:example_field, 0).(args) == {:error, "'example_field' should be equal 0"}
      args = %{ example_field: -1 }
      assert ArgsChecker.eq(:example_field, 0).(args) == {:error, "'example_field' should be equal 0"}
    end
  end


  describe "Test:Helpers::required" do
    test "required field" do
      args = %{ example_field: "a" }
      assert ArgsChecker.required(:example_field).(args) == {:ok, nil}
      args = %{ example_field: "a" }
      assert ArgsChecker.required(:example_require_field).(args) == {:error, "'example_require_field' is required"}
    end
  end

  describe "Test:Helpers::Should_be" do
    test "should_be field, :number" do
      args = %{ example_field: "a" }
      assert ArgsChecker.should_be(:example_field, :number).(args) == {:error, "'example_field' should be number"}
      args = %{ example_field: 0 }
      assert ArgsChecker.should_be(:example_field, :number).(args) == {:ok, nil}
      args = %{ example_field: 0.0 }
      assert ArgsChecker.should_be(:example_field, :number).(args) == {:ok, nil}
      args = %{ example_field: [1,2] }
      assert ArgsChecker.should_be(:example_field, :number).(args) == {:error, "'example_field' should be number"}
      args = %{ example_field: true }
      assert ArgsChecker.should_be(:example_field, :number).(args) == {:error, "'example_field' should be number"}
    end

    test "should_be field, :float" do
      args = %{ example_field: "a" }
      assert ArgsChecker.should_be(:example_field, :float).(args) == {:error, "'example_field' should be float"}
      args = %{ example_field: 0 }
      assert ArgsChecker.should_be(:example_field, :float).(args) == {:error, "'example_field' should be float"}
      args = %{ example_field: 0.0 }
      assert ArgsChecker.should_be(:example_field, :float).(args) == {:ok, nil}
      args = %{ example_field: [1,2] }
      assert ArgsChecker.should_be(:example_field, :float).(args) == {:error, "'example_field' should be float"}
      args = %{ example_field: true }
      assert ArgsChecker.should_be(:example_field, :float).(args) == {:error, "'example_field' should be float"}
    end

    test "should_be field, :string" do
      args = %{ example_field: "a" }
      assert ArgsChecker.should_be(:example_field, :string).(args) == {:ok, nil}
      args = %{ example_field: 0 }
      assert ArgsChecker.should_be(:example_field, :string).(args) == {:error, "'example_field' should be string"}
      args = %{ example_field: 0.0 }
      assert ArgsChecker.should_be(:example_field, :string).(args) == {:error, "'example_field' should be string"}
      args = %{ example_field: [1,2] }
      assert ArgsChecker.should_be(:example_field, :string).(args) == {:error, "'example_field' should be string"}
      args = %{ example_field: true }
      assert ArgsChecker.should_be(:example_field, :string).(args) == {:error, "'example_field' should be string"}
    end

    test "should_be field, :list" do
      args = %{ example_field: "a" }
      assert ArgsChecker.should_be(:example_field, :list).(args) == {:error, "'example_field' should be list"}
      args = %{ example_field: 0 }
      assert ArgsChecker.should_be(:example_field, :list).(args) == {:error, "'example_field' should be list"}
      args = %{ example_field: 0.0 }
      assert ArgsChecker.should_be(:example_field, :list).(args) == {:error, "'example_field' should be list"}
      args = %{ example_field: [1,2] }
      assert ArgsChecker.should_be(:example_field, :list).(args) == {:ok, nil}
      args = %{ example_field: true }
      assert ArgsChecker.should_be(:example_field, :list).(args) == {:error, "'example_field' should be list"}
    end

    test "should_be field, :boolean" do
      args = %{ example_field: "a" }
      assert ArgsChecker.should_be(:example_field, :boolean).(args) == {:error, "'example_field' should be boolean"}
      args = %{ example_field: 0 }
      assert ArgsChecker.should_be(:example_field, :boolean).(args) == {:error, "'example_field' should be boolean"}
      args = %{ example_field: 0.0 }
      assert ArgsChecker.should_be(:example_field, :boolean).(args) == {:error, "'example_field' should be boolean"}
      args = %{ example_field: [1,2] }
      assert ArgsChecker.should_be(:example_field, :boolean).(args) == {:error, "'example_field' should be boolean"}
      args = %{ example_field: true }
      assert ArgsChecker.should_be(:example_field, :boolean).(args) == {:ok, nil}
    end
  end



end
