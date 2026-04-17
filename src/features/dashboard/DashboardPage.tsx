import { Card } from '../../components/Card';

const tiles = [
  ['Today Receipts', '27'],
  ['Dock-to-Stock Avg', '42 min'],
  ['Open Outbound Orders', '31'],
  ['Items on Hold', '9'],
  ['Clocked-in Associates', '44'],
  ['Pick Rate', '112 lines/hr']
];

export function DashboardPage() {
  return (
    <div className="space-y-4">
      <h2 className="text-xl font-semibold">Operations Dashboard</h2>
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {tiles.map(([label, value]) => (
          <Card key={label}>
            <p className="text-sm text-slate-500">{label}</p>
            <p className="mt-2 text-2xl font-bold">{value}</p>
          </Card>
        ))}
      </div>
      <Card>
        <h3 className="mb-2 font-semibold">Real-time Activity Board</h3>
        <p className="text-sm text-slate-700">Hook this to Supabase Realtime channels for receipts, picks, QC and shipments.</p>
      </Card>
    </div>
  );
}
