/**************************************************************************************************
 * Name:  SAC_CaseComprobarAdjuntos
 * Copyright © 2021  
 * CaixaBank
 *
 * Proposito:         
 *          Comprobar que si actualiza la Reclamación no se pueda marcar
 *          el campo ficheros adjuntos si no tiene documentos adjuntos                                                
 * 
 * Historial
 * VERSION        USER_STORY            AUTHOR                DATE                   Description
 * 1.0             US213187          Marcela Neira         05/05/2021                Creación
 * ************************************************************************************************/
public without sharing class SAC_CaseComprobarAdjuntos {

    public class My1Exception  extends Exception {}

    public static void comprobar(List<Case> listaReclamacionesNueva){

    /****************************************************************************
     *  Caso A  sin tick y sin adjuntos             Aquí no tengo que decir nada
     *  Caso B  sin tick pero con adjuntos          Aquí no tengo que decir nada
     *  Caso C  con tick pero sin adjuntos          ERROR!!!!!!!!
     *  Caso D  con tick y con adjuntos             Aquí no tengo que decir nada
     *****************************************************************************/        

    //Consultamos todos los Id de los Casos que SI tengan Documentos Adjuntos  
        
    List<ContentDocumentLink> contenidos =[SELECT LinkedEntityId   
                                    FROM ContentDocumentLink 
                                    WHERE LinkedEntityId in 
                                            ( SELECT Id FROM Case WHERE id in: listaReclamacionesNueva)];

  //  List<Attachment> adjuntos = [SELECT id, name, ParentId FROM Attachment WHERE ParentId IN (SELECT id FROM EmailMessage WHERE ParentId in: listaReclamacionesNueva) ] ;                                       

    List<EmailMessage> adjuntos = [SELECT ParentId FROM EmailMessage WHERE ParentId in: listaReclamacionesNueva AND HasAttachment = true];

    for(Case caso: listaReclamacionesNueva){
        Boolean mostrarError = true;

        if (!contenidos.isEmpty() || !adjuntos.isEmpty()) {
            for(ContentDocumentLink contenido: contenidos){
                if(contenido.LinkedEntityId == caso.id){
                    mostrarError = false;
                }
            }
            if(mostrarError){
                for(EmailMessage adjunto: adjuntos){
                    if(adjunto.parentId == caso.id){mostrarError = false;
                    }

                }    
            }
        }

        if(caso.CC_SuppliedFiles__c && mostrarError){
            caso.CC_SuppliedFiles__c.addError('No puede editar este campo si el caso no tiene ficheros adjuntos');
        }
    }
}

      
}