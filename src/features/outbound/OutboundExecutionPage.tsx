import { Card } from '../../components/Card';
import { BarcodeScanner } from '../../components/BarcodeScanner';

export function OutboundExecutionPage() {
  return (
    <div className="space-y-4">
      <Card>
        <h2 className="text-xl font-semibold">Pick Task Execution</h2>
        <BarcodeScanner onDetected={(code) => console.log('pick scan', code)} />
        <div className="mt-3 grid gap-2 sm:grid-cols-3">
          <input placeholder="Task / Order" />
          <input placeholder="Location" />
          <input placeholder="Item" />
          <input type="number" placeholder="Qty picked" />
          <select><option>Exception</option><option>SHORT_PICK</option></select>
        </div>
        <button className="mt-3">Confirm pick</button>
      </Card>
      <Card>
        <h3 className="font-semibold">Pack & Ship</h3>
        <div className="mt-2 grid gap-2 sm:grid-cols-3">
          <input placeholder="Pack session" />
          <input placeholder="Carton / Tracking" />
          <select><option>Carrier</option><option>UPS Ground</option></select>
        </div>
        <button className="mt-3">Close shipment</button>
      </Card>
    </div>
  );
}
