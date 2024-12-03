({
	doInit : function (component, event, helper) {
    $A.get('e.force:refreshView').fire();
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      "url": "/" + component.get('v.identificador')
    });
    urlEvent.fire();
  }
})