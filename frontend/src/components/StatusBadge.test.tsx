import { describe, it, expect } from 'vitest'
import { render, screen } from '../test/test-utils'
import StatusBadge from './StatusBadge'

describe('StatusBadge', () => {
  describe('Status type', () => {
    it('renders pending status correctly', () => {
      render(<StatusBadge status="pending" />)
      expect(screen.getByText('Pending')).toBeInTheDocument()
    })

    it('renders in_progress status correctly', () => {
      render(<StatusBadge status="in_progress" />)
      expect(screen.getByText('In Progress')).toBeInTheDocument()
    })

    it('renders completed status correctly', () => {
      render(<StatusBadge status="completed" />)
      expect(screen.getByText('Completed')).toBeInTheDocument()
    })

    it('applies correct CSS class for pending status', () => {
      render(<StatusBadge status="pending" />)
      const badge = screen.getByText('Pending')
      expect(badge).toHaveClass('badge', 'badge-pending')
    })

    it('applies correct CSS class for in_progress status', () => {
      render(<StatusBadge status="in_progress" />)
      const badge = screen.getByText('In Progress')
      expect(badge).toHaveClass('badge', 'badge-in_progress')
    })

    it('applies correct CSS class for completed status', () => {
      render(<StatusBadge status="completed" />)
      const badge = screen.getByText('Completed')
      expect(badge).toHaveClass('badge', 'badge-completed')
    })
  })

  describe('Priority type', () => {
    it('renders high priority correctly', () => {
      render(<StatusBadge status="high" type="priority" />)
      expect(screen.getByText('High')).toBeInTheDocument()
    })

    it('renders medium priority correctly', () => {
      render(<StatusBadge status="medium" type="priority" />)
      expect(screen.getByText('Medium')).toBeInTheDocument()
    })

    it('renders low priority correctly', () => {
      render(<StatusBadge status="low" type="priority" />)
      expect(screen.getByText('Low')).toBeInTheDocument()
    })

    it('applies correct CSS class for priority type', () => {
      render(<StatusBadge status="high" type="priority" />)
      const badge = screen.getByText('High')
      expect(badge).toHaveClass('badge', 'badge-high')
    })
  })

  describe('Unknown status', () => {
    it('displays the raw status value when not found in labels', () => {
      render(<StatusBadge status="unknown" />)
      expect(screen.getByText('unknown')).toBeInTheDocument()
    })
  })
})
