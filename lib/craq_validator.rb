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

  # rubocop:disable Metrics/MethodLength
  def validate
    return unless add_there_are_no_answers_error

    @questions.each_with_index do |question, index|
      answer = @answers[:"q#{index}"]

      unless answer
        add_was_not_answered_error(index)
        next
      end

      answer_index = @answers.values[index] || @answers.length

      unless question[:options][answer_index]
        add_not_in_valid_answer_error(index)
        next
      end
    end

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

  def add_not_in_valid_answer_error(index)
    @valid = false
    @errors[:"q#{index}"] = 'has an answer that is not on the list of valid answers'
  end

  def add_was_not_answered_error(index)
    @valid = false
    @errors[:"q#{index}"] = 'was not answered'
  end
end
