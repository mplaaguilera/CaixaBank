public with sharing class CC_Mostrar_Oportunidades_Controller {
    public class modelTimeLine {
        @AuraEnabled
        public Id RecordId {get;set;}
    
        @AuraEnabled
        public String Name {get;set;}
    
        @AuraEnabled
        public String CreatedDate {get;set;}
        
        @AuraEnabled
        public String Estado {get;set;}

        @AuraEnabled
        public String Propietario {get;set;}
    }

    @AuraEnabled(cacheable=true)
    public static List<modelTimeLine> getOportunidades(Id recordId) {
        List<modelTimeLine> retorno = new List<modelTimeLine>();
        List<Opportunity> oportunidades = [SELECT Id, Name, OwnerId, Owner.Name, CSBD_Estado__c, CreatedDate FROM Opportunity WHERE CSBD_CasoOrigen__c = :recordId ORDER BY CreatedDate DESC LIMIT 50];
        if(!oportunidades.isEmpty()) {
            for (Opportunity oportunidad : oportunidades) {
                modelTimeLine oportunidadItem = new modelTimeLine();
                oportunidadItem.RecordId = oportunidad.Id;
                oportunidadItem.Name = oportunidad.Name;
                oportunidadItem.CreatedDate = oportunidad.CreatedDate.format('dd-MM-yyyy HH:mm');
                oportunidadItem.Estado = oportunidad.CSBD_Estado__c;
                oportunidadItem.Propietario = oportunidad.Owner.Name;
                retorno.add(oportunidadItem);
            }
		}
        return retorno.isEmpty() ? null : retorno;
    }
}