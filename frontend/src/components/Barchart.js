import React, { Component } from "react";
import * as d3 from "d3";
import * as d3Lasso from "d3-lasso";
// import lasso from "d3-lasso";

var d3s = d3;
console.log(d3s);
// console.log(d3Lasso);
class Barchart extends Component {
  constructor(props) {
    super(props);

    this.myReference = React.createRef();
  }

  componentDidMount() {
    this.drawChart();
  }

  //   drawChart() {
  //     const data = [12, 5, 6, 6, 9, 10];

  //     var container = d3.select(this.myReference.current);

  //     const svg = container.append("svg").attr("width", 700).attr("height", 900);

  //     svg
  //       .selectAll("rect")
  //       .data(data)
  //       .enter()
  //       .append("rect")
  //       .attr("x", (d, i) => i * 70)
  //       .attr("y", 0)
  //       .attr("width", 25)
  //       .attr("height", (d, i) => d * 20)
  //       .attr("fill", "yellow")
  //       .append("svg")
  //       .attr("style", "outline: thin solid red;");
  //   }

  drawChart() {
    // const data s= [12, 5, 6, 6, 9, 10];
    const data = [
      {
        x: 20,
        y: 45,
      },
      {
        x: 12,
        y: 42,
      },
      {
        x: 0,
        y: 25,
      },
      {
        x: 10,
        y: 45,
      },
    ];

    // const data = [12, 5, 6, 6, 9, 10];

    // var container = d3.select(this.myReference.current);

    // const svg = container.append("svg");
    // var width = 400;
    // var height = 400;

    // svg.attr("width", width).attr("height", height);

    var margin = { top: 10, right: 30, bottom: 30, left: 60 },
      width = 460 - margin.left - margin.right,
      height = 400 - margin.top - margin.bottom;

    var Lasso = d3Lasso.lasso();
    console.log("Lasso");
    // console.log(lala);

    // append the svg object to the body of the page
    var svg = d3
      .select(this.myReference.current)
      .append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
      .append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
    console.log("Hey");

    // d3.csv(
    //   "https://raw.githubusercontent.com/holtzy/data_to_viz/master/Example_dataset/2_TwoNum.csv",
    //   function (data) {
    // console.log(data);
    var x = d3.scaleLinear().domain([0, 100]).range([0, width]);
    svg
      .append("g")
      .attr("transform", "translate(0," + height + ")")
      .call(d3.axisBottom(x));

    // Add Y axis
    var y = d3.scaleLinear().domain([0, 100]).range([height, 0]);
    svg.append("g").call(d3.axisLeft(y));

    // Add dots
    // svg
    var circles = svg
      .selectAll("dot")
      .data(data)
      .enter()
      .append("circle")
      .attr("cx", function (d) {
        return x(d.x);
      })
      .attr("cy", function (d) {
        return y(d.y);
      })
      .attr("r", 5)
      .style("fill", "#69b3a2");

    var lasso_draw = function () {
      console.log("draw");
    };

    var lasso = Lasso.closePathSelect(true)
      .closePathDistance(100)
      .items(circles)
      .targetArea(svg)
      .on("draw", lasso_draw);

    console.log(lasso);

    function dragStart() {
      console.log("dragStart");
      //   var p = d3.mouse(this);
      //   selectionRect.init(p[0], p[1]);
      //   selectionRect.removePrevious();
    }

    function dragMove() {
      console.log("dragMove");
      //   var p = d3.mouse(this);
      //   selectionRect.update(p[0], p[1]);
      //   attributesText.text(selectionRect.getCurrentAttributesAsText());
    }

    function dragEnd() {
      console.log("dragEnd");
      //   var finalAttributes = selectionRect.getCurrentAttributes();
      //   console.dir(finalAttributes);
      //   if (
      //     finalAttributes.x2 - finalAttributes.x1 > 1 &&
      //     finalAttributes.y2 - finalAttributes.y1 > 1
      //   ) {
      //     console.log("range selected");
      //     // range selected
      //     d3.event.sourceEvent.preventDefault();
      //     selectionRect.focus();
      //   } else {
      //     console.log("single point");
      //     // single point selected
      //     selectionRect.remove();
      //     // trigger click event manually
      //     clicked();
      //   }
    }

    // svg.call(lasso);
    var dragBehavior = d3
      .drag()
      .on("drag", dragMove)
      //   .on("dragstart", dragStart)
      .on("dragend", dragEnd);

    console.log(data);
    // setState({ data: data });
    //   }
    // );

    // svg
    //   .selectAll("rect")
    //   .data(data)
    //   .enter()
    //   .append("rect")
    //   .attr("x", (d, i) => i * 70)
    //   .attr("y", 0)
    //   .attr("width", 25)
    //   .attr("height", (d, i) => d * 20)
    //   .attr("fill", "yellow");
  }

  render() {
    return <div ref={this.myReference}></div>;
  }
}

export default Barchart;
