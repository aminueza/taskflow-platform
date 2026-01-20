export interface User {
  id: number
  username: string
  email: string
  created_at: string
  updated_at: string
}

export interface Task {
  id: number
  title: string
  description: string | null
  status: 'pending' | 'in_progress' | 'completed'
  user_id: number | null
  user?: User
  created_at: string
  updated_at: string
}

export interface ApiError {
  errors: string[]
}

