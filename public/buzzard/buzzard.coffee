$(document).ready(() ->
    drawGraph()
)

data = [3,7,9,1,4,6,38,8,2,5,45,44,42,42,40,44,45,30]
more_data = [21,45,21,21,34,32,12]
w = 700
h = 300
p = 30
max = d3.max(data) # TODO: max of both arrays

x = d3.scale.linear().domain([0, data.length - 1]).range([0 + p, w - p])
y = d3.scale.linear().domain([0, max]).range([h - p, 0 + p])

# setInterval(
#     () ->
#         data.shift()
#         data.push(Math.round(Math.random() * 50))
#         drawGraph()
#     , 1500)

vis = d3.select("#chart")
    .append("svg:svg")
    .attr("width", w)
    .attr("height", h)

drawGraph = () ->
    console.log("drawing")

    vis.selectAll("path.line")
        .data([data, more_data])
        .enter()
        .append("svg:path")
        .attr("d", d3.svg.line()
            .x((d, i) -> x(i))
            .y((d) -> y(d)) )
        .attr("class", (d, i) -> ( if i == 0 then "o2" else "vodafone"))

    yticks = vis.selectAll(".ticks")
        .data(y.ticks(7))
        .enter()
        .append("svg:g")
        .attr("transform", (d) -> "translate(0, #{y(d)})")
        .attr("class", "tick")

    yticks.append("svg:line")
        .attr("x1", 0)
        .attr("y1", 0)
        .attr("x2", w)
        .attr("y2", 0)

    yticks.append("svg:text")
        .text((d) -> d)
        .attr("text-anchor", "start")
        .attr("dy", 5)
        .attr("dx", 2)

    xticks = vis.selectAll(".ticks")
        .data(x.ticks(10))
        .enter()
        .append("svg:g")
        .attr("transform", (d) -> "translate(#{x(d)}, 0)")
        .attr("class", "tick")

    xticks.append("svg:line")
        .attr("x1", 0)
        .attr("y1", 0)
        .attr("x2", 0)
        .attr("y2", h)

    xticks.append("svg:text")
        .text((d) -> d)
        .attr("text-anchor", "middle")
        .attr("dy", h)
        .attr("dx", 2)
