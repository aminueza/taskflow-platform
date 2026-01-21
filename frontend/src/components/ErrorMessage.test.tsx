import { describe, it, expect } from 'vitest'
import { render, screen } from '../test/test-utils'
import ErrorMessage from './ErrorMessage'

describe('ErrorMessage', () => {
  it('renders error message correctly', () => {
    const message = 'Something went wrong'
    render(<ErrorMessage message={message} />)

    expect(screen.getByText('Error')).toBeInTheDocument()
    expect(screen.getByText(message)).toBeInTheDocument()
  })

  it('renders with correct styling classes', () => {
    render(<ErrorMessage message="Test error" />)

    const container = screen.getByText('Error').parentElement
    expect(container).toHaveClass('bg-red-500/10', 'border', 'border-red-500/20', 'rounded-lg', 'p-4', 'text-red-400')
  })

  it('displays long error messages', () => {
    const longMessage = 'This is a very long error message that contains multiple sentences. It should still be displayed correctly without any issues. The component should handle long text gracefully.'
    render(<ErrorMessage message={longMessage} />)

    expect(screen.getByText(longMessage)).toBeInTheDocument()
  })

  it('displays empty error message', () => {
    render(<ErrorMessage message="" />)

    expect(screen.getByText('Error')).toBeInTheDocument()
    const messageElement = screen.getByText('Error').nextElementSibling
    expect(messageElement).toHaveTextContent('')
  })

  it('handles special characters in message', () => {
    const specialMessage = 'Error: <script>alert("XSS")</script> & "quotes"'
    render(<ErrorMessage message={specialMessage} />)

    expect(screen.getByText(specialMessage)).toBeInTheDocument()
  })
})
