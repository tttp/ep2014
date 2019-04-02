<script>
{assign var="epgroup_field" value="custom_1"}
{assign var="country_field" value="custom_4"}
{assign var="party_field" value="custom_5"}
{assign var="return_party" value="organization_name,nick_name,legal_name,country,$epgroup_field"}

var selector = "#ep2019";
var epgroup_field = "{$epgroup_field}";
var countries = {crmAPI entity="Country" sequential=0}.values;

var country_field = "{$country_field}";
var party_field = "{$party_field}";

var parties = {crmAPI entity="Contact" sequential=0 contact_sub_type="party" option_limit=1000 return="organization_name,country,custom_10" option_sort="organization_name ASC"}.values;

var epgroups = {crmAPI entity="Contact" contact_sub_type="epgroup" sequential=0 return="organization_name,nick_name,legal_name" option_limit=1000}.values;


var meps = {crmAPI entity="Contact" contact_sub_type="EP2014" option_limit=1000 return="first_name,last_name,custom_5,custom_4"}.values;

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

  var color = d3.scaleLinear()
    .clamp(true)
    .domain([0, 0.9, 1, 10])
    .range(["#b00000","#f4d8d8","#d0e5cc","#3a6033"])
    .interpolate(d3.interpolateHcl);

var parties_flat = {"_": {}}; 
var parties_map = {}; 

cj(function($) {
    $("h1").html(meps.length +" meps").hide();

    $.each(parties, function(n) {
    });

    meps.forEach(function(d){
       d.country="?";
       if (d.custom_4 && countries[d.custom_4])
         d.country=countries[d.custom_4].name;
       d.party="?";
       if (d.custom_5 && parties[d.custom_5])
         d.party= parties[d.custom_5].organization_name;
       
    });

    draw ();
  
});

function draw () {
  var graphs =[];
  var ndx = crossfilter(meps),
  all = ndx.groupAll();

//  drawDate (ndx, " .date");
  graphs.table= drawMep (ndx,  " .list");
  graphs.total= drawTotal (  " .total");
     graphs.search = drawTextSearch('#input-filter', jQuery);
 
//  drawParty (ndx,  selector + " .partyheat");
//  drawBinary (ndx, selector + " .email","email");
//  drawBinary (ndx, selector + " .website","website");
//  drawBinary (ndx, selector + " .facebook","facebook");
//  drawBinary (ndx, selector + " .twitter","twitter");
  dc.renderAll();
    function drawTextSearch(dom, $, val) {

      var dim = ndx.dimension(function(d) {
        return d.first_name.toLowerCase() + " " + d.last_name.toLowerCase() + " " + d.party.toLowerCase() + " " + " " + d.country.toLowerCase()
      });

      var throttleTimer;

      $(dom).keyup(function() {

        var s = jQuery(this).val().toLowerCase();
        $(".resetall").attr("disabled", false);
        throttle();

        function throttle() {
          window.clearTimeout(throttleTimer);
          throttleTimer = window.setTimeout(function() {
            dim.filterAll();
            dim.filterFunction(function(d) {
              return d.indexOf(s) !== -1;
            });
            dc.redrawAll();
          }, 250);
        }
      });

      return dim;

    }


  function drawTotal(dom) {
    return dc
      .dataCount(dom)
      .dimension(ndx)
      .group(ndx.groupAll())
      .html({
        some: "%filter-count MEPs out of %total-count",
        all:
          '%total-count sitting MEPs. <span class="small">Click on charts to apply filters or use the search box</span>'
      });
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

function drawMep (ndx,selector) {

      var dim = ndx.dimension(function(d) {
        return 1
      });
  var graph=dc.dataTable(selector)
        .dimension(dim)
        .group(function (d) {
//            return parties[parties_map[d.party]].custom_10;
            if (!d.party || !parties[d.party]) return "";
              return parties[d.party].organization_name || "";
            return d.party;
        })
        .size(1000)
        .columns([
            function (d) {
              var checked = d.contact_sub_type.includes("Candidate") ? "checked" :"";
              return "<input type='checkbox' class='candidate' "+checked+" data-id='"+d.id+"'>";
            },
            function (d) {
                return d.first_name || "";
            },
            function (d) {
                return "<a href='/civicrm/contact/view?cid="+d.id+"'>" + d.last_name+"</a>";
            },
            function (d) {
                return d.party || "?";
            },
            function (d) {
                return d.country || "?";
            }
        ])
        .sortBy(function (d) {
            return d.last_name;
        })
        .order(d3.ascending)
        .on('renderlet', function(chart) {
          CRM.$(".list").on("click",".candidate",function() {
            var sub=["EP2014"];
            if (this.checked)
              sub.push("candidate");
            CRM.api3("Contact","create",{
              id:CRM.$(this).data("id"),
              contact_sub_type:sub
            },true);
             
          });

         })
   return graph;
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



};

{/literal}
</script>

{literal}
<style>
#binaries {width:60px;}
#ep2019 .clear {clear:both}

.heat-box {
  stroke: #E6E6E6;
  stroke-width: 2px;
}
</style>
{/literal}

<div id="ep2019"> 
<div class="row">
<div class="col-sm-11" >
<h3 class="total">Total</h3>
<div class="form-group">
<label>Search</label>
            <span class="input-group-addon"><span class="glyphicon glyphicon-search" aria-hidden="true"></span></span>
            <input type="text" id="input-filter" class="form-control" placeholder="name, party, country...">
</div>
</div>
</div>
    <table class="table table-hover list">
        <thead>
        <tr class="header">
            <th>Running?</th>
            <th>First Name</th>
            <th>Last Name</th>
            <th>Party</th>
            <th>Country</th>
        </tr>
        </thead>
    </table>

</div> 
<div class="clear"></div>
</div>
