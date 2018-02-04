defmodule CalcTest do
  use ExUnit.Case
  doctest Calc

  test "Test Case 1"do
  	assert Calc.eval("2+3*2") == 8
  end

  test "Test Case 2"do
  	assert Calc.eval("(2+3)*(8-0)") == 40
  end

  test "Test Case 3"do
  	assert Calc.eval("((5+9*6)+3)/7") == 8
  end

  test "Test Case 4"do
  	assert Calc.eval("24 / 6 + (5 - 4)") == 5
  end

  test "Test Case 5"do
  	assert Calc.eval("1 + 3 * 3 + 1") == 11
  end

  test "Test Case 6"do
  	assert Calc.eval("2/2") == 1
  end

  test "Test Case 7"do
  	assert Calc.eval("6-7-6-0") == -7
  end

  
  end

