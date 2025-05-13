/*****************************************************************
 * Name: SAC_LCMP_DespachoRepresentante
 * Copyright © 2023  CaixaBank
 * 
 * Proposito: Clase controlador del componente sac_DespachoRepresentante
 * Clase test: SAC_LCMP_DespachoRepresentante_Test
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US1093930       Álex Polo          08/01/2025        Creación
*****************************************************************/

public with sharing class SAC_LCMP_DespachoRepresentante {

    private static Set<String> objetos = new Set<String>{'SAC_MaestroTemas__c', 'CC_Caracteristica__c', 'CC_Grupo_Colaborador__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    //Los maestros de temas con este Record Type van a indicar qué valores de despachos representantes se pueden escoger
    private final static Id RECTYPEDESPACHOS_MAESTROTEMAS = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_DespachoRepresentante').getRecordTypeId();
    private final static Id RTREPRESENTANTECARACTERISTICA = mapRTsObjects.get('CC_Caracteristica__c').get('SAC_CaracteristicaRepresentante').getRecordTypeId();

    //Rec Type de Tareas
    private static final Id RECTYGRUPOTAREAS = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SAC_GrupoResponsableAccion').getRecordTypeId();


    //Los valores que se van a mostrar a modo de picklist serán aquellos nombres de maestro de temas con el RT correspondiente
    @AuraEnabled(cacheable=true)
    public static List<String> obtenerValoresDespachoRepresentante(){

        List<SAC_MaestroTemas__c> listaMaestroTemas = new List<SAC_MaestroTemas__c>();
        List<String> listaNombresDespachos = new List<String>();

        listaMaestroTemas = [SELECT Id, Name FROM SAC_MaestroTemas__c WHERE RecordTypeId = :RECTYPEDESPACHOS_MAESTROTEMAS AND SAC_Activo__c = true ORDER BY Name ASC];
        
        if(!listaMaestroTemas.isEmpty()){
            for(SAC_MaestroTemas__c despacho : listaMaestroTemas){
                listaNombresDespachos.add(despacho.Name);
            }
            return listaNombresDespachos;
        }else{
            return new List<String>();
        }
    }


    //Se almacena el valor seleccionado en el campo correspondiente del case extension
    @AuraEnabled
    public static void guardarDespachoRepresentante(String despachoSeleccionado, Id idCaso){

        CBK_Case_Extension__c casoExtension = new CBK_Case_Extension__c();
        List<Case> listaCasos = [SELECT SAC_TipoDeRepresentante__c, CBK_Case_Extension_Id__c, CBK_Case_Extension_Id__r.SAC_DespachoRepresentante__c FROM Case WHERE Id = :idCaso];

        if(!listaCasos.isEmpty()){
            Case casoReclamacion = listaCasos[0];
            casoExtension.Id = casoReclamacion.CBK_Case_Extension_Id__c;

            if(casoReclamacion.SAC_TipoDeRepresentante__c == 'SAC_Abogado'){
                if(despachoSeleccionado == '--None--'){                             //Si en la picklist se ha elegido el valor de --None--, se vacía el campo
                    casoExtension.SAC_DespachoRepresentante__c = null;
                }else{
                    casoExtension.SAC_DespachoRepresentante__c = despachoSeleccionado;
                }
            }else{
                casoExtension.SAC_DespachoRepresentante__c = null;
            }

            SAC_DatabaseDML.updateDML(casoExtension, false);
        }

    }

    public class GestorLetradoWrapper{

        @AuraEnabled public Boolean esUsuarioLetrado {get; set;}
        @AuraEnabled public Boolean esUsuarioGestor {get; set;}
        @AuraEnabled public Boolean esUsuarioCOPSAJ {get; set;}

        public GestorLetradoWrapper(Boolean varEsUsuarioLetrado, Boolean varEsUsuarioGestor, Boolean varEsUsuarioCOPSAJ)
        {
            esUsuarioLetrado = varEsUsuarioLetrado;
            esUsuarioGestor = varEsUsuarioGestor;
            esUsuarioCOPSAJ = varEsUsuarioCOPSAJ;
        }
    }

    
    //Comprobar si el usuario es owner de la reclamación o de alguna de sus pretensiones
    @AuraEnabled
    public static GestorLetradoWrapper verSiGestorLetrado(id idCaso, id ownerCaso){
        String idUser = UserInfo.getUserId();
        List<Case> listaPretensiones = new List<Case>();
        Boolean esGestor = false;
        Boolean esLetrado = false;
        Boolean esCOPSAJ = false;

        //Se obtienen las pretnsiones de la reclamación
        listaPretensiones = listaPretensiones = [SELECT Id, SAC_Reclamacion__c, OwnerId FROM Case WHERE SAC_Reclamacion__c = :idCaso];
  
        //Si el usuario es owner de alguna pretensión, entonces es letrado
        if(!listaPretensiones.isEmpty()){
            for(Case pretension : listaPretensiones){
                if(pretension.OwnerId == idUser){
                    esLetrado = true;
                }
            }
        }

        //Si el usuario es owner de la reclamación, entonces es gestor
        if(ownerCaso == idUser){
            esGestor = true;
        }

        //Buscar si el usuario pertence a COPS o AJ
        List<CC_Grupo_Colaborador_Contact__c> colabContact= new List<CC_Grupo_Colaborador_Contact__c>();
        colabContact = [SELECT id FROM CC_Grupo_Colaborador_Contact__c 
                        WHERE CC_Usuario__c=:idUser AND CC_Grupo_Colaborador__r.RecordTypeId = :RECTYGRUPOTAREAS
                        AND (CC_Grupo_Colaborador__r.SAC_DeveloperName__c = 'COPS' OR CC_Grupo_Colaborador__r.SAC_DeveloperName__c = 'AJ')];

        if(!colabContact.isEmpty()){esCOPSAJ = true;}       

        //Se construye el wrapper que se va a devolver, con todos los escalados necesarios para el componente
        GestorLetradoWrapper wrapperGestorLetrado = new GestorLetradoWrapper(esLetrado, esGestor, esCOPSAJ);
        return wrapperGestorLetrado;
    }


    @AuraEnabled
    public static List<CC_Caracteristica_Detalle__c> comprobarCaractRepresentante(String documento, String despacho){

        List<CC_Caracteristica_Detalle__c> caracteristicasRepresentante = [SELECT Id, SAC_Identificador__c, CC_Caracteristica__r.Name, CC_Caracteristica__r.CC_Descripcion__c FROM CC_Caracteristica_Detalle__c WHERE CC_Caracteristica__r.RecordTypeId = :RTREPRESENTANTECARACTERISTICA AND (SAC_Identificador__c = :documento OR SAC_Identificador__c = :despacho) ORDER BY SAC_Identificador__c DESC];

        if(!caracteristicasRepresentante.isEmpty()){
            
            Set<String> caracteristicaIds = new Set<String>();
            List<CC_Caracteristica_Detalle__c> asignacionesUnicas = new List<CC_Caracteristica_Detalle__c>();

            for (CC_Caracteristica_Detalle__c asignacion : caracteristicasRepresentante) {
                if (!caracteristicaIds.contains(asignacion.CC_Caracteristica__c)) {
                    caracteristicaIds.add(asignacion.CC_Caracteristica__c);
                    asignacionesUnicas.add(asignacion);
                }
            }

            return asignacionesUnicas;
        }else{
            return null;
        }
        
    }

}