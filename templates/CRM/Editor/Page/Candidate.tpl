<script>
{assign var="epgroup_field" value="group"}
{assign var="country_field" value="custom_4"}
{assign var="party_field" value="custom_5"}
{assign var="return_party" value="organization_name,nick_name,legal_name,country,$epgroup_field"}

var epgroup_field = "{$epgroup_field}";
var countries_flat = {crmAPI sequential=0 entity="Constant" name="country"}.values;
var countries = {crmAPI sequential=0 entity="Country"}.values;

var country_field = "{$country_field}";
var party_field = "{$party_field}";

var parties = {crmAPI entity="Contact" sequential=0 contact_sub_type="party" option_limit=1000 return="organization_name,country" option_sort="organization_name ASC"}.values;

var candidates = {$candidates};
{literal}
var parties_flat = {"_": {}}; 

 function exportToExcel() {
        var tab_text = "<tr bgcolor='#87AFC6'>";
        var textRange; var j = 0, rows = '';
//        tab = document.getElementById('candidates');
        var cols="id,first_name,last_name,email,twitter,party,position".split(",");
//        tab_text = tab_text + tab.rows[0].innerHTML + "</tr>";
            cols.forEach(function(col){
              tab_text += '<td>' + col + '</td>'
            });
            tab_text += '</tr>';
        candidates.forEach (function(d){
            rows += '<tr>';
            cols.forEach(function(col){
              rows += '<td>' + d[col] + '</td>'
            });
            rows += '</tr>';
        });
        tab_text += rows;
        var data_type = 'data:application/vnd.ms-excel;base64,',
            template = '<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns="http://www.w3.org/TR/REC-html40"><head><!--[if gte mso 9]><xml><x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>{worksheet}</x:Name><x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook></xml><![endif]--></head><body><table border="2px">{table}</table></body></html>',
            base64 = function (s) {
                return window.btoa(unescape(encodeURIComponent(s)))
            },
            format = function (s, c) {
                return s.replace(/{(\w+)}/g, function (m, p) {
                    return c[p];
                })
            }

        var ctx = {
            worksheet: "Sheet 1" || 'Worksheet',
            table: tab_text
        }
        document.getElementById("dlink").href = data_type + base64(format(template, ctx));
        document.getElementById("dlink").download = "candidates.xls";
        document.getElementById("dlink").traget = "_blank";
        document.getElementById("dlink").click();
    }

