# LuxeService Project Setup

This project is built using a **Scalable Clean Architecture** pattern, optimized for React/TypeScript while mirroring professional Flutter architectural standards.

## 📁 Architecture Overview
- `src/lib/core`: App foundations (constants, theme, shared tokens, reusable widgets).
- `src/lib/models`: Immutable data interfaces and domain-level contracts.
- `src/lib/services`: External communication layer (Mock APIs for now).
- `src/lib/repositories`: Data abstraction layer. Components talk to Repositories, not APIs.
- `src/lib/auth`: Dedicated module for authentication states and screens.
- `src/lib/features`: Business domains (Home, Bookings, Services, Profile).
- `src/lib/navigation`: Centralized routing system using `react-router-dom`.

## 🚀 How to Run
1. Install dependencies: `npm install`
2. Start development server: `npm run dev`
3. Access the app at `http://localhost:3000`

## 🔌 Replacing Mock Services with Real Backend
To transition to a real backend:
1. **Update Services**: Create new service classes in `src/lib/services` (e.g., `ApiService.ts`) that use `fetch` or `axios` instead of `setTimeout`.
2. **Adjust Repositories**: Update `src/lib/repositories/repositories.ts` to instantiate and use the new `ApiService`.
3. **Environmental Config**: Use `.env` files to store your backend base URL and inject it into your services.
4. **Auth Integration**: Update `src/lib/auth/auth_store.ts` to call your real `/login` and `/register` endpoints.

## 🛠️ Key Technologies
- **Vite**: Ultra-fast build tool and dev server.
- **Tailwind CSS**: Utility-first styling with Material 3 design tokens.
- **Zustand**: Lightweight, decoupled state management.
- **Framer Motion**: State-driven premium animations and transitions.
- **Lucide React**: Consistent, high-end iconography.
