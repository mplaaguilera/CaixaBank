/**********************************************************************************************************************
Name:	  AV_CustomCommentsHistory_Controller
Copyright © 2024  CaixaBank
=======================================================================================================================
Proposito: Controller para mostrar comentarios asociados a la oportunidad
=======================================================================================================================
Historial
---------------------
VERSION		USER_STORY		AUTHOR				DATE			Description
1.0         US796346        Gonzalo Ávila  	    31/01/2024		Init version
1.1         Fix             Sandra Gómez        22/04/2024      tolabel in query
1.2         Fix             Gonzalo Ávila       23/04/2024      resolve ordenation and invalid date problem
1.3         Fix             Gonzalo Ávila       24/04/2024      change AV_ModificationDate to CreatedDate
1.4         Fix Timeline    Luis Fernández      03/06/2024      Added filter post-query in getRecords in order to purge duplicate records

***********************************************************************************************************************/
public with sharing class AV_CustomCommentsHistory_Controller {
    @AuraEnabled(cacheable=true)
    public static DataResponse getRecords(String recordId){
        
        DataResponse response = new DataResponse();
        List<Column> listCols = new List<Column>();
        
        // Column labels
        List<String> labels = new List<String>{'FECHA', 'COMENTARIO', 'ETAPA', 'EMPLEADO'};

        response.labelObject = SObjectType.AV_CommentsHistory__c.getLabelPlural();                
        response.icono = 'standard:walkthroughs';
        response.title = Label.AV_CommentsRelatedLabel;

        for(String label : labels){
            Column col = new Column();
            col.sortable = true;
            col.label = label;
            col.hideDefaultActions = true;

            if (label.equalsIgnoreCase('FECHA')) {
                col.fieldName = 'CreatedDate';
                col.sortBy = 'CreatedDate';
                col.type = 'datetime'; 
                AV_CustomCommentsHistory_Controller.CLS_TypeAttributes attributes = new AV_CustomCommentsHistory_Controller.CLS_TypeAttributes();
                attributes.day = '2-digit';
                attributes.month = 'short';
                attributes.year = 'numeric';
                attributes.hour = '2-digit'; 
                attributes.minute = '2-digit'; 
                col.typeAttributes = attributes;
            }
            else if(label.equalsIgnoreCase('COMENTARIO')){
                col.fieldName = 'AV_NewComment__c';
                col.sortBy = 'AV_NewComment__c';
            }
            else if(label.equalsIgnoreCase('ETAPA')){
                col.fieldName = 'AV_OpportunityStatus__c';
                col.sortBy = 'AV_OpportunityStatus__c';
            }
            else if(label.equalsIgnoreCase('EMPLEADO')){
                col.fieldName = 'ownerLink';
				col.type = 'url';
				CLS_TypeAttributes attributes = new CLS_TypeAttributes();
				CLS_Label clslabel = new CLS_Label();
				Tooltip tooltip = new Tooltip();
				tooltip.fieldName = 'ownerLabel';
				clslabel.fieldName = 'ownerLabel';
				attributes.label = clslabel;
				attributes.tooltip = tooltip;
				col.sortBy = 'ownerLabel';
				col.typeAttributes = attributes;
            }
            listCols.add(col);
        }

        response.cols = listCols;
        
        List<AV_CommentsHistory__c> queryComments = [SELECT CreatedDate, AV_NewComment__c, TOLABEL(AV_OpportunityStatus__c), AV_AssignedEmployee__r.Name, AV_Opportunity__c,AV_OldComment__c FROM AV_CommentsHistory__c WHERE AV_Opportunity__c = :recordId  ORDER BY CreatedDate DESC]; 

        Set<String> codedComments = new Set<String>();
        Map<String,AV_CommentsHistory__c> codedCmms = new Map<String,AV_CommentsHistory__c>();
        for(AV_CommentsHistory__c cmmh : queryComments){
            String key = cmmh.AV_Opportunity__c+cmmh.AV_NewComment__c+cmmh.AV_OldComment__c;
            if(!codedCmms.containsKey(key)){
                codedCmms.put(key,cmmh);
            }

        }
        
        
        response.data = codedCmms.values();
        return response;
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
        public List<AV_CommentsHistory__c> data;
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
        public String hour;
        @AuraEnabled
        public String minute;
        @AuraEnabled
        public Tooltip tooltip;    //Subject
    }
    
    public class CLS_Label {
        @AuraEnabled
        public String fieldName;
    }

    public class CLS_Class {
        @AuraEnabled
        public String fieldName;
    }

    public class Tooltip {
        @AuraEnabled
        public String fieldName;
    }
}