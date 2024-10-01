<master>
<property name="context">@context;literal@</property>
<property name="&body">body</property>
<property name="&doc">doc</property>
<if @item_id@ not nil><property name="displayed_object_id">@item_id;literal@</property></if>

<!-- The following DIV is needed for overlib to function! -->
<div id="overDiv" style="position:absolute; visibility:hidden; z-index:1000;"></div>
<div class='xowiki-content'>
  <if @body.menubarHTML@ not nil><div class='visual-clear'><!-- --></div>@body.menubarHTML;noquote@</if>
  <if @page_context@ not nil><h1>@body.title@ (@page_context@)</h1></if>
  <else><h1>@body.title@</h1></else>
  @content;noquote@
  @top_includelets;noquote@
</div> <!-- class='xowiki-content' -->

