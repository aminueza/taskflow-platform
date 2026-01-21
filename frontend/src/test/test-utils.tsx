import { ReactElement } from 'react'
import { render, RenderOptions } from '@testing-library/react'
import { BrowserRouter } from 'react-router-dom'
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
}

function customRender(
  ui: ReactElement,
  options: CustomRenderOptions = {}
) {
  const {
    withRouter = false,
    withQueryClient = false,
    ...renderOptions
  } = options

  let Wrapper = ({ children }: { children: React.ReactNode }) => <>{children}</>

  if (withQueryClient) {
    const queryClient = createTestQueryClient()
    const QueryWrapper = Wrapper
    Wrapper = ({ children }) => (
      <QueryClientProvider client={queryClient}>
        <QueryWrapper>{children}</QueryWrapper>
      </QueryClientProvider>
    )
  }

  if (withRouter) {
    const RouterWrapper = Wrapper
    Wrapper = ({ children }) => (
      <BrowserRouter>
        <RouterWrapper>{children}</RouterWrapper>
      </BrowserRouter>
    )
  }

  return render(ui, { wrapper: Wrapper, ...renderOptions })
}

export * from '@testing-library/react'
export { customRender as render }
