{literal}
<style>
    .slick-headerrow-column {
      background: #87ceeb;
      text-overflow: clip;
      -moz-box-sizing: border-box;
      box-sizing: border-box;
    }

    .slick-headerrow-column input {
      margin: 0;
      padding: 0;
      width: 100%;
      height: 100%;
      -moz-box-sizing: border-box;
      box-sizing: border-box;
    }

#candidates {
height:500px;
}

    #nnoocandidates {
position:fixed;
top:50px;
z-index:9000;
left:0;
right:0;
bottom:0;
width:100%;
    }
nok.grid-header {
position:fixed;
top:28px;
width:100%;
}


</style>
{/literal}

    <div class="grid-header" style="width:100%">
      <label>Candidates</label>
      <span style="float:right" class="ui-icon ui-icon-search" title="Toggle search panel"
            onclick="toggleFilterRow()"></span>
    </div>
 <div id="candidates"></div>
    <div id="pager" style="width:100%;height:20px;">Pager</div>
   <div style="padding:6px;">
      <label style="width:200px;float:left">Show tasks with % at least: </label>

      <div style="padding:2px;">
        <div style="width:100px;display:inline-block;" id="pcSlider"></div>
      </div>
      <br/>
      <label style="width:200px;float:left">And title including:</label>
      <input type=text id="txtSearch" style="width:100px;">
      <br/><br/>
      <button id="btnSelectRows">Select first 10 rows</button>


<script>
  var candidates = {crmAPI entity="contact" return="first_name,last_name,country,email,phone" contact_sub_type="mep" option_limit=10000};
</script>
