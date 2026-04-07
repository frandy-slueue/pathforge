function App() {
  return (
    <div className="w-full h-full flex flex-col items-center justify-center gap-6 bg-bg-app">

      <h1 className="text-5xl font-black tracking-tight font-ui">
        <span className="text-accent">Path</span>
        <span className="text-accent-2">Forge</span>
      </h1>

      <p className="font-mono text-xs text-text-sec tracking-wide">
        Step 1.3 — Frontend scaffold running
      </p>

      <div className="flex flex-col gap-2 px-7 py-5 bg-bg-surface border border-white/5 rounded-lg">
        {[
          'React 18 mounted',
          'TypeScript compiling',
          'Vite dev server running',
          'CSS variables active',
          'Tailwind v4 active',
          'Syne + Space Mono fonts',
        ].map((item) => (
          <div
            key={item}
            className="flex items-center gap-3 font-mono text-xs text-text-pri"
          >
            <span className="text-accent text-sm">✓</span>
            {item}
          </div>
        ))}
      </div>

      <p className="font-mono text-[10px] text-text-muted">
        Next: Step 1.4 — Docker Compose
      </p>
    </div>
  )
}

export default App
