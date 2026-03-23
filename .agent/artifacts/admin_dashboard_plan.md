# Admin Dashboard Implementation Plan

## 1. Overview
The Admin Dashboard is a centralized control center for the StartLink platform. It allows admins to manage users, verified content, monitor AI systems, and handle support tickets. A critical requirement is the manual approval flow for Mentors and Investors.

## 2. Architecture
- **Location**: `lib/features/admin`
- **Pattern**: Clean Architecture (Presentation, Domain, Data)
- **State Management**: BLoC

### Directory Structure
```
lib/features/admin/
├── data/
│   ├── datasources/        # Admin-specific API calls (Supabase RPCs)
│   ├── models/             # Admin-specific data models (e.g., VerificationRequest)
│   └── repositories/       # AdminRepositoryImpl
├── domain/
│   ├── entities/           # Core entities
│   ├── repositories/       # IAdminRepository
│   └── usecases/           # ApproveUser, BanUser, GetSystemStats, etc.
└── presentation/
    ├── bloc/               # AdminBloc
    ├── pages/              # AdminDashboard, UserManagement, Verification, etc.
    └── widgets/            # AdminSidebar, StatsCard, DataTables
```

## 3. Key Modules & phases

### Phase 1: Foundation & Navigation
- [ ] Create `AdminLayout` (Shell) with Sidebar.
- [ ] Implement `AdminAuthGuard` (Protect routes).
- [ ] Setup `AdminDashboard` landing page with high-level stats.

### Phase 2: User Management & Verification (CRITICAL)
- [ ] **Mentor/Investor Approval Pipeline**:
    - List functionality for `status='pending'` users.
    - Detail view with attached documents.
    - Approve/Reject actions.
- [ ] **User List**:
    - Searchable/Filterable table of all users.
    - Role management actions (Ban, Promote).

### Phase 3: Content & Analytics
- [ ] **Idea Management**: List/Flag/Feature ideas.
- [ ] **Analytics**: Graphs for user growth, activity.

### Phase 4: System & AI
- [ ] **AI Monitoring**: Logs of AI usage.
- [ ] **Settings**: Global toggles.

## 4. Technical Details

### Authentication
- Rely on `AuthBloc` for current user.
- Check `user_metadata['role'] == 'admin' | 'super_admin'`.

### Data Fetching
- Use Supabase directly or specialized RPCs for heavy admin queries (e.g., `get_all_users`).
- RLS policies must allow admins to see data that users typically can't.

### UI Components
- **Sidebar**: Collapsible, responsive.
- **DataTables**: Reusable table widget with pagination and sort.
- **StatusBadges**: Visual indicators for `Verified`, `Pending`, `Banned`.

## 5. Step-by-Step Implementation

1.  **Scaffold**: Setup `AdminLayout` and `AdminDashboard`.
2.  **Navigation**: Add `RoleAwareNavigationBar` integration or specific Admin Sidebar.
3.  **Role Guard**: Ensure non-admins are redirected.
4.  **Verification Module**: Build the UI to list Pending users and approve them.
