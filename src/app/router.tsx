import { Navigate, Route, Routes } from 'react-router-dom';
import { Layout } from '../components/Layout';
import { LoginPage } from '../features/auth/LoginPage';
import { DashboardPage } from '../features/dashboard/DashboardPage';
import { MasterDataPage } from '../features/admin/MasterDataPage';
import { InventoryAdjustmentsPage } from '../features/inventory/InventoryAdjustmentsPage';
import { InventoryInquiryPage } from '../features/inventory/InventoryInquiryPage';
import { OutboundExecutionPage } from '../features/outbound/OutboundExecutionPage';
import { OutboundOrdersPage } from '../features/outbound/OutboundOrdersPage';
import { QcQueuePage } from '../features/qc/QcQueuePage';
import { PutawayPage } from '../features/receiving/PutawayPage';
import { ReceivingExecutionPage } from '../features/receiving/ReceivingExecutionPage';
import { ReceivingOrdersPage } from '../features/receiving/ReceivingOrdersPage';
import { TimeClockPage } from '../features/time/TimeClockPage';

export function AppRouter() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route path="/" element={<Layout />}>
        <Route index element={<DashboardPage />} />
        <Route path="receiving/orders" element={<ReceivingOrdersPage />} />
        <Route path="receiving/execute" element={<ReceivingExecutionPage />} />
        <Route path="receiving/putaway" element={<PutawayPage />} />
        <Route path="inventory/inquiry" element={<InventoryInquiryPage />} />
        <Route path="inventory/adjustments" element={<InventoryAdjustmentsPage />} />
        <Route path="qc/queue" element={<QcQueuePage />} />
        <Route path="outbound/orders" element={<OutboundOrdersPage />} />
        <Route path="outbound/execution" element={<OutboundExecutionPage />} />
        <Route path="time/clock" element={<TimeClockPage />} />
        <Route path="admin/master-data" element={<MasterDataPage />} />
      </Route>
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}
