@IsTest
public class SEG_redactarEmail_Controller_Test{

    //Creamos los datos que vamos a usar en el test
    @TestSetup
    static void crearDatosTest(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];
        System.RunAs(supervisor){

            Id grupoOpSegId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();

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

            SEG_ClasificacionRapida__c regla1 = new SEG_ClasificacionRapida__c();
            regla1.Name = 'CR1';
            regla1.SEG_Tematica__c = mccTematica.Id;
            regla1.SEG_Producto__c = mccProducto.Id;
            regla1.SEG_Motivo__c = mccMotivo.Id;
            regla1.SEG_Detalle__c = mccDetalle.Id;
            regla1.CBK_Negocio__c = 'Segmentos';
            insert regla1;
            
            //Account
            List<Account> cuentas = new List<Account>();
            Account oficinaGestora = new Account();
            oficinaGestora.Name='Cuenta';
            oficinaGestora.SEG_NotaCentroPlantillasCAT__c = 'notasCentroCAT'; 
            oficinaGestora.SEG_NotaCentroPlantillasEN__c = 'notasCentroEN'; 
            oficinaGestora.SEG_NotaCentroPlantillasES__c = 'notasCentroES'; 
            oficinaGestora.SEG_NotaCentroPlantillasEU__c = 'notasCentroEU'; 
            oficinaGestora.SEG_NotaCentroPlantillasGL__c = 'notasCentroGL';
            
            cuentas.add(oficinaGestora);
            
            //Account
            Account cuenta = new Account(Name='Cuenta', AV_OficinaPrincipal__c = oficinaGestora.id, SEG_NotasEmpresaSR__c = 'notasEmpresa');
            
            cuentas.add(cuenta);
            
            //Contact
            List<Contact> contactos = new List<Contact>();
            Contact contacto = new Contact(LastName='Contacto', AccountId=cuenta.Id);
            
            contactos.add(contacto);
            
            
            Account cuentaSEG1 = new Account();
            cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
            cuentaSEG1.Name = 'Empresa Test';
            cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG';
            cuentaSEG1.CC_Numero_Documento__c = '04822802R';
            cuentaSEG1.CC_Numero_Oficina__c = '74512';
            cuentaSEG1.SEG_NotasEmpresaSR__c = 'abracadabra';
            cuentaSEG1.SEG_NotaCentroPlantillasEN__c= 'bici';
            cuentaSEG1.SEG_NotaCentroPlantillasES__c = 'atn';
            cuentaSEG1.SEG_NotaCentroPlantillasCAT__c = 'atn';
            cuentaSEG1.SEG_NotaCentroPlantillasEU__c = 'atn';
            cuentaSEG1.SEG_NotaCentroPlantillasGL__c = 'atn';
            cuentas.add(cuentaSEG1);
            insert cuentas;
            
            // Crear contactos para cuentas SEG.
            Contact contactoSEG1 = new Contact();
            contactoSEG1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            contactoSEG1.LastName = 'Contacto SEG 1';
            contactoSEG1.AccountId = cuentaSEG1.Id;
            contactoSEG1.Email = 'test@test.com';
            contactos.add(contactoSEG1);
            insert contactos;
            
                
            //Grupo Colaborador
            CC_Grupo_Colaborador__c grupoCol1 = new CC_Grupo_Colaborador__c();
            grupoCol1.Name = 'GrupoSegOp1';
            grupoCol1.RecordTypeId = grupoOpSegId;
            grupoCol1.SEG_NotaGrupoPlantillaEN__c = 'notaGrupoEN';
            grupoCol1.SEG_NotaGrupoPlantillaES__c = 'notaGrupoES';
            grupoCol1.SEG_NotaGrupoPlantillaCAT__c = 'notaGrupoCAT';
            grupoCol1.SEG_NotaGrupoPlantillaEU__c = 'notaGrupoEU';
            grupoCol1.SEG_NotaGrupoPlantillaGL__c = 'notaGrupoGA';
            insert grupoCol1;
            
            //Clasificación rápida    
            SEG_ClasificacionRapida__c clasR = new SEG_ClasificacionRapida__c();
            clasR.SEG_Canaldeentrada__c = 'Oficina';
            insert clasR;
            
            //Casos
            Case casoDetalle = new Case();
            casoDetalle.SEG_ClasificacionRapida__c = clasR.id; 
            casoDetalle.SEG_Grupo__c = grupoCol1.id; 
            casoDetalle.Status = 'Activo'; 
            casoDetalle.SEG_Subestado__c = 'En curso';
            casoDetalle.CC_Detalles_Consulta__c = 'Test';
            casoDetalle.SEG_Idioma__c = 'en';
            casoDetalle.CC_AcuseRecibo__c ='1';
            casoDetalle.Subject = 'test 1';
            casoDetalle.CC_MCC_Tematica__c = mccTematica.Id;
            casoDetalle.CC_MCC_ProdServ__c = mccProducto.Id;
            casoDetalle.CC_MCC_Motivo__c = mccMotivo.Id;
            casoDetalle.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
            casoDetalle.AccountId = cuentaSEG1.Id;
            casoDetalle.ContactId = contactoSEG1.Id;
            casoDetalle.CC_MailTelfNotif__c = contactoSEG1.Email;
            casoDetalle.SEG_N_operaciones_del_caso__c = 1.0;
            insert casoDetalle;

            Case casoDetalle2 = new Case();
            casoDetalle2.SEG_ClasificacionRapida__c = regla1.id; 
            casoDetalle2.SEG_Grupo__c = grupoCol1.id; 
            casoDetalle2.Status = 'Activo'; 
            casoDetalle2.SEG_Subestado__c = 'En curso';
            casoDetalle2.CC_Detalles_Consulta__c = 'Test';
            casoDetalle2.SEG_Idioma__c = 'en';
            casoDetalle2.CC_AcuseRecibo__c ='1';
            casoDetalle2.Subject = 'test 12';
            casoDetalle2.CC_MCC_Tematica__c = mccTematica.Id;
            casoDetalle2.CC_MCC_ProdServ__c = mccProducto.Id;
            casoDetalle2.CC_MCC_Motivo__c = mccMotivo.Id;
            casoDetalle2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
            casoDetalle2.AccountId = cuentaSEG1.Id;
            casoDetalle2.ContactId = contactoSEG1.Id;
            casoDetalle2.CC_MailTelfNotif__c = contactoSEG1.Email;
            casoDetalle2.SEG_N_operaciones_del_caso__c = 1;
            insert casoDetalle2;
            
            EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE LocalPart LIKE 'SEG_%' LIMIT 1];
            String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;

