import { Card } from '../../components/Card';

export function OutboundOrdersPage() {
  return (
    <Card>
      <h2 className="text-xl font-semibold">Create Outbound Order</h2>
      <div className="mt-3 grid gap-2 sm:grid-cols-2">
        <input placeholder="Order number" />
        <input placeholder="Customer" />
        <input type="date" />
        <select><option>Priority</option><option>Normal</option><option>Rush</option></select>
      </div>
      <div className="mt-4 rounded border border-dashed border-slate-300 p-3">
        <p className="text-sm">Add order lines and quantities. Allocation will create pick tasks.</p>
      </div>
      <button className="mt-3">Save outbound order</button>
    </Card>
  );
}
