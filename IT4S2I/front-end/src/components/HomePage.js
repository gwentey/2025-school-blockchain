import React from 'react';
import './HomePage.css'; // We'll create this CSS file next

const HomePage = () => {
  return (
    <div className="home-page">
      {/* Hero Section */}
      <section className="hero-section">
        <div className="hero-content">
          <h1>Welcome to Your Bank</h1>
          <p>Secure, Fast, and Reliable Banking for Everyone</p>
        </div>
      </section>

      {/* Features Section */}
      <section className="features-section">
        <div className="features-grid">
          <div className="feature-card">
            <h3>Secure Transactions</h3>
            <p>Your money is safe with our advanced encryption technology.</p>
          </div>
          <div className="feature-card">
            <h3>24/7 Support</h3>
            <p>We’re here for you anytime, anywhere.</p>
          </div>
          <div className="feature-card">
            <h3>Easy Transfers</h3>
            <p>Send money to anyone, anytime, with just a few clicks.</p>
          </div>
        </div>
      </section>
    </div>
  );
};

export default HomePage;