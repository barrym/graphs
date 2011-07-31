socket = io.connect('http://localhost:8888')

socket.on('connect', () ->
    console.log("connected")
)

socket.on('mt_sent_update', (new_data) ->
    for data in new_data
        if !mt_sent_data[data.operator]
            mt_sent_data[data.operator] = d3.range(60).map((x) -> {operator:data.operator,time:x,value:1})

            # Redraw, is this bad?
            vis.selectAll("path")
                .data(d3.values(mt_sent_data))
                .enter()
                .append("svg:path")
                .attr("d", path)
                .attr("class", (d) -> d3.first(d).operator)

        mt_sent_data[data.operator].shift()
        mt_sent_data[data.operator].push(
            {
                operator:data.operator,
                time:data.time,
                value:data.value
            }
        )

    times.push({
        time:d3.last(d3.first(d3.values(mt_sent_data))).time
    })
    times.shift()

    calculate_scales()
    redraw()
)






mt_sent_data = []
# Slight hack to initialise the array
['uk_o2'].map((operator) ->
    mt_sent_data[operator] = d3.range(60).map((x) -> {operator:operator,time:x,value:1})
)


w = 700
h = 300
p = 30
durationTime = 500
x = null
y = null
yTickCount = 10

times = d3.first(d3.values(mt_sent_data)).map((d) ->
    {
        time: d.time
    }
    )

calculate_scales = () ->
    values = d3.merge(d3.values(mt_sent_data).map((data_objects) -> data_objects.map((d) -> d.value)))
    max = d3.max(values)
    x = d3.scale.linear().domain([d3.min(times.map((d) -> d.time)), d3.max(times.map((d) -> d.time))]).range([0 + 2 * p, w - p])
    y = d3.scale.linear().domain([0, max]).range([h - p, 0 + p])


$('#ytickcount_text_input').val(yTickCount)

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

vis.selectAll("path")
    .data(d3.values(mt_sent_data))
    .enter()
    .append("svg:path")
    .attr("d", path)
    .attr("class", (d) -> d3.first(d).operator)

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
        .data(d3.values(mt_sent_data))
        .attr("transform", "translate(#{x(times[5].time) - x(times[4].time)})")
        .attr("d", path)
        .transition()
        .ease("linear")
        .duration(durationTime)
        .attr("transform", "translate(0)")
