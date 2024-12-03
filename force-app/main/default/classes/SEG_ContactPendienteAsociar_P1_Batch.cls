/**
*   @description SEG_ContactPendienteAsociar_P1_Batch  --> Paso 1: Fusión de Contactos
*/
public with sharing class SEG_ContactPendienteAsociar_P1_Batch implements Database.Batchable<string> {
    
    public SEG_ContactPendienteAsociar_P1_Batch() {
        CBK_Log.debug('Contructor - SEG_ContactPendienteAsociar_P1_Batch',logginglevel.INFO);
    }

    /**
     *  @description start
     *  @param bc -> Objeto contexto
     *  @return Database.QueryLocator
     */
    public Iterable<String> start(Database.BatchableContext bc)
    {
        CBK_Log.debug('Start - SEG_ContactPendienteAsociar_P1_Batch',logginglevel.INFO);

        list<string> ini = new list<string>();
        list<string> ini2 = new list<string>();

        for (contact con :[SELECT Email 
                            FROM Contact 
                            WHERE CreatedDate = LAST_N_DAYS:7
                            and Account.Name ='CUENTA PENDIENTE ASOCIAR' 
                            and Account.RecordType.DeveloperName ='CC_ClienteSEG' 
                            and Email != null]){
            ini.add(con.Email);
        }

        List<String> subLista = new list<string>();

        for (Integer i = 0; i < ini.size(); i += 1) {
            subLista.add(ini[i]);
            if (math.mod(i,500) == 0) {
                ini2.addAll(procesaLote(subLista));
                subLista.clear();
            }
        }
        ini2.addAll(procesaLote(subLista));
        //Eliminación de duplicados
        Set<String> setEmails = new Set<String>(ini2);
        list<string> lstEmails = new list<string>();
        lstEmails.addAll(setEmails);
        CBK_Log.debug(ini.size()+'',logginglevel.INFO);
        CBK_Log.debug(lstEmails.size()+'',logginglevel.INFO);
        return lstEmails;
    }

    /**
     *  @description execute
     *  @param bc -> Objeto contexto
     *  @param scope -> Scope del batch
     */
    public void execute(Database.BatchableContext bc, List<String> scope)
    {
        CBK_Log.debug('scope:' + scope.size()+'',logginglevel.INFO);
        if (scope.isEmpty())  {
            // No hay registros, salir.
            return;
        }

        map<string,contact> mapPrincipal = new map<string,contact> ();
        map<string,contact> mapSecundario = new map<string,contact> ();
        for (Contact c : [Select Id,email from Contact 
                                    where email in :scope 
                                      and Account.Name!='CUENTA PENDIENTE ASOCIAR' 
                                      and RecordType.DeveloperName='CC_Cliente' 
                                      and AccountId !=null ]){
            mapPrincipal.put(c.email,c);
        }

        for (Contact c : [Select Id,email from Contact 
                                         where email in :scope 
                                           and Account.Name='CUENTA PENDIENTE ASOCIAR']){
            mapSecundario.put(c.email,c);
        }

        Contact cPrincipal;
        Contact cSecundario;


        for (string email : scope){
            if (mapPrincipal.containsKey(email) && mapSecundario.containsKey(email)){
                cPrincipal = mapPrincipal.get(email);
                cSecundario = mapSecundario.get(email);
                fusion(cPrincipal,cSecundario);    
            }
        }
    }

    /**
     *  @description Proceso final del batch.
     *  @param bc -> Objeto contexto
     */
    public void finish(Database.BatchableContext bc)
    {
        CBK_Log.debug('Finalización - SEG_ContactPendienteAsociar_P1_Batch',logginglevel.INFO);
    }

    private List<String>  procesaLote(List<String> subLista) {  
        list<string> result = new list<string> ();
        for (contact con :[SELECT Email 
                            FROM contact 
                            WHERE Account.Name !='CUENTA PENDIENTE ASOCIAR'
                            and RecordType.DeveloperName like 'CC_Cliente%' 
                            and AccountId !=null 
                            and Email IN :subLista ]){
            result.add(con.Email);
        }
        return result;
    }

    private void fusion(contact cPrincipal,contact cSecundario) {  
        merge cPrincipal cSecundario;    
    }


}