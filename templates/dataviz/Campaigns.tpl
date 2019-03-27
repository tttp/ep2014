{crmTitle title="List of pledges"}
    {crmAPI var='result' entity='Campaign' action='get' return="id,title,description,external_identifier" is_active=1}
<ul>
    {foreach from=$result.values item=campaign}
      {if $campaign.external_identifier}
      <li><a href="/civicrm/dataviz/campaign/{$campaign.external_identifier}">{$campaign.title}</a> <i>by {$campaign.description}</i></li>
{else}
      <li>{$campaign.title} <i>by {$campaign.description}</i></li>
{/if}
    {/foreach}
</ul>
