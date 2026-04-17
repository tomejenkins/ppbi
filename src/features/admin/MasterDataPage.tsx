import { Card } from '../../components/Card';

const modules = [
  'Facilities',
  'Users and roles',
  'Labor codes',
  'Locations',
  'Items and barcodes',
  'Suppliers and customers',
  'Carriers',
  'Reason codes',
  'QC templates',
  'System settings'
];

export function MasterDataPage() {
  return (
    <Card>
      <h2 className="text-xl font-semibold">Admin Configuration</h2>
      <ul className="mt-4 grid gap-2 sm:grid-cols-2">
        {modules.map((module) => (
          <li key={module} className="rounded border border-slate-200 bg-slate-50 px-3 py-2 text-sm">
            {module}
          </li>
        ))}
      </ul>
    </Card>
  );
}
