import { Card } from '../../components/Card';

export function TimeClockPage() {
  return (
    <div className="space-y-4">
      <Card>
        <h2 className="text-xl font-semibold">Time Clock</h2>
        <div className="grid gap-2 sm:grid-cols-3">
          <button>Clock In</button>
          <button>Meal Start</button>
          <button>Meal End</button>
          <button>Break Start</button>
          <button>Break End</button>
          <button>Clock Out</button>
        </div>
      </Card>
      <Card>
        <h3 className="font-semibold">Coded Labor</h3>
        <div className="mt-2 grid gap-2 sm:grid-cols-3">
          <select>
            <option>Labor code</option>
            <option>receiving</option>
            <option>putaway</option>
            <option>picking</option>
            <option>packing</option>
            <option>shipping</option>
          </select>
          <button>Start Activity</button>
          <button>Stop Activity</button>
        </div>
      </Card>
    </div>
  );
}
