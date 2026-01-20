module Api
  module V1
    class TasksController < Api::BaseController
      def index
        tasks = Task.includes(:user).all.order(created_at: :desc)
        render json: tasks
      end

      def show
        task = Task.find(params[:id])
        render json: task
      end

      def create
        task = Task.new(task_params)
        if task.save
          render json: task, status: :created
        else
          render json: { errors: task.errors.full_messages }, status: :unprocessable_content
        end
      end

      def update
        task = Task.find(params[:id])
        if task.update(task_params)
          render json: task
        else
          render json: { errors: task.errors.full_messages }, status: :unprocessable_content
        end
      end

      def destroy
        task = Task.find(params[:id])
        task.destroy
        head :no_content
      end

      def toggle_status
        task = Task.find(params[:id])
        task.status = task.status == 'completed' ? 'pending' : 'completed'
        if task.save
          render json: task
        else
          render json: { errors: task.errors.full_messages }, status: :unprocessable_content
        end
      end

      private

      def task_params
        params.require(:task).permit(:title, :description, :status, :user_id)
      end
    end
  end
end
