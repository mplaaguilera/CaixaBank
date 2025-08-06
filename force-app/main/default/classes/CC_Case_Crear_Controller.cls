public with sharing class CC_Case_Crear_Controller {

    @AuraEnabled(cacheable=true)
    public static Id buscarRecordTypeId(Id recordId) {
        Id recordTypeId;
        Id recordTypeIdContact;
        if(recordId != null){
            recordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        	List<Contact> contacto = [SELECT RecordTypeId FROM Contact WHERE Id = :recordId LIMIT 1];
            if(!contacto.isEmpty()){
                if(contacto.get(0).RecordTypeId == recordTypeIdContact){
                	recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
                }		    
            }
        }
        return recordTypeId;
    }
    
    @AuraEnabled(cacheable=true)
    public static RetornoComprobarRol comprobarRol() {
        Id recordTypeId;

        if (!UserRole.SObjectType.getDescribe().isAccessible()) {
            throw new AuraHandledException('Fallo al comprobar privilegios.');
        }

        List<UserRole> roles = [SELECT Name FROM UserRole WHERE Id = :UserInfo.getUserRoleId()];
        if (!roles.isEmpty()) {
            if (roles[0].Name == 'SAC General') {
                //recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
            } else if (roles[0].Name == 'SACH') {
                recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SACH_Cliente').getRecordTypeId();
            } else if (roles[0].Name == 'Testamentarías'){
                recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TMS_Expediente').getRecordTypeId();
            } else if (roles[0].Name == 'GRR' || roles[0].Name == 'GRR Agente'  || roles[0].Name == 'GRR Agente COPS') {
                recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'GRR_Cliente'); 
            }
        }
        
        return new RetornoComprobarRol(roles.isEmpty() ? '' : roles[0].Name, recordTypeId);
    }

    @AuraEnabled(cacheable=true)
    public static String getProcedenciaUsuarioGRR(){
        String resultado;
        List<GroupMember> gruposPertenecientes = [SELECT Id, Group.DeveloperName FROM GroupMember WHERE (UserOrGroupId = :UserInfo.getUserId() AND Group.Type='Regular' AND Group.DeveloperName LIKE 'GRR_Buzon%') LIMIT 1];
        
        if (!gruposPertenecientes.isEmpty()) {
            //Pertenece a uno o varios grupos
            List<GRR_Correos_Buzones_Entrada__mdt> relaciones = [SELECT GRR_Canal_Procedencia__c, GRR_Cola_Procedencia__c FROM GRR_Correos_Buzones_Entrada__mdt WHERE GRR_Cola_Procedencia__c = :gruposPertenecientes[0].Group.DeveloperName LIMIT 1];
            
            if (!relaciones.isEmpty()) {
                //Siempre se asocia el primer grupo al que pertenece (ya sea único o varios)
                resultado = relaciones[0].GRR_Canal_Procedencia__c;
            }
        }
        else {
            throw new AuraHandledException('Su usuario no pertenece a ningún public group');
        }

        return resultado;
    }

    public class RetornoComprobarRol {
        @AuraEnabled
        public String nombreRol {get; set;}
        @AuraEnabled
        public Id recordTypeId {get; set;}

        public RetornoComprobarRol(String nombreRol, Id recordTypeId) {
            this.nombreRol = nombreRol;
            this.recordTypeId = recordTypeId;
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> obtenerVariablesCOPS(Id recordTypeId, Id recordId) {
        //Comprobamos si el caso que se crea es de COPS, el usuario es perfil COPS y si tiene departamento asignado --> Para mostrar un canal de procedencia u otro
        Map<String, Object> retorno = new Map<String, Object>();

        if(recordId != null){
        	recordTypeId = buscarRecordTypeId(recordId);
        }

        if (recordTypeId != null) {
            RecordType tipoRegistro = [SELECT DeveloperName FROM RecordType WHERE Id = :recordTypeId];
            retorno.put('recordTypeDeveloperName', tipoRegistro.DeveloperName.SubStringBefore('_'));
            retorno.put('recordTypeId', recordTypeId);
            if (tipoRegistro.DeveloperName.equalsIgnoreCase('CC_Cliente')){
                retorno.put('esClienteCC', 'true');
            }
            
        }
        
        User usuarioActual = [SELECT Department, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];

        List<String> departamentosUsuario;
        if (usuarioActual.Department != null) {
            departamentosUsuario = usuarioActual.Department.split('/');
        }

        retorno.put('usuarioDepartamento', departamentosUsuario);
        retorno.put('perfilUsuario', usuarioActual.Profile.Name.SubStringBefore('_'));
        
        return retorno;
    }

    @AuraEnabled
    public static void crearActividadCasoNuevo(Id recordId) {
        //Para COPS
        if (OT_Proyectos.registroProyecto(recordId) == 'OS' || OT_Proyectos.registroProyecto(recordId) == 'SACH') {
            //Se crea actividad de alta manual
            Task taskAltaManual = new Task();
            if (OT_Proyectos.registroProyecto(recordId) == 'OS') {
                taskAltaManual.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
            } else if (OT_Proyectos.registroProyecto(recordId) == 'SACH') {
                taskAltaManual.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'SACH_Task');
            }
            taskAltaManual.Status = 'Completed';
            taskAltaManual.WhatId = recordId;
            taskAltaManual.Type = 'Alta manual de caso';
            taskAltaManual.Subject = 'Alta manual de caso';
            taskAltaManual.ActivityDate = System.today();
            insert taskAltaManual;

            //Se informa el la cola origen en función del canal de procedencia seleccionado
            Case caso = [SELECT CC_Canal_Procedencia__c FROM Case WHERE Id = :recordId];

            List<OS_Canal_Procedencia__mdt> colasProcedencia = [SELECT OS_Cola_Procedencia__c FROM OS_Canal_Procedencia__mdt
                                                                WHERE OS_Canal_Procedencia__c = :caso.CC_Canal_Procedencia__c LIMIT 1];
            if (!colasProcedencia.isEmpty()) {
                caso.CC_Cola_Procedencia__c = colasProcedencia[0].OS_Cola_Procedencia__c;
                update caso;
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static String obtenerTipoContacto(String canalProd) {
        String tipoCliente;
        List<CC_Lista_Valores__c> canalProcedencia = [SELECT Name, CC_Valor__c FROM CC_Lista_Valores__c
                                                        WHERE CC_Lista__r.Name = 'COPS: Relación Tipo de Contacto y Canal de Procedencia'
                                                        AND Name = :canalProd];
        if (!canalProcedencia.isEmpty()) {
            tipoCliente = canalProcedencia[0].CC_Valor__c;
        }
        return tipoCliente;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> obtenerGruposTrabajo(String canalProd) {

        List <string> gruposNombre = new List <string> ();

        //se tiene id de usuario y canal de procedencia de caso
        //buscar grupos de trabajo con canal de procedencia coincidente e id de usuario en objeto Colaboradores  
        if (!String.isBlank(canalProd)) {

            List <CC_Grupo_Colaborador__c> gruposTrabajo = [SELECT Name, Id FROM CC_Grupo_Colaborador__c WHERE CC_Canal_de_procedencia__c INCLUDES (:canalProd)];
            List <CC_Grupo_Colaborador_Contact__c> gruposColab = new List <CC_Grupo_Colaborador_Contact__c> ();
            
            if (!gruposTrabajo.isEmpty()){
                gruposColab = [SELECT CC_Grupo_Colaborador__c, CC_Grupo_Colaborador__r.Name, Id FROM CC_Grupo_Colaborador_Contact__c 
                                WHERE CC_Grupo_Colaborador__c IN :gruposTrabajo AND CC_Usuario__c = :UserInfo.getUserId()];
            }
            
            for (CC_Grupo_Colaborador_Contact__c grupo : gruposColab) {
                gruposNombre.add(grupo.CC_Grupo_Colaborador__r.Name);
            }
        }
        return gruposNombre;
    }

    @AuraEnabled
    public static void asociarContactoCCEmpleado(Id recordId, Id contactId) {
        Id recordType = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
        List<Contact> contacto = new List<Contact>();
        contacto = [SELECT Id, RecordTypeId FROM Contact WHERE Id = :contactId LIMIT 1]; 
        if (!contacto.isEmpty() && recordType == contacto[0].RecordTypeId) {
            Case casoCreado = [SELECT Id, ContactId FROM Case WHERE Id = :recordId];
            casoCreado.ContactId = contacto[0].Id;
            update casoCreado;
        }
    }

    //US713663 - Segmentos - Crear caso nuevo incorporando el NIF del cliente
    @AuraEnabled(cacheable=true)
    public static Boolean isPerfilSegmentos() {

        Boolean esSegmentos = false;
        User usuarioActual = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];

        if(usuarioActual != null && usuarioActual.Profile.Name == 'SEG_Usuario_CaixaBank'){
            esSegmentos = true;
        }
        
        return esSegmentos;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> obtencionNIF(String nif) {
        List<String> lstDatos = new List<String>();
        if(nif != null){
          List<Account> cuenta = [SELECT id, SEG_Prioridad_Carterizacion_Segmentos__c, AV_OficinaPrincipal__r.SEG_Organizacion__c, AV_OficinaPrincipal__r.SEG_Zona__c, SEG_Oficina_Gestora_Segmentos__r.SEG_Organizacion__c, SEG_Oficina_Gestora_Segmentos__r.SEG_Zona__c  FROM Account WHERE CC_Numero_Documento__c = :nif LIMIT 1];
            if(!cuenta.isEmpty()){
                lstDatos.add(cuenta[0].id);
                if(cuenta[0].SEG_Prioridad_Carterizacion_Segmentos__c && cuenta[0].SEG_Oficina_Gestora_Segmentos__r.SEG_Organizacion__c != null && cuenta[0].SEG_Oficina_Gestora_Segmentos__r.SEG_Zona__c != null){
                    lstDatos.add(cuenta[0].SEG_Oficina_Gestora_Segmentos__r.SEG_Organizacion__c);
                    lstDatos.add(cuenta[0].SEG_Oficina_Gestora_Segmentos__r.SEG_Zona__c);
                } else if(!cuenta[0].SEG_Prioridad_Carterizacion_Segmentos__c && cuenta[0].AV_OficinaPrincipal__r.SEG_Organizacion__c != null && cuenta[0].AV_OficinaPrincipal__r.SEG_Zona__c != null){
                    lstDatos.add(cuenta[0].AV_OficinaPrincipal__r.SEG_Organizacion__c);
                    lstDatos.add(cuenta[0].AV_OficinaPrincipal__r.SEG_Zona__c);
                } else {
                    lstDatos.add('errorOrgZona');
                }
                return lstDatos;
            }else{
                lstDatos.add('error');
                return lstDatos;
            }
        }
        lstDatos.add('error');
        return lstDatos;
    }
    //FIN - US713663 - Segmentos - Crear caso nuevo incorporando el NIF del cliente
}