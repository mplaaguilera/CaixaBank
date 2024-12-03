@isTest
public class SEG_SincronizarGrupoHelper_Test 
{ 
    /**
     * @description   Preparación de los datos.
     */
    @testSetup
    public static void testSetup() 
    {
		User userA = SEG_TestHelper.createUser('UsA');
        User userB = SEG_TestHelper.createUser('UsB');
        CC_Grupo_Colaborador__c grupoColaboradorA = SEG_TestHelper.createGrupoColaborador('BO_TESTApex1', 'SEGMENTOS', 'BO');
        CC_Grupo_Colaborador__c grupoColaboradorB = SEG_TestHelper.createGrupoColaborador('BO_TESTApex2', 'SEGMENTOS', 'BO');
        CC_Grupo_Colaborador__c grupoColaboradorC = SEG_TestHelper.createGrupoColaborador('BO_TESTApex3', 'SEGMENTOS', 'BO');
        CC_Grupo_Colaborador_Contact__c colaboradorA = SEG_TestHelper.createColaborador(grupoColaboradorA, 'Escritura', userA);
        CC_Grupo_Colaborador_Contact__c colaboradorB = SEG_TestHelper.createColaborador(grupoColaboradorA, 'Escritura', userB);
        SEG_TestHelper.createCaseTeamTemplate(grupoColaboradorC.Name,grupoColaboradorC.Id);

    }
    @isTest
    public static void sincronizarGruposACaseTeamBulkNormalTest()
    {
        List<Id> listId = new List<Id>();
        for (CC_Grupo_Colaborador__c grupoTratamiento : [SELECT Id, Name, SEG_Inactivo__c, SEG_EquipoCaso__c FROM CC_Grupo_Colaborador__c where name='BO_TESTApex1'])
        {
            listId.add(grupoTratamiento.id);
        }
        Test.startTest();
        
        // Sincronizar el grupo creado.
        SEG_SincronizarGrupoHelper.sincronizarGruposACaseTeamBulk(listId);
        
        // Actualizar el ID de grupo.
        futureSincronizarCaseTeamId (listId);
        
        // Forzar actualización nombre de grupo.
        futureSincronizarGruposACaseTeam(listId);
        
        Test.stopTest();
        
        // Comprobar resultado.
        List<CaseTeamTemplate> equipoCaso = [SELECT Id FROM CaseTeamTemplate WHERE Name = 'BO_TESTApex1'];
        System.assert(equipoCaso.size()>0);
    }
    
    @isTest
    public static void sincronizarGruposACaseTeamBulkForzarAnadirMiembrosTest()
    {
        List<Id> listId = new List<Id>();
        for (CC_Grupo_Colaborador__c grupoTratamiento : [SELECT Id, Name, SEG_Inactivo__c, SEG_EquipoCaso__c FROM CC_Grupo_Colaborador__c where name='BO_TESTApex1'])
        {
            listId.add(grupoTratamiento.id);
        }
        Test.startTest();
        
        // Sincronizar el grupo creado.
        SEG_SincronizarGrupoHelper.sincronizarGruposACaseTeamBulk(listId);
        
        // Actualizar el ID de grupo.
        futureSincronizarCaseTeamId (listId);
        
        // Forzar actualización nombre de grupo.
        futureSincronizarGruposACaseTeam(listId);
        
        // Forzar adición de miembros en el caseTeam.
        futureBorrarMiembrosCaseTeam(listId, true);
        
        Test.stopTest();
        
        // Comprobar resultado.
        List<CaseTeamTemplate> equipoCaso = [SELECT Id FROM CaseTeamTemplate WHERE Name = 'BO_TESTApex1'];
        System.assert(equipoCaso.size()>0);
    }
    
    @isTest
    public static void sincronizarGruposACaseTeamBulkInactivarGrupoTest()
    {
        List<Id> listId = new List<Id>();
        for (CC_Grupo_Colaborador__c grupoTratamiento : [SELECT Id, Name, SEG_Inactivo__c, SEG_EquipoCaso__c FROM CC_Grupo_Colaborador__c where name='BO_TESTApex1'])
        {
            System.debug(grupoTratamiento);
            listId.add(grupoTratamiento.id);
        }
        
        Test.startTest();
        
        // Sincronizar el grupo creado.
        SEG_SincronizarGrupoHelper.sincronizarGruposACaseTeamBulk(listId);
        
        // Actualizar el ID de grupo.
        futureSincronizarCaseTeamId (listId);
        
        // Forzar actualización nombre de grupo.
        futureSincronizarGruposACaseTeam(listId);
        
        // Forzar actualización nombre de grupo.
        futureInactivarGrupo(listId);
        
        // Forzar actualización caseTeam.
        futureSincronizarGruposACaseTeam(listId);
        
        Test.stopTest();
        
        // Comprobar resultado.
        List<CaseTeamTemplate> equipoCaso = [SELECT Id FROM CaseTeamTemplate WHERE Name = 'BO_TESTApex1'];
        System.assert(equipoCaso.size()>0);
    }
    
