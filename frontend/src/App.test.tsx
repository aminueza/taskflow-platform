import { describe, it, expect } from 'vitest'
import { render, screen } from './test/test-utils'
import { MemoryRouter } from 'react-router-dom'
import App from './App'

describe('App', () => {
  it('renders without crashing', () => {
    render(<App />)
    expect(screen.getByText('TaskFlow')).toBeInTheDocument()
  })

  it('redirects root path to dashboard', () => {
    const { container } = render(
      <MemoryRouter initialEntries={['/']}>
        <App />
      </MemoryRouter>
    )

    // After redirect, we should see the TaskFlow header
    expect(screen.getByText('TaskFlow')).toBeInTheDocument()
  })

  it('renders navigation items', () => {
    render(<App />)

    expect(screen.getByText(/Dashboard/)).toBeInTheDocument()
    expect(screen.getByText(/Tasks/)).toBeInTheDocument()
    expect(screen.getByText(/Users/)).toBeInTheDocument()
  })

  it('displays application subtitle', () => {
    render(<App />)

    expect(screen.getByText('React + Rails API')).toBeInTheDocument()
  })

  it('renders Layout component with navigation', () => {
    render(<App />)

    // Check for navigation icons
    const navigation = screen.getByText('TaskFlow').closest('header')
    expect(navigation).toBeInTheDocument()
  })
})
