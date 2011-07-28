w = 700
h = 300
p = 40
interval = 1000

data = []
ranks = []
data.push({name:"Barry", votes:0, color:"#ff0000", rank:0})
data.push({name:"David", votes:0, color:"#00ff00", rank:1})
data.push({name:"Luca",  votes:0, color:"#0000ff", rank:2})
data.push({name:"Toons", votes:0, color:"#33c9fb", rank:3})
data.push({name:"Misha", votes:0, color:"#c33e8b", rank:4})

maxvotes = d3.max(data.map((d) -> d.votes))
x = d3.scale.linear().domain([0, maxvotes]).range([p, w - p * 2]) # WHY?!
y = d3.scale.ordinal().domain(d3.range(data.length)).rangeBands([0, h], .2)

setInterval(
    () ->
        data.map((d) -> d.votes += Math.round(Math.random() * Math.random() * 1000))
        rankeddata = data.slice(0)
        rankeddata.sort((candidate1, candidate2) -> candidate2.votes - candidate1.votes)
        i = 0
        while i < rankeddata.length
            ranks[rankeddata[i].name] = {rank:i, votes:rankeddata[i].votes}
            i++
        maxvotes = d3.max(data.map((d) -> d.votes))
        x = d3.scale.linear().domain([0, maxvotes]).range([p, w - p * 2]) # WHY?!
        redraw()
        data = rankeddata
    , interval)

vis = d3.select("#chart")
    .append("svg:svg")
    .attr("width", w + p)
    .attr("height", h + p)
    .append("svg:g")
    .attr("transform", "translate(#{p},#{p})")

vis.selectAll("rect")
    .data(data)
    .enter()
    .append("svg:rect")
    .attr("x", p + 10)
    .attr("y", (d, i) -> y(i))
    .attr("height", 50)
    .style("fill", (d) -> d.color)
    .attr("width", (d) -> x(d.votes))

vis.selectAll("text.votes")
    .data(data)
    .enter()
    .append("svg:text")
    .attr("class", "votes")
    .attr("x", (d) -> x(d.votes))
    .attr("y", (d, i) -> y(i))
    .attr("dx", 30)
    .attr("dy", 35)
    .attr("text-anchor", "end")
    .text((d) -> d.votes)

vis.selectAll("text.candidates")
    .data(data)
    .enter()
    .append("svg:text")
    .attr("class", "candidates")
    .attr("x", 0)
    .attr("y", (d, i) -> y(i))
    .attr("dx", -p)
    .attr("dy", 35)
    .attr("text-anchor", "start")
    .text((d) -> d.name)

redraw = () ->
    durationTime = interval
    vis.selectAll("rect")
        .data(data)
        .transition()
        .duration(durationTime)
        .ease("linear")
        .attr("width", (d) -> x(d.votes))
        .attr("y", (d) -> y(ranks[d.name].rank))

    vis.selectAll("text.votes")
        .data(data)
        .transition()
        .duration(durationTime)
        .attr("x", (d) -> x(d.votes))
        .attr("y", (d) -> y(ranks[d.name].rank))
        .text((d) -> ranks[d.name].votes)

    vis.selectAll("text.candidates")
        .data(data)
        .transition()
        .duration(durationTime)
        .attr("y", (d) -> y(ranks[d.name].rank))
