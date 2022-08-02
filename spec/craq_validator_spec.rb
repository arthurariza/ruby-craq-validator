# frozen_string_literal: true

require_relative '../lib/craq_validator'

# rubocop:disable Metrics/BlockLength
describe CraqValidator do
  let(:questions) do
    [
      {
        text: 'question one?',
        options: [{ text: '1' }, { text: '2' }]
      },
      {
        text: 'question two?',
        options: [{ text: '1' }, { text: '2' }]
      }
    ]
  end

  let(:three_questions) do
    [
      {
        text: 'question one?',
        options: [{ text: '1' }, { text: '2' }]
      },
      {
        text: 'question two?',
        options: [{ text: '1' }, { text: '2' }]
      },
      {
        text: 'question three?',
        options: [{ text: '1' }, { text: '2' }]
      }
    ]
  end

  let(:terminal_questions) do
    [
      {
        text: 'question one?',
        options: [{ text: '1' }, { text: '2' }]
      },
      {
        text: 'question two?',
        options: [{ text: '1' }, { text: '2', complete_if_selected: true }]
      },
      {
        text: 'question three?',
        options: [{ text: '1' }, { text: '2' }]
      }
    ]
  end

  describe '#validate' do
    context 'returns valid' do
      let(:answers_correct) { { q0: 1, q1: 0 } }
      let(:terminal_answers_not_answered) { { q0: 0, q1: 0, q2: 1 } }
      let(:terminal_answers_is_answered) { { q0: 0, q1: 1 } }

      it 'when all questions are answered' do
        validator = CraqValidator.new(questions, answers_correct)

        expect(validator.validate).to be_truthy
        expect(validator.errors).to be_empty
      end

      it 'when terminal question is not answered' do
        validator = CraqValidator.new(terminal_questions, terminal_answers_not_answered)

        expect(validator.validate).to be_truthy
        expect(validator.errors).to be_empty
      end

      it 'when terminal question is answered' do
        validator = CraqValidator.new(terminal_questions, terminal_answers_is_answered)

        expect(validator.validate).to be_truthy
        expect(validator.errors).to be_empty
      end
    end

    context 'returns invalid' do
      let(:answers_invalid_list) { { q0: 3, q1: 0 } }
      let(:answers_not_answered) { { q1: 0, q2: 0 } }
      let(:terminal_answers_shouldnt_be_answered) { { q0: 0, q1: 1, q2: 1 } }

      it 'when answers is empty' do
        validator = CraqValidator.new(questions, {})

        expect(validator.validate).to be_falsey
        expect(validator.errors).not_to be_empty
        expect(validator.errors).to include(answers: 'there are no answers')
      end

      it 'when answer is not on the list of valid answers' do
        validator = CraqValidator.new(questions, answers_invalid_list)

        expect(validator.validate).to be_falsey
        expect(validator.errors).not_to be_empty
        expect(validator.errors).to include(q0: 'has an answer that is not on the list of valid answers')
      end

      it 'when a question is not answered' do
        validator = CraqValidator.new(three_questions, answers_not_answered)

        expect(validator.validate).to be_falsey
        expect(validator.errors).not_to be_empty
        expect(validator.errors).to include(q0: 'was not answered')
      end

      it 'when terminal question is answered' do
        validator = CraqValidator.new(terminal_questions, terminal_answers_shouldnt_be_answered)

        expect(validator.validate).to be_falsey
        expect(validator.errors).not_to be_empty
        expect(validator.errors).to include(q2: 'was answered even though a previous response indicated that the questions were complete')
      end
    end
  end
end
