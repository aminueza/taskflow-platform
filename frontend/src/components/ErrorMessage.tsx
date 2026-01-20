interface Props {
  message: string
}

export default function ErrorMessage({ message }: Props) {
  return (
    <div className="bg-red-500/10 border border-red-500/20 rounded-lg p-4 text-red-400">
      <p className="font-medium">Error</p>
      <p className="text-sm mt-1">{message}</p>
    </div>
  )
}

