count = 0
xrule_data = []
xrulePeriod = 10

mt_sent_data = []
# Slight hack to initialise the array
['uk_o2'].map((operator) ->
    mt_sent_data[operator] = d3.range(60).map((x) -> {operator:operator,time:x,value:1})
)


w = 500
h = 300
p = 30
durationTime = 500
x = null
y = null
yTickCount = 10

times = d3.first(d3.values(mt_sent_data)).map((d) -> d.time)

socket = io.connect('http://localhost:8888')

socket.on('connect', () ->
    console.log("connected")
)

socket.on('mt_sent_update', (new_data) ->
    for data in new_data
        if !mt_sent_data[data.operator]
            mt_sent_data[data.operator] = d3.range(60).map((x) -> {operator:data.operator,time:x,value:1})

            # Redraw, is this bad? Move to redraw() ?
            vis.selectAll("path")
                .data(d3.values(mt_sent_data))
                .enter()
                .append("svg:path")
                .attr("d", path)
                .attr("class", (d) -> d3.first(d).operator)

            vis.selectAll("rect.legend")
                .data(d3.keys(mt_sent_data))
                .enter()
                .append("svg:rect")
                .attr("x", w + 10)
                .attr("y", (d, i) -> (i * 30))
                .attr("height", 15)
                .attr("width", 15)
                .attr("class", (d) -> "legend #{d}")

            vis.selectAll("text.legend")
                .data(d3.keys(mt_sent_data))
                .enter()
                .append("svg:text")
                .attr("x", w + 10)
                .attr("y", (d, i) -> (i * 30))
                .attr("class", "legend")
                .attr("dx", 20)
                .attr("dy", 12)
                .text(String)


        mt_sent_data[data.operator].shift()
        mt_sent_data[data.operator].push(
            {
                operator:data.operator,
                time:data.time,
                value:data.value
            }
        )

    latest_timestamp = d3.last(d3.first(d3.values(mt_sent_data))).time
    times.push(latest_timestamp)
    times.shift()

    count++
    if count == xrulePeriod
        console.log("displaying this date #{latest_timestamp}")
        xrule_data.push({time:latest_timestamp})
        if xrule_data.length == (60/xrulePeriod) + 1 # On first load it might not have 3 elements
            console.log("removing")
            xrule_data.shift()
        count = 0


    calculate_scales()
    redraw()
)

calculate_scales = () ->
    values = d3.merge(d3.values(mt_sent_data).map((data_objects) -> data_objects.map((d) -> d.value)))
    max = d3.max(values)
    x = d3.scale.linear().domain([d3.min(times), d3.max(times)]).range([0 + 2 * p, w - p])
    y = d3.scale.linear().domain([0, max]).range([h - p, 0 + p])

dateFormatter = d3.time.format("%H:%M:%S")
formatDate = (timestamp) ->
    date = new Date(timestamp * 1000)
    dateFormatter(date)

$('#ytickcount_text_input').val(yTickCount)

$('#ytickcount_text_input').change((e) ->
    yTickCount = parseInt($('#ytickcount_text_input').val())
)


calculate_scales()

vis = d3.select("#chart")
    .append("svg:svg")
    .attr("width", w + p * 6) # To make room for the labels
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

xrule = vis.selectAll("g.x")
    .data(xrule_data, (d) -> d.time)
    .enter()
    .append("svg:g")
    .attr("class", "x")

xrule.append("svg:line")
    .style("shape-rendering", "crispEdges")
    .attr("x1", (d) -> x(d.time))
    .attr("y1", h)
    .attr("x2", (d) -> x(d.time))
    .attr("y2", h-10)

xrule.append("svg:text")
    .attr("x", (d) -> x(d.time))
    .attr("y", h)
    .text(String)


redraw = () ->

    yrule = vis.selectAll("g.y")
        .data(y.ticks(yTickCount))


    xrule = vis.selectAll("g.x")
        .data(xrule_data, (d) -> d.time)


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

    newxrule = xrule.enter().append("svg:g")
        .attr("class", "x")

    newxrule.append("svg:line")
        .style("shape-rendering", "crispEdges")
        .attr("x1", w + p)
        .attr("y1", h)
        .attr("x2", w + p)
        .attr("y2", 0)
        .transition()
        .duration(durationTime)
        .ease("bounce")
        .attr("x1", (d) -> x(d.time))
        .attr("x2", (d) -> x(d.time))

    newxrule.append("svg:text")
        .text((d) -> formatDate(d.time))
        .style("font-size", "12")
        .attr("text-anchor", "middle")
        .attr("x", w + p)
        .attr("y", h)
        .transition()
        .duration(durationTime)
        .ease("bounce")
        .attr("x", (d) -> x(d.time))

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

    xrule.select("line")
        .transition()
        .duration(durationTime)
        .ease("linear")
        .attr("x1", (d) -> x(d.time))
        .attr("x2", (d) -> x(d.time))

    xrule.select("text")
        .transition()
        .duration(durationTime)
        .ease("linear")
        .attr("x", (d) -> x(d.time))
        # .attr("y", h)
        # .text(String)

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

    oldxrule = xrule.exit()

    oldxrule.select("line")
            .transition()
            .duration(durationTime)
            # .ease("back")
            # .attr("x1", 0 - p)
            # .attr("x2", 0 - p)
            .style("opacity", 0)
            .remove()

    oldxrule.select("text")
            .transition()
            .duration(durationTime)
            # .ease("linear")
            # .attr("x", 0 - p)
            .style("opacity", 0)
            .remove()

    oldxrule.transition().duration(durationTime).remove()

    vis.selectAll("path")
        .data(d3.values(mt_sent_data))
        .attr("transform", "translate(#{x(times[5]) - x(times[4])})")
        .attr("d", path)
        .transition()
        .ease("linear")
        .duration(durationTime)
        .attr("transform", "translate(0)")
