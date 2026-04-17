# Forge WMS MVP

## 1) Architecture Summary
Forge WMS is a mobile-first, production-minded MVP for warehouse execution. The frontend is a React + Vite + TypeScript single-page app with React Router, TanStack Query, React Hook Form, and Zod validation. Supabase provides Auth, Postgres, RLS, Storage, Realtime, and Edge Functions. Inventory is strictly transaction-based: all balance changes are performed through `post_inventory_transaction`; direct balance edits are prohibited.

### Core architectural decisions
- **Facility-scoped, role-based access** with Supabase RLS and `facility_id` on operational tables.
- **Immutable inventory ledger** in `inventory_transactions`; `inventory_balances` is maintained transactionally.
- **Mobile scan-first UX** with camera barcode support using `BarcodeDetector`, fallback to ZXing.
- **Edge functions for privileged operations**: inventory posting and shipment close.
- **PWA shell + offline queue** for short connectivity drops.

## 2) Database Schema
Migrations are in `supabase/migrations`:
- `0001_init_schema.sql`: normalized domain tables for facilities, auth mapping, receiving, QC, inventory, cycle count, outbound, shipping, labor, audit.
- `0002_rls_policies.sql`: RLS enablement for operational tables + sample role/facility policies.
- `0003_seed.sql`: demo facility/master data.
- `0004_business_functions.sql`: transaction-safe business functions.

## 3) RLS Strategy
- `current_user_facility_id()` maps authenticated users to one facility.
- `has_role(role_code)` checks assigned role in `user_roles`.
- `can_read()` includes all active roles + auditor.
- `can_write()` includes operational roles.
- Facility-scoped tables enforce `facility_id = current_user_facility_id()` for read and write.
- Admin-only write policies for setup tables (roles, status codes, facilities).

## 4) Project File Tree

```txt
.
├── src/
│   ├── app/router.tsx
│   ├── components/{Layout,Card,BarcodeScanner}.tsx
│   ├── features/
│   │   ├── auth/LoginPage.tsx
│   │   ├── dashboard/DashboardPage.tsx
│   │   ├── receiving/{ReceivingOrdersPage,ReceivingExecutionPage,PutawayPage}.tsx
│   │   ├── inventory/{InventoryInquiryPage,InventoryAdjustmentsPage}.tsx
│   │   ├── qc/QcQueuePage.tsx
│   │   ├── outbound/{OutboundOrdersPage,OutboundExecutionPage}.tsx
│   │   ├── time/TimeClockPage.tsx
│   │   └── admin/MasterDataPage.tsx
│   ├── lib/{supabase,pwa,offlineQueue}.ts
│   ├── main.tsx
│   └── styles/index.css
├── public/{manifest.webmanifest,sw.js,icon-app.svg,icon-maskable.svg}
├── supabase/
│   ├── migrations/{0001_init_schema,0002_rls_policies,0003_seed,0004_business_functions}.sql
│   └── functions/{inventory_transaction,shipment_close}/index.ts
├── .env.example
├── wrangler.toml
└── README.md
```

## 5) Migrations and Supabase Setup
1. Create Supabase project.
2. Run SQL migrations in order using Supabase CLI or dashboard SQL editor.
3. Create users in Supabase Auth, then insert linked `user_profiles` and `user_roles` rows.
4. Deploy Edge Functions:
   - `supabase functions deploy inventory_transaction`
   - `supabase functions deploy shipment_close`

## 6) Frontend and Backend MVP Coverage
Implemented initial release scope screens and wiring:
- auth + role-ready Supabase client
- receiving order creation
- mobile receiving execution + scanner
- putaway confirmation
- inventory inquiry + adjustment request entry
- QC queue + disposition action UI
- outbound order creation
- pick/pack/ship execution UI
- time clock + coded labor controls
- operations dashboard

## Cloudflare Pages deployment
1. Build command: `npm run build`
2. Output dir: `dist`
3. Add env vars from `.env.example` in Cloudflare Pages project settings.
4. Use `wrangler.toml` in repo root for Pages config.

## Security notes
- Never expose service role keys in frontend env.
- Keep service-role usage only in Supabase Edge Functions.
- Use `post_inventory_transaction()` and `close_shipment()` for inventory-affecting flows.
- Audit critical events with `audit_event()`.

## Future enhancements
- Full API data layer with typed repositories and TanStack Query hooks per module.
- Robust session/role guard routes and permission-aware menu rendering.
- Wave/zone/batch picking engine and replenishment orchestration.
- Advanced cartonization and carrier label integrations.
- Full QC template builder + dynamic checklists.
- Rich dashboards with drill-down charts and CSV exports.
- Conflict-safe offline sync with retry/backoff and idempotency keys.
- E2E tests (Playwright) and db integration tests for business functions.
