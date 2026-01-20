import api from './client'
import type { Task } from '../types'

export interface TaskInput {
  title: string
  description?: string
  status: string
  user_id?: number | null
}

export const getTasks = async (): Promise<Task[]> => {
  const { data } = await api.get('/tasks')
  return data
}

export const getTask = async (id: number): Promise<Task> => {
  const { data } = await api.get(`/tasks/${id}`)
  return data
}

export const createTask = async (task: TaskInput): Promise<Task> => {
  const { data } = await api.post('/tasks', { task })
  return data
}

export const updateTask = async (id: number, task: Partial<TaskInput>): Promise<Task> => {
  const { data } = await api.patch(`/tasks/${id}`, { task })
  return data
}

export const deleteTask = async (id: number): Promise<void> => {
  await api.delete(`/tasks/${id}`)
}

