<h3>Parties</h3>

<script>
{assign var="epgroup_field" value="custom_1"}
{assign var="return_party" value="organization_name,nick_name,legal_name,country,$epgroup_field"}

var epgroup_field = "{$epgroup_field}";
var euparty_field = epgroup_field;//"{$euparty_field}";
var countries_flat = {crmAPI sequential=0 entity="Constant" name="country"}.values;
var countries = {crmAPI entity="Country"}.values;

var groups = {crmAPI entity="Contact" contact_sub_type="eugroup" option_limit=1000 return="organization_name,nick_name,legal_name" option_sort="organization_name ASC"}.values;
var euparties = groups;//{crmAPI entity="Contact" contact_sub_type="euparty" option_limit=1000 return="organization_name,nick_name,legal_name" option_sort="organization_name ASC"}.values;

var parties = {crmAPI entity="Contact" contact_sub_type="party" option_limit=1000 return=$return_party option_sort="organization_name ASC"}.values;
{literal}
var groups_flat = {}; 
var euparties_flat = {}; 

CRM.$(function($) {

    $.each(groups, function(n) {
        groups_flat[groups[n].id]=groups[n].organization_name;
    });
    groups_flat[0]="-select-";
    euparties.forEach(function(d){
      d.contact_id = parseInt(d.contact_id,10);
      d.id = parseInt(d.id,10);
      d.country_id = parseInt(d.country_id,10);
    });

    parties.forEach(function(d){
      d.contact_id = parseInt(d.contact_id,10);
      d.id = parseInt(d.id,10);
      d.country_id = parseInt(d.country_id,10);
      d.address_id = parseInt(d.address_id,10);
      d.custom_1 = parseInt(d.custom_1,10);
    });
    $.each(euparties, function(n) {
        euparties_flat[euparties[n].id]=euparties[n].organization_name;
    });
    euparties_flat[0]="-select-";

    countries_flat[0]="-select-";

/*    $.each(parties, function(n,p) {
      if (parties[n][epgroup_field]){
        parties[n][epgroup_field] = parseInt(parties[n][epgroup_field],10);
      }

      if (parties[n][epgroup_field]) {
        
//typeof parties[n][epgroup_field] == "number")  {
        if (groups_flat[parties[n][epgroup_field]]) {
          parties[n][epgroup_field]=groups_flat[parties[n][epgroup_field]];
        } else if (typeof parties[n][epgroup_field] == "number") {
          parties[n][epgroup_field]= "<b>missing "+parties[n][epgroup_field]+"</b>";
        }
      } else {
        parties[n][epgroup_field]="";
      };
      if (parties[n][euparty_field]) {
        if (euparties_flat[parties[n][euparty_field]])
          parties[n][euparty_field]=euparties_flat[parties[n][euparty_field]];
        else {
          parties[n][euparty_field]="<b>missing "+parties[n][euparty_field]+"</b>";
        }
      } else {
        parties[n][euparty_field]="";
      };
    });
*/
    var oTable = $('#contacts').dataTable( {
    aaSorting:[],
bSortClasses: false,
    bJQueryUI: true,
    bStateSave: false,
    "bPaginate":false,
    "aaData": parties,
    aoColumnDefs: [
      {"aTargets":[0],sTitle:"",mData:"id",mRender:function (data,type,full) {return "<a class='crm-i fa-address-book-o' href='"+CRM.url('civicrm/contact/view', {"reset": 1, "cid":data})+"'></a>";}},
      {"aTargets":[1], "sTitle": "name", mData: "organization_name",sClass: "editable"},
      { "aTargets":[2],"sTitle": "group", mData:epgroup_field,"sClass": "group" },
//      { "aTargets":[3],"sTitle": "euparty", mData:euparty_field,"sClass": "euparty" },
      { "aTargets":[3],"sTitle": "english", mData:"legal_name","sClass": "editable" },
      { "aTargets":[4],"sTitle": "accronym" , mData:"nick_name","sClass": "editable"},
      { "aTargets":[5],"sTitle": "country", mData:"country", "sClass": "country" }
      
    ],
    "fnDrawCallback": function () {
//TODO: add the editable
    }
  });

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
console.log(value);
              return value.replace(/<(?:.|\n)*?>/gm, '');
            },
  
        "height": "24px",
        "width": "100%",
        "placeholder": '<span class="crm-editable-placeholder">Click to edit</span>',
        "onblur": "ignore" 
    };


    CRM.$('td.editable').crmEditable(function(value,settings) {
      $(this).addClass ('crm-editable-saving');
      pos = oTable.fnGetPosition( this );
      row= pos[0];
      column= pos[2];
      contact_id=parties[row].id;
      field = oTable.fnSettings().aoColumns[column].mData;
      entity="Contact";
      CRM.api(entity, "setvalue", {"field":field,"value":value, "id":contact_id}, {
        context: this,
        error: function (data) {
          editableSettings.error.call(this,data);
        },
        success: function (data) {
          CRM.alert( ts('Saved') + " " + value,parties[row].organization_name, 'success');
        }
      });
      return value;
    },settings);

    /* Apply the jEditable handlers to the eu parties */
    settings.type="select";
    settings.data=euparties_flat;
    settings.onblur = 'submit';
 
    oTable.$('td.euparty').crmEditable( function(value,settings) {
      $(this).addClass ('crm-editable-saving');
      pos = oTable.fnGetPosition( this );
      row= pos[0];
      column= pos[2];
      entity="Contact";
      var params = {};
      params["id"]=parties[row].id; 
      params[euparty_field]=value; 
      CRM.api(entity, "create", params, {
        context: this,
        error: function (data) {
          editableSettings.error.call(this,data);
        },
        success: function (data) {
          CRM.alert( parties[row].organization_name , ts('Saved') + " " + euparties_flat[value], 'success');
        }
      });
      return euparties_flat[value];
    },settings);

    /* Apply the jEditable handlers to the eu groups */
    settings.type="select";
    settings.data=groups_flat;
    settings.onblur = 'submit';
 
    oTable.$('td.group').crmEditable( function(value,settings) {
      $(this).addClass ('crm-editable-saving');
      pos = oTable.fnGetPosition( this );
      row= pos[0];
      column= pos[2];
      entity="Contact";
      var params = {};
      params["id"]=parties[row].id; 
      params[epgroup_field]=value; 
      CRM.api(entity, "create", params, {
        context: this,
        error: function (data) {
          editableSettings.error.call(this,data);
        },
        success: function (data) {
          CRM.alert( parties[row].organization_name , ts('Saved') + " " + groups_flat[value], 'success');
        }
      });
      return groups_flat[value];
    },settings);

    /* Apply the jEditable handlers to the countries */
    settings.data=countries_flat;
    oTable.$('td.country').crmEditable( function(value,settings) {
      $(this).addClass ('crm-editable-saving');
      pos = oTable.fnGetPosition( this );
      row= pos[0];
      column= pos[2];
      address_id=parties[row].address_id;
      entity="Address";
      if (address_id) {
        CRM.api(entity, "setvalue", {"field":"country_id","value":value, "id":address_id}, {
          context: this,
          error: function (data) {
            editableSettings.error.call(this,data);
          },
          success: function (data) {
            CRM.alert(parties[row].organization_name ,countries_flat[value] +" "+ ts('Saved'), 'success');
          }
        });
      } else {
        contact_id=parties[row].id;
        CRM.api(entity, "create", 
          {"location_type_id":2,"is_primary":1,"country_id":value, "contact_id":contact_id}, {
          context: this,
          error: function (data) {
            editableSettings.error.call(this,data);
          },
          success: function (data) {
            parties[row].address_id = data.address_id;
            CRM.alert(countries_flat[value]+ " "+ ts('Saved'),parties[row].organization_name , 'success');
          }
        });
      }
      return countries_flat[value];
    },settings);

    $(".ui-widget-header").append("<button id='add' class='add_row'>Add</button>");
    var o= "";
    $.each(countries, function (i,d) {
      o = o + "<option value='"+d.id+"'>"+d.name+"</option>";
    });
    $("#new_dialog select#country").append (o);
    
    var o= "<option value=''>-select-</option>";
    $.each(groups, function (i,d) {
      o = o + "<option value='"+d.id+"'>"+d.organization_name+"</option>";
    });
    $("#new_dialog select#"+epgroup_field).append (o);
    $("#new_dialog").dialog({"modal":true, autoOpen:false}).submit (function (e) {
      e.preventDefault();
      var fields = ["organization_name", "legal_name", "nick_name", "country",epgroup_field];
      var params = {
        "dedupe_check":true,
        "source": "civicrm/party",
        "sequential": 1,
        "contact_type":"Organization",
        "contact_sub_type":"party"
      };
      $.each(fields, function(id) {
        params[fields[id]]=$("#"+fields[id]).val();
      });
      params["api.address"]={"location_type_id":2,"is_primary":1,"country_id":params["country"]};
      var entity="contact";
      CRM.api(entity, "create", params, {
        context: this,
        error: function (data) {
          CRM.alert(data.error_message, 'Save error', 'error')
          console.log (data);
        },
        success: function (data) {
          params["id"]=data["id"];
          params[epgroup_field]=groups_flat[params[epgroup_field]];
          params["country"]=countries_flat[params["country"]];
          oTable.fnAddData( params);
          $("#new_dialog").dialog('close');
          CRM.alert(params.organization_name, 'Saved', 'success')
        }
      });
    });
      
    $("#add").click(function () { $("#new_dialog").dialog('open'); });

    $('#contacts select').on('change', function () {
      $(this).closest("form").submit();
//      alert("Change Event Triggered On:" + $(this).attr("value"));
    });

});

</script>
<style>
.ui-icon-person {cursor:pointer}
</style>
{/literal}

<table id="contacts"></table>

<div id="new_dialog">
<form>
<div class="form-item">
<label>Name</label>
<input id="organization_name"  class="form-control "/>
</div>
<div class="form-item">
<label>Group</label>
<select id="{$epgroup_field}"  class="form-control ">
</select>
</div>
<div class="form-item">
<label>English Name</label>
<input id="legal_name" class="form-control "/>
</div>
<div class="form-item">
<label>Accronym</label>
<input id="nick_name"  class="form-control "/>
<label>Country</label>
<select id="country"  class="form-control ">
</select>
</div>

<input type="submit" name="save" class="btn-primary form-submit"/>
</form>
</div>
