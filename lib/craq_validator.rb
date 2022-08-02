# frozen_string_literal: true

class CraqValidator
  attr_reader :questions, :answers
  attr_accessor :errors

  def initialize(questions, answers)
    @questions = questions
    @answers = answers
    @errors = {}
    @valid = true
  end

  def validate
    return unless add_there_are_no_answers_error

    @valid
  end

  private

  def add_there_are_no_answers_error
    if @answers.empty?
      @valid = false
      @errors[:answers] = 'there are no answers'
    end

    @valid
  end
end
