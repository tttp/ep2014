{crmTitle string="Campaign"}
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
var pledge="{$id}";
var candidates= {crmSQL json="pledged" pledge=$id debug=1}.values;
{crmTitle title=$id}
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
  var graphs =[];

cj(function($) {
    $("h1").html(candidates.length +" meps").hide();

    $.each(parties, function(n) {
    });

    candidates.forEach(function(d){
       d.country="?";
       if (d.country_id && countries[d.country_id])
         d.country=countries[d.country_id].name;
       d.party="?";
       if (d.party_id && parties[d.party_id])
         d.party= parties[d.party_id].organization_name;
       
    });

    draw ();
  
});

function draw () {
  var ndx = crossfilter(candidates),
  all = ndx.groupAll();

//  drawDate (ndx, " .date");
  graphs.table= drawTable (ndx,  " .list");
     graphs.search = drawTextSearch('#input-filter', jQuery);
  graphs.status = drawStatus(".statuspledge");
  drawNumber();
 
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


function drawNumber(){
  var group=ndx.groupAll().reduceCount();
  dc.numberDisplay("#total")
    .valueAccessor(function(d){return +d.value})
    .group(group);   
}

function drawStatus (dom){
  var dim=ndx.dimension(function(d){return d.status_id});
  var group   = dim.group().reduceSum(function(d) {   return 1; });
  var graph = dc.pieChart(dom)
//.innerRadius(3).radius(25)
  .width(0)
  .height(0)
  .dimension(dim)
  .label(function(d){
     var status={1:"?",2:"👍",3:"👎"};
     return status[d.key];
  })
  .ordering(dc.pluck('key'))
  .colors(d3.scaleOrdinal().range(['#e6ab5e','#0071bd','#4d4d69']))
  .group(group);

  return graph;

}

function drawBinary (ndx,selector,attribute) {
  var dim = ndx.dimension(function(d) {
    if (typeof d[attribute] == "undefined" || !d[attribute])
      return "Missing";
    return "Complete";
  });
  var group   = dim.group().reduceSum(function(d) {   return 1; });
  var graph = dc.pieChart(selector).innerRadius(3).radius(25)
  .width(50)
  .height(50)
  .dimension(dim)
  .renderLabel(false)
//  .colors(d3.scale.ordinal().range(['#3a6033','#b00000']))
  .group(group);
  return graph;
}

function drawTable (ndx,selector) {

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
              var disabled="";
              var t="<span class='btn-status btn-group btn-group-xs' data-id='"+d.activity_id+"'>";
              disabled= d.status_id ==2 ? "disabled":"";
                 t += "<button class='btn btn-primary' data-value='2' title='Approve' "+ disabled+"><i class='crm-i fa-thumbs-up'></i></button>";
              disabled= d.status_id ==1 ? "disabled":"";
              t += "<button class='btn btn-warning' data-value='1' title='To be moderated' "+ disabled+"><i class='crm-i fa-question-circle'></i></button>";
              disabled= d.status_id ==3 ? "disabled":"";
                 t += "<button class='btn btn-secondary' data-value='3' title='Cancel/Reject' "+ disabled+"><i class='crm-i fa-thumbs-down'></i></button>";
              return t + "</span>";
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
            return d.activity_date_time;
        })
        .order(d3.descending)
        .on('renderlet', function(chart) {
          CRM.$("table").on("click",".btn-status .btn",function() {
            var btn=CRM.$(this);
            var status_id=btn.data("value");
            var activity_id=btn.closest(".btn-status").data("id");
            console.log(activity_id+":"+status_id);
            CRM.api3("Activity","create",{
              id:activity_id,
              status_id:status_id
            },true)
            .done(function(result){
              btn.closest(".btn-group").find(".btn").attr("disabled",false);
              btn.attr("disabled","disabled");
            });
             
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

cj(function($){
      $("#csv").click(function(e) {
        download_csv();
        e.stopPropagation();
      });

      $("#excel").click(function(e) {
        download_excel();
        e.stopPropagation();
      });

    function download_csv() {
      var csv="";
      var line = function (d){
          csv += d.join(',') + "\n";
      };
      prepareData(line,line);
      window.open('data:application/csv; charset=utf-8,' + encodeURI(csv));
    }

function download_excel() {

  var uri = 'data:application/vnd.ms-excel;base64,',
  template = '<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns="http://www.w3.org/TR/REC-html40"><head><!--[if gte mso 9]><?xml version="1.0" encoding="UTF-8" standalone="yes"?><x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>{worksheet}</x:Name><x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook></xml><![endif]--></head><body><table>{table}</table></body></html>',
  base64 = function(s) {
    return window.btoa(unescape(encodeURIComponent(s)))
  },
  format = function(s, c) {
    return s.replace(/{(\w+)}/g, function(m, p) {
      return c[p];
    })
  }

 var toExcel = "<thead><tr>";
  var head= function(d){
    for (var c in d) {
      toExcel += "<th>" + d[c] + "</th>";
    };
    toExcel += "</tr>";
    toExcel += "</thead><tbody>\n";
  };

  var row= function(d){
    toExcel += "<tr>";
    for (var c in d) {
      toExcel += "<td>" + d[c] + "</td>";
    };
    toExcel += "</tr>\n";
  };

  prepareData(row,head);
  toExcel+="</tbody>";

  var ctx = {
    worksheet: name || 'person',
    table: toExcel
  };
  window.open(uri + base64(format(template, ctx)));

}

    function status(id){
      var name={1:"pending",2:"validated",3:"cancelled"};
      return name[id];
    }

    function prepareData(row,head) {
      var col =  "first_name,last_name,country,party,twitter,email,id,date,status".split(",");
      head(col);
      graphs.table.dimension().top(Number.POSITIVE_INFINITY).forEach(function(d) {
        row([
          d.first_name
          ,d.last_name
          ,d.country
          ,d.party
          ,d.twitter ? d.twitter: ""
          ,d.mail ? d.mail:""
          ,d.id
          ,d.date
          ,status(d.status_id)
        ]);
      });
    }

});

{/literal}
</script>

{literal}
<style>
#binaries {width:60px;}
#ep2019 .clear {clear:both}
table .btn {
  border-radius: 0px!important;
}
table .btn:disabled {
  border-radius: 10px!important;
}
.heat-box {
  stroke: #E6E6E6;
  stroke-width: 2px;
}
.statuspledge svg .pie-slice {font-size:30px;}
</style>
{/literal}

<div id="ep2019"> 
<div class="row">
<div class="col-sm-4">
<div class="statuspledge">
</div>
</div>
<div class="col-sm-4" >
<div class="input-group input-group-lg">
<span class="hidden input-group-addon">🔎</span>
            <input type="text" id="input-filter" class="form-control" placeholder="name, party, committee...">
</div>
</div>
<div class="col-sm-4">
<i class='crm-i fa-download' id="csv"></i>
<i class='crm-i fa-file-excel-o' id="excel"></i>
</div>
</div> 
    <table class="table table-hover list">
        <thead>
        <tr class="header">
            <th>Pledged?</th>
            <th>First Name</th>
            <th>Last Name</th>
            <th>Party</th>
            <th>Country</th>
        </tr>
        </thead>
    </table>

