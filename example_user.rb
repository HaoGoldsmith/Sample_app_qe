# frozen_string_literal: true

class User
  attr_accessor :name, :email, :surname
  def initialize(attributes = {})
    @name = attributes[:name]
    @email = attributes[:email]
    @surname= attributes[:surname]
  end

  def full_name
    "#{@name} #{@surname}"
  end

  def formatted_email
    "#{@name} #{@surname}<#{@email}>"
  end
end