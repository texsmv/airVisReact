import React, { Component } from "react";
import ReactDom from "react-dom";
import {
  BrowserRouter as Router,
  Routes,
  Route,
  Link,
  Redirect,
} from "react-router-dom";
import Dashboard from "./Dashboard";
import Home from "./Home";

function App() {
  //   return <Home></Home>;
  //   return <Dashboard></Dashboard>;
  return (
    <Router>
      <Routes>
        <Route exact path="/" element={<Home />}></Route>
        <Route path="/dashboard" element={<Dashboard />}></Route>
      </Routes>
    </Router>
  );
  //   return <h1>Hello Worlsd</h1>;
}

const appDiv = document.getElementById("app");
ReactDom.render(<App />, appDiv);
