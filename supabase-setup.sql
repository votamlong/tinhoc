-- Chạy toàn bộ file này trong Supabase: SQL Editor -> New query -> Run

create table profiles (
  id uuid primary key references auth.users on delete cascade,
  name text,
  role text not null default 'teacher' check (role in ('admin','teacher'))
);
create table kv (key text primary key, value jsonb not null default '{}');

alter table profiles enable row level security;
alter table kv enable row level security;

create function is_admin() returns boolean language sql security definer stable set search_path = public
as $$ select exists (select 1 from profiles where id = auth.uid() and role = 'admin') $$;
create function is_staff() returns boolean language sql security definer stable set search_path = public
as $$ select exists (select 1 from profiles where id = auth.uid()) $$;

-- Mỗi người chỉ đọc được hồ sơ của chính mình
create policy "doc ho so cua minh" on profiles for select using (id = auth.uid());

-- Dữ liệu: admin và giáo viên đều đọc được
create policy "nhan vien doc" on kv for select using (is_staff());
-- Admin ghi mọi thứ
create policy "admin ghi" on kv for all using (is_admin()) with check (is_admin());
-- Giáo viên chỉ ghi được điểm số và điểm danh
create policy "gv them diem" on kv for insert with check (is_staff() and key in ('grades','att'));
create policy "gv sua diem" on kv for update using (is_staff() and key in ('grades','att'))
  with check (is_staff() and key in ('grades','att'));

-- Tài khoản mới tạo tự động là giáo viên
create function handle_new_user() returns trigger language plpgsql security definer set search_path = public
as $$ begin
  insert into profiles (id, name) values (new.id, coalesce(new.raw_user_meta_data->>'name', new.email));
  return new;
end $$;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function handle_new_user();

insert into kv (key, value) values
  ('teachers','[]'),('classes','[]'),('students','[]'),('grades','{}'),('att','{}')
on conflict do nothing;

-- SAU KHI tạo tài khoản đầu tiên (Authentication -> Users -> Add user), đổi email bên dưới rồi chạy dòng này để lên admin:
-- update profiles set role = 'admin' where id = (select id from auth.users where email = 'admin@truong.edu.vn');
