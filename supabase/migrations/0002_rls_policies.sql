create or replace function public.can_write()
returns boolean language sql stable as $$
  select public.has_role('admin')
    or public.has_role('operations_manager')
    or public.has_role('supervisor')
    or public.has_role('receiver')
    or public.has_role('inventory_control')
    or public.has_role('quality_control')
    or public.has_role('picker_packer')
    or public.has_role('shipper')
    or public.has_role('associate');
$$;

create or replace function public.can_read()
returns boolean language sql stable as $$
  select public.can_write() or public.has_role('auditor_readonly');
$$;

create or replace function public.audit_event(event_type text, payload jsonb)
returns void language plpgsql security definer as $$
begin
  insert into public.audit_log (facility_id, event_type, event_payload, actor_id)
  values (public.current_user_facility_id(), event_type, payload, auth.uid());
end;
$$;

alter table public.facilities enable row level security;
alter table public.roles enable row level security;
alter table public.user_profiles enable row level security;
alter table public.user_roles enable row level security;
alter table public.associates enable row level security;
alter table public.uoms enable row level security;
alter table public.suppliers enable row level security;
alter table public.customers enable row level security;
alter table public.items enable row level security;
alter table public.item_barcodes enable row level security;
alter table public.locations enable row level security;
alter table public.location_barcodes enable row level security;
alter table public.lots enable row level security;
alter table public.serial_numbers enable row level security;
alter table public.reason_codes enable row level security;
alter table public.status_codes enable row level security;
alter table public.inventory_balances enable row level security;
alter table public.inventory_transactions enable row level security;
alter table public.inventory_adjustments enable row level security;
alter table public.receiving_orders enable row level security;
alter table public.expected_receipts enable row level security;
alter table public.receipts enable row level security;
alter table public.receipt_lines enable row level security;
alter table public.qc_inspections enable row level security;
alter table public.qc_dispositions enable row level security;
alter table public.outbound_orders enable row level security;
alter table public.outbound_order_lines enable row level security;
alter table public.pick_waves enable row level security;
alter table public.pick_tasks enable row level security;
alter table public.pick_task_lines enable row level security;
alter table public.pack_sessions enable row level security;
alter table public.carriers enable row level security;
alter table public.shipments enable row level security;
alter table public.shipment_lines enable row level security;
alter table public.loads enable row level security;
alter table public.attachments enable row level security;
alter table public.labor_codes enable row level security;
alter table public.time_clock_entries enable row level security;
alter table public.labor_activity_entries enable row level security;
alter table public.cycle_count_headers enable row level security;
alter table public.cycle_count_lines enable row level security;
alter table public.audit_log enable row level security;

create policy facility_read on public.user_profiles for select using (id = auth.uid() or public.has_role('admin'));
create policy facility_update on public.user_profiles for update using (id = auth.uid() or public.has_role('admin'));

create policy profile_roles_read on public.user_roles for select using (user_id = auth.uid() or public.has_role('admin'));
create policy profile_roles_write on public.user_roles for all using (public.has_role('admin')) with check (public.has_role('admin'));

create policy facilities_read on public.facilities for select using (public.can_read());
create policy facilities_write on public.facilities for all using (public.has_role('admin')) with check (public.has_role('admin'));
create policy roles_read on public.roles for select using (public.can_read());
create policy roles_write on public.roles for all using (public.has_role('admin')) with check (public.has_role('admin'));

create policy uoms_access on public.uoms for all using (public.can_read()) with check (public.has_role('admin'));
create policy status_codes_read on public.status_codes for select using (public.can_read());
create policy status_codes_write on public.status_codes for all using (public.has_role('admin')) with check (public.has_role('admin'));