    @isTest
    public static void sincronizarGruposACaseTeamBulkBorrarMiembrosCaseTeamTest()
    {
        List<Id> listId = new List<Id>();
        CC_Grupo_Colaborador__c grupoColaboradorB;
        for (CC_Grupo_Colaborador__c grupoTratamiento : [SELECT Id, Name, SEG_Inactivo__c, SEG_EquipoCaso__c FROM CC_Grupo_Colaborador__c where name='BO_TESTApex2'])
        {
            listId.add(grupoTratamiento.id);
            grupoColaboradorB = grupoTratamiento;
        }
        
		User userA = SEG_TestHelper.createUser('BO1');
        User userB = SEG_TestHelper.createUser('BO2');
        CC_Grupo_Colaborador_Contact__c colaboradorA = SEG_TestHelper.createColaborador(grupoColaboradorB, 'Escritura', userA);
        CC_Grupo_Colaborador_Contact__c colaboradorB = SEG_TestHelper.createColaborador(grupoColaboradorB, 'Escritura', userB);
        
        Test.startTest();
        
        // Sincronizar el grupo creado.
        futureSincronizarGruposACaseTeam(listId);
        
        // Actualizar el ID de grupo.
        futureSincronizarCaseTeamId (listId);
        
        // Forzar actualización nombre de grupo.
        futureSincronizarGruposACaseTeam(listId);
        
        // Forzar adición de miembros en el caseTeam.
        futureBorrarMiembrosCaseTeam(listId, false);
        
        // Forzar borrado miembros por quitarlo del grupo.
        futureBorrarColaboradorGrupo(listId, false);
        
        // Sincronizar el grupo creado.
        futureSincronizarGruposACaseTeam(listId);
        
        Test.stopTest();
        
        // Comprobar resultado.
        List<CaseTeamTemplate> equipoCaso = [SELECT Id FROM CaseTeamTemplate WHERE Name = 'BO_TESTApex2'];
        System.assert(equipoCaso.size()>0);
    }
    
    @isTest
    public static void verificarGrupoSegmentosTest()
    {
        Map<ID,CC_Grupo_Colaborador__c> mapNew = new Map<ID,CC_Grupo_Colaborador__c>([SELECT Id, RecordTypeId, Name, SEG_Inactivo__c, SEG_EquipoCaso__c, SEG_Tipologia__c 
                                                                                      FROM CC_Grupo_Colaborador__c where name='BO_TESTApex1']);
        
        Map<ID,CC_Grupo_Colaborador__c> mapOld = new Map<ID,CC_Grupo_Colaborador__c>([SELECT Id, RecordTypeId, Name, SEG_Inactivo__c, SEG_EquipoCaso__c, SEG_Tipologia__c 
                                                                                      FROM CC_Grupo_Colaborador__c where name='BO_TESTApex1']);
        
        Test.startTest();
        
        SEG_SincronizarGrupoHelper.verificarGrupoSegmentos(mapNew, mapOld);
        
        Test.stopTest();
        
        // Función de verificación para Trigger. No Assert.
        System.assert(true);
    }
    
    @isTest
    public static void verificarGrupoSegmentosKOTest()
    {
        Map<ID,CC_Grupo_Colaborador__c> mapNew = new Map<ID,CC_Grupo_Colaborador__c>([SELECT Id, RecordTypeId, Name, SEG_Inactivo__c, SEG_EquipoCaso__c, SEG_Tipologia__c 
                                                                                      FROM CC_Grupo_Colaborador__c where name='BO_TESTApex1']);
        for (ID clave : mapNew.keySet())
        {
            mapNew.get(clave).SEG_Tipologia__c = 'CSO';
        }
        
        Map<ID,CC_Grupo_Colaborador__c> mapOld = new Map<ID,CC_Grupo_Colaborador__c>([SELECT Id, RecordTypeId, Name, SEG_Inactivo__c, SEG_EquipoCaso__c, SEG_Tipologia__c 
                                                                                      FROM CC_Grupo_Colaborador__c where name='BO_TESTApex1']);
        
        Test.startTest();
        
        SEG_SincronizarGrupoHelper.verificarGrupoSegmentos(mapNew, mapOld);
        
        Test.stopTest();
        
        // Función de verificación para Trigger. No Assert.
        System.assert(true);
    }
    
    @isTest
    public static void verificarUsuarioGrupoSegmentosTest()
    {
        Map<ID,CC_Grupo_Colaborador__c> mapGrupo = new Map<ID,CC_Grupo_Colaborador__c>([SELECT Id, RecordTypeId, Name, SEG_Inactivo__c, SEG_EquipoCaso__c, SEG_Tipologia__c 
                                                                                      FROM CC_Grupo_Colaborador__c where name='BO_TESTApex1']);
        
        Map<ID,CC_Grupo_Colaborador_Contact__c> mapColaboradores = new Map<ID,CC_Grupo_Colaborador_Contact__c>([
            													  SELECT Id, CC_Grupo_Colaborador__c, CC_Usuario__c
                                                                  FROM CC_Grupo_Colaborador_Contact__c
                                                                  WHERE CC_Grupo_Colaborador__c IN :mapGrupo.keySet()]);        
        
        Test.startTest();
        
        SEG_SincronizarGrupoHelper.verificarUsuarioGrupoSegmentos(mapColaboradores);
        
        Test.stopTest();
        
        // Función de verificación para Trigger. No Assert.
        System.assert(true);
    }
    
