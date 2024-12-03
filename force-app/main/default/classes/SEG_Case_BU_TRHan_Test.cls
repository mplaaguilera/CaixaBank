@isTest
public with sharing class SEG_Case_BU_TRHan_Test {

    @testSetup
    static void testSetup() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Profile perfil = [SELECT Id FROM Profile WHERE Name='SEG_Usuario_CaixaBank'];
            UserRole rol = [SELECT Id FROM UserRole WHERE Name='Segmentos + FFEE'];
            User thisUser = new User(alias = 'tsegmen', email='testSEGBI@acme.com',
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

        Id recordDet = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
        Id grColId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs(usuarioTest) { 
            List<CC_Grupo_Colaborador__c> lstGruposCol = new List<CC_Grupo_Colaborador__c>();
            Id grupoOpSegId = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
            CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
            grupoColab.Name = 'GrupoColabSeg';
            grupoColab.SEG_Tipologia__c = 'BO';
            grupoColab.RecordTypeId = grupoOpSegId;
            grupoColab.SEG_GrupoSegmentos__c = true;
            grupoColab.SEG_envio_a_TaskConnect__c = true;
            grupoColab.OS_Negocio__c = 'SEGMENTOS';
            lstGruposCol.add(grupoColab);

            CC_Grupo_Colaborador__c grupoRTGrupoCol = new CC_Grupo_Colaborador__c();
            grupoRTGrupoCol.Name='Grupo Colaborador';
            grupoRTGrupoCol.RecordTypeId = grupoOpSegId;
            grupoRTGrupoCol.SEG_envio_a_TaskConnect__c = true;
            grupoRTGrupoCol.SEG_GrupoSegmentos__c = true;
            grupoRTGrupoCol.OS_Negocio__c = 'SEGMENTOS';
            lstGruposCol.add(grupoRTGrupoCol);

            CC_Grupo_Colaborador__c grupoCol2 = new CC_Grupo_Colaborador__c(Name = 'GrupoSegOp2', RecordTypeId = grupoOpSegId, SEG_GrupoSegmentos__c = true, OS_Negocio__c = 'SEGMENTOS');
            lstGruposCol.add(grupoCol2);

            insert lstGruposCol;
        }

        List<CC_Grupo_Colaborador__c> lstGrupos = [SELECT Id, RecordType.DeveloperName, SEG_GrupoSegmentos__c, OS_Negocio__c FROM CC_Grupo_Colaborador__c LIMIT 2];

        // Contactos
        List<Contact> lstContact = new List<Contact>();
        List<Account> lstCuentas = new List<Account>();

        Account cuentaSEG = new Account();
        cuentaSEG.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        cuentaSEG.Name = 'test segmentos';
        cuentaSEG.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG.CC_Numero_Documento__c = '111111114';
        cuentaSEG.CC_Grupo_Colaborador__c = lstGrupos[0].Id;
        cuentaSEG.SEG_No_enviar_Acuse_Recibo_Empresa__c = false;
        lstCuentas.add(cuentaSEG);

        Contact contactoSEG = new Contact();
        contactoSEG.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        contactoSEG.FirstName = 'Yaiza';
        contactoSEG.LastName = 'Contacto 2';
        contactoSEG.Email = 'testasdas@test.com';
        contactoSEG.AccountId = cuentaSEG.Id;
        contactoSEG.SEG_No_enviar_Acuse_Recibo__c = false;
        lstContact.add(contactoSEG);

        Account cuentaSEG1 = new Account();
        cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        cuentaSEG1.Name = 'Empresa segmentos';
        cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG1.CC_Numero_Documento__c = '11111111H';
        cuentaSEG1.AV_EAPGestor__c = contactoSEG.Id;
        cuentaSEG1.SEG_No_enviar_Acuse_Recibo_Empresa__c = false;
        lstCuentas.add(cuentaSEG1);
        
        Account cuentaSEG2 = new Account();
        cuentaSEG2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        cuentaSEG2.Name = 'Empresa Test';
        cuentaSEG2.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG2.CC_Numero_Documento__c = '11111112H';
        cuentaSEG2.CC_Numero_Oficina__c = '74512';
        lstCuentas.add(cuentaSEG2);

        Account cuentaSEG3 = new Account();
        cuentaSEG3.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        cuentaSEG3.Name = 'Empresa Test 2';
        cuentaSEG3.SEG_DominioMail__c = '@cuenta';
        cuentaSEG3.CC_Numero_Documento__c = '11111189H';
        cuentaSEG3.CC_Numero_Oficina__c = '74516';
        lstCuentas.add(cuentaSEG3);

        //SLA START
        Account a = new Account();
        a.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        a.Name = 'account temp';
        lstCuentas.add(a);

        insert lstCuentas;

        // Crear contactos para cuentas SEG.
        Contact contactoSEG1 = new Contact();
        contactoSEG1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contactoSEG1.LastName = 'Contacto SEG 1';
        contactoSEG1.AccountId = cuentaSEG1.Id;
        contactoSEG1.SEG_Estado__c = 'Activo';
        contactoSEG1.Email = 'test@test.com';
        contactoSEG.SEG_No_enviar_Acuse_Recibo__c = false;
        lstContact.add(contactoSEG1);

        Contact contactoSEG2 = new Contact();
        contactoSEG2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contactoSEG2.LastName = 'Contacto SEG 2';
        contactoSEG1.AccountId = cuentaSEG1.Id;
        contactoSEG2.Email = 'test23@test.com';
        lstContact.add(contactoSEG2);

        insert lstContact;

        // Gestor Grupo
        SEG_Gestor_Grupo__c gestorDeGrupo = new SEG_Gestor_Grupo__c();
        gestorDeGrupo.SEG_GrupoOperativa__c = lstGrupos[0].Id;
        gestorDeGrupo.SEG_EmpleadoGestor__c = contactoSEG.id;
        insert gestorDeGrupo;
        

        CC_MCC__c mccDetalle3 = new CC_MCC__c();  
        mccDetalle3.RecordTypeId = recordDet;
        mccDetalle3.Name = 'Detalle';
        mccDetalle3.CC_Tipo_Cliente__c = 'Cliente';
        mccDetalle3.CC_Codigo_Externo__c = 'DE-000003';
        insert mccDetalle3;  
        
        EmailTemplate emailEs = new EmailTemplate();
		emailEs.DeveloperName = 'Reclamacion_1_1616749645917';
		emailEs.Encoding = 'ISO-8859-1';
		emailEs.FolderId = UserInfo.getUserId();
		emailEs.Subject = '[num_casos]';
		emailEs.IsActive = true;
		emailEs.Name = 'Reclamacion 1º';
		emailEs.TemplateType = 'custom';
		emailEs.TemplateStyle = 'none';
		emailEs.HtmlValue = '<html><head><title></title></head><body style="height: auto; min-height: auto;">1&ordm; reclamaci&oacute;n enviada con la SR de seguimiento&nbsp;{{{Case.CaseNumber}}}<style type="text/css">table {font-family: arial, sans-serif; border-collapse: collapse;width: 100%;}td, th {border: 1px solid #dddddd; text-align: left; padding: 8px;}tr:nth-child(even) { background-color: #dddddd;}</style><table><tr><th>N&uacute;mero Contrato</th><th>Fecha Contrato</th><th>Descripci&oacute;n Contrato</th></tr></table></body></html>';
		System.runAs(new User(Id = UserInfo.getUserId())) {
			insert emailEs;
		}

        List<SEG_Plantilla__c> listPlantillas = new List<SEG_Plantilla__c>();
		SEG_Plantilla__c plantillacierre = new SEG_Plantilla__c();
		plantillacierre.Name = 'Cierre Caso Padre';
		plantillacierre.SEG_Organizacion__c = 'Banca Corporativa;Centro Empresas;Instituciones;Centro Soporte Especialistas;Financiación Estructurada';
		plantillacierre.SEG_Zona__c = 'Corporativa;Empresas Barcelona;Empresas Castilla La Mancha;Empresas Cataluña;Empresas Madrid;Empresas Valencia;Instituciones Canarias;Empresas Cataluña';
		plantillacierre.SEG_TipoOperativa__c = 'Cierre Caso Padre';
		plantillacierre.SEG_Activa__c = true;
		plantillacierre.SEG_PlantillaCastellano__c = 'Firma BO';
		plantillacierre.SEG_PlantillaCatalan__c = 'Firma CAT';
		plantillacierre.SEG_PlantillaIngles__c = 'Firma IN';
		plantillacierre.SEG_PlantillaEuskera__c = 'Firma EUSK';
		plantillacierre.SEG_PlantillaGalego__c = 'Firma GAL';
		plantillacierre.SEG_PlantillaCastellanoID__c = emailEs.Id;
        plantillacierre.SEG_PlantillaInglesID__c = emailEs.Id;
		listPlantillas.add(plantillacierre);
        
        SEG_Plantilla__c planAR = new SEG_Plantilla__c();
		planAR.Name = 'Acuse de recibo';
		planAR.SEG_Organizacion__c = 'Banca Corporativa;Centro Empresas;Instituciones;Centro Soporte Especialistas;Financiación Estructurada';
		planAR.SEG_Zona__c = 'Corporativa;Empresas Barcelona;Empresas Castilla La Mancha;Empresas Cataluña;Empresas Madrid;Empresas Valencia;Instituciones Canarias;Empresas Cataluña';
		planAR.SEG_TipoOperativa__c = 'Acuse de recibo';
		planAR.SEG_Activa__c = true;
		planAR.SEG_PlantillaCastellano__c = 'Firma BO';
		planAR.SEG_PlantillaCatalan__c = 'Firma CAT';
		planAR.SEG_PlantillaIngles__c = 'Firma IN';
		planAR.SEG_PlantillaEuskera__c = 'Firma EUSK';
		planAR.SEG_PlantillaGalego__c = 'Firma GAL';
		planAR.SEG_PlantillaCastellanoID__c = emailEs.Id;
        planAR.SEG_PlantillaInglesID__c = emailEs.Id;
		listPlantillas.add(planAR);

        //String idPlantilla = '00X5r000000LxqTEAS';

        //Grupo Colaborador con RT Grupo Colaborador
        SEG_Plantilla__c plantilla = new SEG_Plantilla__C();
        plantilla.Name ='Plantilla Col';
        plantilla.SEG_TipoOperativa__c = 'Acuse de recibo';
        plantilla.SEG_PlantillaCastellanoID__c=emailEs.Id;
        plantilla.SEG_Activa__c = true;
        listPlantillas.add(plantilla);
        insert listPlantillas;

        //Grupo MCC link Grupo Colaborador
        CC_MCC_Grupo_Colaborador__c  grupoCol = new CC_MCC_Grupo_Colaborador__c();
        grupoCol.Name='Colaborador';
        grupoCol.CC_MCC__c = mccDetalle3.Id; 
        grupoCol.CC_Grupo_Colaborador__c=lstGrupos[1].Id;
        grupoCol.SEG_Zona__c = 'Todas';
        grupoCol.SEG_Organizacion__c = 'Todas';
        insert grupoCol;
        //Creamos una plantilla para usar en RT = 'Grupo Colaborador'
        CC_Grupo_Colaborador_Plantilla__c plantillagrupo = new CC_Grupo_Colaborador_Plantilla__c();
        plantillagrupo.CC_Operativa__c= 'Trasladar';
        plantillagrupo.SEG_Plantilla__c=plantilla.id;
        plantillagrupo.CC_Grupo_Colaborador__c = lstGrupos[1].Id;
        insert plantillagrupo;


        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Tematica1';
        mccTematica.CC_Tipo_Cliente__c = 'Segmentos';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Producto1';
        mccProducto.CC_Tipo_Cliente__c = 'Segmentos';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Motivo1';
        mccMotivo.CC_Tipo_Cliente__c = 'Segmentos';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;

        Id recordTypeIdDetalle = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
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

        CC_MCC__c mccTematicaSLA = new CC_MCC__c();
		mccTematicaSLA.Name = 'Tematica SLA';
        mccTematicaSLA.CC_Tipo_Cliente__c = 'Segmentos';
        mccTematicaSLA.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematicaSLA.RecordTypeId = recordTypeIdTematica;
        mccTematicaSLA.SEG_SLACliente__c = 'Máximo 3 días hábiles desde la recepción';
        insert mccTematicaSLA;
        
        CC_MCC__c mccProductoSLA = new CC_MCC__c();
        mccProductoSLA.Name = 'Producto SLA';
        mccProductoSLA.CC_Tipo_Cliente__c = 'Segmentos';
        mccProductoSLA.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProductoSLA.RecordTypeId = recordTypeIdProducto;
        mccProductoSLA.CC_Tematica__c = mccTematicaSLA.Id;
        mccProductoSLA.SEG_SLACliente__c = 'Máximo 3 días hábiles desde la recepción';
        insert mccProductoSLA; 
        
       	CC_MCC__c mccMotivoSLA = new CC_MCC__c();
        mccMotivoSLA.Name = 'Motivo SLA';
        mccMotivoSLA.CC_Tipo_Cliente__c = 'Segmentos';
        mccMotivoSLA.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivoSLA.RecordTypeId = recordTypeIdMotivo;
        mccMotivoSLA.CC_Tematica__c = mccTematica.Id;
        mccMotivoSLA.CC_Producto_Servicio__c = mccProductoSLA.Id;
        mccMotivoSLA.SEG_SLACliente__c = 'Máximo 3 días hábiles desde la recepción';
        insert mccMotivoSLA;

       	CC_MCC__c mccDetalleSLA = new CC_MCC__c();
        mccDetalleSLA.Name = 'Detalle SLA';
        mccDetalleSLA.CC_Tipo_Cliente__c = 'Segmentos';
        mccDetalleSLA.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccDetalleSLA.RecordTypeId = recordTypeIdDetalle;
        mccDetalleSLA.CC_Tematica__c = mccTematica.Id;
        mccDetalleSLA.CC_Producto_Servicio__c = mccMotivoSLA.Id;
        mccDetalleSLA.CC_Motivo__c = mccMotivo.Id;
        mccDetalleSLA.SEG_SLACliente__c = 'Máximo 3 días hábiles desde la recepción';
        insert mccDetalleSLA;

        CC_MCC__c mccTematica2 = new CC_MCC__c();
		mccTematica2.Name = 'Tematica2';
        mccTematica2.CC_Tipo_Cliente__c = 'Segmentos';
        mccTematica2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica2.RecordTypeId = recordTypeIdTematica;
        mccTematica2.CC_Codigo_Externo__c = 'TE-000002';
        mccTematica2.SEG_envio_a_TaskConnect__c = true;
        insert mccTematica2;
        
        CC_MCC__c mccProducto2 = new CC_MCC__c();
        mccProducto2.Name = 'Producto2';
        mccProducto2.CC_Tipo_Cliente__c = 'Segmentos';
        mccProducto2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto2.RecordTypeId = recordTypeIdProducto;
        mccProducto2.CC_Tematica__c = mccTematica2.Id;
        mccProducto2.CC_Codigo_Externo__c = 'PR-000002'; 
        mccProducto2.SEG_envio_a_TaskConnect__c = true;
        insert mccProducto2; 
        
       	CC_MCC__c mccMotivo2 = new CC_MCC__c();
        mccMotivo2.Name = 'Motivo2';
        mccMotivo2.CC_Tipo_Cliente__c = 'Segmentos';
        mccMotivo2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo2.RecordTypeId = recordTypeIdMotivo;
        mccMotivo2.CC_Tematica__c = mccTematica2.Id;
        mccMotivo2.CC_Producto_Servicio__c = mccProducto2.Id;
        mccMotivo2.CC_Codigo_Externo__c = 'MO-000002';
        mccMotivo2.SEG_envio_a_TaskConnect__c = true;
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
        mccDetalle2.SEG_envio_a_TaskConnect__c = true;
        insert mccDetalle2;

        List<SEG_ClasificacionRapida__c> lstReglas = new List<SEG_ClasificacionRapida__c>();
        SEG_ClasificacionRapida__c regla1 = new SEG_ClasificacionRapida__c();
        regla1.Name = 'CR1';
        regla1.SEG_Tematica__c = mccTematica.Id;
        regla1.SEG_Producto__c = mccProducto.Id;
        regla1.SEG_Motivo__c = mccMotivo.Id;
        regla1.SEG_Detalle__c = mccDetalle.Id;
        regla1.SEG_TPMV__c = String.valueOf(mccTematica.Id).right(15)+String.valueOf(mccProducto.Id).right(15)+String.valueOf(mccMotivo.Id).right(15)+String.valueOf(mccDetalle.Id).right(15);
        regla1.CBK_Negocio__c = 'Segmentos';
        lstReglas.add(regla1);

        SEG_ClasificacionRapida__c regla2 = new SEG_ClasificacionRapida__c();
        regla2.Name = 'CR2';
        regla2.SEG_Tematica__c = mccTematica2.Id;
        regla2.SEG_Producto__c = mccProducto2.Id;
        regla2.SEG_Motivo__c = mccMotivo2.Id;
        regla2.SEG_Detalle__c = mccDetalle2.Id;
        regla2.SEG_TPMV__c = String.valueOf(mccTematica2.Id).right(15)+String.valueOf(mccProducto2.Id).right(15)+String.valueOf(mccMotivo2.Id).right(15)+String.valueOf(mccDetalle2.Id).right(15);
        regla2.CBK_Negocio__c = 'Segmentos';
        lstReglas.add(regla2);
        insert lstReglas;

        //Crear reclamaciones
        SEG_Reclamaciones__c recl = new SEG_Reclamaciones__c();
        recl.Name = 'Testreclamaciones';
        recl.SEG_Plazo1Reclamacion__c = 1;
        recl.SEG_Plazo2Reclamacion__c = 2;
        recl.SEG_Plazo3Reclamacion__c = 3;
        recl.SEG_PlazoEnvioGestor__c = 4;
        recl.SEG_PlazoLlamada__c = 1;

        insert recl;
        
        //Crear MCC para CR

        CC_MCC__c mccTematicaSEG = new CC_MCC__c();
		mccTematicaSEG.Name = 'Tematica1SEG';
        mccTematicaSEG.CC_Tipo_Cliente__c = 'Segmentos';
        mccTematicaSEG.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematicaSEG.RecordTypeId = recordTypeIdTematica;
        mccTematicaSEG.CC_Codigo_Externo__c = 'TE-000007';
        insert mccTematicaSEG;
        
        CC_MCC__c mccProductoSEG = new CC_MCC__c();
        mccProductoSEG.Name = 'Producto1SEG';
        mccProductoSEG.CC_Tipo_Cliente__c = 'Segmentos';
        mccProductoSEG.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProductoSEG.RecordTypeId = recordTypeIdProducto;
        mccProductoSEG.CC_Tematica__c = mccTematicaSEG.Id;
        mccProductoSEG.CC_Codigo_Externo__c = 'PR-000007'; 
        insert mccProductoSEG; 
        
       	CC_MCC__c mccMotivoSEG = new CC_MCC__c();
        mccMotivoSEG.Name = 'Motivo1SEG';
        mccMotivoSEG.CC_Tipo_Cliente__c = 'Segmentos';
        mccMotivoSEG.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivoSEG.RecordTypeId = recordTypeIdMotivo;
        mccMotivoSEG.CC_Tematica__c = mccTematicaSEG.Id;
        mccMotivoSEG.CC_Producto_Servicio__c = mccProductoSEG.Id;
        mccMotivoSEG.CC_Codigo_Externo__c = 'MO-000007';
        insert mccMotivoSEG;

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
        regla3.SEG_ReclamacionesContratos__c = recl.Id;
        regla3.SEG_CRContratos__c  = true;
        regla3.CBK_Negocio__c = 'Segmentos';
        insert regla3;
        
                //Crear reclamaciones
        SEG_Reclamaciones__c recl2 = new SEG_Reclamaciones__c();
        recl2.Name = 'Testreclamaciones';
        recl2.SEG_Plazo1Reclamacion__c = 2;
        recl2.SEG_Plazo2Reclamacion__c = 3;
        recl2.SEG_Plazo3Reclamacion__c = 4;
        recl2.SEG_PlazoEnvioGestor__c = 4;
        recl2.SEG_PlazoLlamada__c = 1;

        insert recl2;
        
        //Crear MCC para CR contratos

        CC_MCC__c mccTematicaSEG2 = new CC_MCC__c();
		mccTematicaSEG2.Name = 'Tematica1SEG2';
        mccTematicaSEG2.CC_Tipo_Cliente__c = 'Segmentos';
        mccTematicaSEG2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematicaSEG2.RecordTypeId = recordTypeIdTematica;
        mccTematicaSEG2.CC_Codigo_Externo__c = 'TE-000008';
        insert mccTematicaSEG2;
        
        CC_MCC__c mccProductoSEG2 = new CC_MCC__c();
        mccProductoSEG2.Name = 'Producto1SEG2';
        mccProductoSEG2.CC_Tipo_Cliente__c = 'Segmentos';
        mccProductoSEG2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProductoSEG2.RecordTypeId = recordTypeIdProducto;
        mccProductoSEG2.CC_Tematica__c = mccTematicaSEG2.Id;
        mccProductoSEG2.CC_Codigo_Externo__c = 'PR-000008'; 
        insert mccProductoSEG2; 
        
       	CC_MCC__c mccMotivoSEG2 = new CC_MCC__c();
        mccMotivoSEG2.Name = 'Motivo1SEG2';
        mccMotivoSEG2.CC_Tipo_Cliente__c = 'Segmentos';
        mccMotivoSEG2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivoSEG2.RecordTypeId = recordTypeIdMotivo;
        mccMotivoSEG2.CC_Tematica__c = mccTematicaSEG2.Id;
        mccMotivoSEG2.CC_Producto_Servicio__c = mccProductoSEG2.Id;
        mccMotivoSEG2.CC_Codigo_Externo__c = 'MO-000008';
        insert mccMotivoSEG2;

       	CC_MCC__c mccDetalleSEG2 = new CC_MCC__c();
        mccDetalleSEG2.Name = 'Detalle1SEG2';
        mccDetalleSEG2.CC_Tipo_Cliente__c = 'Segmentos';
        mccDetalleSEG2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccDetalleSEG2.RecordTypeId = recordTypeIdDetalle;
        mccDetalleSEG2.CC_Tematica__c = mccTematicaSEG2.Id;
        mccDetalleSEG2.CC_Producto_Servicio__c = mccProductoSEG2.Id;
        mccDetalleSEG2.CC_Motivo__c = mccMotivoSEG2.Id;
        mccDetalleSEG2.CC_Codigo_Externo__c = 'DE-000008';
        insert mccDetalleSEG2;
        
        SEG_ClasificacionRapida__c regla4 = new SEG_ClasificacionRapida__c();
        regla4.Name = 'CR4';
        regla4.SEG_Tematica__c = mccTematicaSEG2.Id;
        regla4.SEG_Producto__c = mccProductoSEG2.Id;
        regla4.SEG_Motivo__c = mccMotivoSEG2.Id;
        regla4.SEG_Detalle__c = mccDetalleSEG2.Id;
        regla4.SEG_ReclamacionesContratos__c = recl2.Id;
        regla4.SEG_CRContratos__c  = true;
        regla4.CBK_Negocio__c = 'Segmentos';
        insert regla4;
        
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

        Profile pf= [SELECT Id FROM profile WHERE Name='SEG_Usuario_CaixaBank']; 
        String orgId= UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer randomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+randomId;
        List<User> usuarios = new List<User>(); 
        User uu= new User(firstname = 'ABC', 
                        lastName = 'XYZ', 
                        email = uniqueName + '@test' + orgId + '.org', 
                        Username = uniqueName + '@test' + orgId + '.org', 
                        EmailEncodingKey = 'ISO-8859-1', 
                        Alias = uniqueName.substring(18, 23), 
                        TimeZoneSidKey = 'America/Los_Angeles', 
                        LocaleSidKey = 'en_US', 
                        LanguageLocaleKey = 'en_US', 
                        ProfileId = pf.Id
                        ); 

        // create user
        usuarios.add(uu);

        User uu2= new User(firstname = 'CFE', 
                        lastName = 'XYZ', 
                        email = uniqueName + '@test' + orgId + '.org' + 2, 
                        Username = uniqueName + '@test' + orgId + '.org' +2, 
                        EmailEncodingKey = 'ISO-8859-1', 
                        Alias = uniqueName.substring(18, 23), 
                        TimeZoneSidKey = 'America/Los_Angeles', 
                        LocaleSidKey = 'en_US', 
                        LanguageLocaleKey = 'en_US', 
                        ProfileId = pf.Id
                        ); 

        // create user
        usuarios.add(uu2);
        insert usuarios;
        
		// Crear casos de los clientes.
        List<Case> listadoCasos = new List<Case>();

        Case caso1 = new Case();
        caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso1.AccountId = cuentaSEG1.Id;
        caso1.ContactId = contactoSEG1.Id;
        caso1.CC_MailTelfNotif__c = contactoSEG1.Email;
        caso1.SEG_Idioma__c = 'es';
        caso1.CC_AcuseRecibo__c ='1';
        caso1.Subject = 'test 1';
        caso1.CC_MCC_Tematica__c = mccTematica.Id;
        caso1.CC_MCC_ProdServ__c = mccProducto.Id;
        caso1.CC_MCC_Motivo__c = mccMotivo.Id;
        caso1.Status = 'Pendiente';
        caso1.SEG_N_operaciones_del_caso__c = 1.0;
        caso1.SEG_ClasificacionRapida__c = regla1.id;
        caso1.SEG_ClasificacionRapidaOrigen__c = regla1.id;
        listadoCasos.add(caso1);
        
        Case caso2 = new Case();
        caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso2.AccountId = cuentaSEG1.Id;
        caso2.ContactId = contactoSEG1.Id;
        caso2.OwnerId = uu2.id;
        caso2.SEG_grupo__c = lstGrupos[1].Id;
        caso2.CC_MailTelfNotif__c = contactoSEG1.Email;
        caso2.SEG_Idioma__c = 'es';
        caso2.CC_AcuseRecibo__c ='1';
        caso2.ParentId = caso1.Id;
        caso2.CC_MCC_Tematica__c = mccTematica.Id;
        caso2.CC_MCC_ProdServ__c = mccProducto.Id;
        caso2.CC_MCC_Motivo__c = mccMotivo.Id;
        caso2.SEG_ClasificacionRapida__c = regla1.id;
        caso2.Status = 'Activo';
        caso2.Subject = 'test 2';
        caso2.EntitlementId = e.Id;
        caso2.SlaStartDate = System.now();
        caso2.SEG_SLA_cliente_case__c = 'Mismo día recepción';
        caso2.Origin = 'Email';
        caso2.SEG_Organizacion__c = 'Centro Soporte Especialistas';
		caso2.SEG_Zona__c = 'CSE';
        caso2.SEG_N_operaciones_del_caso__c = 1.0;
        listadoCasos.add(caso2);
        
        //Caso de seguimiento
        Case caso3 = new Case();
        caso3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
        caso3.AccountId = cuentaSEG1.Id;
        caso3.ContactId = contactoSEG1.Id;
        caso3.CC_MailTelfNotif__c = contactoSEG1.Email;
        caso3.SEG_Idioma__c = 'es';
        caso3.CC_AcuseRecibo__c ='1';
        caso3.ParentId = caso1.Id;
        caso3.CC_MCC_Tematica__c = mccTematica.Id;
        caso3.CC_MCC_ProdServ__c = mccProducto.Id;
        caso3.CC_MCC_Motivo__c = mccMotivo.Id;
        caso3.Status = 'Activo';
        caso3.Subject = 'test Seguimiento';
        caso3.SEG_ClasificacionRapida__c = regla3.Id;
        caso3.SEG_Organizacion__c = 'Centro Empresas';
		caso3.SEG_Zona__c = 'Empresas Cataluña';
        caso3.SEG_N_operaciones_del_caso__c = 1.0;
        listadoCasos.add(caso3);
        
        Case caso4 = new Case();
        caso4.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso4.AccountId = cuentaSEG1.Id;
        caso4.ContactId = contactoSEG1.Id;
        caso4.CC_MailTelfNotif__c = contactoSEG1.Email;
        caso4.SEG_Idioma__c = 'en';
        caso4.Subject = 'caso4 Test';
        caso4.CC_MCC_Tematica__c = mccTematica.Id;
        caso4.CC_MCC_ProdServ__c = mccProducto.Id;
        caso4.CC_MCC_Motivo__c = mccMotivo.Id;
        caso4.Status = 'Activo';
        caso4.SEG_Organizacion__c = 'Centro Empresas';
		caso4.SEG_Zona__c = 'Empresas Barcelona';
        caso4.SEG_N_operaciones_del_caso__c = 1.0;
        listadoCasos.add(caso4);
        
        //casos relacionados
        Case casopadre = new Case();
        casopadre.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        casopadre.AccountId = cuentaSEG1.Id;
        casopadre.ContactId = contactoSEG1.Id;
        casopadre.CC_MailTelfNotif__c = contactoSEG1.Email;
        casopadre.SEG_Idioma__c = 'es';
        casopadre.CC_AcuseRecibo__c ='1';
        casopadre.Subject = 'casopadre';
        casopadre.CC_MCC_Tematica__c = mccTematica.Id;
        casopadre.CC_MCC_ProdServ__c = mccProducto.Id;
        casopadre.CC_MCC_Motivo__c = mccMotivo.Id;
        casopadre.Status = 'Activo';
        casopadre.SEG_Organizacion__c = 'Banca Corporativa';
		casopadre.SEG_Zona__c = 'Corporativa';
        casopadre.SEG_N_operaciones_del_caso__c = 1.0;
        listadoCasos.add(casopadre);
        
        insert listadoCasos;
        
        Case casohijo = new Case();
        casohijo.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        casohijo.AccountId = cuentaSEG1.Id;
        casohijo.ContactId = contactoSEG1.Id;
        casohijo.CC_MailTelfNotif__c = contactoSEG1.Email;
        casohijo.SEG_Idioma__c = 'es';
        casohijo.CC_AcuseRecibo__c ='1';
        casohijo.CC_MCC_Tematica__c = mccTematica.Id;
        casohijo.CC_MCC_ProdServ__c = mccProducto.Id;
        casohijo.CC_MCC_Motivo__c = mccMotivo.Id;
        casohijo.Status = 'Activo';
        casohijo.Subject = 'casohijo';
        casohijo.EntitlementId = e.Id;
        casohijo.SlaStartDate = System.now();
        casohijo.SEG_SLA_cliente_case__c = 'Mismo día recepción';
        casohijo.Origin = 'Email';
        casohijo.ParentId = casopadre.Id;
        casohijo.SEG_Organizacion__c = 'Banca Corporativa';
		casohijo.SEG_Zona__c = 'Corporativa';
        casohijo.SEG_N_operaciones_del_caso__c = 1.0;
        insert casohijo;
        
        //Crear contratos
        List<SEG_Contratos__c> listadoContratos = new List<SEG_Contratos__c>();
        SEG_Contratos__c contrato1 = new SEG_Contratos__c();
        contrato1.Name = 'Number1';
        contrato1.SEG_NombreCliente__c = contactoSEG1.Id;
        contrato1.SEG_NombreCuenta__c = cuentaSEG1.Id;
        contrato1.SEG_SR_Seguimiento__c=caso3.Id;
        contrato1.SEG_Estado__c = 'No firmado';
        contrato1.SEG_Fecha_1_Reclamacion__c = date.Today();
        listadoContratos.add(contrato1);

        SEG_Contratos__c contrato2 = new SEG_Contratos__c();
        contrato2.Name = 'Number2';
        contrato2.SEG_NombreCliente__c = contactoSEG1.Id;
        contrato2.SEG_NombreCuenta__c = cuentaSEG1.Id;
        contrato2.SEG_SR_Seguimiento__c=caso3.Id;
        contrato2.SEG_Estado__c = 'No firmado';
        contrato2.SEG_Fecha_2_Reclamacion__c = date.Today();
        listadoContratos.add(contrato2);
        insert listadoContratos;
    }

    @isTest
    public static void actualizarCasoCR()
    {
        SEG_ClasificacionRapida__c regla2 = [SELECT Id FROM SEG_ClasificacionRapida__c WHERE Name = 'CR2'];

        Case caso = [SELECT Id FROM Case WHERE Subject = 'test 2'];

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

            Test.startTest();
            
                caso.SEG_ClasificacionRapida__c = regla2.Id;
                caso.CC_MCC_Tematica__c = null;
                update caso;
            Test.stopTest();

            Case casoRes = [SELECT Id, SEG_ClasificacionRapida__c, CC_MCC_Motivo__c FROM Case WHERE Subject = 'test 2'];
            System.assert(casoRes.SEG_ClasificacionRapida__c != null);
            System.assert(casoRes.CC_MCC_Motivo__c != null);
        }
    } 
    
        @isTest
    public static void actualizarCasoCR2()
    {
		CC_MCC__c tematica = [SELECT Id FROM CC_MCC__c WHERE Name ='Tematica2'];
        CC_MCC__c producto = [SELECT Id FROM CC_MCC__c WHERE Name ='Producto2'];
        CC_MCC__c motivo = [SELECT Id FROM CC_MCC__c WHERE Name ='Motivo2'];
        CC_MCC__c detalle = [SELECT Id FROM CC_MCC__c WHERE Name ='Detalle2'];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'test 2'];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
                caso.CC_MCC_Tematica__c = tematica.Id;
                caso.CC_MCC_ProdServ__c = producto.Id;
                caso.CC_MCC_Motivo__c = motivo.Id;
                caso.SEG_Detalle__c = detalle.Id;
                update caso;

            Test.stopTest();
        }
        System.assertEquals(true,true,'Se ha modificado el mcc');
    } 

    @isTest
    public static void cerrarcasosAuditoriaTest()
    {

        Case caso = [SELECT Id FROM Case WHERE Subject = 'test 1'];

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        
        Test.startTest();
        caso.SEG_SRAuditoria__c = true;
        caso.Status = 'Cerrado';
        caso.CC_Detalles_Consulta__c = 'Caso cerrado';
        update caso;
        
        
        Test.stopTest();
        
        Case casoRes = [SELECT Id, SEG_ClasificacionRapida__c,Status, CC_MCC_Motivo__c FROM Case WHERE Subject = 'test 1'];
        System.assert(casoRes.Status != null);
        }
    }
    
    @isTest
    public static void casoReabiertoTest()
    {

        Case caso = [SELECT Id FROM Case WHERE Subject = 'test 2'];

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

        Test.startTest();
        caso.Status = 'Reabierto';
        update caso;
        
        
        Test.stopTest();
        
        Case casoRes = [SELECT Id, SEG_ClasificacionRapida__c,Status, CC_MCC_Motivo__c FROM Case WHERE Subject = 'test 2'];
        System.assert(casoRes.Status != null);
        }
    }
    
    @isTest
    public static void casoFechaValorSLATest()
    {

        Case caso = [SELECT Id FROM Case WHERE Subject = 'test 2'];

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

        Test.startTest();
        caso.SEG_Fecha_valor__c = system.now() + 5;
        update caso;
        
        
        Test.stopTest();
        
        Case casoRes = [SELECT Id, SEG_ClasificacionRapida__c,Status, CC_MCC_Motivo__c FROM Case WHERE Subject = 'test 2'];
        System.assert(casoRes.Status != null);
        }
    }
    
    @isTest
    public static void cerrarCasoPadreTest()
    {

        Case caso = [SELECT Id FROM Case WHERE Subject = 'casopadre'];

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

        Test.startTest();
        caso.Status = 'Cerrado';
        caso.CC_Detalles_Consulta__c = 'Caso cerrado';
        update caso;
        
        
        Test.stopTest();
        
        Case casoRes = [SELECT Id, SEG_ClasificacionRapida__c,Status, CC_MCC_Motivo__c FROM Case WHERE Subject = 'casopadre'];
        System.assert(casoRes.Status != null);
        }
    } 
    
    @isTest
    public static void cerrarCasoHijoTest()
    {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'casohijo'];

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

        Test.startTest();
        caso.Status = 'Cerrado';
        caso.CC_Detalles_Consulta__c = 'Caso cerrado';
        update caso;      
        Test.stopTest();
        
        Case casoRes = [SELECT Id, SEG_ClasificacionRapida__c,Status, CC_MCC_Motivo__c FROM Case WHERE Subject = 'casohijo'];
        System.assert(casoRes.Status != null);
        }
    } 
    
    @isTest
    public static void actualizarNumeroCentroTest()
    {
		Case caso = [SELECT Id,AccountId FROM Case WHERE Subject = 'test 2'];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Empresa Test'];

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

        Test.startTest();
        caso.SEG_Numero_de_centro__c = acc.Id;
        update caso;       
        Test.stopTest();
        Case casoRes = [SELECT Id, SEG_ClasificacionRapida__c,Status, CC_MCC_Motivo__c FROM Case WHERE Subject = 'test 2'];
        System.assert(casoRes.Status != null);
        }
    }
    
    @isTest
    public static void actualizarNumeroCentroaccIdTest()
    {
		Case caso = [SELECT Id,AccountId FROM Case WHERE Subject = 'test 2'];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Empresa Test'];

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

            Test.startTest();
            caso.AccountId = acc.Id;
            update caso;       
            Test.stopTest();
            Case casoRes = [SELECT Id, SEG_ClasificacionRapida__c,Status, CC_MCC_Motivo__c FROM Case WHERE Subject = 'test 2'];
            System.assert(casoRes.Status != null);
        }
    }
    
    @isTest
    public static void actualizarGrupoAnteriorTest()
    {
        Id grupoOpSegId = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        //Grupos Colaboradores
        CC_Grupo_Colaborador__c grupoCol1 = new CC_Grupo_Colaborador__c(Name = 'GrupoSegOp1', RecordTypeId = grupoOpSegId);
		insert grupoCol1;
		Case caso = [SELECT Id,AccountId FROM Case WHERE Subject = 'test 2'];

        User usuario = [SELECT Id, firstname FROM User WHERE firstName = 'ABC'];

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

        Test.startTest();
        caso.SEG_Grupo__c = grupoCol1.Id;
        update caso;       
        Test.stopTest();

        CC_Grupo_Colaborador_Contact__c contactoGrupo = new CC_Grupo_Colaborador_Contact__c();
        contactoGrupo.CC_Usuario__c = usuario.id;
        contactoGrupo.CC_Grupo_Colaborador__c = grupoCol1.id;
        insert contactoGrupo;

        SEG_Grupos_por_caso__c  grupoDelCaso = new SEG_Grupos_por_caso__c ();
        grupoDelCaso.SEG_caseId__c = caso.id;
        grupoDelCaso.SEG_GrupoId__c = grupoCol1.Id;
        grupoDelCaso.SEG_PropAnterior__c = usuario.id;
        insert grupoDelCaso;
        
            Case casoRes = [SELECT Id, SEG_ClasificacionRapida__c,Status, CC_MCC_Motivo__c FROM Case WHERE Subject = 'test 2'];
        System.assert(casoRes.Status != null);
        }
    }
    
    @isTest
    public static void lanzarAcuseReciboTest()
    {
		Case caso = [SELECT SEG_Idioma__c,CC_AcuseRecibo__c  FROM Case WHERE Subject = 'caso4 Test'];

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

        Test.startTest();
        caso.SEG_Idioma__c = 'en';
        caso.CC_AcuseRecibo__c ='1';
        update caso;       
        Test.stopTest();
        Case casoRes = [SELECT Status FROM Case WHERE Subject = 'caso4 Test'];
        System.assert(casoRes.Status != null);
        }
    } 
    
    @isTest
    public static void updateFechasParametrizacionTest() {
        SEG_ClasificacionRapida__c regla1 = [SELECT Id FROM SEG_ClasificacionRapida__c WHERE Name = 'CR4'];
        
        Case caso = [SELECT Id FROM Case WHERE Subject = 'test Seguimiento'];
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

        Test.startTest();   
        caso.SEG_ClasificacionRapida__c = regla1.Id;
        update caso;
        
        Test.stopTest();
        
        Case casoRes = [SELECT SEG_ClasificacionRapida__c FROM Case WHERE Subject = 'test Seguimiento'];
        System.assert(casoRes.SEG_ClasificacionRapida__c != null);
        }
    }

    @isTest
    public static void desplanificarCasos() {

        //Habilitar la ejecución de la lógica después de la primera ejecución de SEG_Case_BU_TRHan
        SEG_Modificadores_Trigger.activarModificador('SEG_Case_BU_TRHan: reejecutar lógica');
        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();

        //Insertar casos planificados
        Case caso1 = new Case();
        caso1.RecordTypeId = recordTypeCaso;
        caso1.Status = 'Planificado';
        caso1.SEG_Fecha_planificaci_n__c = System.now().addDays(1);

        Case caso2 = new Case();
        caso2.RecordTypeId = recordTypeCaso;
        caso2.Status = 'Planificado';
        caso2.SEG_Fecha_planificaci_n__c = System.now().addDays(1);

        insert new List<Case>{caso1, caso2};

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

        Test.startTest();
        //Desplanificar caso vaciando la fecha de planificación
        caso1.SEG_Fecha_planificaci_n__c = null;
        //Desplanificar caso saliendo del estado "Planificado"
        caso2.Status = 'Activo';
        caso2.SEG_Subestado__c = null;
        update new List<Case>{caso1, caso2};
        Test.stopTest();

        //Deshabilitar la ejecución de la lógica después de la primera ejecución de SEG_Case_BU_TRHan
        SEG_Modificadores_Trigger.desactivarModificador('SEG_Case_BU_TRHan: reejecutar lógica');
        
        //Validar
        Map<Id, Case> casos = new Map<Id, Case>(
            [SELECT Status, SEG_Subestado__c, SEG_Fecha_planificaci_n__c
                FROM Case WHERE Id IN :new List<Id>{caso1.Id, caso2.Id}]
        );

        caso1 = casos.get(caso1.Id);
        System.assert(
            caso1.Status == 'Activo' && caso1.SEG_Subestado__c == 'En curso' && caso1.SEG_Fecha_planificaci_n__c == null,
            'Al vaciar la fecha de planificación el caso debería volver a estado Activo - En curso.'
        );

        caso2 = casos.get(caso2.Id);
        System.assert(
            caso2.Status == 'Activo' && caso2.SEG_Fecha_planificaci_n__c == null,
            'Al salir del estado "Planificado" la fecha de planificación debería vaciarse.'
        );
        }
    }

    @isTest
    public static void mostrarCargosContacto() {
        
        Contact contacto = [SELECT id, lastname FROM Contact WHERE lastname = 'Contacto SEG 1'LIMIT 1];
        Account cuenta = [SELECT id FROM Account WHERE Name = 'Empresa Test 2' LIMIT 1];
        Case caso = new Case();
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso.Subject = 'prueba';
        caso.Status = 'Pendiente';
        insert caso;
        
        AccountContactRelation relacion = new AccountContactRelation();
        relacion.AccountId = cuenta.Id;
        relacion.ContactId = contacto.id;
        relacion.SEG_Cargos_Operativa__c = 'AVALES CANCELACION';
        relacion.SEG_Creditos_sindicados__c = 'ASESOR CONTRATO';
        insert relacion; 
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

        Test.startTest();  
        
        caso.accountId = cuenta.id;
        caso.contactId = contacto.id;
        update caso;
        
        Test.stopTest();
        Case casoCargo = [SELECT id, SEG_Cargos_Operativa__c,SEG_Creditos_sindicadosContacto__c, accountId, ContactId FROM Case WHERE Subject = 'prueba'];

        System.assert(casoCargo.SEG_Cargos_Operativa__c != null);
        System.assert(casoCargo.SEG_Creditos_sindicadosContacto__c != null);
        }
    }

    @isTest
        public static void enviarMailAlCierreCasoPadre_test() {
        List<Id> casos = new List<Id>();
        List<Case> caso1 = [SELECT id, contactid, accountid, SEG_NO_AR_Account__c,SEG_No_AR_Contact__c, ContactEmail, subject , SEG_Idioma__C FROM Case WHERE Subject = 'test 2' LIMIT 1];
        
        casos.add(caso1[0].id);
        Map<Id,Case> mapaCasos = new map<Id,Case>();
        mapacasos.put(caso1[0].id, caso1[0]);
        String datosCasosPadre = JSON.serialize(mapaCasos);
      
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

        Test.starttest();
            SEG_Case_BU_TRHan.enviarMailAlCierreCasoPadre(casos, datosCasosPadre);
        Test.stopTest();
        System.assert(datosCasosPadre != null);
        }
    }
    
    @isTest
    public static void cambiarEstadoSLA_test() {
		Case caso = [SELECT Id,Status FROM Case WHERE Subject = 'test 2'];
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

        Test.startTest();
        caso.Status = 'Pendiente';
        update caso;       
        Test.stopTest();
        Case casoRes = [SELECT Id, SEG_ClasificacionRapida__c,Status, CC_MCC_Motivo__c FROM Case WHERE Subject = 'test 2'];
        System.assert(casoRes.Status != null);
        }
    }
    

    @isTest
    public static void rellenarClienteCabeceraUpdate_test(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT Id, Account.Name FROM Case WHERE Subject = 'test 2' LIMIT 1];
		Account cuentaSEG1 = new Account();
        cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        cuentaSEG1.Name = 'Test';
        cuentaSEG1.SEG_DominioMail__c = '@cuentaSEGTest';
        cuentaSEG1.CC_Numero_Documento__c = '11111111F';
        cuentaSEG1.SEG_No_enviar_Acuse_Recibo_Empresa__c = false;
        insert cuentaSEG1;
        caso.OwnerId = usuarioTest.Id;
        update caso;
        Test.startTest();    
            System.runAs ( new User(Id = UserInfo.getUserId()) ) { 
                caso.AccountId = cuentaSEG1.Id;  
                update caso;
            }
        Test.stopTest();
        
        Case casoRes = [SELECT Id, Account.name, AccountId ,SEG_Cliente_de_la_cabecera__c  FROM Case WHERE Subject = 'test 2' LIMIT 1];
        System.assertEquals(casoRes.Account.Name, casoRes.SEG_Cliente_de_la_cabecera__c, 'No se ha modificado la cuenta del caso');
        
    }

    @isTest
    public static void rellenarBuzonZonaUpdate_test(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso2 = new Case();
        caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso2.Subject = 'rellenarBuzonZonaUpdate_test';
        caso2.Status = 'Pendiente';
        caso2.SEG_Organizacion__c = 'Banca Corporativa';
        caso2.SEG_Zona__c = 'Corporativa';
        caso2.OwnerId = usuarioTest.Id;
        insert caso2;
 
        Test.startTest();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) { 
            caso2.SEG_Organizacion__c = 'Centro Empresas';
            caso2.SEG_Zona__c = 'Empresas Madrid';
			update caso2;  
        }
        Test.stopTest();
        Case casoRes = [SELECT Id, SEG_Buz_n_de_la_zona__c  FROM Case WHERE Subject = 'rellenarBuzonZonaUpdate_test'];
        SEG_Buzon__mdt buzon = [SELECT Id, SEG_Zona__c, SEG_Organizacion__c, SEG_Correo_de_procedencia__c, SEG_EMail_SF__c FROM SEG_Buzon__mdt WHERE SEG_Zona__c = :caso2.SEG_Zona__c AND SEG_Organizacion__c =: caso2.SEG_Organizacion__c AND (NOT SEG_EMail_SF__c LIKE 'Invalid%') LIMIT 1];
        System.assertEquals(buzon.SEG_Correo_de_procedencia__c, casoRes.SEG_Buz_n_de_la_zona__c, 'No se ha modificado el buzon de la zona del caso');
    }

    @isTest
    public static void marcaTaskConnectTest(){
 
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        CC_MCC__c tematica = [SELECT Id FROM CC_MCC__c WHERE Name ='Tematica2'];
        CC_MCC__c producto = [SELECT Id FROM CC_MCC__c WHERE Name ='Producto2'];
        CC_MCC__c motivo = [SELECT Id FROM CC_MCC__c WHERE Name ='Motivo2'];
        List<CC_Grupo_Colaborador__c> lstGrupos = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE SEG_envio_a_TaskConnect__c = true LIMIT 2];

        Case caso2 = new Case();
        caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso2.Subject = 'PruebaTaskConnect';
        caso2.Status = 'Pendiente';
        caso2.SEG_Organizacion__c = 'Banca Corporativa';
        caso2.SEG_Zona__c = 'Corporativa';
        caso2.OwnerId = usuarioTest.Id;
        caso2.CC_MCC_Tematica__c = tematica.Id;
        caso2.CC_MCC_ProdServ__c = producto.Id;
        caso2.CC_MCC_Motivo__c = motivo.Id;
        caso2.SEG_Grupo__c = lstGrupos[0].Id;
        insert caso2;
 
        Test.startTest();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) { 
            caso2.SEG_Grupo__c = lstGrupos[1].Id;
			update caso2;  
        }
        Test.stopTest();
        Case casoUpdates = [SELECT Id, SEG_sincronizado_con_TaskConnect__c FROM Case WHERE Subject = 'PruebaTaskConnect' LIMIT 1];
        System.assertEquals(true, casoUpdates.SEG_sincronizado_con_TaskConnect__c, 'No se ha modificado el buzon de la zona del caso');
    }

    @isTest
    public static void asignarSlaNivelMCCTest(){
 
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        CC_MCC__c tematica = [SELECT Id FROM CC_MCC__c WHERE Name ='Tematica SLA'];
        CC_MCC__c producto = [SELECT Id FROM CC_MCC__c WHERE Name ='Producto SLA'];
        CC_MCC__c motivo = [SELECT Id FROM CC_MCC__c WHERE Name ='Motivo SLA'];
        CC_MCC__c detalle = [SELECT Id FROM CC_MCC__c WHERE Name ='Detalle SLA'];
        List<CC_Grupo_Colaborador__c> lstGrupos = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE SEG_envio_a_TaskConnect__c = true LIMIT 2];

        Case caso2 = new Case();
        caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso2.Subject = 'Prueba SLA MCC';
        caso2.Status = 'Pendiente';
        caso2.SEG_Organizacion__c = 'Banca Corporativa';
        caso2.SEG_Zona__c = 'Corporativa';
        caso2.OwnerId = usuarioTest.Id;
        caso2.SEG_Grupo__c = lstGrupos[0].Id;
        insert caso2;
 
        Test.startTest();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) { 
            caso2.CC_MCC_Tematica__c = tematica.Id;
            caso2.CC_MCC_ProdServ__c = producto.Id;
            caso2.CC_MCC_Motivo__c = motivo.Id;
            caso2.SEG_Detalle__c = detalle.Id;
			update caso2;
        }
        Test.stopTest();
        Case casoUpdates = [SELECT Id, SEG_SLA_cliente_case__c FROM Case WHERE Subject = 'Prueba SLA MCC' LIMIT 1];
        System.assertEquals('Máximo 3 días hábiles desde la recepción', casoUpdates.SEG_SLA_cliente_case__c, 'No se ha modificado el SLA');
    }

    @isTest
    public static void reaperturaCasoGrupoInactivoTest(){
 
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        List<CC_Grupo_Colaborador__c> lstGrupos = [SELECT Id, RecordType.DeveloperName, SEG_GrupoSegmentos__c, OS_Negocio__c FROM CC_Grupo_Colaborador__c LIMIT 2];

        //Creamos el caso cerrado para reabrir posteriormente
        Case caso = new Case();
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso.Subject = 'Prueba Grupo Alternativo';
        caso.Status = 'Cerrado';
        caso.SEG_Organizacion__c = 'Banca Corporativa';
        caso.SEG_Zona__c = 'Corporativa';
        caso.OwnerId = usuarioTest.Id;
        caso.SEG_Grupo__c = lstGrupos[0].Id;
        insert caso;

        //Asignamos el grupo alternativo al grupo del caso e inactivamos el grupo del caso
        lstGrupos[0].SEG_Inactivo__c = true;
        lstGrupos[0].SEG_GrupoAlternativo__c = lstGrupos[1].Id;
        update lstGrupos;
 
        Test.startTest();
            System.runAs(usuarioTest) { 
                caso.Status = 'Activo';
                update caso;
            }
        Test.stopTest();

        Case casoUpdates = [SELECT Id, SEG_Grupo__c FROM Case WHERE Subject = 'Prueba Grupo Alternativo' LIMIT 1];
        System.assertEquals(lstGrupos[1].Id, casoUpdates.SEG_Grupo__c, 'No se ha modificado el grupo');
    }

    @isTest
    public static void buSRContratosTest(){
 
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];

        //Creamos el caso 
        Case caso = new Case();
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso.Subject = 'Prueba primer caso';
        caso.Status = 'Pendiente';
        caso.SEG_Organizacion__c = 'Banca Corporativa';
        caso.SEG_Zona__c = 'Corporativa';
        caso.OwnerId = usuarioTest.Id;
        caso.SEG_SRContratos__c ='Prueba';

		Case caso2 = new Case();
        caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
        caso2.Subject = 'Prueba segundo caso';
        caso2.Status = 'Pendiente';
        caso2.SEG_Organizacion__c = 'Banca Corporativa';
        caso2.SEG_Zona__c = 'Corporativa';
        caso2.OwnerId = usuarioTest.Id;
        caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();

        insert caso;
        insert caso2;

        Test.startTest();
            System.runAs(usuarioTest) { 
                caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
                update caso;
                caso2.Status = 'Activo';
                update caso2;
            }
        Test.stopTest();

        Case casoUpdates = [SELECT SEG_SRContratos__c,SEG_Check_Contratos__c FROM Case WHERE Subject = 'Prueba primer caso' LIMIT 1];
		Case casoUpdates2 = [SELECT SEG_SRContratos__c FROM Case WHERE Subject = 'Prueba segundo caso' LIMIT 1];

        System.assertEquals('Contratos',casoUpdates.SEG_SRContratos__c);
        System.assertEquals(true,casoUpdates.SEG_Check_Contratos__c);
		System.assertEquals(null,casoUpdates2.SEG_SRContratos__c);
    }
}