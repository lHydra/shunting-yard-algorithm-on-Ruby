def get_token(string)
  if @pos == string.size
    nil
  elsif integer?(string[@pos])
    read_float(string)
  else
    string[@pos]
  end
end

def read_float(string)
  num = ''
  while @pos < string.size && (integer?(string[@pos]) || string[@pos] == '.')
    num += string[@pos]
    @pos += 1
  end
  num.to_f
end

def integer?(char)
  char =~ /\D/ ? false : true
end

def get_priority(op)
  case op
  when '('
    -1
  when '*', '/'
    1
  when '+', '-'
    2
  else
    raise 'Недопустимая операция'
  end
end

def can_pop?(op, operators)
  return false if operators.count.zero?

  p1 = get_priority(op)
  p2 = get_priority(operators.last)

  p1 >= 0 && p2 >= 0 && p1 >= p2
end

def pop_operators(operators, operands)
  b = operands.pop
  a = operands.pop
  op = operators.pop

  begin
    operands.push(a.send(op, b))
  rescue NoMethodError
    raise
  end
end

def calc(string)
  string = '(' + string + ')'
  operands = []
  operators = []
  prev_token = 'Ы'
  @pos = 0

  loop do
    token = get_token(string)
    if prev_token == '(' && token == '-'
      operands.push(0)
    elsif token.is_a? Float
      operands.push(token)
    elsif token.is_a? String
      if token == ')'
        while operators.count > 0 && operators.last != '('
          pop_operators(operators, operands)
        end
        operators.pop
      else
        pop_operators(operators, operands) while can_pop?(token, operators)
        operators.push(token)
      end
      @pos += 1
    end
    prev_token = token
    break if token.nil?
  end
  operands[0]
end