            //EmailMessage
            List<EmailMessage> emails = new List<EmailMessage>();
            EmailMessage dataEmail = new EmailMessage();
            dataEmail.FromAddress='prueba@test.com';
            dataEmail.MessageDate = Datetime.now();
            dataEmail.CcAddress = null;
            dataEmail.FromName = 'Testemail';
            dataEmail.ToAddress = 'toaddress@test.com';
            dataEmail.subject = 'Caso SEG_redactarEmail_Controller_Test';
            dataEmail.HtmlBody = 'EmailMessage Body <img src="/sfc/servlet.shepherd/version/download/0685r0000020aZcAAI"><img src="https://caixabankcc--devboseg01--c.documentforce.com/sfc/servlet.shepherd/version/download/0685r0000015bet?asPdf=false&amp;operationContext=CHATTER"><img src="https://caixabankcc--devser2.sandbox.file.force.com/sfc/servlet.shepherd/version/download/0683O000003gFPV?asPdf=false&amp;operationContext=CHATTER">';
            dataEmail.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
            dataEmail.ParentId = casoDetalle.Id;
            
            emails.add(dataEmail);
            EmailMessage dataEmail2 = new EmailMessage();
            dataEmail2.FromAddress='prueba2@test.com';
            dataEmail2.MessageDate = Datetime.now();
            dataEmail2.CcAddress = 'testcc1@test.com';
            dataEmail2.FromName = 'Testemail1';
            dataEmail2.ToAddress = 'toaddress12@test.com';
            dataEmail2.subject = 'Caso SEG_redactarEmail_Controller_Test12';
            dataEmail2.HtmlBody = 'EmailMessage Body12 <img src="https://caixabankcc--devboseg01--c.documentforce.com/sfc/servlet.shepherd/version/download/0685r0000015bet?asPdf=false&amp;operationContext=CHATTER">';
            dataEmail2.ParentId = casoDetalle.Id;
            dataEmail2.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
            emails.add(dataEmail2);
            insert emails;
            
            CC_Grupo_Colaborador_Contact__c gC = new CC_Grupo_Colaborador_Contact__c();
            gC.CC_Usuario__c = supervisor.Id;
            gC.CC_Grupo_Colaborador__c = grupoCol1.Id;
            insert gC;
            
            EmailTemplate template = new EmailTemplate();
            User thisUser2 = [select Id from User where Id = :supervisor.Id];
            System.runAs ( thisUser2 ) 
            {
                template.DeveloperName = 'template';
                template.Name = 'email';
                template.TemplateType = 'text';
                template.FolderId = supervisor.Id;
                insert template;
            }      
            
            //Plantillas
            List<SEG_Plantilla__c> plantillas = new List<SEG_Plantilla__c>();
            SEG_Plantilla__c plantillaOrg = new SEG_Plantilla__c();
            plantillaOrg.Name = 'org';
            plantillaOrg.SEG_Activa__c = true;
            plantillaOrg.SEG_TipoOperativa__c = 'Acuse de recibo';
            plantillaOrg.SEG_Organizacion__c = 'Banca Corporativa';
            plantillaOrg.SEG_PlantillaCastellanoID__c = template.id;
            plantillaOrg.SEG_PlantillaCatalanID__c = template.id;
            plantillaOrg.SEG_PlantillaEuskeraID__c = template.id;
            plantillaOrg.SEG_PlantillaGalegoID__c = template.id;
            plantillaOrg.SEG_PlantillaInglesID__c = template.id;
            plantillas.add(plantillaOrg);
            
            
            //Firma
            SEG_Plantilla__c firma = new SEG_Plantilla__c();
            firma.Name = 'firma';
            firma.SEG_Activa__c = true;
            firma.SEG_TipoOperativa__c = 'Firma';
            firma.SEG_PlantillaCastellanoID__c = template.id;
            firma.SEG_PlantillaCatalanID__c = template.id;
            firma.SEG_PlantillaEuskeraID__c = template.id;
            firma.SEG_PlantillaGalegoID__c = template.id;
            firma.SEG_PlantillaInglesID__c = template.id;
            plantillas.add(firma);
            insert plantillas;
            
            SEG_ExcepcionesGrupo__c exGrupo = new SEG_ExcepcionesGrupo__c();
            exGrupo.SEG_GrupoTrabajoTexto__c = grupoCol1.id;
            exGrupo.SEG_Plantilla__c = firma.id;
            insert exGrupo;

            SEG_NotasTipificadas__c notaTip = new SEG_NotasTipificadas__c();
            notaTip.Name = 'test';
            insert notaTip;

            SEG_CRNotasTipificadas__c crNotasTip = new SEG_CRNotasTipificadas__c();
            crNotasTip.SEG_NotasTipificadas__c = notaTip.id;
            crNotasTip.SEG_CR__c = regla1.id;
            insert crNotasTip;

