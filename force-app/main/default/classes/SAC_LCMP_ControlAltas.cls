public with sharing class SAC_LCMP_ControlAltas {

    private static Set<String> objetos = new Set<String>{'Case', 'SAC_MaestroTemas__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    private static final Id RECTYPECONTROLALTAS = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_ControlAltas').getRecordTypeId();


    /***********************************************************************************************************
    * Proposito: Recupera los campos de control de alta, así como los checkeados o los permisos de edicción del usuario actual.
    *
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US1100463     Raúl Santos     03/01/25        Creación
    ***********************************************************************************************************/
    @AuraEnabled
    public static Map<String, List<WrapperControlAltas>> cargarDatosControlAltas(String idCaso) {

        Map<String, List<WrapperControlAltas>> wrappersMap = new Map<String, List<WrapperControlAltas>>();
        Set<String> controlesCaso = new Set<String>();
        Boolean desactivarEdiccion = false;
        Boolean cargarDatos = false;
        String estadoCaso;

        List<SAC_MaestroTemas__c> listControles = [SELECT Id, Name, SAC_Descripcion__c, SAC_Seccion__c, SAC_Activo__c FROM SAC_MaestroTemas__c WHERE RecordTypeId = :RECTYPECONTROLALTAS AND SAC_Seccion__c <> null ORDER BY SAC_Seccion__c, Name];
       
        if(!listControles.isEmpty()){

            List<SAC_Marca_Case__c> listMarcasCaso = [SELECT Id, SAC_Marca__r.Name, SAC_Case__r.Status, SAC_Case__r.OwnerId FROM SAC_Marca_Case__c WHERE SAC_Marca__r.RecordTypeId = : RECTYPECONTROLALTAS AND SAC_Case__c = :idCaso];
            if(!listMarcasCaso.isEmpty()){
                estadoCaso = listMarcasCaso[0].SAC_Case__r.Status;
                cargarDatos = true;

                for(SAC_Marca_Case__c marcaCaso : listMarcasCaso){
                    controlesCaso.add(marcaCaso.SAC_Marca__r.Name);
                }

                desactivarEdiccion = comprobarPermisosEdicion(listMarcasCaso[0].SAC_Case__r.Status, listMarcasCaso[0].SAC_Case__r.OwnerId);

            }else{
                List<Case> listCaso = [SELECT Id, OwnerId, Status FROM Case WHERE RecordTypeId = :RECTYPERECLAMACION AND Id = :idCaso LIMIT 1];

                if(!listCaso.isEmpty()){
                    estadoCaso = listCaso[0].Status;
                    cargarDatos = true;

                    desactivarEdiccion = comprobarPermisosEdicion(listCaso[0].Status, listCaso[0].OwnerId);
                }
            }

            if(cargarDatos){
                for(SAC_MaestroTemas__c control : listControles) {

                    if((estadoCaso == 'SAC_001' || estadoCaso == 'SAC_006') && (control.SAC_Activo__c || controlesCaso.contains(control.Name))){

                        WrapperControlAltas valor = new WrapperControlAltas(control.Id, control.Name, control.SAC_Descripcion__c, desactivarEdiccion, false);
                    
                        if(controlesCaso.contains(control.Name)){
                            // Si se encuentra una coincidencia, cambia el valor de Selecionado a true
                            valor.selecionadoControl = true;
                        }

                        if(!wrappersMap.containsKey(control.SAC_Seccion__c)){
                            wrappersMap.put(control.SAC_Seccion__c, new List<WrapperControlAltas>{valor} );
                        }else{
                            wrappersMap.get(control.SAC_Seccion__c).add(valor);
                        }
                    }else if(estadoCaso != 'SAC_001' && estadoCaso != 'SAC_006' && controlesCaso.contains(control.Name)){
                        WrapperControlAltas valor = new WrapperControlAltas(control.Id, control.Name, control.SAC_Descripcion__c, desactivarEdiccion, true);

                        if(!wrappersMap.containsKey(control.SAC_Seccion__c)){
                            wrappersMap.put(control.SAC_Seccion__c, new List<WrapperControlAltas>{valor} );
                        }else{
                            wrappersMap.get(control.SAC_Seccion__c).add(valor);
                        }
                    }
                }
            }
        }

        return wrappersMap;     
    }

    /***********************************************************************************************************
    * Proposito: Almacena en bbdd los cambios que realiza el usuario en los campos del control de altas.
    *
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US1100463     Raúl Santos     03/01/25        Creación
    ***********************************************************************************************************/
    @AuraEnabled
    public static void guardarControlAlta(String idCaso, List<String> listaControles){

        Set<String> controlesCaso = new Set<String>();
        List<SAC_Marca_Case__c> controlAltaInsert = new List<SAC_Marca_Case__c>();
        List<SAC_Marca_Case__c> controlAltaDelete = new List<SAC_Marca_Case__c>();


        List<SAC_Marca_Case__c> listMarcasCaso = [SELECT Id, SAC_Marca__c, SAC_Marca__r.Name FROM SAC_Marca_Case__c WHERE SAC_Marca__r.RecordTypeId = : RECTYPECONTROLALTAS AND SAC_Case__c = :idCaso];
        if(!listMarcasCaso.isEmpty()){
            for(SAC_Marca_Case__c marcaCaso : listMarcasCaso){
                controlesCaso.add(marcaCaso.SAC_Marca__c);

                if(!listaControles.contains(marcaCaso.SAC_Marca__c)){
                    controlAltaDelete.add(marcaCaso);
                }
            }
        }

        if(!listaControles.isEmpty()){
            for(String control : listaControles){
                if(!controlesCaso.contains(control)){
                    controlAltaInsert.add(new SAC_Marca_Case__c(SAC_Case__c = idCaso, SAC_Marca__c = control));
                }
            }
        }

        if(!controlAltaInsert.isEmpty()){
            SAC_DatabaseDML.insertListDML(controlAltaInsert, false);
        }

        if(!controlAltaDelete.isEmpty()){
            SAC_DatabaseDML.deleteListDML(controlAltaDelete, false);
        }
    }

    /***********************************************************************************************************
    * Proposito: Comprueba los permisos de edicción de los campos de control de altas
    *
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US1100463     Raúl Santos     03/01/25        Creación
    ***********************************************************************************************************/
    public static Boolean comprobarPermisosEdicion(String estadoCaso, String ownerCaso){

        Id idUsuarioAct = UserInfo.getUserId();
                    
        if(estadoCaso == 'SAC_001' && ownerCaso == idUsuarioAct){
            return false;
        }else{
            return true;
        }
    }


    public class WrapperControlAltas {
        @AuraEnabled public String idControl {get;set;}
		@AuraEnabled public String nameControl {get;set;}
        @AuraEnabled public String descControl {get;set;}
		@AuraEnabled public boolean desactivarControl {get;set;}
		@AuraEnabled public boolean selecionadoControl {get;set;}
        
        public WrapperControlAltas(String idActual, String nameActual, String descripcionActual, boolean desactivarEditarActual, boolean selecionadoActual) {
            this.idControl = idActual;
            this.nameControl = nameActual;
            this.descControl = descripcionActual;
            this.desactivarControl = desactivarEditarActual;
            this.selecionadoControl = selecionadoActual;
        }
	}
}