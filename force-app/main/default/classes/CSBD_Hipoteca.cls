public with sharing class CSBD_Hipoteca {

    public static void automatismosHipotecas(List<Id> idOportunidades) {
        List<Opportunity> oportunidades = [SELECT CSBD_Now_Num_Oficina__c, CSBD_Finalidad__c, CSBD_Idioma_Solicitud__c,
                                            CSBD_Email_Solicitud__c, RecordTypeId, IsClosed, CSBD_Now_EmailGestor__c, CSBD_Empresa_Proveedora__c
                                            FROM Opportunity WHERE Id IN :idOportunidades AND CSBD_Canal__c != 'Plataformas Hipotecarias Digitales'];

        for (Opportunity hipoteca : descartarNoHipotecas(oportunidades)) {
            //Para cada solicitud de hipotca
            if (hipoteca.CSBD_Now_Num_Oficina__c != 4223 && hipoteca.CSBD_Empresa_Proveedora__c != 'imaginBank') {
                //La oficina NO es la 4223 (CSBD) y la empresa proveedora no es imaginBank,
                //la oportunidad queda rechazada y se deriva la gestión a la oficina correspondiente vía correo
                try {
                    //Envío de correo de derivación a oficina
                    enviarCorreo(
                        hipoteca.Id,
                        'CSBD - CaixaBank Informa',
                        CSBD_EmailMessage.plantillaOperativaId('Derivación de hipoteca a oficina', idiomaOficina(hipoteca)),
                        destinatariosOficina(hipoteca)
                    );
                    //Rechazo de la oportunidad
                    CSBD_Opportunity.cerrarOportunidad(hipoteca.Id, 'Rechazada', 'Derivada a oficina');
                } catch (Exception e) {
                    CSBD_Activity.crearActividad(hipoteca.Id, 'Error derivando a oficina', 'Completed', 'Error derivando a oficina', e.getMessage());
                }
            }

            if (hipoteca.CSBD_Finalidad__c != 'LEADS') {
                //Envío de correo solicitando documentación al cliente
                try {
                    String operativa = '';
                    if (hipoteca.CSBD_Empresa_Proveedora__c == 'imaginBank') {
                        operativa = 'Solicitud de doc hipoteca - Imagin';
                    } else {
                        operativa = 'Solicitud de documentación hipoteca';
                    }
                    enviarCorreo(
                        hipoteca.Id,
                        hipoteca.CSBD_Empresa_Proveedora__c == 'imaginBank' ? 'CSBD - ImaginBank' : 'CSBD - CaixaBank',
                        CSBD_EmailMessage.plantillaOperativaId(operativa, hipoteca.CSBD_Idioma_Solicitud__c),
                        new Map<String, List<String>>{'Para' => new List<String>{hipoteca.CSBD_Email_Solicitud__c}, 'CC' => new List<String>()}
                    );
                } catch (Exception e) {
                    CSBD_Activity.crearActividad(hipoteca.Id, 'Error enviando solicitud de documentación', 'Completed', 'Error enviando solicitud de documentación', e.getMessage());
                }
            }
        }
    }

    private static List<Opportunity> descartarNoHipotecas(List<Opportunity> oportunidades) {
        //Descarta oportunidades que no sean hipotecas y oportunidades ya cerradas o rechazadas
        Id idRecordTypeHipoteca = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Opportunity', 'CSBD_Hipoteca');
        List<Opportunity> retorno = new List<Opportunity>();
        for (Opportunity oportunidad : oportunidades) {
            if (oportunidad.RecordTypeId == idRecordTypeHipoteca && !oportunidad.IsClosed) {
                retorno.add(oportunidad);
            }
        }
        return retorno;
    }

    private static Boolean enviarCorreo(Id whatId, String nombreBuzonSalida, String plantillaId, Map<String, List<String>> destinatarios) {
        Messaging.SingleEmailMessage correo = new Messaging.SingleEmailMessage();
        correo.setToAddresses(destinatarios.get('Para'));
        correo.setCcAddresses(destinatarios.get('CC'));
        correo.setTemplateId(plantillaId);
        List<Opportunity> contactoOportunidad = [SELECT CSBD_Contact__c FROM Opportunity WHERE Id =: whatId LIMIT 1];
        Id contactId;
        if (!contactoOportunidad.isEmpty() && contactoOportunidad[0].CSBD_Contact__c != null) {
            contactId = contactoOportunidad[0].CSBD_Contact__c;
        }  else {
            contactId = [SELECT Id FROM Contact WHERE Email != NULL LIMIT 1].Id;
        }
        correo.setTargetObjectId(contactId);
        correo.setTreatTargetObjectAsRecipient(false);
        correo.setWhatId(whatId);
        correo.setSaveAsActivity(true);
        correo.setOrgWideEmailAddressId([SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = :nombreBuzonSalida].Id);
        List<Messaging.SendEmailResult> resultadoEnvios = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{correo});
        return resultadoEnvios[0].isSuccess();
    }

    private static Map<String, List<String>> destinatariosOficina(Opportunity hipoteca) {
        Map<String, List<String>> retorno = new Map<String, List<String>>();

        //Destinatarios "Para"
        Decimal dNumeroOficina = hipoteca?.CSBD_Now_Num_Oficina__c;
        String sNumeroOficina = String.valueOf(dNumeroOficina.intValue()).leftPad(5, '0');
        List<Account> oficinas = [SELECT CC_Email__c FROM Account
                                    WHERE RecordType.DeveloperName = 'CC_CentroCaixaBank'
                                    AND CC_Numero_Oficina__c = :sNumeroOficina];
        if (oficinas.size() == 1) {
            retorno.put('Para', new List<String>{oficinas[0].CC_Email__c});
        } else {
            retorno.put('Para', new List<String>());
        }

        //Destinatarios "CC" (el director de la oficina + valor "EmailGestor" recibido en la solicitud)
        List<String> destinatariosCc = new List<String>();
        if (oficinas.size() == 1) {
            for (Contact director : [SELECT Email FROM Contact
                                        WHERE CC_Inactivo__c = FALSE AND (CC_Cargo__c = 'DIRECCION' OR CC_Cargo__c = 'DIRECCIÓN' OR CC_Cargo__c = 'GERENCIA COORD. EQUIPO')
                                        AND AccountId = :oficinas[0].Id]) {
                destinatariosCc.add(director.Email);
            }
        }
        if (String.isNotBlank(hipoteca?.CSBD_Now_EmailGestor__c)) {
            destinatariosCc.add(hipoteca?.CSBD_Now_EmailGestor__c);
        }
        retorno.put('CC', destinatariosCc);

        return retorno;
    }

    private static String idiomaOficina(Opportunity hipoteca) {
        Decimal dNumeroOficina = hipoteca?.CSBD_Now_Num_Oficina__c;
        String sNumeroOficina = String.valueOf(dNumeroOficina.intValue()).leftPad(5, '0');
        List<Account> oficinas = [SELECT CC_Idioma_Oficina__c FROM Account
                                    WHERE RecordType.DeveloperName = 'CC_CentroCaixaBank'
                                    AND CC_Numero_Oficina__c = :sNumeroOficina];
        if (oficinas.size() == 1) {
            return oficinas[0].CC_Idioma_Oficina__c == '001' ? 'Catalán' : 'Castellano';
        } else {
            return 'Castellano';
        }
    }

    private static Map<String, List<String>> destinatariosCliente(Opportunity hipoteca) {
        return new Map<String, List<String>>{
            'Para' => new List<String>{hipoteca.CSBD_Email_Solicitud__c},
            'CC' => new List<String>()
        };
    }

    public static void informarCampoPrioridad(List<Opportunity> oportunidades, Map<Id, Contact> titulares) {
        if (titulares == null) {
            titulares = new Map<Id, Contact>([SELECT CSBD_Profesion__c, CSBD_ClienteCaixabank__c
                                                FROM Contact WHERE RecordType.DeveloperName = 'CSBD_TitularHipoteca'
												AND Id IN :CC_MetodosUtiles.listaCampo(oportunidades, 'CSBD_ContactoTitular1__c')]);
        }

        Id idRecordTypeHipoteca = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CSBD_Hipoteca').getRecordTypeId();
        for (Opportunity oportunidad : oportunidades) {
            Contact titular = titulares.get(oportunidad.CSBD_ContactoTitular1__c);
            if (oportunidad.RecordTypeId == idRecordTypeHipoteca) {
                Integer prioridad = 0;

                if (oportunidad.CSBD_Datos_Calculo_DTI__c != null) {
                    CSBD_DatosEntrevistaHipoteca datosEntrevista = new CSBD_DatosEntrevistaHipoteca(oportunidad);

                    Decimal total = 0;
                    if(datosEntrevista.primerTitular != null ){
                        total += datosEntrevista.primerTitular?.totalIngresosNomina + ((datosEntrevista.primerTitular.IngresosNetosIrpf?.neto ?? 0) / 12);
                    }

                    if(datosEntrevista.segundoTitular != null){
                        total += datosEntrevista.segundoTitular?.totalIngresosNomina + ((datosEntrevista.segundoTitular.IngresosNetosIrpf?.neto ?? 0) / 12);
                    }

                    if (total >= 6000) {
                        prioridad += 3;
                    } else if (total >= 4000) {
                        prioridad += 2;
                    } else if (total >= 2500) {
                        prioridad += 1;
                    }

                    Map<String, Decimal> indicadoresViabilidad = datosEntrevista.getIndicadoresViabilidad();
                    if (indicadoresViabilidad.get('ltv') > 0 && indicadoresViabilidad.get('ltv') <= 50) {
                        prioridad++;
                    }

                    if ((indicadoresViabilidad.get('dti nómina') > 0 && indicadoresViabilidad.get('dti nómina') <= 20) || (indicadoresViabilidad.get('dti irpf') > 0 && indicadoresViabilidad.get('dti irpf') <= 20)) {
                        prioridad++;
                    }
                }

                List<Boolean> criterios = new List<Boolean>{
                    oportunidad.CSBD_Tasacion__c > 0,
                    oportunidad.CSBD_Urgencia__c == 'Si',
                    oportunidad.CSBD_UsoVivienda2__c != null,
                    (oportunidad.Amount ?? 0) > 0,
                    oportunidad.CSBD_AportacionInicial__c > 0,
                    oportunidad.CSBD_TipoOperacion2__c != null
                };
                if (titular != null) {
                    criterios.add(String.isNotBlank(titular.CSBD_Profesion__c));
                    criterios.add(titular.CSBD_ClienteCaixabank__c);
                }
                for (Boolean criterio : criterios) {
                    prioridad += (criterio ?? false) ? 1 : 0;
                }
                oportunidad.CSBD_OC_Prioridad__c = prioridad.toString();
            }
        }
    }
}