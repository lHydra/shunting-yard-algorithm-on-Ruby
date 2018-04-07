[Статья об этом алгоритме в моем в блоге](https://kingcode.ru/articles/implementation-shunting-yard-algorithm-on-ruby)

Здесь представлен вариант алгоритма Дейкстры "сортировочная станция", который позволит нам вычислять значения выражения полученного на вход строкой. Данный алгоритм основан на двух стеках - стеке операторов и стеке операндов. В оригинале используется один стек операторов, а операнды сразу попадают в "выходную строку", потому что нам не всегда может требоваться вычислять значение выражения сразу же (например, если в выражении есть переменные), также как указано на википедии, алгоритм может быть использован просто для преобразования из инфиксной нотации в постфиксную нотацию.

> **Инфиксная нотация** — это форма записи математических и логических формул, в которой операторы записаны в инфиксном стиле между операндами на которые они воздействуют (например 2 **+** 2).

> **Обратная польская нотация (постфиксная нотация)** — форма записи математических и логических выражений, в которой операнды расположены перед знаками операций. (например 3 4 **+**)

Суть алгоритма состоит в том, что любое выражение можно разбить на более простое. Таким образом решение сведется к разбору бинарных операций над операндами A и B.

По ходу нашего алгоритма мы будем идти слева на право по выражению и добавлять операнды в один стек, а операции в другой. И во время добавления новой операции, мы будем пытаться вытолкнуть предыдущие операции с меньшим приоритетом из стека.

Рассмотрим алгоритм на  простом примере:

1. Входная строка 10+6-2*3

   В выражении идут подряд + и - с  одинаковыми приоритетами. Скобок нет, поэтому '-' вытолкнет +.

2. Оборачиваем всё выражение в скобки, чтобы упростить разбор конечного выражения: (10+6-2*3)

3. Пушим '(' в стек операторов. Operators.push('(')

4. Пушим 10 в стек операндов. Operands.push(10)

5. Operators.push('+')

6. Operands.push(6)

7. Operators.push('-'). Как уже писало у минуса и плюса приоритет одинаковый, поэтому выталкиваем +

8. Operators = { '(', '-' }; Operands = { 16 }

9. Operands.push(2)

10. Operators.push('*'). Умножить имеет более низкий приоритет, поэтому ничего не делаем

11. Operands.push(3)

12. Operators.push(')'). На вход поступила закрывающая скобка - следовательно выталкиваем все операции до первой открывающей (в нашем случае это обертка выражения)

13. Operators = { }; Operands = { 10 }. Если в стеке операндов содержится больше одного числа, значит на вход было подано некорректное выражение

Давайте теперь разберем более сложный пример по шагам:

1. Входная строка: 3+(6-10/2)

   Здесь у нас есть последовательно идущие знаки + и - у которых приоритет одинаковый, но из-за того, что выражение (6-10/2) взято в скобки, то выталкивания не будет происходить сразу.

2. Оборачиваем всё выражение в скобки: (3+(6-10/2))

3. Пушим '(' в стек операторов. Operators.push('(')

   Открывающая скобка имеет приоритет -1 и не может никого вытолкнуть, а ее вытолкнуть может только закрывающая скобка.

   Operators = { '(' }

   Operands = { }

4. Пушим 3 в стек операндов. Operands.push(3)

   Operators = { '(' }

   Operands = { 3 }

5. Operators.push('+')

   Operators = { '(', '+' }

   Operands = { 3 }

6. Operators.push('(')

   Operators = { '(', '+', '(' }

   Operands = { 3 }

7. Operands.push(6)

   Operators = { '(', '+', '(' }

   Operands = { 3, 6 }

8. Operators.push('-')

   Operators = { '(', '+', '(', '-' }

   Operands = { 3, 6 }

9. Operands.push(10)

   Operators = { '(', '+', '(', '-' }

   Operands = { 3, 6, 10 }

10. Operators.push('/')

    Operators = { '(', '+', '(', '-', '/'}

    Operands = { 3, 6, 10 }

11. Operands.push(2)

    Operators = { '(', '+', '(', '-', '/'}

    Operands = { 3, 6, 10, 2 }

12. Operators.push(')') - на вход поступает закрывающаяся скобка ')' и выталкивает все операции до первой открывающей.

    Operators = { '(', '+' }

    Operands = { 3, 1 }

13. Operators.push(')') - снова на входе закрывающая скобка, которая выталкивает последнюю операцию

14. Operators = { }; Operands = { 4 }

Чтобы избежать проблем с унарными операциями, мы будем превращать их в бинарные путем добавления нейтрального элемента. В нашем случае 0, так как -2 это то же самое, что и 0-2.

*Код программы написанный на Ruby*:

```ruby
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
```

В методе ```pop_operators``` используется немного метапрограммирования, благодаря которому нам нет смысла перебирать все операции с помощью ```case```, а достаточно вызвать на одном операнде метод ```send``` и передать второй операнд в качестве аргумента. Это позволяет достаточно просто расширять поддерживаемые операторы - достаточно просто расписать их приоритет.

*Полезные ссылки:*

1. [Отсюда я взял этот алгоритм, в статье реализация на C#](https://habrahabr.ru/post/50196/)
2. [Shunting-yard algorithm](https://en.wikipedia.org/wiki/Shunting-yard_algorithm)