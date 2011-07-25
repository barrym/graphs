$(document).ready(() ->
    drawGraph()
)

data      = d3.range(10).map(() -> Math.round(Math.random() * 50))
data.shift()
data.push(12000)
more_data = d3.range(10).map(() -> Math.round(Math.random() * 50))

w = 700
h = 300
p = 30
interval = 1000
max = d3.max(data) # TODO: max of both arrays

x = d3.scale.linear().domain([0, data.length - 1]).range([0 + p, w - p])
y = d3.scale.linear().domain([0, max]).range([h - p, 0 + p])
yTickCount = 5

setInterval(
    () ->
        data.shift()
        data.push(Math.round(Math.random() * 50 + Math.random() * 1000))
        more_data.shift()
        more_data.push(Math.round(Math.random() * 50 + Math.random() * 1000))
        x = d3.scale.linear().domain([0, data.length - 1]).range([0 + p, w - p])
        y = d3.scale.linear().domain([0, d3.max(data.concat(more_data))]).range([h - p, 0 + p])
        redraw()
    , interval)

vis = d3.select("#chart")
    .append("svg:svg")
    .attr("width", w)
    .attr("height", h)


path = d3.svg.line()
    .x((d, i) -> x(i))
    .y((d) -> y(d))
    .interpolate("monotone")

drawGraph = () ->
    # console.log("drawing")

    vis.selectAll("path.line")
        .data([data, more_data])
        .enter()
        .append("svg:path")
        .attr("d", path)
        .attr("class", (d, i) -> ( if i == 0 then "o2" else "vodafone"))

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

    yticks = vis.selectAll("g.ticks")
        .data(y.ticks(yTickCount))
        .enter()
        .append("svg:g")
        .attr("transform", (d) -> "translate(0, #{y(d)})")
        .attr("class", "y tick")

    yticks.append("svg:line")
        .attr("x1", 0)
        .attr("y1", 0)
        .attr("x2", w)
        .attr("y2", 0)

    yticks.append("svg:text")
        .text(y.tickFormat(yTickCount))
        .attr("text-anchor", "start")
        .attr("dy", 5)
        .attr("dx", 2)


redraw = () ->

    durationTime = interval/2

    vis.selectAll("path")
        .data([data, more_data])
        .transition()
        .duration(durationTime)
        .attr("d", path)

    yrule = vis.selectAll("g.y")
        .data(y.ticks(yTickCount))
        .attr("transform", (d) -> "translate(0, #{y(d)})")

    yrule.select("text")
        .transition()
        .duration(durationTime)
        .text(y.tickFormat(yTickCount))

    yrule.select("line")
        # .transition()
        # .duration(durationTime)
        .attr("y1", 0)
        .attr("y2", 0)

    newrule = yrule.enter()
    newrule.append("svg:g")
        # .attr("transform", (d) -> "translate(0, #{y(d)})")
        .attr("class", "y tick")

    newrule.append("svg:line")
        .attr("x1", 0)
        .attr("y1", 0)
        .attr("x2", w)
        .attr("y2", 0)

    newrule.append("svg:text")
        .text("new")
        .attr("text-anchor", "start")
        .attr("dy", 5)
        .attr("dx", 2)


    oldrule = yrule.exit()
    oldrule.transition().duration(durationTime).remove()
