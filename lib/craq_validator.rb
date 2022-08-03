# frozen_string_literal: true

class CraqValidator
  COMPLETE_SYMBOL = :complete_if_selected

  attr_reader :questions, :answers
  attr_accessor :errors, :terminal_question_answered

  def initialize(questions, answers)
    @questions = questions
    @answers = answers
    @errors = {}
    @valid = true
    @terminal_question_answered = false
  end

  def validate
    return unless add_there_are_no_answers_error

    validate_each_question

    @valid
  end

  private

  # rubocop:disable Metrics/MethodLength
  def validate_each_question
    @questions.each_with_index do |question, index|
      answer = @answers[:"q#{index}"]

      if @terminal_question_answered
        add_terminal_question_aswered(index) if answer
        next
      end

      unless answer
        add_was_not_answered_error(index)
        next
      end

      answer_index = @answers.values[index]

      unless answer_index && question[:options][answer_index]
        add_not_in_valid_answer_error(index)
        next
      end

      check_terminal_question_answered(question, answer)
    end
  end

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

  def check_terminal_question_answered(question, answer)
    @terminal_question_answered = question[:options][answer].key?(COMPLETE_SYMBOL)
  end

  def add_terminal_question_aswered(index)
    @valid = false
    @errors[:"q#{index}"] = 'was answered even though a previous response indicated that the questions were complete'
  end
end
