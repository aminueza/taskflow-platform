import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Link } from 'react-router-dom'
import { getTasks, deleteTask, updateTask } from '../api/tasks'
import Loading from '../components/Loading'
import ErrorMessage from '../components/ErrorMessage'
import StatusBadge from '../components/StatusBadge'
import { clsx } from 'clsx'
import { format } from 'date-fns'
import type { Task } from '../types'

type FilterStatus = 'all' | 'pending' | 'in_progress' | 'completed'

export default function TaskList() {
  const [filter, setFilter] = useState<FilterStatus>('all')
  const queryClient = useQueryClient()

  const { data: tasks, isLoading, error } = useQuery({
    queryKey: ['tasks'],
    queryFn: getTasks,
  })

  const deleteMutation = useMutation({
    mutationFn: deleteTask,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['tasks'] })
    },
  })

  const updateMutation = useMutation({
    mutationFn: ({ id, status }: { id: number; status: string }) =>
      updateTask(id, { status }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['tasks'] })
    },
  })

  if (isLoading) return <Loading />
  if (error) return <ErrorMessage message="Failed to load tasks" />

  const filteredTasks = tasks?.filter((task) =>
    filter === 'all' ? true : task.status === filter
  ) || []

  const handleStatusChange = (task: Task, newStatus: string) => {
    updateMutation.mutate({ id: task.id, status: newStatus })
  }

  const handleDelete = (id: number) => {
    if (confirm('Are you sure you want to delete this task?')) {
      deleteMutation.mutate(id)
    }
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-white">Tasks</h1>
          <p className="text-slate-400 mt-1">{filteredTasks.length} tasks</p>
        </div>
        <Link to="/tasks/new" className="btn btn-primary">
          + New Task
        </Link>
      </div>

      {/* Filters */}
      <div className="flex gap-2">
        {(['all', 'pending', 'in_progress', 'completed'] as const).map((status) => (
          <button
            key={status}
            onClick={() => setFilter(status)}
            className={clsx(
              'px-4 py-2 rounded-lg text-sm font-medium transition-colors',
              filter === status
                ? 'bg-emerald-600 text-white'
                : 'bg-slate-700 text-slate-300 hover:bg-slate-600'
            )}
          >
            {status === 'all' ? 'All' : status === 'in_progress' ? 'In Progress' : status.charAt(0).toUpperCase() + status.slice(1)}
          </button>
        ))}
      </div>

      {/* Task List */}
      <div className="space-y-3">
        {filteredTasks.map((task) => (
            <div
              key={task.id}
              className="card flex items-start gap-4"
            >
              {/* Status Quick Toggle */}
              <select
                value={task.status}
                onChange={(e) => handleStatusChange(task, e.target.value)}
                className="bg-slate-700 border border-slate-600 rounded-lg px-2 py-1 text-sm text-slate-300 cursor-pointer"
              >
                <option value="pending">Pending</option>
                <option value="in_progress">In Progress</option>
                <option value="completed">Completed</option>
              </select>

              {/* Task Info */}
              <div className="flex-1 min-w-0">
                <Link
                  to={`/tasks/${task.id}`}
                  className="text-white font-medium hover:text-emerald-400 transition-colors"
                >
                  {task.title}
                </Link>
                {task.description && (
                  <p className="text-slate-400 text-sm mt-1 line-clamp-2">
                    {task.description}
                  </p>
                )}
                <div className="flex items-center gap-4 mt-2">
                  <span className="text-slate-400 text-sm">
                    {task.user?.username || task.user_id ? `User #${task.user_id}` : 'Unassigned'}
                  </span>
                  <span className="text-slate-400 text-sm">
                    Created: {format(new Date(task.created_at), 'MMM d, yyyy')}
                  </span>
                </div>
              </div>

              {/* Actions */}
              <div className="flex items-center gap-2">
                <Link
                  to={`/tasks/${task.id}/edit`}
                  className="px-3 py-1 text-sm bg-slate-700 hover:bg-slate-600 text-slate-300 rounded-lg transition-colors"
                >
                  Edit
                </Link>
                <button
                  onClick={() => handleDelete(task.id)}
                  className="px-3 py-1 text-sm bg-red-500/20 hover:bg-red-500/30 text-red-400 rounded-lg transition-colors"
                >
                  Delete
                </button>
              </div>
            </div>
          ))}

        {filteredTasks.length === 0 && (
          <div className="card text-center py-12">
            <p className="text-slate-400">No tasks found</p>
            <Link to="/tasks/new" className="text-emerald-400 text-sm hover:text-emerald-300 mt-2 inline-block">
              Create your first task →
            </Link>
          </div>
        )}
      </div>
    </div>
  )
}

