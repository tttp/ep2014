<script>
{assign var="epgroup_field" value="group"}
{assign var="country_field" value="custom_3"}
{assign var="party_field" value="custom_5"}
{assign var="return_party" value="organization_name,nick_name,legal_name,country,$epgroup_field"}

var selector = "#ep2014";
var epgroup_field = "{$epgroup_field}";
var countries_flat = {crmAPI sequential=0 entity="Constant" name="country"}.values;
var countries = {crmAPI entity="Country" sequential=0}.values;

var country_field = "{$country_field}";
var party_field = "{$party_field}";

var parties = {crmAPI entity="Contact" contact_sub_type="party" option_limit=1000 return="organization_name,country,custom_10" option_sort="organization_name ASC"}.values;

var epgroups = {crmAPI entity="Contact" contact_sub_type="epparty" sequential=0 return="organization_name,nick_name,legal_name" option_limit=1000}.values;


var candidates = {crmAPI entity="Candidate" return="created"}.values;

{literal}
var epgroups_color = {
"eu left":"#df73be",
"PES":"#ec2335",
"EFA":"#67bd1b",
"EGP":"#67bd1b",
"ALDE":"#f1cb01",
"EFD":"#60c0e2",
"PPE":"blue",
"EPP":"blue",
"MELD":"#00cc44",
"EUD":"#00cc99",
"ECPM":"#00cc",
"PPEU":"purple",
"ECR":"darkblue",
"Non-attached Members":"grey",
"NA/NI":"grey",
"EDP":"cyan",
"AECR":"brown",
"None":"pink"
};

var seats= {"DE":"96","FR":"74","GB":"73","IT":"73","ES":"54","PL":"51","RO":"32","NL":"26","GR":"21","BE":"21","PT":"21","CZ":"21","HU":"21","SE":"20","AT":"18","BG":"17","DK":"13","SK":"13","FI":"13","IE":"11","HR":"11","LT":"11","SL":"8","LV":"8","SI":"7","EE":"6","CY":"6", "LU":"6","MT":"6"};

  var color = d3.scale.linear()
    .clamp(true)
    .domain([0, 0.9, 1, 10])
    .range(["#b00000","#f4d8d8","#d0e5cc","#3a6033"])
    .interpolate(d3.interpolateHcl);

var parties_flat = {"_": {}}; 
var parties_map = {}; 

cj(function($) {
    countries_flat["_"]="-select-";
    $("h1").html(candidates.length +" candidates").hide();

    $.each(countries_flat, function (n) {
      parties_flat[n]= {};
    });
    $.each(parties, function(n) {
      if (!parties[n].country_id)
        parties[n].country_id = "_";
      parties_flat[parties[n].country_id][parties[n].id]=parties[n].organization_name;
      parties_flat[parties[n].id]=parties[n].organization_name;
      parties_map[parties[n].id]=[n];
    });

    var dateFormat = d3.time.format("%Y-%m-%d");
    $.each(candidates, function(n,c) {
       c.dateCreated = dateFormat.parse(c.created);
    });

    draw ();
  
});

