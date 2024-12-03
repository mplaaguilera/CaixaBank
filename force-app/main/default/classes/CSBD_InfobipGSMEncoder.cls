public class CSBD_InfobipGSMEncoder {

    // Define GSM 03.38 character set
    public static final String GSM_CHARSET = '@£$¥èéùìòÇ\nØø\rÅåΔ_ΦΓΛΩΠΨΣΘΞ1BÆæßÉ !"#$%&\'()*+,-./0123456789:;<=>?¡ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÑÜ§¿abcdefghijklmnopqrstuvwxyzäöñüà';

    // Encode the input message to be GSM 03.38 compliant
    public static String encodeToGSM(String message) {
        String messageReplaced = message;
        
        for (Integer i = 0; i < message.length(); i++) {
            String character = message.substring(i, i + 1);
            
            // If the character is part of the GSM charset, add it to the result
            if (!GSM_CHARSET.contains(character)) {
                String characterNew = replaceUnsupportedCharacter(character);
                messageReplaced.replace(character, characterNew);
            } 
        }
        
        return messageReplaced;
    }

    // Replace unsupported characters with alternatives (e.g., é -> e, ñ -> n)
    private static String replaceUnsupportedCharacter(String character) {
        switch on character {
            when 'é' {		// when block 1
                return 'e';
            }	
            when 'ñ' {		// when block 2
                return 'n';
            }
            when 'ø' {		// when block 3
                return 'o';
            }
            when else {		  // default block, optional
                return '';
            }
        }   
    }
}