import { Outlet, NavLink } from 'react-router-dom'
import { clsx } from 'clsx'

const navItems = [
  { path: '/dashboard', label: 'Dashboard', icon: '📊' },
  { path: '/tasks', label: 'Tasks', icon: '📋' },
  { path: '/users', label: 'Users', icon: '👥' },
]

export default function Layout() {
  return (
    <div className="min-h-full">
      {/* Header */}
      <header className="bg-slate-800 border-b border-slate-700">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <div className="flex items-center gap-8">
              <NavLink to="/" className="flex items-center gap-2">
                <span className="text-2xl">⚡</span>
                <span className="text-xl font-bold text-white">TaskFlow</span>
              </NavLink>
              <nav className="flex gap-1">
                {navItems.map((item) => (
                  <NavLink
                    key={item.path}
                    to={item.path}
                    className={({ isActive }) =>
                      clsx(
                        'px-4 py-2 rounded-lg text-sm font-medium transition-colors',
                        isActive
                          ? 'bg-emerald-600 text-white'
                          : 'text-slate-300 hover:bg-slate-700 hover:text-white'
                      )
                    }
                  >
                    <span className="mr-2">{item.icon}</span>
                    {item.label}
                  </NavLink>
                ))}
              </nav>
            </div>
            <div className="flex items-center gap-4">
              <span className="text-sm text-slate-400">React + Rails API</span>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <Outlet />
      </main>
    </div>
  )
}

