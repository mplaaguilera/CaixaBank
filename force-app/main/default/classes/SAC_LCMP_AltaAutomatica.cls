/*****************************************************************
 * Name: SAC_LCMP_AltaAutomatica
 * Copyright © 2023  CaixaBank
 * 
 * Proposito: Clase controlador del componente sac_AltaAutomatica
 * Clase test: SAC_LCMP_AltaAutomatica_Test
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US354289         CS                   09/10/2023   Creación
*****************************************************************/
public without sharing class SAC_LCMP_AltaAutomatica {

    private static Set<String> objetos = new Set<String>{'Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
    private static final Id RECORDTYPERECLAMACION = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    private static final Id RECORDTYPEPRETENSION = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();

    @AuraEnabled(cacheable = true)
    public static WrapperAvisos recuperarCasos(String caseId, String caseRecordTypeId, String reclamacionPadre, Boolean recPadreEsM2P, Boolean esM2P, String entidadAfectada, String sentidoResolucion, String status, String casoRelacionado){
        try {
            //Wrapper para devolver datos al componente
            WrapperAvisos wpAvisos = new WrapperAvisos();
            //Comprobar si es una copia masiva mediante el campo relacionado, y en caso de serlo, buscar el caseNumber del caso relacionado.
            if (String.isNotBlank(casoRelacionado)) {
                List<Case> listaCasoRelacionado = [SELECT Id, CaseNumber FROM Case WHERE RecordTypeId IN(:RECORDTYPERECLAMACION, :RECORDTYPEPRETENSION) AND Id = :casoRelacionado];

                if (!listaCasoRelacionado.isEmpty()) {
                    wpAvisos.avisoCopiaMasiva = 'Este caso ha sido generado de forma masiva a partir del caso ' + listaCasoRelacionado[0].CaseNumber;
                    wpAvisos.mostrarAvisoCopiaMasiva = true;
                }
            }
            
            //Comprobar si es reclamación o pretensión para hacer la comprobacion de si necesita mostrar un aviso de buzón SAC o M2P
            if (caseRecordTypeId == RECORDTYPERECLAMACION) {
                wpAvisos.listaAvisos = comprobacionesReclamacion(esM2P, caseId);
                wpAvisos.mostrarAvisoM2P = !wpAvisos.listaAvisos.isEmpty() ? true : false;
            } else if (caseRecordTypeId == RECORDTYPEPRETENSION) {
                String aviso = comprobacionesPretension(recPadreEsM2P, entidadAfectada, sentidoResolucion, status);
                if (String.isNotBlank(aviso)) {
                    wpAvisos.listaAvisos.add(aviso);
                    wpAvisos.mostrarAvisoM2P = true;    
                }
            }

            return wpAvisos;
        } catch (Exception e) {CBK_Log.error(e); throw new AuraHandledException(e.getMessage());}
    }

    public static List<String> comprobacionesReclamacion(Boolean esM2P, String caseId) {
        List<String> listaAvisos = new List<String>();
        //Recuperar pretensiones hijas
        List <Case> listaPrets = [SELECT Id, SAC_Entidad_Afectada__c, SAC_SentidoResolucion__c, Status, CaseNumber FROM Case WHERE RecordTypeId = :RECORDTYPEPRETENSION AND SAC_Reclamacion__c = :caseId];
        for (Case pret : listaPrets) {
            if (String.isNotBlank(pret.SAC_Entidad_Afectada__c) && esM2P && pret.SAC_Entidad_Afectada__c != 'SAC_010' && pret.SAC_SentidoResolucion__c != 'SAC_004' && pret.Status != 'SAC_009') {
                //avisar de la pretension que no es m2p
                listaAvisos.add('La pretensión '+ pret.CaseNumber + ' no tiene entidad afectada Money to pay. Por favor, inadmita la pretensión y comunique al cliente que debe reclamarla por el buzón SAC');
            }
            else if (String.isNotBlank(pret.SAC_Entidad_Afectada__c) && !esM2P && pret.SAC_Entidad_Afectada__c == 'SAC_010' && pret.SAC_SentidoResolucion__c != 'SAC_004' && pret.Status != 'SAC_009') {
                //avisar de la pretension que es m2p
                listaAvisos.add('La pretensión '+ pret.CaseNumber + ' tiene entidad afectada Money to pay. Por favor, inadmita la pretensión y comunique al cliente que debe reclamarla por el buzón M2P');
            }
        }

        return listaAvisos;
    }

    public static String comprobacionesPretension(Boolean recPadreEsM2P, String entidadAfectada, String sentidoResolucion, String status) {
        String aviso = '';
        if (String.isNotBlank(entidadAfectada) && recPadreEsM2P && entidadAfectada != 'SAC_010' && sentidoResolucion != 'SAC_004' && status != 'SAC_009') {
            aviso = 'Esta pretensión no es "Money to pay". Por favor, inadmita la pretensión y comuniquese con el cliente para que mande la reclamación por el buzón SAC';
        }
        else if (String.isNotBlank(entidadAfectada) && !recPadreEsM2P && entidadAfectada == 'SAC_010' && sentidoResolucion != 'SAC_004' && status != 'SAC_009') {
            aviso = 'Esta pretensión es "Money to pay". Por favor, inadmita la pretensión y comuniquese con el cliente para que mande la reclamación por el buzón M2P';
        }

        return aviso;
    }

    public class WrapperAvisos{
        @AuraEnabled
        public Boolean mostrarAvisoM2P;
        @AuraEnabled
        public List<String> listaAvisos = new List<String>();
        @AuraEnabled
        public Boolean mostrarAvisoCopiaMasiva;
        @AuraEnabled
        public String avisoCopiaMasiva;
    }
}