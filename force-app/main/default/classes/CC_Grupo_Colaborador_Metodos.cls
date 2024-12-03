public class CC_Grupo_Colaborador_Metodos {

    @InvocableMethod(label='CC_Grupo_Colaborador_Metodos' description='Generar externalId Grupo Colaborador')
    public static void generaExternalId (List<Id> grupos)
    {
        if (!grupos.isEmpty())
         {
             List<CC_Grupo_Colaborador__c> listGrupos= [SELECT Id, CC_External__c, RecordType.DeveloperName FROM CC_Grupo_Colaborador__c WHERE Id IN : grupos];             
             
             List<CC_Grupo_Colaborador__c> gruposUpdate = new List<CC_Grupo_Colaborador__c>();  
             
             Id recordTypeIdGrupoColaborador = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
             Id recordTypeIdGrupoMaximo = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_GrupoMaximo').getRecordTypeId();
             Id recordTypeIdComunicacionInformativa = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Comunicacion_Informativa').getRecordTypeId();
             
             List <CC_Grupo_Colaborador__c> codigosExternosGrupoColaborador = [SELECT CC_External__c FROM CC_Grupo_Colaborador__c WHERE RecordTypeId = :recordTypeIdGrupoColaborador AND CC_External__c <> null ORDER BY CC_External__c DESC LIMIT 1 ];
             List <CC_Grupo_Colaborador__c> codigosExternosGrupoMaximo = [SELECT CC_External__c FROM CC_Grupo_Colaborador__c WHERE RecordTypeId = :recordTypeIdGrupoMaximo AND CC_External__c <> null ORDER BY CC_External__c DESC LIMIT 1];
             List <CC_Grupo_Colaborador__c> codigosExternosComunicacionInformativa = [SELECT CC_External__c FROM CC_Grupo_Colaborador__c WHERE RecordTypeId = :recordTypeIdComunicacionInformativa AND CC_External__c <> null ORDER BY CC_External__c DESC LIMIT 1];
             
             
             String codigoExternoGrupoColaborador = codigosExternosGrupoColaborador.get(0).CC_External__c;
             String[] codExternoGrupoColaborador = codigoExternoGrupoColaborador.split('-');
             Integer numGrupoColaborador = Integer.ValueOf(codExternoGrupoColaborador[1]);
             for (CC_Grupo_Colaborador__c grupo : listGrupos){
                 if (grupo.RecordType.DeveloperName == 'CC_Grupo_Colaborador' && grupo.CC_External__c == null){                         
                     numGrupoColaborador = numGrupoColaborador+1;
                     codigoExternoGrupoColaborador = String.valueOf(numGrupoColaborador).leftPad(5, '0');
                     codigoExternoGrupoColaborador = codExternoGrupoColaborador[0] + '-' +codigoExternoGrupoColaborador;
                     grupo.CC_External__c = codigoExternoGrupoColaborador;
                 }else if (grupo.RecordType.DeveloperName == 'CC_GrupoMaximo' && grupo.CC_External__c == null){
                     String codigoExternoGrupoMaximo = codigosExternosGrupoMaximo.get(0).CC_External__c;
                     String[] codExternoGrupoMaximo = codigoExternoGrupoMaximo.split('-');
                     Integer numGrupoMaximo = Integer.ValueOf(codExternoGrupoMaximo[1]);
                     numGrupoMaximo = numGrupoMaximo+1;
                     codigoExternoGrupoMaximo = String.valueOf(numGrupoMaximo).leftPad(5, '0');
                     codigoExternoGrupoMaximo = codExternoGrupoMaximo[0] + '-' +codigoExternoGrupoMaximo;
                     grupo.CC_External__c = codigoExternoGrupoMaximo;
                 }else if(grupo.RecordType.DeveloperName == 'CC_Comunicacion_Informativa' && grupo.CC_External__c == null){
                     String codigoExternoComunicacionInformativa = codigosExternosComunicacionInformativa.get(0).CC_External__c;
                     String[] codExternoComunicacionInformativa = codigoExternoComunicacionInformativa.split('-');
                     Integer numComunicacionInformativa = Integer.ValueOf(codExternoComunicacionInformativa[1]);
                     numComunicacionInformativa = numComunicacionInformativa+1;
                     codigoExternoComunicacionInformativa = String.valueOf(numComunicacionInformativa).leftPad(5, '0');
                     codigoExternoComunicacionInformativa = codExternoComunicacionInformativa[0] + '-' +codigoExternoComunicacionInformativa;
                     grupo.CC_External__c = codigoExternoComunicacionInformativa;
                 }
                 gruposUpdate.add (grupo);
             }
             update gruposUpdate;
         }
    }
}