insert into public.facilities (id, code, name, timezone)
values ('11111111-1111-1111-1111-111111111111', 'DAL1', 'Dallas Main DC', 'America/Chicago');

insert into public.roles (code, name) values
  ('admin', 'Admin'),
  ('operations_manager', 'Operations Manager'),
  ('supervisor', 'Supervisor'),
  ('receiver', 'Receiver'),
  ('inventory_control', 'Inventory Control'),
  ('quality_control', 'Quality Control'),
  ('picker_packer', 'Picker/Packer'),
  ('shipper', 'Shipper'),
  ('associate', 'Associate'),
  ('auditor_readonly', 'Read-only Auditor');

insert into public.uoms (code, name) values ('EA', 'Each'), ('CS', 'Case');

insert into public.suppliers (facility_id, supplier_code, name, qc_required_default)
values
  ('11111111-1111-1111-1111-111111111111', 'SUP-ACME', 'ACME Industrial', true),
  ('11111111-1111-1111-1111-111111111111', 'SUP-ORB', 'Orbit Tools', false);

insert into public.customers (facility_id, customer_code, name)
values
  ('11111111-1111-1111-1111-111111111111', 'CUST-ALPHA', 'Alpha Retail'),
  ('11111111-1111-1111-1111-111111111111', 'CUST-BETA', 'Beta Stores');

insert into public.locations (facility_id, location_code, zone, location_type, is_pickable)
values
  ('11111111-1111-1111-1111-111111111111', 'DOCK-A-01', 'DOCK', 'staging', false),
  ('11111111-1111-1111-1111-111111111111', 'A-01-01-01', 'A', 'storage', true),
  ('11111111-1111-1111-1111-111111111111', 'A-01-03-02', 'A', 'storage', true),
  ('11111111-1111-1111-1111-111111111111', 'HOLD-01', 'HOLD', 'quarantine', false);

insert into public.items (facility_id, sku, description, abc_class, lot_controlled, serial_controlled, qc_required)
values
  ('11111111-1111-1111-1111-111111111111', 'SKU-1001', 'Industrial Fastener Pack', 'A', true, false, true),
  ('11111111-1111-1111-1111-111111111111', 'SKU-2002', 'Cordless Driver Kit', 'A', false, true, false),
  ('11111111-1111-1111-1111-111111111111', 'SKU-3003', 'Safety Gloves Large', 'C', false, false, false);

insert into public.reason_codes (facility_id, code, reason_type, description)
values
  ('11111111-1111-1111-1111-111111111111', 'OVERAGE', 'receipt_mismatch', 'Received quantity over expected'),
  ('11111111-1111-1111-1111-111111111111', 'SHORTAGE', 'receipt_mismatch', 'Received quantity below expected'),
  ('11111111-1111-1111-1111-111111111111', 'DAMAGE', 'adjustment', 'Damaged goods'),
  ('11111111-1111-1111-1111-111111111111', 'COUNT_VAR', 'cycle_count', 'Cycle count variance');

insert into public.labor_codes (facility_id, code, description, is_direct)
values
  ('11111111-1111-1111-1111-111111111111', 'receiving', 'Receiving execution', true),
  ('11111111-1111-1111-1111-111111111111', 'putaway', 'Putaway operations', true),
  ('11111111-1111-1111-1111-111111111111', 'picking', 'Order picking', true),
  ('11111111-1111-1111-1111-111111111111', 'training', 'Training and meetings', false);

insert into public.carriers (facility_id, code, name)
values
  ('11111111-1111-1111-1111-111111111111', 'UPS', 'UPS'),
  ('11111111-1111-1111-1111-111111111111', 'FDX', 'FedEx');
