import { useQuery } from '@tanstack/react-query'
import { Link } from 'react-router-dom'
import { getTasks } from '../api/tasks'
import { getUsers } from '../api/users'
import Loading from '../components/Loading'
import ErrorMessage from '../components/ErrorMessage'
import StatusBadge from '../components/StatusBadge'
import { format } from 'date-fns'

export default function Dashboard() {
  const { data: tasks, isLoading: tasksLoading, error: tasksError } = useQuery({
    queryKey: ['tasks'],
    queryFn: getTasks,
  })

  const { data: users, isLoading: usersLoading, error: usersError } = useQuery({
    queryKey: ['users'],
    queryFn: getUsers,
  })

  if (tasksLoading || usersLoading) return <Loading />
  if (tasksError) return <ErrorMessage message="Failed to load tasks" />
  if (usersError) return <ErrorMessage message="Failed to load users" />

  const pendingCount = tasks?.filter(t => t.status === 'pending').length || 0
  const inProgressCount = tasks?.filter(t => t.status === 'in_progress').length || 0
  const completedCount = tasks?.filter(t => t.status === 'completed').length || 0

  const recentTasks = tasks?.slice(0, 5) || []

  return (
    <div className="space-y-8">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-white">Dashboard</h1>
        <p className="text-slate-400 mt-1">Overview of your tasks and team</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-4">
        <div className="card">
          <p className="text-slate-400 text-sm">Total Tasks</p>
          <p className="text-3xl font-bold text-white mt-2">{tasks?.length || 0}</p>
        </div>
        <div className="card">
          <p className="text-slate-400 text-sm">Pending</p>
          <p className="text-3xl font-bold text-amber-400 mt-2">{pendingCount}</p>
        </div>
        <div className="card">
          <p className="text-slate-400 text-sm">In Progress</p>
          <p className="text-3xl font-bold text-blue-400 mt-2">{inProgressCount}</p>
        </div>
        <div className="card">
          <p className="text-slate-400 text-sm">Completed</p>
          <p className="text-3xl font-bold text-emerald-400 mt-2">{completedCount}</p>
        </div>
        <div className="card">
          <p className="text-slate-400 text-sm">Team Members</p>
          <p className="text-3xl font-bold text-purple-400 mt-2">{users?.length || 0}</p>
        </div>
      </div>

      {/* Two Column Layout */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        {/* Recent Tasks */}
        <div className="card">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold text-white">Recent Tasks</h2>
            <Link to="/tasks" className="text-emerald-400 text-sm hover:text-emerald-300">
              View all →
            </Link>
          </div>
          <div className="space-y-3">
            {recentTasks.map((task) => (
              <Link
                key={task.id}
                to={`/tasks/${task.id}`}
                className="block p-3 bg-slate-700/50 rounded-lg hover:bg-slate-700 transition-colors"
              >
                <div className="flex items-start justify-between gap-3">
                  <div className="flex-1 min-w-0">
                    <p className="text-white font-medium truncate">{task.title}</p>
                    <p className="text-slate-400 text-sm mt-1">
                      {task.user_id ? `User #${task.user_id}` : 'Unassigned'}
                    </p>
                  </div>
                  <StatusBadge status={task.status} />
                </div>
              </Link>
            ))}
            {recentTasks.length === 0 && (
              <p className="text-slate-400 text-center py-4">No tasks yet</p>
            )}
          </div>
        </div>

        {/* Team Members */}
        <div className="card">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold text-white">Team Members</h2>
            <Link to="/users" className="text-emerald-400 text-sm hover:text-emerald-300">
              View all →
            </Link>
          </div>
          <div className="space-y-3">
            {users?.slice(0, 5).map((user) => (
              <Link
                key={user.id}
                to={`/users/${user.id}`}
                className="flex items-center gap-3 p-3 bg-slate-700/50 rounded-lg hover:bg-slate-700 transition-colors"
              >
                <div className="w-10 h-10 rounded-full bg-gradient-to-br from-emerald-500 to-blue-500 flex items-center justify-center text-white font-medium">
                  {user.username.charAt(0).toUpperCase()}
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-white font-medium truncate">{user.username}</p>
                  <p className="text-slate-400 text-sm truncate">{user.email}</p>
                </div>
                <span className="text-slate-400 text-sm">
                  {tasks?.filter(t => t.user_id === user.id).length || 0} tasks
                </span>
              </Link>
            ))}
            {(!users || users.length === 0) && (
              <p className="text-slate-400 text-center py-4">No team members yet</p>
            )}
          </div>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="flex gap-4">
        <Link to="/tasks/new" className="btn btn-primary">
          + New Task
        </Link>
        <Link to="/users/new" className="btn btn-secondary">
          + Add Team Member
        </Link>
      </div>
    </div>
  )
}

