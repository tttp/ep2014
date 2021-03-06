<link href="//netdna.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet">

<script>
{assign var="epgroup_field" value="group"}
{assign var="country_field" value="custom_3"}
{assign var="party_field" value="custom_5"}
{assign var="return_party" value="organization_name,nick_name,legal_name,country,$epgroup_field"}

var selector = "#ep2019";
var epgroup_field = "{$epgroup_field}";
var countries_flat = {crmAPI sequential=0 entity="Constant" name="country"}.values;
var countries = {crmAPI entity="Country" sequential=0}.values;

var country_field = "{$country_field}";
var party_field = "{$party_field}";

var parties = {crmAPI entity="Contact" contact_sub_type="party" option_limit=1000 return="organization_name,country,custom_10" option_sort="organization_name ASC"}.values;

var epgroups = {crmAPI entity="Contact" contact_sub_type="epparty" sequential=0 return="organization_name,nick_name,legal_name" option_limit=1000}.values;

var constituencies = {crmAPI entity="Contact" contact_sub_type="constituency" sequential=0 return="organization_name,nick_name,legal_name" option_limit=1000}.values;


var candidates = {crmAPI entity="Candidate"  return="created"}.values;

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

countryID = function (iso) {
  for (a in countries) {
    if (countries[a].iso_code == iso) {
      return countries[a].name;
    }
  }
  return iso; //didn't find the country             
};

var seats= {"DE":"96","FR":"74","GB":"73","IT":"73","ES":"54","PL":"51","RO":"32","NL":"26","GR":"21","BE":"21","PT":"21","CZ":"21","HU":"21","SE":"20","AT":"18","BG":"17","DK":"13","SK":"13","FI":"13","IE":"11","HR":"11","LT":"11","SL":"8","LV":"8","SI":"7","EE":"6","CY":"6", "LU":"6","MT":"6"};

  var color = d3.scale.linear()
    .clamp(true)
    .domain([0, 0.9, 1, 1.1, 10])
    .range(["#b00000","#f4d8d8","#0ef609","#d0e5cc","#3a6033"])
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
    $("body").on("click","td._0", function () {
      $thumb= $(this).find(".fa");
      if ($thumb.hasClass("fa-thumbs-o-down")) {
        $thumb.removeClass("fa-thumbs-o-down").addClass("fa-thumbs-o-up");
        CRM.api("candidate","create",{"elected":"1",id:$thumb.data("id")});
      } else {
        $thumb.removeClass("fa-thumbs-o-up").addClass("fa-thumbs-o-down");
        CRM.api("candidate","create",{"elected":"",id:$thumb.data("id")});
      }
    });
  
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

//  drawDate (ndx, " .date");
  drawCandidate (ndx, selector + " .list");
  drawConstituency (ndx)
//  drawParty (ndx,  selector + " .partyheat");
  drawBinary (ndx, selector + " .elected","elected");
  drawBinary (ndx, selector + " .priority","priority");
//  drawBinary (ndx, selector + " .email","email");
//  drawBinary (ndx, selector + " .website","website");
//  drawBinary (ndx, selector + " .facebook","facebook");
//  drawBinary (ndx, selector + " .twitter","twitter");

  var bar_country = dc.barChart(selector + " .country");
  var country = ndx.dimension(function(d) {
    if (typeof d.country == "undefined" || !(d.country in countries)) return "";
    return countries[d.country].iso_code;
  });
  var countryGroup   = country.group().reduceSum(function(d) { return 1; });
  var countryGroup   = country.group().reduce(
      function(a,d) {a.count +=1; a.id= d.country; return a; },
      function(a,d) {a.count -=1; a.id =d.country; return a; },
      function() {return {count:0,score:0}; }
      );

 
 pie_party
  .width(140)
  .height(140)
  .dimension(party)
  .title(function (d) { 
     if (typeof(d.key) == 'undefined') return ".";
     if (typeof(parties_map[d.key]) == 'undefined') return "?";
     if (typeof(parties[parties_map[d.key]]) == 'undefined') return "??";
       return parties[parties_map[countryID(d.key)]].organization_name + ":" +d.value;
  })
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
    if (!d.data || !d.data.key) return "xx";
    return parties_flat[d.data.key];})
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
  .title(function (d) { 
    if (!d.key) return "(missing)";
    if (!countries[d.key]) return "(missing)";
    return countries[d.key].name + " "+ d.values + " seats: "+ seats[countryID(d.key)];
  })
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

