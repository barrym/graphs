foo = 0
next = (x) ->
    foo = x
    {
        time: x * 3,
        value: Math.round(Math.random() * modifier)
    }

modifier = 500
xpoints = 60

uk_o2       = d3.range(xpoints).map(next)
uk_vodafone = d3.range(xpoints).map(next)

w = 700
h = 300
p = 30
interval = 1000
durationTime = 500


uk_o2_values = uk_o2.map((d) -> d.value)
times = uk_o2.map((d) ->
    {
        time: d.time,
        visible: if d.time % 5 == 0 then true else false
    }
    )
uk_vodafone_values = uk_vodafone.map((d) -> d.value)
max = d3.max(uk_o2_values.concat(uk_vodafone_values))

x = d3.scale.linear().domain([d3.min(times.map((d) -> d.time)), d3.max(times.map((d) -> d.time))]).range([0 + p, w - p])
y = d3.scale.linear().domain([0, 5000]).range([h - p, 0 + p])

xTickCount = 10
yTickCount = 10


$('#modifier_text_input').val(modifier)
$('#xtickcount_text_input').val(xTickCount)
$('#ytickcount_text_input').val(yTickCount)

$('#modifier_text_input').change((e) ->
    modifier = parseInt($('#modifier_text_input').val())
)

$('#xtickcount_text_input').change((e) ->
    xTickCount = parseInt($('#xtickcount_text_input').val())
)


$('#ytickcount_text_input').change((e) ->
    yTickCount = parseInt($('#ytickcount_text_input').val())
)



vis = d3.select("#chart")
    .append("svg:svg")
    .attr("width", w + p * 2)
    .attr("height", h + p * 2)
    .append("svg:g")
    .attr("transform", "translate(#{p}, #{p})")


path = d3.svg.line()
    .x((d, i) -> x(d['time']))
    .y((d) -> y(d['value']))
    .interpolate("linear")

xrule = vis.selectAll("g.x")
    .data(x.ticks(xTickCount))
    .enter()
    .append("svg:g")
    .attr("class", "x")

xrule.append("svg:line")
    .style("shape-rendering", "crispEdges")
    .attr("x1", x)
    .attr("y1", 0)
    .attr("x2", x)
    .attr("y2", h)

xrule.append("svg:text")
    .attr("text-anchor", "middle")
    .attr("x", x)
    .attr("y", h)
    .attr("text-anchor", "middle")
    .text(x.tickFormat(xTickCount))

yrule = vis.selectAll("g.y")
    .data(y.ticks(yTickCount))
    .enter()
    .append("svg:g")
    .attr("class", "y")

yrule.append("svg:line")
    .style("shape-rendering", "crispEdges")
    .attr("x1", 0)
    .attr("y1", y)
    .attr("x2", w)
    .attr("y2", y)

yrule.append("svg:text")
    .text(y.tickFormat(yTickCount))
    .attr("text-anchor", "start")
    .attr("x", 0)
    .attr("y", y)

vis.selectAll("path.line")
    .data([uk_o2, uk_vodafone])
    .enter()
    .append("svg:path")
    .attr("d", path)
    .attr("class", (d, i) -> ( if i == 0 then "uk_o2" else "uk_vodafone"))


setInterval(
    () ->
        foo++
        uk_o2.push(next(foo))
        uk_vodafone.push(next(foo))
        uk_o2.shift()
        uk_vodafone.shift()
        uk_o2_values = uk_o2.map((d) -> d.value)
        times.push({
            time:d3.last(uk_o2).time,
            visible: if d3.last(uk_o2).time % 5 == 0 then true else false
        })
        times.shift()
        uk_vodafone_values = uk_vodafone.map((d) -> d['value'])
        max = d3.max(uk_o2_values.concat(uk_vodafone_values))

        x = d3.scale.linear().domain([d3.min(times.map((d) -> d.time)), d3.max(times.map((d) -> d.time))]).range([0 + p, w - p])
        # x = d3.scale.linear().domain([times.first, times.last]).range([0 + p, w - p])
        y = d3.scale.linear().domain([0, 5000]).range([h - p, 0 + p])
        redraw()
    , interval)


redraw = () ->

    xrule = vis.selectAll("g.x")
        .data(x.ticks(xTickCount))

    yrule = vis.selectAll("g.y")
        .data(y.ticks(yTickCount))

    # NEW
    newyrule = yrule.enter().append("svg:g")
        .attr("class", "y")

    newyrule.append("svg:line")
        .attr("x1", 0)
        .attr("y1", 0)
        .attr("x2", w)
        .attr("y2", 0)
        .transition()
        .duration(durationTime)
        .attr("y1", y)
        .attr("y2", y)

    newyrule.append("svg:text")
        .attr("text-anchor", "start")
        .attr("y", 0)
        .transition()
        .duration(durationTime)
        .attr("y", y)
        .text(y.tickFormat(yTickCount))

    # newxrule = xrule.enter().append("svg:g")
    #     .attr("class", "x")

    # newxrule.append("svg:line")
    #     .attr("x1", 0)
    #     .attr("y1", 0)
    #     .attr("x2", w)
    #     .attr("y2", h)
    #     .transition()
    #     .duration(durationTime)
    #     .attr("x1", x)
    #     .attr("x2", x)

    # newxrule.append("svg:text")
    #     .attr("text-anchor", "middle")
    #     .attr("x", w)
    #     .attr("y", h)
    #     .style("opacity", 0)
    #     .transition()
    #     .duration(durationTime)
    #     .style("opacity", 1)
    #     .attr("x", x)
    #     .attr("text-anchor", "middle")
    #     .text(x.tickFormat(xTickCount))

    # UPDATES
    yrule.select("text")
        .transition()
        .duration(durationTime)
        .attr("y", y)
        .text(y.tickFormat(yTickCount))

    xrule.select("text")
        .transition()
        .duration(durationTime)
        # .attr("x", x)
        .text(x.tickFormat(xTickCount))

    # xrule.select("line")
    #     .transition()
    #     .duration(durationTime)
    #     .attr("x1", x)
    #     .attr("x2", x)

    yrule.select("line")
        .transition()
        .duration(durationTime)
        .attr("y1", y)
        .attr("y2", y)

    # OLD
    oldxrule = xrule.exit()

    oldxrule.select("line")
            .transition()
            .duration(durationTime)
            .attr("x1", 0)
            .attr("x2", 0)
            .style("opacity", 0)
            .remove()

    oldxrule.select("text")
            .transition()
            .duration(durationTime)
            .attr("x", 0)
            .style("opacity", 0)
            .remove()

    oldxrule.transition().duration(durationTime).remove()

    oldyrule = yrule.exit()

    oldyrule.select("line")
            .transition()
            .duration(durationTime)
            .attr("y1", 0)
            .attr("y2", 0)
            .style("opacity", 0)
            .remove()

    oldyrule.select("text")
            .transition()
            .duration(durationTime)
            .attr("y", 0)
            .style("opacity", 0)
            .remove()

    oldyrule.transition().duration(durationTime).remove()

    vis.selectAll("path")
        .data([uk_o2, uk_vodafone])
        .attr("transform", "translate(#{x(times[5].time) - x(times[4].time)})")
        .attr("d", path)
        .transition()
        .ease("linear")
        .duration(durationTime)
        .attr("transform", "translate(0)")
