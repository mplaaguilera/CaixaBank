/**********************************************************************************************************************
Name:	  AV_LinkedLeadOpp_Controller
Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Link a Lead Oportunidad desde Tarea 
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	  AUTHOR		   	    DATE				Description
	1.0			US473478	  Vladislav Lityagin  	11/10/2022		  	Init version
    1.1         Fix SortBy    Elisabeth Rodríguez   09/02/2022          Added sortBy attribute

***********************************************************************************************************************/

public without sharing class AV_LinkedLeadOpp_Controller {

    public static final String OBJECT_LEADOPP = 'AV_LeadOpportunity__c';

    @AuraEnabled(cacheable=true)
	public static DataResponse getLeadOpp(String recordId, String objectName, String valid){
        String methodName = 'getRecords';
		
		DataResponse response = new DataResponse();
		List<SObject> listRecords = new List<SObject>();
		Set<String> setFieldApiNames = new Set<String>();
		Set<String> picklistField = new Set<String>();
		List<Column> listCols = new List<Column>();
		List<Column> listColsToShow = new List<Column>();
		Set<Id> setAccId = new Set<Id>();

        for(Schema.FieldSetMember fld :SObjectType.AV_LeadOpportunity__c.FieldSets.AV_LinkedLeadOpp.getFields()) {


            Column col = new Column();
			Schema.DisplayType fldType;
			if (!fld.getFieldPath().equalsIgnoreCase('Owner.Name') && !fld.getFieldPath().equalsIgnoreCase('AV_Producto__r.Name') /*&& !fld.getFieldPath().equalsIgnoreCase('AV_Lead__r.Name')*/){
					Map<String, Schema.SObjectField> mapa;
					mapa = Schema.SObjectType.AV_LeadOpportunity__c.fields.getMap();
					Schema.SObjectField field = mapa.get(fld.getFieldPath());
					fldType = field.getDescribe().getType();
			} 

			if(!fld.getFieldPath().equalsIgnoreCase('Owner.Name') || !fld.getFieldPath().equalsIgnoreCase('AV_Producto__r.Name') || !fld.getFieldPath().equalsIgnoreCase('AV_Lead__r.Name')){
				col.sortBy = fld.getFieldPath();
			}
			col.sortable = true;
			col.label = fld.getLabel().toUpperCase();
			col.fieldName = fld.getFieldPath();
			col.hideDefaultActions = true;
			if(fldType != Null && fldType == Schema.DisplayType.Picklist){
				picklistField.add(col.fieldName); 
			}else{
				setFieldApiNames.add(col.fieldName);
			}

            if(fldType != null && (fldType == Schema.DisplayType.DateTime || fldType == Schema.DisplayType.Date)) {
				col.label = Label.AV_DueDateTXT.toUpperCase();
				col.type = 'date';
				CLS_TypeAttributes attributes = new CLS_TypeAttributes();
				attributes.day = '2-digit';
				attributes.month = 'short';
				attributes.year = 'numeric';
				col.typeAttributes = attributes;
			}
			
			if(fld.getFieldPath().equalsIgnoreCase('Owner.Name')) {
				col.label = Label.AV_OwnerIdLabel.toUpperCase();
				col.fieldName = 'ownerLink';
				col.type = 'url';
				CLS_TypeAttributes attributes = new CLS_TypeAttributes();
				CLS_Label label = new CLS_Label();
				label.fieldName = 'ownerLabel';
				col.sortBy = 'ownerLabel';
				attributes.label = label;
				attributes.tooltip = 'Owner.Name';
				col.typeAttributes = attributes;
			}

            if(fld.getFieldPath().equalsIgnoreCase('AV_Status__c')) {
				col.label=Label.AV_StatusTXT.toUpperCase();
				col.fieldName = 'AV_Status__c';
				col.type = 'text';
				CLS_Class cls = new CLS_Class();
				cls.fieldName = 'customClass';
				col.cellAttributes = new Map<String, CLS_Class>{'class' => cls};
			}

            if(fld.getFieldPath().equalsIgnoreCase('AV_Producto__r.Name')) {
				col.fieldName = 'Product2';
				col.sortBy = 'Product2';
				col.type = 'string';
				CLS_Class cls = new CLS_Class();
				cls.fieldName = 'customClass';
				col.cellAttributes = new Map<String, CLS_Class>{'class' => cls};
			}

            if(fld.getFieldPath().equalsIgnoreCase('AV_PrescriberId__c')) {
				col.fieldName = 'AV_PrescriberId__c';
				col.type = 'text';
                col.label = Label.AV_OriginTXT.toUpperCase();
				CLS_Class cls = new CLS_Class();
				cls.fieldName = '';
				col.cellAttributes = new Map<String, CLS_Class>{'class' => cls};
			}

            if(fld.getFieldPath().equalsIgnoreCase('Name')) {
                col.fieldName = 'leadoppLink';
				col.sortBy = 'leadoppLabel';
                col.type = 'url';
                CLS_TypeAttributes attributes = new CLS_TypeAttributes();
                CLS_Label label = new CLS_Label();
                label.fieldName = 'leadoppLabel';
                attributes.label = label;
                attributes.tooltip = 'Id';
                col.typeAttributes = attributes;
            }

            listCols.add(col);
        }
		
		
        String targetObjectName = OBJECT_LEADOPP;
		
		response.labelObject = SObjectType.AV_LeadOpportunity__c.getLabelPlural();			
		if(targetObjectName.equalsIgnoreCase(OBJECT_LEADOPP)){
			response.icono = 'utility:archive';
			response.title = response.labelObject;
		}

		//Obtener de forma distinta los AccsIds
        setAccId = getAccountIds(recordId, objectName);
        System.debug('Setaccid--->' + setAccId);
        System.debug('recordId--->' + recordId);
        System.debug('objectName-->'+ objectName);
        listRecords = getRecordsByDynamicQuery(setFieldApiNames, picklistField, targetObjectName, setAccId, valid);
        
        AV_LogDebug.printLogDebug(methodName, 'Registro recuperados: ' + listRecords.size());
		AV_LogDebug.printLogDebug(methodName, 'Columnas total: ' +listCols);
		
		response.cols = listCols;
		response.data = listRecords;
		return response;
    }

    private static Set<Id> getAccountIds(String id, String objectName){
        Set<Id> setAccId = new Set<Id>();
		String accId = '';
		if(objectName.equalsIgnoreCase('Task')){
			accId = [SELECT AccountId FROM Task WHERE Id =: id LIMIT 1].AccountId;
			setAccId.add(accId);
		}else if(objectName.equalsIgnoreCase('Event')){
			accId = [SELECT AccountId FROM Event WHERE Id =: id LIMIT 1].AccountId;
			setAccId.add(accId);
		}else if(objectName.equalsIgnoreCase('Account')){
			setAccId.add(id);
		}
        System.debug('setAccid2--'+ setAccId);
        return setAccId;
    }

    private static List<SObject> getRecordsByDynamicQuery(Set<String> setFieldApiNames, Set<String> picklistField, String targetObjectName, Set<Id> setLeadOppIds, String valid){
		String methodName = 'getRecordsByDynamicQuery';
		if (setFieldApiNames==null){
			setFieldApiNames = new Set<String>();
		}
		setFieldApiNames.add('Id');

		String querysoql = 'SELECT';
		integer i=0;
		for(String field : setFieldApiNames){
			querysoql += ' '+field;
			i++;
			if(i!= setFieldApiNames.size()) {
                querysoql += ',';
            }
		
		}
		if(!picklistField.isEmpty()){
			for(String fieldPick : picklistField){
				querysoql += ',TOLABEL (' + fieldpick + ')';
			}
		}
		querysoql += ' FROM '+targetObjectName ;
		String formatSetAccsIds = '(\'\')';
		if(!setLeadOppIds.isEmpty()){
			i=0;
			formatSetAccsIds= '(';
		for(String id :setLeadOppIds){
			formatSetAccsIds += '\''+id+'\'';
			formatSetAccsIds += ((++i)!=setLeadOppIds.size())?',':')';
		}
		}
		//LeadOpp object
        if(OBJECT_LEADOPP.equalsIgnoreCase(targetObjectName)){
            querysoql += ' WHERE AV_Lead__r.AV_numperso__c IN '+formatSetAccsIds /*+ ' AND RecordType.DeveloperName =: AV_AppConstants.LEAD_PPHH_RT'*/;
        }
		//comprobar Vigente o No vigente para distinto filtro
        if(valid!=null && !String.isEmpty(valid)){
            if(valid.equalsIgnoreCase('Vigente')){
                querysoql += ' AND AV_StatusLeadOpp__c in (\''+AV_AppConstants.LEADOPP_STAGE_GESTION
                +'\', \''+AV_AppConstants.LEADOPP_STAGE_POTENCIAL+
                '\') ORDER BY LastModifiedDate desc';
            }else if(valid.equalsIgnoreCase('NoVigente')){
                querysoql += ' AND AV_StatusLeadOpp__c in (\''+AV_AppConstants.LEADOPP_STAGE_POSITIVA
                +'\', \''+AV_AppConstants.LEADOPP_STAGE_NEGATIVA
                +'\', \''+AV_AppConstants.LEADOPP_STAGE_VENTA
                +'\', \''+AV_AppConstants.LEADOPP_STAGE_NO_APTO
                +'\', \''+AV_AppConstants.LEADOPP_STAGE_VENCIDA
                +'\') ORDER BY AV_FechaCierreGestion__c desc';
            }
        }
		
		return capsulateQuery(querysoql);
	}

	private static List<SObject> capsulateQuery(String q){
		return Database.query(q);
	}

    public class DataResponse {
		@AuraEnabled
		public String labelObject;
		@AuraEnabled
		public String icono;
		@AuraEnabled
		public String title;
		@AuraEnabled
		public List<Column> cols;
		@AuraEnabled
		public List<Object> data;
	}

    public class Column {
		@AuraEnabled
		public String label;
		@AuraEnabled
		public String fieldName;
		@AuraEnabled
		public String type;
		@AuraEnabled
		public CLS_TypeAttributes typeAttributes;
		@AuraEnabled
		public Map<String, CLS_Class> cellAttributes;
		@AuraEnabled
		public boolean sortable;
		@AuraEnabled
		public String sortBy;
		@AuraEnabled
		public boolean hideDefaultActions;
		
		public Column() {
			typeAttributes = new CLS_TypeAttributes();
		}		
	}
	
	public class CLS_TypeAttributes {
		@AuraEnabled
		public CLS_Label label;
		@AuraEnabled
		public String day;
		@AuraEnabled
		public String month;
		@AuraEnabled
		public String year;
		@AuraEnabled
		public String tooltip;	//Subject
		//@AuraEnabled
		//public String target;	//_blank
	}

	public class CLS_Label {
		@AuraEnabled
		public String fieldName;
	}

	public class CLS_Class {
		@AuraEnabled
		public String fieldName;
	}
}