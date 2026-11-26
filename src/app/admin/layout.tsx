import { redirect } from 'next/navigation';
import { Sidebar } from '@/components/admin/Sidebar';
import { Topbar } from '@/components/admin/Topbar';
import { ToastProvider } from '@/components/admin/toast';
import { createSupabaseServerClient } from '@/lib/supabase/server';

export default async function AdminLayout({ children }: { children: React.ReactNode }) {
  const supabase = await createSupabaseServerClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  return (
    <ToastProvider>
      <div className="flex min-h-screen">
        <Sidebar />
        <div className="flex min-w-0 flex-1 flex-col">
          <Topbar />
          <main className="flex-1 px-6 py-6 md:px-8 md:py-8">{children}</main>
        </div>
      </div>
    </ToastProvider>
  );
}
