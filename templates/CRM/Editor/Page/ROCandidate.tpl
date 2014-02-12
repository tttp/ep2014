<script>
{assign var="epgroup_field" value="group"}
{assign var="country_field" value="custom_3"}
{assign var="party_field" value="custom_5"}
{assign var="return_party" value="organization_name,nick_name,legal_name,country,$epgroup_field"}

var epgroup_field = "{$epgroup_field}";
var countries_flat = {crmAPI sequential=0 entity="Constant" name="country"}.values;
var countries = {crmAPI entity="Country"}.values;

var country_field = "{$country_field}";
var party_field = "{$party_field}";

var parties = {crmAPI entity="Contact" contact_sub_type="party" option_limit=1000 return="organization_name,country" option_sort="organization_name ASC"}.values;

var candidates = {crmAPI entity="Candidate" option_limit=1000 }.values;
{literal}
var parties_flat = {}; 

cj(function($) {
    countries_flat["_"]="-select-";

    $("h1").prepend(candidates.length);
    $.each(countries_flat, function (n) {
      parties_flat[n]= {};
    });
    $.each(parties, function(n) {
        parties_flat[parties[n].country_id][parties[n].id]=parties[n].organization_name;
    });

    $.each(candidates, function(n) {
      if (candidates[n].party) {
        if (parties_flat[candidates[n].country][candidates[n].party]) { 
          candidates[n].party=parties_flat[candidates[n].country][candidates[n].party];
        } else {
          candidates[n].party="<b>party "+candidates[n].party+" missing</b>";
        }
      } else {
        candidates[n].party="";
      };
      if (candidates[n].country) {
        candidates[n].country = countries_flat[candidates[n].country];
      }
    });

// Set the classes that TableTools uses to something suitable for Bootstrap
$.extend( true, $.fn.DataTable.TableTools.classes, {
  "container": "btn-group",
  "buttons": {
    "normal": "btn",
    "disabled": "btn disabled"
  },
  "collection": {
    "container": "DTTT_dropdown dropdown-menu",
    "buttons": {
      "normal": "",
      "disabled": "disabled"
    }
  }
} );

// Have the collection use a bootstrap compatible dropdown
$.extend( true, $.fn.DataTable.TableTools.DEFAULTS.oTags, {
  "collection": {
    "container": "ul",
    "button": "li",
    "liner": "a"
  }
} );

    var linkify = function (data,protocol) {
      if (protocol == "display") protocol = "";
      return "<a href='"+protocol+data+"'>"+data+"</a>";
    }
    var oTable = $('#contacts').dataTable( {
    "sDom": "<'ui-widget-header'<'span6'T><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",
    "oTableTools": {
      "sSwfPath": "/extensions/ep2014/TableTools/swf/copy_csv_xls.swf",
    },
    aaSorting:[],
    bSortClasses: false,
    bJQueryUI: true,
    "bStateSave": true,
    "bPaginate":false,
    "aaData": candidates,
    aoColumnDefs: [
        { "aTargets":[0],"sTitle": "First Name", mDataProp: "first_name",sClass:""},
        { "aTargets":[1],"sTitle": "Last Name", mDataProp: "last_name",sClass: ""},
        { "aTargets":[2],"sTitle": "country", mDataProp:"country", "sClass": "" },
        { "aTargets":[3],"sTitle": "party", mDataProp:"party", "sClass": "" },
        { "aTargets":[4],"sTitle": "email" , mDataProp:"email","sClass": "",mRender: function (data) {return linkify(data,"mailto:");}},
        { "aTargets":[5],"sTitle": "website" , mDataProp:"website","sClass": "",mRender: linkify},
        { "aTargets":[6],"sTitle": "facebook" , mDataProp:"facebook","sClass": "",mRender: linkify},
        { "aTargets":[7],"sTitle": "twitter" , mDataProp:"twitter","sClass": "",mRender: linkify},
    ],
    "fnDrawCallback": function () {
//TODO: add the editable
    }
  });
    $(".ui-widget-header").append("&nbsp;");
});

</script>
<style>
.breadcrumb {display:none;}
.DTTT_button {padding:0 10px;}
.DTTT_container {float:left;}
td {word-break:break-word}
.col-sm-9 {width:100%;}
.col-sm-3 {display:none;}
.ui-icon {cursor:pointer;}
</style>
{/literal}

<table id="contacts"></table>
