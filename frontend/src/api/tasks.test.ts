import { describe, it, expect, beforeEach, afterEach } from 'vitest'
import MockAdapter from 'axios-mock-adapter'
import api from './client'
import { getTasks, getTask, createTask, updateTask, deleteTask } from './tasks'
import type { Task } from '../types'

describe('Tasks API', () => {
  let mock: MockAdapter

  beforeEach(() => {
    mock = new MockAdapter(api)
  })

  afterEach(() => {
    mock.restore()
  })

  describe('getTasks', () => {
    it('fetches all tasks successfully', async () => {
      const mockTasks: Task[] = [
        {
          id: 1,
          title: 'Task 1',
          description: 'Description 1',
          status: 'pending',
          user_id: 1,
          created_at: '2024-01-01T00:00:00Z',
          updated_at: '2024-01-01T00:00:00Z',
        },
        {
          id: 2,
          title: 'Task 2',
          description: null,
          status: 'completed',
          user_id: 2,
          created_at: '2024-01-02T00:00:00Z',
          updated_at: '2024-01-02T00:00:00Z',
        },
      ]

      mock.onGet('/tasks').reply(200, mockTasks)

      const tasks = await getTasks()
      expect(tasks).toEqual(mockTasks)
      expect(tasks).toHaveLength(2)
    })

    it('handles empty tasks list', async () => {
      mock.onGet('/tasks').reply(200, [])

      const tasks = await getTasks()
      expect(tasks).toEqual([])
      expect(tasks).toHaveLength(0)
    })

    it('throws error on failed request', async () => {
      mock.onGet('/tasks').reply(500, { error: 'Server error' })

      await expect(getTasks()).rejects.toThrow()
    })
  })

  describe('getTask', () => {
    it('fetches a single task by id', async () => {
      const mockTask: Task = {
        id: 1,
        title: 'Test Task',
        description: 'Test Description',
        status: 'in_progress',
        user_id: 1,
        created_at: '2024-01-01T00:00:00Z',
        updated_at: '2024-01-01T00:00:00Z',
      }

      mock.onGet('/tasks/1').reply(200, mockTask)

      const task = await getTask(1)
      expect(task).toEqual(mockTask)
      expect(task.id).toBe(1)
      expect(task.title).toBe('Test Task')
    })

    it('throws error for non-existent task', async () => {
      mock.onGet('/tasks/999').reply(404, { error: 'Task not found' })

      await expect(getTask(999)).rejects.toThrow()
    })
  })

  describe('createTask', () => {
    it('creates a new task successfully', async () => {
      const taskInput = {
        title: 'New Task',
        description: 'New Description',
        status: 'pending',
        user_id: 1,
      }

      const mockCreatedTask: Task = {
        id: 3,
        ...taskInput,
        created_at: '2024-01-03T00:00:00Z',
        updated_at: '2024-01-03T00:00:00Z',
      }

      mock.onPost('/tasks', { task: taskInput }).reply(201, mockCreatedTask)

      const task = await createTask(taskInput)
      expect(task).toEqual(mockCreatedTask)
      expect(task.id).toBe(3)
      expect(task.title).toBe('New Task')
    })

    it('creates task without optional fields', async () => {
      const taskInput = {
        title: 'Minimal Task',
        status: 'pending',
      }

      const mockCreatedTask: Task = {
        id: 4,
        title: 'Minimal Task',
        description: null,
        status: 'pending',
        user_id: null,
        created_at: '2024-01-04T00:00:00Z',
        updated_at: '2024-01-04T00:00:00Z',
      }

      mock.onPost('/tasks').reply(201, mockCreatedTask)

      const task = await createTask(taskInput)
      expect(task.description).toBeNull()
      expect(task.user_id).toBeNull()
    })

    it('throws error on validation failure', async () => {
      const invalidTask = {
        title: '',
        status: 'invalid',
      }

      mock.onPost('/tasks').reply(422, { errors: ['Title cannot be blank'] })

      await expect(createTask(invalidTask)).rejects.toThrow()
    })
  })

  describe('updateTask', () => {
    it('updates a task successfully', async () => {
      const taskUpdate = {
        title: 'Updated Task',
        status: 'completed',
      }

      const mockUpdatedTask: Task = {
        id: 1,
        title: 'Updated Task',
        description: 'Original Description',
        status: 'completed',
        user_id: 1,
        created_at: '2024-01-01T00:00:00Z',
        updated_at: '2024-01-05T00:00:00Z',
      }

      mock.onPatch('/tasks/1', { task: taskUpdate }).reply(200, mockUpdatedTask)

      const task = await updateTask(1, taskUpdate)
      expect(task.title).toBe('Updated Task')
      expect(task.status).toBe('completed')
    })

    it('updates only status field', async () => {
      const taskUpdate = { status: 'completed' }

      const mockUpdatedTask: Task = {
        id: 1,
        title: 'Original Task',
        description: 'Original Description',
        status: 'completed',
        user_id: 1,
        created_at: '2024-01-01T00:00:00Z',
        updated_at: '2024-01-05T00:00:00Z',
      }

      mock.onPatch('/tasks/1').reply(200, mockUpdatedTask)

      const task = await updateTask(1, taskUpdate)
      expect(task.status).toBe('completed')
    })

    it('throws error for non-existent task', async () => {
      mock.onPatch('/tasks/999').reply(404, { error: 'Task not found' })

      await expect(updateTask(999, { title: 'Test' })).rejects.toThrow()
    })
  })

  describe('deleteTask', () => {
    it('deletes a task successfully', async () => {
      mock.onDelete('/tasks/1').reply(204)

      await expect(deleteTask(1)).resolves.toBeUndefined()
    })

    it('throws error for non-existent task', async () => {
      mock.onDelete('/tasks/999').reply(404, { error: 'Task not found' })

      await expect(deleteTask(999)).rejects.toThrow()
    })
  })
})
