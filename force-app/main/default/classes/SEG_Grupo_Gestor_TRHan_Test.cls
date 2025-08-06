@isTest
public class SEG_Grupo_Gestor_TRHan_Test {
    @testSetup
    public static void testSetup() {

        Id grupoOpSegId = Schema.SObjectType.CC_Grupo_Colaborador__c
            .getRecordTypeInfosByDeveloperName()
            .get('SEG_GrupoOperativoSegmentos')
            .getRecordTypeId();

        CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
        grupoColab.Name = 'GrupoColabSeg';
        grupoColab.SEG_Tipologia__c = 'BO';
        grupoColab.RecordTypeId = grupoOpSegId;
        insert grupoColab;

        Contact contactoSEG1 = new Contact();
        contactoSEG1.RecordTypeId = Schema.SObjectType.Contact
            .getRecordTypeInfosByDeveloperName()
            .get('CC_Empleado')
            .getRecordTypeId();
        contactoSEG1.LastName = 'Contacto SEG 1';
        insert contactoSEG1;

        User thisUser;
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Profile perfil = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            UserRole rol = [SELECT Id FROM UserRole WHERE Name='Segmentos + FFEE'];
            thisUser = new User(alias = 'tsegmen', email='testSEGBI@acme.com',
                emailencodingkey='UTF-8', lastname='Smith',
                languagelocalekey='en_US',
                localesidkey='en_US', profileid = perfil.Id, userroleid = rol.Id,
                timezonesidkey='America/Los_Angeles',
                username='testSEGBI@acme.com');
            insert thisUser;
            List<PermissionSetAssignment> listPermissionSetAssignment = new List<PermissionSetAssignment>();
            for (PermissionSetGroupComponent permisoUnitario : [SELECT Id, PermissionSetGroupId, PermissionSetId, PermissionSet.Name FROM PermissionSetGroupComponent WHERE PermissionSetGroup.DeveloperName IN ('SEG_Operativo','SEG_Supervisor')]){
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

    @isTest
    static void testGrupoGestorBIyBU() {
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        
        CC_Grupo_Colaborador__c grupoColab = [SELECT Id FROM CC_Grupo_Colaborador__c LIMIT 1];
        Contact contactoSEG1 = [SELECT Id FROM Contact LIMIT 1];
        
        SEG_Gestor_Grupo__c gestorDeGrupo = new SEG_Gestor_Grupo__c();
        gestorDeGrupo.SEG_GrupoOperativa__c = grupoColab.Id;
        gestorDeGrupo.SEG_EmpleadoGestor__c = contactoSEG1.Id;
        
        System.runAs (usuarioTest) {
            Test.startTest();
            insert gestorDeGrupo;
            Test.stopTest();
        }
        
        SEG_Gestor_Grupo__c gestorDeGrupoInsertado = [SELECT Id, SEG_EmpleadoGestor__c, SEG_IDGestor__c FROM SEG_Gestor_Grupo__c LIMIT 1];
		System.assertEquals(String.valueOf(gestorDeGrupo.SEG_EmpleadoGestor__c).left(15),gestorDeGrupoInsertado.SEG_IDGestor__c,'No se ha rellenado el SEG_IDGestor__c');
		
        gestorDeGrupoInsertado.SEG_EmpleadoGestor__c = null;
        update gestorDeGrupoInsertado;
        
        SEG_Gestor_Grupo__c gestorDeGrupoActualizado = [SELECT Id, SEG_EmpleadoGestor__c, SEG_IDGestor__c FROM SEG_Gestor_Grupo__c LIMIT 1];
		System.assertEquals(null,gestorDeGrupoActualizado.SEG_IDGestor__c,'No se ha blanqueado el SEG_IDGestor__c');
        
        gestorDeGrupoInsertado.SEG_EmpleadoGestor__c = contactoSEG1.Id;
        update gestorDeGrupoInsertado;
        
        SEG_Gestor_Grupo__c gestorDeGrupoRellenado = [SELECT Id, SEG_EmpleadoGestor__c, SEG_IDGestor__c FROM SEG_Gestor_Grupo__c LIMIT 1];
		System.assertEquals(String.valueOf(gestorDeGrupo.SEG_EmpleadoGestor__c).left(15),gestorDeGrupoRellenado.SEG_IDGestor__c,'No se ha rellenado el SEG_IDGestor__c en el update');
    }
}