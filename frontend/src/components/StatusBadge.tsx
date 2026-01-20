import { clsx } from 'clsx'

interface Props {
  status: string
  type?: 'status' | 'priority'
}

const statusLabels: Record<string, string> = {
  pending: 'Pending',
  in_progress: 'In Progress',
  completed: 'Completed',
  high: 'High',
  medium: 'Medium',
  low: 'Low',
}

export default function StatusBadge({ status, type = 'status' }: Props) {
  return (
    <span
      className={clsx(
        'badge',
        type === 'status' ? `badge-${status}` : `badge-${status}`
      )}
    >
      {statusLabels[status] || status}
    </span>
  )
}

