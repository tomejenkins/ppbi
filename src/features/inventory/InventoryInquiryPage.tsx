import { Card } from '../../components/Card';

export function InventoryInquiryPage() {
  return (
    <Card>
      <h2 className="text-xl font-semibold">Inventory Inquiry</h2>
      <div className="mt-3 grid gap-2 sm:grid-cols-4">
        <input placeholder="Item" />
        <input placeholder="Location" />
        <select>
          <option>Status</option>
          <option>available</option>
          <option>quarantine</option>
          <option>hold</option>
        </select>
        <button>Search</button>
      </div>
      <div className="mt-4 overflow-x-auto">
        <table className="min-w-full text-sm">
          <thead>
            <tr className="border-b text-left">
              <th>Item</th><th>Location</th><th>Status</th><th>Lot</th><th>Qty</th><th>Last Txn</th>
            </tr>
          </thead>
          <tbody>
            <tr className="border-b"><td>SKU-1001</td><td>A-01-01-01</td><td>available</td><td>L2409</td><td>148</td><td>PUTAWAY</td></tr>
          </tbody>
        </table>
      </div>
    </Card>
  );
}
