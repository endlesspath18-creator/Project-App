import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { useAuthStore } from '../auth/auth_store';

// We will create these components next
import { LoginSelectionScreen } from '../auth/screens/login_selection_screen';
import { LoginScreen } from '../auth/screens/login_screen';
import { Layout } from './layout';
import { HomeScreen } from '../features/home/screens/home_screen';
import { ServicesScreen } from '../features/services/screens/services_screen';
import { ServiceDetailScreen } from '../features/services/screens/service_detail_screen';
import { CategoriesScreen } from '../features/categories/screens/categories_screen';
import { BookingsScreen } from '../features/bookings/screens/bookings_screen';
import { RewardsScreen } from '../features/rewards/screens/rewards_screen';
import { ProfileScreen, SupportScreen } from '../features/profile/screens/profile_screen';
import { LiveTrackingScreen } from '../features/tracking/screens/tracking_screen';
import { BookingFlow } from '../features/bookings/screens/booking_flow';

export const AppRouter = () => {
  const { isAuthenticated, role } = useAuthStore();

  return (
    <BrowserRouter>
      <Routes>
        {/* Auth Flow */}
        {!isAuthenticated ? (
          <>
            <Route path="/login" element={<LoginSelectionScreen />} />
            <Route path="/login/:role" element={<LoginScreen />} />
            <Route path="*" element={<Navigate to="/login" replace />} />
          </>
        ) : (
          /* Main App Flow */
          <>
            <Route element={<Layout />}>
              <Route path="/home" element={<HomeScreen />} />
              <Route path="/categories" element={<CategoriesScreen />} />
              <Route path="/services" element={<ServicesScreen />} />
              <Route path="/bookings" element={<BookingsScreen />} />
              <Route path="/rewards" element={<RewardsScreen />} />
              <Route path="/profile" element={<ProfileScreen />} />
              <Route path="*" element={<Navigate to="/home" replace />} />
            </Route>
            
            {/* Full Screen Views (No Bottom Nav) */}
            <Route path="/service/:id" element={<ServiceDetailScreen />} />
            <Route path="/book/:id" element={<BookingFlow />} />
            <Route path="/track/:id" element={<LiveTrackingScreen />} />
            <Route path="/support" element={<SupportScreen />} />
          </>
        )}
      </Routes>
    </BrowserRouter>
  );
};
