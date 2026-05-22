import React, { useState, useEffect } from 'react';

function App() {
  const [products, setProducts] = useState([]);

  useEffect(() => {
    // Relative endpoint path mapped through the custom Nginx layer
    fetch('/api/v1/products/')
      .then(res => res.json())
      .then(data => setProducts(data))
      .catch(err => console.error("Error communicating with gateway API:", err));
  }, []);

  return (
    <div className="app-container">
      {/* Global Application Header */}
      <header className="navbar">
        <div className="brand">
          Nexa<span>Cart</span>
        </div>
        <div className="cart-icon">
          🛒 Cart (0)
        </div>
      </header>
      
      {/* Primary Content Target */}
      <main>
        <section className="hero-section">
          <h2>Discover Premium Products</h2>
          <p>Handpicked engineering items curated specifically for your stack.</p>
        </section>

        {/* Evaluates state array content for smart rendering options */}
        {products.length === 0 ? (
          <div className="hero-section" style={{ textAlign: 'center', padding: '3rem' }}>
            <p>No products available right now. Visit <code>localhost:8000/docs</code> to seed item data!</p>
          </div>
        ) : (
          <div className="product-grid">
            {products.map(product => (
              <article key={product.id} className="card">
                {/* Visual placeholder mapping inside individual cards */}
                <div className="image-placeholder">📦</div>
                
                <h3>{product.name}</h3>
                <p className="description">
                  {product.description || "No description provided for this premium option item."}
                </p>
                
                <div className="card-footer">
                  <span className="price">${product.price.toFixed(2)}</span>
                  <button>Add to Cart</button>
                </div>
              </article>
            ))}
          </div>
        )}
      </main>
    </div>
  );
}

export default App;