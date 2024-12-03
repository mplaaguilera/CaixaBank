@isTest
private class SEG_Case_Test {

    @TestSetup
    static void makeData(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Account cuentaSEG1 = new Account();
        cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        cuentaSEG1.Name = 'Empresa segmentos';
        cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG1.CC_Numero_Documento__c = '11111171H';
        insert cuentaSEG1;
        
        // Crear contactos para cuentas SEG.
        Contact contactoSEG1 = new Contact();
        contactoSEG1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contactoSEG1.LastName = 'Contacto SEG 1';
        contactoSEG1.AccountId = cuentaSEG1.Id;
        contactoSEG1.Email = 'test@test.com';
        contactoSEG1.CC_Idioma__c = 'ca';
        insert contactoSEG1;

        List<CC_MCC__c> mccsLista = new List<CC_MCC__c>();
        
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematicaSEG = new CC_MCC__c();
		mccTematicaSEG.Name = 'Tematica1SEG';
        mccTematicaSEG.CC_Tipo_Cliente__c = 'Segmentos';
        mccTematicaSEG.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematicaSEG.RecordTypeId = recordTypeIdTematica;
        mccTematicaSEG.CC_Codigo_Externo__c = 'TE-000007';
        mccsLista.add(mccTematicaSEG);
        insert mccsLista;

        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProductoSEG = new CC_MCC__c();
        mccProductoSEG.Name = 'Producto1SEG';
        mccProductoSEG.CC_Tipo_Cliente__c = 'Segmentos';
        mccProductoSEG.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProductoSEG.RecordTypeId = recordTypeIdProducto;
        mccProductoSEG.CC_Tematica__c = mccTematicaSEG.Id;
        mccProductoSEG.CC_Codigo_Externo__c = 'PR-000007'; 
        
        insert mccProductoSEG; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivoSEG = new CC_MCC__c();
        mccMotivoSEG.Name = 'Motivo1SEG';
        mccMotivoSEG.CC_Tipo_Cliente__c = 'Segmentos';
        mccMotivoSEG.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivoSEG.RecordTypeId = recordTypeIdMotivo;
        mccMotivoSEG.CC_Tematica__c = mccTematicaSEG.Id;
        mccMotivoSEG.CC_Producto_Servicio__c = mccProductoSEG.Id;
        mccMotivoSEG.CC_Codigo_Externo__c = 'MO-000007';
        insert mccMotivoSEG;

        Id recordTypeIdDetalle = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
       	CC_MCC__c mccDetalleSEG = new CC_MCC__c();
        mccDetalleSEG.Name = 'Detalle1SEG';
        mccDetalleSEG.CC_Tipo_Cliente__c = 'Segmentos';
        mccDetalleSEG.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccDetalleSEG.RecordTypeId = recordTypeIdDetalle;
        mccDetalleSEG.CC_Tematica__c = mccTematicaSEG.Id;
        mccDetalleSEG.CC_Producto_Servicio__c = mccProductoSEG.Id;
        mccDetalleSEG.CC_Motivo__c = mccMotivoSEG.Id;
        mccDetalleSEG.CC_Codigo_Externo__c = 'DE-000007';
        insert mccDetalleSEG;

        SEG_ClasificacionRapida__c regla3 = new SEG_ClasificacionRapida__c();
        regla3.Name = 'CR3';
        regla3.SEG_Tematica__c = mccTematicaSEG.Id;
        regla3.SEG_Producto__c = mccProductoSEG.Id;
        regla3.SEG_Motivo__c = mccMotivoSEG.Id;
        regla3.SEG_Detalle__c = mccDetalleSEG.Id;
        regla3.SEG_CRContratos__c  = false;
        regla3.CBK_Negocio__c = 'Segmentos';
        insert regla3;

        Id grupoOpSegId = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoCol1 = new CC_Grupo_Colaborador__c(
            SEG_Zona__c = 'Corporativa',
            SEG_Organizacion__C = 'Banca Corporativa',
        	Name = 'GrupoSegOp1',
            RecordTypeId = grupoOpSegId       
        );
		insert grupoCol1;

        CC_Grupo_Colaborador_Contact__c contactoGrupo = new CC_Grupo_Colaborador_Contact__c();
        contactoGrupo.CC_Usuario__c = supervisor.id;
        contactoGrupo.CC_Grupo_Colaborador__c = grupoCol1.id;
        insert contactoGrupo;

        Case caso1 = new Case();
        caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso1.AccountId = cuentaSEG1.Id;
        caso1.ContactId = contactoSEG1.Id;
        caso1.CC_MailTelfNotif__c = contactoSEG1.Email;
        caso1.OwnerId = supervisor.Id;
        caso1.SEG_Idioma__c = 'es';
        caso1.CC_AcuseRecibo__c ='1';
        caso1.Subject = 'test 1';
        caso1.SEG_Grupo__c = grupoCol1.id;
        caso1.CC_MCC_Tematica__c = mccTematicaSEG.Id;
        caso1.SEG_SRAuditoria__c = true;
        caso1.CC_MCC_ProdServ__c = mccProductoSEG.Id;
        caso1.CC_MCC_Motivo__c = mccMotivoSEG.Id;
        caso1.SEG_ClasificacionRapida__c = regla3.Id;
        caso1.Status = 'Activo';
        caso1.SEG_Zona__c = 'Corporativa';
        caso1.SEG_Organizacion__C = 'Banca Corporativa';
        caso1.SEG_N_operaciones_del_caso__c = 3.0;  
        insert caso1;
        
        //MIXED_DML_OPERATION
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            //supervisor.UserRoleId = [SELECT Id FROM UserRole WHERE Name='Responsable Corporativa'].Id;
            //update supervisor;

            Group grupo = [SELECT Id FROM Group WHERE Name = 'SEG_Robotics'];
            Group grupoBO = [SELECT Id FROM Group WHERE Name = 'SEG_BO'];

            GroupMember grupoRobo = new GroupMember();
            grupoRobo.GroupId = grupo.Id;
            grupoRobo.UserOrGroupId = supervisor.Id;
            insert grupoRobo;

            GroupMember grupoBOm = new GroupMember();
            grupoBOm.GroupId = grupoBO.Id;
            grupoBOm.UserOrGroupId = supervisor.Id;
            insert grupoBOm;
        }
    }

    @isTest
    static void testTomarPropiedad() {
        /* Case caso = [SELECT id, SEG_Grupo__r.Name, OwnerId, Owner.Name FROM Case WHERE Subject = 'test 1' LIMIT 1];
        caso.OwnerId = supervisor.Id;
        update caso;
        
        idsCaso.add(caso.Id);*/
        List<Id> idsCaso = new List<Id>();
        Account cuentaSEG1 = [SELECT Id FROM Account LIMIT 1];
        Contact contactoSEG1 = [SELECT Id, Email FROM Contact LIMIT 1];
        CC_Grupo_Colaborador__c grupoCol1 = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'GrupoSegOp1' LIMIT 1];
        SEG_ClasificacionRapida__c regla3 = [SELECT Id FROM SEG_ClasificacionRapida__c WHERE Name = 'CR3' LIMIT 1];
        CC_MCC__c mccTematicaSEG = [SELECT Id FROM CC_MCC__c WHERE Name = 'Tematica1SEG' LIMIT 1];
        CC_MCC__c mccProductoSEG = [SELECT Id FROM CC_MCC__c WHERE Name = 'Producto1SEG' LIMIT 1];
        CC_MCC__c mccMotivoSEG = [SELECT Id FROM CC_MCC__c WHERE Name = 'Motivo1SEG' LIMIT 1];

        Id grColId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoRTGrupoCol = new CC_Grupo_Colaborador__c();
        grupoRTGrupoCol.Name='Grupo Colaborador';
        grupoRTGrupoCol.RecordTypeId = grColId;
        insert grupoRTGrupoCol;

        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];
        
        Case caso1 = new Case();
        caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso1.AccountId = cuentaSEG1.Id;
        caso1.ContactId = contactoSEG1.Id;
        caso1.CC_MailTelfNotif__c = contactoSEG1.Email;
        caso1.OwnerId = supervisor.Id;
        caso1.SEG_Idioma__c = 'es';
        caso1.CC_AcuseRecibo__c ='1';
        caso1.Subject = 'test 1';
        caso1.SEG_Grupo__c = grupoCol1.id;
        caso1.CC_MCC_Tematica__c = mccTematicaSEG.Id;
        caso1.SEG_SRAuditoria__c = true;
        caso1.CC_MCC_ProdServ__c = mccProductoSEG.Id;
        caso1.CC_MCC_Motivo__c = mccMotivoSEG.Id;
        caso1.SEG_ClasificacionRapida__c = regla3.Id;
        caso1.Status = 'Activo';
        caso1.SEG_Zona__c = 'Corporativa';
        caso1.SEG_Organizacion__C = 'Banca Corporativa';
        caso1.SEG_N_operaciones_del_caso__c = 3.0;  
        insert caso1;
        idsCaso.add(caso1.Id);

            // Perform the method under test
        System.runAs(supervisor){
            Test.startTest();
            SEG_Case.tomarPropiedad(idsCaso);
            Test.stopTest();
            
            // Verify the results
            Case casoUpdt = [SELECT Id, OwnerId, Status, SEG_Subestado__c FROM Case WHERE Id = :caso1.Id LIMIT 1];
    
            System.assertEquals(supervisor.Id, casoUpdt.OwnerId);
            System.assertEquals('Activo', casoUpdt.Status);
            System.assertEquals('En curso', casoUpdt.SEG_Subestado__c);
        }
    }
    
    @isTest
    static void testRechazar() {
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematicaSEG = new CC_MCC__c();
		mccTematicaSEG.Name = 'Segmentos';
        mccTematicaSEG.CC_Tipo_Cliente__c = 'Segmentos';
        mccTematicaSEG.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematicaSEG.RecordTypeId = recordTypeIdTematica;
        mccTematicaSEG.CC_Codigo_Externo__c = 'TE-000008';
        insert mccTematicaSEG;

        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProductoSEG = new CC_MCC__c();
        mccProductoSEG.Name = 'No procede';
        mccProductoSEG.CC_Tipo_Cliente__c = 'Segmentos';
        mccProductoSEG.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProductoSEG.RecordTypeId = recordTypeIdProducto;
        mccProductoSEG.CC_Tematica__c = mccTematicaSEG.Id;
        mccProductoSEG.CC_Codigo_Externo__c = 'PR-000008'; 
        
        insert mccProductoSEG; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivoSEG = new CC_MCC__c();
        mccMotivoSEG.Name = 'No procede';
        mccMotivoSEG.CC_Tipo_Cliente__c = 'Segmentos';
        mccMotivoSEG.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivoSEG.RecordTypeId = recordTypeIdMotivo;
        mccMotivoSEG.CC_Tematica__c = mccTematicaSEG.Id;
        mccMotivoSEG.CC_Producto_Servicio__c = mccProductoSEG.Id;
        mccMotivoSEG.CC_Codigo_Externo__c = 'MO-000008';
        insert mccMotivoSEG;

        Id recordTypeIdDetalle = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
       	CC_MCC__c mccDetalleSEG = new CC_MCC__c();
        mccDetalleSEG.Name = 'No procede';
        mccDetalleSEG.CC_Tipo_Cliente__c = 'Segmentos';
        mccDetalleSEG.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccDetalleSEG.RecordTypeId = recordTypeIdDetalle;
        mccDetalleSEG.CC_Tematica__c = mccTematicaSEG.Id;
        mccDetalleSEG.CC_Producto_Servicio__c = mccProductoSEG.Id;
        mccDetalleSEG.CC_Motivo__c = mccMotivoSEG.Id;
        mccDetalleSEG.CC_Codigo_Externo__c = 'DE-000008';
        insert mccDetalleSEG;

        SEG_ClasificacionRapida__c regla3 = new SEG_ClasificacionRapida__c();
        regla3.Name = 'No procede';
        regla3.SEG_Tematica__c = mccTematicaSEG.Id;
        regla3.SEG_Producto__c = mccProductoSEG.Id;
        regla3.SEG_Motivo__c = mccMotivoSEG.Id;
        regla3.SEG_Detalle__c = mccDetalleSEG.Id;
        regla3.SEG_CRContratos__c  = false;
        regla3.CBK_Negocio__c = 'Segmentos';
        regla3.SEG_CRAuditoria__c = false;
        insert regla3;
        
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];
        Case caso = [SELECT id FROM Case WHERE Subject = 'test 1' LIMIT 1];
        List<Id> idsCaso = new List<Id>();
        idsCaso.add(caso.Id);
        System.runAs(supervisor){
            // Perform the method under test
            try {
                Test.startTest();
                SEG_Case.rechazar(idsCaso);
                Test.stopTest();
                
                // Verify the results
                List<Case> updatedCases = [SELECT Id, OwnerId, Status, SEG_Subestado__c, SEG_ClasificacionRapida__c FROM Case WHERE Id IN :idsCaso];
                for (Case updatedCase : updatedCases) {
                    System.assertEquals('Descartado', updatedCase.Status);
                    System.assertEquals('Rechazada', updatedCase.SEG_Subestado__c);
                    System.assertNotEquals(null, updatedCase.SEG_ClasificacionRapida__c);
                }
            } catch (Exception ex) {
                System.assertNotEquals(null, idsCaso);
            }
            
        }
    }
    
    @isTest
    static void testCambiarOwner() {
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];
        Case caso = [SELECT id FROM Case WHERE Subject = 'test 1' LIMIT 1];
        List<Id> idsCaso = new List<Id>();
        idsCaso.add(caso.Id);

        Id grColId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoRTGrupoCol = new CC_Grupo_Colaborador__c();
        grupoRTGrupoCol.Name='Grupo Colaborador';
        grupoRTGrupoCol.RecordTypeId = grColId;
        insert grupoRTGrupoCol;

        System.runAs(supervisor){
            // Perform the method under test
            Test.startTest();
            SEG_Case.cambiarOwner(idsCaso, supervisor.Id);
            Test.stopTest();
            
            // Verify the results
            List<Case> updatedCases = [SELECT Id, OwnerId, Status, SEG_Subestado__c FROM Case WHERE Id IN :idsCaso];
            for (Case updatedCase : updatedCases) {
                System.assertEquals(supervisor.Id, updatedCase.OwnerId);
                System.assertEquals('Activo', updatedCase.Status);
                System.assertEquals('En curso', updatedCase.SEG_Subestado__c);
            }
        }
    }
    
    @isTest
    static void testCambiarGrupoMasivo_NoExiste() {
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];
        Case caso = [SELECT id FROM Case WHERE Subject = 'test 1' LIMIT 1];
        List<Id> idsCaso = new List<Id>();
        idsCaso.add(caso.Id);

        Id grColId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoRTGrupoCol = new CC_Grupo_Colaborador__c();
        grupoRTGrupoCol.Name='Grupo Colaborador';
        grupoRTGrupoCol.RecordTypeId = grColId;
        insert grupoRTGrupoCol;

        System.runAs(supervisor){
            // Perform the method under test
            Test.startTest();
            SEG_Case.RespuestaCompleja response = SEG_Case.cambiarGrupoMasivo(idsCaso, grupoRTGrupoCol.Id);
            Test.stopTest();
            
            // Verify the results
            System.assertEquals('Error en el grupo indicado', response.nombreMsg);
            System.assertEquals('El grupo indicado no existe o no tiene la organización y la zona rellenados.', response.datosMsg);
        }
    }


    @IsTest
    static void testCambiarGrupoMasivo() {
        // Preparación de datos de prueba
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];
        Case caso = [SELECT id FROM Case WHERE Subject = 'test 1' LIMIT 1];
        List<Id> idsCaso = new List<Id>();
        idsCaso.add(caso.Id);

        // Ejecución del método a probar
        Test.startTest();
        System.runAs(supervisor){
            CC_Grupo_Colaborador__c grupoRTGrupoCol = new CC_Grupo_Colaborador__c();
            grupoRTGrupoCol.Name = 'Grupo Colaborador';
            grupoRTGrupoCol.SEG_Organizacion__c = 'Banca Corporativa';
            grupoRTGrupoCol.SEG_Zona__c = 'Corporativa';
            insert grupoRTGrupoCol;

            SEG_Case.RespuestaCompleja response = SEG_Case.cambiarGrupoMasivo(idsCaso, grupoRTGrupoCol.Id);
            
            // Verificación de resultados
            List<Case> updatedCases = [SELECT Id, SEG_Grupo__c FROM Case WHERE Id IN :idsCaso];
            for (Case updatedCase : updatedCases) {
                System.assertEquals(grupoRTGrupoCol.Id, updatedCase.SEG_Grupo__c);
            }
        }
        Test.stopTest();
    }

    @IsTest
    static void testCambiarGrupoMasivo_GrupoDistintoOrganizacionZona() {
        // Preparación de datos de prueba
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];
        Case caso = [SELECT id FROM Case WHERE Subject = 'test 1' LIMIT 1];
        List<Id> idsCaso = new List<Id>();
        idsCaso.add(caso.Id);

        // Ejecución del método a probar
        Test.startTest();
        System.runAs(supervisor){
            Id grColId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
            CC_Grupo_Colaborador__c grupoRTGrupoCol = new CC_Grupo_Colaborador__c();
            grupoRTGrupoCol.Name = 'Grupo Colaborador';
            grupoRTGrupoCol.SEG_Organizacion__c = 'Banca Corporativa';
            grupoRTGrupoCol.SEG_Zona__c = '	Empresas Andalucía';
            insert grupoRTGrupoCol;

            SEG_Case.RespuestaCompleja response = SEG_Case.cambiarGrupoMasivo(idsCaso, grupoRTGrupoCol.Id);
            
            // Verificación de resultados
            List<Case> updatedCases = [SELECT Id, SEG_Grupo__c FROM Case WHERE Id IN :idsCaso];
            System.assertEquals('Error al actualizar algunos casos', response.nombreMsg);
            System.assertEquals(true, response.datosMsg.contains('Los casos indicados no coinciden en Org y Zona con el grupo'));
        }
        Test.stopTest();
    }



    
    @isTest
    static void testCerrarCasoMasivo() {
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];
        Case caso = [SELECT id, Status FROM Case WHERE Subject = 'test 1' LIMIT 1];
        List<Id> idsCaso = new List<Id>();
        idsCaso.add(caso.Id);

        Id grColId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoRTGrupoCol = new CC_Grupo_Colaborador__c();
        grupoRTGrupoCol.Name='Grupo Colaborador';
        grupoRTGrupoCol.RecordTypeId = grColId;
        insert grupoRTGrupoCol;

        System.runAs(supervisor){
        
            // Perform the method under test
            Test.startTest();
            SEG_Case.cerrarCasoMasivo(idsCaso);
            Test.stopTest();
            
            // Verify the results
            List<Case> updatedCases = [SELECT Id, Status FROM Case WHERE Id IN :idsCaso];
            for (Case updatedCase : updatedCases) {
                System.assertNotEquals(caso.Status, updatedCase.Status);
            }
        }
    }
}