            SEG_NotasTipificadas__c notaTip2 = new SEG_NotasTipificadas__c();
            notaTip2.Name = 'notatiptest';
            insert notaTip2;

        }
    }

    @IsTest
    static void emailTemplateUnive(){      
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Case caso =[SELECT Id FROM Case LIMIT 1];
        SEG_Plantilla__c plan =[SELECT Id FROM SEG_Plantilla__c WHERE Name = 'org' LIMIT 1];
        EmailMessage dataEmail = [SELECT Id,LastModifiedById,MessageDate,CreatedDate,CcAddress,FromName,FromAddress,ToAddress,subject,HtmlBody,ParentId 
                                  FROM EmailMessage 
                                  WHERE fromAddress = 'prueba2@test.com' 
                                  LIMIT 1];
        Boolean resultEn = false;
        Boolean resultEs = false;
        Boolean resultCa = false;
        Boolean resultEu = false;
        Boolean resultGa = false;
        Boolean resultAll = false;
		Boolean result = false;

        
        System.runAs ( supervisor ) {
            Test.startTest();
            if (SEG_redactarEmail_Controller.getEmailTemplate(caso.id, dataEmail, 'en', null, plan.Id, null, false)!= null){
                resultEn = true;
            }
            if (SEG_redactarEmail_Controller.getEmailTemplate(caso.id, dataEmail, 'es', null, plan.Id, null, true)!= null){
                resultEs = true;
            }
            if (SEG_redactarEmail_Controller.getEmailTemplate(caso.id, dataEmail, 'ca', null, plan.Id, null, true)!= null){
                resultCa = true;
            }
            if (SEG_redactarEmail_Controller.getEmailTemplate(caso.id, dataEmail, 'eu', null, plan.Id, null, true)!= null){
                resultEu = true;
            }
            if (SEG_redactarEmail_Controller.getEmailTemplate(caso.id, dataEmail, 'ga', null, plan.Id, null, true)!= null){
                resultGa = true;
            }
            if (SEG_redactarEmail_Controller.getEmailTemplate(caso.id, dataEmail, 'en', 'doce', plan.Id, plan.Id, false)!= null){
                result = true;
            }
            if (resultEn != false || resultEs != false || resultCa != false || resultEu != false || resultGa != false || result != false){
                resultAll = true;
            }
            Test.stopTest();  
            system.assertEquals(resultAll, true, 'Plantillas incorrectas');     
        }
    }  

    //Enviamos el Correo
    @IsTest
    static void enviarCorreoUnico(){
		User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];
        
        Case caso =[SELECT Id,ContactId FROM Case LIMIT 1];
        EmailMessage dataEmail = [SELECT Id,LastModifiedById,FromAddress, htmlBody,Subject FROM EmailMessage WHERE parentId =: caso.Id LIMIT 1];
        String emailbody = dataEmail.htmlBody;
        String cambioPara = 'newPara@test.com';
        List<String> paraList = new List<String>();
        paraList.add('buzon.segmentos1@gmail.com');
        List<String> copiaList = new List<String>();
        copiaList.add('copiaList.segmentos1@test.com');
        List<String> listaAnexos = new List<String>();
        listaAnexos.add('0');
        String subject = 'Hola';
        String boton = 'RespUnico';
        String botonRM = 'RespMultiple';
        String botonN = 'botonNuevo';
        Datetime revision = Datetime.now();
        
        System.runAs ( supervisor ) {
            Test.startTest();
            //Respúnico
                SEG_redactarEmail_Controller.enviarCorreo(caso.Id, dataEmail, emailBody, subject, paraList, copiaList, false, false, listaAnexos, caso.ContactId,true,'test',revision, boton,true,null);
            Test.stopTest();
            List<ContentVersion> cntList = [SELECT Id FROM ContentVersion];
            EmailMessage mensajeEnviado = [SELECT id, parentId, incoming FROM EmailMessage WHERE parentId =: caso.id AND incoming = false ORDER BY createdDate DESC LIMIT 1];
            system.assertNotEquals(mensajeEnviado, null, 'Mensaje no enviado');     
        }
    }

    //Enviamos el Correo
    @IsTest
    static void enviarCorreoMultiple(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Case caso =[SELECT Id,ContactId FROM Case LIMIT 1];
        EmailMessage dataEmail = [SELECT Id,LastModifiedById,FromAddress, htmlBody,Subject FROM EmailMessage LIMIT 1];
        String emailbody = dataEmail.htmlBody;
        String cambioPara = 'newPara@test.com';
        List<String> paraList = new List<String>();
        paraList.add('buzon.segmentos1@gmail.com');
        List<String> copiaList = new List<String>();
        copiaList.add('copiaList.segmentos1@test.com');
        List<String> listaAnexos = new List<String>();
        listaAnexos.add('0');
        String subject = 'Hola';
        String boton = 'RespUnico';
        String botonRM = 'RespMultiple';
        String botonN = 'botonNuevo';
        Datetime revision = Datetime.now();
        
        
        System.runAs ( supervisor ) {
            Test.startTest();
            //Respuesta Múltiple
                SEG_redactarEmail_Controller.enviarCorreo(caso.Id, dataEmail, emailBody, subject, paraList, copiaList, false, true, listaAnexos, caso.ContactId,true,'test',revision, botonRM,false,null);
            Test.stopTest();
            EmailMessage mensajeEnviado = [SELECT id, parentId FROM EmailMessage WHERE parentId =: caso.id AND incoming = false ORDER BY createdDate DESC LIMIT 1];
            system.assertNotEquals(mensajeEnviado, null, 'Mensaje no enviado'); 
        }
    }

    //Enviamos el Correo
    @IsTest
    static void enviarCorreoBotonNuevo(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Case caso =[SELECT Id,ContactId FROM Case LIMIT 1];
        EmailMessage dataEmail = [SELECT Id,LastModifiedById,FromAddress, htmlBody,Subject FROM EmailMessage LIMIT 1];
        String emailbody = dataEmail.htmlBody;
        String cambioPara = 'newPara@test.com';
        List<String> paraList = new List<String>();
        paraList.add('buzon.segmentos1@gmail.com');
        List<String> copiaList = new List<String>();
        copiaList.add('copiaList.segmentos1@test.com');
        List<String> listaAnexos = new List<String>();
        listaAnexos.add('0');
        String subject = 'Hola';
        String boton = 'RespUnico';
        String botonRM = 'RespMultiple';
        String botonN = 'botonNuevo';
        Datetime revision = Datetime.now();
        
        
        System.runAs ( supervisor ) {
            Test.startTest();
            //botón nuevo
                SEG_redactarEmail_Controller.enviarCorreo(caso.Id, dataEmail, emailBody, subject, paraList, copiaList, true, false, listaAnexos, caso.ContactId,false,subject,revision, botonN,true,null);
            Test.stopTest();
            EmailMessage mensajeEnviado = [SELECT id, parentId FROM EmailMessage WHERE parentId =: caso.id AND incoming = false ORDER BY createdDate DESC LIMIT 1 ];
            system.assertNotEquals(mensajeEnviado, null, 'Mensaje no enviado'); 
        }
    }

    @IsTest
    static void linkAttachmentsToEmailTest(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Case caso =[SELECT Id FROM Case WHERE subject = 'test 1' LIMIT 1];       
   	 	EmailMessage dataEmail = [SELECT Id,LastModifiedById,Subject,HasAttachment FROM EmailMessage WHERE parentID =: caso.id LIMIT 1];

        ContentVersion docsV = new contentVersion();
            docsV.title='ABC';
            docsV.PathOnClient ='test';
            Blob b=Blob.valueOf('Unit Test Attachment Body');
            docsV.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
            insert docsV;

        List<String> contentDocumentIds = new List<String>();
        contentDocumentIds.add(docsV.id);

        
        System.runAs ( supervisor ) {
            Test.startTest();
                SEG_redactarEmail_Controller.getAttachments(contentDocumentIds);
                SEG_redactarEmail_Controller.getFilesCase(caso.id);
            Test.stopTest();

            EmailMessage mensajeEnviado = [SELECT id, parentId, HasAttachment FROM EmailMessage WHERE id =: dataEmail.id LIMIT 1];
            system.assertNotEquals(mensajeEnviado.HasAttachment, null , 'Mensaje no contiene adjuntos'); 
        }
    }

    @IsTest
    static void linkAttachmentsToEmailTestAssets(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];


        System.runAs (supervisor) {

            Case caso =[SELECT Id FROM Case WHERE subject = 'test 1' LIMIT 1];       
            EmailMessage dataEmail = [SELECT Id,LastModifiedById,Subject,HasAttachment FROM EmailMessage WHERE parentID =: caso.id LIMIT 1];

            ContentVersion docsV = new contentVersion();
            docsV.title='/test.jpeg';
            docsV.PathOnClient ='/test.jpeg';
            docsV.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
            insert docsV;

            ContentVersion docsV2 = new ContentVersion();
            docsV2.title='/testDos.jpeg';
            docsV2.PathOnClient ='/testDos.jpeg';
            docsV2.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body Dos');
            insert docsV2;
    
            String randomUuid = UUID.randomUUID().toString().remove('-').left(18);
            String developerNameFinal = 'SEG_' + docsV2.id + randomUuid;
            
            ContentAsset assetId = new ContentAsset();
            assetId.DeveloperName = developerNameFinal;
            assetId.IsVisibleByExternalUsers = true;
            assetId.MasterLabel = developerNameFinal;
            insert assetId;

            List<ContentDocument> documents = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = : docsV2.Id];
    
            ContentDocument cntDocument2 = new ContentDocument();
            cntDocument2.Id = documents[0].Id;
            cntDocument2.ContentAssetId = assetId.Id;
            update cntDocument2;

            String emailBody = '</p><p><img src="https://caixabankcc.lightning.force.com/sfc/servlet.shepherd/version/download/'+ docsV2.Id + '"></p><p>';
        
            Test.startTest();
                String htmlResult = SEG_redactarEmail_Controller.gestionarImagenesInlineRedactarMail(caso.id,emailBody);
            Test.stopTest();

            System.assertNotEquals(emailBody, htmlResult);
            System.assertEquals(true, htmlResult.contains(developerNameFinal));
        }
    }

    @IsTest
    static void linkAttachmentsToEmailTestAssetsNotEqual(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];


        System.runAs (supervisor) {

            Case caso =[SELECT Id FROM Case WHERE subject = 'test 1' LIMIT 1];       
            EmailMessage dataEmail = [SELECT Id,LastModifiedById,Subject,HasAttachment FROM EmailMessage WHERE parentID =: caso.id LIMIT 1];

            ContentVersion docsV = new contentVersion();
            docsV.title='/test.jpeg';
            docsV.PathOnClient ='/test.jpeg';
            docsV.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
            insert docsV;

            ContentVersion docsV2 = new ContentVersion();
            docsV2.title='/testDos.jpeg';
            docsV2.PathOnClient ='/testDos.jpeg';
            docsV2.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body Dos');
            insert docsV2;

            String randomUuid = UUID.randomUUID().toString().remove('-').left(18);
            String developerNameFinal = 'SEG_' + docsV2.id + randomUuid;
            
            ContentAsset assetId = new ContentAsset();
            assetId.DeveloperName = developerNameFinal;
            assetId.IsVisibleByExternalUsers = true;
            assetId.MasterLabel = developerNameFinal;
            insert assetId;

            List<ContentDocument> documents = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = : docsV2.Id];
    
            ContentDocument cntDocument2 = new ContentDocument();
            cntDocument2.Id = documents[0].Id;
            cntDocument2.ContentAssetId = assetId.Id;
            update cntDocument2;

            String emailBody = '</p><p><img src="https://caixabankcc.lightning.force.com/sfc/servlet.shepherd/version/download/'+ docsV.Id + '"></p><p>';
        
            Test.startTest();
                String htmlResult = SEG_redactarEmail_Controller.gestionarImagenesInlineRedactarMail(caso.id,emailBody);
            Test.stopTest();

            System.assertNotEquals(emailBody, htmlResult);
        }
    }

    @IsTest
    static void comprobarContentRepetidos(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        System.runAs (supervisor) {

            ContentVersion docsV = new contentVersion();
            docsV.title='/test.jpeg';
            docsV.PathOnClient ='/test.jpeg';
            docsV.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
            insert docsV;

            ContentVersion docsV2 = new ContentVersion();
            docsV2.title='/testDos.jpeg';
            docsV2.PathOnClient ='/testDos.jpeg';
            docsV2.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body Dos');
            insert docsV2;

            List<ContentVersion> listContent = new List<ContentVersion>();
            listContent.add(docsV);
            docsV2.Id = docsV.Id;
            listContent.add(docsV2);
        
            Test.startTest();
            Map<String, List<ContentVersion>> mapResult = SEG_redactarEmail_Controller.juntarRepeticiones(listContent);
            Test.stopTest();

            System.assertEquals(mapResult.get(String.valueOf(docsV.Id).left(15)).size(), 2);
        }
    }
    
    @IsTest
    static void getFPlanificacion_Test(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Case caso =[SELECT Id,CC_Detalles_Consulta__c FROM Case LIMIT 1]; 
        caso.CC_Detalles_Consulta__c = null;
        update caso;
        
        System.runAs ( supervisor ) {
            Test.startTest();
                SEG_redactarEmail_Controller.getFPlanificacion(caso.id);
            Test.stopTest();  
            Case caso1 =[SELECT Id,CC_Detalles_Consulta__c, Status , SEG_Fecha_Revisi_n__c FROM Case WHERE subject = 'test 12' LIMIT 1];
            system.assertEquals(caso1.SEG_Fecha_Revisi_n__c, null , 'Caso planificado');     
        }
    }
    
    @IsTest
    static void identificarDestinatarioP1_Test(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Id recordTypeCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        Contact contacto = [SELECT id, LastName, Email FROM Contact WHERE Email = 'test@test.com' LIMIT 1];
        Account cuenta = [SELECT id, Name,SEG_NotasEmpresaSR__c,AV_EAPGestor__c FROM Account WHERE SEG_NotasEmpresaSR__c ='abracadabra' LIMIT 1]  ;
        cuenta.AV_EAPGestor__c = contacto.id;
        update cuenta;
        Case caso = [SELECT id, status,SEG_Subestado__c, contact.email,CC_Detalles_Consulta__c,SEG_Idioma__c,CC_AcuseRecibo__c,Subject,RecordTypeId,AccountId,ContactId,CC_MailTelfNotif__c 
                     FROM Case WHERE RecordTypeId =: recordTypeCliente AND subject = 'test 12' LIMIT 1];
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        caso.CC_MailTelfNotif__c = contacto.Email;
        update caso;

        
        System.runAs ( supervisor ) {
            Test.startTest();
                SEG_redactarEmail_Controller.identificarDestinatario(caso.id, contacto.Email);
            Test.stopTest();   
            Case caso1 =[SELECT Id, Status , contactId, contact.email FROM Case WHERE id =: caso.id LIMIT 1];
            system.assertNotEquals(caso1.status, null , 'Caso pendiente');     
        }
    }

    @IsTest
    static void identificarDestinatarioP2_Test(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        String emailcntct = 'test@test.com';
        id recordTypeColaborador = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();

        Account cuenta = new Account();
        cuenta.Name ='Cuenta';
        cuenta.SEG_NotasEmpresaSR__c = 'notasEmpresa';
        insert cuenta;
        
        Contact contacto = new Contact();
        contacto.RecordTypeId = recordTypeColaborador;
        contacto.LastName = 'Contacto';
        contacto.Email = emailcntct;
        contacto.accountID=cuenta.Id;
        insert contacto;

        Case caso =[SELECT Id,ContactId, contact.email FROM Case WHERE subject = 'test 12' LIMIT 1];

        
        System.runAs ( supervisor ) {
            Test.startTest();
                SEG_redactarEmail_Controller.identificarDestinatario(caso.id,emailcntct);
            Test.stopTest();  
            Case caso1 = [SELECT Id, Status , contactId, contact.email FROM Case WHERE id =: caso.id LIMIT 1];
            system.assertNotEquals(caso1.status, null , 'Caso pendiente');     
        }
    }

    @IsTest
    static void identificarDestinatarioP3_Test(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        String emailcntct = 'test@test.com';
        id recordTypesContacto = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

        Contact contacto = new Contact();
        contacto.RecordTypeId = recordTypesContacto;
        contacto.LastName = 'Contacto1';
        contacto.Email = emailcntct;
        insert contacto;

        Account cuenta = new Account();
        cuenta.Name ='Cuenta';
        cuenta.SEG_NotasEmpresaSR__c = 'notasEmpresa';
        insert cuenta;

        Case caso = [SELECT Id, Status , contactId, contact.email FROM Case WHERE subject = 'test 12' LIMIT 1];
        
        System.runAs ( supervisor ) {
            Test.startTest();
                SEG_redactarEmail_Controller.identificarDestinatario(caso.id,emailcntct);
            Test.stopTest(); 
            Case caso1 = [SELECT Id, Status , contactId, contact.email FROM Case WHERE id =: caso.id LIMIT 1];
            system.assertNotEquals(caso1.status, null , 'Caso pendiente');     
        }
           
    }

    @IsTest
    static void enviarCorreoRemitir3Test(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        //RT Empleado
        Contact cntct =[SELECT Id,RecordTypeId FROM Contact WHERE LastName = 'Contacto SEG 1'];
        cntct.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        update cntct;
        //String fechaplan = String.valueOf(System.now());
        Case caso =[SELECT Id,ContactId FROM Case LIMIT 1];
        EmailMessage dataEmail = [SELECT Id,LastModifiedById,FromAddress, htmlBody,Subject FROM EmailMessage LIMIT 1];
        String emailbody = 'prueba';
        String cambioPara = 'newPara@gmail.com';
        List<String> paraList = new List<String>();
        paraList.add('buzon.segmentos1@gmail.com');
        List<String> copiaList = new List<String>();
        List<String> listaAnexos = new List<String>();
        listaAnexos.add('0');
        String subject = 'Hola';
        String boton = 'botonNuevo';
        String botonR = 'botonReenviar';
        Datetime revision = Datetime.now();

        //Fecha Plan
        
        System.runAs ( supervisor ) {
            Test.startTest();
                SEG_redactarEmail_Controller.enviarCorreo(caso.Id, dataEmail, emailBody,subject, paraList, copiaList, true, false, listaAnexos, caso.ContactId,false,subject,revision, boton,null,copiaList);
            Test.stopTest();
            EmailMessage mensajeEnviado = [SELECT id, parentId FROM EmailMessage WHERE parentId =: caso.id AND incoming = false ORDER BY createdDate DESC LIMIT 1];
            system.assertNotEquals(mensajeEnviado, null, 'Mensaje no enviado'); 
        }
    }
    
    @IsTest
    static void enviarCorreoRemitir4Test1(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        // RT COLABORADOR
        // BOTON NUEVO
        Contact cntct =[SELECT Id,RecordTypeId FROM Contact WHERE LastName = 'Contacto SEG 1'];
        cntct.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        update cntct;
        
        String fechaplan = String.valueOf(System.now());
        Case caso =[SELECT Id,ContactId FROM Case LIMIT 1];
        EmailMessage dataEmail = [SELECT Id,LastModifiedById,FromAddress, htmlBody,Subject FROM EmailMessage LIMIT 1];
        String emailbody = 'prueba';
        String cambioPara = 'newPara@gmail.com';
        List<String> paraList = new List<String>();
        paraList.add('buzon.segmentos1@gmail.com');
        List<String> copiaList = new List<String>();
        List<String> listaAnexos = new List<String>();
        listaAnexos.add('0');
        String subject = 'Hola';
        String boton = 'botonNuevo';
        Datetime revision = Datetime.now();

        //sin fecha plan
        
        System.runAs ( supervisor ) {
            Test.startTest();
                SEG_redactarEmail_Controller.enviarCorreo(caso.Id, dataEmail, emailBody, subject, paraList, copiaList, true, false, listaAnexos, caso.ContactId,false,null,revision, boton,null,copiaList);
            Test.stopTest();
            EmailMessage mensajeEnviado = [SELECT id, parentId FROM EmailMessage WHERE parentId =: caso.id AND incoming = false ORDER BY createdDate DESC LIMIT 1];
            system.assertNotEquals(mensajeEnviado, null, 'Mensaje no enviado'); 
        }
        
    }
    @IsTest
    static void enviarCorreoRemitir4Test(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        // RT COLABORADOR
        // BOTON NUEVO
        Contact cntct =[SELECT Id,RecordTypeId FROM Contact WHERE LastName = 'Contacto SEG 1'];
        cntct.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        update cntct;
        
        //String fechaplan = String.valueOf(System.now());
        Datetime fechaPlan = System.now();
        Case caso =[SELECT Id,ContactId FROM Case LIMIT 1];
        EmailMessage dataEmail = [SELECT Id,LastModifiedById,FromAddress, htmlBody,Subject FROM EmailMessage LIMIT 1];
        String emailbody = 'prueba';
        String cambioPara = 'newPara@gmail.com';
        List<String> paraList = new List<String>();
        paraList.add('buzon.segmentos1@gmail.com');
        List<String> copiaList = new List<String>();
        List<String> listaAnexos = new List<String>();
        listaAnexos.add('0');
        String subject = 'Hola';
        String boton = 'botonNuevo';
        Datetime revision = Datetime.now();

        
        System.runAs ( supervisor ) {
            Test.startTest();
            //fecha plan
                SEG_redactarEmail_Controller.enviarCorreo(caso.Id, dataEmail, emailBody,subject, paraList, copiaList, true, false, listaAnexos, caso.ContactId,false,null, revision ,boton, null,copiaList);
            Test.stopTest();
            EmailMessage mensajeEnviado = [SELECT id, parentId FROM EmailMessage WHERE parentId =: caso.id AND incoming = false ORDER BY createdDate DESC LIMIT 1];
            system.assertNotEquals(mensajeEnviado, null, 'Mensaje no enviado'); 
        }
    }

    @IsTest
    static void enviarCorreoRemitir4Test3(){
        		User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        // RT COLABORADOR
        // BOTON NUEVO
        Contact cntct =[SELECT Id,RecordTypeId FROM Contact WHERE LastName = 'Contacto SEG 1'];
        cntct.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        update cntct;
        
        //String fechaplan = String.valueOf(System.now());
        Datetime fechaPlan = System.now();
        Case caso =[SELECT Id,ContactId FROM Case LIMIT 1];
        EmailMessage dataEmail = [SELECT Id,LastModifiedById,FromAddress, htmlBody,Subject FROM EmailMessage LIMIT 1];
        String emailbody = 'prueba';
        String cambioPara = 'newPara@gmail.com';
        List<String> paraList = new List<String>();
        paraList.add('buzon.segmentos1@gmail.com');
        List<String> copiaList = new List<String>();
        List<String> listaAnexos = new List<String>();
        listaAnexos.add('0');
        String subject = 'Hola';
        String boton = 'botonNuevo';
        Datetime revision = Datetime.now();

        
        System.runAs ( supervisor ) {
            Test.startTest();
            //true
                SEG_redactarEmail_Controller.enviarCorreo(caso.Id, dataEmail, emailBody,subject, paraList, copiaList, true, false, listaAnexos, caso.ContactId,true,null,revision, boton,null,copiaList);
            Test.stopTest();
            EmailMessage mensajeEnviado = [SELECT id, parentId FROM EmailMessage WHERE parentId =: caso.id AND incoming = false ORDER BY createdDate DESC LIMIT 1];
            system.assertNotEquals(mensajeEnviado, null, 'Mensaje no enviado'); 
        }
    }    
    
    @IsTest
    static void enviarCorreoRemitir6Test(){
        		User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Contact cntct =[SELECT Id,RecordTypeId FROM Contact WHERE LastName = 'Contacto SEG 1'];
        cntct.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        update cntct;
        //String fechaplan = String.valueOf(System.now());
        Datetime fechaplan = System.now();
        Case caso =[SELECT Id,ContactId FROM Case LIMIT 1];
        
        EmailMessage dataEmail = [SELECT Id,LastModifiedById,FromAddress, htmlBody,Subject FROM EmailMessage LIMIT 1];
        String emailbody = 'prueba';
        String cambioPara = 'newPara@gmail.com';
        List<String> paraList = new List<String>();
        paraList.add('buzon.segmentos1@gmail.com');
        List<String> copiaList = new List<String>();
        List<String> listaAnexos = new List<String>();
        listaAnexos.add('0');
        String subject = 'Hola';
        String boton = 'botonNuevo';
        Datetime revision = Datetime.now();
        
        
        System.runAs ( supervisor ) {
            Test.startTest();
                SEG_redactarEmail_Controller.enviarCorreo(caso.Id, dataEmail, emailBody,subject, paraList, copiaList, true, false, listaAnexos, caso.ContactId,false,null,revision, boton,null,copiaList);
    
            Test.stopTest();
            EmailMessage mensajeEnviado = [SELECT id, parentId FROM EmailMessage WHERE parentId =: caso.id AND incoming = false ORDER BY createdDate DESC LIMIT 1];
            system.assertNotEquals(mensajeEnviado, null, 'Mensaje no enviado'); 
        }
    }

    @IsTest
    static void enviarCorreoGCTest(){
        		User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Id recordDet = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
        CC_MCC__c mccDetalle3 = new CC_MCC__c();
        mccDetalle3.RecordTypeId = recordDet;
        mccDetalle3.Name = 'Detalle';
        mccDetalle3.CC_Tipo_Cliente__c = 'Cliente';
        mccDetalle3.CC_Codigo_Externo__c = 'DE-000003';
        insert mccDetalle3;

        EmailTemplate plantillaEmail = [SELECT Id FROM EmailTemplate LIMIT 1];

        SEG_Plantilla__c plantilla = new SEG_Plantilla__C();
        plantilla.Name ='Plantilla Col';
        plantilla.SEG_TipoOperativa__c = 'Acuse de recibo';
        plantilla.SEG_PlantillaCastellanoID__c= plantillaEmail.Id; //00X5r000000LxqTEAS
        plantilla.SEG_Activa__c = true;
        insert plantilla;

        Id grColId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
		//Asignamos el RecordType ='Grupo Colaborador'
        CC_Grupo_Colaborador__c grupoRTGrupoCol = new CC_Grupo_Colaborador__c();
        grupoRTGrupoCol.Name='Grupo Colaborador';
        grupoRTGrupoCol.RecordTypeId = grColId;
        insert grupoRTGrupoCol;

        CC_Grupo_Colaborador__c grupoRTGrupoColRes = new CC_Grupo_Colaborador__c();
        grupoRTGrupoColRes.Name='Grupo Colaborador 2';
        grupoRTGrupoColRes.RecordTypeId = grColId;
        grupoRTGrupoColRes.SEG_GrupoSegmentos__c = true;
        insert grupoRTGrupoColRes;

        //Grupo MCC link Grupo Colaborador
        CC_MCC_Grupo_Colaborador__c  grupoCol = new CC_MCC_Grupo_Colaborador__c();
        grupoCol.Name='Colaborador';
        grupoCol.CC_MCC__c = mccDetalle3.Id; 
        grupoCol.CC_Grupo_Colaborador__c=grupoRTGrupoCol.id;
        grupoCol.SEG_Zona__c = 'Todas';
        grupoCol.SEG_Organizacion__c = 'Todas';
        grupoCol.SEG_Grupo_respuesta__c = grupoRTGrupoColRes.id ;
        insert grupoCol;

        //Creamos una plantilla para usar en RT = 'Grupo Colaborador'
        CC_Grupo_Colaborador_Plantilla__c plantillagrupo = new CC_Grupo_Colaborador_Plantilla__c();
        plantillagrupo.CC_Operativa__c= 'Trasladar';
        plantillagrupo.SEG_Plantilla__c=plantilla.id;
        plantillagrupo.CC_Grupo_Colaborador__c = grupoRTGrupoCol.id;
        insert plantillagrupo;

        //Account
        Account cuenta = new Account(Name='Cuenta', SEG_NotasEmpresaSR__c = 'notasEmpresa');
        insert cuenta;

        Contact contacto = new Contact();
        contacto.LastName = 'Contacto1';
        contacto.AccountId = cuenta.Id;
        insert contacto;

        Contact cntct =[SELECT Id,RecordTypeId FROM Contact WHERE LastName = 'Contacto SEG 1' LIMIT 1];
        cntct.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        update cntct;
        
        Case caso =[SELECT Id,ContactId FROM Case LIMIT 1];
        caso.SEG_Detalle__c = mccDetalle3.id;
        caso.ContactId = contacto.id; 
        update caso;
        
        EmailMessage dataEmail = [SELECT Id,LastModifiedById,FromAddress, htmlBody,Subject FROM EmailMessage LIMIT 1];
        String emailbody = 'prueba';
        String cambioPara = 'newPara@gmail.com';
        List<String> paraList = new List<String>();
        paraList.add('buzon.segmentos1@gmail.com');
        List<String> copiaList = new List<String>();
        List<String> listaAnexos = new List<String>();
        listaAnexos.add('0');

        CC_Grupo_Colaborador_Contact__c gC1 = new CC_Grupo_Colaborador_Contact__c();
        gC1.CC_Usuario__c = supervisor.Id;
        gC1.CC_Grupo_Colaborador__c = grupoRTGrupoCol.Id;
        gC1.CC_Contacto__c = cntct.id;
        insert gC1;
        String subject = 'Hola';
        String boton = 'botonNuevo';
        Datetime revision = Datetime.now();

        
        System.runAs ( supervisor ) {
            Test.startTest();
                SEG_redactarEmail_Controller.enviarCorreo(caso.Id, dataEmail, emailBody,subject, paraList, copiaList, true, false, listaAnexos, grupoRTGrupoCol.Id,false,null,revision, boton,null,copiaList);
            Test.stopTest();

            EmailMessage mensajeEnviado = [SELECT id, parentId FROM EmailMessage WHERE parentId =: caso.id AND incoming = false ORDER BY createdDate DESC LIMIT 1];
            system.assertNotEquals(mensajeEnviado, null, 'Mensaje no enviado'); 
        }
    }   

    @IsTest
    static void getCanalesComunicacionManualesParaTest(){
        		User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Account cuenta =[SELECT id, Name FROM Account WHERE Name='Cuenta' LIMIT 1];
        Case caso =[SELECT Id, subject, AccountId FROM Case WHERE subject = 'test 1' LIMIT 1];
        caso.AccountId = cuenta.id;
        update caso;
        Contact contacto =[SELECT id, LastName FROM Contact WHERE LastName = 'Contacto SEG 1' LIMIT 1];
        
        String emails = 'test@test.com';

        CC_Canal_Com__c canalCom = new CC_Canal_Com__c();
        canalCom.CC_ContactoId__c = contacto.Id;
        canalCom.CC_Email__c = 'Estamoaqui@mail.com';
        canalCom.CC_CuentaId__c = cuenta.id ;
        canalCom.SEG_ParaCC__c = 'Para' ;
        insert canalCom;    
        Boolean noContactos = false;
        String idBotonPara = 'BotonPara';
		String idBotonCC = 'BotonCc';
        String idBotonCCo = 'BotonCco';
        
        
        System.runAs ( supervisor ) {
            Test.startTest();
                SEG_redactarEmail_Controller.ListadoEmailsWrapper wrapper1 = SEG_redactarEmail_Controller.getCanalesComunicacionManuales(caso.Id,emails,noContactos,idBotonPara);
                SEG_redactarEmail_Controller.ListadoEmailsWrapper wrapper2 = SEG_redactarEmail_Controller.getCanalesComunicacionManuales(caso.Id,emails,noContactos,idBotonCC);
                SEG_redactarEmail_Controller.ListadoEmailsWrapper wrapper3 = SEG_redactarEmail_Controller.getCanalesComunicacionManuales(caso.Id,emails,noContactos,idBotonCCo);
                SEG_redactarEmail_Controller.ListadoEmailsWrapper wrapper4 = SEG_redactarEmail_Controller.getCanalesComunicacionManuales(caso.Id,emails,true,idBotonCCo);
            Test.stopTest();

            system.assertNotEquals(wrapper1, null, 'Nok');
            system.assertNotEquals(wrapper2, null, 'Nok'); 
            system.assertNotEquals(wrapper3, null, 'Nok'); 
            system.assertNotEquals(wrapper4, null, 'Nok'); 
        }

    }

    @IsTest
    static void fetchNotasTipificadasTest(){
        		User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Case caso =[SELECT Id,CC_Detalles_Consulta__c FROM Case WHERE subject = 'test 12' LIMIT 1]; 
        caso.CC_Detalles_Consulta__c = null;
        update caso;
        
        System.runAs ( supervisor ) {
            Test.startTest();
            Map<Id, String> mapaNotas = SEG_redactarEmail_Controller.fetchNotasTipificadas(caso.id);
            Test.stopTest();  
            system.assertNotEquals(mapaNotas.size(), 0, 'Sin notas'); 
        }
    }

    @IsTest
    static void postOnChatterTest(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Case caso =[SELECT Id,CC_Detalles_Consulta__c FROM Case LIMIT 1]; 
        caso.CC_Detalles_Consulta__c = null;
        update caso;
        
        System.runAs ( supervisor ) {
            Test.startTest();
                SEG_redactarEmail_Controller.postOnChatter(caso.id,'Test','test','Sin notas');
            Test.stopTest();  
        }

        FeedItem insertedPost = [SELECT id, parentId FROM FeedItem WHERE parentId =: caso.id ORDER BY createdDate DESC LIMIT 1];  
        system.assertNotEquals(insertedPost, null, 'Post a chatter erroneo'); 
    }

    @IsTest
    static void postOnChatterTest2(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Case caso =[SELECT Id,CC_Detalles_Consulta__c FROM Case LIMIT 1]; 
        caso.CC_Detalles_Consulta__c = null;
        update caso;

        SEG_NotasTipificadas__c nota = [SELECT Id from SEG_NotasTipificadas__c LIMIT 1];
        
        System.runAs ( supervisor ) {
            Test.startTest();
                SEG_redactarEmail_Controller.postOnChatter(caso.id,'','test',String.valueOf(nota.Id));
            Test.stopTest();  
        }

        FeedItem insertedPost = [SELECT id, parentId FROM FeedItem WHERE parentId =: caso.id ORDER BY createdDate DESC LIMIT 1];  
        system.assertNotEquals(insertedPost, null, 'Post a chatter erroneo'); 
    }
    
    @IsTest
    static void getNombreEmailContactoTest(){
        		User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Case caso =[SELECT Id,ContactId FROM Case LIMIT 1]; 
        caso.CC_Detalles_Consulta__c = null;
        update caso;
        
        System.runAs ( supervisor ) {
            Test.startTest();
                Contact contacto =  SEG_redactarEmail_Controller.getNombreEmailContacto(caso.ContactId);
            Test.stopTest();    
            system.assertNotEquals(contacto, null, 'Sin contacto'); 
        }
    }
    
    @IsTest
    static void recuperarResultadosTest(){
        		User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        
        System.runAs ( supervisor ) {
            Test.startTest();
                List<String> result = SEG_redactarEmail_Controller.recuperarResultados();
            Test.stopTest();   
            system.assertNotEquals(result, null, 'Sin contacto'); 
        }
    }

    @IsTest
    static void informarNumOperacionesCasoTest(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Case caso =[SELECT Id,ContactId, SEG_N_operaciones_del_caso__c, subject FROM Case WHERE subject = 'test 1' LIMIT 1]; 
        
        System.runAs ( supervisor ) {
            Test.startTest();
                SEG_redactarEmail_Controller.informarNumOperacionesCaso(caso.id, 3, 4);
            Test.stopTest();   
            Case caso1 =[SELECT Id,ContactId, SEG_N_operaciones_del_caso__c, subject FROM Case WHERE subject = 'test 1' LIMIT 1]; 
            system.assertEquals(caso1.SEG_N_operaciones_del_caso__c, 3, 'Numero operaciones no cambiado'); 
        }
    }
    @IsTest
    static void noInformarNumOperacionesCasoTest(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Case caso =[SELECT Id,ContactId, SEG_N_operaciones_del_caso__c, subject FROM Case WHERE subject = 'test 1' LIMIT 1]; 
        
        System.runAs ( supervisor ) {
            Test.startTest();
                SEG_redactarEmail_Controller.informarNumOperacionesCaso(caso.id, 5, 5);
            Test.stopTest();   
            Case caso1 =[SELECT Id,ContactId, SEG_N_operaciones_del_caso__c, subject FROM Case WHERE subject = 'test 1' LIMIT 1]; 
            system.assertNotEquals(caso1.SEG_N_operaciones_del_caso__c, 5, 'Numero operaciones cambiado'); 
        }
    }
}