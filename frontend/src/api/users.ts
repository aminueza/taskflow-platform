import api from './client'
import type { User } from '../types'

export interface UserInput {
  username: string
  email: string
}

export const getUsers = async (): Promise<User[]> => {
  const { data } = await api.get('/users')
  return data
}

export const getUser = async (id: number): Promise<User> => {
  const { data } = await api.get(`/users/${id}`)
  return data
}

export const createUser = async (user: UserInput): Promise<User> => {
  const { data } = await api.post('/users', { user })
  return data
}

export const updateUser = async (id: number, user: Partial<UserInput>): Promise<User> => {
  const { data } = await api.patch(`/users/${id}`, { user })
  return data
}

export const deleteUser = async (id: number): Promise<void> => {
  await api.delete(`/users/${id}`)
}

