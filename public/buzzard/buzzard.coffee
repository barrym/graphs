$(document).ready(() ->
    drawGraph()
)

data = [3,7,9,1,4,6,8,2,5]
w = 700
h = 300
max = d3.max(data)

x = d3.scale.linear().domain([0, data.length - 1]).range([0, w])
y = d3.scale.linear().domain([0, max]).range([h, 0])


drawGraph = () ->
    vis = d3.select("#chart")
        .append("svg:svg")
        .attr("width", w)
        .attr("height", h)

    vis.selectAll("path.line")
        .data([data])
        .enter()
        .append("svg:path")
        .attr("d", d3.svg.line()
            .x((d, i) -> x(i))
            .y(y))

    ticks = vis.selectAll(".ticks")
        .data(y.ticks(7))
        .enter()
        .append("svg:g")
        .attr("transform", (d) -> "translate(0, #{y(d)})")
        .attr("class", "tick")

    ticks.append("svg:line")
        .attr("x1", 0)
        .attr("y1", 0)
        .attr("x2", w)
        .attr("y2", 0)

    ticks.append("svg:text")
        .text((d) -> d)
        # .attr("text-anchor", "end")
        .attr("dy", 2)
        .attr("dx", -4)
