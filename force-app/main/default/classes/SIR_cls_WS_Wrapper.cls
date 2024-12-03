public class SIR_cls_WS_Wrapper {


    //WRAP ERROR
    public class ErrorResponseDto{
        public String codigoSoft;
        public String codigoOracle;
        public String descripcionError;

    }

    @TestVisible
    private static String formatNumber(Integer input){
        return input<10 ? '0' + String.valueOf(input) : String.valueOf(input);
    }

    public static String formatDate (Datetime dt){
        
       // if(dt.hour() != 0 && dt.minute() != 0 && dt.second() != 0 && dt.millisecond() != 0){
         //   String hora = formatNumber(dt.hour());
         //   String minuto = formatNumber(dt.minute());
         //   String segundo = formatNumber(dt.second());
        //    return dt.day() + '/' + dt.month() + '/' + dt.year() + ' ' + hora + ':' + minuto + ':' + segundo;
      //  }
       // else {
            return dt.day() + '/' + dt.month() + '/' + dt.year();
      //  }
        
    }

        public static String formatDateGMT (Datetime dt){        
            return dt.formatGMT('dd/MM/YYYY');
        }
  
   
    // Transforma la fecha recibida en WS de String con formato dd/mm/yyyy a date 
    public static date formatDateSF (String fecha){        
        
        date dateSF;
        try { 
           if(!String.isEmpty(fecha)){            
              dateSF = date.newinstance(Integer.valueOf(fecha.substring(6,10)), Integer.valueOf(fecha.substring(3,5)), Integer.valueOf(fecha.substring(0,2)));             
           }
        } catch (Exception ex) {
            CBK_log.error(ex, 'Error : formatDateSF - ' + ex.getTypeName() + ': ' + ex.getMessage());            
        }
        return dateSF;
    }

    private static Map<Integer, String> mapHttpMsg = new Map<Integer,String>{300 => ' ', 
                                                                            401 => 'No autorizado',
                                                                            403 => 'Prohibido',
                                                                            404 => 'No encontrado',
                                                                            500 => 'Error en el servidor',
                                                                            503 => 'Error en el servidor'};                                                                            

    public static List<String> responseError(Integer status,ErrorResponseDto errorDto){
        List<String> lstErrorInfo = new List<String>();
        lstErrorInfo.add('KO');
        if(status > 201){
            if(status == 300){
                lstErrorInfo.add('Inténtelo más tarde.');
                lstErrorInfo.add(errorDto.descripcionError);                  
            }else{
                lstErrorInfo.add('Se ha producido un error en la sincronización, inténtelo más tarde.');
                lstErrorInfo.add(status + ' - ' + mapHttpMsg.get(status));                        
            }
        }else{
            lstErrorInfo.add('Se ha producido un error en la sincronización, contacte con el administrador.');
            lstErrorInfo.add('Error ' + errorDto.codigoSoft + ' - ' + errorDto.descripcionError);
        }

        return lstErrorInfo;

    }
}