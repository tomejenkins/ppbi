import { useState } from 'react';
import { BarcodeScanner } from '../../components/BarcodeScanner';
import { Card } from '../../components/Card';

export function ReceivingExecutionPage() {
  const [lastScan, setLastScan] = useState('');

  return (
    <div className="space-y-4">
      <Card>
        <h2 className="text-xl font-semibold">Mobile Receiving</h2>
        <p className="mb-3 text-sm text-slate-600">Scan order, scan item, confirm quantity, capture lot/serial when required.</p>
        <BarcodeScanner onDetected={setLastScan} />
        <input className="mt-3 w-full" placeholder="Manual barcode entry" onChange={(e) => setLastScan(e.target.value)} />
        <p className="mt-2 text-sm">Last scan: <span className="font-semibold">{lastScan || 'None'}</span></p>
      </Card>
      <Card>
        <div className="grid gap-2 sm:grid-cols-2">
          <input placeholder="Receiving Order" />
          <input placeholder="Item SKU / Barcode" />
          <input type="number" placeholder="Received Qty" />
          <select>
            <option>Staging Location</option>
            <option>DOCK-A-01</option>
          </select>
          <select>
            <option>Mismatch Reason</option>
            <option>OVERAGE</option>
            <option>SHORTAGE</option>
            <option>DAMAGED</option>
          </select>
          <input placeholder="Lot / Serial / Expiration" />
        </div>
        <button className="mt-3 w-full">Post Receipt Line</button>
      </Card>
    </div>
  );
}
