public without sharing class GRR_UR_Merge {
    
    @AuraEnabled
    public static String fusionarUR(String masterURId, String idURSelected) {
        try {
            String resultado = 'Ok';
            GRR_UR__c urOrigen = [SELECT Id, GRR_Id_UR__c FROM GRR_UR__c WHERE Id = :masterURId WITH SECURITY_ENFORCED];
            GRR_UR__c urDestino = [SELECT Id, GRR_Id_UR__c FROM GRR_UR__c WHERE Id = :idURSelected WITH SECURITY_ENFORCED];

            //Buscamos los lanzamientos asociados a la UR origen y los asocia a la UR destino
            List<GRR_Lanzamiento__c> listaLanzamientosUROrigen = [SELECT GRR_UR__c, GRR_Codigo_UR__c, GRR_Fecha_Prevista_Posesion__c FROM GRR_Lanzamiento__c WHERE GRR_UR__c = :urOrigen.Id WITH SECURITY_ENFORCED];
            List<GRR_Lanzamiento__c> fechasPrevistaPosesionURDestino = [SELECT GRR_Fecha_Prevista_Posesion__c FROM GRR_Lanzamiento__c WHERE GRR_UR__c = :urDestino.Id];
            Set<String> fechasDestino = new Set<String>();
            if (!listaLanzamientosUROrigen.isEmpty()) {
                List<GRR_Lanzamiento__c> listaLanzamientosActualizar = new List<GRR_Lanzamiento__c>();
                List<GRR_Lanzamiento__c> listaLanzamientosBorrar = new List<GRR_Lanzamiento__c>();
                for (GRR_Lanzamiento__c fecha : fechasPrevistaPosesionURDestino) {
                    fechasDestino.add(fecha.GRR_Fecha_Prevista_Posesion__c.format('yyyyMMdd'));
                }
                for (GRR_Lanzamiento__c lanzamiento : listaLanzamientosUROrigen) {
                    if (!fechasDestino.contains(lanzamiento.GRR_Fecha_Prevista_Posesion__c.format('yyyyMMdd'))) {
                        lanzamiento.GRR_UR__c = urDestino.Id;
                        lanzamiento.GRR_Codigo_UR__c = urDestino.GRR_Id_UR__c;
                        lanzamiento.GRR_Codigo_Lanzamiento__c = urDestino.GRR_Id_UR__c + '-' + lanzamiento.GRR_Fecha_Prevista_Posesion__c.format('yyyyMMdd');
                        listaLanzamientosActualizar.add(lanzamiento);
                    } else {
                        listaLanzamientosBorrar.add(lanzamiento);
                    }
                }
                if (!Schema.sObjectType.GRR_Lanzamiento__c.fields.GRR_UR__c.isUpdateable()) {
                    return null;
                }
                Database.update(listaLanzamientosActualizar, false);
                Database.delete(listaLanzamientosBorrar, false);
            }

            //Buscamos los casos asociados a la UR origen y los asocia a la UR destino
            List<Case> listaCasosVinculadosUR = [SELECT GRR_UR_Relacionada__c FROM Case WHERE GRR_UR_Relacionada__c = :urOrigen.Id WITH SECURITY_ENFORCED];
            if (!listaCasosVinculadosUR.isEmpty()) {
                List<Case> listaCasosActualizar = new List<Case>();
                for (Case caso : listaCasosVinculadosUR) {
                    caso.GRR_UR_Relacionada__c = urDestino.Id;
                    listaCasosActualizar.add(caso);
                }
                if (!Schema.sObjectType.Case.fields.GRR_UR_Relacionada__c.isUpdateable()) {
                    return null;
                }
                Database.update(listaCasosActualizar, false);
            }

            //Buscamos los registros de carga asociados a la UR origen y los asocia a la UR destino
            List<GRR_RegistroCarga__c> listaRegistrosVinculadosUR = [SELECT GRR_UR__c, GRR_CodigoUR__c FROM GRR_RegistroCarga__c WHERE GRR_UR__c = :urOrigen.Id WITH SECURITY_ENFORCED];
            if (!listaRegistrosVinculadosUR.isEmpty()) {
                List<GRR_RegistroCarga__c> listaRegistrosActualizar = new List<GRR_RegistroCarga__c>();
                for (GRR_RegistroCarga__c registroCarga : listaRegistrosVinculadosUR) {
                    registroCarga.GRR_UR__c = urDestino.Id;
                    registroCarga.GRR_CodigoUR__c = urDestino.GRR_Id_UR__c;
                    listaRegistrosActualizar.add(registroCarga);
                }
                if (!Schema.sObjectType.GRR_RegistroCarga__c.fields.GRR_UR__c.isUpdateable()) {
                    return null;
                }
                Database.update(listaRegistrosActualizar, false);
            }

            //Buscamos los archivos adjuntos asociados a la UR origen y los asocia a la UR destino
            List<ContentDocumentLink> listaAdjuntosVinculadosUR = [SELECT LinkedEntityId, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId = :urOrigen.Id WITH SECURITY_ENFORCED];
            if (!listaAdjuntosVinculadosUR.isEmpty()) {
                List<ContentDocumentLink> listaArchivosURMaster = new List<ContentDocumentLink>();
                for (ContentDocumentLink cdl : listaAdjuntosVinculadosUR) {
                    ContentDocumentLink nuevoCdl = cdl.clone();
                    nuevoCdl.LinkedEntityId = urDestino.Id;
                    listaArchivosURMaster.add(nuevoCdl);
                }
                Database.delete(listaAdjuntosVinculadosUR, false);

                if (!Schema.sObjectType.ContentDocumentLink.fields.LinkedEntityId.isCreateable()) {
                    return null;
                }
                Database.insert(listaArchivosURMaster, false);
            }

            //Buscamos las tareas asociadas a la UR origen y los asocia a la UR destino
            List<Task> listaTareasCerradas = [SELECT WhatId FROM Task WHERE WhatId = :urOrigen.Id WITH SECURITY_ENFORCED];
            if (!listaTareasCerradas.isEmpty()) {
                for (Task tarea : listaTareasCerradas) {
                    tarea.WhatId = urDestino.Id;
                }
                if (!Schema.sObjectType.Task.fields.WhatId.isUpdateable()) {
                    return null;
                }
                Database.update(listaTareasCerradas, false);
            }

            //Creamos tarea de fusión de UR
            Map<String, Object> campos = new Map<String, Object>();
            campos.put('WhatId', urDestino.Id);
            campos.put('Type', 'Fusión de URs');
            campos.put('Subject', 'Fusión de URs');
            campos.put('Description', 'Fusión de la UR ' + urOrigen.GRR_Id_UR__c + ' con la UR ' + urDestino.GRR_Id_UR__c);
            campos.put('ActivityDate', System.today());
            campos.put('Status', 'Completed');
            insert GRR_Activity.crearTarea('GRR_Task', campos);

            // Se elimina la UR origen
            Database.delete(urOrigen, false);
            return resultado;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}