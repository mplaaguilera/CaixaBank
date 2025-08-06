public with sharing class CC_Grupo_Colaborador {
    
    private static Id centroCaracteristicaRecordTypeId = Schema.getGlobalDescribe().get('CC_Caracteristica__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Centro_CaixaBank').getRecordTypeId();
    private static Id centroRecordTypeId = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();

    public static void tratarGrupo(List<Account> cuentas) {        
        Set<Id> cuentaId = new Set<Id>();
		for(Account cuenta : cuentas){
			cuentaId.add(cuenta.Id);
        }        

        List<CC_Grupo_Colaborador__c> grupos = [
            SELECT Id, Name, CC_Cuenta__c
            FROM CC_Grupo_Colaborador__c 
            WHERE CC_Cuenta__c in :cuentaId
        ];

        Map<Account, CC_Grupo_Colaborador__c> mapaCuentasGrupos = new Map<Account, CC_Grupo_Colaborador__c>();

        for (Account cuenta : cuentas) {
            for (CC_Grupo_Colaborador__c grupo : grupos) {
                if (cuenta.Id == grupo.CC_Cuenta__c) {
                    mapaCuentasGrupos.put(cuenta,grupo);
                }
            } 
        }

        List<CC_Grupo_Colaborador__c> gruposNuevos = new List<CC_Grupo_Colaborador__c>();
        List<CC_Grupo_Colaborador__c> gruposActualizados = new List<CC_Grupo_Colaborador__c>();

        for (Account cuenta : cuentas) {
            if (cuenta.CC_Tipo_Centro__c == 'OF' || cuenta.CC_Tipo_Centro__c == 'GC') {
                if (mapaCuentasGrupos.get(cuenta) == null) {
                    gruposNuevos.add(insertarGrupoColaborador(cuenta));
                }
                else if (mapaCuentasGrupos.get(cuenta) != null) {
                    gruposActualizados.add(actualizarGrupoColaborador(cuenta,mapaCuentasGrupos.get(cuenta)));
                }
            }
        }

        if (gruposNuevos.size() > 0) {
            insert gruposNuevos;
        }
        if (gruposActualizados.size() > 0) {
            update gruposActualizados;
        }
    }

    private static CC_Grupo_Colaborador__c insertarGrupoColaborador(Account cuenta) {
        CC_Grupo_Colaborador__c grupo = new CC_Grupo_Colaborador__c(
            Name = cuenta.Name,
            CC_Cuenta__c = cuenta.Id,
            RecordTypeId = centroRecordTypeId
        );

        return grupo;
    }

    private static CC_Grupo_Colaborador__c actualizarGrupoColaborador(Account cuenta, CC_Grupo_Colaborador__c grupo) {
        grupo.Name = cuenta.Name;
        return grupo;
    }

    
}