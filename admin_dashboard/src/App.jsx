import React from 'react';
import { motion } from 'framer-motion';
import { 
  Users, 
  ShoppingBag, 
  DollarSign, 
  UserCheck, 
  LayoutDashboard, 
  Settings, 
  Bell, 
  Search,
  TrendingUp
} from 'lucide-react';

function App() {
  return (
    <div className="admin-app">
      <div className="glacier-bg" />
      
      {/* Sidebar */}
      <aside className="sidebar">
        <div style={{ marginBottom: '60px', paddingLeft: '10px' }}>
          <h2 style={{ letterSpacing: '4px', fontSize: '1.2rem', color: '#7dd3fc' }}>ENDLESSPATH</h2>
          <p style={{ fontSize: '0.7rem', opacity: 0.5, marginTop: '4px' }}>ADMIN CONSOLE</p>
        </div>
        
        <nav>
          <NavItem icon={<LayoutDashboard size={20} />} label="Dashboard" active />
          <NavItem icon={<Users size={20} />} label="Users" />
          <NavItem icon={<UserCheck size={20} />} label="Providers" />
          <NavItem icon={<ShoppingBag size={20} />} label="Orders" />
          <NavItem icon={<DollarSign size={20} />} label="Revenue" />
          <NavItem icon={<Bell size={20} />} label="Support" />
          <div style={{ marginTop: '40px' }}>
            <NavItem icon={<Settings size={20} />} label="Settings" />
          </div>
        </nav>
      </aside>

      {/* Main Content */}
      <main className="main-content">
        <header style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '60px' }}>
          <div>
            <h1 style={{ fontSize: '2rem', marginBottom: '4px' }}>Overview</h1>
            <p style={{ color: '#a0b4c4' }}>Welcome back, Super Admin.</p>
          </div>
          
          <div style={{ display: 'flex', gap: '20px', alignItems: 'center' }}>
            <div className="glass-card" style={{ padding: '10px 20px', display: 'flex', alignItems: 'center', gap: '10px' }}>
              <Search size={18} color="#7dd3fc" />
              <input 
                type="text" 
                placeholder="Search analytics..." 
                style={{ background: 'none', border: 'none', color: '#fff', outline: 'none', width: '200px' }} 
              />
            </div>
            <div className="glass-card" style={{ padding: '10px', borderRadius: '12px' }}>
              <Bell size={20} color="#7dd3fc" />
            </div>
          </div>
        </header>

        {/* Stats Grid */}
        <div className="stat-grid">
          <StatCard icon={<Users color="#7dd3fc" />} label="Total Users" value="12,482" trend="+12%" />
          <StatCard icon={<UserCheck color="#7dd3fc" />} label="Providers" value="842" trend="+5%" />
          <StatCard icon={<ShoppingBag color="#7dd3fc" />} label="Total Orders" value="3,102" trend="+24%" />
          <StatCard icon={<DollarSign color="#7dd3fc" />} label="Total Revenue" value="₹2.4M" trend="+18%" />
        </div>

        {/* Recent Orders Section */}
        <div className="glass-card">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
            <h3>Recent Bookings</h3>
            <button className="glass-button" style={{ padding: '8px 16px', fontSize: '0.8rem' }}>View All</button>
          </div>
          
          <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left' }}>
            <thead>
              <tr style={{ color: '#a0b4c4', borderBottom: '1px solid rgba(125, 211, 252, 0.1)' }}>
                <th style={{ padding: '15px' }}>ID</th>
                <th>CUSTOMER</th>
                <th>SERVICE</th>
                <th>AMOUNT</th>
                <th>STATUS</th>
                <th>DATE</th>
              </tr>
            </thead>
            <tbody>
              <OrderRow id="#8291" customer="Rahul Sharma" service="AC Repair" amount="₹499" status="Completed" date="Oct 24, 2:30 PM" />
              <OrderRow id="#8290" customer="Anita Singh" service="Deep Cleaning" amount="₹1,299" status="Pending" date="Oct 24, 1:15 PM" />
              <OrderRow id="#8289" customer="Vikram Dev" service="Plumbing" amount="₹299" status="InProgress" date="Oct 23, 11:00 AM" />
            </tbody>
          </table>
        </div>
      </main>
    </div>
  );
}

const NavItem = ({ icon, label, active }) => (
  <motion.div 
    whileHover={{ x: 5 }}
    style={{ 
      display: 'flex', 
      alignItems: 'center', 
      gap: '15px', 
      padding: '12px 20px', 
      borderRadius: '12px',
      cursor: 'pointer',
      background: active ? 'rgba(125, 211, 252, 0.1)' : 'transparent',
      color: active ? '#7dd3fc' : '#a0b4c4',
      marginBottom: '8px'
    }}
  >
    {icon}
    <span style={{ fontWeight: 600 }}>{label}</span>
  </motion.div>
);

const StatCard = ({ icon, label, value, trend }) => (
  <motion.div 
    initial={{ opacity: 0, y: 20 }}
    animate={{ opacity: 1, y: 0 }}
    className="glass-card"
  >
    <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '20px' }}>
      <div style={{ background: 'rgba(125, 211, 252, 0.1)', padding: '10px', borderRadius: '12px' }}>
        {icon}
      </div>
      <div style={{ color: '#22c55e', fontSize: '0.8rem', display: 'flex', alignItems: 'center' }}>
        <TrendingUp size={14} style={{ marginRight: '4px' }} />
        {trend}
      </div>
    </div>
    <h1 style={{ fontSize: '1.8rem', marginBottom: '4px' }}>{value}</h1>
    <p style={{ color: '#a0b4c4', fontSize: '0.9rem' }}>{label}</p>
  </motion.div>
);

const OrderRow = ({ id, customer, service, amount, status, date }) => {
  const statusColor = {
    Completed: '#22c55e',
    Pending: '#f59e0b',
    InProgress: '#3b82f6'
  }[status];

  return (
    <tr style={{ borderBottom: '1px solid rgba(125, 211, 252, 0.05)', color: '#e0e8f0' }}>
      <td style={{ padding: '20px', color: '#7dd3fc' }}>{id}</td>
      <td style={{ fontWeight: 600 }}>{customer}</td>
      <td>{service}</td>
      <td style={{ fontWeight: 700 }}>{amount}</td>
      <td>
        <span style={{ color: statusColor, background: `${statusColor}10`, padding: '4px 10px', borderRadius: '8px', fontSize: '0.8rem' }}>
          {status}
        </span>
      </td>
      <td style={{ opacity: 0.5 }}>{date}</td>
    </tr>
  );
};

export default App;
