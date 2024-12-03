public with sharing class CC_Grupo_Colaborador_Contact {
    private static Id centroRecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
    
    @InvocableMethod
    public static void tratarColaborador(List<Id> empleadosId) {
      
        //Buscamos los contactos que cumplen los requisitos para figurar como colaboradores
        List<Contact> empleados = [
            SELECT Id, AccountId,Email
            FROM Contact
            WHERE Id in :empleadosId
            	AND ((AV_DescFuncion__c LIKE '%DIREC%' AND Account.CC_Tipo_Centro__c = 'OF' AND Email != '')
                     OR (AV_DescFuncion__c IN ('DIRECTOR AREA DE NEGOCIO','DIRECTORA AREA DE NEGOCIO') AND Account.CC_Tipo_Centro__c = 'GC' AND Email != ''))];
        //Nos guardamos conjuntos de ids de Centros y de Empleados para uso posterior
     
        Set<Id> centroIds = new Set<Id>();
        Set<Id> empleadoIds = new Set<Id>();
        for(Contact empleado : empleados) {
            centroIds.add(empleado.AccountId);
            empleadoIds.add(empleado.Id);
        }
        
        //Iniciamos el proceso de borrado de los colaboradores que no cumplen los requisitos
        Set<Id> empleadosBorradoIds = new Set<Id>();
        for(Id empleado : empleadosId) {
            if (!empleadoIds.contains(empleado)) {
                empleadosBorradoIds.add(empleado);
            }
        }
        //Borramos los no aptos
        if (!empleadosBorradoIds.isEmpty()) {
            List<CC_Grupo_Colaborador_Contact__c> colaboradoresBorrado = [SELECT Id FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Contacto__c in :empleadosBorradoIds AND CC_Grupo_Colaborador__r.OS_Negocio__c	='CC' and CC_Grupo_Colaborador__r.RecordTypeId = :centroRecordTypeId];
            delete colaboradoresBorrado;
        }
        
        //Hacemos una búsqueda de los Grupos Colaboradores en relación a las cuentas asociadas a los empleados
        List<CC_Grupo_Colaborador__c> grupos = [
             SELECT Id, CC_Cuenta__c
             FROM CC_Grupo_Colaborador__c
             WHERE CC_Cuenta__c in :centroIds AND OS_Negocio__c	='CC'];
        Map<Id,Id> centrosGrupos = new Map<Id,Id>();
        for(CC_Grupo_Colaborador__c grupo : grupos) {
            centrosGrupos.put(grupo.CC_Cuenta__c, grupo.Id);
        } 
        
        //Buscamos los colaboradores que ya han sido registrados en su correspondiente Grupo Colaborador
        List<CC_Grupo_Colaborador_Contact__c> colaboradoresExistentes = [
            SELECT Id,CC_Grupo_Colaborador__c, CC_Contacto__c,CC_Para_CC__c
            FROM CC_Grupo_Colaborador_Contact__c
            WHERE CC_Contacto__c in :empleadoIds AND CC_Grupo_Colaborador__r.OS_Negocio__c	='CC'
        ];
        Map<Id,CC_Grupo_Colaborador_Contact__c> empleadosColaboradores = new Map<Id,CC_Grupo_Colaborador_Contact__c>();
        for (CC_Grupo_Colaborador_Contact__c colaborador : colaboradoresExistentes) {
            empleadosColaboradores.put(colaborador.CC_Contacto__c,colaborador);
        }

        //Iniciamos el proceso de creación/modificación de colaboradores
        List<CC_Grupo_Colaborador_Contact__c> colaboradores = new List<CC_Grupo_Colaborador_Contact__c>();
        if(!empleados.isEmpty()){
            for(Contact empleado : empleados) {
                //De no formar parte de los colaboradores registrados lo creamos y añadimos a la lista
                if (empleadosColaboradores.get(empleado.Id) == null && centrosGrupos.get(empleado.AccountId) !=null){
                    CC_Grupo_Colaborador_Contact__c colaborador = new CC_Grupo_Colaborador_Contact__c(
                        CC_Contacto__c = empleado.Id,
                        CC_Grupo_Colaborador__c = centrosGrupos.get(empleado.AccountId),
                        CC_Para_CC__c = 'CC');
                    colaboradores.add(colaborador);
                }
            }
        }
        
        
        //Realizamos los cambios
        if (colaboradores.size() > 0) {
            upsert colaboradores;
        }
    }
    
  
    
    
    
/*
   
    public static void tratarColaborador(List<Id> empleadosId) {
        List<CC_Grupo_Colaborador_Contact__c> colaboradores = [
            SELECT Id,CC_Contacto__c
            FROM CC_Grupo_Colaborador_Contact__c
            WHERE CC_Contacto__c in :empleadosId
        ];

        List<Contact> empleados = [
            SELECT Id, AccountId, CC_Cargo__c,Email
            FROM Contact
            WHERE Id in :empleadosId
        ];

        //Relacionamos los colaboradores asociados a los contactos recibidos
        Map<Contact,CC_Grupo_Colaborador_Contact__c> mapaContactosColaboradores = new Map<Contact,CC_Grupo_Colaborador_Contact__c>();
        for (Contact empleado : empleados) {
            for (CC_Grupo_Colaborador_Contact__c colaborador : colaboradores) {
                if (empleado.Id == colaborador.CC_Contacto__c) {
                    mapaContactosColaboradores.put(empleado,colaborador);
                }
            } 
        }

        List<CC_Grupo_Colaborador_Contact__c> colaboradoresNuevos = new List<CC_Grupo_Colaborador_Contact__c>();
        List<CC_Grupo_Colaborador_Contact__c> colaboradoresActualizados = new List<CC_Grupo_Colaborador_Contact__c>();

        //Creamos al colaborador en caso de no existir, lo modificamos en caso contrario
        for (Contact empleado : empleados) {
            if (mapaContactosColaboradores.get(empleado) == null && insertarColaborador(empleado) != null) {
                colaboradoresNuevos.add(insertarColaborador(empleado));
            }
            else if (mapaContactosColaboradores.get(empleado) != null && actualizarColaborador(empleado,mapaContactosColaboradores.get(empleado))) {
                colaboradoresActualizados.add(mapaContactosColaboradores.get(empleado));
            }
        }

        if (colaboradoresNuevos.size() > 0) {
            insert colaboradoresNuevos;
        }
        if (colaboradoresActualizados.size() > 0) {
            delete colaboradoresActualizados;
        }
    }

    private static CC_Grupo_Colaborador_Contact__c insertarColaborador(Contact empleado) {
        Account cuenta = [
            SELECT Id, CC_Tipo_Centro__c
            FROM Account
            WHERE 
                Id = :empleado.AccountId
                AND RecordTypeId = :centroRecordTypeId
            LIMIT 1
        ];

        if (cuenta != null) {
            CC_Grupo_Colaborador__c grupo = [
                        SELECT Id
                        FROM CC_Grupo_Colaborador__c
                        WHERE CC_Cuenta__c = :cuenta.Id
                        LIMIT 1
                    ];
            
            if (cuenta.CC_Tipo_Centro__c == 'OF' && (empleado.CC_Cargo__c == 'DIRECCIÓN' || empleado.CC_Cargo__c == 'SUBDIRECCIÓN') && String.isNotBlank(empleado.Email)) {
                CC_Grupo_Colaborador_Contact__c colaborador = new CC_Grupo_Colaborador_Contact__c(
                    CC_Contacto__c = empleado.Id,
                    CC_Grupo_Colaborador__c = grupo.Id,
                    CC_Para_CC__c = 'CC'
                );
                return colaborador;
            }
            else if (cuenta.CC_Tipo_Centro__c == 'GC' && empleado.CC_Cargo__c == 'DIRECCIÓN ÁREA DE NEGOCIO' && String.isNotBlank(empleado.Email)) {
                CC_Grupo_Colaborador_Contact__c colaborador = new CC_Grupo_Colaborador_Contact__c(
                    CC_Contacto__c = empleado.Id,
                    CC_Grupo_Colaborador__c = grupo.Id,
                    CC_Para_CC__c = 'CC'
                );
                return colaborador;
            }
        }
        return null;
    }   
    
    private static Boolean actualizarColaborador(Contact empleado, CC_Grupo_Colaborador_Contact__c colaborador) {
        Account cuenta = [
            SELECT Id, CC_Tipo_Centro__c
            FROM Account
            WHERE 
                Id = :empleado.AccountId
                AND RecordTypeId = :centroRecordTypeId
            LIMIT 1
        ];

        if (cuenta != null){
            if (!String.isNotBlank(empleado.Email)) {
                return true;
            }
            else if (cuenta.CC_Tipo_Centro__c == 'OF' && empleado.CC_Cargo__c != 'DIRECCIÓN' && empleado.CC_Cargo__c != 'SUBDIRECCIÓN' ) {
                return true;
            }
            else if (cuenta.CC_Tipo_Centro__c == 'GC' && empleado.CC_Cargo__c != 'DIRECCIÓN ÁREA DE NEGOCIO') {
                return true;
            }
        }

        return false;
    }*/
}