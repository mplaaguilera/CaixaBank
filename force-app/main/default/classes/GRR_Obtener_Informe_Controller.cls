public with sharing class GRR_Obtener_Informe_Controller {
  
  @AuraEnabled(cacheable=true)
  public static String getReportId(){
    GRR_Parametros__c params = GRR_Parametros__c.getInstance('GRR_RecobrosReport');
    String nombreInforme = params.GRR_Valor__c;

   return [SELECT Id FROM Report WHERE DeveloperName= :nombreInforme LIMIT 1]?.Id;
  }
  
}