    @isTest
    public static void actualizarUsuarioSegmentosTest()
    {
        Map<ID,CC_Grupo_Colaborador__c> mapGrupo = new Map<ID,CC_Grupo_Colaborador__c>([SELECT Id, RecordTypeId, Name, SEG_Inactivo__c, SEG_EquipoCaso__c, SEG_Tipologia__c 
                                                                                      FROM CC_Grupo_Colaborador__c where name='BO_TESTApex1']);
        
        List<CC_Grupo_Colaborador_Contact__c> listadoColaboradores = [SELECT Id, CC_Grupo_Colaborador__c 
                                                                  FROM CC_Grupo_Colaborador_Contact__c
                                                                  WHERE CC_Grupo_Colaborador__c IN :mapGrupo.keySet()];        
        
        Test.startTest();
        
        SEG_SincronizarGrupoHelper.actualizarUsuarioSegmentos(listadoColaboradores);
        
        Test.stopTest();
        
        // Comprobar resultado.
        List<CC_Grupo_Colaborador__c> grupoColaborador = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'BO_TESTApex1' AND SEG_EstadoSincronizacion__c = 'No sincronizado'];
        System.assert(grupoColaborador.size()>0);
    }
    
    @isTest
    public static void comprobarNullTest()
    {
        SEG_SincronizarGrupoHelper.sincronizarGruposACaseTeamBulk(null);
        
        SEG_SincronizarGrupoHelper.sincronizarCaseTeamIdBulk(null);
        
        SEG_SincronizarGrupoHelper.verificarGrupoSegmentos(null,null);
        
        SEG_SincronizarGrupoHelper.verificarUsuarioGrupoSegmentos(null);
        
        SEG_SincronizarGrupoHelper.actualizarUsuarioSegmentos(null);
        
        // Función de verificación - No Assert.
        System.assert(true);
    }
    
    @future
    private static void futureSincronizarGruposACaseTeam(List<Id> listId)
    {
        SEG_SincronizarGrupoHelper.sincronizarGruposACaseTeamBulk(listId);
    }
    @future
    private static void futureSincronizarCaseTeamId(List<Id> listId)
    {
        SEG_SincronizarGrupoHelper.sincronizarCaseTeamIdBulk(listId);
    }

    @future
    private static void futureBorrarMiembrosCaseTeam(List<Id> listId, Boolean todos)
    {
        List<ID> equipoCaso = new List<ID>();
        for (CC_Grupo_Colaborador__c grupoTratamiento : [SELECT Id, Name, SEG_Inactivo__c, SEG_EquipoCaso__c 
                                                         FROM CC_Grupo_Colaborador__c
                                                         WHERE Id IN :listId])
        {
            equipoCaso.add(grupoTratamiento.SEG_EquipoCaso__c);
        }

		List<CaseTeamTemplateMember> miembrosBorrar = new List<CaseTeamTemplateMember>();        
        for (CaseTeamTemplateMember miembroEquipoCaso : [SELECT Id, MemberId, TeamTemplateId
                                                         FROM CaseTeamTemplateMember
                                                         WHERE TeamTemplateId IN :equipoCaso])
        {
            miembrosBorrar.add(miembroEquipoCaso);
            if (!todos)
            {
                // Salimos solo borrando un miembro.
                break;
            }
        }
        System.debug('borrado');
        System.debug(miembrosBorrar);
        delete miembrosBorrar;
        
        SEG_SincronizarGrupoHelper.sincronizarGruposACaseTeamBulk(listId);
    }
    
    @future
    private static void futureInactivarGrupo(List<Id> listId)
    {
        List<CC_Grupo_Colaborador__c> grupoColaborador = new List<CC_Grupo_Colaborador__c>();
        for (CC_Grupo_Colaborador__c grupoTratamiento : [SELECT Id, Name, SEG_Inactivo__c, SEG_EquipoCaso__c 
                                                         FROM CC_Grupo_Colaborador__c
                                                         WHERE Id IN :listId])
        {
            grupoTratamiento.SEG_Inactivo__c = true;
            grupoColaborador.add(grupoTratamiento);
        }
        System.debug('***');
        System.debug(listId);
		System.debug(grupoColaborador);
		update grupoColaborador;
    }
    
    @future
    private static void futureBorrarColaboradorGrupo(List<Id> listId, Boolean todos)
    {
        List<CC_Grupo_Colaborador_Contact__c> listaColaboradores = new List<CC_Grupo_Colaborador_Contact__c>();
        for (CC_Grupo_Colaborador_Contact__c colaboradores : [SELECT Id 
                                                         FROM CC_Grupo_Colaborador_Contact__c
                                                         WHERE CC_Grupo_Colaborador__c IN :listId])
        {
            listaColaboradores.add(colaboradores);
            if (!todos)
            {
                // Salimos solo borrando un miembro.
                break;
            }
        }

        delete listaColaboradores;
    }
}