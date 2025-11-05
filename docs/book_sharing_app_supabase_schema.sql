-- 📚 Book Sharing App – Supabase Schema + Triggers

-- ================================================
-- EXTENSIONS
-- ================================================
create extension if not exists "uuid-ossp";

-- ================================================
-- TABLES
-- ================================================

-- Local application users (ties auth.users to domain data)
create table if not exists local_users (
  id uuid default uuid_generate_v4() primary key,
  auth_user_id uuid references auth.users(id) on delete cascade unique,
  username text not null,
  display_name text,
  avatar_url text,
  google_books_api_key text,
  is_deleted boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  constraint username_must_be_unique unique (lower(username))
);

-- Personal library
create table if not exists books (
  id uuid default uuid_generate_v4() primary key,
  owner_id uuid references local_users(id) on delete cascade,
  title text not null,
  author text,
  isbn text,
  barcode text,
  cover_url text,
  status text default 'available' check (status in ('available', 'loaned', 'reserved', 'archived')),
  notes text,
  is_deleted boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Reviews for personal books (one per user/book)
create table if not exists book_reviews (
  id uuid default uuid_generate_v4() primary key,
  book_id uuid references books(id) on delete cascade,
  author_id uuid references local_users(id) on delete cascade,
  rating int not null check (rating between 1 and 5),
  review text,
  is_deleted boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  constraint book_reviews_one_per_user unique (book_id, author_id, is_deleted)
);

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
alter table local_users enable row level security;
alter table books enable row level security;
alter table book_reviews enable row level security;
alter table groups enable row level security;
alter table group_members enable row level security;
alter table shared_books enable row level security;
alter table loans enable row level security;
alter table notifications enable row level security;

-- Local users policies
create policy "Users can view their own profile"
on local_users
for select
using (auth.uid() = auth_user_id);

create policy "Users manage their own profile"
on local_users
for all
using (auth.uid() = auth_user_id)
with check (auth.uid() = auth_user_id);

-- Personal books policies
create policy "Owners can manage their books"
on books
for all
using (auth.uid() = (select auth_user_id from local_users where local_users.id = owner_id))
with check (auth.uid() = (select auth_user_id from local_users where local_users.id = owner_id));

create policy "Owners view their books"
on books
for select
using (auth.uid() = (select auth_user_id from local_users where local_users.id = owner_id));

-- Book reviews policies
create policy "Review authors can manage their reviews"
on book_reviews
for all
using (auth.uid() = (select auth_user_id from local_users where local_users.id = author_id))
with check (auth.uid() = (select auth_user_id from local_users where local_users.id = author_id));

create policy "Book owners can view reviews"
on book_reviews
for select
using (
  auth.uid() = (select auth_user_id from local_users where local_users.id = author_id)
  or auth.uid() = (
    select auth_user_id from local_users where local_users.id = (select owner_id from books where books.id = book_id)
  )
);

-- Notifications visible only to owner
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

create policy "Group owners manage membership"
on group_members
for all
using (
  auth.uid() = (select owner_id from groups where groups.id = group_id)
)
with check (
  auth.uid() = (select owner_id from groups where groups.id = group_id)
);

-- Shared books (only owner can modify, group members can view)
create policy "Group members can view books in their group"
on shared_books
for select
using (
  exists (
    select 1
    from group_members gm
    where gm.group_id = shared_books.group_id
      and gm.user_id = auth.uid()
  )
);

create policy "Owners can manage their own shared books"
on shared_books
for all
using (auth.uid() = owner_id)
with check (auth.uid() = owner_id);

-- Loans visibility and management
create policy "Users can view loans they participate in"
on loans
for select
using (
  auth.uid() = from_user
  or auth.uid() = to_user
);

create policy "Users can manage loans they participate in"
on loans
for all
using (
  auth.uid() = from_user
  or auth.uid() = to_user
)
with check (
  auth.uid() = from_user
  or auth.uid() = to_user
);
