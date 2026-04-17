import { Card } from '../../components/Card';

export function QcQueuePage() {
  return (
    <div className="space-y-4">
      <Card>
        <h2 className="text-xl font-semibold">Inbound QC Queue</h2>
        <p className="text-sm text-slate-600">Inspections from receipts flagged by item/supplier rules.</p>
        <table className="mt-3 min-w-full text-sm">
          <thead><tr className="border-b text-left"><th>Receipt</th><th>Item</th><th>Status</th><th>Disposition</th></tr></thead>
          <tbody><tr className="border-b"><td>RCV-10042</td><td>SKU-1001</td><td>pending</td><td>-</td></tr></tbody>
        </table>
      </Card>
      <Card>
        <h3 className="font-semibold">Disposition</h3>
        <div className="mt-2 grid gap-2 sm:grid-cols-3">
          <select><option>PASS</option><option>FAIL</option><option>CONDITIONAL_PASS</option></select>
          <select><option>Release to available</option><option>Scrap</option><option>Return to vendor</option></select>
          <input type="file" />
        </div>
        <button className="mt-3">Apply QC disposition</button>
      </Card>
    </div>
  );
}
