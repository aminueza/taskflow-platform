import { describe, it, expect } from 'vitest'
import { render, screen } from '../test/test-utils'
import Loading from './Loading'

describe('Loading', () => {
  it('renders loading spinner', () => {
    const { container } = render(<Loading />)

    const spinner = container.querySelector('.animate-spin')
    expect(spinner).toBeInTheDocument()
  })

  it('applies correct styling classes to container', () => {
    const { container } = render(<Loading />)

    const wrapper = container.firstChild
    expect(wrapper).toHaveClass('flex', 'items-center', 'justify-center', 'py-12')
  })

  it('applies correct styling classes to spinner', () => {
    const { container } = render(<Loading />)

    const spinner = container.querySelector('.animate-spin')
    expect(spinner).toHaveClass('animate-spin', 'rounded-full', 'h-8', 'w-8', 'border-b-2', 'border-emerald-500')
  })

  it('renders without crashing', () => {
    const { container } = render(<Loading />)
    expect(container).toBeTruthy()
  })
})
