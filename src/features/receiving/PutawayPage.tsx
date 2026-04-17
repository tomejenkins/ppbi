import { Card } from '../../components/Card';
import { BarcodeScanner } from '../../components/BarcodeScanner';
import { useState } from 'react';

export function PutawayPage() {
  const [location, setLocation] = useState('');

  return (
    <Card>
      <h2 className="text-xl font-semibold">Putaway Execution</h2>
      <p className="mb-3 text-sm text-slate-600">System suggestion: A-01-03-02. Scan destination location barcode to confirm.</p>
      <BarcodeScanner onDetected={setLocation} />
      <input className="mt-3 w-full" placeholder="Destination location" value={location} onChange={(e) => setLocation(e.target.value)} />
      <button className="mt-3 w-full">Move from staging to storage</button>
    </Card>
  );
}
