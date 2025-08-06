/**********************************************************************************************************************
 Name:	  CBK_PKChunkUtils
 Copyright © 2021  CaixaBank
=======================================================================================================================
Proposito: Clase de utilidades para la conversión de IDs a enteros y viceversa para el calculo segmentos vía PKChunking
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Francisco Zaragoza	28/05/2021			Init version
***********************************************************************************************************************/
public with sharing class CBK_PKChunkUtils {

    static String baseDigits = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    
    /**
    * @description Converts the string value of an ID to a integer value in base64
    * @author   fzaragoza | 28/05/2021 
	* @param s		-> String value of Id
	* @return		-> long value of the ID
	*/
	public static Long decodeBase62(String s) {
		Long ret = 0;
		Long mult = 1;
		
		String[] chars = s.split('');
		
		String[] charsReversed = new List<String>();
		
		for(Integer i = chars.size()-1; i>=0; i--) {
	    	charsReversed.add(chars.get(i));
		}
		
		for (String c: charsReversed) {
			Integer index = baseDigits.indexOf(c);
			system.assert(index > -1, 'carácter incorrecto');
			ret += mult*index;
       		mult *= 62;
		}
		
		return ret;
	}    
    
    /**
    * @description Converts the integer value of an ID in base64 to a string value
    * @author   fzaragoza | 28/05/2021 
	* @param num		-> integer value of Id
	* @return		-> string value of the ID
	*/
	public static String encodeBase62(Long num) {
		system.assert(num >= 0, 'Se espera un valor positivo');
		if (num == 0) {
			return '0';
		}

		List<String> retList = new List<String>();

		String[] basedigitsArr = basedigits.split('');

		while (num != 0) {
			Integer cIndex = (Integer)Math.Mod(num, 62);
			retList.add(basedigitsArr[cIndex]);
			num = (num/62);
		}
		
		List<String> retListReversed = new List<String>();
		for(Integer i = retList.size()-1; i>=0; i--) {
	    	retListReversed.add(retList.get(i));
		}	
			
		return String.join(retListReversed, '');
	}  

    /**
    * @description Take a 15 or 18 digit start and ending salesforce Id and break in into chunk ranges of specified size
    *              Only works if all the IDs have the same pod identider. Be careful of pod splits, sandbox / production data in a sandbox, etc
    * @author   fzaragoza | 28/05/2021 
	* @param startId		-> string value of the first Id of the interval
    * @param endId		-> string value of the last Id of the interval
    * @param chunkSize		-> Chunk size in order to divide the interval between first an last value indicated
	* @return		-> string value of the ID
	*/  
    public static List<Map<String, String>> chunkIdRange(String startId, String endId, Integer chunkSize) {
		
		//guardamos el prefijo
        String idPrefix = startId.left(6);
		
		String startIdStripped = startId.left(15).right(9);
		String endIdStripped = endId.left(15).right(9);
		
		Long startNum = decodeBase62(startIdStripped); 
		Long endNum = decodeBase62(endIdStripped); 
	    	
    	//segmentamos numericamente los intervalos
    	List<Map<String, String>> numberChunkList = chunkRange(startNum, endNum, 9, chunkSize);

    	//transformamos a formato Id válido
    	List<Map<String, String>> idChunkList = new List<Map<String, String>>();
    	for (Map<String, String> chunkMap: numberChunkList) {
    		Long rangeStart = Long.valueOf(removeLeadZeroes(chunkMap.get('first')));
    		Long rangeEnd 	= Long.valueOf(removeLeadZeroes(chunkMap.get('last')));
    		
    		String rangeStartB62 	= prefixStringWithZeros(encodeBase62(rangeStart), 9);
    		String rangeEndB62 		= prefixStringWithZeros(encodeBase62(rangeEnd), 9);
    		
    		idChunkList.add(new Map<String, String>{'first'=> idPrefix+rangeStartB62, 'last'=> idPrefix+rangeEndB62});
    	}
    	
    	return idChunkList;    
    }

    /**
    * @description This method is used to chunk up a large range of Long Integers into a list of smaller ranges.
    * @author   fzaragoza | 28/05/2021 
	* @param firstNum		-> start number
    * @param lastNum		-> end number
    * @param totalLength		-> length of characters (for trailing zeroes)
    * @param chunkSize		-> size of the chunks
	* @return		-> string value of the ID
	*/ 
    public static List<Map<String, String>> chunkRange(Long firstNum, Long lastNum, Integer totalLength, Integer chunkSize) {
   		//rango
   		Long range = (lastNum - firstNum);	
    	
    	List<Map<String, Long>> numChunkList = new List<Map<String, Long>>();
    	
    	
 		if (range < chunkSize) { 
 			numChunkList.add(new Map<String, Long>{'first'=> firstNum, 'last'=> lastNum});	
 		} else {
	    	//calculamos número de bloques del rango
			Decimal numChunks = (range / chunkSize);
			numChunks = numChunks.round(System.RoundingMode.DOWN);
			Integer numWholeChunks = numChunks.intValue();
			
			//primer bloque
			Long firstNumChunk = 	firstNum;
			Long lastNumChunk = 	firstNum + chunkSize - 1;
			numChunkList.add(new Map<String, Long>{'first'=> firstNumChunk, 'last'=> lastNumChunk}); 			
			
			//resto de bloques completos
			for (Integer i=1; i<numWholeChunks; i++) {
				firstNumChunk = (lastNumChunk + 1);
				lastNumChunk = (firstNumChunk + chunkSize - 1);						
				numChunkList.add(new Map<String, Long>{'first'=> firstNumChunk, 'last'=> lastNumChunk});
			}
			
			//resto - intervalo final (módulo)
			Long lastlastNumChunk = numChunkList[numChunkList.size()-1].get('last');
			if (lastlastNumChunk < lastNum) {
				numChunkList.add(new Map<String, Long>{'first'=> lastlastNumChunk+1, 'last'=> lastNum});	
			}
	 	}    	
    	
    	//retorno a formato Ids Salesforce válido
    	List<Map<String, String>> numChunkListZeroPadded = new List<Map<String, String>>();
    	for (Map<String, Long> rangeMap: numChunkList) {
    		numChunkListZeroPadded.add(new Map<String, String>{	'first'=> prefixLongWithZeros(rangeMap.get('first'), totalLength), 
    															'last' => prefixLongWithZeros(rangeMap.get('last'),  totalLength)	});		
    	}
    	
    	return numChunkListZeroPadded;
    }    
    
     /**
    * @description This method removes leading zeros from a passed string of numbers or returns NULL when not all numeric characters
    * @author   fzaragoza | 28/05/2021 
	* @param passedValue	-> string value
	* @return		-> string value without trailing zeroes
	*/ 
    public static String removeLeadZeroes(String passedValue) {
        String returnString = null;
        if (passedValue != null) { 
            returnString = passedValue.trim();
            Pattern validCharacters = Pattern.compile('([0-9]+)'); 
            Matcher checkChars = validCharacters.matcher(returnString); 
            if (checkChars.matches()) {
                if (returnString.startsWith('0') && returnString.length() > 1) { 
                    boolean keepChecking = true; 
                    while (keepChecking) { 
                        if (returnString.startsWith('0') && returnString.length() > 1) { 
                            returnString = returnString.substring(1); 
                        } else { 
                            keepChecking = false; 
                        }
                    }
                }
                if (returnString == '0') { 
                    returnString = null; 
                }
            } else { 
                returnString = null; 
            }
        }
        return returnString;
    }        
    
    /**
    * @description This method adds leading zeros to a string 
    * @author   fzaragoza | 28/05/2021 
	* @param passedValue	-> string value
    * @param totalLength	-> string total length required
	* @return		-> string value with trailing zeroes
	*/
	public static String prefixStringWithZeros(String passedValue, Integer totalLength) {
		String strOutput = '';
		
		if (passedValue != null) {
			strOutput	= passedValue+'';
		}
		//incluye los 0 previos hasta completar la longitud de cadena indicada
		Integer zerosToAdd = (totalLength - strOutput.length());
		if (zerosToAdd > 0) {
			for (Integer i=0; i<zerosToAdd; i++) {
				strOutput = '0'+strOutput;	
			}
		}
		
		return strOutput;
	}	    
    
    /**
    * @description This method adds leading zeros to a long and returns it as a string 
    * @author   fzaragoza | 28/05/2021 
	* @param passedValue	-> long value
    * @param totalLength	-> string total length required
	* @return		-> string value with trailing zeroes
	*/
	public static String prefixLongWithZeros(Long lngInput, Integer totalLength) {
		String strOutput = '';
		
		if (lngInput != null) {
			strOutput	= lngInput+'';
		}
		
		//prepend with zeros needed to get up to total length
		Integer zerosToAdd = (totalLength - strOutput.length());
		if (zerosToAdd > 0) {
			for (Integer i=0; i<zerosToAdd; i++) {
				strOutput = '0'+strOutput;	
			}
		}
		
		return strOutput;
	}	    
}