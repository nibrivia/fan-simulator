
//data = [.1,.2,.3,.4,.1,.4,.3]

var size = Math.min(height, width);


// Scales
var x_scale = d3.scaleLinear()
  .domain([-1.1, 1.1])
  .range([width/2-size/2, width/2+size/2]);

var y_scale = d3.scaleLinear()
  .domain([-1.1, 1.1])
  .range([height/2-size/2, height/2+size/2]);

var col_scale = d3.scaleSequential()
  .domain([-1, 1])
  .interpolator(d3.interpolateRainbow);


// LEDs...
svg.style("background", "black");

var leds = svg.selectAll('circle')
  .data(data, function(d) { return d.blade*1000+d.led; });

leds.exit()
    .remove();

leds.enter().append('circle')
    .attr("r", "1px")
  .merge(leds)
    .attr("cx", function(d) { return x_scale(d.x); })
    .attr("cy", function(d) { return y_scale(d.y); })
    .style("fill", function(d) { return col_scale(d.y)});


