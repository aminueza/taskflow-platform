# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Tasks', type: :request do
  let(:user) { create(:user) }

  describe 'GET /api/v1/tasks' do
    before do
      create_list(:task, 3, user: user)
      create_list(:task, 2)
    end

    it 'returns all tasks' do
      get '/api/v1/tasks'

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.size).to eq(5)
    end

    it 'returns tasks ordered by created_at desc' do
      get '/api/v1/tasks'

      tasks = response.parsed_body
      expect(tasks.first['created_at']).to be >= tasks.last['created_at']
    end

    it 'includes user association' do
      get '/api/v1/tasks'

      tasks = response.parsed_body
      task_with_user = tasks.find { |t| t['user_id'].present? }
      expect(task_with_user).to be_present
    end
  end

  describe 'GET /api/v1/tasks/:id' do
    let(:task) { create(:task, user: user) }

    it 'returns a specific task' do
      get "/api/v1/tasks/#{task.id}"

      expect(response).to have_http_status(:ok)
      json = response.parsed_body
      expect(json['id']).to eq(task.id)
      expect(json['title']).to eq(task.title)
    end

    it 'returns 404 for non-existent task' do
      get '/api/v1/tasks/999999'

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/tasks' do
    let(:valid_attributes) do
      {
        task: {
          title: 'New Task',
          description: 'Task description',
          status: 'pending',
          user_id: user.id
        }
      }
    end

    context 'with valid parameters' do
      it 'creates a new task' do
        expect do
          post '/api/v1/tasks', params: valid_attributes
        end.to change(Task, :count).by(1)
      end

      it 'returns the created task' do
        post '/api/v1/tasks', params: valid_attributes

        expect(response).to have_http_status(:created)
        json = response.parsed_body
        expect(json['title']).to eq('New Task')
        expect(json['description']).to eq('Task description')
        expect(json['status']).to eq('pending')
      end

      it 'creates a task without user_id' do
        valid_attributes[:task].delete(:user_id)
        post '/api/v1/tasks', params: valid_attributes

        expect(response).to have_http_status(:created)
        json = response.parsed_body
        expect(json['user_id']).to be_nil
      end

      it 'creates a task without description' do
        valid_attributes[:task].delete(:description)
        post '/api/v1/tasks', params: valid_attributes

        expect(response).to have_http_status(:created)
        json = response.parsed_body
        expect(json['description']).to be_nil
      end
    end

    context 'with invalid parameters' do
      it 'returns unprocessable_entity for missing title' do
        post '/api/v1/tasks', params: { task: { status: 'pending' } }

        expect(response).to have_http_status(:unprocessable_content)
        json = response.parsed_body
        expect(json['errors']).to be_present
      end

      it 'returns unprocessable_entity for invalid status' do
        invalid_attributes = valid_attributes.deep_dup
        invalid_attributes[:task][:status] = 'invalid'
        post '/api/v1/tasks', params: invalid_attributes

        expect(response).to have_http_status(:unprocessable_content)
        json = response.parsed_body
        expect(json['errors']).to include(match(/status/i))
      end

      it 'returns unprocessable_entity for empty title' do
        invalid_attributes = valid_attributes.deep_dup
        invalid_attributes[:task][:title] = ''
        post '/api/v1/tasks', params: invalid_attributes

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'PATCH /api/v1/tasks/:id' do
    let(:task) { create(:task, user: user, title: 'Original Title', status: 'pending') }

    context 'with valid parameters' do
      it 'updates the task' do
        patch "/api/v1/tasks/#{task.id}", params: {
          task: { title: 'Updated Title' }
        }

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['title']).to eq('Updated Title')
      end

      it 'updates the status' do
        patch "/api/v1/tasks/#{task.id}", params: {
          task: { status: 'completed' }
        }

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['status']).to eq('completed')
      end

      it 'updates multiple fields' do
        patch "/api/v1/tasks/#{task.id}", params: {
          task: {
            title: 'New Title',
            description: 'New Description',
            status: 'in_progress'
          }
        }

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['title']).to eq('New Title')
        expect(json['description']).to eq('New Description')
        expect(json['status']).to eq('in_progress')
      end
    end

    context 'with invalid parameters' do
      it 'returns unprocessable_entity for invalid status' do
        patch "/api/v1/tasks/#{task.id}", params: {
          task: { status: 'invalid' }
        }

        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'returns unprocessable_entity for empty title' do
        patch "/api/v1/tasks/#{task.id}", params: {
          task: { title: '' }
        }

        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'returns 404 for non-existent task' do
        patch '/api/v1/tasks/999999', params: {
          task: { title: 'New Title' }
        }

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE /api/v1/tasks/:id' do
    let!(:task) { create(:task, user: user) }

    it 'deletes the task' do
      expect do
        delete "/api/v1/tasks/#{task.id}"
      end.to change(Task, :count).by(-1)
    end

    it 'returns no_content status' do
      delete "/api/v1/tasks/#{task.id}"

      expect(response).to have_http_status(:no_content)
    end

    it 'returns 404 for non-existent task' do
      delete '/api/v1/tasks/999999'

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PATCH /api/v1/tasks/:id/toggle_status' do
    context 'when task is pending' do
      let(:task) { create(:task, status: 'pending') }

      it 'changes status to completed' do
        patch "/api/v1/tasks/#{task.id}/toggle_status"

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['status']).to eq('completed')
      end
    end

    context 'when task is completed' do
      let(:task) { create(:task, status: 'completed') }

      it 'changes status to pending' do
        patch "/api/v1/tasks/#{task.id}/toggle_status"

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['status']).to eq('pending')
      end
    end

    context 'when task is in_progress' do
      let(:task) { create(:task, status: 'in_progress') }

      it 'changes status to completed' do
        patch "/api/v1/tasks/#{task.id}/toggle_status"

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['status']).to eq('completed')
      end
    end

    it 'returns 404 for non-existent task' do
      patch '/api/v1/tasks/999999/toggle_status'

      expect(response).to have_http_status(:not_found)
    end
  end
end
