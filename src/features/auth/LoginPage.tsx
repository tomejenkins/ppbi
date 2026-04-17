import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';
import { supabase, supabaseConfigError } from '../../lib/supabase';
import { Card } from '../../components/Card';

const schema = z.object({
  email: z.string().email(),
  password: z.string().min(8)
});

type FormValues = z.infer<typeof schema>;

export function LoginPage() {
  const [message, setMessage] = useState(supabaseConfigError ?? '');
  const { register, handleSubmit } = useForm<FormValues>({ resolver: zodResolver(schema) });

  const onSubmit = async (data: FormValues) => {
    if (!supabase) {
      setMessage(supabaseConfigError ?? 'Supabase is not configured.');
      return;
    }
    const { error } = await supabase.auth.signInWithPassword(data);
    setMessage(error ? error.message : 'Login successful.');
  };

  return (
    <div className="mx-auto mt-20 max-w-md">
      <Card>
        <h2 className="mb-4 text-lg font-semibold">Sign in to Force WMS</h2>
        <form className="space-y-3" onSubmit={handleSubmit(onSubmit)}>
          <input placeholder="Email" {...register('email')} />
          <input placeholder="Password" type="password" {...register('password')} />
          <button type="submit" className="w-full" disabled={!supabase}>
            Sign in
          </button>
          {message ? <p className="text-sm text-slate-700">{message}</p> : null}
        </form>
      </Card>
    </div>
  );
}
