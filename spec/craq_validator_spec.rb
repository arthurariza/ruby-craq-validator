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

  let(:answers_correct) { { q0: 1, q1: 0 } }
  let(:answers_invalid_list) { { q0: 3, q1: 0 } }

  describe '#validate' do
    context 'returns valid' do
      it 'when all questions are answered' do
        validator = CraqValidator.new(questions, answers_correct)

        expect(validator.validate).to be_truthy
        expect(validator.errors).to be_empty
      end
    end

    context 'returns invalid' do
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
        validator = CraqValidator.new(questions, { q0: 0 })

        expect(validator.validate).to be_falsey
        expect(validator.errors).not_to be_empty
        expect(validator.errors).to include(q1: 'was not answered')
      end
    end
  end
end
