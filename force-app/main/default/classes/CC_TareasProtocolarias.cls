public with sharing class CC_TareasProtocolarias {

    public static Integer cantidadTareas = 0;

    private static Set<String> objetos = new Set<String>{'Case', 'SAC_MaestroTemas__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
    // private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = getRecordTypesObject(objetos);

    // MGT: US1203387: Checklist tareas protocolarias en los casos
    private static final Id RECTYPE_CC = mapRTsObjects.get('Case').get('CC_Cliente').getRecordTypeId();

    private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    public static final Id RECTYPETAREAS = mapRTsObjects.get('SAC_MaestroTemas__c').get('CC_ChecklistTareasProtocolarias').getRecordTypeId();

    public static final Id RECTYPECHECKLIST = mapRTsObjects.get('SAC_MaestroTemas__c').get('CC_Checklist').getRecordTypeId();

    /***********************************************************************************************************
    * Proposito: Recupera los campos de control de alta, así como los checkeados o los permisos de edicción del usuario actual.
    ***********************************************************************************************************/
    @AuraEnabled
    public static Map<String, List<WrapperControlAltas>> cargarDatosControlAltas(String idCaso) {

        Map<String, List<WrapperControlAltas>> wrappersMap = new Map<String, List<WrapperControlAltas>>();
        Set<String> controlesCaso = new Set<String>();
        Boolean desactivarEdiccion = false;
        Boolean cargarDatos = false;
        String estadoCaso;

        // Recuperar el motivo del caso
        List<Case> lstCaso = [SELECT Id, CC_MCC_Motivo__c, CC_Motivo__c, CC_Rechazar_Reabrir_Caso__c, OwnerId, Status, RecordTypeId 
            FROM Case 
            WHERE Id = :idCaso 
            LIMIT 1];
        Case caso = lstCaso[0];
        String motivoCaso = caso.CC_MCC_Motivo__c;

        // Juntion Object
        Set<Id> maestroTemaIds = new Set<Id>();
        for (CC_TareaMotivo__c tareaMotivo : [
            SELECT CC_Checklist__c 
            FROM CC_TareaMotivo__c 
            WHERE CC_MCC_Motivo__c = :motivoCaso 
            AND CC_Tarea_Motivo_Activa__c = true
        ]) {
            maestroTemaIds.add(tareaMotivo.CC_Checklist__c);
        }

        // Maestro Temas Checklist
        Set<Id> maestroTemasChecklist = new Set<Id>();
        List<SAC_MaestroTemas__c> listControles = new List<SAC_MaestroTemas__c>();
        for (SAC_MaestroTemas__c checklist : [
            SELECT Id, 
                (SELECT Id, Name, SAC_Descripcion__c, SAC_Seccion__c, SAC_Activo__c, CC_Maestro_Temas__c 
                FROM Maestro_Temas__r 
                WHERE RecordTypeId = :RECTYPETAREAS AND SAC_Seccion__c <> null ORDER BY SAC_Seccion__c, Name) 
            FROM SAC_MaestroTemas__c 
            WHERE Id 
            IN :maestroTemaIds
            AND RecordTypeId = :RECTYPECHECKLIST 
        ]) {
            maestroTemasChecklist.add(checklist.Id);
            listControles.addAll(checklist.Maestro_Temas__r);
        }
                
        if(!listControles.isEmpty()){

            Integer limite = 1;
            limite = listControles.size();
            Boolean marcasCierreCaso = false;
            List<SAC_Marca_Case__c> listMarcasCaso = [SELECT Id, SAC_Marca__r.Name, SAC_Case__r.Status, SAC_Case__r.OwnerId, CC_TareaCompletada__c, CC_No_Aplica__c,
                                                        CC_CantidadTareasGuardadas__c, SAC_Marca__r.SAC_Descripcion__c, 
                                                        SAC_Marca__r.SAC_Seccion__c, CC_Motivo_del_Caso__c, CC_Caso_Cerrado__c, CC_Razon_No_Aplica__c
                                                        FROM SAC_Marca_Case__c 
                                                        WHERE SAC_Marca__r.RecordTypeId = :RECTYPETAREAS AND SAC_Case__c = :idCaso AND CC_Motivo_del_Caso__c = :caso.CC_Motivo__c
                                                        ORDER BY CreatedDate desc];
                
            Map<String, SAC_Marca_Case__c> mapMarcasCaso = new Map<String, SAC_Marca_Case__c>();                                           

            if(!listMarcasCaso.isEmpty()){
                estadoCaso = listMarcasCaso[0].SAC_Case__r.Status;
                cargarDatos = true;

                for(SAC_Marca_Case__c marcaCaso : listMarcasCaso){
                    if(!mapMarcasCaso.containsKey(marcaCaso.SAC_Marca__r.Name)){
                        mapMarcasCaso.put(marcaCaso.SAC_Marca__r.Name, marcaCaso);
                    }
                    if(!controlesCaso.contains(marcaCaso.SAC_Marca__r.Name)){
                        controlesCaso.add(marcaCaso.SAC_Marca__r.Name);
                    }
                    if(!marcasCierreCaso && marcaCaso.CC_Caso_Cerrado__c){
                        marcasCierreCaso = true;
                    }
                }

                desactivarEdiccion = comprobarPermisosEdicion(listMarcasCaso[0].SAC_Case__r.Status, listMarcasCaso[0].SAC_Case__r.OwnerId, (caso.CC_Rechazar_Reabrir_Caso__c && marcasCierreCaso));

            }else{
                List<Case> listCaso = new List<Case>();
                listCaso.add(caso);
                if(!listCaso.isEmpty()){
                    estadoCaso = listCaso[0].Status;
                    cargarDatos = true;

                    if (listCaso[0].RecordTypeId == RECTYPERECLAMACION) {
                        desactivarEdiccion = comprobarPermisosEdicion(listCaso[0].Status, listCaso[0].OwnerId, (caso.CC_Rechazar_Reabrir_Caso__c && marcasCierreCaso));
                    } else if (listCaso[0].RecordTypeId == RECTYPE_CC) {
                        desactivarEdiccion = comprobarPermisosEdicion(listCaso[0].Status, listCaso[0].OwnerId, (caso.CC_Rechazar_Reabrir_Caso__c && marcasCierreCaso));
                    }
                }
            }

            if(cargarDatos){      
                if(estadoCaso == 'Cerrado' || (caso.CC_Rechazar_Reabrir_Caso__c && marcasCierreCaso)){

                    List<SAC_Marca_Case__c> nuevoRegistro = listMarcasCaso;
                    if (!nuevoRegistro.isEmpty()) {
                        cantidadTareas = (Integer)nuevoRegistro[0].CC_CantidadTareasGuardadas__c;
                    } else {
                        cantidadTareas = 0;
                    }

                    if(cantidadTareas != 0){
                            

                        //GLM update
                        for(SAC_MaestroTemas__c control : listControles) {
                            Boolean seleccionado = false;
                            Boolean noAplica = false;
                            String razonNoAplica = '';
                            SAC_Marca_Case__c marcaCaso = mapMarcasCaso.get(control.Name);
                            if (marcaCaso != null) {
                                seleccionado = marcaCaso.CC_TareaCompletada__c;
                                noAplica = marcaCaso.CC_No_Aplica__c;
                                razonNoAplica = marcaCaso.CC_Razon_No_Aplica__c;
                            }

                            if(control.SAC_Activo__c || controlesCaso.contains(control.Name)){

                            WrapperControlAltas valor = new WrapperControlAltas(control.Id, control.Name, control.SAC_Descripcion__c, desactivarEdiccion, seleccionado, noAplica, caso.CC_Motivo__c, razonNoAplica);
                                
                                if(!wrappersMap.containsKey(control.SAC_Seccion__c)){
                                    wrappersMap.put(control.SAC_Seccion__c, new List<WrapperControlAltas>{ valor });
                                }else{
                                    wrappersMap.get(control.SAC_Seccion__c).add(valor);
                                }
                            }
                        }

                    }
                        
                }else {
                    for(SAC_MaestroTemas__c control : listControles) {

                        Boolean seleccionado = false;
                        Boolean noAplica = false;
                        String razonNoAplica = '';
                        SAC_Marca_Case__c marcaCaso = mapMarcasCaso.get(control.Name);
                        if (marcaCaso != null) {
                            seleccionado = marcaCaso.CC_TareaCompletada__c;
                            noAplica = marcaCaso.CC_No_Aplica__c;
                            razonNoAplica = marcaCaso.CC_Razon_No_Aplica__c;
                        }

                        if((estadoCaso == 'SAC_001' || estadoCaso == 'SAC_006' || estadoCaso == 'Activo') && (control.SAC_Activo__c || controlesCaso.contains(control.Name))){

                            WrapperControlAltas valor = new WrapperControlAltas(control.Id, control.Name, control.SAC_Descripcion__c, desactivarEdiccion, seleccionado, noAplica, caso.CC_Motivo__c, razonNoAplica);
                            
                            if(!wrappersMap.containsKey(control.SAC_Seccion__c)){
                                wrappersMap.put(control.SAC_Seccion__c, new List<WrapperControlAltas>{ valor });
                            }else{
                                wrappersMap.get(control.SAC_Seccion__c).add(valor);
                            }
                        }else if(estadoCaso != 'SAC_001' && estadoCaso != 'SAC_006' && estadoCaso != 'Activo' && controlesCaso.contains(control.Name)){
                            WrapperControlAltas valor = new WrapperControlAltas(control.Id, control.Name, control.SAC_Descripcion__c, desactivarEdiccion, true, false, caso.CC_Motivo__c, '');

                            if(!wrappersMap.containsKey(control.SAC_Seccion__c)){
                                wrappersMap.put(control.SAC_Seccion__c, new List<WrapperControlAltas>{valor} );
                            }else{
                                wrappersMap.get(control.SAC_Seccion__c).add(valor);
                            }
                        }
                    }
                }
            }
        }
        return wrappersMap;     
    }

    /***********************************************************************************************************
    * Proposito: Almacena en bbdd los cambios que realiza el usuario en los campos del control de altas.
    ***********************************************************************************************************/
    @AuraEnabled
    public static void guardarControlAlta(String idCaso, String motivoCaso, List<String> listaControles, List<Boolean> listaEstados, List<Boolean> listaNoAplica, List<String> listaRazonNoAplica){
        // Extraemos los registros existentes para este Caso y solo nos quedamos con el ultimo de cada tipo para ver el estado actual y revisar si ha cambiado.
        List<SAC_Marca_Case__c> lstMarcaCaseExistentes = [SELECT Id, SAC_Marca__c, CC_TareaCompletada__c, CC_No_Aplica__c, CC_CantidadTareasGuardadas__c, CC_Motivo_del_Caso__c
                                                            FROM SAC_Marca_Case__c 
                                                            WHERE SAC_Case__c = :idCaso AND SAC_Marca__r.RecordTypeId = :RECTYPETAREAS AND CC_Motivo_del_Caso__c = :motivoCaso
                                                            ORDER BY CreatedDate DESC];
        Map<String, SAC_Marca_Case__c> mapMarcaCaseExistentes = new Map<String, SAC_Marca_Case__c>();
        for(SAC_Marca_Case__c marcaCase : lstMarcaCaseExistentes){
            if(!mapMarcaCaseExistentes.containsKey(marcaCase.SAC_Marca__c)){
                // Solo guardamos el primer registro de cada tipo
                mapMarcaCaseExistentes.put(marcaCase.SAC_Marca__c, marcaCase);
            }
        }

        // Recorremos el estado en el que se va a guardar y revisamos si se han marcado/desmarcado
        List<SAC_Marca_Case__c> controlAltaInsert = new List<SAC_Marca_Case__c>();
        for(Integer i = 0; i < listaControles.size(); i++){
            // Si existe el registro y se ha marcado/desmarcado, creamos uno nuevo
            if(mapMarcaCaseExistentes.containsKey(listaControles[i]) && 
            (listaEstados[i] != mapMarcaCaseExistentes.get(listaControles[i]).CC_TareaCompletada__c || 
                listaNoAplica[i] != mapMarcaCaseExistentes.get(listaControles[i]).CC_No_Aplica__c)){
                SAC_Marca_Case__c nuevoRegistro = new SAC_Marca_Case__c(SAC_Case__c = idCaso, SAC_Marca__c = listaControles[i]);
                nuevoRegistro.CC_TareaCompletada__c = listaEstados[i];
                nuevoRegistro.CC_No_Aplica__c = listaNoAplica[i];
                nuevoRegistro.CC_Razon_No_Aplica__c = listaRazonNoAplica[i];
                nuevoRegistro.CC_Motivo_del_Caso__c = motivoCaso;
                nuevoRegistro.CC_CantidadTareasGuardadas__c = listaControles.size(); // Guardar el tamaño de la lista
                controlAltaInsert.add(nuevoRegistro);
            }else if(!mapMarcaCaseExistentes.containsKey(listaControles[i]) && (listaEstados[i] == true || listaNoAplica[i] == true)){
                // Si no existe el registro y se ha marcado, lo creamos
                SAC_Marca_Case__c nuevoRegistro = new SAC_Marca_Case__c(SAC_Case__c = idCaso, SAC_Marca__c = listaControles[i]);
                nuevoRegistro.CC_TareaCompletada__c = listaEstados[i];
                nuevoRegistro.CC_No_Aplica__c = listaNoAplica[i];
                nuevoRegistro.CC_Razon_No_Aplica__c = listaRazonNoAplica[i];
                nuevoRegistro.CC_Motivo_del_Caso__c = motivoCaso;
                nuevoRegistro.CC_CantidadTareasGuardadas__c = listaControles.size(); // Guardar el tamaño de la lista
                controlAltaInsert.add(nuevoRegistro);
            }
        }
        if(!controlAltaInsert.isEmpty()){
            SAC_DatabaseDML.insertListDML(controlAltaInsert, false);

            Case caso = [SELECT Id, CBK_Case_Extension_Id__c, CBK_Case_Extension_Id__r.CC_CantidadDeChecklistsMostradas__c 
            FROM Case 
            WHERE Id = :idCaso];

            if(caso.CBK_Case_Extension_Id__r != null){
                caso.CBK_Case_Extension_Id__r.CC_CantidadDeChecklistsMostradas__c = listaControles.size();
                update caso.CBK_Case_Extension_Id__r;
            } else {
                CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c(
                    Case_Id__c = caso.Id,
                    CC_CantidadDeChecklistsMostradas__c = listaControles.size()
                );
                insert caseExtension;
                caso.CBK_Case_Extension_Id__c = caseExtension.Id;
                update caso;
            }
        }

        // Verificar si todas las tareas están completadas para poder ocultar el aviso de tareas

        Case caso = [SELECT Id, OwnerId, Origin, CC_MCC_Tematica__c, CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__c, CC_Motivo_Derivacion__c, CBK_Case_Extension_Id__r.CC_Ocultar_Aviso_Tareas__c,
                    CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__c, CC_Motivo__c, CC_MCC_Motivo__r.Name, 
                    CC_MCC_Motivo__r.CC_Ambito_tareas_Imagin__c, CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c, 
                    Account.AV_IndicadoresClientes__c, RecordType.DeveloperName, CC_MCC_Causa__c, CC_Telefono_Contacto__c,
                    CC_MCC_Solucion__c, AccountId, ContactId, CC_Oportunidad_creada__c,Account.RecordType.DeveloperName, Account.AV_Segmento__c, Account.AV_NumPerso__c, Account.CC_NumPerso__c, Account.CC_Numero_Documento__c,
                    CC_Representante__r.CC_Representante__r.AV_IndicadoresClientes__c,  CC_Representante__r.CC_Representante__r.CC_NumPerso__c, CC_Representante__r.CC_Representante__r.CC_Numero_Documento__c, CC_Representante__r.CC_Representante__r.AV_NumPerso__c, Contact.RecordType.DeveloperName, Contact.CIBE_NumPerso__c, Contact.AV_NumPerso__c, Contact.CC_NumPerso__c, Contact.CC_Numero_Documento__c, CC_OTP_Nivel__c, CC_Status_Autorizacion__c 
                    FROM Case WHERE Id = :idCaso];

        Id recordId = caso.Id;
        Integer cantidadTareas = 0;
        String mensajeTareas = CC_Settings__c.getValues('CC_MensajeTareasProtocolarias')?.CC_Configuracion_1__c;
        
        // Verificar si hay tareas cargadas en la lista listControles

        String motivoCaso2 = caso.CC_MCC_Motivo__c;

        // Juntion Object
        Set<Id> maestroTemaIds = new Set<Id>();
        for (CC_TareaMotivo__c tareaMotivo : [
            SELECT CC_Checklist__c 
            FROM CC_TareaMotivo__c 
            WHERE CC_MCC_Motivo__c = :motivoCaso2 
            AND CC_Tarea_Motivo_Activa__c = true
        ]) {
            maestroTemaIds.add(tareaMotivo.CC_Checklist__c);
        }

        // Maestro Temas Checklist
        Set<Id> maestroTemasChecklist = new Set<Id>();
        for (SAC_MaestroTemas__c checklist : [
            SELECT Id 
            FROM SAC_MaestroTemas__c 
            WHERE Id 
            IN :maestroTemaIds
            AND RecordTypeId = :CC_TareasProtocolarias.RECTYPECHECKLIST 
        ]) {
            maestroTemasChecklist.add(checklist.Id);
        }

        List<SAC_MaestroTemas__c> listControles = [
            SELECT Id, Name, SAC_Descripcion__c, SAC_Seccion__c, SAC_Activo__c, CC_Maestro_Temas__c
            FROM SAC_MaestroTemas__c 
            WHERE CC_Maestro_Temas__c IN :maestroTemasChecklist 
            AND RecordTypeId = :CC_TareasProtocolarias.RECTYPETAREAS 
            AND SAC_Seccion__c <> null 
            ORDER BY SAC_Seccion__c, Name
        ];

        List<SAC_Marca_Case__c> tareasCompletadas = [
            SELECT Id, CC_TareaCompletada__c, CC_No_Aplica__c, SAC_Marca__r.Name 
            FROM SAC_Marca_Case__c 
            WHERE SAC_Case__c = :recordId 
            AND SAC_Marca__r.RecordTypeId = :CC_TareasProtocolarias.RECTYPETAREAS
            AND CC_Motivo_del_Caso__c = :caso.CC_Motivo__c
        ];

        Map<String, SAC_Marca_Case__c> mapaTareasCompletadas = new Map<String, SAC_Marca_Case__c>();
        for (SAC_Marca_Case__c tarea : tareasCompletadas) {
            mapaTareasCompletadas.put(tarea.SAC_Marca__r.Name, tarea);
        }

        Boolean todasTareasCompletadas = true;
        for (SAC_MaestroTemas__c control : listControles) {
            SAC_Marca_Case__c marcaCaso = mapaTareasCompletadas.get(control.Name);
            if (marcaCaso == null || (!marcaCaso.CC_TareaCompletada__c && !marcaCaso.CC_No_Aplica__c)) {
                todasTareasCompletadas = false;
                break;
            }
        }

        if (todasTareasCompletadas) {
            CBK_Case_Extension__c caseExtension = caso.CBK_Case_Extension_Id__r;
            if (caseExtension == null) {
                caseExtension = [SELECT Id, CC_Ocultar_Aviso_Tareas__c FROM CBK_Case_Extension__c WHERE Id = :caso.CBK_Case_Extension_Id__c];
            }
            caseExtension.CC_Ocultar_Aviso_Tareas__c = true;
            update caseExtension;
        } else {
            CBK_Case_Extension__c caseExtension = caso.CBK_Case_Extension_Id__r;
            if (caseExtension == null) {
                caseExtension = [SELECT Id, CC_Ocultar_Aviso_Tareas__c FROM CBK_Case_Extension__c WHERE Id = :caso.CBK_Case_Extension_Id__c];
            }
            caseExtension.CC_Ocultar_Aviso_Tareas__c = false;
            update caseExtension;
        }
    }

    /***********************************************************************************************************
    * Proposito: Comprueba los permisos de edicción de los campos de control de altas
    ***********************************************************************************************************/
    public static Boolean comprobarPermisosEdicion(String estadoCaso, String ownerCaso, Boolean rechazarReabrirCaso){
        Id idUsuarioAct = UserInfo.getUserId();
        if(estadoCaso == 'Activo' && ownerCaso == idUsuarioAct && !rechazarReabrirCaso){
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
        @AuraEnabled public boolean noAplicaControl {get;set;}
        @AuraEnabled public String nombreChecklist {get;set;}
        @AuraEnabled public String razonNoAplica {get;set;}
        
        public WrapperControlAltas(String idActual, String nameActual, String descripcionActual, boolean desactivarEditarActual, boolean selecionadoActual, boolean noAplicaActual, String nombreChecklistActual, String razonNoAplicaActual) {
            this.idControl = idActual;
            this.nameControl = nameActual;
            this.descControl = descripcionActual;
            this.desactivarControl = desactivarEditarActual;
            this.selecionadoControl = selecionadoActual;
            this.noAplicaControl = noAplicaActual;
            this.nombreChecklist = nombreChecklistActual;
            this.razonNoAplica = razonNoAplicaActual;
        }
    }
}