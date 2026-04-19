# CateGurumi - Decisions & Development Plan

## Project Overview
CateGurumi is a website for showcasing Amigurumi creations.
- **Backend:** Laravel
- **Frontend:** React (via Inertia.js)
- **Admin Panel:** Filament PHP

## Architectural Decisions

### 1. Integration Stack
- **Selection:** Laravel + Inertia.js + React.
- **Rationale:** Fulfils the requirement of Laravel serving React via Blade (through Inertia's root template) and provides a smooth SPA-like experience for the user.

### 2. Admin Interface
- **Selection:** Filament PHP.
- **Rationale:** Rapid development of the admin CRUD for managing "Creations" (uploads, titles, descriptions).
- **Default Admin (Dev):** `catecalab@icloud.com` / `password` (Change password immediately in production).

### 3. Styling & Design
- **Theme:** Mobile-first, beautiful, modern.
- **Color Palette:**
    - Primary: `#6a4c94`
    - Secondary: `#8a5fbf`
    - Accent: `#ffd900`, `#fff36b`
    - Background/Misc: `#ffdcad`
- **Font:** Apple SD Gothic Neo.
- **Corners:** Rounded.
- **Frontend Caching:** To be implemented to minimize data usage and improve speed.

## Roadmap

### Phase 1: Foundation
- [x] Initialize Laravel + Inertia.js + React.
- [x] Database configuration (SQLite).
- [x] Basic routing and asset compilation setup.

### Phase 2: Content Management (Admin)
- [x] Creation Model & Migration.
- [x] Filament Installation & Configuration.
- [x] Creation Resource (Image upload, title, description).

### Phase 3: Public UI
- [x] Public Gallery View (React).
- [x] Detailed View Modal.
- [x] Branding & Styling (Colors, Fonts).
- [x] Image Caching strategy (Service Worker implemented in public/sw.js).

### Phase 4: Deployment
- [x] Caddy configuration verification (Updated for Laravel/PHP).
- [x] Deployment script testing (Updated for Laravel/React sync).
