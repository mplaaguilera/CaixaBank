public without sharing class SEG_GetRT {
    /*
    @description Método para recuperar los record types de un mapa de objetos.
    @param mapObjetos -> Mapa de objetos a obtener los recordTypes.
    @return Mapa con la configuración de de recordTypes obtenidos.
    */
    public static Map<String,Map<String,Schema.RecordTypeInfo>> getRecordTypesObjects (Set<String> setObjetos) {
        
        Map<String,Map<String,Schema.RecordTypeInfo>> mapObjectRT = new Map<String,Map<String,Schema.RecordTypeInfo>>();
        for(String objeto : setObjetos){
            if (String.isNotBlank(objeto) && !mapObjectRT.containsKey(objeto)){
                switch on objeto {
                    when 'Case' {
                        mapObjectRT.put(objeto,Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName());
                    }
                    when 'Account' {
                        mapObjectRT.put(objeto,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName());
                    }
                    when 'Contact' {
                        mapObjectRT.put(objeto,Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName());
                    }
                    when 'Task' {
                        mapObjectRT.put(objeto,Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName());
                    }
                    when 'CC_Canal_Com__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'CC_Caracteristica__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'CC_Grupo_Colaborador__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SEG_Auditoria__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SEG_Auditoria__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SEG_ClasificacionRapida__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SEG_ClasificacionRapida__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SEG_Contratos__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SEG_Contratos__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SEG_CRNotasTipificadas__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SEG_CRNotasTipificadas__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SEG_Duplicate_Case__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SEG_Duplicate_Case__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SEG_Excepciones__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SEG_Excepciones__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SEG_Excepciones_Caso__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SEG_Excepciones_Caso__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SEG_Excepciones_Centro__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SEG_Excepciones_Centro__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SEG_Excepciones_CR__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SEG_Excepciones_CR__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SEG_Excepciones_Grupo__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SEG_Excepciones_Grupo__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SEG_Excepciones_Grupo_Empresa__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SEG_Excepciones_Grupo_Empresa__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SEG_ExcepcionesCentro__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SEG_ExcepcionesCentro__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SEG_ExcepcionesCR__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SEG_ExcepcionesCR__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SEG_ExcepcionesEmpresa__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SEG_ExcepcionesEmpresa__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SEG_ExcepcionesGrupo__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SEG_ExcepcionesGrupo__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SEG_ExcepcionesGrupoEmpresa__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SEG_ExcepcionesGrupoEmpresa__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SEG_Fotosdefacturacion__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SEG_Fotosdefacturacion__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SEG_Gestor_Grupo__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SEG_Gestor_Grupo__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SEG_Grupos_por_caso__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SEG_Grupos_por_caso__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SEG_GruposCSO__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SEG_GruposCSO__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SEG_GruposServiciosCSO__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SEG_GruposServiciosCSO__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SEG_GrupoTrabajoRelacionado__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SEG_GrupoTrabajoRelacionado__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SEG_ListaNegra__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SEG_ListaNegra__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SEG_Marca_de_un_cliente__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SEG_Marca_de_un_cliente__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SEG_MarcasCSO__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SEG_MarcasCSO__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SEG_Marcasdeuncaso__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SEG_Marcasdeuncaso__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SEG_MCCServiciosCSO__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SEG_MCCServiciosCSO__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SEG_Multivalor__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SEG_Multivalor__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SEG_NotasTipificadas__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SEG_NotasTipificadas__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SEG_Operacion__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SEG_Operacion__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SEG_Plantilla__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SEG_Plantilla__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SEG_Reclamaciones__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SEG_Reclamaciones__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SEG_Regladeclasificacion__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SEG_Regladeclasificacion__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SEG_Reglas_inconsitentes__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SEG_Reglas_inconsitentes__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SEG_ServiciosCSO__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SEG_ServiciosCSO__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SEG_UsuariosCSO__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SEG_UsuariosCSO__c.getRecordTypeInfosByDeveloperName());
                    }
                    when else {
                        mapObjectRT.put(objeto,Schema.getGlobalDescribe().get(objeto).getDescribe().getRecordTypeInfosByDeveloperName());
                    }
                }
            }
        }
        return mapObjectRT;
    }
}