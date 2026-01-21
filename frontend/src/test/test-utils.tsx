import { ReactElement } from 'react'
import { render, RenderOptions } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'

const createTestQueryClient = () =>
  new QueryClient({
    defaultOptions: {
      queries: {
        retry: false,
      },
      mutations: {
        retry: false,
      },
    },
  })

interface CustomRenderOptions extends Omit<RenderOptions, 'wrapper'> {
  withRouter?: boolean
  withQueryClient?: boolean
  initialEntries?: string[]
}

function customRender(
  ui: ReactElement,
  options: CustomRenderOptions = {}
) {
  const {
    withRouter = true,
    withQueryClient = true,
    initialEntries,
    ...renderOptions
  } = options

  const queryClient = createTestQueryClient()

  function Wrapper({ children }: { children: React.ReactNode }) {
    let wrapped = <>{children}</>

    if (withQueryClient) {
      wrapped = (
        <QueryClientProvider client={queryClient}>
          {wrapped}
        </QueryClientProvider>
      )
    }

    if (withRouter) {
      wrapped = <MemoryRouter initialEntries={initialEntries}>{wrapped}</MemoryRouter>
    }

    return wrapped
  }

  return render(ui, { wrapper: Wrapper, ...renderOptions })
}

export * from '@testing-library/react'
export { customRender as render }
