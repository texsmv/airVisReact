import React from "react";

import Barchart from "./Barchart";

var scope = {
  splitterStyle: {
    height: 500,
  },
};

function Dashboard(props) {
  // return <h1>Home dash</h1>;
  return (
    <div style={{ backgroundColor: "#00B1E1" }}>
      <ol>
        <li>
          <p>Dashboard</p>
        </li>
        <li>
          <div style={scope}>
            <Barchart></Barchart>
          </div>
        </li>
      </ol>
    </div>
  );
}

export default Dashboard;
