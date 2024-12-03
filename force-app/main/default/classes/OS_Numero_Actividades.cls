@SuppressWarnings('PMD.AvoidSoqlInLoops') //Es necesario hacer el SELECT Count() dentro del for
public with sharing class OS_Numero_Actividades {
    
    @InvocableMethod
    public static void sumarTask(List<Id> idCasos) {
        try{
            //Al crear una nueva actividad el PB OS_Task invoca este método con el WhatId como entrada
            List<Case> casos = [SELECT Status FROM Case WHERE Id IN :idCasos];
            List<Case> casosCerrados = new List<Case>();

            for (Case caso : casos) {
                //Si el caso está cerrado se marca el flag Admin que inhabilita
                //la validation rule que impide modificar casos cerrados
                if (caso.Status == 'Cerrado') {
                    casosCerrados.add(caso);
                    caso.CC_Admin__c = true;
                }
                
                //Se refresca el campo OS_Numero_Actividades__c del caso el volumen actual de actividades
                caso.OS_Numero_Actividades__c = [SELECT Count() FROM Task WHERE WhatId = :caso.Id];
            }
            update casos;

            //Se deshace la marca Admin
            for (Case caso : casosCerrados) {
                caso.CC_Admin__c = false;
            }

            try{
                update casosCerrados;
            }catch(Exception e){CBK_log.error(e);
            }

        }catch(Exception e){CBK_log.error(e);
        }     
    }
}