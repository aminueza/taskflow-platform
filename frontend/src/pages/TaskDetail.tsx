import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Link, useParams, useNavigate } from 'react-router-dom'
import { getTask, deleteTask } from '../api/tasks'
import Loading from '../components/Loading'
import ErrorMessage from '../components/ErrorMessage'
import StatusBadge from '../components/StatusBadge'
import { format } from 'date-fns'

export default function TaskDetail() {
  const { id } = useParams()
  const navigate = useNavigate()
  const queryClient = useQueryClient()

  const { data: task, isLoading, error } = useQuery({
    queryKey: ['task', id],
    queryFn: () => getTask(Number(id)),
  })

  const deleteMutation = useMutation({
    mutationFn: deleteTask,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['tasks'] })
      navigate('/tasks')
    },
  })

  if (isLoading) return <Loading />
  if (error) return <ErrorMessage message="Failed to load task" />
  if (!task) return <ErrorMessage message="Task not found" />

  const handleDelete = () => {
    if (confirm('Are you sure you want to delete this task?')) {
      deleteMutation.mutate(task.id)
    }
  }

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      {/* Breadcrumb */}
      <nav className="flex items-center gap-2 text-sm text-slate-400">
        <Link to="/tasks" className="hover:text-white">Tasks</Link>
        <span>/</span>
        <span className="text-white">{task.title}</span>
      </nav>

      {/* Header */}
      <div className="card">
        <div className="flex items-start justify-between gap-4">
          <div>
            <div className="flex items-center gap-3 mb-2">
              <StatusBadge status={task.status} />
            </div>
            <h1 className="text-2xl font-bold text-white">{task.title}</h1>
          </div>
          <div className="flex gap-2">
            <Link
              to={`/tasks/${task.id}/edit`}
              className="btn btn-secondary"
            >
              Edit
            </Link>
            <button
              onClick={handleDelete}
              className="btn btn-danger"
            >
              Delete
            </button>
          </div>
        </div>

        {task.description && (
          <div className="mt-6">
            <h3 className="text-sm font-medium text-slate-400 mb-2">Description</h3>
            <p className="text-slate-200 whitespace-pre-wrap">{task.description}</p>
          </div>
        )}

        <div className="grid grid-cols-2 gap-6 mt-6 pt-6 border-t border-slate-700">
          <div>
            <h3 className="text-sm font-medium text-slate-400 mb-2">Assigned To</h3>
            {task.user ? (
              <Link
                to={`/users/${task.user.id}`}
                className="flex items-center gap-3 hover:text-emerald-400"
              >
                <div className="w-8 h-8 rounded-full bg-gradient-to-br from-emerald-500 to-blue-500 flex items-center justify-center text-white text-sm font-medium">
                  {task.user.username.charAt(0).toUpperCase()}
                </div>
                <span className="text-white">{task.user.username}</span>
              </Link>
            ) : (
              <span className="text-slate-400">Unassigned</span>
            )}
          </div>

          <div>
            <h3 className="text-sm font-medium text-slate-400 mb-2">User ID</h3>
            <span className="text-white">
              {task.user_id ? `#${task.user_id}` : 'Unassigned'}
            </span>
          </div>

          <div>
            <h3 className="text-sm font-medium text-slate-400 mb-2">Created</h3>
            <span className="text-white">
              {format(new Date(task.created_at), 'MMM d, yyyy h:mm a')}
            </span>
          </div>

          <div>
            <h3 className="text-sm font-medium text-slate-400 mb-2">Last Updated</h3>
            <span className="text-white">
              {format(new Date(task.updated_at), 'MMM d, yyyy h:mm a')}
            </span>
          </div>
        </div>
      </div>

      {/* Back Link */}
      <Link to="/tasks" className="text-slate-400 hover:text-white text-sm inline-flex items-center gap-2">
        ← Back to Tasks
      </Link>
    </div>
  )
}

