import React, { Component } from "react";
import ReactDom from "react-dom";
import {
  BrowserRouter as Router,
  Switch,
  Route,
  Link,
  Redirect,
} from "react-router-dom";
import Home from "./Home";
import Dashboard from "./Dashboard";

class Welcome extends React.Component {
  render() {
    return <h1>Hello</h1>;
  }
}

function App() {
  //   return (
  //     <Router>
  //       <Switch>
  //         <Route exact path="/" component={Home}></Route>
  //         <Route exact path="/dashboard" component={Dashboard}></Route>
  //       </Switch>
  //     </Router>
  //   );
  return <h1>Hello Worlsd</h1>;
}

const appDiv = document.getElementById("app");
ReactDom.render(<Welcome />, appDiv);
