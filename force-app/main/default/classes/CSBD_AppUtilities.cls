/**********************************************************************************************************************
 Name:	  CSBD_AppUtilities
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de métodos útiles para la aplicación de CSBD
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION		USER_STORY	   AUTHOR		   		DATE			  Description
   	1.0			App CSBD	   Esperanza Conde 		11/02/2022		  Init version
***********************************************************************************************************************/
public with sharing class CSBD_AppUtilities {

    /**
	 * Transforma hexadecimal en number.
	 * @param texto  texto hexadecimal
     * @return String  texto en number
	 */
    public static String formatearNumperso(String texto) {
        try {
            if (String.isBlank(texto)) {
                return '';
            } else {
                Map<String, Integer> mapa = new Map<String, Integer>();
                mapa.put('0', 0);
                mapa.put('1', 1);
                mapa.put('2', 2);
                mapa.put('3', 3);
                mapa.put('4', 4);
                mapa.put('5', 5);
                mapa.put('6', 6);
                mapa.put('7', 7);
                mapa.put('8', 8);
                mapa.put('9', 9);
                mapa.put('A', 10);
                mapa.put('B', 11);
                mapa.put('C', 12);
                mapa.put('D', 13);
                mapa.put('E', 14);
                mapa.put('F', 15);
                mapa.put('a', 10);
                mapa.put('b', 11);
                mapa.put('c', 12);
                mapa.put('d', 13);
                mapa.put('e', 14);
                mapa.put('f', 15);

                Double retorno = 0;
                for (Integer i = 0; i < texto.length(); i++)  {
                    retorno += (mapa.get(texto.substring(i, i + 1)) * Math.pow(16, texto.length() - (i + 1))) ;
                }
                //El numperso retornado puede tener un número diferente de 8 caracteres. Si tiene menos caracteres, no están guardados con 0 delante
                //return String.valueOf(Integer.valueOf(retorno)).leftPad(8, '0');
                return String.valueOf(Integer.valueOf(retorno));
            }
        } catch (Exception e) {
            return null;
        }
    }

    /**
	* @description          Método que compara fechas
	* @param  fechaPeticion  Datetime de la fecha en que se registro la petición
	* @param  today         Datetime de la fecha justo ahora
	* @return               Regresa la diferencia entre ambas fechas en minutos    
	*/
    public static Long calculateTimeDifferences(DateTime fechaPeticion, DateTime today){
	   
        Long minutes;
        Long fechaPeticionLong = fechaPeticion.getTime();
        Long todayLong = today.getTime();
        Long milliseconds = todayLong - fechaPeticionLong;
        Long seconds = milliseconds / 1000;
        minutes = seconds / 60;
        return minutes;
    }

}