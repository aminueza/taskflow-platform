import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Link } from 'react-router-dom'
import { getUsers, deleteUser } from '../api/users'
import Loading from '../components/Loading'
import ErrorMessage from '../components/ErrorMessage'
import { format } from 'date-fns'

export default function UserList() {
  const queryClient = useQueryClient()

  const { data: users, isLoading, error } = useQuery({
    queryKey: ['users'],
    queryFn: getUsers,
  })

  const deleteMutation = useMutation({
    mutationFn: deleteUser,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] })
    },
  })

  if (isLoading) return <Loading />
  if (error) return <ErrorMessage message="Failed to load users" />

  const handleDelete = (id: number, username: string) => {
    if (confirm(`Are you sure you want to delete ${username}?`)) {
      deleteMutation.mutate(id)
    }
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-white">Team Members</h1>
          <p className="text-slate-400 mt-1">{users?.length || 0} members</p>
        </div>
        <Link to="/users/new" className="btn btn-primary">
          + Add Member
        </Link>
      </div>

      {/* User Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {users?.map((user) => (
          <div key={user.id} className="card">
            <div className="flex items-start justify-between">
              <Link
                to={`/users/${user.id}`}
                className="flex items-center gap-3 hover:opacity-80 transition-opacity"
              >
                <div className="w-12 h-12 rounded-full bg-gradient-to-br from-emerald-500 to-blue-500 flex items-center justify-center text-white text-lg font-medium">
                  {user.username.charAt(0).toUpperCase()}
                </div>
                <div>
                  <p className="text-white font-medium">{user.username}</p>
                  <p className="text-slate-400 text-sm">{user.email}</p>
                </div>
              </Link>
            </div>

            <div className="mt-4 pt-4 border-t border-slate-700 flex items-center justify-between">
              <span className="text-slate-400 text-sm">
                Joined {format(new Date(user.created_at), 'MMM yyyy')}
              </span>
              <div className="flex gap-2">
                <Link
                  to={`/users/${user.id}/edit`}
                  className="px-3 py-1 text-sm bg-slate-700 hover:bg-slate-600 text-slate-300 rounded-lg transition-colors"
                >
                  Edit
                </Link>
                <button
                  onClick={() => handleDelete(user.id, user.username)}
                  className="px-3 py-1 text-sm bg-red-500/20 hover:bg-red-500/30 text-red-400 rounded-lg transition-colors"
                >
                  Delete
                </button>
              </div>
            </div>
          </div>
        ))}

        {(!users || users.length === 0) && (
          <div className="card col-span-full text-center py-12">
            <p className="text-slate-400">No team members yet</p>
            <Link to="/users/new" className="text-emerald-400 text-sm hover:text-emerald-300 mt-2 inline-block">
              Add your first team member →
            </Link>
          </div>
        )}
      </div>
    </div>
  )
}

