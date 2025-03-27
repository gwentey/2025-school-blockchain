import React from 'react';
import { Link } from 'react-router-dom'; // Assuming you are using React Router for navigation

const NavBar = () => {
  return (
    <nav>
      <ul>
      <li>
          <Link to="/">Home</Link>
        </li>
        <li>
          <Link to="/createCompte">Create Compte</Link>
        </li>
        <li>
          <Link to="/depositMoney">Deposer Argent</Link>
        </li>
        <li>
          <Link to="/retirerArgent">Retirer Argent</Link>
        </li>
        <li>
          <Link to="/transfertArgent">Transferer Argent</Link>
        </li>
      </ul>
    </nav>
  );
}

export default NavBar;