function drawConstituency (ndx) {
  var selector =".constituency";
  var dim = ndx.dimension(function(d) {
    if (typeof d.constituency == "undefined" || !d.constituency)
      return "";
    if (!constituencies[d.constituency])
      return d.constituency;
    return constituencies[d.constituency].organization_name;
  });
  var group   = dim.group().reduceSum(function(d) {   return 1; });
  var pie = dc.pieChart(selector).innerRadius(3).radius(60)
  .width(200)
  .height(200)
  .dimension(dim)
  .renderLabel(false)
  .colors(d3.scale.category20())
  .group(group);
}

function drawBinary (ndx,selector,attribute) {
  var dim = ndx.dimension(function(d) {
    if (typeof d[attribute] == "undefined" || !d[attribute])
      return "";
    return attribute;
  });
  var group   = dim.group().reduceSum(function(d) {   return 1; });
  var pie = dc.pieChart(selector).innerRadius(3).radius(25)
  .width(50)
.minAngleForLabel(0)
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
        .size(10000)
        .columns([
            function (d) { 
              var dir ="down";
              if (d.elected)
                dir ="up";
              return '<i class="fa fa-thumbs-o-'+dir+'" title="click to change the elected status" data-id="'+d.id+'"></i>';
            },
            function (d) {
              var name = d.first_name +" "+ d.last_name;
              if (d.priority)
                var name ="<b>"+name+"</b>";
              return "<a href='/civicrm/contact/view?cid="+d.id+"'>" + name+"</a>";
            },
            function (d) {
                if (!d.party || !parties_map[d.party]) return "?";
                return parties[parties_map[d.party]].organization_name || "??";
            },
            function (d) {
              if (typeof d.constituency == "undefined" || !d.constituency)
                return "";
              if (!constituencies[d.constituency])
                return d.constituency;
              return constituencies[d.constituency].organization_name;
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

.dc-chart {position:relative;}
.dc-chart svg {z-index:100;}
.dc-chart h2 {position:absolute;font-size:18px;color:grey;text-align:center;width:100%}

td._0 {cursor:pointer;}

#binaries {width:60px;}
#ep2019 .clear {clear:both}

.heat-box {
  stroke: #E6E6E6;
  stroke-width: 2px;
}
</style>
{/literal}

<div id="ep2019"> 
    <div> 
        <div class="dc-data-count"> 
            <span class="filter-count"></span> selected out of <span class="total-count"></span> candidates | <a 
                href="javascript:dc.filterAll(); dc.renderAll();">Show all candidates</a> 
        </div> 
    </div> 
<div class="date"></div> 
<div class="country"></div> 
<div class="group"></div> 
<div class="party"><h2>Nat Party</h2></div> 
<div class="constituency"><h2>Constituency<h2></div> 
<div id="binaries" class ="dc-chart"> 
  <div class="elected">Elected</div> 
  <div class="priority">Priority</div> 
  <!--div class="email">Email</div> 
  <div class="website">Website</div> 
  <div class="facebook">Facebook</div> 
  <div class="twitter">Twitter</div--> 
</div>
<div class="clear">
    <table class="table table-hover list">
        <thead>
        <tr class="header">
            <th>Won</th>
            <th>Name</th>
            <th>Party</th>
            <th>Constituency</th>
            <th>Country</th>
            <th>EU</th>
        </tr>
        </thead>
    </table>

</div> 
<div class="clear"></div>
</div>
