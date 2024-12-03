@isTest
public with sharing class SEG_ReclamacionesAgotadas_Test {

	@TestSetup
	public static void crearDatosPrueba() {
		Id recordTypeSeg = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
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
		Id recordDet = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
		Id recordMotiv = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
		Id recordProdServ = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
		Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
		Id opSegId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
		Id autoSegId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('SEG_GrupoAutomaticoSegmentos').getRecordTypeId();
		Id grColId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
		Id accRecTypeCentro = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
		Id contactRecord = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

		List<SObject> listadoTotal = new List<SObject> ();
		
		Contact conLaborador = new Contact(RecordTypeId = contactRecord, LastName = 'Gestor', CC_Idioma__c = 'ga');
		//listadoTotal.add(congestor);
		insert conLaborador;
		
		Account cuentaGestora = new Account(Name = 'OficinaGestora', CC_Numero_Oficina__c = '00123',CC_Tipo_Centro__c = 'Of', SEG_Organizacion__c= 'Banca Corporativa' , 
		SEG_Zona__c = 'Corporativa', recordTypeId = accRecTypeCentro,  SEG_Empleado_gestor_Segmentos__c = conLaborador.id );
		insert cuentaGestora;

		Contact congestor = new Contact(LastName = 'Gestor', CC_Idioma__c = 'ga');
		listadoTotal.add(congestor);
		//insert congestor;

		Account cuenta = new Account(Name = 'Cuenta', AV_EAPGestor__c = congestor.Id, SEG_Prioridad_Carterizacion_Segmentos__c = true, SEG_Oficina_Gestora_Segmentos__c = cuentaGestora.id, SEG_Empleado_gestor_Segmentos__c = conLaborador.id);
		listadoTotal.add(cuenta);
		//insert cuenta;

		Contact conEs = new Contact(LastName = 'ContactoES', AccountId = cuenta.Id, CC_Idioma__c = 'es');
		//insert conEs;
		listadoTotal.add(conEs);

		Contact conCa = new Contact(LastName = 'ContactoCA', AccountId = cuenta.Id, CC_Idioma__c = 'ca');
		//insert conCa;
		listadoTotal.add(conCa);

		Contact conEn = new Contact(LastName = 'ContactoEN', AccountId = cuenta.Id, CC_Idioma__c = 'en');
		//insert conEn;
		listadoTotal.add(conEn);

		Contact conGa = new Contact(LastName = 'ContactoGA', AccountId = cuenta.Id, CC_Idioma__c = 'ga');
		//insert conGa;
		listadoTotal.add(conGa);

		CC_MCC__c mccDetalle = new CC_MCC__c();
		mccDetalle.RecordTypeId = recordDet;
		mccDetalle.Name = 'Detalle';
		mccDetalle.CC_Tipo_Cliente__c = 'Cliente';
		mccDetalle.CC_Codigo_Externo__c = 'DE-000003';
		//insert mccDetalle;
		listadoTotal.add(mccDetalle);

		CC_MCC__c mccMotivo = new CC_MCC__c();
		mccMotivo.RecordTypeId = recordMotiv;
		mccMotivo.Name = 'Motivo';
		mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
		mccMotivo.CC_Codigo_Externo__c = 'DE-000004';
		//insert mccMotivo;
		listadoTotal.add(mccMotivo);

		CC_MCC__c mccProdServ = new CC_MCC__c();
		mccProdServ.RecordTypeId = recordProdServ;
		mccProdServ.Name = 'ProdSev';
		mccProdServ.CC_Tipo_Cliente__c = 'Cliente';
		mccProdServ.CC_Codigo_Externo__c = 'DE-000005';
		///insert mccProdServ;
		listadoTotal.add(mccProdServ);

		CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.RecordTypeId = recordTem;
		mccTematica.Name = 'Tematica';
		mccTematica.CC_Tipo_Cliente__c = 'Cliente';
		mccTematica.CC_Codigo_Externo__c = 'DE-000006';
		mccTematica.CC_Canal_Operativo__c ='Sin canal';
		//insert mccTematica;
		listadoTotal.add(mccTematica);

		CC_MCC__c mccTematicaColaborador = new CC_MCC__c();
		mccTematicaColaborador.RecordTypeId = recordTem;
		mccTematicaColaborador.Name = 'Tematica';
		mccTematicaColaborador.CC_Tipo_Cliente__c = 'Cliente';
		mccTematicaColaborador.CC_Codigo_Externo__c = 'DE-000007';
		mccTematicaColaborador.CC_Canal_Operativo__c ='Sin canal';
		//insert mccTematicaColaborador;
		listadoTotal.add(mccTematicaColaborador);
		
		
		//Grupo Operativo Segmentos
		CC_Grupo_Colaborador__c grupoOpSeg = new CC_Grupo_Colaborador__c();
		grupoOpSeg.RecordTypeId = opSegId;
		listadoTotal.add(grupoOpSeg);

		//Grupo Automático Segmentos
		CC_Grupo_Colaborador__c grupoAutoSeg = new CC_Grupo_Colaborador__c();
		grupoAutoSeg.Name = 'BO*';
		grupoAutoSeg.RecordTypeId = autoSegId;
		listadoTotal.add(grupoAutoSeg);

		//Gestor Comercial
		CC_Grupo_Colaborador__c grupoGestorComercial = new CC_Grupo_Colaborador__c();
		grupoGestorComercial.Name = 'Gestor Comercial';
		grupoGestorComercial.RecordTypeId = autoSegId;
		listadoTotal.add(grupoGestorComercial);

		//Gestor Operativa Nacional
		CC_Grupo_Colaborador__c grupoGestorOperativaNacional = new CC_Grupo_Colaborador__c();
		grupoGestorOperativaNacional.Name = 'Gestor Operativa Nacional';
		grupoGestorOperativaNacional.RecordTypeId = autoSegId;
		listadoTotal.add(grupoGestorOperativaNacional);

		//Gestor Operativa Internacional
		CC_Grupo_Colaborador__c grupoGestorOperativaInternacional = new CC_Grupo_Colaborador__c();
		grupoGestorOperativaInternacional.Name = 'Gestor Operativa Internacional';
		grupoGestorOperativaInternacional.RecordTypeId = autoSegId;
		listadoTotal.add(grupoGestorOperativaInternacional);

		//Gestor Financiación Estructurada
		CC_Grupo_Colaborador__c grupoGestorFinanciacionEstruct = new CC_Grupo_Colaborador__c();
		grupoGestorFinanciacionEstruct.Name = 'Gestor Financiación Estructurada';
		grupoGestorFinanciacionEstruct.RecordTypeId = autoSegId;
		listadoTotal.add(grupoGestorFinanciacionEstruct);

		//Asignamos el RecordType ='Grupo Colaborador'
		CC_Grupo_Colaborador__c grupoRTGrupoCol = new CC_Grupo_Colaborador__c();
		grupoRTGrupoCol.Name = 'BO 112';
		grupoRTGrupoCol.RecordTypeId = opSegId;
		grupoRTGrupoCol.SEG_GrupoSegmentos__c = true;
		grupoRTGrupoCol.SEG_CierreAutomaticoSR__c = false;
		grupoRTGrupoCol.SEG_Grupo_Estandar__c = false;
		grupoRTGrupoCol.SEG_Inactivo__c = false;
		grupoRTGrupoCol.SEG_No_visible__c = false;
		grupoRTGrupoCol.SEG_Padre__c = false;

		listadoTotal.add(grupoRTGrupoCol);

		CC_Grupo_Colaborador__c grupoRTGrupoCol2 = new CC_Grupo_Colaborador__c();
		grupoRTGrupoCol2.Name = 'BO 113';
		grupoRTGrupoCol2.RecordTypeId = grColId;
		grupoRTGrupoCol2.SEG_GrupoSegmentos__c = true;
		grupoRTGrupoCol2.SEG_CierreAutomaticoSR__c = false;
		grupoRTGrupoCol2.SEG_Grupo_Estandar__c = false;
		grupoRTGrupoCol2.SEG_Inactivo__c = false;
		grupoRTGrupoCol2.SEG_No_visible__c = false;
		grupoRTGrupoCol2.SEG_Padre__c = false;
		listadoTotal.add(grupoRTGrupoCol2);
		insert listadoTotal;


		EmailTemplate emailEs = new EmailTemplate();
		emailEs.DeveloperName = 'Reclamacion_1_1616749645917';
		emailEs.Encoding = 'ISO-8859-1';
		emailEs.FolderId = thisUser.Id;
		emailEs.Subject = '[num_casos]';
		emailEs.IsActive = true;
		emailEs.Name = 'Reclamacion 1º';
		emailEs.TemplateType = 'custom';
		emailEs.TemplateStyle = 'none';
		emailEs.HtmlValue = '<html><head><title></title></head><body style="height: auto; min-height: auto;">1&ordm; reclamaci&oacute;n enviada con la SR de seguimiento&nbsp;{{{Case.CaseNumber}}}<style type="text/css">table {font-family: arial, sans-serif; border-collapse: collapse;width: 100%;}td, th {border: 1px solid #dddddd; text-align: left; padding: 8px;}tr:nth-child(even) { background-color: #dddddd;}</style><table><tr><th>N&uacute;mero Contrato</th><th>Fecha Contrato</th><th>Descripci&oacute;n Contrato</th></tr></table></body></html>';
		System.runAs(thisUser) {
			insert emailEs;
		}

		//Grupo Colaborador con RT Grupo Colaborador
		SEG_Plantilla__c plantilla = new SEG_Plantilla__C();
		plantilla.Name = 'Plantilla Col';
		plantilla.SEG_PlantillaCastellanoID__c = emailEs.Id;
		insert plantilla;

		//Creamos una plantilla para usar en RT = 'Grupo Colaborador'
		CC_Grupo_Colaborador_Plantilla__c plantillagrupo = new CC_Grupo_Colaborador_Plantilla__c();
		plantillagrupo.CC_Operativa__c = 'Trasladar';
		plantillagrupo.SEG_Plantilla__c = plantilla.id;
		plantillagrupo.CC_Grupo_Colaborador__c = grupoRTGrupoCol2.id;
		insert plantillagrupo;
		
		List<SObject> listadoTotal2 = new List<SObject> ();
		//Grupo MCC link Grupo Colaborador
		CC_MCC_Grupo_Colaborador__c grupoCol = new CC_MCC_Grupo_Colaborador__c();
		grupoCol.Name = 'Colaborador';
		grupoCol.CC_MCC__c = mccTematicaColaborador.Id;
		grupoCol.CC_Grupo_Colaborador__c = grupoRTGrupoCol2.id;
		grupoCol.SEG_Zona__c = 'Todas';
		grupoCol.SEG_Organizacion__c = 'Todas';
		listadoTotal2.add( grupoCol);

		//Relacionamos MCC con Grupos Colaborador
		CC_MCC_Grupo_Colaborador__c GrupoDetalle = new CC_MCC_Grupo_Colaborador__c();
		GrupoDetalle.Name = 'detalle';
		GrupoDetalle.CC_MCC__c = mccDetalle.Id;
		GrupoDetalle.CC_Grupo_Colaborador__c = grupoOpSeg.Id;
		GrupoDetalle.SEG_Zona__c = 'Todas';
		GrupoDetalle.SEG_Organizacion__c = 'Todas';
		GrupoDetalle.SEG_Grupo_respuesta__c = grupoRTGrupoCol.id;
		listadoTotal2.add( GrupoDetalle);

		CC_MCC_Grupo_Colaborador__c GrupoMotivo = new CC_MCC_Grupo_Colaborador__c();
		GrupoMotivo.Name = 'motivo';
		GrupoMotivo.CC_MCC__c = mccMotivo.Id;
		GrupoMotivo.CC_Grupo_Colaborador__c = grupoOpSeg.Id;
		GrupoMotivo.SEG_Zona__c = 'Todas';
		GrupoMotivo.SEG_Organizacion__c = 'Banca Corporativa';
		GrupoMotivo.SEG_Grupo_respuesta__c = grupoRTGrupoCol.id;
		listadoTotal2.add( GrupoMotivo);

		CC_MCC_Grupo_Colaborador__c GrupoProdServ = new CC_MCC_Grupo_Colaborador__c();
		GrupoProdServ.Name = 'prodServ';
		GrupoProdServ.CC_MCC__c = mccProdServ.Id;
		GrupoProdServ.CC_Grupo_Colaborador__c = grupoAutoSeg.Id;
		GrupoProdServ.SEG_Grupo_respuesta__c = grupoRTGrupoCol.id;
		listadoTotal2.add( GrupoProdServ);

		CC_MCC_Grupo_Colaborador__c GrupoTematica = new CC_MCC_Grupo_Colaborador__c();
		GrupoTematica.Name = 'Tematica';
		GrupoTematica.CC_MCC__c = mccTematica.Id;
		GrupoTematica.CC_Grupo_Colaborador__c = grupoOpSeg.Id;
		GrupoTematica.SEG_Zona__c = 'Corporativa';
		GrupoTematica.SEG_Organizacion__c = 'Banca Corporativa';
		GrupoTematica.SEG_Grupo_respuesta__c = grupoRTGrupoCol.id;
		listadoTotal2.add( GrupoTematica);

		CC_MCC_Grupo_Colaborador__c GrupoGesComer = new CC_MCC_Grupo_Colaborador__c();
		GrupoGesComer.Name = 'Gestor Comercial';
		GrupoGesComer.CC_MCC__c = mccTematica.Id;
		GrupoGesComer.CC_Grupo_Colaborador__c = grupoGestorComercial.Id;
		listadoTotal2.add( GrupoGesComer);

		CC_MCC_Grupo_Colaborador__c GrupoGesOpNacional = new CC_MCC_Grupo_Colaborador__c();
		GrupoGesOpNacional.Name = 'Gestor Operativa Nacional';
		GrupoGesOpNacional.CC_MCC__c = mccTematica.Id;
		GrupoGesOpNacional.CC_Grupo_Colaborador__c = grupoGestorOperativaNacional.Id;
		listadoTotal2.add( GrupoGesOpNacional);

		CC_MCC_Grupo_Colaborador__c GrupoGesOpInt = new CC_MCC_Grupo_Colaborador__c();
		GrupoGesOpInt.Name = 'Gestor Operativa Internacional';
		GrupoGesOpInt.CC_MCC__c = mccTematica.Id;
		GrupoGesOpInt.CC_Grupo_Colaborador__c = grupoGestorOperativaInternacional.Id;
		listadoTotal2.add( GrupoGesOpInt);

		CC_MCC_Grupo_Colaborador__c GrupoGesFinEs = new CC_MCC_Grupo_Colaborador__c();
		GrupoGesFinEs.Name = 'Gestor Financiación Estructurada';
		GrupoGesFinEs.CC_MCC__c = mccTematica.Id;
		GrupoGesFinEs.CC_Grupo_Colaborador__c = grupoGestorFinanciacionEstruct.Id;
		listadoTotal2.add( GrupoGesFinEs);

		//Plantilla
		SEG_Plantilla__c plantilla1 = new SEG_Plantilla__c();
		plantilla1.Name = 'Review';
		plantilla1.SEG_Activa__c = true;
		plantilla1.SEG_TipoOperativa__c = 'Reclamaciones';
		plantilla1.Reclamaciones__c = 'Reclamaciones Agotadas';
		plantilla1.SEG_Organizacion__c = 'Banca Corporativa';
		plantilla1.SEG_Zona__c = 'Corporativa';
		listadoTotal2.add( plantilla1);

		//Creación nuevos casos asociado al contacto 
		Case casoDetalle = new Case(AccountId = cuenta.Id, ContactId = conEs.Id, Status = 'Activo', CC_Idioma__c = 'es', Subject = 'Detalle',
		                            CC_Tipo_Cliente__c = 'Cliente', Origin = 'Comentarios Stores', CC_Tipo_Contacto__c = 'Consulta', SEG_Organizacion__c = 'Banca Corporativa',
		                            SEG_Zona__c = 'Corporativa', CC_Canal_Procedencia__c = 'Google Play Store', SEG_Detalle__c = mccDetalle.Id);
		listadoTotal2.add( casoDetalle);

		Case casoMotivo = new Case(AccountId = cuenta.Id, ContactId = conEs.Id, Status = 'Activo', CC_Idioma__c = 'es', Subject = 'Motivo',
		                           CC_Tipo_Cliente__c = 'Cliente', Origin = 'Comentarios Stores', CC_Tipo_Contacto__c = 'Consulta', SEG_Organizacion__c = 'Banca Corporativa',
		                           SEG_Zona__c = 'Corporativa', CC_Canal_Procedencia__c = 'Google Play Store', CC_MCC_Motivo__c = mccMotivo.id);
		listadoTotal2.add( casoMotivo);

		Case casoProdServ = new Case(AccountId = cuenta.Id, ContactId = conEs.Id, Status = 'Activo', CC_Idioma__c = 'es', Subject = 'ProdServ',
		                             CC_Tipo_Cliente__c = 'Cliente', Origin = 'Comentarios Stores', CC_Tipo_Contacto__c = 'Consulta', SEG_Organizacion__c = 'Banca Corporativa',
		                             SEG_Zona__c = 'Corporativa', CC_Canal_Procedencia__c = 'Google Play Store', CC_MCC_ProdServ__c = mccProdServ.id);
		listadoTotal2.add( casoProdServ);

		Case casoTematica = new Case(AccountId = cuenta.Id, ContactId = conEs.Id, Status = 'Activo', CC_Idioma__c = 'es', Subject = 'Tematica',
		                             CC_Tipo_Cliente__c = 'Cliente', Origin = 'Comentarios Stores', CC_Tipo_Contacto__c = 'Consulta', SEG_Organizacion__c = 'Banca Corporativa',
		                             SEG_Zona__c = 'Corporativa', CC_Canal_Procedencia__c = 'Google Play Store', CC_MCC_Tematica__c = mccTematica.id);
		listadoTotal2.add( casoTematica);

		Case GesComercial = new Case(AccountId = cuenta.Id, ContactId = conEs.Id, Status = 'Activo', CC_Idioma__c = 'es', Subject = 'Comercial',
		                             CC_Tipo_Cliente__c = 'Cliente', Origin = 'Comentarios Stores', CC_Tipo_Contacto__c = 'Consulta',
		                             CC_Canal_Procedencia__c = 'Google Play Store', CC_MCC_Tematica__c = mccTematica.id);
		listadoTotal2.add( GesComercial);

		Case colaborador = new Case(AccountId = cuenta.Id, ContactId = conEs.Id, Status = 'Activo', CC_Idioma__c = 'es', Subject = 'colab',
		                            CC_Tipo_Cliente__c = 'Cliente', Origin = 'Comentarios Stores', CC_Tipo_Contacto__c = 'Consulta',
		                            CC_Canal_Procedencia__c = 'Google Play Store', CC_MCC_Tematica__c = mccTematicaColaborador.id);
		listadoTotal2.add( colaborador);
		insert listadoTotal2;

	}

	@isTest
	static void testEntradaDetalle()
	{
		//Contact contact = [SELECT id, CC_Idioma__c FROM Contact WHERE LastName = 'ContactoGA' LIMIT 1];
		List<Case> casos = [SELECT id, AccountId, SEG_Detalle__c, CC_MCC_Motivo__c,CC_MCC_ProdServ__c,CC_MCC_Tematica__c,SEG_Numero_de_centro__c,
					SEG_Zona__c, SEG_Organizacion__c, Account.AV_OficinaPrincipal__r.CC_Numero_Oficina__c, SEG_Grupo__c, Subject
					 FROM Case WHERE Subject = 'Detalle' OR  Subject = 'Motivo' OR Subject = 'ProdServ' OR Subject = 'Tematica' OR Subject = 'Comercial' OR Subject = 'colab' ];

	    List<Case> casoDetalle = new List<case>();
		List<Case> casoMotivo = new List<case>();
		List<Case> casoProdServ = new List<case>();
		List<Case> casoTematica = new List<case>();
		List<Case> casoComercial = new List<case>();
		List<Case> casoColab = new List<case>();
		
		for (case casosTemas : casos) {
			if(casosTemas.Subject == 'Detalle'){
				casoDetalle.add(casosTemas);
			}
			if(casosTemas.Subject == 'Motivo'){
				casoMotivo.add(casosTemas);
			}
			if(casosTemas.Subject == 'ProdServ'){
				casoProdServ.add(casosTemas);
			}
			if(casosTemas.Subject == 'Tematica'){
				casoTematica.add(casosTemas);
			}
			if(casosTemas.Subject == 'Comercial'){
				casoComercial.add(casosTemas);
			}
			if(casosTemas.Subject == 'colab'){
				casoColab.add(casosTemas);
			}
		}

		List<Account> lstAccount = [SELECT SEG_Prioridad_Carterizacion_Segmentos__c, SEG_Empleado_gestor_Segmentos__c, AV_EAPGestor__c,
		                            SEG_GestorOperativaNacional__c, SEG_GestorOperativaInternacional__c, SEG_GestorFinEstructurada__c, AV_OficinaPrincipal__r.CC_Numero_Oficina__c
		                            FROM Account WHERE Id =: casos[0].AccountId];

		Map<String, List<SEG_Gestor_Grupo__c>> mapEmpleadoGestorGrupo0 = getMapEmpleadoLstGestoresGrupos(lstAccount.get(0));
		List<CC_MCC_Grupo_Colaborador__c> lstMCCGrupos0 = getListMccGrupoColaborador(casos[0]);
		List<CC_MCC_Grupo_Colaborador__c> lstMCCGrupos1 = getListMccGrupoColaborador(casos[1]);
		List<CC_MCC_Grupo_Colaborador__c> lstMCCGrupos2 = getListMccGrupoColaborador(casos[2]);
		List<CC_MCC_Grupo_Colaborador__c> lstMCCGrupos3 = getListMccGrupoColaborador(casos[3]);
		List<CC_MCC_Grupo_Colaborador__c> lstMCCGrupos4 = getListMccGrupoColaborador(casos[4]);
		List<CC_MCC_Grupo_Colaborador__c> lstMCCGrupos5 = getListMccGrupoColaborador(casos[5]);

		Test.startTest();
		SEG_ReclamacionesAgotadas.tratarAvisosAgotadosMail(lstAccount.get(0), casos[0], lstMCCGrupos0, mapEmpleadoGestorGrupo0);
		SEG_ReclamacionesAgotadas.tratarAvisosAgotadosMail(lstAccount.get(0), casos[1], lstMCCGrupos1, mapEmpleadoGestorGrupo0);
		SEG_ReclamacionesAgotadas.tratarAvisosAgotadosMail(lstAccount.get(0), casos[2], lstMCCGrupos2, mapEmpleadoGestorGrupo0);
		SEG_ReclamacionesAgotadas.tratarAvisosAgotadosMail(lstAccount.get(0), casos[3], lstMCCGrupos3, mapEmpleadoGestorGrupo0);
		SEG_ReclamacionesAgotadas.tratarAvisosAgotadosMail(lstAccount.get(0), casos[4], lstMCCGrupos4, mapEmpleadoGestorGrupo0);
		SEG_ReclamacionesAgotadas.tratarAvisosAgotadosMail(lstAccount.get(0), casos[5], lstMCCGrupos5, mapEmpleadoGestorGrupo0);
		Test.stopTest();
	}

	private static Map<String, List<SEG_Gestor_Grupo__c>> getMapEmpleadoLstGestoresGrupos(Account acc) {
		Set<Id> setAccGestor = new Set<Id> ();
		if (String.isNotBlank(acc.SEG_Empleado_gestor_Segmentos__c)) {
			setAccGestor.add(acc.SEG_Empleado_gestor_Segmentos__c);
		}
		if (String.isNotBlank(acc.AV_EAPGestor__c)) {
			setAccGestor.add(acc.AV_EAPGestor__c);
		}
		if (String.isNotBlank(acc.SEG_GestorOperativaNacional__c)) {
			setAccGestor.add(acc.SEG_GestorOperativaNacional__c);
		}
		if (String.isNotBlank(acc.SEG_GestorOperativaInternacional__c)) {
			setAccGestor.add(acc.SEG_GestorOperativaInternacional__c);
		}
		if (String.isNotBlank(acc.SEG_GestorFinEstructurada__c)) {
			setAccGestor.add(acc.SEG_GestorFinEstructurada__c);
		}
		List<SEG_Gestor_Grupo__c> gestores = [SELECT SEG_EmpleadoGestor__c, SEG_GrupoOperativa__c from SEG_Gestor_Grupo__c
		                                      where SEG_EmpleadoGestor__c IN :setAccGestor AND SEG_EmpleadoGestor__c != null];
		Map<String, List<SEG_Gestor_Grupo__c>> mapEmpleadoGestorGrupo = new Map<String, List<SEG_Gestor_Grupo__c>> ();
		for (SEG_Gestor_Grupo__c segGestorGrupo : gestores) {
			if (mapEmpleadoGestorGrupo.containsKey(segGestorGrupo.SEG_EmpleadoGestor__c)) {
				mapEmpleadoGestorGrupo.get(segGestorGrupo.SEG_EmpleadoGestor__c).add(segGestorGrupo);
			}
			else {
				mapEmpleadoGestorGrupo.put(segGestorGrupo.SEG_EmpleadoGestor__c, new List<SEG_Gestor_Grupo__c> { segGestorGrupo });
			}
		}
		return mapEmpleadoGestorGrupo;
	}

	private static List<CC_MCC_Grupo_Colaborador__c> getListMccGrupoColaborador(Case cs) {
		Set<Id> setMccIds = new Set<Id> ();
		List<Id> lstMCCGruposIds;
		lstMCCGruposIds = new List<Id> ();
		if (cs.SEG_Detalle__c != null) {
			setMccIds.add(cs.SEG_Detalle__c);
		}
		if (cs.CC_MCC_Motivo__c != null) {
			setMccIds.add(cs.CC_MCC_Motivo__c);
		}
		if (cs.CC_MCC_ProdServ__c != null) {
			setMccIds.add(cs.CC_MCC_ProdServ__c);
		}
		if (cs.CC_MCC_Tematica__c != null) {
			setMccIds.add(cs.CC_MCC_Tematica__c);
		}
		Map<Id, CC_MCC_Grupo_Colaborador__c> mapMCCs = new Map<id, CC_MCC_Grupo_Colaborador__c> ();
		if (setMccIds.size() > 0) {
			mapMCCs = new Map<id, CC_MCC_Grupo_Colaborador__c> ([SELECT Id, CC_Grupo_Colaborador__c, SEG_Grupo_respuesta__c,
			                                                    CC_Grupo_Colaborador__r.RecordType.DeveloperName, CC_MCC__c,
			                                                    SEG_Zona__c, SEG_Organizacion__c, CC_Grupo_Colaborador__r.Name
			                                                    FROM CC_MCC_Grupo_Colaborador__c
			                                                    WHERE CC_MCC__c IN :setMccIds AND CC_Grupo_Colaborador__c != null]);
		}
		return mapMCCs.values();
	}
}