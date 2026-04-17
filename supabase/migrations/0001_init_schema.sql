create extension if not exists pgcrypto;

create type public.inventory_status as enum ('available', 'hold', 'quarantine', 'damaged', 'allocated', 'shipped');
create type public.order_status as enum ('draft', 'released', 'in_progress', 'packed', 'shipped', 'cancelled');
create type public.qc_result as enum ('pass', 'fail', 'conditional_pass');
create type public.time_event_type as enum ('clock_in', 'clock_out', 'meal_start', 'meal_end', 'break_start', 'break_end');

create table public.facilities (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,
  name text not null,
  timezone text not null default 'America/Chicago',
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.roles (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,
  name text not null
);

create table public.user_profiles (
  id uuid primary key references auth.users(id),
  facility_id uuid not null references public.facilities(id),
  employee_code text unique,
  full_name text not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.user_roles (
  user_id uuid not null references public.user_profiles(id),
  role_id uuid not null references public.roles(id),
  facility_id uuid not null references public.facilities(id),
  primary key (user_id, role_id, facility_id)
);

create table public.associates (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities(id),
  profile_id uuid references public.user_profiles(id),
  badge_code text unique,
  status text not null default 'active'
);

create table public.uoms (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,
  name text not null
);

create table public.suppliers (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities(id),
  supplier_code text not null,
  name text not null,
  qc_required_default boolean not null default false,
  unique (facility_id, supplier_code)
);

create table public.customers (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities(id),
  customer_code text not null,
  name text not null,
  unique (facility_id, customer_code)
);

create table public.items (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities(id),
  sku text not null,
  description text not null,
  base_uom_id uuid references public.uoms(id),
  abc_class text not null default 'B',
  lot_controlled boolean not null default false,
  serial_controlled boolean not null default false,
  allow_substitution boolean not null default false,
  qc_required boolean not null default false,
  is_active boolean not null default true,
  unique (facility_id, sku)
);

create table public.item_barcodes (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities(id),
  item_id uuid not null references public.items(id),
  barcode text not null,
  is_primary boolean not null default false,
  unique (facility_id, barcode)
);

create table public.locations (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities(id),
  location_code text not null,
  zone text,
  location_type text not null default 'storage',
  is_pickable boolean not null default true,
  is_active boolean not null default true,
  unique (facility_id, location_code)
);

create table public.location_barcodes (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities(id),
  location_id uuid not null references public.locations(id),
  barcode text not null,
  unique (facility_id, barcode)
);

create table public.lots (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities(id),
  item_id uuid not null references public.items(id),
  lot_number text not null,
  expiration_date date,
  unique (facility_id, item_id, lot_number)
);

create table public.serial_numbers (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities(id),
  item_id uuid not null references public.items(id),
  serial_number text not null,
  status text not null default 'available',
  unique (facility_id, serial_number)
);

create table public.reason_codes (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities(id),
  code text not null,
  reason_type text not null,
  description text not null,
  unique (facility_id, code, reason_type)
);

create table public.status_codes (
  id uuid primary key default gen_random_uuid(),
  domain text not null,
  code text not null,
  label text not null,
  unique (domain, code)
);

create table public.inventory_balances (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities(id),
  item_id uuid not null references public.items(id),
  location_id uuid not null references public.locations(id),
  lot_id uuid references public.lots(id),
  serial_id uuid references public.serial_numbers(id),
  status public.inventory_status not null default 'available',
  quantity numeric(14,3) not null default 0,
  version int not null default 1
);

create unique index inventory_balances_unique_dim_idx
  on public.inventory_balances (
    facility_id,
    item_id,
    location_id,
    coalesce(lot_id, '00000000-0000-0000-0000-000000000000'::uuid),
    coalesce(serial_id, '00000000-0000-0000-0000-000000000000'::uuid),
    status
  );

create table public.inventory_transactions (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities(id),
  txn_type text not null,
  item_id uuid not null references public.items(id),
  from_location_id uuid references public.locations(id),
  to_location_id uuid references public.locations(id),
  lot_id uuid references public.lots(id),
  serial_id uuid references public.serial_numbers(id),
  quantity numeric(14,3) not null,
  status_from public.inventory_status,
  status_to public.inventory_status,
  source_doc_type text,
  source_doc_id uuid,
  reason_code_id uuid references public.reason_codes(id),
  performed_by uuid references public.user_profiles(id),
  created_at timestamptz not null default now()
);

create table public.inventory_adjustments (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities(id),
  item_id uuid not null references public.items(id),
  location_id uuid not null references public.locations(id),
  quantity_delta numeric(14,3) not null,
  reason_code_id uuid not null references public.reason_codes(id),
  notes text,
  requested_by uuid not null references public.user_profiles(id),
  approved_by uuid references public.user_profiles(id),
  status text not null default 'pending',
  created_at timestamptz not null default now(),
  approved_at timestamptz
);

create table public.receiving_orders (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities(id),
  supplier_id uuid not null references public.suppliers(id),
  order_number text not null,
  expected_date date,
  status text not null default 'open',
  created_by uuid references public.user_profiles(id),
  unique (facility_id, order_number)
);

create table public.expected_receipts (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities(id),
  receiving_order_id uuid not null references public.receiving_orders(id),
  item_id uuid not null references public.items(id),
  expected_qty numeric(14,3) not null,
  qc_required boolean not null default false
);

create table public.receipts (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities(id),
  receiving_order_id uuid not null references public.receiving_orders(id),
  receipt_number text not null,
  status text not null default 'open',
  created_by uuid not null references public.user_profiles(id),
  created_at timestamptz not null default now(),
  unique (facility_id, receipt_number)
);

create table public.receipt_lines (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities(id),
  receipt_id uuid not null references public.receipts(id),
  item_id uuid not null references public.items(id),
  location_id uuid not null references public.locations(id),
  received_qty numeric(14,3) not null,
  lot_id uuid references public.lots(id),
  serial_id uuid references public.serial_numbers(id),
  qc_required boolean not null default false,
  mismatch_reason_code_id uuid references public.reason_codes(id)
);

create table public.qc_inspections (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities(id),
  receipt_line_id uuid not null references public.receipt_lines(id),
  checklist_template text,
  result public.qc_result,
  inspected_by uuid references public.user_profiles(id),
  inspected_at timestamptz,
  notes text
);

create table public.qc_dispositions (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities(id),
  qc_inspection_id uuid not null references public.qc_inspections(id),
  disposition text not null,
  reason_code_id uuid references public.reason_codes(id),
  performed_by uuid not null references public.user_profiles(id),
  created_at timestamptz not null default now()
);

create table public.outbound_orders (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities(id),
  customer_id uuid not null references public.customers(id),
  order_number text not null,
  status public.order_status not null default 'draft',
  ship_by_date date,
  created_by uuid references public.user_profiles(id),
  unique (facility_id, order_number)
);

create table public.outbound_order_lines (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities(id),
  outbound_order_id uuid not null references public.outbound_orders(id),
  item_id uuid not null references public.items(id),
  ordered_qty numeric(14,3) not null,
  allocated_qty numeric(14,3) not null default 0,
  picked_qty numeric(14,3) not null default 0,
  packed_qty numeric(14,3) not null default 0,
  shipped_qty numeric(14,3) not null default 0,
  line_status text not null default 'open'
);

create table public.pick_waves (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities(id),
  wave_number text not null,
  status text not null default 'released',
  unique (facility_id, wave_number)
);

create table public.pick_tasks (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities(id),
  outbound_order_id uuid not null references public.outbound_orders(id),
  pick_wave_id uuid references public.pick_waves(id),
  task_number text not null,
  status text not null default 'released',
  assigned_to uuid references public.user_profiles(id),
  unique (facility_id, task_number)
);

create table public.pick_task_lines (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities(id),
  pick_task_id uuid not null references public.pick_tasks(id),
  outbound_order_line_id uuid not null references public.outbound_order_lines(id),
  from_location_id uuid not null references public.locations(id),
  item_id uuid not null references public.items(id),
  requested_qty numeric(14,3) not null,
  picked_qty numeric(14,3) not null default 0,
  exception_code text
);

create table public.pack_sessions (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities(id),
  outbound_order_id uuid not null references public.outbound_orders(id),
  session_number text not null,
  packed_by uuid references public.user_profiles(id),
  packed_at timestamptz,
  unique (facility_id, session_number)
);

create table public.carriers (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities(id),
  code text not null,
  name text not null,
  unique (facility_id, code)
);

create table public.shipments (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities(id),
  outbound_order_id uuid not null references public.outbound_orders(id),
  shipment_number text not null,
  carrier_id uuid references public.carriers(id),
  service_level text,
  status text not null default 'packed',
  shipped_at timestamptz,
  shipped_by uuid references public.user_profiles(id),
  unique (facility_id, shipment_number)
);

create table public.shipment_lines (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities(id),
  shipment_id uuid not null references public.shipments(id),
  outbound_order_line_id uuid not null references public.outbound_order_lines(id),
  item_id uuid not null references public.items(id),
  shipped_qty numeric(14,3) not null
);

create table public.loads (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities(id),
  load_number text not null,
  trailer_number text,
  status text not null default 'open',
  unique (facility_id, load_number)
);

create table public.attachments (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities(id),
  entity_type text not null,
  entity_id uuid not null,
  file_path text not null,
  uploaded_by uuid references public.user_profiles(id),
  created_at timestamptz not null default now()
);

create table public.labor_codes (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities(id),
  code text not null,
  description text not null,
  is_direct boolean not null default true,
  unique (facility_id, code)
);

create table public.time_clock_entries (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities(id),
  associate_id uuid not null references public.associates(id),
  event_type public.time_event_type not null,
  event_at timestamptz not null default now(),
  created_by uuid references public.user_profiles(id)
);

create table public.labor_activity_entries (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities(id),
  associate_id uuid not null references public.associates(id),
  labor_code_id uuid not null references public.labor_codes(id),
  started_at timestamptz not null default now(),
  ended_at timestamptz,
  reference_type text,
  reference_id uuid
);

create table public.cycle_count_headers (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities(id),
  count_number text not null,
  status text not null default 'released',
  blind_count boolean not null default true,
  created_by uuid references public.user_profiles(id),
  unique (facility_id, count_number)
);

create table public.cycle_count_lines (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities(id),
  cycle_count_header_id uuid not null references public.cycle_count_headers(id),
  item_id uuid not null references public.items(id),
  location_id uuid not null references public.locations(id),
  system_qty numeric(14,3) not null,
  counted_qty numeric(14,3),
  variance_qty numeric(14,3),
  variance_reason_code_id uuid references public.reason_codes(id),
  approved_by uuid references public.user_profiles(id)
);

create table public.audit_log (
  id bigint generated always as identity primary key,
  facility_id uuid references public.facilities(id),
  event_type text not null,
  event_payload jsonb not null,
  actor_id uuid references public.user_profiles(id),
  created_at timestamptz not null default now()
);

create or replace function public.current_user_facility_id()
returns uuid language sql stable as $$
  select facility_id from public.user_profiles where id = auth.uid();
$$;

create or replace function public.has_role(role_code text)
returns boolean language sql stable as $$
  select exists (
    select 1
    from public.user_roles ur
    join public.roles r on r.id = ur.role_id
    where ur.user_id = auth.uid() and ur.facility_id = public.current_user_facility_id() and r.code = role_code
  );
$$;
