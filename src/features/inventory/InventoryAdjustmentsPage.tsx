import { Card } from '../../components/Card';

export function InventoryAdjustmentsPage() {
  return (
    <Card>
      <h2 className="text-xl font-semibold">Manual Inventory Adjustment</h2>
      <p className="text-sm text-slate-600">Adjustments route through approval and always generate immutable transactions.</p>
      <div className="mt-3 grid gap-2 sm:grid-cols-3">
        <input placeholder="Item" />
        <input placeholder="Location" />
        <input type="number" placeholder="Qty delta (+/-)" />
        <select>
          <option>Reason code</option>
          <option>DAMAGE</option>
          <option>COUNT_VARIANCE</option>
        </select>
        <textarea className="sm:col-span-2" placeholder="Notes" />
      </div>
      <button className="mt-3">Submit for approval</button>
    </Card>
  );
}
