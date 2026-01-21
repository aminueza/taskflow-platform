# Frontend Testing Guide

## Overview

This project uses **Vitest** as the test runner and **React Testing Library** for component testing. Tests are co-located with their source files using the `.test.tsx` or `.test.ts` extension.

## Installation

All testing dependencies are included in `package.json`. To install them:

```bash
npm install
```

## Running Tests

### Run all tests
```bash
npm test
```

### Run tests in watch mode
```bash
npm test -- --watch
```

### Run tests with UI
```bash
npm run test:ui
```

### Run tests with coverage
```bash
npm run test:coverage
```

## Test Structure

### Component Tests
Component tests are located next to their source files:
```
src/components/
├── StatusBadge.tsx
├── StatusBadge.test.tsx
├── ErrorMessage.tsx
├── ErrorMessage.test.tsx
└── ...
```

### API Tests
API tests are located in the `src/api/` directory:
```
src/api/
├── tasks.ts
├── tasks.test.ts
├── users.ts
└── users.test.ts
```

## Writing Tests

### Component Testing

Use the custom render function from `src/test/test-utils.tsx`:

```typescript
import { render, screen } from '../test/test-utils'
import MyComponent from './MyComponent'

describe('MyComponent', () => {
  it('renders correctly', () => {
    render(<MyComponent />)
    expect(screen.getByText('Hello')).toBeInTheDocument()
  })
})
```

#### With Router
For components that use React Router:

```typescript
render(<MyComponent />, { withRouter: true })
```

#### With React Query
For components that use React Query:

```typescript
render(<MyComponent />, { withQueryClient: true })
```

#### With Both
```typescript
render(<MyComponent />, { withRouter: true, withQueryClient: true })
```

### API Testing

API tests use `axios-mock-adapter` to mock HTTP requests:

```typescript
import { describe, it, expect, beforeEach, afterEach } from 'vitest'
import MockAdapter from 'axios-mock-adapter'
import api from './client'
import { getItems } from './items'

describe('Items API', () => {
  let mock: MockAdapter

  beforeEach(() => {
    mock = new MockAdapter(api)
  })

  afterEach(() => {
    mock.restore()
  })

  it('fetches items successfully', async () => {
    const mockItems = [{ id: 1, name: 'Item 1' }]
    mock.onGet('/items').reply(200, mockItems)

    const items = await getItems()
    expect(items).toEqual(mockItems)
  })
})
```

## Test Files Overview

### Component Tests
- `StatusBadge.test.tsx` - Tests status badge rendering and styling
- `ErrorMessage.test.tsx` - Tests error message display
- `Loading.test.tsx` - Tests loading spinner component
- `Layout.test.tsx` - Tests layout navigation and routing
- `App.test.tsx` - Tests application routing

### API Tests
- `tasks.test.ts` - Tests all task API operations (CRUD)
- `users.test.ts` - Tests all user API operations (CRUD)

## Configuration Files

### vitest.config.ts
Main Vitest configuration file with:
- React plugin setup
- jsdom environment
- Global test utilities
- Path aliases

### src/test/setup.ts
Test setup file that:
- Imports jest-dom matchers
- Configures cleanup after each test

### src/test/test-utils.tsx
Custom render utilities with wrappers for:
- React Router (BrowserRouter)
- React Query (QueryClientProvider)

## Best Practices

1. **Use descriptive test names**: Test names should clearly describe what they're testing
2. **Test user behavior**: Focus on how users interact with components, not implementation details
3. **Mock external dependencies**: Use axios-mock-adapter for API calls
4. **Clean up after tests**: The setup file automatically cleans up after each test
5. **Use semantic queries**: Prefer `getByRole`, `getByText`, `getByLabelText` over `getByTestId`

## Common Testing Patterns

### Testing async operations
```typescript
it('loads data', async () => {
  render(<MyComponent />)

  // Wait for element to appear
  const element = await screen.findByText('Loaded data')
  expect(element).toBeInTheDocument()
})
```

### Testing user interactions
```typescript
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'

it('handles button click', async () => {
  const user = userEvent.setup()
  render(<MyComponent />)

  const button = screen.getByRole('button', { name: /submit/i })
  await user.click(button)

  expect(screen.getByText('Submitted')).toBeInTheDocument()
})
```

### Testing form inputs
```typescript
it('handles form input', async () => {
  const user = userEvent.setup()
  render(<MyForm />)

  const input = screen.getByLabelText(/username/i)
  await user.type(input, 'john')

  expect(input).toHaveValue('john')
})
```

## Resources

- [Vitest Documentation](https://vitest.dev/)
- [React Testing Library](https://testing-library.com/react)
- [Testing Library Queries](https://testing-library.com/docs/queries/about)
- [jest-dom Matchers](https://github.com/testing-library/jest-dom)
