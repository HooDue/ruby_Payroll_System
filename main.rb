=begin
Last name: Hong
Language: Ruby
Paradigm(s): OOP, Functional, Procedural
=end


require_relative "weekly_payroll_system"
DEFAULT_WORKDAYS = 5

system1 = PayrollSystem.new(DEFAULT_WORKDAYS)
system1.start_program()
