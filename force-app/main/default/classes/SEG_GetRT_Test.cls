@isTest
public class SEG_GetRT_Test {
    @isTest
    static void testGetRecordTypesObjects() {
        // Set up test data
        Set<String> setObjetos = new Set<String>{ 'Case', 'Account', 'Contact','Task','CC_Canal_Com__c','CC_Caracteristica__c','CC_Grupo_Colaborador__c','SEG_Auditoria__c','SEG_ClasificacionRapida__c','SEG_Contratos__c','SEG_CRNotasTipificadas__c','SEG_Duplicate_Case__c','SEG_Excepciones__c','SEG_Excepciones_Caso__c','SEG_Excepciones_Centro__c','SEG_Excepciones_CR__c','SEG_Excepciones_Empresa__c','SEG_Excepciones_Grupo__c','SEG_Excepciones_Grupo_Empresa__c','SEG_ExcepcionesCentro__c','SEG_ExcepcionesCR__c','SEG_ExcepcionesEmpresa__c','SEG_ExcepcionesGrupo__c','SEG_ExcepcionesGrupoEmpresa__c','SEG_Fotosdefacturacion__c','SEG_Gestor_Grupo__c','SEG_Grupos_por_caso__c','SEG_GruposCSO__c','SEG_GruposServiciosCSO__c','SEG_GrupoTrabajoRelacionado__c','SEG_ListaNegra__c','SEG_Marca_de_un_cliente__c','SEG_MarcasCSO__c','SEG_Marcasdeuncaso__c','SEG_MCCServiciosCSO__c','SEG_Multivalor__c','SEG_NotasTipificadas__c','SEG_Operacion__c','SEG_Plantilla__c','SEG_Reclamaciones__c','SEG_Regladeclasificacion__c','SEG_Reglas_inconsitentes__c','SEG_ServiciosCSO__c','SEG_UsuariosCSO__c'};

        // Call the method being tested
        Map<String, Map<String, Schema.RecordTypeInfo>> result = SEG_GetRT.getRecordTypesObjects(setObjetos);

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            // Verify the results
            System.assertEquals(true, result.containsKey('Case'), 'No se ha obtenido el recordType');
            System.assertEquals(true, result.containsKey('Account'), 'No se ha obtenido el recordType');
            System.assertEquals(true, result.containsKey('Contact'), 'No se ha obtenido el recordType');
        }
    }
}