/*****************************************************************
 * Name: SAC_QueueableInsertarAdjuntos
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Updatea los casos a los que se les ha insertado una alerta y les añade un punto al contador
 * La clase test que cubre esta clase es: SAC_Alerta_AI_TRHan_Test
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0                                            02/09/2022   Creación
*****************************************************************/
public without sharing class SAC_QueueableContadorAlertas implements Queueable{

    List<Case> listaReclamaciones;

    public SAC_QueueableContadorAlertas(List<Case> listaReclamacionesC) {
        listaReclamaciones = listaReclamacionesC;
    }

    public void execute(QueueableContext context) {
        for (Case reclamacion : listaReclamaciones) {
            if(reclamacion.SAC_AlertasPtes__c == null) {
                reclamacion.SAC_AlertasPtes__c= 1;
            }else{
                reclamacion.SAC_AlertasPtes__c++;
            }
        }

        update listaReclamaciones;
    }
}