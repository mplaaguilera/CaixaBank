public with sharing class SAC_LCMP_MensajeComplementaria {

    @AuraEnabled(cacheable=true)
    public static cASE getReclamacionVinculada(Id idReclamacionVinculada){

        List<Case> listaCasos = [SELECT Id, CaseNumber FROM Case WHERE Id = :idReclamacionVinculada];

        if(!listaCasos.isEmpty()){
            Case reclamacion = listaCasos[0];
            return reclamacion;
        }else{
            return null;
        }
    }


}