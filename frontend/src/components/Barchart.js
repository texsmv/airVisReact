import React, { Component } from "react";
import * as d3 from "d3";

class Barchart extends Component {
  constructor(props) {
    super(props);

    this.myReference = React.createRef();
  }

  componentDidMount() {
    this.drawChart();
  }

  drawChart() {
    const data = [12, 5, 6, 6, 9, 10];

    var container = d3.select(this.myReference.current);

    const svg = container.append("svg").attr("width", 700).attr("height", 900);

    svg
      .selectAll("rect")
      .data(data)
      .enter()
      .append("rect")
      .attr("x", (d, i) => i * 70)
      .attr("y", 0)
      .attr("width", 25)
      .attr("height", (d, i) => d * 20)
      .attr("fill", "yellow")
      .append("svg")
      .attr("style", "outline: thin solid red;");
  }

  render() {
    return <div ref={this.myReference}></div>;
  }
}

export default Barchart;
