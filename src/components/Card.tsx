import { PropsWithChildren } from 'react';

export function Card({ children }: PropsWithChildren) {
  return <section className="rounded-lg bg-white p-4 shadow-sm">{children}</section>;
}
