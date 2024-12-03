@isTest
public with sharing class SEG_MetodosComunes_Test {

	@TestSetup
	public static void crearDatosPrueba() {

		Account cuenta = new Account(Name = 'Cuenta', AV_Idioma__c = '001');
		insert cuenta;

        Account centro = new Account(Name = 'Centro', AV_Idioma__c = '001', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId(), CC_Numero_Oficina__c = '111');
		insert centro;

        List<Contact> listContact = new List<Contact> ();
		Contact contacto = new Contact(LastName = 'Contacto', AccountId = cuenta.Id);
       	listContact.add(contacto);
        
        Account cuentaSEG1 = new Account();
        cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        cuentaSEG1.Name = 'Empresa segmentos';
        cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG1.AV_OficinaPrincipal__c = centro.id;
        cuentaSEG1.CC_Numero_Documento__c = '11111123F';
		cuentaSEG1.AV_Idioma__c = '003';
        insert cuentaSEG1;
        
        // Crear contactos para cuentas SEG.
        Contact contactoSEG1 = new Contact();
        contactoSEG1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contactoSEG1.LastName = 'Contacto SEG 1';
        contactoSEG1.AccountId = cuentaSEG1.Id;
        contactoSEG1.Email = 'test@test.com';
		contactoSEG1.CC_Idioma__c = 'ca';
        listContact.add(contactoSEG1);

        Contact empleado = new Contact();
        empleado.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        empleado.LastName = 'Empleado';
        empleado.AccountId = cuentaSEG1.Id;
        empleado.Email = 'mariadcra@test.com';
        listContact.add(empleado);
		
		Contact colab = new Contact();
        colab.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        colab.LastName = 'Empleadotestgr';
        colab.AccountId = cuentaSEG1.Id;
        colab.Email = 'mariadcrasdasa@test.com';
        listContact.add(colab);
        insert listContact;
        
        Account cuentaSEG2 = new Account();
        cuentaSEG2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        cuentaSEG2.Name = 'Cliente segmentos';
        cuentaSEG2.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG2.AV_OficinaPrincipal__c = centro.id;
        cuentaSEG2.SEG_GestorOperativaInternacional__c = empleado.id;
        cuentaSEG2.CC_Numero_Documento__c = '11111223F';
		cuentaSEG2.AV_Idioma__c = '003';
        insert cuentaSEG2;
        
		Id recordDet = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
		Id recordMotiv = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
		Id recordProdServ = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
		Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();

        List<CC_MCC__c> listaMCCs = new List<CC_MCC__c> ();
		CC_MCC__c mccDetalle = new CC_MCC__c();
		mccDetalle.RecordTypeId = recordDet;
		mccDetalle.Name = 'Detalle';
		mccDetalle.CC_Tipo_Cliente__c = 'Segmentos';
		mccDetalle.CC_Codigo_Externo__c = 'DE-000003';
		listaMCCs.add(mccDetalle);

		CC_MCC__c mccMotivo = new CC_MCC__c();
		mccMotivo.RecordTypeId = recordMotiv;
		mccMotivo.Name = 'Motivo';
		mccMotivo.CC_Tipo_Cliente__c = 'Segmentos';
		mccMotivo.CC_Codigo_Externo__c = 'DE-000004';
		listaMCCs.add(mccMotivo);

		CC_MCC__c mccProdServ = new CC_MCC__c();
		mccProdServ.RecordTypeId = recordProdServ;
		mccProdServ.Name = 'ProdSev';
		mccProdServ.CC_Tipo_Cliente__c = 'Segmentos';
		mccProdServ.CC_Codigo_Externo__c = 'DE-000005';
		listaMCCs.add(mccProdServ);

		CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.RecordTypeId = recordTem;
		mccTematica.Name = 'Tematica';
		mccTematica.CC_Tipo_Cliente__c = 'Segmentos';
		mccTematica.CC_Codigo_Externo__c = 'DE-000006';
		mccTematica.CC_Canal_Operativo__c = 'Oficina';
		listaMCCs.add(mccTematica);

		CC_MCC__c mccTematicaColaborador = new CC_MCC__c();
		mccTematicaColaborador.RecordTypeId = recordTem;
		mccTematicaColaborador.Name = 'TematicaColaborador';
		mccTematicaColaborador.CC_Tipo_Cliente__c = 'Segmentos';
		mccTematicaColaborador.CC_Codigo_Externo__c = 'DE-000007';
		mccTematica.CC_Canal_Operativo__c = 'Oficina';
		listaMCCs.add(mccTematicaColaborador);
        insert listaMCCs;
        
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
        
        SEG_Plantilla__c planAR = new SEG_Plantilla__c();
		planAR.Name = 'Acuse de recibo';
		planAR.SEG_Organizacion__c = 'Banca Corporativa;Centro Empresas;Instituciones;Centro Soporte Especialistas;Financiación Estructurada';
		planAR.SEG_Zona__c = 'Corporativa;Empresas Barcelona;Empresas Castilla La Mancha;Empresas Cataluña;Empresas Madrid;Empresas Valencia;Instituciones Canarias';
		planAR.SEG_TipoOperativa__c = 'Acuse de recibo';
		planAR.SEG_Activa__c = true;
		planAR.SEG_PlantillaCastellano__c = 'Firma BO';
		planAR.SEG_PlantillaCatalan__c = 'Firma CAT';
		planAR.SEG_PlantillaIngles__c = 'Firma IN';
		planAR.SEG_PlantillaEuskera__c = 'Firma EUSK';
		planAR.SEG_PlantillaGalego__c = 'Firma GAL';
		planAR.SEG_PlantillaCastellanoID__c = emailEs.Id;
        planAR.SEG_PlantillaInglesID__c = emailEs.Id;
		insert planAR;
		
		Id opSegId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
		Id autoSegId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('SEG_GrupoAutomaticoSegmentos').getRecordTypeId();
		Id grColId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
		
		//Grupo Operativo Segmentos
		CC_Grupo_Colaborador__c grupoOpSeg = new CC_Grupo_Colaborador__c();
		grupoOpSeg.RecordTypeId = opSegId;
        grupoOpSeg.SEG_GrupoSegmentos__c = true;
		insert grupoOpSeg;

		//Grupo Automático Segmentos
		List<CC_Grupo_Colaborador__c> listacolabs = new List<CC_Grupo_Colaborador__c>();
		CC_Grupo_Colaborador__c grupoAutoSeg = new CC_Grupo_Colaborador__c();
		grupoAutoSeg.Name = 'BO*';
		grupoAutoSeg.SEG_GrupoSegmentos__c = true;
		grupoAutoSeg.RecordTypeId = autoSegId;
		listacolabs.add(grupoAutoSeg);

		//Gestor Comercial
		CC_Grupo_Colaborador__c grupoGestorComercial = new CC_Grupo_Colaborador__c();
		grupoGestorComercial.Name = 'Gestor Comercial';
		grupoGestorComercial.RecordTypeId = autoSegId;
        grupoGestorComercial.SEG_GrupoSegmentos__c = true;
		listacolabs.add(grupoGestorComercial);

		//Gestor Operativa Nacional
		CC_Grupo_Colaborador__c grupoGestorOperativaNacional = new CC_Grupo_Colaborador__c();
		grupoGestorOperativaNacional.Name = 'Gestor Operativa Nacional';
		grupoGestorOperativaNacional.RecordTypeId = autoSegId;
        grupoGestorOperativaNacional.SEG_GrupoSegmentos__c = true;
		listacolabs.add(grupoGestorOperativaNacional);

		//Gestor Operativa Internacional
		CC_Grupo_Colaborador__c grupoGestorOperativaInternacional = new CC_Grupo_Colaborador__c();
		grupoGestorOperativaInternacional.Name = 'Gestor Operativa Internacional';
		grupoGestorOperativaInternacional.RecordTypeId = autoSegId;
        grupoGestorOperativaInternacional.SEG_GrupoSegmentos__c = true;
		listacolabs.add(grupoGestorOperativaInternacional);

		//Gestor Financiación Estructurada
		CC_Grupo_Colaborador__c grupoGestorFinanciacionEstruct = new CC_Grupo_Colaborador__c();
		grupoGestorFinanciacionEstruct.Name = 'Gestor Financiación Estructurada';
		grupoGestorFinanciacionEstruct.RecordTypeId = autoSegId;
        grupoGestorFinanciacionEstruct.SEG_GrupoSegmentos__c = true;
		listacolabs.add(grupoGestorFinanciacionEstruct);

        CC_Grupo_Colaborador__c grupoGestorAuto = new CC_Grupo_Colaborador__c();
		grupoGestorAuto.Name = 'Envío correo Gestor Comercial';
		grupoGestorAuto.RecordTypeId = autoSegId;
        grupoGestorAuto.SEG_GrupoSegmentos__c = true;
		listacolabs.add(grupoGestorAuto);
        insert listacolabs;

		//Grupo Colaborador con RT Grupo Colaborador
		SEG_Plantilla__c plantilla = new SEG_Plantilla__C();
		plantilla.Name = 'Plantilla Col';
		//plantilla.SEG_PlantillaCastellanoID__c = '00X5r000000LxqTEAS';
		plantilla.SEG_PlantillaCastellanoID__c=emailEs.Id;
		insert plantilla;
		
		SEG_Plantilla__c plantillaFirma = new SEG_Plantilla__c();
		plantillaFirma.Name = 'FirmaGrupo';
		plantillaFirma.SEG_Organizacion__c = 'Banca Corporativa;Centro Empresas;Instituciones;Centro Soporte Especialistas;Financiación Estructurada';
		plantillaFirma.SEG_Zona__c = 'Corporativa;Empresas Barcelona;Empresas Castilla La Mancha;Empresas Cataluña;Empresas Madrid;Empresas Valencia;Instituciones Canarias';
		plantillaFirma.SEG_TipoOperativa__c = 'Firma';
		plantillaFirma.SEG_Activa__c = true;
		plantillaFirma.SEG_PlantillaCastellano__c = 'Firma BO';
		plantillaFirma.SEG_PlantillaCatalan__c = 'Firma CAT';
		plantillaFirma.SEG_PlantillaIngles__c = 'Firma IN';
		plantillaFirma.SEG_PlantillaEuskera__c = 'Firma EUSK';
		plantillaFirma.SEG_PlantillaGalego__c = 'Firma GAL';
		plantillaFirma.SEG_PlantillaCastellanoID__c = emailEs.Id;
        plantillaFirma.SEG_PlantillaInglesID__c = emailEs.Id;

		insert plantillaFirma;
       
		//Asignamos el RecordType ='Grupo Colaborador'
		CC_Grupo_Colaborador__c grupoRTGrupoCol = new CC_Grupo_Colaborador__c();
		grupoRTGrupoCol.Name = 'Grupo Colaborador';
		grupoRTGrupoCol.RecordTypeId = opSegId;
		grupoRTGrupoCol.SEG_GrupoSegmentos__c = true;
		grupoRTGrupoCol.SEG_Tipologia__c = 'CSO';
		insert grupoRTGrupoCol;

        CC_Grupo_Colaborador__c grupoRTGrupoColRemitir = new CC_Grupo_Colaborador__c();
		grupoRTGrupoColRemitir.Name = 'Grupo Colaborador Remitir';
		grupoRTGrupoColRemitir.RecordTypeId = grColId;
		grupoRTGrupoColRemitir.SEG_CierreAutomaticoSR__c = true;
        grupoRTGrupoColRemitir.SEG_GrupoSegmentos__c = true;
		insert grupoRTGrupoColRemitir;

		Profile prof = [select id from profile where name LIKE '%marketing%'];
		User userA = new User();
        userA.firstName = 'test1';
        userA.lastName = 'test2';
        userA.profileId = prof.id;
        userA.SEG_Tipo_usuario_SEG__c='BO';
        userA.username = 'test@testsegmentos.com';
        userA.email = 'test@testsegmentos.com';
        userA.EmailEncodingKey = 'UTF-8';
        userA.LanguageLocaleKey = 'es';
		userA.LocaleSidKey = 'es';
		userA.TimeZoneSidKey = 'Europe/Berlin';
        userA.Alias = 'seg';
        insert userA;

		CC_Grupo_Colaborador_Contact__c colaboradorA = new CC_Grupo_Colaborador_Contact__c();
        colaboradorA.CC_Usuario__c = userA.id;
        colaboradorA.CC_Grupo_Colaborador__c=grupoRTGrupoCol.Id;
		colaboradorA.CC_Para_CC__c= 'Para';
		colaboradorA.CC_Contacto__c= colab.id;
		
        //colaboradorA.SEG_TipodeAcceso__c= 'Escritura' ;
        insert colaboradorA;
		
		//Grupo MCC link Grupo Colaborador

		// Miguel
		CC_MCC_Grupo_Colaborador__c grupoCSO = new CC_MCC_Grupo_Colaborador__c();
		grupoCSO.Name = 'Grupo CSO';
		grupoCSO.CC_MCC__c = mccTematicaColaborador.Id;
		grupoCSO.CC_Grupo_Colaborador__c = grupoRTGrupoCol.id;
		grupoCSO.SEG_Grupo_respuesta__c = grupoAutoSeg.id;
		grupoCSO.SEG_Zona__c = 'Todas';
		grupoCSO.SEG_Organizacion__c = 'Todas';
		insert grupoCSO;
		// Miguel

		CC_MCC_Grupo_Colaborador__c grupoCol = new CC_MCC_Grupo_Colaborador__c();
		grupoCol.Name = 'Colaborador';
		grupoCol.CC_MCC__c = mccTematicaColaborador.Id;
		grupoCol.CC_Grupo_Colaborador__c = grupoRTGrupoCol.id;
		grupoCol.SEG_Grupo_respuesta__c = grupoAutoSeg.id;
		grupoCol.SEG_Zona__c = 'Todas';
		grupoCol.SEG_Organizacion__c = 'Todas';
		insert grupoCol;

        //Grupo MCC link Grupo Colaborador Remitir
		CC_MCC_Grupo_Colaborador__c grupoColRemitir = new CC_MCC_Grupo_Colaborador__c();
		grupoColRemitir.Name = 'Colaborador Remitir';
		grupoColRemitir.CC_MCC__c = mccTematicaColaborador.Id;
		grupoColRemitir.CC_Grupo_Colaborador__c = grupoRTGrupoColRemitir.id;
		grupoColRemitir.SEG_Grupo_respuesta__c = grupoAutoSeg.id;
		grupoColRemitir.SEG_Zona__c = 'Todas';
		grupoColRemitir.SEG_Organizacion__c = 'Todas';
        insert grupoColRemitir;

        CC_MCC_Grupo_Colaborador__c grupoAutoEnvio = new CC_MCC_Grupo_Colaborador__c();
		grupoAutoEnvio.Name = 'Envío Correo Gestor Financiación Estructurada';
		grupoAutoEnvio.CC_MCC__c = mccTematicaColaborador.Id;
		grupoAutoEnvio.CC_Grupo_Colaborador__c = grupoGestorAuto.id;
		grupoAutoEnvio.SEG_Grupo_respuesta__c = grupoAutoSeg.id;
		grupoAutoEnvio.SEG_Zona__c = 'Todas';
		grupoAutoEnvio.SEG_Organizacion__c = 'Todas';
		insert grupoAutoEnvio;

		//Creamos una plantilla para usar en RT = 'Grupo Colaborador'
		CC_Grupo_Colaborador_Plantilla__c plantillagrupo = new CC_Grupo_Colaborador_Plantilla__c();
		plantillagrupo.CC_Operativa__c = 'Trasladar';
		plantillagrupo.SEG_Plantilla__c = plantilla.id;
		plantillagrupo.CC_Grupo_Colaborador__c = grupoRTGrupoCol.id;
		insert plantillagrupo;
		
        CC_Grupo_Colaborador_Plantilla__c plantillaRemitir = new CC_Grupo_Colaborador_Plantilla__c();
		plantillaRemitir.CC_Operativa__c = 'Remitir';
		plantillaRemitir.SEG_Plantilla__c = plantilla.id;
		plantillaRemitir.CC_Grupo_Colaborador__c = grupoRTGrupoColRemitir.id;
		insert plantillaRemitir;
		
		CC_Grupo_Colaborador_Plantilla__c plantillafirmar = new CC_Grupo_Colaborador_Plantilla__c();
		plantillafirmar.CC_Operativa__c = 'Trasladar';
		plantillafirmar.SEG_Plantilla__c = plantillaFirma.id;
		plantillafirmar.CC_Grupo_Colaborador__c = grupoRTGrupoColRemitir.id;
		insert plantillafirmar;
        

		//Relacionamos MCC con Grupos Colaborador
		List<CC_MCC_Grupo_Colaborador__c> listaMCCGrupos = new List<CC_MCC_Grupo_Colaborador__c> ();

		CC_MCC_Grupo_Colaborador__c grupoDetalle = new CC_MCC_Grupo_Colaborador__c();
		GrupoDetalle.Name = 'detalle';
		GrupoDetalle.CC_MCC__c = mccDetalle.Id;
		GrupoDetalle.CC_Grupo_Colaborador__c = grupoOpSeg.Id;
		GrupoDetalle.SEG_Grupo_respuesta__c = grupoAutoSeg.Id;
		GrupoDetalle.SEG_Zona__c = 'Todas';
		GrupoDetalle.SEG_Organizacion__c = 'Todas';
        listaMCCGrupos.add(GrupoDetalle);

		CC_MCC_Grupo_Colaborador__c grupoMotivo = new CC_MCC_Grupo_Colaborador__c();
		GrupoMotivo.Name = 'motivo';
		GrupoMotivo.CC_MCC__c = mccMotivo.Id;
		GrupoMotivo.CC_Grupo_Colaborador__c = grupoOpSeg.Id;
		GrupoMotivo.SEG_Grupo_respuesta__c = grupoAutoSeg.Id;
		GrupoMotivo.SEG_Zona__c = 'Todas';
		GrupoMotivo.SEG_Organizacion__c = 'Banca Corporativa';
        listaMCCGrupos.add(GrupoMotivo);

		CC_MCC_Grupo_Colaborador__c grupoProdServ = new CC_MCC_Grupo_Colaborador__c();
		GrupoProdServ.Name = 'prodServ';
		GrupoProdServ.CC_MCC__c = mccProdServ.Id;
		GrupoProdServ.CC_Grupo_Colaborador__c = grupoAutoSeg.Id;
		GrupoProdServ.SEG_Grupo_respuesta__c = grupoAutoSeg.Id;
        listaMCCGrupos.add(GrupoProdServ);

		CC_MCC_Grupo_Colaborador__c grupoTematica = new CC_MCC_Grupo_Colaborador__c();
		GrupoTematica.Name = 'Tematica';
		GrupoTematica.CC_MCC__c = mccTematica.Id;
		GrupoTematica.CC_Grupo_Colaborador__c = grupoOpSeg.Id;
		GrupoTematica.SEG_Zona__c = 'Corporativa';
		GrupoTematica.SEG_Organizacion__c = 'Banca Corporativa';
		GrupoTematica.SEG_Grupo_respuesta__c = grupoAutoSeg.Id;
        listaMCCGrupos.add(GrupoTematica);

		CC_MCC_Grupo_Colaborador__c grupoGesComer = new CC_MCC_Grupo_Colaborador__c();
		GrupoGesComer.Name = 'Gestor Comercial';
		GrupoGesComer.CC_MCC__c = mccTematica.Id;
		GrupoGesComer.CC_Grupo_Colaborador__c = grupoGestorComercial.Id;
		GrupoGesComer.SEG_Grupo_respuesta__c = grupoAutoSeg.Id;
        listaMCCGrupos.add(GrupoGesComer);

		CC_MCC_Grupo_Colaborador__c grupoGesOpNacional = new CC_MCC_Grupo_Colaborador__c();
		GrupoGesOpNacional.Name = 'Gestor Operativa Nacional';
		GrupoGesOpNacional.CC_MCC__c = mccTematica.Id;
		GrupoGesOpNacional.CC_Grupo_Colaborador__c = grupoGestorOperativaNacional.Id;
        listaMCCGrupos.add(GrupoGesOpNacional);

		CC_MCC_Grupo_Colaborador__c grupoGesOpInt = new CC_MCC_Grupo_Colaborador__c();
		GrupoGesOpInt.Name = 'Gestor Operativa Internacional';
		GrupoGesOpInt.CC_MCC__c = mccTematica.Id;
		GrupoGesOpInt.CC_Grupo_Colaborador__c = grupoGestorOperativaInternacional.Id;
        listaMCCGrupos.add(GrupoGesOpInt);

		CC_MCC_Grupo_Colaborador__c grupoGesFinEs = new CC_MCC_Grupo_Colaborador__c();
		GrupoGesFinEs.Name = 'Gestor Financiación Estructurada';
		GrupoGesFinEs.CC_MCC__c = mccTematica.Id;
		GrupoGesFinEs.CC_Grupo_Colaborador__c = grupoGestorFinanciacionEstruct.Id;
        listaMCCGrupos.add(GrupoGesFinEs);
        insert listaMCCGrupos;

		//Plantilla
		List<SEG_Plantilla__c> listPlantillas = new List<SEG_Plantilla__c> ();
		SEG_Plantilla__c plantilla1 = new SEG_Plantilla__c();
		plantilla1.Name = 'Review';
		plantilla1.SEG_Activa__c = true;
		plantilla1.SEG_TipoOperativa__c = 'Acuse de recibo';
		plantilla1.SEG_Organizacion__c = 'Banca Corporativa';
		plantilla1.SEG_Zona__c = 'Corporativa';
        listPlantillas.add(plantilla1);
        
        SEG_Plantilla__c plantilla2 = new SEG_Plantilla__c();
		plantilla2.Name = 'Review';
		plantilla2.SEG_Activa__c = true;
		plantilla2.SEG_TipoOperativa__c = 'Reclamaciones';
		plantilla2.SEG_Organizacion__c = 'Banca Corporativa';
		plantilla2.SEG_Zona__c = 'Corporativa';
        plantilla2.Reclamaciones__c = '1ª Reclamación';
        listPlantillas.add(plantilla2);
        
        SEG_Plantilla__c plantilla3 = new SEG_Plantilla__c();
		plantilla3.Name = 'Review';
		plantilla3.SEG_Activa__c = true;
		plantilla3.SEG_TipoOperativa__c = 'Reclamaciones';
		plantilla3.SEG_Organizacion__c = 'Banca Corporativa';
		plantilla3.SEG_Zona__c = 'Corporativa';
        plantilla3.Reclamaciones__c = 'Reclamaciones Agotadas';
        plantilla3.SEG_PlantillaCastellanoID__c = emailEs.Id;
        listPlantillas.add(plantilla3);

		SEG_Plantilla__c plantilla4 = new SEG_Plantilla__c();
		plantilla4.Name = 'Review';
		plantilla4.SEG_Activa__c = true;
		plantilla4.SEG_TipoOperativa__c = 'Envío automático gestor';
		plantilla4.SEG_Organizacion__c = 'Banca Corporativa';
		plantilla4.SEG_Zona__c = 'Corporativa';
        plantilla4.SEG_PlantillaCastellanoID__c = emailEs.Id;
        listPlantillas.add(plantilla4);
		
		insert listPlantillas;        


        Id rtSegcli = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();

		//Creación nuevos casos asociado al contacto 
		List<Case> caseContList = new List<Case>();
        
		Case casoDetalle = new Case(AccountId = cuentaSEG1.Id, ContactId = contactoSEG1.Id, Status = 'Activo', CC_Idioma__c = 'eu', Subject = 'Detalle',RecordTypeId = rtSegcli,
		                            CC_Tipo_Cliente__c = 'Cliente', Origin = 'Comentarios Stores', CC_Tipo_Contacto__c = 'Consulta', SEG_Organizacion__c = 'Banca Corporativa',SEG_SemillaId__C = '#@SEG:1611676158418#',
		                            SEG_Zona__c = 'Corporativa', SEG_Idioma__c = 'eu', CC_Canal_Procedencia__c = 'Google Play Store', SEG_Detalle__c = mccDetalle.Id, SEG_Grupo__c = grupoRTGrupoCol.Id);
		caseContList.add(casoDetalle);

		Case casoMotivo = new Case(AccountId = cuentaSEG2.Id, ContactId = contactoSEG1.Id, Status = 'Activo', CC_Idioma__c = 'ca', Subject = 'Motivo',RecordTypeId = rtSegcli,
		                           CC_Tipo_Cliente__c = 'Cliente', Origin = 'Comentarios Stores', CC_Tipo_Contacto__c = 'Consulta', SEG_Organizacion__c = 'Banca Corporativa',
		                           SEG_Zona__c = 'Corporativa', SEG_Idioma__c = 'ca', CC_Canal_Procedencia__c = 'Google Play Store', CC_MCC_Motivo__c = mccMotivo.id);
		caseContList.add(casoMotivo);

		Case casoProdServ = new Case(AccountId = cuentaSEG1.Id, ContactId = contactoSEG1.Id, Status = 'Activo', CC_Idioma__c = 'en', Subject = 'ProdServ',RecordTypeId = rtSegcli,
		                             CC_Tipo_Cliente__c = 'Cliente', Origin = 'Comentarios Stores', CC_Tipo_Contacto__c = 'Consulta', SEG_Organizacion__c = 'Banca Corporativa',
		                             SEG_Zona__c = 'Corporativa', SEG_Idioma__c = 'en', CC_Canal_Procedencia__c = 'Google Play Store', CC_MCC_ProdServ__c = mccProdServ.id);
		caseContList.add(casoProdServ);

		Case casoTematica = new Case(AccountId = cuentaSEG1.Id, ContactId = contactoSEG1.Id, Status = 'Activo', CC_Idioma__c = 'ga', Subject = 'Tematica',RecordTypeId = rtSegcli,
		                             CC_Tipo_Cliente__c = 'Cliente', Origin = 'Comentarios Stores', CC_Tipo_Contacto__c = 'Consulta', SEG_Organizacion__c = 'Banca Corporativa',
		                             SEG_Zona__c = 'Corporativa', SEG_Idioma__c = 'ga', CC_Canal_Procedencia__c = 'Google Play Store', CC_MCC_Tematica__c = mccTematica.id);
		caseContList.add(casoTematica);

		Case gesComercial = new Case(AccountId = cuentaSEG1.Id, ContactId = contactoSEG1.Id, Status = 'Activo', CC_Idioma__c = 'eu', Subject = 'Comercial',RecordTypeId = rtSegcli,
		                             CC_Tipo_Cliente__c = 'Cliente', Origin = 'Comentarios Stores', CC_Tipo_Contacto__c = 'Consulta',
		                             CC_Canal_Procedencia__c = 'Google Play Store', CC_MCC_Tematica__c = mccTematica.id);
		caseContList.add(GesComercial);

		//Excepciones       
		SEG_ExcepcionesCentro__c exCentro = new SEG_ExcepcionesCentro__c();
		exCentro.SEG_Plantilla__c = planAR.id;
		exCentro.SEG_CentroEmpresa__c = centro.id;
		insert exCentro;
		
		SEG_ExcepcionesGrupo__c exGrupo = new SEG_ExcepcionesGrupo__c();
		exGrupo.SEG_Plantilla__c = planAR.id;
		exGrupo.SEG_GrupoTrabajoTexto__c = grupoRTGrupoCol.id;
		insert exGrupo;

		SEG_ExcepcionesEmpresa__c exEmpresa = new SEG_ExcepcionesEmpresa__c();
		exEmpresa.SEG_Plantilla__c = planAR.id;
		exEmpresa.SEG_Empresa__c = cuentaSEG1.id;
		insert exEmpresa;

		SEG_ExcepcionesCR__c exCR = new SEG_ExcepcionesCR__c();
		exCR.SEG_Plantilla__c = planAR.id;
		insert exCR;
        
        SEG_ExcepcionesCentro__c exCentroReclamacion = new SEG_ExcepcionesCentro__c();
		exCentroReclamacion.SEG_Plantilla__c = plantilla2.id;
		exCentro.SEG_CentroEmpresa__c = centro.id;
		insert exCentroReclamacion;
        
        SEG_ExcepcionesGrupo__c exGrupoReclamacion = new SEG_ExcepcionesGrupo__c();
		exGrupoReclamacion.SEG_Plantilla__c = plantilla2.id;
		exGrupo.SEG_GrupoTrabajoTexto__c = grupoRTGrupoCol.id;
		insert exGrupoReclamacion;

		SEG_ExcepcionesEmpresa__c exEmpresaReclamacion = new SEG_ExcepcionesEmpresa__c();
		exEmpresaReclamacion.SEG_Plantilla__c = plantilla2.id;
		exEmpresaReclamacion.SEG_Empresa__c = cuenta.id;
		insert exEmpresaReclamacion;

		SEG_ExcepcionesCR__c exCRReclamacion = new SEG_ExcepcionesCR__c();
		exCRReclamacion.SEG_Plantilla__c = plantilla2.id;
		insert exCRReclamacion;
        

		ContentVersion cv = new Contentversion();
		cv.title = 'ABC';
		cv.PathOnClient = 'test';
		cv.SEG_Firmado__c = false;
		Blob b = Blob.valueOf('Unit Test Attachment Body');
		cv.versiondata = EncodingUtil.base64Decode('Unit Test Attachment Body');
		insert cv;
		List<ContentDocument> documents = [
		                                   SELECT Id, Title, LatestPublishedVersionId
		                                   FROM ContentDocument
		                                  ];
		
        
        //Datos Envio Correo con plantilla
        List<Case> listaEnvio = new List<Case>();
        
        Case casoEnvio = new Case(AccountId = cuentaSEG1.Id, ContactId = contactoSEG1.Id, Status = 'Activo', CC_Idioma__c = 'es', Subject = 'Envio',RecordTypeId = rtSegcli,
		                            CC_Tipo_Cliente__c = 'Cliente', Origin = 'Comentarios Stores', SEG_Resultado__c='Enviado justificantes al cliente',
                                    CC_Tipo_Contacto__c = 'Consulta', SEG_Organizacion__c = 'Banca Corporativa',
		                            SEG_Zona__c = 'Corporativa', CC_Canal_Procedencia__c = 'Google Play Store', 
                                    SEG_Detalle__c = mccDetalle.Id, SEG_Grupo__c = grupoRTGrupoCol.Id);
		caseContList.add(casoEnvio);
        
        Case casoEnvioCA = new Case(AccountId = cuentaSEG1.Id, ContactId = contactoSEG1.Id, Status = 'Activo', CC_Idioma__c = 'ca', SEG_Idioma__c = 'ca', Subject = 'EnvioCA',RecordTypeId = rtSegcli,
		                            CC_Tipo_Cliente__c = 'Cliente', Origin = 'Comentarios Stores', SEG_Resultado__c='Enviado justificantes al cliente',
                                    CC_Tipo_Contacto__c = 'Consulta', SEG_Organizacion__c = 'Banca Corporativa',
		                            SEG_Zona__c = 'Corporativa', CC_Canal_Procedencia__c = 'Google Play Store', 
                                    SEG_Detalle__c = mccDetalle.Id, SEG_Grupo__c = grupoRTGrupoCol.Id);
		caseContList.add(casoEnvioCA);
        Case casoEnvioEN = new Case(AccountId = cuentaSEG1.Id, ContactId = contactoSEG1.Id, Status = 'Activo', CC_Idioma__c = 'en', SEG_Idioma__c = 'en', Subject = 'EnvioEN',RecordTypeId = rtSegcli,
		                            CC_Tipo_Cliente__c = 'Cliente', Origin = 'Comentarios Stores', SEG_Resultado__c='Enviado justificantes al cliente',
                                    CC_Tipo_Contacto__c = 'Consulta', SEG_Organizacion__c = 'Banca Corporativa',
		                            SEG_Zona__c = 'Corporativa', CC_Canal_Procedencia__c = 'Google Play Store', 
                                    SEG_Detalle__c = mccDetalle.Id, SEG_Grupo__c = grupoRTGrupoCol.Id);
		caseContList.add(casoEnvioEN);
        Case casoEnvioEU = new Case(AccountId = cuentaSEG1.Id, ContactId = contactoSEG1.Id, Status = 'Activo', CC_Idioma__c = 'eu', SEG_Idioma__c = 'eu', Subject = 'EnvioEU',RecordTypeId = rtSegcli,
		                            CC_Tipo_Cliente__c = 'Cliente', Origin = 'Comentarios Stores', SEG_Resultado__c='Enviado justificantes al cliente',
                                    CC_Tipo_Contacto__c = 'Consulta', SEG_Organizacion__c = 'Banca Corporativa',
		                            SEG_Zona__c = 'Corporativa', CC_Canal_Procedencia__c = 'Google Play Store', 
                                    SEG_Detalle__c = mccDetalle.Id, SEG_Grupo__c = grupoRTGrupoCol.Id); 
		caseContList.add(casoEnvioEU);

        Case casoEnvioGA = new Case(AccountId = cuentaSEG1.Id, ContactId = contactoSEG1.Id, Status = 'Activo', CC_Idioma__c = 'ga', SEG_Idioma__c = 'ga', Subject = 'EnvioGA',RecordTypeId = rtSegcli,
		                            CC_Tipo_Cliente__c = 'Cliente', Origin = 'Comentarios Stores', SEG_Resultado__c='Enviado justificantes al cliente',
                                    CC_Tipo_Contacto__c = 'Consulta', SEG_Organizacion__c = 'Banca Corporativa',
		                            SEG_Zona__c = 'Corporativa', CC_Canal_Procedencia__c = 'Google Play Store', 
                                    SEG_Detalle__c = mccDetalle.Id, SEG_Grupo__c = grupoRTGrupoCol.Id);
		caseContList.add(casoEnvioGA);

        insert caseContList;
        
        
         EmailTemplate emailEnvio = new EmailTemplate();
		emailEnvio.DeveloperName = 'Reclamacion_1_1616749645916';
		emailEnvio.Encoding = 'ISO-8859-1';
		emailEnvio.FolderId = UserInfo.getUserId();
		emailEnvio.Subject = '[num_casos]';
		emailEnvio.IsActive = true;
		emailEnvio.Name = 'Reclamacion 1º';
		emailEnvio.TemplateType = 'custom';
		emailEnvio.TemplateStyle = 'none';
		emailEnvio.HtmlValue = '<html><head><title></title></head><body style="height: auto; min-height: auto;">1&ordm; reclamaci&oacute;n enviada con la SR de seguimiento&nbsp;{{{Case.CaseNumber}}}<style type="text/css">table {font-family: arial, sans-serif; border-collapse: collapse;width: 100%;}td, th {border: 1px solid #dddddd; text-align: left; padding: 8px;}tr:nth-child(even) { background-color: #dddddd;}</style><table><tr><th>N&uacute;mero Contrato</th><th>Fecha Contrato</th><th>Descripci&oacute;n Contrato</th></tr></table></body></html>';
		System.runAs(new User(Id = UserInfo.getUserId())) {
			insert emailEnvio;
		}
        SEG_Plantilla__c plantillaEnvio = new SEG_Plantilla__c();
		plantillaEnvio.Name = 'Review';
		plantillaEnvio.SEG_Activa__c = true;
		plantillaEnvio.SEG_TipoOperativa__c = 'Cierre';
		plantillaEnvio.SEG_Organizacion__c = 'Banca Corporativa';
		plantillaEnvio.SEG_Zona__c = 'Corporativa';
        plantillaEnvio.SEG_Resultado__c = 'Enviado justificantes al cliente';
        plantillaEnvio.SEG_PlantillaCastellanoID__c =emailEnvio.id;
		insert plantillaEnvio;
        
        //Creamos un buzon mdt
        SEG_Buzon__mdt buzon = SEG_TestHelper.createBuzon();
        
        List<EmailMessage> lstEmails = new List<EmailMessage>();
        EmailMessage eMessage = new EmailMessage();
        eMessage.Incoming = false;
        eMessage.SEG_HasAnexo__c = false;
        eMessage.HtmlBody ='';
        eMessage.ParentId = casoEnvio.Id;
		lstEmails.add(eMessage);     
        
        EmailMessage dMessage = new EmailMessage();
        dMessage.Incoming = false;
        dMessage.SEG_HasAnexo__c = false;
        dMessage.HtmlBody ='';
        dMessage.ParentId = casoDetalle.Id;
		lstEmails.add(dMessage);     
        
        EmailMessage mMessage = new EmailMessage();
        mMessage.Incoming = false;
        mMessage.SEG_HasAnexo__c = false;
        mMessage.HtmlBody ='';
        mMessage.ParentId = casoMotivo.Id;
		lstEmails.add(mMessage);     
        
        EmailMessage pMessage = new EmailMessage();
        pMessage.Incoming = false;
        pMessage.SEG_HasAnexo__c = false;
        pMessage.HtmlBody ='';
        pMessage.ParentId = casoProdServ.Id;
		lstEmails.add(pMessage);     
        
        EmailMessage tMessage = new EmailMessage();
        tMessage.Incoming = false;
        tMessage.SEG_HasAnexo__c = false;
        tMessage.HtmlBody ='';
        tMessage.ParentId = casoTematica.Id;
		lstEmails.add(tMessage);     
        
        insert lstEmails;
        
        //create ContentDocumentLink  record 
		ContentDocumentLink cdl = New ContentDocumentLink();
		cdl.LinkedEntityId = casoDetalle.Id;
		cdl.ContentDocumentId = documents[0].Id;
		cdl.shareType = 'V';
		insert cdl;
        
        SEG_Gestor_Grupo__c gg = new SEG_Gestor_Grupo__c();
        gg.SEG_EmpleadoGestor__c = empleado.id;
        gg.SEG_GrupoOperativa__c = grupoOpSeg.id;
        insert gg;
        
		List<CC_Canal_Com__c> canalCom = new List<CC_Canal_Com__c>();
        CC_Canal_Com__c para = new CC_Canal_Com__c ();
        para.RecordTypeId = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();
        para.CC_Email__c = 'test@test.com';
        para.SEG_ParaCC__c = 'Para';
        para.CC_ContactoId__c = empleado.Id;
        para.CC_CuentaId__c = null;
        canalCom.add(para);
        CC_Canal_Com__c cc = new CC_Canal_Com__c ();
        cc.RecordTypeId = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();
        cc.CC_Email__c = 'test@test.com';
        cc.SEG_ParaCC__c = 'CC';
        cc.CC_ContactoId__c = empleado.Id;
        cc.CC_CuentaId__c = null;
        canalCom.add(cc);
        CC_Canal_Com__c cco = new CC_Canal_Com__c ();
        cco.RecordTypeId = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();
        cco.CC_Email__c = 'test@test.com';
        cco.SEG_ParaCC__c = 'CCO';
        cco.CC_ContactoId__c = empleado.Id;
        cco.CC_CuentaId__c = null;
        canalCom.add(cco);
		insert canalCom;
        
	}

	@isTest
	static void getAttachmentsFromObject_test()
	{
		Map<Id,Case> mapCase = new Map<Id,Case>([Select Id From Case]);
		Test.startTest();
			SEG_MetodosComunes.getAttachmentsFromObject(mapCase.keySet(), 'and SEG_Firmado__c = false');
		Test.stopTest();
		System.assert(mapCase != null,'ok');
	}

	@isTest
	static void recuperarParametrosProceso()
	{
		List<SEG_Parametros__mdt> listadoParametros = [SELECT Id, DeveloperName, MasterLabel, SEG_AreaProceso__c, SEG_Valor__c
		                                               FROM SEG_Parametros__mdt
		                                               WHERE SEG_AreaProceso__c<> null LIMIT 1];
		if (!listadoParametros.isEmpty())
		{
			Map<String, SEG_Parametros__mdt> resultado = SEG_MetodosComunes.recuperarParametrosProceso(listadoParametros[0].SEG_AreaProceso__c);
			System.assert(!resultado.isEmpty());
		}

	}

	@isTest
	static void recuperarParametrosValor()
	{
		List<SEG_Parametros__mdt> listadoParametros = [SELECT Id, DeveloperName, MasterLabel, SEG_AreaProceso__c, SEG_Valor__c
		                                               FROM SEG_Parametros__mdt
		                                               WHERE SEG_Valor__c<> null LIMIT 1];
		if (!listadoParametros.isEmpty())
		{
			String resultado = SEG_MetodosComunes.recuperarParametrosValor(listadoParametros[0].DeveloperName);
			System.assert(String.isNotBlank(resultado));
		}
	}

	@isTest
	static void registrarErrorDML()
	{
		// Crear cuenta.
		List<Account> listaCuentas = new List<Account> ();
		Account cuentaSEG1 = new Account();
		cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
		cuentaSEG1.Name = 'Empresa segmentos';
		cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG';
		cuentaSEG1.CC_Numero_Documento__c = '11111111H';
		listaCuentas.add(cuentaSEG1);
		insert listaCuentas;

		Test.startTest();

		Boolean bError = false;
		Database.SaveResult[] resultadoInsercion = Database.insert(listaCuentas, false);
		for (Integer i = 0; i<resultadoInsercion.size(); i++)
		{
			if (!resultadoInsercion[i].isSuccess())
			{
				bError = true;
				SEG_MetodosComunes.registrarErrorDML(resultadoInsercion[i].getErrors(), listaCuentas[i]);
			}
		}

		Test.stopTest();

		System.assert(cuentaSEG1 != null,'ok');
	}

	@isTest
	static void asignarGrupoCasoDetalle()
	{
		Account cuenta = [SELECT id FROM Account LIMIT 1];
		Case caso = [SELECT id, ContactId, SEG_Detalle__c, SEG_Zona__c, SEG_Organizacion__c FROM Case WHERE Subject = 'Detalle' LIMIT 1];

		String motivo, prodServ, tematica;
		String detalle = String.valueOf(caso.SEG_Detalle__c);
		String account = String.valueOf(cuenta.id);

		Test.startTest();
		//SEG_MetodosComunes.asignarGrupoCaso(caso);
		SEG_MetodosComunes.asignarGrupoCaso(detalle, motivo, prodServ, tematica, account, caso.SEG_Zona__c, caso.SEG_Organizacion__c, false);
		Test.stopTest();

		System.assert(detalle != null,'ok');
	}
	
	@isTest
	static void asignarGrupoCasoMotivo()
	{
		Account cuenta = [SELECT id FROM Account LIMIT 1];
		Case caso = [SELECT id, CC_MCC_Motivo__c, SEG_Zona__c, SEG_Organizacion__c FROM Case WHERE Subject = 'Motivo' LIMIT 1];

		String detalle, prodServ, tematica;
		String motivo = String.valueOf(caso.CC_MCC_Motivo__c);
		String account = String.valueOf(cuenta.id);

		Test.startTest();
		//SEG_MetodosComunes.asignarGrupoCaso(caso);
		SEG_MetodosComunes.asignarGrupoCaso(detalle, motivo, prodServ, tematica, account, caso.SEG_Zona__c, caso.SEG_Organizacion__c, true);
		Test.stopTest();
		System.assert(motivo != null,'ok');
	}

	@isTest
	static void asignarGrupoCasoProdServ()
	{
		Account cuenta = [SELECT id FROM Account LIMIT 1];
		Case caso = [SELECT id, CC_MCC_ProdServ__c, SEG_Zona__c, SEG_Organizacion__c FROM Case WHERE Subject = 'ProdServ' LIMIT 1];

		String detalle, motivo, tematica;
		String prodServ = String.valueOf(caso.CC_MCC_ProdServ__c);
		String account = String.valueOf(cuenta.id);

		Test.startTest();
		//SEG_MetodosComunes.asignarGrupoCaso(caso);
		SEG_MetodosComunes.asignarGrupoCaso(detalle, motivo, prodServ, tematica, account, caso.SEG_Zona__c, caso.SEG_Organizacion__c, false);
		Test.stopTest();
		System.assert(prodServ != null,'ok');
	}

	@isTest
	static void asignarGrupoCasoTematica()
	{
		Account cuenta = [SELECT id FROM Account LIMIT 1];
		Case caso = [SELECT id, CC_MCC_Tematica__c, SEG_Zona__c, SEG_Organizacion__c FROM Case WHERE Subject = 'Tematica' LIMIT 1];

		String detalle, motivo, prodServ;
		String tematica = String.valueOf(caso.CC_MCC_Tematica__c);
		String account = String.valueOf(cuenta.id);

		Test.startTest();
		//SEG_MetodosComunes.asignarGrupoCaso(caso);
		SEG_MetodosComunes.asignarGrupoCaso(detalle, motivo, prodServ, tematica, account, caso.SEG_Zona__c, caso.SEG_Organizacion__c, true);
		Test.stopTest();
		System.assert(caso != null,'ok');
	}

	@isTest
	static void asignarGrupoGestorComercial()
	{
		Account cuenta = [SELECT id FROM Account LIMIT 1];
		Case caso = [SELECT id, CC_MCC_Tematica__c, SEG_Zona__c, SEG_Organizacion__c FROM Case WHERE Subject = 'Tematica' LIMIT 1];

		String detalle, motivo, tematica;
		String prodServ = String.valueOf(caso.CC_MCC_Tematica__c);
		String account = String.valueOf(cuenta.id);

		Test.startTest();
		//SEG_MetodosComunes.asignarGrupoCaso(caso);
		SEG_MetodosComunes.asignarGrupoCaso(detalle, motivo, prodServ, tematica, account, caso.SEG_Zona__c, caso.SEG_Organizacion__c, false);
		Test.stopTest();
		System.assert(caso != null,'ok');
	}

	@isTest
	static void asignarGrupoGestorOpNacional()
	{
		Account cuenta = [SELECT id FROM Account LIMIT 1];
		Case caso = [SELECT id, CC_MCC_Tematica__c, SEG_Zona__c, SEG_Organizacion__c FROM Case WHERE Subject = 'Tematica' LIMIT 1];

		String detalle, motivo, tematica;
		String prodServ = String.valueOf(caso.CC_MCC_Tematica__c);
		String account = String.valueOf(cuenta.id);

		Test.startTest();
		//SEG_MetodosComunes.asignarGrupoCaso(caso);
		SEG_MetodosComunes.asignarGrupoCaso(detalle, motivo, prodServ, tematica, account, caso.SEG_Zona__c, caso.SEG_Organizacion__c, true);
		Test.stopTest();
		System.assert(caso != null,'ok');
	}

	@isTest
	static void asignarGrupoGestorOpInter()
	{
		Account cuenta = [SELECT id FROM Account LIMIT 1];
		Case caso = [SELECT id, CC_MCC_Tematica__c, SEG_Zona__c, SEG_Organizacion__c FROM Case WHERE Subject = 'Tematica' LIMIT 1];

		String detalle, motivo, tematica;
		String prodServ = String.valueOf(caso.CC_MCC_Tematica__c);
		String account = String.valueOf(cuenta.id);

		Test.startTest();
		//SEG_MetodosComunes.asignarGrupoCaso(caso);
		SEG_MetodosComunes.asignarGrupoCaso(detalle, motivo, prodServ, tematica, account, caso.SEG_Zona__c, caso.SEG_Organizacion__c, false);
		Test.stopTest();
		System.assert(caso != null,'ok');
	}

	@isTest
	static void asignarGrupoGestorFinEstructurada()
	{
		Account cuenta = [SELECT id FROM Account LIMIT 1];
		Case caso = [SELECT id, ContactId, CC_MCC_Tematica__c, SEG_Zona__c, SEG_Organizacion__c FROM Case WHERE Subject = 'Tematica' LIMIT 1];

		String detalle, motivo, tematica;
		String prodServ = String.valueOf(caso.CC_MCC_Tematica__c);
		String account = String.valueOf(cuenta.id);

		Test.startTest();
		//SEG_MetodosComunes.asignarGrupoCaso(caso);
		SEG_MetodosComunes.asignarGrupoCaso(detalle, motivo, prodServ, tematica, account, caso.SEG_Zona__c, caso.SEG_Organizacion__c, true);
		Test.stopTest();
		System.assert(caso != null,'ok');
	}
	
    	//Envio automatico de correo Grupo Colaborador RT Grupo Colaborador
	@IsTest
	static void enviarCorreoAsignarGrupo() {
		Account acc = [SELECT id,SEG_Prioridad_Carterizacion_Segmentos__c,AV_EAPGestor__c FROM Account LIMIT 1];
        Contact empleado = [SELECT Id FROM Contact WHERE LastName = 'Empleado' LIMIT 1];
        acc.SEG_Empleado_gestor_Segmentos__c = empleado.Id;
        acc.SEG_GestorOperativaNacional__c = empleado.Id;
        acc.SEG_GestorOperativaInternacional__c = empleado.Id;
        acc.SEG_GestorFinEstructurada__c = empleado.Id;
        //acc.AV_EAPGestor__c = empleado.Id;
        update acc;
		Case caso = [SELECT id, SEG_Organizacion__c, SEG_Zona__c, ContactId FROM Case WHERE Subject = 'Detalle' LIMIT 1];
		CC_MCC_Grupo_Colaborador__c MCCgrupoC = [SELECT id, CC_Grupo_Colaborador__c,
		                                         CC_Grupo_Colaborador__r.RecordType.DeveloperName, CC_MCC__c,
		                                         SEG_Zona__c, SEG_Organizacion__c, CC_Grupo_Colaborador__r.Name,SEG_Grupo_respuesta__c
		                                         FROM CC_MCC_Grupo_Colaborador__c
		                                         WHERE name = 'Envío Correo Gestor Financiación Estructurada' LIMIT 1];
		Test.startTest();
		//SEG_MetodosComunes.asignarGrupo(caso, MCCgrupoC, acc);
		SEG_MetodosComunes.recuperarGrupo(MCCgrupoC, acc.id, caso.SEG_Zona__c, caso.SEG_Organizacion__c, false, caso.id);
		Test.stopTest();
		System.assert(caso != null,'ok');
	}
	//Envio automatico de correo Grupo Colaborador RT Grupo Colaborador
	@IsTest
	static void asignarGrupoRTGrupoColaborador() { 
		Account acc = [SELECT id FROM Account LIMIT 1];
		Case caso = [SELECT id, SEG_Organizacion__c, SEG_Zona__c, ContactId FROM Case WHERE Subject = 'Detalle' LIMIT 1];
		CC_MCC_Grupo_Colaborador__c MCCgrupoC = [SELECT id, CC_Grupo_Colaborador__c,
		                                         CC_Grupo_Colaborador__r.RecordType.DeveloperName, CC_MCC__c,
		                                         SEG_Zona__c, SEG_Organizacion__c, CC_Grupo_Colaborador__r.Name
		                                         FROM CC_MCC_Grupo_Colaborador__c
		                                         WHERE name = 'Colaborador' LIMIT 1];
		Test.startTest();
		//SEG_MetodosComunes.asignarGrupo(caso, MCCgrupoC, acc);
		SEG_MetodosComunes.recuperarGrupo(MCCgrupoC, acc.id, caso.SEG_Organizacion__c, caso.SEG_Zona__c, true);
		Test.stopTest();
		System.assert(caso != null,'ok');
	}
    @IsTest
	static void asignarGrupoRTGrupoColaborador2() {
		Account acc = [SELECT id FROM Account LIMIT 1];
		Case caso = [SELECT id, SEG_Organizacion__c, SEG_Zona__c, ContactId FROM Case WHERE Subject = 'Detalle' LIMIT 1];
		CC_MCC_Grupo_Colaborador__c MCCgrupoC = [SELECT id, CC_Grupo_Colaborador__c,
		                                         CC_Grupo_Colaborador__r.RecordType.DeveloperName, CC_MCC__c,
		                                         SEG_Zona__c, SEG_Organizacion__c, CC_Grupo_Colaborador__r.Name
		                                         FROM CC_MCC_Grupo_Colaborador__c
		                                         WHERE name = 'Colaborador Remitir' LIMIT 1];
		Test.startTest();
		//SEG_MetodosComunes.asignarGrupo(caso, MCCgrupoC, acc);
		SEG_MetodosComunes.recuperarGrupo(MCCgrupoC, acc.id, caso.SEG_Organizacion__c, caso.SEG_Zona__c, false);
		Test.stopTest();
		System.assert(caso != null,'ok');
	}
    @IsTest
	static void asignarGrupoRTGestorComercial() {
		Account acc = [SELECT id,SEG_Prioridad_Carterizacion_Segmentos__c,AV_EAPGestor__c FROM Account LIMIT 1];
		Case caso = [SELECT id, AccountId, SEG_Organizacion__c, SEG_Zona__c, ContactId FROM Case WHERE Subject = 'Detalle' LIMIT 1];
		CC_MCC_Grupo_Colaborador__c MCCgrupoC = [SELECT id, Name, CC_Grupo_Colaborador__c, SEG_Grupo_respuesta__c,
		                                         CC_Grupo_Colaborador__r.RecordType.DeveloperName, CC_MCC__c,
		                                         SEG_Zona__c, SEG_Organizacion__c, CC_Grupo_Colaborador__r.Name
		                                         FROM CC_MCC_Grupo_Colaborador__c
		                                         WHERE name = 'Gestor Comercial'];
		Test.startTest();
		//SEG_MetodosComunes.asignarGrupo(caso, MCCgrupoC, acc);
		SEG_MetodosComunes.recuperarGrupo(MCCgrupoC, acc.id, caso.SEG_Organizacion__c, caso.SEG_Zona__c, true);
        SEG_MetodosComunes.calcularGrupoAutomatico(MCCgrupoC.Name, MCCgrupoC.SEG_Grupo_respuesta__c, caso.AccountId, false, caso.id);
		Test.stopTest();
		System.assert(caso != null,'ok');
	}
    @IsTest
	static void asignarGrupoRTGestorOperativaComercial() {
		Account acc = [SELECT id,SEG_Prioridad_Carterizacion_Segmentos__c,AV_EAPGestor__c,SEG_GestorOperativaNacional__c FROM Account LIMIT 1];
		Case caso = [SELECT id, AccountId, SEG_Organizacion__c, SEG_Zona__c, ContactId FROM Case WHERE Subject = 'Detalle' LIMIT 1];
		CC_MCC_Grupo_Colaborador__c MCCgrupoC = [SELECT id, Name, CC_Grupo_Colaborador__c, SEG_Grupo_respuesta__c,
		                                         CC_Grupo_Colaborador__r.RecordType.DeveloperName, CC_MCC__c,
		                                         SEG_Zona__c, SEG_Organizacion__c, CC_Grupo_Colaborador__r.Name
		                                         FROM CC_MCC_Grupo_Colaborador__c
		                                         WHERE name = 'Gestor Operativa Nacional'];
		Test.startTest();
		//SEG_MetodosComunes.asignarGrupo(caso, MCCgrupoC, acc);
		SEG_MetodosComunes.recuperarGrupo(MCCgrupoC, acc.id, caso.SEG_Organizacion__c, caso.SEG_Zona__c, true);
        SEG_MetodosComunes.calcularGrupoAutomatico(MCCgrupoC.Name, MCCgrupoC.SEG_Grupo_respuesta__c, caso.AccountId, false, caso.id);
		Test.stopTest();
		System.assert(caso != null,'ok');
	}
    @IsTest
	static void asignarGrupoRTGestorOperativaInternacional() {
		Account acc = [SELECT id,SEG_Prioridad_Carterizacion_Segmentos__c,AV_EAPGestor__c,SEG_GestorOperativaInternacional__c FROM Account LIMIT 1];
		Case caso = [SELECT id, AccountId, SEG_Organizacion__c, SEG_Zona__c, ContactId FROM Case WHERE Subject = 'Motivo' LIMIT 1];
		CC_MCC_Grupo_Colaborador__c MCCgrupoC = [SELECT id, Name, CC_Grupo_Colaborador__c, SEG_Grupo_respuesta__c,
		                                         CC_Grupo_Colaborador__r.RecordType.DeveloperName, CC_MCC__c,
		                                         SEG_Zona__c, SEG_Organizacion__c, CC_Grupo_Colaborador__r.Name
		                                         FROM CC_MCC_Grupo_Colaborador__c
		                                         WHERE name = 'Gestor Operativa Internacional'];
		Test.startTest();
		//SEG_MetodosComunes.asignarGrupo(caso, MCCgrupoC, acc);
		SEG_MetodosComunes.recuperarGrupo(MCCgrupoC, acc.id, caso.SEG_Organizacion__c, caso.SEG_Zona__c, true);
        SEG_MetodosComunes.calcularGrupoAutomatico('Envío correo Gestor Operativa Internacional', MCCgrupoC.SEG_Grupo_respuesta__c, caso.AccountId, false, caso.id);
		Test.stopTest();
		System.assert(caso != null,'ok');
	}
    @IsTest
	static void asignarGrupoRTGestorFinanciacionEstructurada() {
		Account acc = [SELECT id,SEG_Prioridad_Carterizacion_Segmentos__c,AV_EAPGestor__c,SEG_GestorFinEstructurada__c FROM Account LIMIT 1];
		Case caso = [SELECT id, AccountId, SEG_Organizacion__c, SEG_Zona__c, ContactId FROM Case WHERE Subject = 'Detalle' LIMIT 1];
		CC_MCC_Grupo_Colaborador__c MCCgrupoC = [SELECT id, Name, CC_Grupo_Colaborador__c, SEG_Grupo_respuesta__c,
		                                         CC_Grupo_Colaborador__r.RecordType.DeveloperName, CC_MCC__c,
		                                         SEG_Zona__c, SEG_Organizacion__c, CC_Grupo_Colaborador__r.Name
		                                         FROM CC_MCC_Grupo_Colaborador__c
		                                         WHERE name = 'Gestor Financiación Estructurada'];
		Test.startTest();
		//SEG_MetodosComunes.asignarGrupo(caso, MCCgrupoC, acc);
		SEG_MetodosComunes.recuperarGrupo(MCCgrupoC, acc.id, caso.SEG_Organizacion__c, caso.SEG_Zona__c, true);
        SEG_MetodosComunes.calcularGrupoAutomatico(MCCgrupoC.Name, MCCgrupoC.SEG_Grupo_respuesta__c, caso.AccountId, false, caso.id);
		Test.stopTest();
		System.assert(caso != null,'ok'); 
	}  

	//Comprobamos lista negra de direcciones email
	@IsTest
	static void recuperaListaNegra() {
		List<String> listEmail = new List<String> ();
		listEmail.add('prueba@gmail.com');
		listEmail.add('prueba2@ibm.com');

		Test.startTest();
		Map<String, String> resultemail = SEG_MetodosComunes.recuperaListaNegra(listEmail);
		Test.stopTest();
		System.assert(listEmail != null,'ok');

	}

	@IsTest
	static void determinarPlantillaExclusivaTest() {

		Case caso = [SELECT id, AccountId, SEG_Organizacion__c, SEG_Zona__c, SEG_Numero_de_centro__c, SEG_Grupo__c, SEG_Grupo_Empresa__c, SEG_ClasificacionRapida__c, SEG_Resultado__c
		             FROM Case WHERE SEG_Organizacion__c = 'Banca Corporativa' AND SEG_Zona__c = 'Corporativa' LIMIT 1];
		String operativa = 'Acuse de recibo';

		Test.startTest();
		SEG_MetodosComunes.determinarPlantillaExclusiva(caso, operativa);
		Test.stopTest();
		System.assert(caso != null,'ok');

	}
    
    @IsTest
	static void determinarPlantillaContrato() {

		Case caso = [SELECT id, AccountId, SEG_Organizacion__c, SEG_Zona__c, SEG_Numero_de_centro__c, SEG_Grupo__c, SEG_Grupo_Empresa__c, SEG_ClasificacionRapida__c, SEG_Resultado__c
		             FROM Case WHERE SEG_Organizacion__c = 'Banca Corporativa' AND SEG_Zona__c = 'Corporativa' LIMIT 1];
		//String operativa = 'Acuse de recibo';
		String operativa = 'Acuse de recibo';
		String reclamacion = '';
		String casoid = caso.id;
		Test.startTest();
		SEG_MetodosComunes.determinarPlantillaContrato(casoid, operativa, reclamacion);
		Test.stopTest();
		System.assert(caso != null,'ok');
	}

	@IsTest
	static void errorEnviarEmailAutomaticoTest() {
		Case caso = [SELECT id, SEG_Idioma__c FROM Case WHERE Subject = 'Detalle' LIMIT 1];
		String grupoDestinoId = '';
		String grupoOrigenId = '';
		
		Test.startTest();
		SEG_MetodosComunes.enviarEmailAutomatico(null, caso.Id, caso.Id);
		Test.stopTest();
		System.assert(caso != null,'ok');

	}
    
    @IsTest
	static void errorEnviarEmailAutomaticoTest2() {
		Case caso = [SELECT id FROM Case WHERE Subject = 'Detalle' LIMIT 1];
		Database.delete(caso.Id);
		String grupoOrigenId = '';
		CC_Grupo_Colaborador__c gCol = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Colaborador' LIMIT 1];
        
        String grupoDestinoId = gCol.Id;
		Test.startTest();
		SEG_MetodosComunes.enviarEmailAutomatico(grupoDestinoId, grupoDestinoId, caso.Id);
		Test.stopTest();
		System.assert(caso != null,'ok');

	}
    
    @IsTest
	static void enviarEmailAutomaticoTest() {
		Case caso = [SELECT id FROM Case WHERE Subject = 'Detalle' LIMIT 1];
		
		String grupoOrigenId = '';
		CC_Grupo_Colaborador__c gCol = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Colaborador' LIMIT 1];
        
        String grupoDestinoId = gCol.Id;
		Test.startTest();
		SEG_MetodosComunes.enviarEmailAutomatico(grupoDestinoId, caso.Id, caso.Id);
		Test.stopTest();
		System.assert(caso != null,'ok');

	}
     @IsTest
	static void enviarEmailAutomaticoRemitir() {
		Case caso = [SELECT id FROM Case WHERE Subject = 'Detalle' LIMIT 1];
		
		String grupoOrigenId = '';
		CC_Grupo_Colaborador__c gCol = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Colaborador Remitir' LIMIT 1];
        
        String grupoDestinoId = gCol.Id;
		Test.startTest();
		SEG_MetodosComunes.enviarEmailAutomatico(grupoDestinoId, caso.Id, caso.Id);
		Test.stopTest();
		System.assert(caso != null,'ok');

	}
    
	@IsTest
	static void ERRenviarCorreoTest() {
		List<Case> casolst = [SELECT id,ContactEmail,SEG_Estado_Contacto__c, SEG_No_AR_Account__c, SEG_No_AR_Contact__c,SEG_Resultado__c,SEG_Organizacion__c,
                              SEG_Zona__c, SEG_Idioma__c, SEG_Numero_de_centro__c,SEG_Grupo_Empresa__c,SEG_Grupo__c,AccountId,SEG_ClasificacionRapida__c
                              FROM Case WHERE Subject = 'Detalle' LIMIT 1];
        List<Id> caseId = new List<Id>();
        Map<Id,Case> auxMapCase = new Map<Id,Case>();
        String operativa = 'Reclamaciones';
        
        for(Case casrecNew: casolst){
            caseId.add(casrecNew.Id);
            auxMapCase.put(casrecNew.Id,casrecNew);
        }
		
		Test.startTest();
		SEG_MetodosComunes.enviarCorreo(caseId, auxMapCase, operativa);
		Test.stopTest();
		System.assert(casolst != null,'ok');

	}
    @IsTest
	static void enviarCorreoTest() {
		List<Case> casolst = [SELECT id,ContactEmail,SEG_Estado_Contacto__c, SEG_No_AR_Account__c, SEG_No_AR_Contact__c,SEG_Resultado__c,SEG_Organizacion__c,caseNumber,
                              SEG_Zona__c,SEG_SemillaId__c, SEG_Numero_de_centro__c,SEG_Grupo_Empresa__c,SEG_Grupo__c,AccountId,SEG_ClasificacionRapida__c,SEG_Idioma__c, ContactId
                              FROM Case WHERE Subject = 'Envio' LIMIT 1];
        List<Id> caseId = new List<Id>();
        Map<Id,Case> auxMapCase = new Map<Id,Case>();
        String operativa = 'Cierre';
        for(Case casrecNew: casolst){
            caseId.add(casrecNew.Id);
            auxMapCase.put(casrecNew.Id,casrecNew);
        }
		Test.startTest();
		SEG_MetodosComunes.enviarCorreo(caseId, auxMapCase, operativa);
		Test.stopTest();
		System.assert(casolst != null,'ok');
	}
    
    
    @IsTest
	static void enviarCorreoTestCA() {
		List<Case> casolst = [SELECT id,ContactEmail,SEG_Estado_Contacto__c, SEG_No_AR_Account__c, SEG_No_AR_Contact__c,SEG_Resultado__c,SEG_Organizacion__c,
                              SEG_Zona__c,SEG_Numero_de_centro__c,SEG_Grupo_Empresa__c,SEG_Grupo__c,AccountId,SEG_ClasificacionRapida__c,SEG_Idioma__c, ContactId
                              FROM Case WHERE Subject = 'EnvioCA' LIMIT 1];
        List<Id> caseId = new List<Id>();
        Map<Id,Case> auxMapCase = new Map<Id,Case>();
        String operativa = 'Cierre';
        for(Case casrecNew: casolst){
            caseId.add(casrecNew.Id);
            auxMapCase.put(casrecNew.Id,casrecNew);
        }
		Test.startTest();
		SEG_MetodosComunes.enviarCorreo(caseId, auxMapCase, operativa);
		Test.stopTest();
		System.assert(casolst != null,'ok');
	}
        @IsTest
	static void enviarCorreoTestEN() {
		List<Case> casolst = [SELECT id,ContactEmail,SEG_Estado_Contacto__c, SEG_No_AR_Account__c, SEG_No_AR_Contact__c,SEG_Resultado__c,SEG_Organizacion__c,
                              SEG_Zona__c,SEG_Numero_de_centro__c,SEG_Grupo_Empresa__c,SEG_Grupo__c,AccountId,SEG_ClasificacionRapida__c,SEG_Idioma__c, ContactId,Status
                              FROM Case WHERE Subject = 'EnvioEN' LIMIT 1];
        List<Id> caseId = new List<Id>();
        Map<Id,Case> auxMapCase = new Map<Id,Case>();
        String operativa = 'Cierre';
        for(Case casrecNew: casolst){
            caseId.add(casrecNew.Id);
            auxMapCase.put(casrecNew.Id,casrecNew);
        }
		Test.startTest();
		SEG_MetodosComunes.enviarCorreo(caseId, auxMapCase, operativa);
		Test.stopTest();
		System.assert(casolst != null,'ok');
	}
            @IsTest
	static void enviarCorreoTestEU() {
		List<Case> casolst = [SELECT id,ContactEmail,SEG_Estado_Contacto__c, SEG_No_AR_Account__c, SEG_No_AR_Contact__c,SEG_Resultado__c,SEG_Organizacion__c,
                              SEG_Zona__c,SEG_Numero_de_centro__c,SEG_Grupo_Empresa__c,SEG_Grupo__c,AccountId,SEG_ClasificacionRapida__c,SEG_Idioma__c, ContactId
                              FROM Case WHERE Subject = 'EnvioEU' LIMIT 1];
        List<Id> caseId = new List<Id>();
        Map<Id,Case> auxMapCase = new Map<Id,Case>();
        String operativa = 'Cierre';
        for(Case casrecNew: casolst){
            caseId.add(casrecNew.Id);
            auxMapCase.put(casrecNew.Id,casrecNew);
        }
		Test.startTest();
		SEG_MetodosComunes.enviarCorreo(caseId, auxMapCase, operativa);
		Test.stopTest();
		System.assert(casolst != null,'ok');
	}
                @IsTest
	static void enviarCorreoTestGA() {
		List<Case> casolst = [SELECT id,ContactEmail,SEG_Estado_Contacto__c, SEG_No_AR_Account__c, SEG_No_AR_Contact__c,SEG_Resultado__c,SEG_Organizacion__c,
                              SEG_Zona__c,SEG_Numero_de_centro__c,SEG_Grupo_Empresa__c,SEG_Grupo__c,AccountId,SEG_ClasificacionRapida__c,SEG_Idioma__c, ContactId
                              FROM Case WHERE Subject = 'EnvioGA' LIMIT 1];
        List<Id> caseId = new List<Id>();
        Map<Id,Case> auxMapCase = new Map<Id,Case>();
        String operativa = 'Cierre';
        for(Case casrecNew: casolst){
            caseId.add(casrecNew.Id);
            auxMapCase.put(casrecNew.Id,casrecNew);
        }
		Test.startTest();
		SEG_MetodosComunes.enviarCorreo(caseId, auxMapCase, operativa);
		Test.stopTest();
		System.assert(casolst != null,'ok');
	}
    
    @IsTest
	static void enviarCorreoReciclado() {
		List<Case> casolst = [SELECT id,ContactEmail,SEG_Estado_Contacto__c, SEG_No_AR_Account__c, SEG_No_AR_Contact__c,SEG_Resultado__c,SEG_Organizacion__c,SEG_SemillaId__C,
                              SEG_Zona__c,SEG_Numero_de_centro__c,SEG_Grupo_Empresa__c,SEG_Grupo__c,
                              AccountId,SEG_ClasificacionRapida__c,ContactId,SEG_N_case_y_subject__c,SEG_Idioma__c
                              FROM Case WHERE Subject = 'Detalle' LIMIT 1];
        List<Id> caseId = new List<Id>();
        Map<Id,Case> auxMapCase = new Map<Id,Case>();
        String operativa = 'Acuse de correo reciclado';
        
        for(Case casrecNew: casolst){
            caseId.add(casrecNew.Id);
            auxMapCase.put(casrecNew.Id,casrecNew);
        }
		
		Test.startTest();
		SEG_MetodosComunes.enviarCorreo(caseId, auxMapCase, operativa);
		Test.stopTest();
		System.assert(casolst != null,'ok');
	}
    
    @IsTest
	static void enviarCorreoRecicladoCA() {
		List<Case> casolst = [SELECT id,ContactEmail,SEG_Estado_Contacto__c, SEG_No_AR_Account__c, SEG_No_AR_Contact__c,SEG_Resultado__c,SEG_Organizacion__c,SEG_SemillaId__C,
                              SEG_Zona__c,SEG_Numero_de_centro__c,SEG_Grupo_Empresa__c,SEG_Grupo__c,
                              AccountId,SEG_ClasificacionRapida__c,ContactId,SEG_N_case_y_subject__c,SEG_Idioma__c
                              FROM Case WHERE Subject = 'Motivo' LIMIT 1];
        List<Id> caseId = new List<Id>();
        Map<Id,Case> auxMapCase = new Map<Id,Case>();
        String operativa = 'Acuse de correo reciclado';
        
        for(Case casrecNew: casolst){
            caseId.add(casrecNew.Id);
            auxMapCase.put(casrecNew.Id,casrecNew);
        }
		
		Test.startTest();
		SEG_MetodosComunes.enviarCorreo(caseId, auxMapCase, operativa);
		Test.stopTest();
		System.assert(casolst != null,'ok');
	}   
    
	@IsTest
	static void devolverSegBOTest() {
		Case casolst = [SELECT id,ContactEmail,SEG_Estado_Contacto__c, SEG_No_AR_Account__c, SEG_No_AR_Contact__c,SEG_Resultado__c,SEG_Organizacion__c,
                              SEG_Zona__c,SEG_Numero_de_centro__c,SEG_Grupo_Empresa__c,SEG_Grupo__c,AccountId,SEG_ClasificacionRapida__c
                              FROM Case WHERE Subject = 'Detalle' LIMIT 1];
        Id caseId = casolst.Id;

		Test.startTest();
		SEG_MetodosComunes.devolverSegBO(caseId);
		Test.stopTest();
		System.assert(casolst != null,'ok');

	}
    @IsTest
    static void devolverSegBOListPB(){
        List<Case> casolst = [SELECT id,ContactEmail,SEG_Estado_Contacto__c, SEG_No_AR_Account__c, SEG_No_AR_Contact__c,SEG_Resultado__c,SEG_Organizacion__c,
                              SEG_Zona__c,SEG_Numero_de_centro__c,SEG_Grupo_Empresa__c,SEG_Grupo__c,AccountId,SEG_ClasificacionRapida__c
                              FROM Case WHERE Subject = 'Detalle' LIMIT 1];
       
        List<Id> lstId = new List<Id>();
        
        for(Case casrecNew: casolst){
            casrecNew.Status = 'Planificado';
            lstId.add(casrecNew.Id);
        }

        Update casolst;
		Test.startTest();
		SEG_MetodosComunes.devolverSegBOListPB(lstId);
		Test.stopTest();
		System.assert(casolst != null,'ok');
    }
	@IsTest
	static void devolverSegBOList() {
		List<Case> casolst = [SELECT id,ContactEmail,SEG_Estado_Contacto__c, SEG_No_AR_Account__c, SEG_No_AR_Contact__c,SEG_Resultado__c,SEG_Organizacion__c,
                              SEG_Zona__c,SEG_Numero_de_centro__c,SEG_Grupo_Empresa__c,SEG_Grupo__c,AccountId,SEG_ClasificacionRapida__c
                              FROM Case WHERE Subject = 'Detalle' LIMIT 1];
        Set<Id> caseId = new Set<Id>();
        
        for(Case casrecNew: casolst){
            caseId.add(casrecNew.Id);
        }

		Test.startTest();
		SEG_MetodosComunes.devolverSegBOList(caseId);
		Test.stopTest();
		System.assert(casolst != null,'ok');

	}
    
	@IsTest
	static void enviarCorreoAcuseTest() {
		Case casolst = [SELECT Id,ContactId,ContactEmail,SEG_Estado_Contacto__c, SEG_No_AR_Account__c, SEG_No_AR_Contact__c,SEG_Resultado__c,SEG_Organizacion__c,
                              SEG_Zona__c,SEG_Numero_de_centro__c,SEG_Grupo_Empresa__c,SEG_Grupo__c,AccountId,SEG_ClasificacionRapida__c
                              FROM Case WHERE Subject = 'Detalle' LIMIT 1];
        Contact contacto = [Select Id,Email from Contact WHERE Id =: casolst.ContactId];
        Id caseId = casolst.Id;
        
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'Reclamacion_1_1616749645917' LIMIT 1];

		Test.startTest();
		SEG_MetodosComunes.enviarCorreoAcuse(emailTemplate.Id,caseId,contacto);
		Test.stopTest();
		System.assert(casolst != null,'ok');
	}
    
    	@IsTest
	static void errorEnviarCorreoAcuseTest() {
		Case casolst = [SELECT Id,ContactId,ContactEmail,SEG_Estado_Contacto__c, SEG_No_AR_Account__c, SEG_No_AR_Contact__c,SEG_Resultado__c,SEG_Organizacion__c,
                              SEG_Zona__c,SEG_Numero_de_centro__c,SEG_Grupo_Empresa__c,SEG_Grupo__c,AccountId,SEG_ClasificacionRapida__c
                              FROM Case WHERE Subject = 'Detalle' LIMIT 1];
        Contact contacto = [Select Id,Email from Contact WHERE Id =: casolst.ContactId];
        Id caseId = casolst.Id;
        
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'Reclamacion_1_1616749645917' LIMIT 1];

		Test.startTest();
		SEG_MetodosComunes.enviarCorreoAcuse(null,caseId,contacto);
		Test.stopTest();
		System.assert(casolst != null,'ok');
	}
    
    @IsTest
	static void enviarCorreoContratos() {
		Case casolst = [SELECT Id,ContactId,ContactEmail,SEG_Estado_Contacto__c, SEG_No_AR_Account__c, SEG_No_AR_Contact__c,SEG_Resultado__c,SEG_Organizacion__c,
                              SEG_Zona__c,SEG_Numero_de_centro__c,SEG_Grupo_Empresa__c,SEG_Grupo__c,AccountId,SEG_ClasificacionRapida__c
                              FROM Case WHERE Subject = 'Detalle' LIMIT 1];
        Contact contacto = [Select Id,Email from Contact WHERE Id =: casolst.ContactId];
        String caseId = casolst.Id;
        List<SEG_Contratos__c> lstContr = [SELECT id FROM SEG_Contratos__c];
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'Reclamacion_1_1616749645917' LIMIT 1];
        String plantillaidioma = emailTemplate.Id;
        Map<String,String> mapaBuzonesOrgZona = new Map<String, String>();
        mapaBuzonesOrgZona.put(casolst.SEG_Organizacion__c, casolst.SEG_Zona__c);
        
		List<Messaging.EmailFileAttachment> attachment = null;
		Test.startTest();
		SEG_MetodosComunes.enviarCorreoContratos(plantillaidioma,caseId,contacto,lstContr,attachment, mapaBuzonesOrgZona);
		Test.stopTest();
		System.assert(casolst != null,'ok');

	}
    
	@IsTest
	static void gestionTrazas() {
        List<CC_InterfaceSettings__mdt> oConfig = [SELECT DeveloperName, CC_Certificado__c, CC_EndPoint__c, CC_TimeOut__c, CC_TipoPeticion__c, CC_CharSet__c, CC_ContentType__c, CC_HttpRequest__c, CC_SoapAction__c, CC_Body__c, CC_TrazaActiva__c, CC_TrazaEntrada__c, CC_TrazaSalida__c, CC_ALF_CliConf__c, CC_CliConfiErr__c
                                                    FROM CC_InterfaceSettings__mdt WHERE CC_Activa__c = true AND CC_TrazaActiva__c = true LIMIT 1];
        
        CC_TrazaInt__c traza1 = SEG_MetodosComunes.inicioTraza (oConfig[0].DeveloperName, '', '', 'MENSAJE');
        traza1 = SEG_MetodosComunes.finTraza(traza1, 'SALIDA');
        CC_TrazaInt__c traza2 = SEG_MetodosComunes.inicioTraza (oConfig[0].DeveloperName, '', '', 'MENSAJE');
        traza2 = SEG_MetodosComunes.finTraza(traza2, 'SALIDA','1','DETALLE');

		CC_TrazaInt__c traza3 = SEG_MetodosComunes.inicioTraza (oConfig[0].DeveloperName, '', '', 'MENSAJE');
		traza3 = SEG_MetodosComunes.finTrazaNoInsert(traza3, 'mensajeSalida', true, 'tipoError', 'detalleError');
        
        System.assert(traza1 != null);
        System.assert(traza1.Id != null);
        System.assert(traza2 != null);
        System.assert(traza2.Id != null);
		System.assert(traza3 != null);
    }

	@IsTest
	static void getIdPlantillaIdioma() {
        List<SEG_Plantilla__c> plantillas = [SELECT id, name,SEG_PlantillaCastellano__c,SEG_PlantillaCatalan__c,SEG_PlantillaIngles__c
		,SEG_PlantillaEuskera__c,SEG_PlantillaGalego__c, SEG_PlantillaCastellanoID__c,SEG_PlantillaInglesID__c, SEG_PlantillaGalegoID__c,
		SEG_PlantillaCatalanID__c,SEG_PlantillaEuskeraID__c FROM SEG_Plantilla__c WHERE name = 'FirmaGrupo'];

		List<Account> cuenta = [SELECT id, name FROM Account WHERE name= 'Empresa segmentos'];
		List<Contact> contacto = [SELECT id, LastName FROM Contact WHERE LastName = 'Contacto SEG 1'];
		List<CC_Grupo_Colaborador__c> grupoColab = [SELECT id, name, RecordTypeId FROM CC_Grupo_Colaborador__c WHERE name= 'Grupo Colaborador'];
		List<CC_MCC__c> mcc = [SELECT id, name FROM CC_MCC__c WHERE name = 'Detalle'];

		Case casoDetalle1 = new Case();
		casoDetalle1.AccountId = cuenta[0].Id;
		casoDetalle1.ContactId = contacto[0].Id;
		casoDetalle1.Status = 'Activo';
		casoDetalle1.Subject = 'Detalle1';
		casoDetalle1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
		casoDetalle1.CC_Tipo_Cliente__c = 'Cliente';
		casoDetalle1.Origin = 'Comentarios Stores'; 
		casoDetalle1.CC_Tipo_Contacto__c = 'Consulta';
		casoDetalle1.SEG_Organizacion__c = 'Banca Corporativa';
		casoDetalle1.SEG_SemillaId__C = '#@SEG:1611676158419#';
		casoDetalle1.SEG_Zona__c = 'Corporativa';
		casoDetalle1.CC_Canal_Procedencia__c = 'Google Play Store';
		casoDetalle1.SEG_Detalle__c = mcc[0].Id;
		casoDetalle1.SEG_Grupo__c = grupoColab[0].Id;
		insert casoDetalle1;

		Test.startTest();
			SEG_MetodosComunes.getIdPlantillaIdioma(plantillas[0], casoDetalle1);
		Test.stopTest();
		System.assert(casoDetalle1 != null,'ok');
	}
	@IsTest
        static void getIdPlantillaIdiomaGA() {
        List<SEG_Plantilla__c> plantillas = [SELECT id, name,SEG_PlantillaCastellano__c,SEG_PlantillaCatalan__c,SEG_PlantillaIngles__c
		,SEG_PlantillaEuskera__c,SEG_PlantillaGalego__c, SEG_PlantillaCastellanoID__c,SEG_PlantillaInglesID__c, SEG_PlantillaGalegoID__c,
		SEG_PlantillaCatalanID__c,SEG_PlantillaEuskeraID__c FROM SEG_Plantilla__c WHERE name = 'FirmaGrupo'];
		
		Case caso = [SELECT Id,SEG_Idioma__c FROM Case WHERE Subject = 'Detalle' LIMIT 1];
        caso.SEG_Idioma__c = 'ga';
        update caso;
        
        Test.startTest();
			SEG_MetodosComunes.getIdPlantillaIdioma(plantillas[0], caso);
		Test.stopTest();
		System.assert(plantillas != null,'ok');
	}
    
	@IsTest
	static void getIdPlantillaIdiomaCA() {
        List<SEG_Plantilla__c> plantillas = [SELECT id, name,SEG_PlantillaCastellano__c,SEG_PlantillaCatalan__c,SEG_PlantillaIngles__c
		,SEG_PlantillaEuskera__c,SEG_PlantillaGalego__c, SEG_PlantillaCastellanoID__c,SEG_PlantillaInglesID__c, SEG_PlantillaGalegoID__c,
		SEG_PlantillaCatalanID__c,SEG_PlantillaEuskeraID__c FROM SEG_Plantilla__c WHERE name = 'FirmaGrupo'];
		
		Case caso = [SELECT Id,SEG_Idioma__c FROM Case WHERE Subject = 'Detalle' LIMIT 1];
        caso.SEG_Idioma__c = 'ca';
        update caso;
        
		Test.startTest();
			SEG_MetodosComunes.getIdPlantillaIdioma(plantillas[0], caso);
		Test.stopTest();
		System.assert(plantillas != null,'ok');
	}
    
	@IsTest
	static void getIdPlantillaIdiomaEU() {
        List<SEG_Plantilla__c> plantillas = [SELECT id, name,SEG_PlantillaCastellano__c,SEG_PlantillaCatalan__c,SEG_PlantillaIngles__c
		,SEG_PlantillaEuskera__c,SEG_PlantillaGalego__c, SEG_PlantillaCastellanoID__c,SEG_PlantillaInglesID__c, SEG_PlantillaGalegoID__c,
		SEG_PlantillaCatalanID__c,SEG_PlantillaEuskeraID__c FROM SEG_Plantilla__c WHERE name = 'FirmaGrupo'];
		
		Case caso = [SELECT Id,SEG_Idioma__c FROM Case WHERE Subject = 'Detalle' LIMIT 1];
        caso.SEG_Idioma__c = 'eu';
        update caso;
        
		Test.startTest();
			SEG_MetodosComunes.getIdPlantillaIdioma(plantillas[0], caso);
		Test.stopTest();
		System.assert(plantillas != null,'ok');
	}
    
	@IsTest
	static void getIdPlantillaIdiomaEN() {
        List<SEG_Plantilla__c> plantillas = [SELECT id, name,SEG_PlantillaCastellano__c,SEG_PlantillaCatalan__c,SEG_PlantillaIngles__c
		,SEG_PlantillaEuskera__c,SEG_PlantillaGalego__c, SEG_PlantillaCastellanoID__c,SEG_PlantillaInglesID__c, SEG_PlantillaGalegoID__c,
		SEG_PlantillaCatalanID__c,SEG_PlantillaEuskeraID__c FROM SEG_Plantilla__c WHERE name = 'FirmaGrupo'];
		
		Case caso = [SELECT Id,SEG_Idioma__c FROM Case WHERE Subject = 'Detalle' LIMIT 1];
        caso.SEG_Idioma__c = 'en';
        update caso;
        
		Test.startTest();
			SEG_MetodosComunes.getIdPlantillaIdioma(plantillas[0], caso);
		Test.stopTest();
		System.assert(plantillas != null,'ok');
	}
    
	@IsTest
	static void getIdPlantillaIdiomaContact() {
        List<SEG_Plantilla__c> plantillas = [SELECT id, name,SEG_PlantillaCastellano__c,SEG_PlantillaCatalan__c,SEG_PlantillaIngles__c
		,SEG_PlantillaEuskera__c,SEG_PlantillaGalego__c, SEG_PlantillaCastellanoID__c,SEG_PlantillaInglesID__c, SEG_PlantillaGalegoID__c,
		SEG_PlantillaCatalanID__c,SEG_PlantillaEuskeraID__c FROM SEG_Plantilla__c WHERE name = 'FirmaGrupo'];
		
		Case caso = [SELECT Id,SEG_Idioma__c,Contact.CC_Idioma__c FROM Case WHERE Subject = 'Detalle' LIMIT 1];
        caso.SEG_Idioma__c = null;
        update caso;
        
		Test.startTest();
			SEG_MetodosComunes.getIdPlantillaIdioma(plantillas[0], caso);
		Test.stopTest();
		System.assert(plantillas != null,'ok');
	}
    
    @IsTest
	static void getIdPlantillaIdiomaContactGA() {
        List<SEG_Plantilla__c> plantillas = [SELECT id, name,SEG_PlantillaCastellano__c,SEG_PlantillaCatalan__c,SEG_PlantillaIngles__c
		,SEG_PlantillaEuskera__c,SEG_PlantillaGalego__c, SEG_PlantillaCastellanoID__c,SEG_PlantillaInglesID__c, SEG_PlantillaGalegoID__c,
		SEG_PlantillaCatalanID__c,SEG_PlantillaEuskeraID__c FROM SEG_Plantilla__c WHERE name = 'FirmaGrupo'];
		
        Contact contacto = [SELECT Id, CC_Idioma__c FROM Contact WHERE LastName = 'Contacto SEG 1' LIMIT 1];
        contacto.CC_Idioma__c = 'ga';
        update contacto;
        
		Case caso = [SELECT Id,SEG_Idioma__c,Contact.CC_Idioma__c FROM Case WHERE Subject = 'Detalle' LIMIT 1];
        caso.SEG_Idioma__c = null;
        update caso;
        
		Test.startTest();
			SEG_MetodosComunes.getIdPlantillaIdioma(plantillas[0], caso);
		Test.stopTest();
		System.assert(plantillas != null,'ok');
	}
    
    @IsTest
	static void getIdPlantillaIdiomaContactEN() {
        List<SEG_Plantilla__c> plantillas = [SELECT id, name,SEG_PlantillaCastellano__c,SEG_PlantillaCatalan__c,SEG_PlantillaIngles__c
		,SEG_PlantillaEuskera__c,SEG_PlantillaGalego__c, SEG_PlantillaCastellanoID__c,SEG_PlantillaInglesID__c, SEG_PlantillaGalegoID__c,
		SEG_PlantillaCatalanID__c,SEG_PlantillaEuskeraID__c FROM SEG_Plantilla__c WHERE name = 'FirmaGrupo'];
		
        Contact contacto = [SELECT Id, CC_Idioma__c FROM Contact WHERE LastName = 'Contacto SEG 1' LIMIT 1];
        contacto.CC_Idioma__c = 'en';
        update contacto;
        
		Case caso = [SELECT Id,SEG_Idioma__c,Contact.CC_Idioma__c FROM Case WHERE Subject = 'Detalle' LIMIT 1];
        caso.SEG_Idioma__c = null;
        update caso;
        
		Test.startTest();
			SEG_MetodosComunes.getIdPlantillaIdioma(plantillas[0], caso);
		Test.stopTest();
		System.assert(plantillas != null,'ok');
	}

    @IsTest
	static void getIdPlantillaIdiomaContactEU() {
        List<SEG_Plantilla__c> plantillas = [SELECT id, name,SEG_PlantillaCastellano__c,SEG_PlantillaCatalan__c,SEG_PlantillaIngles__c
		,SEG_PlantillaEuskera__c,SEG_PlantillaGalego__c, SEG_PlantillaCastellanoID__c,SEG_PlantillaInglesID__c, SEG_PlantillaGalegoID__c,
		SEG_PlantillaCatalanID__c,SEG_PlantillaEuskeraID__c FROM SEG_Plantilla__c WHERE name = 'FirmaGrupo'];
		
        Contact contacto = [SELECT Id, CC_Idioma__c FROM Contact WHERE LastName = 'Contacto SEG 1' LIMIT 1];
        contacto.CC_Idioma__c = 'eu';
        update contacto;
        
		Case caso = [SELECT Id,SEG_Idioma__c,Contact.CC_Idioma__c FROM Case WHERE Subject = 'Detalle' LIMIT 1];
        caso.SEG_Idioma__c = null;
        update caso;
        
		Test.startTest();
			SEG_MetodosComunes.getIdPlantillaIdioma(plantillas[0], caso);
		Test.stopTest();
		System.assert(plantillas != null,'ok');
	}
    
	@IsTest
	static void getIdPlantillaIdiomaAccount() {
        List<SEG_Plantilla__c> plantillas = [SELECT id, name,SEG_PlantillaCastellano__c,SEG_PlantillaCatalan__c,SEG_PlantillaIngles__c
		,SEG_PlantillaEuskera__c,SEG_PlantillaGalego__c, SEG_PlantillaCastellanoID__c,SEG_PlantillaInglesID__c, SEG_PlantillaGalegoID__c,
		SEG_PlantillaCatalanID__c,SEG_PlantillaEuskeraID__c FROM SEG_Plantilla__c WHERE name = 'FirmaGrupo'];
		
        Contact contacto = [SELECT Id, CC_Idioma__c FROM Contact WHERE LastName = 'Contacto SEG 1' LIMIT 1];
        contacto.CC_Idioma__c = null;
        update contacto;
        
		Case caso = [SELECT Id,SEG_Idioma__c,Contact.CC_Idioma__c, Account.AV_Idioma__c FROM Case WHERE Subject = 'Detalle' LIMIT 1];
        caso.SEG_Idioma__c = null;
        update caso;
        
		Test.startTest();
			SEG_MetodosComunes.getIdPlantillaIdioma(plantillas[0], caso);
		Test.stopTest();
		System.assert(plantillas != null,'ok');
	}
    
    @IsTest
	static void getIdPlantillaIdiomaAccount2() {
        List<SEG_Plantilla__c> plantillas = [SELECT id, name,SEG_PlantillaCastellano__c,SEG_PlantillaCatalan__c,SEG_PlantillaIngles__c
		,SEG_PlantillaEuskera__c,SEG_PlantillaGalego__c, SEG_PlantillaCastellanoID__c,SEG_PlantillaInglesID__c, SEG_PlantillaGalegoID__c,
		SEG_PlantillaCatalanID__c,SEG_PlantillaEuskeraID__c FROM SEG_Plantilla__c WHERE name = 'FirmaGrupo'];
		
        Contact contacto = [SELECT Id, CC_Idioma__c FROM Contact WHERE LastName = 'Contacto SEG 1' LIMIT 1];
        contacto.CC_Idioma__c = null;
        update contacto;
        
        Account cuentaSEG1 = new Account();
        cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        cuentaSEG1.Name = 'Empresa segmentos';
        cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG1.CC_Numero_Documento__c = '11114123F';
		cuentaSEG1.AV_Idioma__c = '004';
        insert cuentaSEG1;
        
		Case caso = [SELECT Id,SEG_Idioma__c,Contact.CC_Idioma__c, AccountId, Account.AV_Idioma__c FROM Case WHERE Subject = 'Detalle' LIMIT 1];
        caso.SEG_Idioma__c = null;
        caso.AccountId = cuentaSEG1.Id;
        update caso;
        
		Test.startTest();
			SEG_MetodosComunes.getIdPlantillaIdioma(plantillas[0], caso);
		Test.stopTest();
		System.assert(plantillas != null,'ok');
	}
    
    @IsTest
	static void getIdPlantillaIdiomaAccount3() {
        List<SEG_Plantilla__c> plantillas = [SELECT id, name,SEG_PlantillaCastellano__c,SEG_PlantillaCatalan__c,SEG_PlantillaIngles__c
		,SEG_PlantillaEuskera__c,SEG_PlantillaGalego__c, SEG_PlantillaCastellanoID__c,SEG_PlantillaInglesID__c, SEG_PlantillaGalegoID__c,
		SEG_PlantillaCatalanID__c,SEG_PlantillaEuskeraID__c FROM SEG_Plantilla__c WHERE name = 'FirmaGrupo'];
		
        Contact contacto = [SELECT Id, CC_Idioma__c FROM Contact WHERE LastName = 'Contacto SEG 1' LIMIT 1];
        contacto.CC_Idioma__c = null;
        update contacto;
        
        Account cuentaSEG1 = new Account();
        cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        cuentaSEG1.Name = 'Empresa segmentos';
        cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG1.CC_Numero_Documento__c = '12111123F';
		cuentaSEG1.AV_Idioma__c = '001';
        insert cuentaSEG1;
        
		Case caso = [SELECT Id,SEG_Idioma__c,Contact.CC_Idioma__c, AccountId, Account.AV_Idioma__c FROM Case WHERE Subject = 'Detalle' LIMIT 1];
        caso.SEG_Idioma__c = null;
        caso.AccountId = cuentaSEG1.Id;
        update caso;
        
		Test.startTest();
			SEG_MetodosComunes.getIdPlantillaIdioma(plantillas[0], caso);
		Test.stopTest();
		System.assert(plantillas != null,'ok');
	}
    
    @IsTest
	static void getIdPlantillaIdiomaAccount4() {
        List<SEG_Plantilla__c> plantillas = [SELECT id, name,SEG_PlantillaCastellano__c,SEG_PlantillaCatalan__c,SEG_PlantillaIngles__c
		,SEG_PlantillaEuskera__c,SEG_PlantillaGalego__c, SEG_PlantillaCastellanoID__c,SEG_PlantillaInglesID__c, SEG_PlantillaGalegoID__c,
		SEG_PlantillaCatalanID__c,SEG_PlantillaEuskeraID__c FROM SEG_Plantilla__c WHERE name = 'FirmaGrupo'];
		
        Contact contacto = [SELECT Id, CC_Idioma__c FROM Contact WHERE LastName = 'Contacto SEG 1' LIMIT 1];
        contacto.CC_Idioma__c = null;
        update contacto;
        
        Account cuentaSEG1 = new Account();
        cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        cuentaSEG1.Name = 'Empresa segmentos';
        cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG1.CC_Numero_Documento__c = '11211123F';
		cuentaSEG1.AV_Idioma__c = '010';
        insert cuentaSEG1;
        
		Case caso = [SELECT Id,SEG_Idioma__c,Contact.CC_Idioma__c, AccountId, Account.AV_Idioma__c FROM Case WHERE Subject = 'Detalle' LIMIT 1];
        caso.SEG_Idioma__c = null;
        caso.AccountId = cuentaSEG1.Id;
        update caso;
        
		Test.startTest();
			SEG_MetodosComunes.getIdPlantillaIdioma(plantillas[0], caso);
		Test.stopTest();
		System.assert(plantillas != null,'ok');
	}
    
	@IsTest
	static void recuperarColaboradorExternoTest() {

        Case caso = [SELECT id, AccountId, ContactId, SEG_Detalle__c, SEG_Zona__c, SEG_Organizacion__c FROM Case WHERE Subject = 'Detalle' LIMIT 1];
		CC_MCC__c mcc = [SELECT id FROM CC_MCC__c WHERE Name = 'TematicaColaborador' LIMIT 1];
        CC_Grupo_Colaborador__c gp = [SELECT id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Colaborador Remitir' LIMIT 1];
		Set<String> mccCaso = new Set<String>();
        mccCaso.add(mcc.id);
        
		Test.startTest();
			SEG_MetodosComunes.recuperarColaboradorExterno(caso.SEG_Organizacion__c, caso.SEG_Zona__c, gp.id, mccCaso, caso.AccountId, false, caso.id);
		Test.stopTest();
		System.assert(caso != null,'ok');
	}
    
	@IsTest
	static void getDestinatariosContactosTest() {
        
		Map<String,String> mapContacts = new Map<String,String>();
        
        for(Contact contacto : [SELECT id, AccountId FROM Contact])
        {
            mapContacts.put(contacto.id, contacto.AccountId);
        }
        
		Test.startTest();
			SEG_MetodosComunes.getDestinatariosContactos(mapContacts);
		Test.stopTest();
		System.assert(mapContacts != null,'ok');
	}
    
	@IsTest
	static void recuperarOWASegmentosTest() {
     
		Test.startTest();
			Map<String,String> mapaOwa = SEG_MetodosComunes.recuperarOWASegmentos();
		Test.stopTest();
		System.assert(mapaOwa != null,'ok');
	}
    
	@IsTest
	static void depuracionCorreosBuzonSegmentosTest() {      
        List<String> lstCorreos = new List<String>();
        lstCorreos.add('SEG_Banca_Corporativa_Madrid');
     
		Test.startTest();
			SEG_MetodosComunes.depuracionCorreosBuzonSegmentos(lstCorreos,'SEG_Banca_Corporativa_Madrid');
		Test.stopTest();
		System.assert(lstCorreos != null,'ok');
	}

	@isTest
	static void recuperarGruposBo(){
		
		Test.startTest();
			Id grupoId = SEG_MetodosComunes.recuperarGrupoBO();
		Test.stopTest();
		System.assert(grupoId != null,'ok');
	}
    
    @isTest
    static void pruebaAttatchmentsWrapper(){
		List<String> lstCorreos = new List<String>();
        lstCorreos.add('SEG_Banca_Corporativa_Madrid');
        Test.startTest();
        SEG_MetodosComunes.AttatchmentsWrapper adjunto;
        Test.stopTest();
		System.assert(lstCorreos != null,'ok');
    }

	@IsTest
	static void asignarGrupoCSO() {
		
		Account acc = [SELECT id FROM Account LIMIT 1];
		Case caso = [SELECT id, SEG_Organizacion__c, SEG_Zona__c, ContactId FROM Case WHERE Subject = 'Detalle' LIMIT 1];
		CC_MCC_Grupo_Colaborador__c MCCgrupoC = [SELECT id, Name, CC_Grupo_Colaborador__c, SEG_Grupo_respuesta__c,
												 CC_Grupo_Colaborador__r.RecordType.DeveloperName, CC_MCC__c,
												 SEG_Zona__c, SEG_Organizacion__c, CC_Grupo_Colaborador__r.Name 
												 FROM CC_MCC_Grupo_Colaborador__c 
												 WHERE name = 'Grupo CSO' AND CC_Grupo_Colaborador__r.SEG_Tipologia__c = 'CSO' LIMIT 1];
	
		Test.startTest();
		Map<String,String> resultado = SEG_MetodosComunes.recuperarGrupo(MCCgrupoC, acc.id, caso.SEG_Organizacion__c, caso.SEG_Zona__c, false, caso.id);
		Test.stopTest();
		System.assertEquals(MCCgrupoC.CC_Grupo_Colaborador__c, resultado.get('grupoCol'), 'No se ha encontrado el grupo colaborador correcto');
	}
}