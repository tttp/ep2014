<h3>Candidates</h3>

<script>
//var position_field = custom_2, party_field = custom_5
var countries_flat = {crmAPI sequential=0 entity="Constant" name="country"}.values;
var countries = {crmAPI entity="Country"}.values;

var parties = {crmAPI entity="Contact" contact_sub_type="party" option_limit=1000 return="organization_name,nick_name,legal_name,country" option_sort="organization_name ASC"}.values;

var candidates = {crmAPI entity="Contact" contact_sub_type="candidate" option_limit=1000 return="first_name,last_name,nick_name,country,website,custom_2,custom_5" option_sort="last_name ASC"};
{literal}
var parties_flat = {};

cj(function($) {
    $.each(parties, function(n) {
        parties_flat[parties[n].id]=parties[n].organization_name;
    });

    $.each(candidates.values, function(n) {
      if (candidates.values[n].custom_5) {
        candidates.values[n].custom_5=parties_flat[candidates.values[n].custom_5];
      };
    });

    var oTable = $('#example').dataTable( {
    bJQueryUI: true,
    "bStateSave": true,
    "bPaginate":false,
    "aaData": candidates.values,
    "aoColumns": [
//           { "sTitle": "id",mData:"id"},
        { "sTitle": "first name", mDataProp: "first_name",sClass: "editable"},
        { "sTitle": "last name", mDataProp: "last_name",sClass: "editable"},
        { "sTitle": "position", mDataProp:"custom_2","sClass": "editable" },
        { "sTitle": "party", mDataProp:"custom_5","sClass": "group" },
        { "sTitle": "website" , mDataProp:"website","sClass": "editable"},
        { "sTitle": "facebook" , mDataProp:"facebook","sClass": "editable"},
        { "sTitle": "twitter" , mDataProp:"twitter","sClass": "editable"},
        { "sTitle": "country", mDataProp:"country", "sClass": "country" }
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
          CRM.alert('', ts('Saved'), 'success');
          $i.removeClass ('crm-editable-saving crm-error');
          $i.html(value);
        }
   };

    /* Apply the jEditable handlers to the table */
    var settings =  {
        "callback": function( sValue, y ) {
console.log ("callback");
console.log (oTable.fnGetPosition( this ));
            var aPos = oTable.fnGetPosition( this );
            oTable.fnUpdate( sValue, aPos[0], aPos[1] );
        },
          data: function(value, settings) {
              return value.replace(/<(?:.|\n)*?>/gm, '');
            },
  
        "height": "24px",
        "width": "100%",
        "placeholder": '<span class="crm-editable-placeholder">Click to edit</span>'
  
    };

    oTable.$('td.editable').editable( function(value,settings) {
console.log ("aaa");
      $(this).addClass ('crm-editable-saving');
      pos = oTable.fnGetPosition( this );
      row= pos[0];
      column= pos[2];
      contact_id=candidates.values[row].id;
      field = oTable.fnSettings().aoColumns[column].mData;
      entity="Contact";
      CRM.api(entity, "setvalue", {"field":field,"value":value, "id":contact_id}, {
        context: this,
        error: function (data) {
          editableSettings.error.call(this,data);
        },
        success: function (data) {
          editableSettings.success.call(this,entity,field,value);
        }
      });
    },settings);

    /* Apply the jEditable handlers to the eu parties */
    settings.type="select";
    settings.data=parties_flat;
    settings.onblur = 'submit';
 
    oTable.$('td.group').editable( function(value,settings) {
      $(this).addClass ('crm-editable-saving');
      pos = oTable.fnGetPosition( this );
      row= pos[0];
      column= pos[2];
      contact_id=candidates.values[row].id;
      entity="Contact";
      CRM.api(entity, "create", {"custom_7":value, "id":contact_id}, {
        context: this,
        error: function (data) {
          editableSettings.error.call(this,data);
        },
        success: function (data) {
          value = countries[value];
          editableSettings.success.call(this,entity,"contact",value);
        }
      });
    },settings);

    /* Apply the jEditable handlers to the countries */
    settings.data=countries_flat;
    oTable.$('td.country').editable( function(value,settings) {
      $(this).addClass ('crm-editable-saving');
      pos = oTable.fnGetPosition( this );
      row= pos[0];
      column= pos[2];
      address_id=candidates.values[row].address_id;
      entity="Address";
      if (address_id) {
        CRM.api(entity, "setvalue", {"field":"country_id","value":value, "id":address_id}, {
          context: this,
          error: function (data) {
            editableSettings.error.call(this,data);
          },
          success: function (data) {
            value = countries_flat[value];
            editableSettings.success.call(this,entity,"country",value);
          }
        });
      } else {
        contact_id=candidates.values[row].id;
        CRM.api(entity, "create", 
          {"location_type_id":2,"is_primary":1,"country_id":value, "contact_id":contact_id}, {
          context: this,
          error: function (data) {
            editableSettings.error.call(this,data);
          },
          success: function (data) {
            value = countries_flat[value];
            candidates.values[row].address_id = data.address_id;
            editableSettings.success.call(this,entity,"country",value);
          }
        });
      }
    },settings);

    $(".ui-widget-header").append("<button id='add' class='add_row'>Add</button>");
    var o= "";
    $.each(countries, function (i,d) {
      o = o + "<option value='"+d.id+"'>"+d.name+"</option>";
    });
    $("#new_dialog select#country").append (o);
    
    var o= "";
    $.each(parties, function (i,d) {
      o = o + "<option value='"+d.id+"'>"+d.organization_name+"</option>";
    });
    $("#new_dialog select#custom_7").append (o);
    $("#new_dialog").dialog({"modal":true, autoOpen:false}).submit (function (e) {
      e.preventDefault();
      var fields = ["first_name", "last_name", "nick_name", "country","custom_2","custom_7"];
      var params = {
        "dedupe_check":true,
        "source": "civicrm/candidate",
        "contact_type":"Individual",
        "contact_sub_type":"candidate"
      };
      $.each(fields, function(id) {
        params[fields[id]]=$("#"+fields[id]).val();
      });
      params["country"]=countries_flat[params["country"]];
      var entity="contact";
      CRM.api(entity, "create", params, {
        context: this,
        error: function (data) {
console.log (data);
        },
        success: function (data) {
          params["id"]=data["id"];
          params["custom_7"]=parties_flat[params["custom_7"]];
          oTable.fnAddData( params);
          $("#new_dialog").dialog('close');
        }
      });
    });
      
    $("#add").click(function () { $("#new_dialog").dialog('open'); });



});

{/literal}
</script>

<table id="example"></table>

<div id="new_dialog">
<form>
<div class="form-item">
<label>Name</label>
<input id="first_name"  class="form-control "/>
</div>
<div class="form-item">
<label>Last Name</label>
<input id="last_name" class="form-control "/>
</div>
<div class="form-item">
<label>Party</label>
<select id="custom_7"  class="form-control ">
</select>
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
