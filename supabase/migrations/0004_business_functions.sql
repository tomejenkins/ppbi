create or replace function public.post_inventory_transaction(
  p_facility_id uuid,
  p_txn_type text,
  p_item_id uuid,
  p_from_location_id uuid,
  p_to_location_id uuid,
  p_quantity numeric,
  p_status_from public.inventory_status,
  p_status_to public.inventory_status,
  p_source_doc_type text default null,
  p_source_doc_id uuid default null,
  p_reason_code_id uuid default null,
  p_user_id uuid default auth.uid()
)
returns uuid
language plpgsql
security definer
as $$
declare
  v_txn_id uuid;
  v_current_qty numeric;
begin
  if p_quantity <= 0 then
    raise exception 'Quantity must be greater than zero';
  end if;

  if p_from_location_id is not null then
    select quantity into v_current_qty
    from public.inventory_balances
    where facility_id = p_facility_id
      and item_id = p_item_id
      and location_id = p_from_location_id
      and status = p_status_from
    for update;

    if coalesce(v_current_qty, 0) < p_quantity and not public.has_role('admin') then
      raise exception 'Negative inventory prevented';
    end if;

    update public.inventory_balances
      set quantity = quantity - p_quantity,
          version = version + 1
    where facility_id = p_facility_id
      and item_id = p_item_id
      and location_id = p_from_location_id
      and status = p_status_from;
  end if;

  if p_to_location_id is not null then
    insert into public.inventory_balances (facility_id, item_id, location_id, status, quantity)
    values (p_facility_id, p_item_id, p_to_location_id, p_status_to, p_quantity)
    on conflict (facility_id, item_id, location_id, coalesce(lot_id, '00000000-0000-0000-0000-000000000000'::uuid), coalesce(serial_id, '00000000-0000-0000-0000-000000000000'::uuid), status)
    do update set quantity = public.inventory_balances.quantity + excluded.quantity,
                  version = public.inventory_balances.version + 1;
  end if;

  insert into public.inventory_transactions (
    facility_id, txn_type, item_id, from_location_id, to_location_id, quantity,
    status_from, status_to, source_doc_type, source_doc_id, reason_code_id, performed_by
  )
  values (
    p_facility_id, p_txn_type, p_item_id, p_from_location_id, p_to_location_id, p_quantity,
    p_status_from, p_status_to, p_source_doc_type, p_source_doc_id, p_reason_code_id, p_user_id
  )
  returning id into v_txn_id;

  perform public.audit_event('inventory_transaction_posted', jsonb_build_object('transaction_id', v_txn_id));
  return v_txn_id;
end;
$$;

create or replace function public.close_shipment(p_shipment_id uuid, p_user_id uuid)
returns uuid
language plpgsql
security definer
as $$
declare
  v_shipment record;
  v_line record;
begin
  select * into v_shipment from public.shipments where id = p_shipment_id for update;
  if v_shipment.id is null then
    raise exception 'Shipment not found';
  end if;

  update public.shipments
  set status = 'shipped',
      shipped_at = now(),
      shipped_by = p_user_id
  where id = p_shipment_id;

  for v_line in
    select sl.item_id, sl.shipped_qty
    from public.shipment_lines sl
    where sl.shipment_id = p_shipment_id
  loop
    perform public.post_inventory_transaction(
      v_shipment.facility_id,
      'ship_confirm',
      v_line.item_id,
      null,
      null,
      v_line.shipped_qty,
      'allocated',
      'shipped',
      'shipment',
      p_shipment_id,
      null,
      p_user_id
    );
  end loop;

  perform public.audit_event('shipment_closed', jsonb_build_object('shipment_id', p_shipment_id));
  return p_shipment_id;
end;
$$;
