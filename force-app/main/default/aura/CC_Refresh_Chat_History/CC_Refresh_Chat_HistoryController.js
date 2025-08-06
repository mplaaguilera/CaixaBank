({
	init : function(cmp, event, helper) {
        let recordId = cmp.get('v.recordId');   
        let cognitivo = true;
        //window.setTimeout($A.getCallback(() => {
			cmp.find('cc_Chat_History').lwcRefresh(recordId, cognitivo);
        //}),5000);
    }
})