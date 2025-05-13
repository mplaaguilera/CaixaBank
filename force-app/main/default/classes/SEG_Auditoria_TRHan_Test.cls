@isTest
public with sharing class SEG_Auditoria_TRHan_Test {
    @testSetup
    static void datosIniciales ()
    {
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

        Id recordTypeSEG = Schema.SObjectType.SEG_Auditoria__c.getRecordTypeInfosByDeveloperName().get('SEG_Auditorias').getRecordTypeId(); 
        Id recordDet = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
        Id grColId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        // Creación cuentas a tratar.
        Account cuentaSEG1 = new Account();
        cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        cuentaSEG1.Name = 'Empresa segmentos';
        cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG1.CC_Numero_Documento__c = '11111111H';
        insert cuentaSEG1;

        // Crear contactos para cuentas SEG.
        Contact contactoSEG1 = new Contact();
        contactoSEG1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contactoSEG1.LastName = 'Contacto SEG 1';
        contactoSEG1.AccountId = cuentaSEG1.Id;
        contactoSEG1.Email = 'test@test.com';
        insert contactoSEG1;
        
        CC_MCC__c mccDetalle3 = new CC_MCC__c();
        mccDetalle3.RecordTypeId = recordDet;
        mccDetalle3.Name = 'Detalle';
        mccDetalle3.CC_Tipo_Cliente__c = 'Cliente';
        mccDetalle3.CC_Codigo_Externo__c = 'DE-000003';
        insert mccDetalle3;  

        //Grupo Colaborador con RT Grupo Colaborador
        SEG_Plantilla__c plantilla = new SEG_Plantilla__C();
        plantilla.Name ='Plantilla Col';
        plantilla.SEG_TipoOperativa__c = 'Acuse de recibo';
        plantilla.SEG_PlantillaCastellanoID__c = plantilla.id;
        plantilla.SEG_Activa__c = true;
        insert plantilla;
        //Asignamos el RecordType ='Grupo Colaborador'
        CC_Grupo_Colaborador__c grupoRTGrupoCol = new CC_Grupo_Colaborador__c();
        grupoRTGrupoCol.Name='Grupo Colaborador';
        grupoRTGrupoCol.RecordTypeId = grColId;
        insert grupoRTGrupoCol;
        //Grupo MCC link Grupo Colaborador
        CC_MCC_Grupo_Colaborador__c  grupoCol = new CC_MCC_Grupo_Colaborador__c();
        grupoCol.Name='Colaborador';
        grupoCol.CC_MCC__c = mccDetalle3.Id; 
        grupoCol.CC_Grupo_Colaborador__c=grupoRTGrupoCol.id;
        grupoCol.SEG_Zona__c = 'Todas';
        grupoCol.SEG_Organizacion__c = 'Todas';
        insert grupoCol;
        //Creamos una plantilla para usar en RT = 'Grupo Colaborador'
        CC_Grupo_Colaborador_Plantilla__c plantillagrupo = new CC_Grupo_Colaborador_Plantilla__c();
        plantillagrupo.CC_Operativa__c= 'Trasladar';
        plantillagrupo.SEG_Plantilla__c=plantilla.id;
        plantillagrupo.CC_Grupo_Colaborador__c = grupoRTGrupoCol.id;
        insert plantillagrupo;


        Id recordTypeIdTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Tematica1';
        mccTematica.CC_Tipo_Cliente__c = 'Segmentos';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Producto1';
        mccProducto.CC_Tipo_Cliente__c = 'Segmentos';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Motivo1';
        mccMotivo.CC_Tipo_Cliente__c = 'Segmentos';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;

        Id recordTypeIdDetalle = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
       	CC_MCC__c mccDetalle = new CC_MCC__c();
        mccDetalle.Name = 'Detalle1';
        mccDetalle.CC_Tipo_Cliente__c = 'Segmentos';
        mccDetalle.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccDetalle.RecordTypeId = recordTypeIdDetalle;
        mccDetalle.CC_Tematica__c = mccTematica.Id;
        mccDetalle.CC_Producto_Servicio__c = mccProducto.Id;
        mccDetalle.CC_Motivo__c = mccMotivo.Id;
        mccDetalle.CC_Codigo_Externo__c = 'DE-000001';
        insert mccDetalle;

        CC_MCC__c mccTematica2 = new CC_MCC__c();
		mccTematica2.Name = 'Tematica2';
        mccTematica2.CC_Tipo_Cliente__c = 'Segmentos';
        mccTematica2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica2.RecordTypeId = recordTypeIdTematica;
        mccTematica2.CC_Codigo_Externo__c = 'TE-000002';
        insert mccTematica2;
        
        CC_MCC__c mccProducto2 = new CC_MCC__c();
        mccProducto2.Name = 'Producto2';
        mccProducto2.CC_Tipo_Cliente__c = 'Segmentos';
        mccProducto2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto2.RecordTypeId = recordTypeIdProducto;
        mccProducto2.CC_Tematica__c = mccTematica2.Id;
        mccProducto2.CC_Codigo_Externo__c = 'PR-000002'; 
        insert mccProducto2; 
        
       	CC_MCC__c mccMotivo2 = new CC_MCC__c();
        mccMotivo2.Name = 'Motivo2';
        mccMotivo2.CC_Tipo_Cliente__c = 'Segmentos';
        mccMotivo2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo2.RecordTypeId = recordTypeIdMotivo;
        mccMotivo2.CC_Tematica__c = mccTematica2.Id;
        mccMotivo2.CC_Producto_Servicio__c = mccProducto2.Id;
        mccMotivo2.CC_Codigo_Externo__c = 'MO-000002';
        insert mccMotivo2;

       	CC_MCC__c mccDetalle2 = new CC_MCC__c();
        mccDetalle2.Name = 'Detalle2';
        mccDetalle2.CC_Tipo_Cliente__c = 'Segmentos';
        mccDetalle2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccDetalle2.RecordTypeId = recordTypeIdDetalle;
        mccDetalle2.CC_Tematica__c = mccTematica2.Id;
        mccDetalle2.CC_Producto_Servicio__c = mccProducto2.Id;
        mccDetalle2.CC_Motivo__c = mccMotivo2.Id;
        mccDetalle2.CC_Codigo_Externo__c = 'DE-000002';
        insert mccDetalle2;

        SEG_ClasificacionRapida__c regla1 = new SEG_ClasificacionRapida__c();
        regla1.Name = 'CR1';
        regla1.SEG_Tematica__c = mccTematica.Id;
        regla1.SEG_Producto__c = mccProducto.Id;
        regla1.SEG_Motivo__c = mccMotivo.Id;
        regla1.SEG_Detalle__c = mccDetalle.Id;
        regla1.CBK_Negocio__c = 'Segmentos';
        insert regla1;

        SEG_ClasificacionRapida__c regla2 = new SEG_ClasificacionRapida__c();
        regla2.Name = 'CR2';
        regla2.SEG_Tematica__c = mccTematica2.Id;
        regla2.SEG_Producto__c = mccProducto2.Id;
        regla2.SEG_Motivo__c = mccMotivo2.Id;
        regla2.SEG_Detalle__c = mccDetalle2.Id;
        regla2.CBK_Negocio__c = 'Segmentos';
        insert regla2;
        
        //SLA START
        Account a = new Account();
        a.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        a.Name = 'account temp';
        insert a;
        
        Entitlement e = new Entitlement();
        e.Name = 'Entitlement SEG';
        //e.SlaProcessId = [SELECT Id FROM SlaProcess WHERE Name = 'SEG Entitlement Process' LIMIT 1].Id;
        e.AccountId = a.Id;
        e.BusinessHoursId = [SELECT Id FROM BusinessHours WHERE Name = 'Segmentos'].Id;
        e.StartDate = Date.today();
	    e.EndDate = Date.today();
        insert e;

        // Select an existing milestone type to test with
        List<MilestoneType> mtLst = [SELECT Name FROM MilestoneType WHERE Name = 'SEG SLA' LIMIT 1];      
        if (mtLst.isEmpty()) {
            return;
        }
        MilestoneType mt = mtLst[0];
        //SLA END
        
        // Crear casos de los clientes.
        List<Case> listadoCasos = new List<Case>();

        Case caso1 = new Case();
        caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso1.AccountId = cuentaSEG1.Id;
        caso1.ContactId = contactoSEG1.Id;
        caso1.CC_MailTelfNotif__c = contactoSEG1.Email;
        caso1.SEG_Idioma__c = 'en';
        caso1.CC_AcuseRecibo__c ='1';
        caso1.Subject = 'test 1';
        caso1.CC_MCC_Tematica__c = mccTematica.Id;
        caso1.CC_MCC_ProdServ__c = mccProducto.Id;
        caso1.CC_MCC_Motivo__c = mccMotivo.Id;
        caso1.Status = 'Pendiente';
        caso1.SEG_SRAuditoria__c = true;
        listadoCasos.add(caso1);
        
        Case caso2 = new Case();
        caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso2.AccountId = cuentaSEG1.Id;
        caso2.ContactId = contactoSEG1.Id;
        caso2.CC_MailTelfNotif__c = contactoSEG1.Email;
        caso2.SEG_Idioma__c = 'es';
        caso2.CC_AcuseRecibo__c ='1';
        caso2.ParentId = caso1.Id;
        caso2.CC_MCC_Tematica__c = mccTematica.Id;
        caso2.CC_MCC_ProdServ__c = mccProducto.Id;
        caso2.CC_MCC_Motivo__c = mccMotivo.Id;
        caso2.Status = 'Activo';
        caso2.Subject = 'test 2';
        caso2.EntitlementId = e.Id;
        caso2.SlaStartDate = System.now();
        caso2.SEG_SLA_cliente_case__c = 'Mismo día recepción';
        caso2.Origin = 'Email';
        listadoCasos.add(caso2);
        
        insert listadoCasos;

		 Seg_auditoria__c segauditoriacObj = new Seg_auditoria__c (
			SEG_NumeroSR__c = caso1.Id, 
			SEG_Resultado__c = 'test auditoria',
            RecordTypeId = recordTypeSEG
		);
        insert segauditoriacObj;
    }

    @isTest
    public static void actualizarAuditoriaTest()
    {
        Seg_auditoria__c audit1 = [SELECT Id,SEG_Resultado__c FROM Seg_auditoria__c Limit 1];

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        audit1.SEG_Resultado__c = 'OK';
        update audit1;
        Test.stopTest();

        System.assert(audit1.SEG_Resultado__c == 'OK');
        }
    }
    
    @isTest
    public static void actualizarAuditoriaTestKO()
    {
        Seg_auditoria__c audit1 = [SELECT Id,SEG_Resultado__c FROM Seg_auditoria__c Limit 1];

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        audit1.SEG_Resultado__c = 'NOK';
        update audit1;
        Test.stopTest();

        System.assert(audit1.SEG_Resultado__c == 'NOK');

        }
    }
    
    //Se comprueban el traspaso de Workflow SEG_FAuditoria a trigger de BI y BU
    @isTest
    public static void concatFechaNifTest(){
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE email = 'testSEGBI2@acme.com' LIMIT 1];
        Account cuentaSeg = [SELECT Id  FROM Account WHERE CC_Numero_Documento__c = '11111111H' LIMIT 1];
        Contact contactSeg = [SELECT Id, Email FROM Contact WHERE email = 'test@test.com' LIMIT 1];
        
        Test.startTest();
        System.runAs(usuarioTest) { 
        Case casoAu = new Case();
        casoAu.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        casoAu.AccountId = cuentaSeg.Id;
        casoAu.ContactId = contactSeg.Id;
        casoAu.CC_MailTelfNotif__c = contactSeg.Email;
        casoAu.SEG_Idioma__c = 'en';
        casoAu.CC_AcuseRecibo__c ='1';
        casoAu.Subject = 'test 8';
        casoAu.Status = 'Pendiente';
        casoAu.SEG_SRAuditoria__c = true;
        insert casoAu;

        Id recordTypeSEG = Schema.SObjectType.SEG_Auditoria__c.getRecordTypeInfosByDeveloperName().get('SEG_Auditorias').getRecordTypeId(); 
        Case casoAudit = [SELECT Id FROM Case WHERE Subject = 'test 8' LIMIT 1];
        List<Seg_auditoria__c> listAdutiroias = new List<Seg_auditoria__c>();
        Seg_auditoria__c segauditoriacObj = new Seg_auditoria__c (
			SEG_NumeroSR__c = casoAudit.Id, 
			SEG_Resultado__c = 'test auditoria nif+fecha',
            RecordTypeId = recordTypeSEG,
            SEG_FechaAuditoria__c = Date.today(),
            SEG_NIF__c = '93826409W'
		);
        listAdutiroias.add(segauditoriacObj);
        Seg_auditoria__c segauditoriacObjFecha = new Seg_auditoria__c (
			SEG_NumeroSR__c = casoAudit.Id, 
			SEG_Resultado__c = 'test auditoria fecha',
            RecordTypeId = recordTypeSEG,
            SEG_FechaAuditoria__c = Date.today()
		);
        listAdutiroias.add(segauditoriacObjFecha);
        insert listAdutiroias;

        List<Seg_auditoria__c> listAdutiroiasPostInserts = [SELECT Id, NIF_FechaAuditoria__c, SEG_FechaAuditoriaFormato__c, SEG_Resultado__c, SEG_NIF__c FROM Seg_auditoria__c WHERE SEG_Resultado__c IN ('test auditoria nif+fecha','test auditoria fecha')];
        for (Seg_auditoria__c auditoriaInsertada : listAdutiroiasPostInserts) {
            if (auditoriaInsertada.SEG_Resultado__c == 'test auditoria nif+fecha') {
                System.assertEquals(auditoriaInsertada.NIF_FechaAuditoria__c, auditoriaInsertada.SEG_NIF__c + String.valueOf(auditoriaInsertada.SEG_FechaAuditoriaFormato__c), 'No se ha concatenado correctamente.');
                auditoriaInsertada.SEG_NIF__c = null;
            } else if(auditoriaInsertada.SEG_Resultado__c == 'test auditoria fecha'){
                //Se concatenan el número de DNI de la cuenta asociada a la auditoría cuando ésta se crea con el NIF a nulo.
                System.assertEquals(auditoriaInsertada.NIF_FechaAuditoria__c, '11111111H' + String.valueOf(auditoriaInsertada.SEG_FechaAuditoriaFormato__c), 'No se ha concatenado correctamente.');
                auditoriaInsertada.SEG_NIF__c = '38797868L';
            }
        }
        update listAdutiroiasPostInserts;

        List<Seg_auditoria__c> listAdutiroiasPostUpdates = [SELECT Id, NIF_FechaAuditoria__c, SEG_FechaAuditoriaFormato__c, SEG_Resultado__c, SEG_NIF__c FROM Seg_auditoria__c WHERE SEG_Resultado__c IN ('test auditoria nif+fecha','test auditoria fecha')];
        for (Seg_auditoria__c auditoriaInsertada : listAdutiroiasPostUpdates) {
            if (auditoriaInsertada.SEG_Resultado__c == 'test auditoria fecha') {
                System.assertEquals(auditoriaInsertada.NIF_FechaAuditoria__c, auditoriaInsertada.SEG_NIF__c + String.valueOf(auditoriaInsertada.SEG_FechaAuditoriaFormato__c), 'No se ha concatenado correctamente.');
            } else if(auditoriaInsertada.SEG_Resultado__c == 'test auditoria nif+fecha'){
                System.assertEquals(auditoriaInsertada.NIF_FechaAuditoria__c, String.valueOf(auditoriaInsertada.SEG_FechaAuditoriaFormato__c), 'No se ha concatenado correctamente.');
            }
        }
    }
    }}