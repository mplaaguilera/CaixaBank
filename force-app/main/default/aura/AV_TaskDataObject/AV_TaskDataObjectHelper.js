({
	showHide : function(component, strComponent) {
		var objCmp = component.find(strComponent);
		$A.util.toggleClass(objCmp, "slds-hide");
	},

	hide : function(component, strComponent) {
		var objCmp = component.find(strComponent);
		$A.util.addClass(objCmp, "slds-hide");
	},

	show : function(component, strComponent) {
		var objCmp = component.find(strComponent);
		$A.util.removeClass(objCmp, "slds-hide");
	},

	showSpinner : function (component) {
		var spinner = component.find("mySpinner");
		$A.util.removeClass(spinner, "slds-hide");
		$A.util.addClass(spinner, "slds-show");
	},

	hideSpinner : function (component) {
		var spinner = component.find("mySpinner");
		$A.util.removeClass(spinner, "slds-show");
		$A.util.addClass(spinner, "slds-hide");
	},

	displayToast : function (component, message, type){
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"title": $A.get("$Label.c.AV_CMP_Message"),
			"message": message,
			"type": type
		});
		toastEvent.fire();
	},

	displayToastSuccess : function (component, message){
		this.displayToast(component, message, "success");
	},

	displayToastWarning : function (component, message){
		this.displayToast(component, message, "warning");
	},

	displayToastError : function (component, message){
		this.displayToast(component, message, "error");
	},

	readWriteMode : function(component) {
		//Hidden the edit button (on top)
		var readOnly = component.get("v.readOnly");
		var allowEditMode = component.get("v.allowEditMode");
		if (readOnly) {
			this.hide(component, "divCreateUpdate");
			this.show(component, "divEditButton");
		}else{
			this.show(component, "divCreateUpdate");
			this.hide(component, "divEditButton");
		}
		//Not display the edit button
		if (!allowEditMode){
			this.hide(component, "divEditButton");
        }
        //$A.get('e.force:refreshView').fire();
	},

	editToogle: function(component){
		var inputModeBool = component.get("v.readOnly");
        component.set("v.readOnly", !inputModeBool);
        var flow = component.find("AV_TaskLookUp");
        var recId = component.get("v.recordId");
        var label = component.get("v.labelTask");
        var fields = component.get("v.fields");
        var fieldName =  fields[0].fieldPath;
        var value =  fields[0].value;
		var inputVariables;		
        if(value!=null){
            inputVariables = [
				{
					name : 'AV_FieldName',
					type : 'String',
					value : fieldName
				},
				{
					name : 'AV_recordId',
					type : 'String',
					value : recId
				},
				{
					name : 'AV_FieldLabel',
					type : 'String',
					value : label
				},	
                {
					name : 'AV_lookUpDefault',
					type : 'String',
					value : value
				}];
        }else{
            inputVariables = [
				{
					name : 'AV_FieldName',
					type : 'String',
					value : fieldName
				},
				{
					name : 'AV_recordId',
					type : 'String',
					value : recId
				},
				{
					name : 'AV_FieldLabel',
					type : 'String',
					value : label
				}];
        }
		flow.startFlow("AV_TaskLookUp", inputVariables);
		this.readWriteMode(component);
	},

	loadData: function(component, event, helper){
		var numColumn = component.get('v.columnNum');
		if(numColumn=='1'){
			component.set('v.numberColumns', 12);
		}
		else if(numColumn=='2'){
			component.set('v.numberColumns', 5);
		}
		else if(numColumn=='3'){
			component.set('v.numberColumns', 4);
		}

		var recordId = component.get("v.recordId");
		var objectApiName = component.get("v.objectApiName");
		var objectFilter = component.get("v.filterType");
		var filterField = component.get("v.filterField");
		var fsName = component.get("v.fieldSetName");
		if (recordId!=null && recordId!=undefined && objectApiName!=null && objectApiName!=undefined
			&& objectFilter!=null && objectFilter!=undefined && filterField!=null && filterField!=undefined
			&& fsName!=null && fsName!=undefined) {
			//Call action to retrieve the fields
			var getFieldsQuery = component.get("c.getFieldsQuery");
			getFieldsQuery.setParams({recordId: recordId,
										objectApiName: objectApiName,
										objectFilter: objectFilter,
										filterField: filterField,
										fsName: fsName});
			getFieldsQuery.setCallback(this, function(response) {
				if (response.getState() === "SUCCESS") {
					var fields = response.getReturnValue();				
					if(fields[0].valueName != ''){
						var labelTask
						if (fields[0].fieldPath.endsWith('__c')) {
							labelTask = $A.getReference("$Label.c."+"AV_"+fields[0].fieldPath.replace('__c', '')+"Label");
						} else {
							labelTask = $A.getReference("$Label.c."+"AV_"+fields[0].fieldPath+"Label");
						}
						if (labelTask != null) {
							component.set("v.labelTask", labelTask);
						}
						//If client doesn't have Interlocutor, hide this block in SObjectRelatedInfo
						if (fields[0].fieldPath == 'Account.AV_Interlocutor__c') {
							if (fields[0].value == null) {
								var compEvent = component.getEvent("interlocutorEvent");
								compEvent.setParams({
									"hasInterlocutor": false
								});
								compEvent.fire();
							} else {
								component.set("v.interlocutor", fields[0].value);
							}
						}
					}
					for( var i = 0; i < fields.length; i++){ 
						if ( fields[i].fieldPath === 'Status') { 
							if(fields[i].value == 'Gestionada positiva' || fields[i].value == 'Gestionada negativa'){
								component.set("v.canEdit",true);
							}
							fields.splice(i, 1);
						}
					}
					component.set("v.fields", fields);
					this.getIdFilterObject(component, event, helper);
				}
				else if (response.getState() === "INCOMPLETE") {
					helper.displayToastWarning(component, $A.get("$Label.c.AV_UserOffline"));
				}
				else if (response.getState() === "ERROR") {
					helper.displayToastError(component, JSON.stringify(response.getError()));
				}
				else {
					helper.displayToastError(component, $A.get("$Label.c.AV_UnknownError") + '. ' + JSON.stringify(response.getError()));
				}
			});
			$A.enqueueAction(getFieldsQuery);
		}
	},

	getIdFilterObject : function (component, event, helper){
		var recordId = component.get("v.recordId");
		var objectApiName = component.get("v.objectApiName");
		var objectFilter = component.get("v.filterType");
		var filterField = component.get("v.filterField");
		if (recordId!=null && recordId!=undefined && objectApiName!=null && objectApiName!=undefined
			&& objectFilter!=null && objectFilter!=undefined && filterField!=null && filterField!=undefined) {
			//Call action for retrieve the ID of the SObject
			var getIdFilterObject = component.get("c.getIdFilterObject");
			getIdFilterObject.setParams({recordId: recordId,
											objectApiName: objectApiName,
											objectFilter: objectFilter,
											filterField: filterField});
			getIdFilterObject.setCallback(this, function(response) {
				if (response.getState() === "SUCCESS") {
					var filterObjectId = response.getReturnValue();
					component.set("v.filterObjectId", filterObjectId);
				}
				else if (response.getState() === "INCOMPLETE") {
					helper.displayToastWarning(component, $A.get("$Label.c.AV_UserOffline"));
				}
				else if (response.getState() === "ERROR") {
					helper.displayToastError(component, JSON.stringify(response.getError()));
				}
				else {
					helper.displayToastError(component, $A.get("$Label.c.AV_UnknownError") + '. ' + JSON.stringify(response.getError()));
				}
				this.hideSpinner(component);
			});
			$A.enqueueAction(getIdFilterObject);
		}
	}

})