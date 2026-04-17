import { useForm } from 'react-hook-form';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';
import { Card } from '../../components/Card';

const schema = z.object({
  order_number: z.string().min(3),
  supplier_id: z.string().uuid().or(z.literal('demo-supplier')),
  expected_date: z.string(),
  reference: z.string().optional()
});

type FormValues = z.infer<typeof schema>;

export function ReceivingOrdersPage() {
  const { register, handleSubmit, reset } = useForm<FormValues>({
    resolver: zodResolver(schema),
    defaultValues: { supplier_id: 'demo-supplier' }
  });

  const onSubmit = (values: FormValues) => {
    console.log('Create receiving order', values);
    reset();
  };

  return (
    <Card>
      <h2 className="mb-4 text-xl font-semibold">Create Receiving Order</h2>
      <form className="grid gap-3 sm:grid-cols-2" onSubmit={handleSubmit(onSubmit)}>
        <input placeholder="RO Number" {...register('order_number')} />
        <input type="date" {...register('expected_date')} />
        <input placeholder="Supplier ID" {...register('supplier_id')} />
        <input placeholder="Reference" {...register('reference')} />
        <button className="sm:col-span-2" type="submit">Save receiving order</button>
      </form>
    </Card>
  );
}
