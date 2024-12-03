public class CC_SLA_Utils {    
    public static datetime calculo_Fecha_Activo(String Canal){    
        Datetime fecha;
        if (Canal=='Accionista') {
            fecha=calculo_Fecha_Activo_Accionistas(System.now());
        }
        return fecha;
    }
    
        
    public static datetime calculo_Fecha_Activo_Accionistas(datetime fechahora){                    
        datetime resultado;
        
        if (fechahora!=null) {
            try{
        		date fecha = Date.valueOf(fechahora);
        		Decimal  dia = calculo_Dia_Semana(fecha);
                Decimal hora = Decimal.valueOf(fechahora.hour());
                Map<Decimal,Decimal> ini = new Map<Decimal,Decimal>();
                Map<Decimal,Decimal> fin = new Map<Decimal,Decimal>();
                
                Map<date,Decimal> ini_add = new Map<date,Decimal>();
                Map<date,Decimal> fin_add = new Map<date,Decimal>();
                
                for (CC_Horario_Accionistas__mdt item : [SELECT Fecha__c, Dia_semama__c, Inicio__c, Fin__c FROM CC_Horario_Accionistas__mdt]){
                    if ((item.Dia_semama__c=='') || (item.Dia_semama__c==null)) {
                        ini_add.put(item.Fecha__c,item.Inicio__c);
                        fin_add.put(item.Fecha__c,item.Fin__c);
                    } else {
                        ini.put(Decimal.ValueOf(item.Dia_semama__c),item.Inicio__c);
                        fin.put(Decimal.ValueOf(item.Dia_semama__c),item.Fin__c);                
                    }
                }
        
                //Búsqueda por Horario
                if (((hora>=ini.get(dia)) && (hora<fin.get(dia))) ||
                    ((hora>=ini_add.get(fecha)) && (hora<fin_add.get(fecha)))
                   ){
                    resultado=fechahora;
                } else
                {
                    //Búsqueda de siguiente laborable
                    if (ini_add.get(fecha.addDays(1))!=null){
                        //Días específicos
                        resultado=DateTime.newInstance((fecha.addDays(1)).year(), (fecha.addDays(1)).month(), (fecha.addDays(1)).day(), (ini_add.get(fecha.addDays(1))).intValue(), 0, 0);                                    
                    }else {
                        //Días de la semana
                        if (dia<5) {
                           resultado=DateTime.newInstance((fecha.addDays(1)).year(), (fecha.addDays(1)).month(), (fecha.addDays(1)).day(), (ini.get(calculo_Dia_Semana(fecha.addDays(1)))).intValue(), 0, 0);                    
                        } else if (dia==5){
                           resultado=DateTime.newInstance((fecha.addDays(3)).year(), (fecha.addDays(3)).month(), (fecha.addDays(3)).day(), (ini.get(calculo_Dia_Semana(fecha.addDays(3)))).intValue(), 0, 0);           
                       } else if (dia==6){
                           resultado=DateTime.newInstance((fecha.addDays(2)).year(), (fecha.addDays(2)).month(), (fecha.addDays(2)).day(), (ini.get(calculo_Dia_Semana(fecha.addDays(2)))).intValue(), 0, 0);           
                       }            
                    }
                }
            } catch(DmlException e) {
                //Ante cualquier error, devolvemos null, para evitar la cancelación del proceso y perder el mail
            }
        }
        return resultado;
    }
    
    public static Decimal calculo_Dia_Semana(date Fecha){      
        date refDate = date.newInstance(1990, 1, 7);
        Decimal dia = Math.mod(refDate.daysBetween(Fecha),7);
         
        return dia;        
    }    
}