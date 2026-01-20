import { useState, useEffect } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Link, useParams, useNavigate } from 'react-router-dom'
import { getUser, createUser, updateUser, type UserInput } from '../api/users'
import Loading from '../components/Loading'
import ErrorMessage from '../components/ErrorMessage'

export default function UserForm() {
  const { id } = useParams()
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const isEditing = Boolean(id)

  const [form, setForm] = useState<UserInput>({
    username: '',
    email: '',
  })
  const [error, setError] = useState<string | null>(null)

  const { data: user, isLoading: userLoading } = useQuery({
    queryKey: ['user', id],
    queryFn: () => getUser(Number(id)),
    enabled: isEditing,
  })

  useEffect(() => {
    if (user) {
      setForm({
        username: user.username,
        email: user.email,
      })
    }
  }, [user])

  const mutation = useMutation({
    mutationFn: (data: UserInput) => {
      return isEditing ? updateUser(Number(id), data) : createUser(data)
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] })
      navigate('/users')
    },
    onError: (err: Error) => {
      setError(err.message || 'Something went wrong')
    },
  })

  if (isEditing && userLoading) return <Loading />

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    setError(null)
    mutation.mutate(form)
  }

  return (
    <div className="max-w-2xl mx-auto space-y-6">
      {/* Breadcrumb */}
      <nav className="flex items-center gap-2 text-sm text-slate-400">
        <Link to="/users" className="hover:text-white">Team</Link>
        <span>/</span>
        <span className="text-white">{isEditing ? 'Edit Member' : 'New Member'}</span>
      </nav>

      <div className="card">
        <h1 className="text-2xl font-bold text-white mb-6">
          {isEditing ? 'Edit Team Member' : 'Add Team Member'}
        </h1>

        {error && <ErrorMessage message={error} />}

        <form onSubmit={handleSubmit} className="space-y-6">
          <div>
            <label className="block text-sm font-medium text-slate-300 mb-2">
              Username *
            </label>
            <input
              type="text"
              value={form.username}
              onChange={(e) => setForm({ ...form, username: e.target.value })}
              className="input"
              placeholder="Enter username"
              required
              minLength={3}
              maxLength={50}
            />
            <p className="text-slate-500 text-sm mt-1">
              3-50 characters
            </p>
          </div>

          <div>
            <label className="block text-sm font-medium text-slate-300 mb-2">
              Email *
            </label>
            <input
              type="email"
              value={form.email}
              onChange={(e) => setForm({ ...form, email: e.target.value })}
              className="input"
              placeholder="Enter email address"
              required
            />
          </div>

          <div className="flex gap-4 pt-4">
            <button
              type="submit"
              disabled={mutation.isPending}
              className="btn btn-primary"
            >
              {mutation.isPending ? 'Saving...' : isEditing ? 'Update Member' : 'Add Member'}
            </button>
            <Link to="/users" className="btn btn-secondary">
              Cancel
            </Link>
          </div>
        </form>
      </div>
    </div>
  )
}