-- facility-scoped operational tables.
create policy assoc_access on public.associates for all using (facility_id = public.current_user_facility_id() and public.can_read()) with check (facility_id = public.current_user_facility_id() and public.can_write());
create policy suppliers_access on public.suppliers for all using (facility_id = public.current_user_facility_id() and public.can_read()) with check (facility_id = public.current_user_facility_id() and public.can_write());
create policy customers_access on public.customers for all using (facility_id = public.current_user_facility_id() and public.can_read()) with check (facility_id = public.current_user_facility_id() and public.can_write());
create policy items_access on public.items for all using (facility_id = public.current_user_facility_id() and public.can_read()) with check (facility_id = public.current_user_facility_id() and public.can_write());
create policy item_barcodes_access on public.item_barcodes for all using (facility_id = public.current_user_facility_id() and public.can_read()) with check (facility_id = public.current_user_facility_id() and public.can_write());
create policy locations_access on public.locations for all using (facility_id = public.current_user_facility_id() and public.can_read()) with check (facility_id = public.current_user_facility_id() and public.can_write());
create policy location_barcodes_access on public.location_barcodes for all using (facility_id = public.current_user_facility_id() and public.can_read()) with check (facility_id = public.current_user_facility_id() and public.can_write());
create policy lots_access on public.lots for all using (facility_id = public.current_user_facility_id() and public.can_read()) with check (facility_id = public.current_user_facility_id() and public.can_write());
create policy serial_numbers_access on public.serial_numbers for all using (facility_id = public.current_user_facility_id() and public.can_read()) with check (facility_id = public.current_user_facility_id() and public.can_write());
create policy reason_codes_access on public.reason_codes for all using (facility_id = public.current_user_facility_id() and public.can_read()) with check (facility_id = public.current_user_facility_id() and public.can_write());
create policy inv_bal_access on public.inventory_balances for all using (facility_id = public.current_user_facility_id() and public.can_read()) with check (facility_id = public.current_user_facility_id() and public.can_write());
create policy inv_txn_access on public.inventory_transactions for all using (facility_id = public.current_user_facility_id() and public.can_read()) with check (facility_id = public.current_user_facility_id() and public.can_write());
create policy inv_adj_access on public.inventory_adjustments for all using (facility_id = public.current_user_facility_id() and public.can_read()) with check (facility_id = public.current_user_facility_id() and (public.has_role('inventory_control') or public.has_role('admin') or public.has_role('supervisor')));
create policy recv_orders_access on public.receiving_orders for all using (facility_id = public.current_user_facility_id() and public.can_read()) with check (facility_id = public.current_user_facility_id() and public.can_write());
create policy expected_receipts_access on public.expected_receipts for all using (facility_id = public.current_user_facility_id() and public.can_read()) with check (facility_id = public.current_user_facility_id() and public.can_write());
create policy receipts_access on public.receipts for all using (facility_id = public.current_user_facility_id() and public.can_read()) with check (facility_id = public.current_user_facility_id() and public.can_write());
create policy receipt_lines_access on public.receipt_lines for all using (facility_id = public.current_user_facility_id() and public.can_read()) with check (facility_id = public.current_user_facility_id() and public.can_write());
create policy qc_insp_access on public.qc_inspections for all using (facility_id = public.current_user_facility_id() and public.can_read()) with check (facility_id = public.current_user_facility_id() and (public.has_role('quality_control') or public.has_role('admin') or public.has_role('supervisor')));
create policy qc_disp_access on public.qc_dispositions for all using (facility_id = public.current_user_facility_id() and public.can_read()) with check (facility_id = public.current_user_facility_id() and (public.has_role('quality_control') or public.has_role('admin') or public.has_role('supervisor')));
create policy outbound_orders_access on public.outbound_orders for all using (facility_id = public.current_user_facility_id() and public.can_read()) with check (facility_id = public.current_user_facility_id() and public.can_write());
create policy outbound_lines_access on public.outbound_order_lines for all using (facility_id = public.current_user_facility_id() and public.can_read()) with check (facility_id = public.current_user_facility_id() and public.can_write());
create policy pick_waves_access on public.pick_waves for all using (facility_id = public.current_user_facility_id() and public.can_read()) with check (facility_id = public.current_user_facility_id() and public.can_write());
create policy pick_tasks_access on public.pick_tasks for all using (facility_id = public.current_user_facility_id() and public.can_read()) with check (facility_id = public.current_user_facility_id() and public.can_write());
create policy pick_task_lines_access on public.pick_task_lines for all using (facility_id = public.current_user_facility_id() and public.can_read()) with check (facility_id = public.current_user_facility_id() and public.can_write());
create policy pack_sessions_access on public.pack_sessions for all using (facility_id = public.current_user_facility_id() and public.can_read()) with check (facility_id = public.current_user_facility_id() and public.can_write());
create policy carriers_access on public.carriers for all using (facility_id = public.current_user_facility_id() and public.can_read()) with check (facility_id = public.current_user_facility_id() and public.can_write());
create policy shipments_access on public.shipments for all using (facility_id = public.current_user_facility_id() and public.can_read()) with check (facility_id = public.current_user_facility_id() and public.can_write());
create policy shipment_lines_access on public.shipment_lines for all using (facility_id = public.current_user_facility_id() and public.can_read()) with check (facility_id = public.current_user_facility_id() and public.can_write());
create policy loads_access on public.loads for all using (facility_id = public.current_user_facility_id() and public.can_read()) with check (facility_id = public.current_user_facility_id() and public.can_write());
create policy attachments_access on public.attachments for all using (facility_id = public.current_user_facility_id() and public.can_read()) with check (facility_id = public.current_user_facility_id() and public.can_write());
create policy labor_codes_access on public.labor_codes for all using (facility_id = public.current_user_facility_id() and public.can_read()) with check (facility_id = public.current_user_facility_id() and public.can_write());
create policy time_clock_access on public.time_clock_entries for all using (facility_id = public.current_user_facility_id() and public.can_read()) with check (facility_id = public.current_user_facility_id() and public.can_write());
create policy labor_activity_access on public.labor_activity_entries for all using (facility_id = public.current_user_facility_id() and public.can_read()) with check (facility_id = public.current_user_facility_id() and public.can_write());
create policy count_headers_access on public.cycle_count_headers for all using (facility_id = public.current_user_facility_id() and public.can_read()) with check (facility_id = public.current_user_facility_id() and public.can_write());
create policy count_lines_access on public.cycle_count_lines for all using (facility_id = public.current_user_facility_id() and public.can_read()) with check (facility_id = public.current_user_facility_id() and public.can_write());
create policy audit_log_access on public.audit_log for select using (facility_id = public.current_user_facility_id() and (public.has_role('admin') or public.has_role('auditor_readonly')));
