public without sharing class SAC_LCMP_RedaccionPretension{
    /*****************************************************************
     * Name: SAC_LCMP_RedaccionPretension
     * Copyright © 2021  CaixaBank
     * ************************************************************
     * Proposito: Controlador  para poder gestionar la redacción parcial de una pretension
     *   LWC asociado: sac_RedaccionTextoPretension
     * ************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US248481         Luis Mesa     9/07/21       Creación Clase
     *****************************************************************/
    public class MyException extends Exception{
    }

    @AuraEnabled(cacheable = true)
    public static List<plantillasWrapper> getTitulos(String idCaso, String sentido){
        /*****************************************************************
         * Proposito: Método para obtener los titulos de las plantillas que se encuentran en carpetas definidas
         * ************************************************************
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0            US248481         Luis Mesa     9/07/21       Creación Método
         * 1.1            US300439       Marcela Neira   30/11/21      Modificación No hay MCC para las plantilla solo recuperar las plantillas
         *                                                             indistintamente del MCC y del idioma, ahora solo depende si es Redacción o inadmisión
         *****************************************************************/
        if (!Schema.sObjectType.Case.isAccessible() || !Schema.sObjectType.CC_MCC__c.isAccessible() || !Schema.sObjectType.SAC_PlantillaRedaccion__c.isAccessible()){
            throw new AuraHandledException('No tienes privilegios para manipular la redacción.');
        }

        Case casoActual = [SELECT Id, SEG_Detalle__c, CaseNumber, SAC_SentidoResolucion__c, CC_Idioma__c, status
                           FROM Case
                           WHERE Id = :idCaso];
        List<plantillasWrapper> listaWrapper = new List<plantillasWrapper>();
        CC_MCC__c mcc = new CC_MCC__c();
        List<SAC_PlantillaRedaccion__c> templatesInadmision = new List<SAC_PlantillaRedaccion__c>();
        List<SAC_PlantillaRedaccion__c> templatesRedaccion = new List<SAC_PlantillaRedaccion__c>();
        if (sentido == null){

            sentido = casoActual.SAC_SentidoResolucion__c;

        }
        if (sentido == 'SAC_004'){
            templatesInadmision = [SELECT Id, Name, SAC_MCC__c, SAC_PlantillaCastellano__c, SAC_PlantillaCastellanoId__c, SAC_PlantillaCatalan__c, SAC_PlantillaCatalanId__c, SAC_PlantillaIngles__c, SAC_PlantillaInglesId__c
                                   FROM SAC_PlantillaRedaccion__c
                                   WHERE  /*SAC_MCC__c =: mcc.Id AND */SAC_TipoPlantilla__c = 'SAC_Inadmision'];

        } else{

            if (String.isNotBlank(casoActual.SEG_Detalle__c)){
                mcc = [SELECT Id, Name
                       FROM CC_MCC__c
                       WHERE Id = :casoActual.SEG_Detalle__c
                       LIMIT 1];
            }
            //query por mcc y nombre a obj custom -> name id-template de idioma que interesa
            if (String.isNotBlank(mcc.Id)){
                templatesRedaccion = [SELECT Id, Name, SAC_MCC__c, SAC_PlantillaCastellano__c, SAC_PlantillaCastellanoId__c, SAC_PlantillaCatalan__c, SAC_PlantillaCatalanId__c, SAC_PlantillaIngles__c, SAC_PlantillaInglesId__c
                                      FROM SAC_PlantillaRedaccion__c
                                      WHERE SAC_MCC__c = :mcc.Id AND SAC_TipoPlantilla__c = 'SAC_Redaccion'];
            }
        }

        if (!templatesRedaccion.isEmpty()){
            for (SAC_PlantillaRedaccion__c et : templatesRedaccion){
                switch  on casoActual.CC_Idioma__c{
                    when 'es'{
                        plantillasWrapper objWrapper = new plantillasWrapper(et.SAC_PlantillaCastellanoId__c, et.SAC_PlantillaCastellano__c);
                        listaWrapper.add(objWrapper);
                    }
                    when 'ca'{
                        plantillasWrapper objWrapper = new plantillasWrapper(et.SAC_PlantillaCatalanId__c, et.SAC_PlantillaCatalan__c);
                        listaWrapper.add(objWrapper);
                    }
                    when 'en'{
                        plantillasWrapper objWrapper = new plantillasWrapper(et.SAC_PlantillaInglesId__c, et.SAC_PlantillaIngles__c);
                        listaWrapper.add(objWrapper);
                    }
                }
            }
            return listaWrapper;
        } else if (!templatesInadmision.isEmpty()){
            for (SAC_PlantillaRedaccion__c et : templatesInadmision){
                if (String.isNotBlank(et.SAC_PlantillaCastellanoId__c)){
                    listaWrapper.add(new plantillasWrapper(et.SAC_PlantillaCastellanoId__c, et.SAC_PlantillaCastellano__c));
                }
                if (String.isNotBlank(et.SAC_PlantillaCatalanId__c)){
                    listaWrapper.add(new plantillasWrapper(et.SAC_PlantillaCatalanId__c, et.SAC_PlantillaCatalan__c));
                }
                if (String.isNotBlank(et.SAC_PlantillaInglesId__c)){
                    listaWrapper.add(new plantillasWrapper(et.SAC_PlantillaInglesId__c, et.SAC_PlantillaIngles__c));
                }
            }
            return listaWrapper;
        } else{
            //throw new AuraHandledException('No hay plantillas definidas para la pretensión.');
            return listaWrapper;
        }
    }

    @AuraEnabled(cacheable = true)
    public static string getBody(String idTitulo, String idCase){
        /*****************************************************************
         * Proposito: Método para obtener el body o contenido de la plantilla seleccionada por el user
         * ************************************************************
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0            US248481         Luis Mesa     12/07/21      Creación Método
         *****************************************************************/
        try{
            List<String> body = new List<String>();
            Case registro = [SELECT Id, CaseNumber, CC_Idioma__c
                             FROM Case
                             WHERE Id = :idCase
                             LIMIT 1];
            EmailTemplate resultado = [SELECT Id, Name, HtmlValue
                                       FROM EmailTemplate
                                       WHERE Id = :idTitulo
                                       LIMIT 1];
            body.add(resultado.HtmlValue);
            String whoId = UserInfo.getUserId();
            String whatId = registro.Id;
            String stringFinal = '';
            List<Messaging.RenderEmailTemplateBodyResult> resList = Messaging.renderEmailTemplate(whoId, whatId, body);

            if (!resList.isEmpty()){
                stringFinal = resList[0].getMergedBody();
            }
            return stringFinal;

        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void insertRedaccion(String campo, String argumentoRes, String id, String valorSentido, String valorMotivo, Boolean listoRedaccion){
        /*****************************************************************
         * Proposito: Método para insertar en la BBDD el campo de redaccion para el objeto case
         * ************************************************************
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0            US248481         Luis Mesa     12/07/21      Creación Método
         * 1.1            US380087       Marcela Neira   18/05/22      Mejora en el comportamiento GGH si algún importe reclamado está informado antes de hacer la redacción
         *                                                             su gemelo (importe resuelto) deberia estar informado tambien
         * 1.2            US609171         CS            21/06/23      Se ha quitado la creación automática de la tarea de facturas especiales
         *****************************************************************/

        if (!Schema.sObjectType.Case.isAccessible() || !Schema.sObjectType.Case.isUpdateable()){
            throw new AuraHandledException('No tienes privilegios para manipular la redacción.');
        }

        Case caso = [SELECT Id, Status, SAC_Redaccion__c, SAC_SentidoResolucion__c, SAC_RedaccionFinal__c, SEG_Detalle__r.SAC_esGGH__c, SAC_Importe_Resuelto__c, SAC_Reclamacion__c, SAC_ImpResueltoNotaria__c, SAC_ImpReclamadoNotaria__c, SAC_ImpResueltoGestoria__c, SAC_ImpReclamadoGestoria__c, SAC_ImpResueltoRegistros__c, SAC_ImpReclamadoRegistros__c, SAC_ImpResueltoTasacion__c, SAC_ImpReclamadoTasacion__c, SAC_ImpReclamadoInteresesLegales__c, SAC_ImpResueltoInteresesLegales__c, SAC_MotivoSentidoResolucion__c, SAC_MotivoInadmision__c
                     FROM Case
                     WHERE Id = :Id
                     LIMIT 1];
        list<Case> pretensiones = [SELECT Id, SAC_MotivoSentidoResolucion__c, CaseNumber
                     FROM Case
                     WHERE SAC_Reclamacion__c = :caso.SAC_Reclamacion__c];
        Case recl = [SELECT Id, SAC_MotivoSentidoResolucion__c FROM Case WHERE Id =: caso.SAC_Reclamacion__c LIMIT 1];

        //Creación instancia de tarea GGH por si hiciera falta insertarla despues del update del caso
        SAC_Accion__c tareaGGH = new SAC_Accion__c();
        if (listoRedaccion && caso.SEG_Detalle__r.SAC_esGGH__c){

            if (caso.SAC_ImpReclamadoNotaria__c != null && caso.SAC_ImpResueltoNotaria__c == null){throw new MyException('El importe resuelto de notaría debe estar informado.');}
            if (caso.SAC_ImpReclamadoGestoria__c != null && caso.SAC_ImpResueltoGestoria__c == null){throw new MyException('El importe resuelto de gestoría debe estar informado.');}
            if (caso.SAC_ImpReclamadoRegistros__c != null && caso.SAC_ImpResueltoRegistros__c == null){throw new MyException('El importe resuelto de registro debe estar informado.');}
            if (caso.SAC_ImpReclamadoTasacion__c != null && caso.SAC_ImpResueltoTasacion__c == null){throw new MyException('El importe resuelto de tasación debe estar informado.');}
            if (caso.SAC_ImpReclamadoInteresesLegales__c != null && caso.SAC_ImpResueltoInteresesLegales__c == null){throw new MyException('El importe intereses legales de tasación debe estar informado.');}
            try{

                list<SAC_Accion__c> tarea1 = [SELECT Id
                                              FROM SAC_Accion__c
                                              WHERE SAC_Pretension__c = :caso.id AND SAC_MaestroAccionesReclamacion__r.SAC_DeveloperName__c = 'GGH'];

                /*
                 Mod 1.2
                 list <SAC_Accion__c> tarea2 = [SELECT Id
                 FROM SAC_Accion__c
                 WHERE SAC_Pretension__c =: caso.id AND SAC_MaestroAccionesReclamacion__r.SAC_DeveloperName__c = 'FE'];
                 */


                Id recordTypeTareas = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SAC_MaestroDeTareas').getRecordTypeId();

                if (tarea1.isEmpty()){
                    /*Damos valor a la Tarea para GGH*/
                    tareaGGH.SAC_MaestroAccionesReclamacion__c = [SELECT Id, SAC_DeveloperName__c
                                                                  FROM SAC_MaestroAccionesReclamacion__c
                                                                  WHERE SAC_DeveloperName__c = 'GGH'
                                                                  LIMIT 1].Id;
                    tareaGGH.SAC_Pretension__c = caso.Id;
                    tareaGGH.SAC_Reclamacion__c = caso.SAC_Reclamacion__c;
                    tareaGGH.RecordTypeId = recordTypeTareas;
                    tareaGGH.SAC_ImpResueltoNotaria__c = caso.SAC_ImpResueltoNotaria__c;
                    tareaGGH.SAC_ImpResueltoGestoria__c = caso.SAC_ImpResueltoGestoria__c;
                    tareaGGH.SAC_ImpResueltoRegistros__c = caso.SAC_ImpResueltoRegistros__c;
                    tareaGGH.SAC_ImpResueltoTasacion__c = caso.SAC_ImpResueltoTasacion__c;
                }
                /*
                 Mod 1.2
                 if(tarea2.isEmpty()){

                 //Creamos la Tarea para Facturas Especiales
                 SAC_Accion__c tareaFE = new SAC_Accion__c();
                 tareaFE.SAC_MaestroAccionesReclamacion__c = [SELECT Id FROM SAC_MaestroAccionesReclamacion__c WHERE SAC_DeveloperName__c = 'FE' LIMIT 1].Id;
                 tareaFE.SAC_Pretension__c = caso.Id;
                 tareaFE.SAC_Reclamacion__c = caso.SAC_Reclamacion__c;
                 tareaFE.RecordTypeId = recordTypeTareas;
                 tareaFE.SAC_ImporteAbonar__c = caso.SAC_ImpReclamadoInteresesLegales__c; //Se sustituirá por el campo SAC_ImpResueltoInteresesLegales__c
                 //tareaFE.SAC_ImpResueltoInteresesLegales__c = caso.SAC_ImpReclamadoInteresesLegales__c; El campo que habrá que cambiar
                 insert tareaFE;

                 }
                 */
            } catch (Exception e){
                throw new AuraHandledException('Compruebe que existen las tareas dentro de Maestro de tareas o que el grupo de Facturas especiales existe \n' + e);
            }
        }

        // Database.update(listCases);
        caso.SAC_MotivoSentidoResolucion__c = argumentoRes;    
        caso.SAC_Redaccion__c = campo;
        caso.SAC_SentidoResolucion__c = valorSentido;
        //Mod 25/01/24 Si el sentido de resolución es inadmisión, pasar el caso a redacción.
        if (caso.SAC_SentidoResolucion__c == 'SAC_004') {
            caso.SAC_MotivoInadmision__c = valorMotivo;
            if(caso.Status != 'Cerrado' && caso.Status != 'SAC_009') {
                caso.Status = 'SAC_003';
                caso.SAC_StatusAuxiliar__c = 'SAC_003';
            }
        } else {
            if(String.isNotBlank(caso.SAC_MotivoInadmision__c)) {
                caso.SAC_MotivoInadmision__c = null;
            }
        }
        //Fin Mod
        caso.SAC_RedaccionFinal__c = listoRedaccion;
        SAC_DatabaseDML.updateDML(caso, true);

        //Insert de la tarea de GGH en caso de que se haya creado
        if (String.isNotBlank(tareaGGH.SAC_Pretension__c)) {
            SAC_DatabaseDML.insertDML(tareaGGH, true);
        }
    }


    @AuraEnabled
    public static String getRedaccion(String id){
        /*****************************************************************
         * Proposito: Método para insertar en la BBDD el campo de redaccion para el objeto case
         * ************************************************************
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0            US248481         Luis Mesa     12/07/21      Creación Método
         *****************************************************************/
        if (!Schema.sObjectType.Case.isAccessible()){
            throw new AuraHandledException('No tienes privilegios para manipular la redacción.');
        }
        Case record = [SELECT Id, SAC_Redaccion__c
                       FROM Case
                       WHERE Id = :Id
                       LIMIT 1];
        return record.SAC_Redaccion__c;
    }

    @AuraEnabled
    public static Boolean recuperarCheckRedaccionFinal(Id record){

        Case caso = [SELECT id, SAC_RedaccionFinal__c
                     FROM CASE
                     WHERE id = :record
                     LIMIT 1];

        if (caso.SAC_RedaccionFinal__c){

            return true;
        }

        return false;
    }

    @AuraEnabled
    public static String recuperarSentidoResolucion(Id record){

        Case caso = [SELECT id, SAC_SentidoResolucion__c
                     FROM CASE
                     WHERE id = :record
                     LIMIT 1];

        return caso.SAC_SentidoResolucion__c;
    }

    @AuraEnabled
    public static List<String> getPickListSentidoResolucion(Id record){
        List<String> pickListValuesList = new List<String>();
        Schema.DescribeFieldResult fieldResult = Case.SAC_SentidoResolucion__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }
        return pickListValuesList;
    }

    @AuraEnabled
    public static Boolean compruebaPropietario(String id){
        /*****************************************************************
         * Proposito: Método para comprobar si el usuario actual es el propietario. La finalidad es que si es el propietario el lwc estará abierto y se podrá usar; si no
         * Modificación 1.1: Se añade que las pretensiones que se crean en las reclamaciones cerradas se permita modificar.
         * ************************************************************
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0            US248481         Luis Mesa     13/07/21      Creación Método
         * 1.1            US1132463     Sergio Martín    22/01/25     	Modificación
         *****************************************************************/
        String user = UserInfo.getUserId();
        Boolean tienePermisoPretensionCerrada= false;      
        Case record = [SELECT Id, OwnerId, SAC_Reclamacion__r.OwnerId, Status, CBK_Case_Extension_Id__r.SAC_PretensionCreadaCerrada__c
                       FROM Case
                       WHERE Id = :id
                       LIMIT 1];

        if(record.Status == 'Cerrado' && record.CBK_Case_Extension_Id__r.SAC_PretensionCreadaCerrada__c) {
            List<GroupMember> listaMiembrosGrupo = [SELECT Id, UserOrGroupId FROM GroupMember WHERE Group.DeveloperName ='SAC_GrupoCreacionPretensionCerrada'];       

            if(!listaMiembrosGrupo.isEmpty()) {
                for (GroupMember ide : listaMiembrosGrupo) {
                    if(ide.UserOrGroupId == UserInfo.getUserId()){
                        tienePermisoPretensionCerrada = true;
                        break;
                    }                
                }
            }    
        }
        return (record.OwnerId == user || record.SAC_Reclamacion__r.OwnerId == user || tienePermisoPretensionCerrada == true) ? false : true;
    }

    public class PlantillasWrapper{
        @AuraEnabled
        public String idPlantilla{ get; set; }

        @AuraEnabled
        public String nombrePlantilla{ get; set; }

        public plantillasWrapper(String id, String nombre){
            idPlantilla = id;
            nombrePlantilla = nombre;
        }

    }

          
    @AuraEnabled(cacheable = true)
    public static String argumentarioPrete(String idCaso){
            Case caso = [SELECT Id FROM Case WHERE Id = :idCaso LIMIT 1];

            list<Case> pretensiones = [SELECT Id, SAC_MotivoSentidoResolucion__c, CaseNumber, SAC_SentidoResolucion__c
            FROM Case
            WHERE SAC_Reclamacion__c = :caso.Id];

            string result = '';
            string sentido;
        


            for(Case prete : pretensiones){
                if(prete.SAC_MotivoSentidoResolucion__c != null){
                    if (prete.SAC_SentidoResolucion__c == 'SAC_001'){
                        sentido = 'A favor de la entidad';
                    } else if (prete.SAC_SentidoResolucion__c == 'SAC_002'){
                        sentido = 'Favorable al cliente parcialmente';
                    } else if (prete.SAC_SentidoResolucion__c == 'SAC_003'){
                        sentido = 'A favor del cliente';
                    } else if (prete.SAC_SentidoResolucion__c == 'SAC_004'){
                        sentido = 'Inadmisión';
                    }
                    result += prete.CaseNumber + '  ' + sentido + ': ' + '\n' + prete.SAC_MotivoSentidoResolucion__c + '\n\n';
                }
            }

            return result;

    }




}