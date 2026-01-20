import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Link, useParams, useNavigate } from 'react-router-dom'
import { getUser, deleteUser } from '../api/users'
import { getTasks } from '../api/tasks'
import Loading from '../components/Loading'
import ErrorMessage from '../components/ErrorMessage'
import StatusBadge from '../components/StatusBadge'
import { format } from 'date-fns'

export default function UserDetail() {
  const { id } = useParams()
  const navigate = useNavigate()
  const queryClient = useQueryClient()

  const { data: user, isLoading: userLoading, error: userError } = useQuery({
    queryKey: ['user', id],
    queryFn: () => getUser(Number(id)),
  })

  const { data: allTasks } = useQuery({
    queryKey: ['tasks'],
    queryFn: getTasks,
  })

  const userTasks = allTasks?.filter((task) => task.user_id === Number(id)) || []

  const deleteMutation = useMutation({
    mutationFn: deleteUser,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] })
      navigate('/users')
    },
  })

  if (userLoading) return <Loading />
  if (userError) return <ErrorMessage message="Failed to load user" />
  if (!user) return <ErrorMessage message="User not found" />

  const handleDelete = () => {
    if (confirm(`Are you sure you want to delete ${user.username}?`)) {
      deleteMutation.mutate(user.id)
    }
  }

  const pendingTasks = userTasks.filter((t) => t.status === 'pending').length
  const inProgressTasks = userTasks.filter((t) => t.status === 'in_progress').length
  const completedTasks = userTasks.filter((t) => t.status === 'completed').length

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      {/* Breadcrumb */}
      <nav className="flex items-center gap-2 text-sm text-slate-400">
        <Link to="/users" className="hover:text-white">Team</Link>
        <span>/</span>
        <span className="text-white">{user.username}</span>
      </nav>

      {/* Profile Card */}
      <div className="card">
        <div className="flex items-start justify-between">
          <div className="flex items-center gap-4">
            <div className="w-16 h-16 rounded-full bg-gradient-to-br from-emerald-500 to-blue-500 flex items-center justify-center text-white text-2xl font-medium">
              {user.username.charAt(0).toUpperCase()}
            </div>
            <div>
              <h1 className="text-2xl font-bold text-white">{user.username}</h1>
              <p className="text-slate-400">{user.email}</p>
              <p className="text-slate-500 text-sm mt-1">
                Member since {format(new Date(user.created_at), 'MMMM yyyy')}
              </p>
            </div>
          </div>
          <div className="flex gap-2">
            <Link to={`/users/${user.id}/edit`} className="btn btn-secondary">
              Edit
            </Link>
            <button onClick={handleDelete} className="btn btn-danger">
              Delete
            </button>
          </div>
        </div>

        {/* Stats */}
        <div className="grid grid-cols-4 gap-4 mt-6 pt-6 border-t border-slate-700">
          <div className="text-center">
            <p className="text-2xl font-bold text-white">{userTasks.length}</p>
            <p className="text-slate-400 text-sm">Total Tasks</p>
          </div>
          <div className="text-center">
            <p className="text-2xl font-bold text-amber-400">{pendingTasks}</p>
            <p className="text-slate-400 text-sm">Pending</p>
          </div>
          <div className="text-center">
            <p className="text-2xl font-bold text-blue-400">{inProgressTasks}</p>
            <p className="text-slate-400 text-sm">In Progress</p>
          </div>
          <div className="text-center">
            <p className="text-2xl font-bold text-emerald-400">{completedTasks}</p>
            <p className="text-slate-400 text-sm">Completed</p>
          </div>
        </div>
      </div>

      {/* Assigned Tasks */}
      <div className="card">
        <h2 className="text-lg font-semibold text-white mb-4">Assigned Tasks</h2>
        <div className="space-y-3">
          {userTasks.map((task) => (
            <Link
              key={task.id}
              to={`/tasks/${task.id}`}
              className="block p-4 bg-slate-700/50 rounded-lg hover:bg-slate-700 transition-colors"
            >
              <div className="flex items-start justify-between gap-3">
                <div className="flex-1 min-w-0">
                  <p className="text-white font-medium">{task.title}</p>
                  {task.description && (
                    <p className="text-slate-400 text-sm mt-1 line-clamp-1">
                      {task.description}
                    </p>
                  )}
                  <p className="text-slate-500 text-sm mt-2">
                    Created: {format(new Date(task.created_at), 'MMM d, yyyy')}
                  </p>
                </div>
                <StatusBadge status={task.status} />
              </div>
            </Link>
          ))}

          {userTasks.length === 0 && (
            <p className="text-slate-400 text-center py-8">No tasks assigned</p>
          )}
        </div>
      </div>

      {/* Back Link */}
      <Link to="/users" className="text-slate-400 hover:text-white text-sm inline-flex items-center gap-2">
        ← Back to Team
      </Link>
    </div>
  )
}

