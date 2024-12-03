public with sharing class GRR_Case_Operativa {

    @AuraEnabled(cacheable=true)
    public static Boolean perteneceServiciosCentrales() {
        return FeatureManagement.checkPermission('GRR_Servicios_Centrales');
    }

    //Comprobar si la validacion es necesario tras obtener el MCC final
    @AuraEnabled
    public static List<String> validarCamposCaso(Id recordId) {
        List<String> camposNoValidos = new List<String>();
        Case caso = [SELECT CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c,
                        Origin, CC_Canal_Procedencia__c, CC_Idioma__c, ContactId, CC_No_Identificado__c
                        FROM Case WHERE Id = :recordId WITH SECURITY_ENFORCED];
        if (caso.CC_MCC_Tematica__c == null) { camposNoValidos.add('Temática'); }
        if (caso.CC_MCC_ProdServ__c == null) { camposNoValidos.add('Producto/Servicio'); }
        if (caso.CC_MCC_Motivo__c == null) { camposNoValidos.add('Motivo'); }
        if (caso.Origin == null) { camposNoValidos.add('Canal de entrada'); }
        if (caso.CC_Canal_Procedencia__c == null) { camposNoValidos.add('Canal de procedencia'); }
        if (caso.CC_Idioma__c == null) {  camposNoValidos.add('Idioma'); }
        if (caso.ContactId == null && caso.CC_No_Identificado__c == false) {  camposNoValidos.add('Cuenta y contacto'); }

        //Si las claves foráneas a MCCs no son nulas, se mira además que los MCCs a los que apuntan estén activos
        if (caso.CC_MCC_Tematica__c != null && caso.CC_MCC_ProdServ__c != null && caso.CC_MCC_Motivo__c != null) {
            //Se preparan los Ids en una lista para poder la comprobación en una sola consulta
            List<Id> idsMCC = new List<Id>{caso.CC_MCC_Tematica__c, caso.CC_MCC_ProdServ__c, caso.CC_MCC_Motivo__c};
            for (CC_MCC__c mcc : [SELECT Name, CC_Activo__c FROM CC_MCC__c WHERE Id IN :idsMCC WITH SECURITY_ENFORCED]) {
                if (!mcc.CC_Activo__c) {
                    camposNoValidos.add('Clasificación ' + mcc.Name + ' inactiva');
                    break;
                }
            }
        }
        return camposNoValidos;
    }

    @AuraEnabled(cacheable=true)
    public static String getURCasoDestino(String idCasoDestino) {
        String resultado;
        List<Case> lstCasos = [SELECT Id, GRR_UR_Relacionada__c FROM Case WHERE Id = :idCasoDestino WITH SECURITY_ENFORCED LIMIT 1];
        if (!lstCasos.isEmpty()){
            resultado = lstCasos[0].GRR_UR_Relacionada__c;
        }
        return resultado;
    }

    @AuraEnabled(cacheable=true)
    public static List<CC_Grupo_Colaborador__c> buscarGruposColaboradores(String cadenaBusqueda) {
        return [SELECT Name FROM CC_Grupo_Colaborador__c WHERE
                Name LIKE :('%' + cadenaBusqueda + '%')
                AND ((OS_Negocio__c = 'CC' AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Grupo_Colaborador__c','CC_CentroCaixaBank')) 
                    OR (OS_Negocio__c = 'GRR' AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Grupo_Colaborador__c','CC_Grupo_Colaborador'))) 
                WITH SECURITY_ENFORCED LIMIT 20];
    }

    @AuraEnabled(cacheable=true)
    public static List<EmailTemplate> getPlantillasGRR() {
        //Se buscan todas las plantillas
        return [SELECT Name FROM EmailTemplate WHERE Folder.DeveloperName LIKE 'GRR_%' WITH SECURITY_ENFORCED LIMIT 30];
    }

    @AuraEnabled
    public static void prepararCaso(Id idCaso, Id idPlantilla, Boolean informarReferenciaCorreo, String operativa, Boolean cierreOperativa) {
        Case caso = [SELECT CC_Canal_Procedencia__c, CC_Buzon_Salida__c, OS_Cerrado_Operativa__c FROM Case WHERE Id = :idCaso WITH SECURITY_ENFORCED];
        caso.CC_MCC_Plantilla__c = idPlantilla;
        caso.CC_Ultima_Operativa_Correo__c = operativa;
        caso.OS_Cerrado_Operativa__c = (cierreOperativa)?true:false;

        //Comprobar los grupos a los que pertenece el usuario 
        List<GroupMember> groupMembers = [SELECT Id, Group.DeveloperName FROM GroupMember WHERE (UserOrGroupId = :UserInfo.getUserId() AND Group.Type='Regular' AND Group.DeveloperName LIKE 'GRR_Buzon%')];
        
        Set<String> groupNames = new Set<String>();
        for (GroupMember member : groupMembers) {
            groupNames.add(member.Group.DeveloperName);
        }

        if (!groupMembers.isEmpty()) {
            List<GRR_Correos_Buzones_Entrada__mdt> configBuzones = [SELECT GRR_Email_Destino__c, GRR_Cola_Procedencia__c, GRR_Canal_Procedencia__c 
                                                                    FROM GRR_Correos_Buzones_Entrada__mdt 
                                                                    WHERE GRR_Cola_Procedencia__c  IN :groupNames 
                                                                    WITH SECURITY_ENFORCED];

            if (configBuzones.size() > 1){
                // El usuario pertenece a varios grupos
                Map<String, GRR_Correos_Buzones_Entrada__mdt> configBuzonesMap = new Map<String, GRR_Correos_Buzones_Entrada__mdt>();

                for (GRR_Correos_Buzones_Entrada__mdt config : configBuzones) {
                    configBuzonesMap.put(config.GRR_Canal_Procedencia__c, config);
                }

                GRR_Correos_Buzones_Entrada__mdt configuracionAux = configBuzonesMap.get(caso.CC_Canal_Procedencia__c);

                if (configuracionAux != null) {
                    // El grupo coincide con el canal de procedencia
                    caso.CC_Buzon_Salida__c = configuracionAux.GRR_Email_Destino__c;
                } else {
                    // El grupo no coincide con el canal de procedencia. Se asocia al caso el primero.
                    caso.CC_Buzon_Salida__c = configBuzones[0].GRR_Email_Destino__c;
                }

            } else if (configBuzones.size() == 1) {
                // El usuario pertenece a un solo grupo
                caso.CC_Buzon_Salida__c = configBuzones[0].GRR_Email_Destino__c;
            }
        }

        if (informarReferenciaCorreo) {
            caso.CC_Referencia_Correo_Saliente__c = CC_EmailMessage.generarReferenciaCorreoSaliente(idCaso); //Se añade el id del caso a la semilla
        }
        if (!Schema.sObjectType.Case.fields.CC_Buzon_Salida__c.isUpdateable() || !Schema.sObjectType.Case.fields.CC_Referencia_Correo_Saliente__c.isUpdateable()) {
            return;
        }
        Database.update(caso);
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, String> destinatariosColaborador(Id idGrupoColaborador) {
        Map<String, String> idMapContacto = new Map<String, String>();
        for (CC_Grupo_Colaborador_Contact__c contactoGrupoColab : [SELECT CC_Para_CC__c, CC_Email__c FROM CC_Grupo_Colaborador_Contact__c
                                                                    WHERE CC_Grupo_Colaborador__c = :idGrupoColaborador AND (CC_Contacto__c != null OR CC_Usuario__c != null)
                                                                    WITH SECURITY_ENFORCED]) {
            idMapContacto.put(contactoGrupoColab.CC_Email__c, contactoGrupoColab.CC_Para_CC__c);
        }
        return idMapContacto;
    }

    /**
     * @description método para fusionar los correos, actividades, adjuntos de los casos.
     * @param masterCaseId
     * @param idCasoSelected
     * @return String 
     */
    @AuraEnabled
    public static String mergeCase(String masterCaseId, String idCasoSelected) {
        return GRR_Case_Merge.fusionarCaso(masterCaseId, idCasoSelected);
    }

    @AuraEnabled(cacheable=true)
    public static List<Folder> getCarpetas(String carpetaDeveloperName) {
        List<Folder> carpetas = new List<Folder>();
        Id parentId = null;
        if (carpetaDeveloperName == null) {
            parentId = [SELECT Id FROM Folder WHERE DeveloperName = 'GRR_Operativas' LIMIT 1].Id;
        } else {
            //parentId = [SELECT Id FROM Folder WHERE DeveloperName = :carpetaDeveloperName LIMIT 1].Id;
            List<Folder> carpetaPrincipal = [SELECT Id FROM Folder WHERE DeveloperName = :carpetaDeveloperName];
            if (!carpetaPrincipal.isEmpty()) {
                parentId = [SELECT Id FROM Folder WHERE DeveloperName = :carpetaDeveloperName LIMIT 1].Id;
            }
        }
        for (Folder carpeta : [SELECT Name, DeveloperName FROM Folder WHERE Type = 'EmailTemplate' AND ParentId = :parentId]) {
            carpetas.add(carpeta);
        }
        return carpetas;
    }

    @AuraEnabled(cacheable=true)
    public static List<PickListWrapper> getPlantillasResponder(Id recordId, String carpeta) {
        List<Case> casos = [SELECT CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c FROM Case WHERE Id = :recordId LIMIT 1];

        Set<String> idsMCC = new Set<String>();
        if(!casos.isEmpty()){
            Case caso = casos[0];
            if (caso.CC_MCC_Tematica__c != null) {
                idsMCC.add(caso.CC_MCC_Tematica__c);
            }
            if (caso.CC_MCC_ProdServ__c != null) {
                idsMCC.add(caso.CC_MCC_ProdServ__c);
            }
            if (caso.CC_MCC_Motivo__c != null) {
                idsMCC.add(caso.CC_MCC_Motivo__c);
            }
        }
        
        List<CC_MCC_Plantilla__c> plantillasMCC = [SELECT CC_MCC_Plantilla_DeveloperName__c
                                                    FROM CC_MCC_Plantilla__c WHERE CC_MCC__c IN :idsMCC];

        List<EmailTemplate> plantillasEmail = new List<EmailTemplate>();
        List<pickListWrapper> wrapPlantilla = new List<PickListWrapper>();

        if (!plantillasMCC.isEmpty()) {
            Set<String> opcionesPlantillaMCC = new Set<String>();
            for (CC_MCC_Plantilla__c plantillaMCC : plantillasMCC) {
                opcionesPlantillaMCC.add(plantillaMCC.CC_MCC_Plantilla_DeveloperName__c);
            }

            plantillasEmail = [SELECT Name, DeveloperName FROM EmailTemplate WHERE Folder.DeveloperName = :carpeta AND DeveloperName IN :opcionesPlantillaMCC ORDER BY Name ASC];
            if (plantillasEmail.isEmpty()) {
                plantillasEmail = [SELECT Name, DeveloperName FROM EmailTemplate WHERE Folder.DeveloperName = :carpeta ORDER BY Name ASC];
            }
        } else {
            plantillasEmail = [SELECT Name, DeveloperName FROM EmailTemplate WHERE Folder.DeveloperName = :carpeta ORDER BY Name ASC];
        }

        for (EmailTemplate plantillaEmail : plantillasEmail) {
            PickListWrapper wrap = new PickListWrapper(plantillaEmail.Name, plantillaEmail.Id);
            wrapPlantilla.add(wrap);
        }

        return wrapPlantilla;
    }

    public class PickListWrapper {
        @AuraEnabled
        public String label {get; set;}

        @AuraEnabled
        public String value {get; set;}

        public PickListWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    @AuraEnabled(cacheable=true)
    public static string buscarCorreoContacto(Id idCaso) {
        List<Case> casos = [SELECT SuppliedEmail, CC_MailTelfNotif__c, Contact.Email FROM Case WHERE Id = :idCaso LIMIT 1];
        if (casos.isEmpty()) {
            return '';
        } else {
            String sAuxMail = '';
            if (casos[0].SuppliedEmail != '' && casos[0].SuppliedEmail != null) {
                sAuxMail = casos[0].SuppliedEmail;
            } else if (casos[0].CC_MailTelfNotif__c != '' && casos[0].CC_MailTelfNotif__c != null) {
                sAuxMail = casos[0].CC_MailTelfNotif__c;
            } else {
                sAuxMail = casos[0].Contact.Email;
            }
            return sAuxMail;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<PickListWrapper> getPlantillaGrupoList(Id grupoId, String tipoOperativa) {
        List<CC_Grupo_Colaborador_Plantilla__c> plantillasGrupo = [SELECT CC_Plantilla_DeveloperName__c FROM CC_Grupo_Colaborador_Plantilla__c WHERE CC_Grupo_Colaborador__c = :grupoId AND CC_Operativa__c = :tipoOperativa];
        List<String> nombresPlantilla = new List<String>();
        for (CC_Grupo_Colaborador_Plantilla__c plantilla : plantillasGrupo) {
            nombresPlantilla.add(plantilla.CC_Plantilla_DeveloperName__c);
        }
        List<pickListWrapper> optionsPlantillas = new List<pickListWrapper>();
        List<EmailTemplate> plantillas = [SELECT Name, DeveloperName FROM EmailTemplate WHERE DeveloperName IN :nombresPlantilla ORDER BY Name ASC];

        for (EmailTemplate plantilla : plantillas) {
            PickListWrapper wrap = new PickListWrapper(plantilla.Name, plantilla.Id);
            optionsPlantillas.add(wrap);
        }
        return optionsPlantillas;
    }

    @AuraEnabled
    public static void crearTareaGestionadoMes(Id idCaso) {
        Task tarea = new Task ();
        tarea.Type = 'Actividad manual';
        tarea.Subject = 'Gestionado en el mes';
        tarea.ActivityDate = System.today();
        tarea.Status = 'Completed';
        tarea.WhatId = idCaso;
        tarea.TaskSubtype = 'Task';
        tarea.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'GRR_Task');
        
        Database.insert(tarea, false);
    }

    @AuraEnabled
    public static void reabrirTareaTrasladoColaborador(Id idCaso){
        List<Task> listaTareasCompletadas = new List<Task>();
        Id rtTaskGRR = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'GRR_Task');

        //Si ya existe alguna tarea de Traslado a Colaborador abierta, no se debe hacer nada. En caso contrario, se busca la tarea completada más reciente para reabrirla
        List<Task> lstTareasTrasladoAbiertas = [SELECT Id FROM Task 
                                                WHERE WhatId = :idCaso AND RecordTypeId = :rtTaskGRR 
                                                AND Type = 'Traslado Colaborador' AND IsClosed = FALSE 
                                                WITH SECURITY_ENFORCED LIMIT 1];
        
        if (lstTareasTrasladoAbiertas.isEmpty()) {
            listaTareasCompletadas = [SELECT Id FROM Task
                                                WHERE WhatId = :idCaso AND RecordTypeId = :rtTaskGRR AND Type = 'Traslado Colaborador' AND IsClosed = TRUE 
                                                WITH SECURITY_ENFORCED
                                                ORDER BY CreatedDate DESC LIMIT 1];

            if (!listaTareasCompletadas.isEmpty()) {
                listaTareasCompletadas[0].Status = 'Open';

                // El cambio de estado del caso es mejor hacerlo en el LWC para que se actualice 
                // Case caso = new Case(Id = idCaso);
                // caso.Status = 'Pendiente Colaborador';
                // lstCasosActualizar.add(caso);
            } else {
                throw new AuraHandledException('No se encuentra ninguna tarea de traslado a colaborador asociada al caso.');
            }
        } else {
            throw new AuraHandledException('Ya existe una tarea de traslado a colaborador abierta asociada al caso.');
        }

        if(!listaTareasCompletadas.isEmpty() && Schema.sObjectType.Task.isUpdateable()){
            Database.update(listaTareasCompletadas[0],true);
        }
    }

}