function draw () {
  var ndx = crossfilter(candidates),
  all = ndx.groupAll();


  var group = ndx.dimension(function(d) {
    if (!d.party || !parties_map[d.party] || !parties[parties_map[d.party]]) return "";
    return parties[parties_map[d.party]].custom_10;
  });
  var groupGroup   = group.group().reduceSum(function(d) {   return 1; });
  var pie_group = dc.pieChart(selector +  " .group").innerRadius(20).radius(70);


  var party = ndx.dimension(function(d) {
    if (typeof d.party == "undefined") return "";
    return d.party;
  });
  var groupParty   = party.group().reduceSum(function(d) {   return 1; });
  var pie_party = dc.pieChart(selector +  " .party").innerRadius(20).radius(70);

  drawDate (ndx, " .date");
  drawCandidate (ndx, selector + " .list");
  drawParty (ndx,  selector + " .partyheat");
  drawBinary (ndx, selector + " .email","email");
  drawBinary (ndx, selector + " .website","website");
  drawBinary (ndx, selector + " .facebook","facebook");
  drawBinary (ndx, selector + " .twitter","twitter");

  var bar_country = dc.barChart(selector + " .country");
  var country = ndx.dimension(function(d) {
    if (typeof d.country == "undefined" || !(d.country in countries)) return "";
    return countries[d.country].name;
  });
  var countryGroup   = country.group().reduceSum(function(d) { return 1; });
  var countryGroup   = country.group().reduce(
      function(a,d) {a.count +=1; a.id= d.country; return a; },
      function(a,d) {a.count -=1; a.id =d.country; return a; },
      function() {return {count:0,score:0}; }
      );

 
 pie_party
  .width(200)
  .height(200)
  .dimension(party)
  .label(function (d) { 
   if (!d.key) return "x";
   if (!parties_flat[d.key]) return "?";
    return (parties_flat[d.key].nick_name || parties_flat[d.key].organization_name);})
  .title(function (d) { 
    if (!d.key) return "xx";
    return parties_flat[d.key].organization_name;})
  .colors(d3.scale.category20())
  .group(groupParty)
  .renderlet(function (chart) {
  });

 pie_group
  .width(200)
  .height(200)
  .dimension(group)
  .group(groupGroup)
    .colorCalculator(function(d, i) {
      if (epgroups[d.key]) {
        return epgroups_color[epgroups[d.key].organization_name];
}
      return "pink";
    })

  .label(function (d) { 
    if (!d.key) return "?";
    return epgroups[d.key].organization_name || "?";
  })
  .title(function (d) { 
    if (!d.key) return "??";
    return epgroups[d.key].legal_name || epgroups[d.key].organization_name;
  })

  .renderlet(function (chart) {
  });

 bar_country
  .width(444)
  .height(200)
  .outerPadding(0)
  .gap(1)
/*  .label(function (d) { 
    if (!d.key) return "?";
    return countries[d.key].iso_code;
  })
  .title(function (d) { 
    if (!d.key) return "(missing)";
    return countries[d.key].name;
  })*/
  .valueAccessor (
      function(d) {
      return d.value.count;
      })

  .margins({top: 0, right: 0, bottom: 95, left: 40})
  .x(d3.scale.ordinal())
  .xUnits(dc.units.ordinal)
  .brushOn(false)
  .elasticY(true)
  .yAxisLabel("nb Candidates")
  .dimension(country)
  .colorCalculator(function(d, i) { 
     if (!d.value.id || !d.value.id in countries) return "#000"; 
     return color(d.value.count/seats[countries[d.value.id].iso_code]);
   })

  .group(countryGroup);

 bar_country.on("postRender", function(c) {rotateBarChartLabels();} );


function rotateBarChartLabels() {
  d3.selectAll(selector+ ' .country .axis.x text')
    .style("text-anchor", "end" )
    .attr("transform", function(d) { return "rotate(-90, -4, 9) "; });
}

function drawDate (ndx,selector) {
  var chart = dc.lineChart(selector);

  var dim = ndx.dimension(function(d) {
      return d.dateCreated;
      });

  var _group = dim.group().reduceSum(function(d) {return 1;});

  var group = {
    all:function () {
      var total = 0, g= [];
      _group.all().forEach(function(d,i) {total += d.value; g.push({key:d.key,value:total})});
      return g;
    }
  };
  chart
    .width(666)
    .height(140)
    .margins({top: 0, right: 0, bottom: 20, left: 40})
    .x(d3.time.scale().domain([new Date("2014-02-14"),new Date("2014-05-22")]))
    .brushOn(true)
    .renderArea(true)
    .elasticY(true)
    .yAxisLabel("nb Candidates")
    .dimension(dim)
    .group(group)
}

function drawBinary (ndx,selector,attribute) {
  var dim = ndx.dimension(function(d) {
    if (typeof d[attribute] == "undefined" || !d[attribute])
      return "Missing";
    return "Complete";
  });
  var group   = dim.group().reduceSum(function(d) {   return 1; });
  var pie = dc.pieChart(selector).innerRadius(3).radius(25)
  .width(50)
  .height(50)
  .dimension(dim)
  .renderLabel(false)
  .colors(d3.scale.ordinal().range(['#3a6033','#b00000']))
  .group(group);
}

function drawCandidate (ndx,selector) {

  dc.dataTable(selector)
        .dimension(party)
        .group(function (d) {
//            return parties[parties_map[d.party]].custom_10;
            if (!d.party || !parties[d.party]) return "";
              return parties[d.party].organization_name || "";
            return d.party;
        })
        .size(100)
        .columns([
            function (d) {
                return d.first_name || "";
            },
            function (d) {
                return d.last_name || "";
            },
            function (d) {
                if (!d.party || !parties_map[d.party]) return "?";
                return parties[parties_map[d.party]].organization_name || "??";
            },
            function (d) {
                if (!d.country || !countries[d.country]) return "?";
                return countries[d.country].iso_code || "??";
            },
            function (d) {
                if (!d.party || !parties_map[d.party] || ! epgroups[parties[parties_map[d.party]].custom_10]) return "?";
                return epgroups[parties[parties_map[d.party]].custom_10].organization_name || "??";
            }
        ])
        .sortBy(function (d) {
            return d.last_name;
        })
        .order(d3.ascending)
} 

function drawParty (ndx,selector) {
  var dim = ndx.dimension(function(d) {
    if (typeof d.party === "undefined" || typeof parties_map[d.party] === "undefined") return "";
    return [d.country,parties[parties_map[d.party]].custom_10];
  });
  var group   = dim.group().reduceSum(function(d) { return +1; });

  var chart = dc.heatMap(selector)
    .width(35 * 15 + 80)
    .height(40 * 5 + 40)
    .dimension(dim)
    .group(group)
    .keyAccessor(function(d) { 
      if (countries[+d.key[0]])
        return countries[d.key[0]].iso_code;
      return "?";
    })
    .valueAccessor(function(d) { 
      if (epgroups[+d.key[1]]) 
        return epgroups[+d.key[1]].organization_name;
      return "?";

 })
  .colorCalculator(function(d, i) { 
      //  return color(d.value.count/seats[countries[d.value.id].iso_code]);
      if (countries[+d.key[0]])
        return color(10*d.value/seats[countries[d.key[0]].iso_code]);
       return +d.value; })
    .title(function(d) {
        return d.value})
//    .colors(["#b00000","#f4d8d8","#d0e5cc","#3a6033"])
//    .calculateColorDomain();

}

  dc.dataCount(".dc-data-count")
    .dimension(ndx)
    .group(all);

  dc.renderAll();


};

{/literal}
</script>

{literal}
<style>
#binaries {width:60px;}
#ep2014 .clear {clear:both}

.heat-box {
  stroke: #E6E6E6;
  stroke-width: 2px;
}
</style>
{/literal}

<div id="ep2014"> 
    <div> 
        <div class="dc-data-count"> 
            <span class="filter-count"></span> selected out of <span class="total-count"></span> candidates | <a 
                href="javascript:dc.filterAll(); dc.renderAll();">Show all candidates</a> 
        </div> 
    </div> 
<div class="date"></div> 
<div class="country"></div> 
<div class="group"></div> 
<div class="partyheat"></div> 
<div id="binaries" class ="dc-chart"> 
  <div class="email">Email</div> 
  <div class="website">Website</div> 
  <div class="facebook">Facebook</div> 
  <div class="twitter">Twitter</div> 
</div>
<div class="no.party"></div>
<div class="clear">
    <table class="table table-hover list">
        <thead>
        <tr class="header">
            <th>First Name</th>
            <th>Last Name</th>
            <th>Party</th>
            <th>Country</th>
            <th>EU</th>
        </tr>
        </thead>
    </table>

</div> 
<div class="clear"></div>
</div>
