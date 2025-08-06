/*****************************************************************
 * Name: SAC_FinalizarProcesoCopia
 * Copyright © 2022  CaixaBank
 * 
 * Proposito: Finaliza el proceso de copias masivas limpiando el campo en el que se guardan
 * los ids de los jobs en curso del caso original y mandando un email con el resultado del proceso.
 * Implementa Queueable
 * Clases test: SAC_LCMP_CopiaMasivaCasos_Test
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US308696         Carlos Solis   14/03/2022   Creación
 * 1.1            US723742         Raúl Santos    05/03/2024   Modificación: añadir lógica envio emails blackList
*****************************************************************/
public without sharing class SAC_FinalizarProcesoCopia implements Queueable {

    private static Set<String> objetos = new Set<String>{'Case','SAC_MaestroTemas__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECORDTYPERECLAMACION = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    private static final Id RECORDTYPEBLACKLIST = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_BlackListEmails').getRecordTypeId();

    List<Case> listaCasosOriginales = new List<Case>();
    Boolean error;

    public SAC_FinalizarProcesoCopia(List<Case> listaCasosOriginalesC, Boolean errorC) {
        listaCasosOriginales = listaCasosOriginalesC;
        error = errorC;
    }

    public void execute(QueueableContext context) {
        //Preparar la reclamación original para después actualizarla limpiando las ids de los Jobs de la reclamación original
        Case reclamacionOriginal = new Case();
        String numeroCaso = '';
        for (Case casoOriginal : listaCasosOriginales) {
            if (casoOriginal.RecordTypeId == RECORDTYPERECLAMACION) {
                reclamacionOriginal.Id = casoOriginal.Id;
                reclamacionOriginal.CC_Detalles_Solucion__c = null;
                numeroCaso = casoOriginal.CaseNumber;
            }
        }

        //Contar cuantos casos se han copiado
        List<AggregateResult> listaCasosCopiados = [SELECT Count (Id) casosCopiados FROM Case WHERE RecordTypeId = :RECORDTYPERECLAMACION
                                                    AND SAC_CasoRelacionado__c <> null AND SAC_CasoRelacionado__c = :reclamacionOriginal.Id];
        
        //Actualizar reclamación original
        if (String.isNotBlank(reclamacionOriginal.Id)) {
            update reclamacionOriginal;
        }

        //Recupero los emails no validos de envio (emails en la blackList)
        List<SAC_MaestroTemas__c> listEmailsNoValidos = [SELECT Name FROM SAC_MaestroTemas__c WHERE RecordTypeId =: RECORDTYPEBLACKLIST AND SAC_Activo__c = true];

        //Compruebo las direcciones de envio con las de la blackList
        List<String> listaDireccionesPara = new List<String>{ UserInfo.getUserEmail() };
        List<String> emailsValidos = SAC_Utils.comprobarEmailsBlackListAuto(listEmailsNoValidos, listaDireccionesPara);

        //Si existen direcciones válidas, continuo el proceso
        if(!emailsValidos.isEmpty()){
            //Mandar email con los casos copiados con éxito. Si corresponde a error mandará un mensaje, si no, mandará otro
            if (error) {
                SAC_LCMP_GestionEmails.enviarEmail(reclamacionOriginal.Id, emailsValidos[0], '', '', 'Las copias lanzadas desde la reclamación ' + numeroCaso + ' no han podido ser generadas. Por favor, reintente el proceso. ' + 'Han conseguido generarse con éxito ' + listaCasosCopiados[0].get('casosCopiados') + ' número de copias en total.', 'Finalización copia reclamación ' + numeroCaso + ' no realizada.', '', '');
            } else {
                SAC_LCMP_GestionEmails.enviarEmail(reclamacionOriginal.Id,
                                            emailsValidos[0], 
                                            '', '',
                                            'Se han generado con éxito las copias desde la reclamación ' + numeroCaso + '. '
                                            + 'Total de copias existentes: ' + listaCasosCopiados[0].get('casosCopiados') + '. ',
                                            'Finalización copia reclamación ' + numeroCaso + ' realizada con éxito.',
                                            '',
                                            '');
            }
        }   
    }  
}