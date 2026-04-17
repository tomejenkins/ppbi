import { openDB } from 'idb';

const DB_NAME = 'force-wms-offline';

const STORE = 'queue';

export type OfflineTxn = {
  id?: number;
  endpoint: string;
  payload: Record<string, unknown>;
  createdAt: string;
};

async function getDb() {
  return openDB(DB_NAME, 1, {
    upgrade(db) {
      db.createObjectStore(STORE, { keyPath: 'id', autoIncrement: true });
    }
  });
}

export async function enqueue(txn: OfflineTxn) {
  const db = await getDb();
  await db.add(STORE, txn);
}

export async function flush(processor: (txn: OfflineTxn) => Promise<void>) {
  const db = await getDb();
  const tx = db.transaction(STORE, 'readwrite');
  const store = tx.objectStore(STORE);
  let cursor = await store.openCursor();
  while (cursor) {
    await processor(cursor.value as OfflineTxn);
    await cursor.delete();
    cursor = await cursor.continue();
  }
  await tx.done;
}
