public with sharing class SAC_CaseControllerVF {

    private Case reclamacion;
    private List<Case> pretensiones;

    public String getReclamacion() {
        return reclamacion.CaseNumber + ' - ' + reclamacion.Subject;
    }

    public String getPretensiones() {
        String redaccion = '';
        for(Case pretension : pretensiones){
            redaccion += pretension.SAC_Redaccion__c + '\n';
        }
        return redaccion;
    }

    public SAC_CaseControllerVF(){

        reclamacion = [SELECT Id, CaseNumber, Subject, SAC_Redaccion__c FROM Case WHERE Id =: ApexPages.currentPage().getParameters().get('id')];
        pretensiones = [SELECT Id, SAC_Redaccion__c FROM Case WHERE SAC_Reclamacion__c =: ApexPages.currentPage().getParameters().get('id')];
    }
}