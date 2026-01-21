# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'validations' do
    subject { build(:task) }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_length_of(:title).is_at_least(1).is_at_most(255) }
    it { is_expected.to validate_inclusion_of(:status).in_array(%w[pending in_progress completed]) }

    it 'is valid with valid attributes' do
      task = build(:task)
      expect(task).to be_valid
    end

    it 'is invalid without a title' do
      task = build(:task, title: nil)
      expect(task).not_to be_valid
      expect(task.errors[:title]).to include("can't be blank")
    end

    it 'is invalid with an empty title' do
      task = build(:task, title: '')
      expect(task).not_to be_valid
    end

    it 'is invalid with a title longer than 255 characters' do
      task = build(:task, title: 'a' * 256)
      expect(task).not_to be_valid
    end

    it 'is invalid with an invalid status' do
      task = build(:task, status: 'invalid_status')
      expect(task).not_to be_valid
      expect(task.errors[:status]).to include('is not included in the list')
    end

    it 'is valid with status pending' do
      task = build(:task, status: 'pending')
      expect(task).to be_valid
    end

    it 'is valid with status in_progress' do
      task = build(:task, status: 'in_progress')
      expect(task).to be_valid
    end

    it 'is valid with status completed' do
      task = build(:task, status: 'completed')
      expect(task).to be_valid
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user).optional }

    it 'can be created without a user' do
      task = build(:task, user: nil)
      expect(task).to be_valid
    end

    it 'can be associated with a user' do
      user = create(:user)
      task = create(:task, user: user)
      expect(task.user).to eq(user)
    end
  end

  describe 'scopes' do
    let!(:pending_task) { create(:task, status: 'pending') }
    let!(:in_progress_task) { create(:task, status: 'in_progress') }
    let!(:completed_task) { create(:task, status: 'completed') }

    describe '.pending' do
      it 'returns only pending tasks' do
        expect(Task.pending).to include(pending_task)
        expect(Task.pending).not_to include(in_progress_task)
        expect(Task.pending).not_to include(completed_task)
      end
    end

    describe '.in_progress' do
      it 'returns only in_progress tasks' do
        expect(Task.in_progress).to include(in_progress_task)
        expect(Task.in_progress).not_to include(pending_task)
        expect(Task.in_progress).not_to include(completed_task)
      end
    end

    describe '.completed' do
      it 'returns only completed tasks' do
        expect(Task.completed).to include(completed_task)
        expect(Task.completed).not_to include(pending_task)
        expect(Task.completed).not_to include(in_progress_task)
      end
    end
  end

  describe 'STATUSES constant' do
    it 'contains the correct statuses' do
      expect(Task::STATUSES).to eq(%w[pending in_progress completed])
    end
  end
end
