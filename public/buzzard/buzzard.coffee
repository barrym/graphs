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
x = null
y = null
yTickCount = 10

times = uk_o2.map((d) ->
    {
        time: d.time,
        visible: if d.time % 5 == 0 then true else false
    }
    )

calculate_scales = () ->
    uk_o2_values = uk_o2.map((d) -> d.value)
    uk_vodafone_values = uk_vodafone.map((d) -> d['value'])
    max = d3.max(uk_o2_values.concat(uk_vodafone_values))
    x = d3.scale.linear().domain([d3.min(times.map((d) -> d.time)), d3.max(times.map((d) -> d.time))]).range([0 + 2 * p, w - p])
    y = d3.scale.linear().domain([0, max]).range([h - p, 0 + p])


$('#modifier_text_input').val(modifier)
$('#ytickcount_text_input').val(yTickCount)

$('#modifier_text_input').change((e) ->
    modifier = parseInt($('#modifier_text_input').val())
)

$('#ytickcount_text_input').change((e) ->
    yTickCount = parseInt($('#ytickcount_text_input').val())
)


calculate_scales()

vis = d3.select("#chart")
    .append("svg:svg")
    .attr("width", w + p * 2)
    .attr("height", h + p * 2)
    .append("svg:g")
    .attr("transform", "translate(#{p}, #{p})")

path = d3.svg.line()
    .x((d, i) -> x(d.time))
    .y((d) -> y(d.value))
    .interpolate("linear")

yrule = vis.selectAll("g.y")
    .data(y.ticks(yTickCount))
    .enter()
    .append("svg:g")
    .attr("class", "y")

yrule.append("svg:line")
    .style("shape-rendering", "crispEdges")
    .attr("x1", p)
    .attr("y1", y)
    .attr("x2", w)
    .attr("y2", y)

yrule.append("svg:text")
    .text(y.tickFormat(yTickCount))
    .attr("text-anchor", "end")
    .attr("x", p)
    .attr("y", y)
    .attr("dx", -5)

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
        times.push({
            time:d3.last(uk_o2).time,
            visible: if d3.last(uk_o2).time % 5 == 0 then true else false
        })
        times.shift()
        calculate_scales()

        redraw()
    , interval)


redraw = () ->

    yrule = vis.selectAll("g.y")
        .data(y.ticks(yTickCount))

    # NEW
    newyrule = yrule.enter().append("svg:g")
        .attr("class", "y")

    newyrule.append("svg:line")
        .attr("x1", p)
        .attr("y1", 0)
        .attr("x2", w)
        .attr("y2", 0)
        .transition()
        .duration(durationTime)
        .ease("bounce")
        .attr("y1", y)
        .attr("y2", y)

    newyrule.append("svg:text")
        .attr("text-anchor", "end")
        .attr("x", p)
        .attr("y", 0)
        .transition()
        .duration(durationTime)
        .ease("bounce")
        .attr("y", y)
        .attr("dx", -5)
        .text(y.tickFormat(yTickCount))

    # UPDATES
    yrule.select("text")
        .transition()
        .duration(durationTime)
        .attr("y", y)
        .text(y.tickFormat(yTickCount))

    yrule.select("line")
        .transition()
        .duration(durationTime)
        .attr("y1", y)
        .attr("y2", y)

    # OLD
    oldyrule = yrule.exit()

    oldyrule.select("line")
            .transition()
            .duration(durationTime)
            .ease("back")
            .attr("y1", 0)
            .attr("y2", 0)
            .style("opacity", 0)
            .remove()

    oldyrule.select("text")
            .transition()
            .duration(durationTime)
            .ease("back")
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
