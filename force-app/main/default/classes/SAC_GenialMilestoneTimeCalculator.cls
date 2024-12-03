/*****************************************************************
 * Name: SAC_GenialMilestoneTimeCalculator
 * Copyright © 2021  CaixaBank
 * 
 * @description: Controlar el tiempo de vida del milestone para la SLA Regulatorio para el proyecto Genial
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR            DATE         Description
 * 1.0            US967476         Borja Lavesiera   12/08/24     Creación
*****************************************************************/
public with sharing class SAC_GenialMilestoneTimeCalculator {

    

    /*****************************************************************
     * @description: En este método se calcula el tiempo del milestone para la SLA Regulatorio del caso
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR            DATE         Description
     * 1.0            US967476         Borja Lavesiera   12/08/24     Creación
     *****************************************************************/
    public static DateTime calculateMilestoneTriggerTime(Case caso) {
        // Obtener record Type
        Set<String> objetos = new Set<String>{'Case'};
        Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
        Id recTypeReclamacion = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
        Id recTypePretension = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();

        Integer retornarDias = 30;
        Integer masDiaHabil = 0;
        Integer diasProrroga = 0;
        Datetime fechaFin = null;
        Datetime fechaInicial; 
        Id ideBH;

        if (Schema.sObjectType.Case.isAccessible()) {

            retornarDias = calcularDiasARetornar(caso, recTypeReclamacion, recTypePretension);

            if (Cache.Org.contains('local.SAC.SACCalendario')) {
                String calend = (String)Cache.Org.get('local.SAC.SACCalendario');
                ideBH = Id.valueOf(calend);
            }
            else{
                ideBH = [SELECT Id, name FROM BusinessHours where name ='SAC_Calendario'].id;
                Cache.Org.put('local.SAC.SACCalendario', String.valueOf(ideBH),300);
            }

            /*Calculo de 1 mes:
            Se empieza a contar desde el siguiente día hábil a la fecha de recepción y será el mismo día del mes siguiente (ejemplo: 26/10-->26/11)
            En caso que el mes en curso tengas más días que mes siguiente (enero, marzo, mayo, agosto, octubre) la fecha fin será el último día del mes siguiente, si es hábil, y si no será el siguiente. (Por ejemplo: 29/01→28/02; 31/03-->30/04)
            Fecha inicio cálculo de SLA Regulatorio: Será el día siguiente hábil a la fecha de recepción. Ejemplo: Fecha recepción: 29/10/21→ Fecha inicio calculo:02/11/21
            Fecha fin SLA Regulatorio: Será el primer día hábil según el cálculo anterior. En caso que caiga en festivo o fin de semana pasará al siguiente día hábil
            Día hábil: Será cualquier día que no sea fin de semana o festivo nacional
            En caso del cálculo de 2 meses (no consumidores en el picklist SAC_TipoConsumidor__c) se aplicará las mismas reglas anteriores pero con dos meses
            */
            
            if(retornarDias == 30){ 
                //US347830 Según el campo consumidor la SLA tendrá diferentes tiempos:  Persona física consumidor: SLA Regulatorio (1 mes) Persona física no consumidor (autónomo): 2 meses desde la fecha inicio cálculo
                
                masDiaHabil = 1;
                Integer mesesAnadir = calcularMesesAnadir(caso); 
                fechaInicial = calcularFechaInicial(caso);

                //Para empezar a contar desde el siguiente día hábil a la fecha de recepción debemos comprobar que es día hábil 
                fechaInicial = fechaInicial.addDays(1);
                while(!BusinessHours.isWithin(ideBH, fechaInicial)) {  //Es día hábil? 
                    fechaInicial = fechaInicial.addDays(1); 
                }
                
                //Calculamos la fecha final del SLA regulatorio
                fechaFin = fechaInicial.addMonths(mesesAnadir);
                Boolean esDiaHabil = BusinessHours.isWithin(ideBH, fechaFin);

                if(!esDiaHabil){//Si no entra en horario de BH necesitamos calcular el siguiente día hábil                    
                    fechaFin = BusinessHours.nextStartDate(ideBH, fechaFin); 
                } 
                 
                //Calcula la diferencia que hay de la fecha incial y la fecha fin con la condiciones antes mencionadas
                Long diferencia = BusinessHours.diff(ideBH, fechaInicial, fechaFin); 

                //Calcular el número de días dados los milisegundos que se han calculado anteriormente
                Double numeroDias = ((Double) diferencia)/(1440*60*1000);
                //numeroDias = numeroDias.round();
                Decimal numeroDias2 = (Decimal)numeroDias;
                Decimal numeroDias3 = numeroDias2 - (numeroDias2.round(System.RoundingMode.DOWN));

                if (numeroDias3>0) { //Para hacer el calculo de añadir días enteros
                    numeroDias++; 
                } 
                retornarDias = numeroDias.intValue();

                fechaFin = BusinessHours.add(ideBH, fechaInicial, calcularMilisegundos(retornarDias)); 
                
            }else{ 
                fechaInicial = calcularFechaInicial(caso); 
                fechaFin = BusinessHours.add(ideBH, fechaInicial, calcularMilisegundos(retornarDias));
            }
        }
       
        /** Se vuelven a cambiar las BBHH de 10 a 24 horas (Antes se tenia una horario de 8:00 - 18:00)*/
        Integer tiempoTotal = (retornarDias + masDiaHabil + diasProrroga) * 1440; //se hacia la mulplicación por 1440 cuando eran días de 24 horas 
        
        //el ultimo + masDiaHabil es para que agregue el día hábil ya que los Milestones hacen los calculos desde la fecha de recepcion será uno cuando
        //tenga que calcular el mes pero será 0 cuando encuentre las parametrizaciones de junta de andalucia, castilla la mancha y PSD2 sin prorrogar
        //tiempoTotal = (retornarDias + tiempoProrroga) * 600; // ahora con las Business Hour los días son de 10 horas es decir 600 minutos
        system.debug('@@tiempoTotal'+tiempoTotal);
        system.debug('@@fechaFin'+fechaFin);
        system.debug('@@caso.SAC_FechaVencimientoSLA__c'+caso.SAC_FechaVencimientoSLA__c);
        if(caso.SAC_FechaVencimientoSLA__c != fechaFin){
            return fechaFin;
        }
        return null;      
    }

    /********************************************************************************************
     * Método: calcularMesesAnadir
     * 
     * US347830 Según el campo consumidor la SLA tendrá diferentes tiempos:
     * Persona física consumidor: SLA Regulatorio (1 mes)
     * Persona física no consumidor (autónomo): 2 meses desde la fecha inicio cálculo
     * 
     ********************************************************************************************/
    public static Integer calcularMesesAnadir(Case caso) {

        Integer mesesAnadir = 0;

        if(caso.SAC_TipoConsumidor__c == 'Si' || caso.SAC_Reclamacion__r.SAC_TipoConsumidor__c =='Si' || caso.SAC_Prorrogado__c){
            mesesAnadir = 1;
        }else if(caso.SAC_TipoConsumidor__c == 'No' || caso.SAC_Reclamacion__r.SAC_TipoConsumidor__c =='No'){
            mesesAnadir = 2;
        }else if(String.isBlank(caso.SAC_TipoConsumidor__c) || String.isBlank(caso.SAC_Reclamacion__r.SAC_TipoConsumidor__c)){
            mesesAnadir = 2;
        }
        return mesesAnadir;
    }


    /********************************************************************************************
     * Método: calcularDiasARetornar
     * 
     * DE64525 MOD MNR 30/08/2022 La prórroga es de 1 mes y no 30 días hábiles, así que se retorna un 30 para que se calcule 
     * con las reglas del mes, que estan especificadas abajo.
     * 
     ********************************************************************************************/
    public static Integer calcularDiasARetornar(Case caso, Id recTypeReclamacion, Id recTypePretension) {

        Integer retornarDias = 30;

        if (caso != null && (caso.RecordTypeId == recTypeReclamacion || caso.RecordTypeId == recTypePretension)) {
            if(caso.SAC_TiempoSLARegulatorio__c != null ){
                retornarDias = Integer.valueOf(caso.SAC_TiempoSLARegulatorio__c);
            }               
        }
        return retornarDias;
    }

    /**********************************************************************************************
     * 
    * Rellenamos una fecha inicial porque cuando se hace una copia de una reclamación vinculada se ha 
    * pedido que la SAC_FechaRecepcion__c esté en blanco
    *
    *
    ***********************************************************************************************/

    public static Datetime calcularFechaInicial(Case caso) {
        
        Datetime fechaInicial; 
        if(caso.SAC_FechaRecepcion__c == null){
            fechaInicial = System.now();
        }else{
            fechaInicial = caso.SAC_FechaRecepcion__c;
        }
        return fechaInicial;
    }

    public static Long calcularMilisegundos(Integer dias) {
 
        //Por errores del campo long, la multiplicación por 1000 se pasa a concatenar el resultado más tres ceros en forma de String
        Integer resultado; 

        resultado = dias*24*60*60;
        //resultado = (dias*24*60*60*1000); Esta multiplicación es la que hace que el Long aparezca como valor negativo (es un error?)
        //Por eso se hace con un String y se devuelve con un Long.valueOf()
        String num = resultado + '000';
 
        return Long.valueOf(num);
    }
}