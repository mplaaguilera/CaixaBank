@isTest
public with sharing class EmailPublisherLoader_Test {
    
    @isTest
    public static void test() {
        Exception failureDuringExecution = null;

        //Preparación de los datos
        List<String> operativasCases = new List<String>{'Trasladar a colaborador','Remitir a colaborador','Solicitud de información','Responder a Clientes Formulario Web'};
        Map<String, Case> casesInsertMap = crearCasoPrueba(operativasCases);
        insert casesInsertMap.values();
        /*Case casoTrasladarColaborador = crearCasoPrueba('Trasladar a colaborador');
        Case casoRemitirColaborador = crearCasoPrueba('Remitir a colaborador');
        Case casoSolicitudInfo = crearCasoPrueba('Solicitud de información');
        Case casoResponderCliente = crearCasoPrueba('Responder a Clientes Formulario Web');*/
        Case casoResponderClienteCOPS = crearCasoPruebaCOPS('Responder a Clientes Formulario Web');

        //Ejecución de las prueba
        Test.startTest();
        List<Map<String, Object>> defaultSettingAsObject = new List<Map<String, Object>>();
        List<QuickAction.SendEmailQuickActionDefaults> defaultsSettings = new List<QuickAction.SendEmailQuickActionDefaults>();

        //Trasladar a colaborador
        if (casesInsertMap.containsKey('Trasladar')) {
            //List<Map<String, Object>> defaultSettingAsObject = new List<Map<String, Object>> {
            defaultSettingAsObject = new List<Map<String, Object>> {
                new Map<String, Object> {
                    'targetSObject' => new EmailMessage(),
                    'contextId' => casesInsertMap.get('Trasladar').Id,
                    'actionType' => 'Email',
                    'actionName' => 'Case.Email_Colaborador',
                    'fromAddressList' => new List<String> {'salesforce@test.com'}
                }
            };

            defaultsSettings =
                (List<QuickAction.SendEmailQuickActionDefaults>)JSON.deserialize(JSON.serialize(defaultSettingAsObject), List<QuickAction.SendEmailQuickActionDefaults>.class);

            try {
                (new EmailPublisherLoader()).onInitDefaults(defaultsSettings);
            } catch(Exception e) {
                failureDuringExecution = e; 
            }
        }

        //Remitir a colaborador
        if (casesInsertMap.containsKey('Remitir')) {
            defaultSettingAsObject.clear();
            defaultSettingAsObject = new List<Map<String, Object>> {
                new Map<String, Object> {
                    'targetSObject' => new EmailMessage(),
                    'contextId' => casesInsertMap.get('Remitir').Id,
                    'actionType' => 'Email',
                    'actionName' => 'Case.Email_Colaborador',
                    'fromAddressList' => new List<String> {'salesforce@test.com'}
                }
            };

            defaultsSettings.clear();
            defaultsSettings = (List<QuickAction.SendEmailQuickActionDefaults>)JSON.deserialize(JSON.serialize(defaultSettingAsObject), List<QuickAction.SendEmailQuickActionDefaults>.class);

            try {
                (new EmailPublisherLoader()).onInitDefaults(defaultsSettings);
            } catch(Exception e) {
                failureDuringExecution = e; 
            }
        }

        //Solicitud de información
        if (casesInsertMap.containsKey('Solicitar')) {
            defaultSettingAsObject.clear();
            defaultSettingAsObject = new List<Map<String, Object>> {
                new Map<String, Object> {
                    'targetSObject' => new EmailMessage(),
                    'contextId' => casesInsertMap.get('Solicitar').Id,
                    'actionType' => 'Email',
                    'actionName' => 'Case.Email_Colaborador',
                    'fromAddressList' => new List<String> {'salesforce@test.com'}
                }
            };

            defaultsSettings.clear();
            defaultsSettings = (List<QuickAction.SendEmailQuickActionDefaults>)JSON.deserialize(JSON.serialize(defaultSettingAsObject), List<QuickAction.SendEmailQuickActionDefaults>.class);

            try {
                (new EmailPublisherLoader()).onInitDefaults(defaultsSettings);
            } catch(Exception e) {
                failureDuringExecution = e; 
            }
        }

        //Responder a cliente
        if (casesInsertMap.containsKey('Responder')) {
            defaultSettingAsObject.clear();
            defaultSettingAsObject = new List<Map<String, Object>> {
                new Map<String, Object> {
                    'targetSObject' => new EmailMessage(),
                    'contextId' => casesInsertMap.get('Responder').Id,
                    'actionType' => 'Email',
                    'actionName' => 'Case.Email_Colaborador',
                    'fromAddressList' => new List<String> {'salesforce@test.com'}
                }
            };

            defaultsSettings.clear();
            defaultsSettings = (List<QuickAction.SendEmailQuickActionDefaults>)JSON.deserialize(JSON.serialize(defaultSettingAsObject), List<QuickAction.SendEmailQuickActionDefaults>.class);

            try {
                (new EmailPublisherLoader()).onInitDefaults(defaultsSettings);
            } catch(Exception e) {
                failureDuringExecution = e; 
            }
        }

        //Ejecución de las pruebas de Cops
        List<Map<String, Object>> defaultSettingAsObject2 = new List<Map<String, Object>>();
        List<QuickAction.SendEmailQuickActionDefaults> defaultsSettings2 = new List<QuickAction.SendEmailQuickActionDefaults>();

        //Trasladar a colaborador
        if (casesInsertMap.containsKey('Trasladar')) {
            //List<Map<String, Object>> defaultSettingAsObject2 = new List<Map<String, Object>> {
            defaultSettingAsObject2 = new List<Map<String, Object>> {
                new Map<String, Object> {
                    'targetSObject' => new EmailMessage(),
                    'contextId' => casesInsertMap.get('Trasladar').Id,
                    'actionType' => 'Email',
                    'actionName' => 'Case.OS_Enviar_Correo',
                    'fromAddressList' => new List<String> {'salesforce@test.com'}
                }
            };

            defaultsSettings2 =
                (List<QuickAction.SendEmailQuickActionDefaults>)JSON.deserialize(JSON.serialize(defaultSettingAsObject2), List<QuickAction.SendEmailQuickActionDefaults>.class);

            try {
                (new EmailPublisherLoader()).onInitDefaults(defaultsSettings2);
            } catch(Exception e) {
                failureDuringExecution = e; 
            }
        }

        //Remitir a colaborador
        if (casesInsertMap.containsKey('Remitir')) {
            defaultSettingAsObject2.clear();
            defaultSettingAsObject2 = new List<Map<String, Object>> {
                new Map<String, Object> {
                    'targetSObject' => new EmailMessage(),
                    'contextId' => casesInsertMap.get('Remitir').Id,
                    'actionType' => 'Email',
                    'actionName' => 'Case.OS_Enviar_Correo',
                    'fromAddressList' => new List<String> {'salesforce@test.com'}
                }
            };

            defaultsSettings2.clear();
            defaultsSettings2 = (List<QuickAction.SendEmailQuickActionDefaults>)JSON.deserialize(JSON.serialize(defaultSettingAsObject2), List<QuickAction.SendEmailQuickActionDefaults>.class);

            try {
                (new EmailPublisherLoader()).onInitDefaults(defaultsSettings2);
            } catch(Exception e) {
                failureDuringExecution = e; 
            }
        }

        //Solicitud de información
        if (casesInsertMap.containsKey('Solicitar')) {
            defaultSettingAsObject2.clear();
            defaultSettingAsObject2 = new List<Map<String, Object>> {
                new Map<String, Object> {
                    'targetSObject' => new EmailMessage(),
                    'contextId' => casesInsertMap.get('Solicitar').Id,
                    'actionType' => 'Email',
                    'actionName' => 'Case.OS_Enviar_Correo',
                    'fromAddressList' => new List<String> {'salesforce@test.com'}
                }
            };

            defaultsSettings2.clear();
            defaultsSettings2 = (List<QuickAction.SendEmailQuickActionDefaults>)JSON.deserialize(JSON.serialize(defaultSettingAsObject2), List<QuickAction.SendEmailQuickActionDefaults>.class);

            try {
                (new EmailPublisherLoader()).onInitDefaults(defaultsSettings2);
            } catch(Exception e) {
                failureDuringExecution = e; 
            }
        }
        
        //ResponderCliente único correo
        defaultSettingAsObject2.clear();
        defaultSettingAsObject2 = new List<Map<String, Object>> {
            new Map<String, Object> {
                'targetSObject' => new EmailMessage(),
                'contextId' => casoResponderClienteCOPS.Id,
                'actionType' => 'Email',
                'actionName' => 'Case.OS_Enviar_Correo',
                'fromAddressList' => new List<String> {'salesforce@test.com'}
            }
        };

        defaultsSettings2.clear();
        defaultsSettings2 = (List<QuickAction.SendEmailQuickActionDefaults>)JSON.deserialize(JSON.serialize(defaultSettingAsObject2), List<QuickAction.SendEmailQuickActionDefaults>.class);

        try {
            (new EmailPublisherLoader()).onInitDefaults(defaultsSettings2);
        } catch(Exception e) {
            failureDuringExecution = e; 
        }

        //Responder a cliente
        if (casesInsertMap.containsKey('Responder')) {
            defaultSettingAsObject2.clear();
            defaultSettingAsObject2 = new List<Map<String, Object>> {
                new Map<String, Object> {
                    'targetSObject' => new EmailMessage(),
                    'contextId' => casesInsertMap.get('Responder').Id,
                    'actionType' => 'Email',
                    'actionName' => 'Case.OS_Enviar_Correo',
                    'fromAddressList' => new List<String> {'salesforce@test.com'}
                }
            };

            defaultsSettings2.clear();
            defaultsSettings2 = (List<QuickAction.SendEmailQuickActionDefaults>)JSON.deserialize(JSON.serialize(defaultSettingAsObject2), List<QuickAction.SendEmailQuickActionDefaults>.class);

            try {
                (new EmailPublisherLoader()).onInitDefaults(defaultsSettings2);
            } catch(Exception e) {
                failureDuringExecution = e; 
            }
        }

        Test.stopTest();       
        
        System.assertEquals(null, failureDuringExecution, 'Ha ocurrido una excepción durante la ejecución del test.');

    }

    //private static Case crearCasoPrueba(String operativa) {
    private static Map<String, Case> crearCasoPrueba (List<String> operativa) {
        
        //Cabecera y pie de plantilla (sin importar la operativa)
        Id idFolderCabeceraPie = [SELECT Id FROM Folder WHERE Name = 'Cabecera y pie de plantilla' AND ParentId = null].Id;
        String plantillaCabecera = [SELECT DeveloperName FROM EmailTemplate WHERE FolderId = :idFolderCabeceraPie LIMIT 1].DeveloperName;
        String plantillaPie = [SELECT DeveloperName FROM EmailTemplate WHERE FolderId = :idFolderCabeceraPie LIMIT 1].DeveloperName;

        //Plantilla cuerpo
        Id idFolderCuerpo = [SELECT Id FROM Folder WHERE Name = 'Operativas' AND ParentId = null].Id;
        /*
        idFolderCuerpo = [SELECT Id FROM Folder WHERE Name = :operativa AND ParentId = :idFolderCuerpo].Id;
        idFolderCuerpo = [SELECT Id FROM Folder WHERE Name = 'Castellano' AND ParentId = :idFolderCuerpo].Id;

        if (operativa == 'Solicitud de información' || operativa == 'Responder a Clientes Formulario Web') {
            idFolderCuerpo = [SELECT Id FROM Folder WHERE Name = 'Formal' AND ParentId = :idFolderCuerpo].Id;
        }
        
        String idPlantillaCuerpo = [SELECT Id FROM EmailTemplate WHERE FolderId = :idFolderCuerpo LIMIT 1].Id;
        */
        List<Folder> foldersOperativas = [SELECT Id FROM Folder WHERE Name = :operativa AND ParentId = :idFolderCuerpo];
        List<Folder> foldersOpCastellano = [SELECT Id, DeveloperName FROM Folder WHERE Name = 'Castellano' AND ParentId = :foldersOperativas];
        List<Folder> foldersOpCastellanoFormal = [SELECT Id, ParentId, DeveloperName FROM Folder WHERE Name = 'Formal' AND ParentId = :foldersOpCastellano];
        List<Folder> lstIdFolderCuerpo = new List<Folder>();
        for (Folder f : foldersOpCastellano) {
            Folder addFolder = f;
            for (Folder f2 : foldersOpCastellanoFormal) {
                if (f2.ParentId == f.Id) {
                    addFolder = f2;
                    break;
                }
            }
            lstIdFolderCuerpo.add(addFolder);
        }
        List<EmailTemplate> idPlantillaCuerpo = [SELECT Id, FolderId FROM EmailTemplate WHERE FolderId = :lstIdFolderCuerpo];
        Map<String, String> mapFolderPlantilla = new Map<String, String>();
        for (Folder f : lstIdFolderCuerpo) {
            for (EmailTemplate et : idPlantillaCuerpo) {
                if (et.FolderId == f.Id) {
                    mapFolderPlantilla.put(f.Id, et.Id);
                    break;
                }
            }
        }

        //Caso
        Map<String, Case> mapCasos = new Map<String, Case>();
        for (Folder f : lstIdFolderCuerpo) {
            Case caso = new Case();
            caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            caso.Subject = 'Caso Test';
            caso.CC_Idioma__c = 'es';
            caso.CC_Referencia_Correo_Saliente__c = CC_EmailMessage.generarReferenciaCorreoSaliente();
            caso.CC_Email_Cabecera__c = plantillaCabecera;
            if (mapFolderPlantilla.containsKey(f.Id)) {
                caso.CC_MCC_Plantilla__c = mapFolderPlantilla.get(f.Id);
            }
            caso.CC_Email_Pie__c = plantillaPie;
            String tmpOperativa = 'Remitir';
            if (f.DeveloperName.containsIgnoreCase('Trasladar')) {
                tmpOperativa = 'Trasladar';
            } else if (f.DeveloperName.containsIgnoreCase('Solicitar')) {
                tmpOperativa = 'Solicitar';
            } else if (f.DeveloperName.containsIgnoreCase('Responder')) {
                tmpOperativa = 'Responder';
            }
            mapCasos.put(tmpOperativa, caso);
        }
        //insert caso;

        //return caso;
        return mapCasos;
    }    
    
    private static Case crearCasoPruebaCOPS(String operativa) {
        
        //Cabecera y pie de plantilla (sin importar la operativa)
        Id idFolderCabeceraPie = [SELECT Id FROM Folder WHERE Name = 'Cabecera y pie de plantilla' AND ParentId = null].Id;
        String plantillaCabecera = [SELECT DeveloperName FROM EmailTemplate WHERE FolderId = :idFolderCabeceraPie LIMIT 1].DeveloperName;
        String plantillaPie = [SELECT DeveloperName FROM EmailTemplate WHERE FolderId = :idFolderCabeceraPie LIMIT 1].DeveloperName;

        //Plantilla cuerpo
        Id idFolderCuerpo = [SELECT Id FROM Folder WHERE Name = 'Operativas' AND ParentId = null].Id;
        idFolderCuerpo = [SELECT Id FROM Folder WHERE Name = :operativa AND ParentId = :idFolderCuerpo].Id;
        idFolderCuerpo = [SELECT Id FROM Folder WHERE Name = 'Castellano' AND ParentId = :idFolderCuerpo].Id;

        if (operativa == 'Solicitud de información' || operativa == 'Responder a Clientes Formulario Web') {
            idFolderCuerpo = [SELECT Id FROM Folder WHERE Name = 'Formal' AND ParentId = :idFolderCuerpo].Id;
        }
        
        String idPlantillaCuerpo = [SELECT Id FROM EmailTemplate WHERE FolderId = :idFolderCuerpo LIMIT 1].Id;

        
        //Caso
        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        caso.Subject = 'Caso Test';
        caso.CC_Idioma__c = 'es';
        caso.CC_Referencia_Correo_Saliente__c = CC_EmailMessage.generarReferenciaCorreoSaliente();
        caso.CC_Email_Cabecera__c = plantillaCabecera;
        caso.CC_MCC_Plantilla__c = idPlantillaCuerpo;
        caso.CC_Email_Pie__c = plantillaPie;
        caso.CC_URL_Encuesta_3N__c = 'https://opina.caixabank.com/index.php?r=survey/index&';
        caso.CC_Ultima_Operativa_Correo__c = 'Cerrado con encuesta';
        insert caso;

        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'OS_%' LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;
        
        EmailMessage correo = new EmailMessage();
        correo.RelatedToId = caso.Id;
        correo.TextBody='CORREO ENTRANTE';
        correo.Incoming=true;
        correo.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        insert correo;
        
        caso.OS_Email_Seleccionado__c = correo.Id;
		update caso;
        
        return caso;
    }    
}