require 'spec_helper'
require './ariphmetic'

RSpec.describe Object, 'shunting-yard algorithm' do
  it 'should calculate values' do
    expect(calc('2.4*(-2)')).to eq(-4.8)
    expect(calc('0+1-1*2')).to eq(-1)
    expect(calc('10+10/2+5*2-15')).to eq(10)
    expect(calc('10*(-2+2*2)')).to eq(20)
  end

  it 'should return a raise error' do
    expect { calc('10%2') }.to raise_error(RuntimeError, 'Недопустимая операция')
  end

  it 'should pop and calculate 2 last operators' do
    operators = ['+', '/']
    operands = [3, 2, 2]
    pop_operators(operators, operands)
    expect(operands).to eq([3, 1])
    expect(operators).to eq(['+'])
  end

  it 'should return raise error when pass invalid operators' do
    operators = ['+', 'w']
    operands = [3, 2, 2]
    expect { pop_operators(operators, operands) }.to raise_error(NoMethodError)
  end

  it 'should return priority of operators' do
    expect(get_priority('+')).to eq(2)
    expect(get_priority('-')).to eq(2)
    expect(get_priority('*')).to eq(1)
    expect(get_priority('/')).to eq(1)
    expect(get_priority('(')).to eq(-1)
  end

  it 'should return true if a char is integer' do
    expect(integer?('1')).to be true
    expect(integer?('0')).to be true
    expect(integer?('s')).to be false
    expect(integer?('-')).to be false
  end

  it 'should return float from the string' do
    @pos = 0
    expect(read_float('3.14')).to eq(3.14)
  end

  it 'should return operators or operand from the string' do
    @pos = 0
    expect(get_token('3+4')).to eq(3)
    @pos = 0
    expect(get_token('(3-3)+4')).to eq('(')
    @pos = 0
    expect(get_token('-3-3)+4')).to eq('-')
  end

  it 'should return true if can pop an operator' do
    expect(can_pop?('+', ['*', '/'])).to be true
    expect(can_pop?('*', ['*', '+'])).to be false
    expect(can_pop?('+', ['*', '('])).to be false
  end
end
