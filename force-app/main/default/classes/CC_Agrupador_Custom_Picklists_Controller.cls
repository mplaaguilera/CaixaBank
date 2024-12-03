public with sharing class CC_Agrupador_Custom_Picklists_Controller {

    public class PickListWrapper {
        //Clase para almacenar valores de una picklist
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String value {get; set;}
        @AuraEnabled
        public String rt {get; set;}

        public PickListWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    public class WrapperAgrupador {
        //Clase para almacenar valores de una picklist
        @AuraEnabled
        public CC_Agrupador__c agrupador {get; set;}
        @AuraEnabled
        public String rt {get; set;}
        

        public WrapperAgrupador(CC_Agrupador__c agrupador) {
            this.agrupador = agrupador;
            this.rt = 'CC_GrupoMaximo';
        }
    }
    

    @AuraEnabled(cacheable=true)
    public static List<PickListWrapper> getPicklistGruposMaximo() {
        List<PickListWrapper> options = new List<PickListWrapper>();

        //La primera opción será "--Ninguno--" (servirá para vaciar el valor del campo)
        PickListWrapper opcionNinguno = new PickListWrapper('--Ninguno--', '--Ninguno--');
        options.add(opcionNinguno);

        //El resto de valores son los "grupos Maximo" que el usuario logado tiene vinculados
        Id userId = UserInfo.getUserId();
        String sRecordType = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_GrupoMaximo').getRecordTypeId();

        List<CC_Grupo_Colaborador_Contact__c> listaGruposMaximo = [SELECT CC_Grupo_Colaborador__c, CC_Grupo_Colaborador__r.Name
                                                                    FROM CC_Grupo_Colaborador_Contact__c
                                                                    WHERE CC_Usuario__c = :userId
                                                                    AND CC_Grupo_Colaborador__r.RecordTypeId = :SRecordType];

        for (CC_Grupo_Colaborador_Contact__c grupoColaboradorMaxUser : listaGruposMaximo) {
            PickListWrapper wrap = new PickListWrapper(grupoColaboradorMaxUser.CC_Grupo_Colaborador__r.Name, grupoColaboradorMaxUser.CC_Grupo_Colaborador__c);
            options.add(wrap);
        }
        return options;
    }

    @AuraEnabled(cacheable=true)
    public static List<PickListWrapper> getPicklistClasificacionesMaximo(Id recordId) {
        List<PickListWrapper> options = new List<PickListWrapper>();

        //La primera opción será "--Ninguna--" (servirá para vaciar el valor del campo)
        PickListWrapper opcionNinguno = new PickListWrapper('--Ninguna--', '--Ninguna--');
        options.add(opcionNinguno);

        CC_Agrupador__c agrupador = [SELECT CC_Causa__c FROM CC_Agrupador__c WHERE Id = :recordId];
        if (agrupador.CC_Causa__c != null) {
            for (CC_MCC__c clasificacion : [SELECT CC_ClasifMaximo__c, CC_ClasifMaximo__r.CC_Path__c FROM CC_MCC__c
                WHERE Id = :agrupador.CC_Causa__c AND CC_ClasifMaximo__c != NULL]) {
                PickListWrapper wrap = new PickListWrapper(clasificacion.CC_ClasifMaximo__r.CC_Path__c, clasificacion.CC_ClasifMaximo__c);
                options.add(wrap);
            }
        }
        return options;
    }

    @AuraEnabled(cacheable=true)
    public static List<PickListWrapper> getPicklistOpcionCallCenter() {
        List<PickListWrapper> options = new List<PickListWrapper>();

        //La primera opción será "--Ninguno--" (servirá para vaciar el valor del campo)
        PickListWrapper opcionNinguno = new PickListWrapper('--Ninguno--', '--Ninguno--');
        options.add(opcionNinguno);

        //El resto de valores son las "opciones call center" definidas en la lista de valores
        List<CC_Lista_Valores__c > listaOpcionesCallCenter = [SELECT CC_Valor__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'Maximo - Opciones Call Center'];
        for (CC_Lista_Valores__c opcionCallCenter : listaOpcionesCallCenter) {
            PickListWrapper wrap = new PickListWrapper(opcionCallCenter.CC_Valor__c, opcionCallCenter.Id);
            options.add(wrap);
        }
        return options;
    }

    @AuraEnabled
    public static void actualizaAgrupador(Id recordId, String clasificacionMaximo, String grupoMaximo, String opcionCallCenter, Boolean esBuscador) {
        CC_Agrupador__c agrupador = new CC_Agrupador__c(Id = recordId);
        CC_Agrupador__c agrupadorAnterior = getValoresIniciales(recordId).agrupador;
        if(esBuscador){
            Id rtMax = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_GrupoMaximo').getRecordTypeId();
            CC_Grupo_Colaborador__c grupoColMax = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE RecordTypeId =: rtMax AND Name =: grupoMaximo LIMIT 1];
            CC_Clasificacion_Maximo__c clasMax = [SELECT Id FROM CC_Clasificacion_Maximo__c WHERE Name =: clasificacionMaximo LIMIT 1];

            agrupador.CC_GrupoMaximo__c = (grupoMaximo == '--Ninguno--' ? null : grupoColMax.Id);
            agrupador.CC_Opcion_Call_Center__c = (opcionCallCenter == '--Ninguno--' ? null : opcionCallCenter);
            agrupador.CC_Clasificacion_Maximo__c = (clasificacionMaximo == '--Ninguna--' ? null : clasMax.Id);
        }
        
        else{
            agrupador.CC_GrupoMaximo__c = (grupoMaximo == '--Ninguno--' ? null : grupoMaximo);
            agrupador.CC_Opcion_Call_Center__c = (opcionCallCenter == '--Ninguno--' ? null : opcionCallCenter);
            agrupador.CC_Clasificacion_Maximo__c = (clasificacionMaximo == '--Ninguna--' ? null : clasificacionMaximo);
        }
        
        
        if (grupoMaximo == null){
            agrupador.CC_GrupoMaximo__c = agrupadorAnterior.CC_GrupoMaximo__c;
        }
        
        if (opcionCallCenter == null){
            agrupador.CC_Opcion_Call_Center__c = agrupadorAnterior.CC_Opcion_Call_Center__c;
        }
       
        if (clasificacionMaximo == null){
            agrupador.CC_Clasificacion_Maximo__c = agrupadorAnterior.CC_Clasificacion_Maximo__c;
        }
        system.debug('antes upd ' + agrupador);
        update agrupador;
        system.debug('despues upd ' + agrupador);

        
    }

    @AuraEnabled
    public static WrapperAgrupador getValoresIniciales(Id recordId) {
        CC_Agrupador__c agr = [SELECT CC_GrupoMaximo__c, CC_GrupoMaximo__r.Name, CC_Opcion_Call_Center__c, CC_Clasificacion_Maximo__c, CC_Clasificacion_Maximo__r.Name, CC_Clasificacion_Maximo__r.CC_Path__c
                    FROM CC_Agrupador__c WHERE Id = :recordId];

        WrapperAgrupador wrap = new WrapperAgrupador(agr);
        return wrap;
    }

    //Search
    @AuraEnabled(cacheable=true)
    public static List<SObJectResult> getResults(String objectName, String fieldName, String value, String propietario) {
        List<SObjectResult> sObjectResultList = new List<SObjectResult>();
        for (sObject so : Database.Query('SELECT ' + fieldName + ', ' + propietario + ' FROM ' + objectName + ' WHERE ' + fieldName + ' LIKE \'%' + value + '%\'')) {
            String fieldvalue = (String)so.get(fieldName);
            String fieldvaluePropietario = (String)so.get(propietario);
            sObjectResultList.add(new SObjectResult(fieldvalue, so.Id, fieldvaluePropietario));
        }
        return sObjectResultList;
    }
    @AuraEnabled(cacheable=true)
    public static List<CC_Clasificacion_Maximo__c> recuperarClasificacion(String cadenaBusqueda){

            return [SELECT Id, CC_Path__c, Name FROM CC_Clasificacion_Maximo__c  WHERE  CC_Activa__c = true AND Name LIKE :('%' + cadenaBusqueda + '%')];

    }


    @AuraEnabled(cacheable=true)
    public static List<CC_Grupo_Colaborador__c> recuperarGrupos(String cadenaBusqueda){
        String sRecordType = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_GrupoMaximo').getRecordTypeId();
        return [SELECT Id, Name, RecordTypeId, RecordType.DeveloperName FROM CC_Grupo_Colaborador__c  WHERE Name LIKE :('%' + cadenaBusqueda + '%') AND RecordTypeId = :SRecordType];
    }

    public class SObJectResult {
        @AuraEnabled    
        public String recName;

        @AuraEnabled
        public String recPropietario;

        @AuraEnabled
        public Id recId;

        public SObJectResult(String recNameTemp, Id recIdTemp, String recPropietarioTemp) {
            recName = recNameTemp;
            recId = recIdTemp;
            recPropietario = recPropietarioTemp;
        }
    }
}