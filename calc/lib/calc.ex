defmodule Calc do

 # main function to repeatedly print a prompt, read one line, eval it, and print the result.
  def main() do
    input =  IO.gets("> ")                # asks for user input
    eval(input)  
    |>IO.puts()                         # evaluates expression
    main()                                # repeatedly print a promt
  end

  def eval(expr) do
    operandsStack = []                    #List to store operands
    operatorStack = []                    #List to store operators
    
    tokenize(expr)                        # tokenizes the string,stores each token in a list, returns the list.
    |> evaluateExpression(operandsStack,operatorStack)  # evaluates the expression
    |> List.first()                       # retrieves first element from the final evaluated list
    |> String.to_integer()                    
 end

  #function which accepts a string expression, tokenizes the expression and returns a list of tokens
  def tokenize(expr) do
   expr = String.replace(expr,~r/\s+/,"")                 # removes all blank spaces  
   exprList = String.graphemes(expr)                      # adds every character to the list
   exprList = Calc.tokenizeToList(exprList, "", [])   # tokenising
   exprList
  end


 @precedence_rule %{"*" => 3, "/" => 3, "x" => 3, "+" => 2, "-" => 2, "(" => 1}



 #function which completely reformats and tokenizes. Returns the tokenized list.
 def tokenizeToList(exprList, temp, final) do
  if exprList == [] do
    case temp do
      "" -> final
      _ -> final ++ [temp]
    end
  else
    [first | rest] = exprList
    op? = Map.has_key?(@precedence_rule, first) 
    cond do
      (op? || first == ")" || first == "(" || first == " ") && temp == "" ->
        tokenizeToList(rest, "", final ++ [first])

        op? || first == ")" || first == "(" || first == " " ->
          tokenizeToList(rest, "", final ++ [temp, first])

          true ->
            tokenizeToList(rest, temp <> first, final)
          end
        end
      end


#function to pop the element from the stack
def pop(stack) do
  if (List.last(stack) != nil)
  do
    [top | rest] = stack
    
    {top, rest}
  else

    {List.last(stack), stack}
 
  end
end

#function to push the element to stack
def push(stack, item) do
  [item | stack]
end

def performOperation(num1, num2, op) do
  cond do
    op == "+" -> num1 + num2
    op == "-" -> num1 - num2
    op == "*" -> num1 * num2
    op == "/" -> div(num1,num2)
    true -> nil 
  end
  
end

# termination condition for calculateFinalValue() function
# this function is called when operatorStack is empty
# Returns final computed value
def calculateFinalValue({operandsStack,[]})
do
  operandsStack
end

# This function applies operators to the remaining operands in the stack
def calculateFinalValue({operandsStack,operatorStack})
do
 {num1,operandsStack} = Calc.pop(operandsStack)
 {num2,operandsStack} = Calc.pop(operandsStack)
 {op,operatorStack} = Calc.pop(operatorStack)
 
 value = Calc.performOperation(String.to_integer(num2),String.to_integer(num1),op)
 operandsStack = Calc.push(operandsStack, Integer.to_string(value))
 calculateFinalValue({operandsStack,operatorStack})
end


# termination condition for calculateValueFromStackForBracket() function
# this function is called when "(" is encountered
# Returns operandsStack,operatorStack
def calculateValueFromStackForBracket(operandsStack,operatorStack,true)
do
  {operandsStack,operatorStack}
  
end

# function to apply operator to the operands within the paranthesis
# pops two operands from the operand stack. Pops operator from the operator stack.
# Apply the operator to the operands.
# Repeat until "(" is encountered.
def calculateValueFromStackForBracket(operandsStack,operatorStack,false)
do
 {num1,operandsStack} = Calc.pop(operandsStack)
 {num2,operandsStack} = Calc.pop(operandsStack)
 {op,operatorStack} = Calc.pop(operatorStack)
 value = Calc.performOperation(String.to_integer(num2),String.to_integer(num1),op)
 operandsStack = Calc.push(operandsStack, Integer.to_string(value))


 if(List.first(operatorStack) == "(")
 do
   {op,operatorStack} = Calc.pop(operatorStack)
   calculateValueFromStackForBracket(operandsStack,operatorStack,true)       #set boolean value to true on encountering "("

 else
  calculateValueFromStackForBracket(operandsStack,operatorStack,false)
end
end

#function to evaluate basic expression (eg: 1 + 2)
# pops two operands from the operand stack. Pops operator from the operator stack.
# Apply the operator to the operands.
# Returns operandsStack,operatorStack
def  calculateValueFromStack(operandsStack,operatorStack,term) do
  {num1,operandsStack} = Calc.pop(operandsStack)
  {num2,operandsStack} = Calc.pop(operandsStack)
  {op,operatorStack} = Calc.pop(operatorStack)
  
  value = Calc.performOperation(String.to_integer(num2),String.to_integer(num1),op)
  operandsStack = Calc.push(operandsStack, Integer.to_string(value))
  operatorStack =  Calc.push(operatorStack,term)
  {operandsStack,operatorStack}
end


# function to check precedence of the operator
# returns true if top of the operatorStack has higher or equal precendence to the current operator,else false
def checkPrecedence(term, operatorStack) do
  checkNil = List.last(operatorStack)
  {topOperatorInStack,operatorStack} = Calc.pop(operatorStack)

  cond do
   (checkNil == nil) ->

     false
     (topOperatorInStack == "(" || topOperatorInStack == ")" )->  false
     (term == "*" and (topOperatorInStack == "+" or topOperatorInStack == "-")) ->  false
     (term == "/" and (topOperatorInStack == "+" or topOperatorInStack == "-")) ->  false
     true -> true

   end

end    #end checkPrecedence


#this function is called when there is no token left to parse in the exprList
def evaluateExpression([],operandsStack,operatorStack)do
   calculateFinalValue({operandsStack,operatorStack})     #apply operator to the remaining operands

end

# evaluates exprList.
def evaluateExpression(exprList,operandsStack,operatorStack) do
  term = List.first(exprList)
  cond do
    
    #if "(" push it to operator stack
    term == "("  ->  
     operatorStack =  Calc.push(operatorStack, term)
     exprList = List.delete(exprList, term)
     evaluateExpression(exprList,operandsStack,operatorStack)
     
    #if ")" solve entirfe paranthesis
    term == ")" ->    
       {operandsStack,operatorStack} = Calc.calculateValueFromStackForBracket(operandsStack,operatorStack,false)
       exprList = List.delete(exprList, term)
       evaluateExpression(exprList,operandsStack,operatorStack)
    
    #if current term is an operator
    term == "*" || term == "/" || term == "+" || term == "-" ->


        if (Calc.checkPrecedence(term, operatorStack) == true)
        do
          # pop the top operator and two operand from the operands list. Apply the operator to the operands
          {operandsStack,operatorStack} = calculateValueFromStack(operandsStack,operatorStack,term)
          exprList = List.delete(exprList, term)
          evaluateExpression(exprList,operandsStack,operatorStack)
        else
         #push the current operator to the stack
         operatorStack = Calc.push(operatorStack, term)
         exprList = List.delete(exprList, term)
         evaluateExpression(exprList,operandsStack,operatorStack)
        end

    #if number push it to operand stack
    is_number(String.to_integer(term)) -> 
         operandsStack = Calc.push(operandsStack, term)
         exprList = List.delete(exprList, term)
         evaluateExpression(exprList,operandsStack,operatorStack)
         true -> nil 
       end
     end
   end
