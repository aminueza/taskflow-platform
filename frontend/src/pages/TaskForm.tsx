import { useState, useEffect } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Link, useParams, useNavigate } from 'react-router-dom'
import { getTask, createTask, updateTask, type TaskInput } from '../api/tasks'
import { getUsers } from '../api/users'
import Loading from '../components/Loading'
import ErrorMessage from '../components/ErrorMessage'

export default function TaskForm() {
  const { id } = useParams()
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const isEditing = Boolean(id)

  const [form, setForm] = useState<TaskInput>({
    title: '',
    description: '',
    status: 'pending',
    user_id: null,
  })
  const [error, setError] = useState<string | null>(null)

  const { data: task, isLoading: taskLoading } = useQuery({
    queryKey: ['task', id],
    queryFn: () => getTask(Number(id)),
    enabled: isEditing,
  })

  const { data: users } = useQuery({
    queryKey: ['users'],
    queryFn: getUsers,
  })

  useEffect(() => {
    if (task) {
      setForm({
        title: task.title,
        description: task.description || '',
        status: task.status,
        user_id: task.user_id,
      })
    }
  }, [task])

  const mutation = useMutation({
    mutationFn: (data: TaskInput) =>
      isEditing ? updateTask(Number(id), data) : createTask(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['tasks'] })
      navigate('/tasks')
    },
    onError: (err: Error) => {
      setError(err.message || 'Something went wrong')
    },
  })

  if (isEditing && taskLoading) return <Loading />

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    setError(null)
    mutation.mutate({
      ...form,
      user_id: form.user_id || null,
    })
  }

  return (
    <div className="max-w-2xl mx-auto space-y-6">
      {/* Breadcrumb */}
      <nav className="flex items-center gap-2 text-sm text-slate-400">
        <Link to="/tasks" className="hover:text-white">Tasks</Link>
        <span>/</span>
        <span className="text-white">{isEditing ? 'Edit Task' : 'New Task'}</span>
      </nav>

      <div className="card">
        <h1 className="text-2xl font-bold text-white mb-6">
          {isEditing ? 'Edit Task' : 'Create New Task'}
        </h1>

        {error && <ErrorMessage message={error} />}

        <form onSubmit={handleSubmit} className="space-y-6">
          <div>
            <label className="block text-sm font-medium text-slate-300 mb-2">
              Title *
            </label>
            <input
              type="text"
              value={form.title}
              onChange={(e) => setForm({ ...form, title: e.target.value })}
              className="input"
              placeholder="Enter task title"
              required
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-slate-300 mb-2">
              Description
            </label>
            <textarea
              value={form.description}
              onChange={(e) => setForm({ ...form, description: e.target.value })}
              className="input min-h-[120px]"
              placeholder="Enter task description"
              rows={4}
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-slate-300 mb-2">
                Status
              </label>
              <select
                value={form.status}
                onChange={(e) => setForm({ ...form, status: e.target.value })}
                className="input"
              >
                <option value="pending">Pending</option>
                <option value="in_progress">In Progress</option>
                <option value="completed">Completed</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-slate-300 mb-2">
                Assign To
              </label>
              <select
                value={form.user_id || ''}
                onChange={(e) => setForm({ ...form, user_id: e.target.value ? Number(e.target.value) : null })}
                className="input"
              >
                <option value="">Unassigned</option>
                {users?.map((user) => (
                  <option key={user.id} value={user.id}>
                    {user.username}
                  </option>
                ))}
              </select>
            </div>
          </div>

          <div className="flex gap-4 pt-4">
            <button
              type="submit"
              disabled={mutation.isPending}
              className="btn btn-primary"
            >
              {mutation.isPending ? 'Saving...' : isEditing ? 'Update Task' : 'Create Task'}
            </button>
            <Link to="/tasks" className="btn btn-secondary">
              Cancel
            </Link>
          </div>
        </form>
      </div>
    </div>
  )
}

