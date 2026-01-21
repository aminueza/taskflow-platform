import { describe, it, expect } from 'vitest'
import { render, screen } from '../test/test-utils'
import { MemoryRouter, Routes, Route } from 'react-router-dom'
import Layout from './Layout'

describe('Layout', () => {
  it('renders TaskFlow branding', () => {
    render(
      <MemoryRouter>
        <Layout />
      </MemoryRouter>
    )

    expect(screen.getByText('TaskFlow')).toBeInTheDocument()
  })

  it('renders all navigation items', () => {
    render(
      <MemoryRouter>
        <Layout />
      </MemoryRouter>
    )

    expect(screen.getByText(/Dashboard/)).toBeInTheDocument()
    expect(screen.getByText(/Tasks/)).toBeInTheDocument()
    expect(screen.getByText(/Users/)).toBeInTheDocument()
  })

  it('renders subtitle text', () => {
    render(
      <MemoryRouter>
        <Layout />
      </MemoryRouter>
    )

    expect(screen.getByText('React + Rails API')).toBeInTheDocument()
  })

  it('renders navigation with correct paths', () => {
    render(
      <MemoryRouter>
        <Layout />
      </MemoryRouter>
    )

    const dashboardLink = screen.getByText(/Dashboard/).closest('a')
    const tasksLink = screen.getByText(/Tasks/).closest('a')
    const usersLink = screen.getByText(/Users/).closest('a')

    expect(dashboardLink).toHaveAttribute('href', '/dashboard')
    expect(tasksLink).toHaveAttribute('href', '/tasks')
    expect(usersLink).toHaveAttribute('href', '/users')
  })

  it('renders child routes through Outlet', () => {
    const TestChild = () => <div>Test Child Component</div>

    render(
      <MemoryRouter initialEntries={['/test']}>
        <Routes>
          <Route path="/" element={<Layout />}>
            <Route path="test" element={<TestChild />} />
          </Route>
        </Routes>
      </MemoryRouter>
    )

    expect(screen.getByText('Test Child Component')).toBeInTheDocument()
  })

  it('applies active styles to current navigation item', () => {
    render(
      <MemoryRouter initialEntries={['/dashboard']}>
        <Routes>
          <Route path="/" element={<Layout />}>
            <Route path="dashboard" element={<div>Dashboard</div>} />
          </Route>
        </Routes>
      </MemoryRouter>
    )

    const dashboardLink = screen.getByText(/Dashboard/).closest('a')
    expect(dashboardLink).toHaveClass('bg-emerald-600', 'text-white')
  })
})
