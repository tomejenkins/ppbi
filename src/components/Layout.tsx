import { Link, Outlet } from 'react-router-dom';

const links = [
  ['Dashboard', '/'],
  ['Receiving', '/receiving/orders'],
  ['Mobile Receive', '/receiving/execute'],
  ['Putaway', '/receiving/putaway'],
  ['Inventory', '/inventory/inquiry'],
  ['Adjustments', '/inventory/adjustments'],
  ['QC', '/qc/queue'],
  ['Outbound', '/outbound/orders'],
  ['Pick/Pack/Ship', '/outbound/execution'],
  ['Time', '/time/clock'],
  ['Admin', '/admin/master-data']
];

export function Layout() {
  return (
    <div className="min-h-screen bg-slate-100">
      <header className="sticky top-0 z-10 bg-slate-900 p-3 text-white">
        <h1 className="text-lg font-semibold">Forge WMS MVP</h1>
      </header>
      <nav className="overflow-x-auto bg-white px-2 py-2 shadow">
        <ul className="flex min-w-max gap-2">
          {links.map(([name, path]) => (
            <li key={path}>
              <Link className="rounded bg-slate-200 px-3 py-2 text-sm font-medium text-slate-800" to={path}>
                {name}
              </Link>
            </li>
          ))}
        </ul>
      </nav>
      <main className="mx-auto max-w-7xl p-4">
        <Outlet />
      </main>
    </div>
  );
}
