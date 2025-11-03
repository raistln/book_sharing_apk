-- 📚 Book Sharing App – Supabase Schema + Triggers

-- ================================================
-- EXTENSIONS
-- ================================================
create extension if not exists "uuid-ossp";

-- ================================================
-- TABLES
-- ================================================

-- Groups
create table if not exists groups (
  id uuid default uuid_generate_v4() primary key,
  name text not null,
  owner_id uuid references auth.users(id) on delete cascade,
  created_at timestamptz default now()
);

-- Group members
create table if not exists group_members (
  id uuid default uuid_generate_v4() primary key,
  group_id uuid references groups(id) on delete cascade,
  user_id uuid references auth.users(id) on delete cascade,
  role text default 'member',
  created_at timestamptz default now(),
  unique (group_id, user_id)
);

-- Shared books
create table if not exists shared_books (
  id uuid default uuid_generate_v4() primary key,
  group_id uuid references groups(id) on delete cascade,
  owner_id uuid references auth.users(id),
  title text not null,
  author text,
  isbn text,
  barcode text,
  cover_url text,
  available boolean default true,
  created_at timestamptz default now()
);

-- Loans
create table if not exists loans (
  id uuid default uuid_generate_v4() primary key,
  book_id uuid references shared_books(id) on delete cascade,
  from_user uuid references auth.users(id),
  to_user uuid references auth.users(id),
  status text default 'pending' check (status in ('pending', 'accepted', 'rejected', 'returned', 'expired', 'cancelled')),
  start_date date default current_date,
  due_date date,
  created_at timestamptz default now()
);

-- Notifications
create table if not exists notifications (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users(id),
  type text not null,
  message text,
  related_loan uuid references loans(id),
  created_at timestamptz default now(),
  read boolean default false
);

-- ================================================
-- TRIGGERS FOR NOTIFICATIONS
-- ================================================

create or replace function notify_loan_status_change()
returns trigger as $$
begin
  if (TG_OP = 'INSERT') then
    insert into notifications (user_id, type, message, related_loan)
    values (NEW.to_user, 'loan_requested', 'Te han solicitado un préstamo.', NEW.id);
  elsif (TG_OP = 'UPDATE') then
    if (NEW.status <> OLD.status) then
      if (NEW.status = 'accepted') then
        insert into notifications (user_id, type, message, related_loan)
        values (NEW.from_user, 'loan_accepted', 'Tu préstamo ha sido aceptado.', NEW.id);
      elsif (NEW.status = 'rejected') then
        insert into notifications (user_id, type, message, related_loan)
        values (NEW.from_user, 'loan_rejected', 'Tu préstamo ha sido rechazado.', NEW.id);
      elsif (NEW.status = 'returned') then
        insert into notifications (user_id, type, message, related_loan)
        values (NEW.to_user, 'loan_returned', 'Se ha marcado el préstamo como devuelto.', NEW.id);
      elsif (NEW.status = 'expired') then
        insert into notifications (user_id, type, message, related_loan)
        values (NEW.from_user, 'loan_expired', 'Un préstamo ha expirado.', NEW.id);
      end if;
    end if;
  end if;
  return NEW;
end;
$$ language plpgsql;

drop trigger if exists on_loan_change on loans;
create trigger on_loan_change
after insert or update on loans
for each row
execute function notify_loan_status_change();

-- ================================================
-- RLS POLICIES
-- ================================================
alter table groups enable row level security;
alter table group_members enable row level security;
alter table shared_books enable row level security;
alter table loans enable row level security;
alter table notifications enable row level security;

-- Policy: Notifications visible only to owner
create policy "Users can view their own notifications"
on notifications
for select
using (auth.uid() = user_id);

create policy "Users can insert notifications for themselves"
on notifications
for insert
with check (auth.uid() = user_id);

-- Groups
create policy "Group owners can manage their groups"
on groups
for all
using (auth.uid() = owner_id)
with check (auth.uid() = owner_id);

create policy "Group members can view their groups"
on group_members
for select
using (auth.uid() = user_id);

-- Shared books (only owner can modify, group members can view)
create policy "Group members can view books in their group"
on shared_books
for select
using (exists (select 1 from group_members where group_members.group_id = shared_books.group_id and group_members.user_id = auth.uid()));

create policy "Owners can manage their own books"
on shared_books
for all
using (auth.uid() = owner_id)
with check (auth.uid() = owner_id);