cj(function($) {
    countries_flat["_"]="-select-";

    $.each(countries_flat, function (n) {
      parties_flat[n]= {};
    });
    $.each(parties, function(n) {
      if (!parties[n].country_id)
        parties[n].country_id = "_";
      parties_flat[parties[n].country_id][parties[n].id]=parties[n].organization_name;
    });

    $.each(candidates, function(n) {
      if (candidates[n].party) {
        if (candidates[n].country && parties_flat[candidates[n].country][candidates[n].party]) { 
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
    var oTable = $('#contacts').dataTable( {
    "sDom": "<'ui-widget-header'<'span6'T><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",
    buttons: ["excel"],
    "bbboTableTools": {
      "sSwfPath": "/extensions/ep2019/TableTools/swf/copy_csv_xls.swf",
    },
    aaSorting:[],
    bSortClasses: false,
    bJQueryUI: true,
    "bStateSave": true,
    "bPaginate":false,
    "aaData": candidates,
    aoColumnDefs: [
      {"aTargets":[0],sTitle:"",mData:"id",mRender:function (data,type,full) {return "<a class='ui-icon ui-icon-person' href='"+CRM.url('civicrm/contact/view', {"reset": 1, "cid":data})+"'></a><a class='ui-icon ui-icon-search' title='search on google'></a>";}},
        { "aTargets":[1],"sTitle": "First Name", mDataProp: "first_name",sClass: "editable"},
        { "aTargets":[2],"sTitle": "Last Name", mDataProp: "last_name",sClass: "editable"},
        { "aTargets":[3],"sTitle": "country", mDataProp:"country", "sClass": "country" },
        { "aTargets":[4],"sTitle": "party", mDataProp:"party", "sClass": "party" },
        { "aTargets":[5],"sTitle": "email" , mDataProp:"email","sClass": "editable"},
        { "aTargets":[6],"sTitle": "twitter" , mDataProp:"twitter","sClass": "editable"},
        { "aTargets":[7],"sTitle": "#", mDataProp: "position",sClass:""},
    ],
    "fnDrawCallback": function () {
       $(".ui-widget-header .btn").hide();
       $(".DTTT_button_xls").show().click(exportToExcel);
//TODO: add the editable
    }
  });
//    $(".ui-widget-header").append("<button id='add' class='add_row ui-state-default'>Add</button>");

   var editableSettings = { 
     callBack:function(data){
          if (data.is_error) {
            editableSettings.error.call (this,data);
          } else {
             return editableSettings.success.call (this,data);
          }
        },
        error: function(data) {
          $(this).crmError(data.error_message, ts('Error'));
          $(this).removeClass('crm-editable-saving');
        },
        success: function(entity,field,value) {
          var $i = $(this);
          CRM.alert(value, ts('Saved'), 'success');
          $i.removeClass ('crm-editable-saving crm-error');
          $i.html(value);
        }
   };

    /* Apply the jEditable handlers to the table */
    var settings =  {
        "callback": function( sValue, y ) {
            var aPos = oTable.fnGetPosition( this );
            oTable.fnUpdate( sValue, aPos[0], aPos[1] );
        },
          data: function(value, settings) {
              return value.replace(/<(?:.|\n)*?>/gm, '');
            },
  
        "height": "24px",
        "width": "100%",
        "placeholder": '<span class="crm-editable-placeholder">Click to edit</span>',
        "onblur": "ignore" 
    };

  $("tbody").on ("click","td.editable",function(event) {
    event.preventDefault();
    $(this).editable( function(value,settings) {
      $(this).addClass ('crm-editable-saving');
      pos = oTable.fnGetPosition( this );
      row= pos[0];
      column= pos[2];
      contact_id=candidates[row].id;
      field = oTable.fnSettings().aoColumns[column].mData;
      CRM.api("candidate", "setvalue", {"field":field,"value":value, "id":contact_id}, {
        context: this,
        error: function (data) {
          editableSettings.error.call(this,data);
        },
        success: function (data) {
          CRM.alert( ts('Saved') + " " + value,candidates[row].last_name, 'success');
        }
      });
      return value;
    },settings).trigger("click");
  });

    /* Apply the jEditable handlers to the parties */
    psettings=$.extend({},settings);
    psettings.type="select";
    psettings.data=function (value,settings) {
      var pos = oTable.fnGetPosition( this );
      var row= pos[0];
      var country_id= candidates[row].country;
      if (isNaN (parseInt(country_id))) {
        country_id= Object.keys(countries_flat).filter(function(key) {return countries_flat[key] === country_id})[0];
      }
      return parties_flat[country_id];
    } 
    psettings.onblur = 'submit';
 
    oTable.$('td.party').editable( function(value,settings) {
      $(this).addClass ('crm-editable-saving');
      pos = oTable.fnGetPosition( this );
      row= pos[0];
      column= pos[2];
      entity="Contact";
      var country_id= candidates[row].country;
      if (isNaN (parseInt(country_id))) {
        country_id= Object.keys(countries_flat).filter(function(key) {return countries_flat[key] === country_id})[0];
      }
      var params = {};
      params["id"]=candidates[row].id; 
      params[party_field]=value; 
      CRM.api(entity, "create", params, {
        context: this,
        error: function (data) {
          editableSettings.error.call(this,data);
        },
        success: function (data) {
          CRM.alert( candidates[row].last_name , ts('Saved') + " " + parties_flat[country_id][value], 'success');
        }
      });
      return parties_flat[country_id][value];
    },psettings);

    /* Apply the jEditable handlers to the countries */
    psettings.data=countries_flat;
    oTable.$('td.country').editable( function(value,settings) {
      $(this).addClass ('crm-editable-saving');
      pos = oTable.fnGetPosition( this );
      row= pos[0];
      column= pos[2];
      entity="Contact";
      contact_id=candidates[row].id;
      var param = {"id": candidates[row].id};
      param[country_field]=value;
      CRM.api(entity, "create", param, {
        context: this,
        error: function (data) {
          editableSettings.error.call(this,data);
        },
        success: function (data) {
          candidates[row].country = value;
          CRM.alert(candidates[row].last_name ,countries_flat[value] +" "+ ts('Saved'), 'success');
        }
      });
      return countries_flat[value];
    },psettings);

    var o= "<option value=''>-select-</option>";
    $.each(countries, function (i,d) {
      o = o + "<option value='"+d.id+"'>"+d.name+"</option>";
    });
    $("#new_dialog select#"+country_field).append (o);
    $("#new_dialog select#"+country_field).on ("change",function() {
      var country_id = this.value;
      if (!country_id) return;
      var o= "<option value=''>-select-</option>";
      $.each(parties_flat[country_id],function (i,d) {
        o = o + "<option value='"+i+"'>"+d+"</option>";
      });
      $("#new_dialog select#"+party_field).html(o);
    });
    
    var o= "<option value=''>-select-</option>";
    $.each(parties, function (i,d) {
      o = o + "<option value='"+d.id+"'>"+d.organization_name+"</option>";
    });
    $("#new_dialog select#"+party_field).append (o);
    $("#new_dialog")//.dialog({"modal":true, autoOpen:false}).
        .submit (function (e) {
      e.preventDefault();
      var fields = ["first_name", "last_name", "twitter","email",party_field,country_field,"position"];
      var params = {
        "dedupe_check":true,
        "option":{"match":["first_name","last_name","email"]},
        "source": "civicrm/candidate",
        "sequential": 1,
        "contact_type":"Individual",
        "contact_sub_type":"Candidate"
      };
      $.each(fields, function(id) {
        params[fields[id]]=$("#"+fields[id]).val();
      });
//      params["api.address"]={"location_type_id":2,"is_primary":1,"country_id":params["country"]};
      var entity="candidate";
      CRM.api3(entity, "create", params,true)
        .done(function (data) {
          params["id"]=data["id"];
          params["party"]=parties[params[party_field] ].organization_name;
          params["country"]=countries[params[country_field]].name;
          oTable.fnAddData( params);
          CRM.$("#new_dialog").modal('hide');
          //CRM.alert(params.last_name, 'Saved', 'success')
        });
    });
      
//    $("#add").click(function () { $("#new_dialog").dialog('open'); });

    $('#contacts select').on('change', '',function () {
      $(this).closest("form").submit();
//      alert("Change Event Triggered On:" + $(this).attr("value"));
    });

   $(".ui-icon-search").on("click",function() {
      var row = oTable.fnGetPosition( $(this).closest("td")[0] )[0];
      var q=candidates[row].first_name+ " "+candidates[row].last_name +" " + candidates[row].party;
      window.open("https://www.google.com/search?q="+q, '_blank');
   },true);
});

</script>
<style>
.DTTT_button {padding:0 10px;}
.DTTT_container {float:left;}
td {word-break:break-word}
.col-sm-9 {width:100%;}
.col-sm-3 {display:none;}
.ui-icon {cursor:pointer;}
</style>
{/literal}

<button type="button" class="btn btn-primary" data-toggle="modal" data-target="#new_dialog">
  <i class="crm-i fa-plus-circle"></i>Add
</button>
<table id="contacts"></table>
<!-- Modal -->
<div class="modal fade" id="new_dialog" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
  <div class="modal-dialog" role="document">
<form>
    <div class="modal-content">
      <div class="modal-header">
        <h4 class="modal-title" id="myModalLabel">Create new candidate</h4>
      </div>
      <div class="modal-body">


<div class="form-group">
<label>First Name</label>
<input id="first_name"  class="form-control " required/>
<label>Last Name</label>
<input id="last_name"  class="form-control " required/>
<label>Email</label>
<input id="email"  class="form-control"/>
</div>
<div class="form-group">
<label>Country</label>
<select id="{$country_field}"  required class="form-control crm-form-select">
</select>
<label>Party</label>
<select id="{$party_field}"  required class="form-control crm-form-select">
</select>
</div>
<div class="form-group">
<label>Position</label>
<input id="position"  class="form-control " placeholder=""/>
</div>
<div class="form-group">
<label>Twitter</label>
<input id="twitter"  class="form-control " placeholder="@something"/>
</div>


      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
<input type="submit" name="save" value="Add Candidate" class="btn btn-primary form-submit"/>
      </div>
    </div>
</form>
  </div>
</div>

<div id="aaanew_dialog">
<form>
</form>
</div>
<a id="dlink">a</a>
