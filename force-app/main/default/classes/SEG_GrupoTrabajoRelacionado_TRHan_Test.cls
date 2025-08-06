@IsTest
public with sharing class SEG_GrupoTrabajoRelacionado_TRHan_Test {
    @testSetup
    static void testSetup() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Profile perfil = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            UserRole rol = [SELECT Id FROM UserRole WHERE Name='Sistemática Comercial'];
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = orgId + dateString + randomInt;
            User thisUser = new User(alias = 'user2', email='testSEGBI2@acme.com',
                emailencodingkey='UTF-8', lastname='Smith',
                languagelocalekey='en_US',
                localesidkey='en_US', profileid = perfil.Id, userroleid = rol.Id,
                timezonesidkey='America/Los_Angeles',
                Username = uniqueName + '@test' + orgId + '.org');
            insert thisUser;
            List<PermissionSetAssignment> listPermissionSetAssignment = new List<PermissionSetAssignment>();
            for (PermissionSetGroupComponent permisoUnitario : [SELECT Id, PermissionSetGroupId, PermissionSetId, PermissionSet.Name FROM PermissionSetGroupComponent WHERE PermissionSetGroup.DeveloperName IN ('CBK_Framework_Login','CBK_Framework_Admin')]){
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permisoUnitario.PermissionSetId;
                nuevoPermiso.AssigneeId = thisUser.id;
                listPermissionSetAssignment.add(nuevoPermiso);
            }
            if (listPermissionSetAssignment.isEmpty()){
                insert listPermissionSetAssignment;
            }
        }
    }

    @IsTest
    static void testActivacionGrupoRel() {
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE email = 'testSEGBI2@acme.com' LIMIT 1];

        Id opSegId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoOpSeg = new CC_Grupo_Colaborador__c();
		grupoOpSeg.RecordTypeId = opSegId;
		grupoOpSeg.SEG_GrupoSegmentos__c = true;
		grupoOpSeg.Name = 'Grupo de trabajo Operativo';
		insert grupoOpSeg;
        
        Id recordTypeMCC = Schema.SObjectType.SEG_ServiciosCSO__c.getRecordTypeInfosByDeveloperName().get('Marca').getRecordTypeId();
        SEG_ServiciosCSO__c servCsoMCC = new SEG_ServiciosCSO__c();
        servCsoMCC.SEG_Activo__c = true;
        servCsoMCC.RecordTypeId = recordTypeMCC;
        servCsoMCC.SEG_Organizacion__c = 'Banca Corporativa;Instituciones';
        servCsoMCC.SEG_Zona__c = 'Corporativa';
        servCsoMCC.SEG_TMO__c = 10;
        servCsoMCC.Name = 'Test MCC';
        insert servCsoMCC;
        
        Test.startTest();
        System.runAs(usuarioTest) { 

        // Crear datos de prueba
        List<SEG_GrupoTrabajoRelacionado__c> lstGrupoRel = new List<SEG_GrupoTrabajoRelacionado__c>();
        SEG_GrupoTrabajoRelacionado__c grupoRel1 = new SEG_GrupoTrabajoRelacionado__c(SEG_Activo__c = true, SEG_GrupoTrabajo__c = grupoOpSeg.Id, SEG_ServiciosCSO__c = servCsoMCC.Id);
        SEG_GrupoTrabajoRelacionado__c grupoRel2 = new SEG_GrupoTrabajoRelacionado__c(SEG_Activo__c = false);
       
        lstGrupoRel.add(grupoRel1);
        lstGrupoRel.add(grupoRel2);

        // Insertar datos de prueba
        insert lstGrupoRel;

        List<SEG_GrupoTrabajoRelacionado__c> grupoRelInsertados = new List<SEG_GrupoTrabajoRelacionado__c>();

        // Verificar que los campos SEG_FechaActivacion__c y SEG_FechaDesactivacion__c se han actualizado correctamente
        for (SEG_GrupoTrabajoRelacionado__c grupoRel : [SELECT SEG_Activo__c,SEG_FechaActivacion__c, SEG_FechaDesactivacion__c FROM SEG_GrupoTrabajoRelacionado__c WHERE Id IN :lstGrupoRel]) {
            if (grupoRel.SEG_Activo__c) {
                System.assertNotEquals(null, grupoRel.SEG_FechaActivacion__c, 'La fecha de activación no es la esperada');
                System.assertEquals(null, grupoRel.SEG_FechaDesactivacion__c, 'La fecha de desactivación no es la esperada');
                grupoRel.SEG_Activo__c = false;
            } else {
                System.assertEquals(null, grupoRel.SEG_FechaActivacion__c, 'La fecha de activación no es la esperada');
                System.assertNotEquals(null, grupoRel.SEG_FechaDesactivacion__c, 'La fecha de desactivación no es la esperada');
                grupoRel.SEG_Activo__c = true;
            }
            grupoRelInsertados.add(grupoRel);
        }

        update grupoRelInsertados;

        // Verificar que los campos SEG\_FechaActivacion\_\_c y SEG\_FechaDesactivacion\_\_c se han actualizado correctamente
    for (SEG_GrupoTrabajoRelacionado__c grupoRel : [SELECT SEG_Activo__c, SEG_FechaActivacion__c, SEG_FechaDesactivacion__c FROM SEG_GrupoTrabajoRelacionado__c WHERE Id IN :grupoRelInsertados]) {
        if (grupoRel.SEG_Activo__c) {
            System.assertNotEquals(null, grupoRel.SEG_FechaActivacion__c, 'La fecha de activación no es la esperada');
        } else {
            System.assertNotEquals(null, grupoRel.SEG_FechaDesactivacion__c, 'La fecha de desactivación no es la esperada');
        }
    }
}
}

            @IsTest
            static void testActivacionGrupoRelUpdate() {
                User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE email = 'testSEGBI2@acme.com' LIMIT 1];
              
                Id opSegId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
                CC_Grupo_Colaborador__c grupoOpSeg = new CC_Grupo_Colaborador__c();
                grupoOpSeg.RecordTypeId = opSegId;
                grupoOpSeg.SEG_GrupoSegmentos__c = true;
                grupoOpSeg.Name = 'Grupo de trabajo Operativo';
                insert grupoOpSeg;
                
                CC_Grupo_Colaborador__c grupoOpSeg2 = new CC_Grupo_Colaborador__c();
                grupoOpSeg2.RecordTypeId = opSegId;
                grupoOpSeg2.SEG_GrupoSegmentos__c = true;
                grupoOpSeg2.Name = 'Grupo de trabajo Operativo Dos';
                insert grupoOpSeg2;
                
                Id recordTypeMCC = Schema.SObjectType.SEG_ServiciosCSO__c.getRecordTypeInfosByDeveloperName().get('Marca').getRecordTypeId();
                SEG_ServiciosCSO__c servCsoMCC = new SEG_ServiciosCSO__c();
                servCsoMCC.SEG_Activo__c = true;
                servCsoMCC.RecordTypeId = recordTypeMCC;
                servCsoMCC.SEG_Organizacion__c = 'Banca Corporativa;Instituciones';
                servCsoMCC.SEG_Zona__c = 'Corporativa';
                servCsoMCC.SEG_TMO__c = 10;
                servCsoMCC.Name = 'Test MCC';
                insert servCsoMCC;
                
                SEG_GrupoTrabajoRelacionado__c grupoRel2 = new SEG_GrupoTrabajoRelacionado__c();
                grupoRel2.SEG_GrupoTrabajo__c = grupoOpSeg.Id;
                grupoRel2.SEG_ServiciosCSO__c = servCsoMCC.Id;
                // Insertar datos de prueba
                insert grupoRel2;
                
                Test.startTest();
                System.runAs(usuarioTest) { 
                    grupoRel2.SEG_GrupoTrabajo__c = grupoOpSeg2.Id;
                    update grupoRel2;}

                Test.stopTest();
                SEG_GrupoTrabajoRelacionado__c grupoRel = [SELECT SEG_GrupoTrabajoCSO__c, SEG_GrupoTrabajo__c, SEG_ServiciosCSO__c FROM SEG_GrupoTrabajoRelacionado__c LIMIT 1];
                System.assertEquals(grupoRel.SEG_GrupoTrabajoCSO__c, String.valueOf(grupoRel.SEG_GrupoTrabajo__c) + String.valueOf(grupoRel.SEG_ServiciosCSO__c), 'No se han concatenado los grupos y servicio.');
                }
}