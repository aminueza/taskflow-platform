import { describe, it, expect, beforeEach, afterEach } from 'vitest'
import MockAdapter from 'axios-mock-adapter'
import api from './client'
import { getUsers, getUser, createUser, updateUser, deleteUser } from './users'
import type { User } from '../types'

describe('Users API', () => {
  let mock: MockAdapter

  beforeEach(() => {
    mock = new MockAdapter(api)
  })

  afterEach(() => {
    mock.restore()
  })

  describe('getUsers', () => {
    it('fetches all users successfully', async () => {
      const mockUsers: User[] = [
        {
          id: 1,
          username: 'user1',
          email: 'user1@example.com',
          created_at: '2024-01-01T00:00:00Z',
          updated_at: '2024-01-01T00:00:00Z',
        },
        {
          id: 2,
          username: 'user2',
          email: 'user2@example.com',
          created_at: '2024-01-02T00:00:00Z',
          updated_at: '2024-01-02T00:00:00Z',
        },
      ]

      mock.onGet('/users').reply(200, mockUsers)

      const users = await getUsers()
      expect(users).toEqual(mockUsers)
      expect(users).toHaveLength(2)
    })

    it('handles empty users list', async () => {
      mock.onGet('/users').reply(200, [])

      const users = await getUsers()
      expect(users).toEqual([])
      expect(users).toHaveLength(0)
    })

    it('throws error on failed request', async () => {
      mock.onGet('/users').reply(500, { error: 'Server error' })

      await expect(getUsers()).rejects.toThrow()
    })
  })

  describe('getUser', () => {
    it('fetches a single user by id', async () => {
      const mockUser: User = {
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        created_at: '2024-01-01T00:00:00Z',
        updated_at: '2024-01-01T00:00:00Z',
      }

      mock.onGet('/users/1').reply(200, mockUser)

      const user = await getUser(1)
      expect(user).toEqual(mockUser)
      expect(user.id).toBe(1)
      expect(user.username).toBe('testuser')
      expect(user.email).toBe('test@example.com')
    })

    it('throws error for non-existent user', async () => {
      mock.onGet('/users/999').reply(404, { error: 'User not found' })

      await expect(getUser(999)).rejects.toThrow()
    })
  })

  describe('createUser', () => {
    it('creates a new user successfully', async () => {
      const userInput = {
        username: 'newuser',
        email: 'newuser@example.com',
      }

      const mockCreatedUser: User = {
        id: 3,
        ...userInput,
        created_at: '2024-01-03T00:00:00Z',
        updated_at: '2024-01-03T00:00:00Z',
      }

      mock.onPost('/users', { user: userInput }).reply(201, mockCreatedUser)

      const user = await createUser(userInput)
      expect(user).toEqual(mockCreatedUser)
      expect(user.id).toBe(3)
      expect(user.username).toBe('newuser')
      expect(user.email).toBe('newuser@example.com')
    })

    it('throws error on validation failure', async () => {
      const invalidUser = {
        username: '',
        email: 'invalid-email',
      }

      mock.onPost('/users').reply(422, { errors: ['Username cannot be blank', 'Email is invalid'] })

      await expect(createUser(invalidUser)).rejects.toThrow()
    })

    it('throws error on duplicate username', async () => {
      const duplicateUser = {
        username: 'existinguser',
        email: 'new@example.com',
      }

      mock.onPost('/users').reply(422, { errors: ['Username has already been taken'] })

      await expect(createUser(duplicateUser)).rejects.toThrow()
    })
  })

  describe('updateUser', () => {
    it('updates a user successfully', async () => {
      const userUpdate = {
        username: 'updateduser',
        email: 'updated@example.com',
      }

      const mockUpdatedUser: User = {
        id: 1,
        ...userUpdate,
        created_at: '2024-01-01T00:00:00Z',
        updated_at: '2024-01-05T00:00:00Z',
      }

      mock.onPatch('/users/1', { user: userUpdate }).reply(200, mockUpdatedUser)

      const user = await updateUser(1, userUpdate)
      expect(user.username).toBe('updateduser')
      expect(user.email).toBe('updated@example.com')
    })

    it('updates only username field', async () => {
      const userUpdate = { username: 'newusername' }

      const mockUpdatedUser: User = {
        id: 1,
        username: 'newusername',
        email: 'original@example.com',
        created_at: '2024-01-01T00:00:00Z',
        updated_at: '2024-01-05T00:00:00Z',
      }

      mock.onPatch('/users/1').reply(200, mockUpdatedUser)

      const user = await updateUser(1, userUpdate)
      expect(user.username).toBe('newusername')
      expect(user.email).toBe('original@example.com')
    })

    it('updates only email field', async () => {
      const userUpdate = { email: 'newemail@example.com' }

      const mockUpdatedUser: User = {
        id: 1,
        username: 'originaluser',
        email: 'newemail@example.com',
        created_at: '2024-01-01T00:00:00Z',
        updated_at: '2024-01-05T00:00:00Z',
      }

      mock.onPatch('/users/1').reply(200, mockUpdatedUser)

      const user = await updateUser(1, userUpdate)
      expect(user.email).toBe('newemail@example.com')
    })

    it('throws error for non-existent user', async () => {
      mock.onPatch('/users/999').reply(404, { error: 'User not found' })

      await expect(updateUser(999, { username: 'test' })).rejects.toThrow()
    })
  })

  describe('deleteUser', () => {
    it('deletes a user successfully', async () => {
      mock.onDelete('/users/1').reply(204)

      await expect(deleteUser(1)).resolves.toBeUndefined()
    })

    it('throws error for non-existent user', async () => {
      mock.onDelete('/users/999').reply(404, { error: 'User not found' })

      await expect(deleteUser(999)).rejects.toThrow()
    })
  })
})
