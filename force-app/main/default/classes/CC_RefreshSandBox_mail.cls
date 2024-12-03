global class CC_RefreshSandBox_mail implements SandboxPostCopy {
  global void runApexClass(SandboxContext context) {
        //Actualización de mail después de refresh de SandBox desde CONSO

        List<String> usuarios = new List<String>();

        usuarios.add('jorge.hernando.garcia@ibm.com.dev002');
        usuarios.add('francisco.cabello.lara@ibm.com.dev003');
        usuarios.add('sofia.pujol.castillo@ibm.com.dev004');
        usuarios.add('victor.melo@ibm.com.dev005');
        usuarios.add('noelia.marin.andrada@ibm.com.dev006');
        usuarios.add('marc.pla.aguilera@ibm.com.dev007'); 
        usuarios.add('josep.costa.sanmarti@ibm.com.dev008');
        usuarios.add('german.meca.duarte@ibm.com.dev009');
        usuarios.add('manuel.albacete.krenn@ibm.com.dev009');
        usuarios.add('antonio.torres@ibm.com.dev010');
        usuarios.add('aaron.pizarro.pedriza@ibm.com.dev011');
        usuarios.add('jordi.cabrera.valls@ibm.com.dev012');
        usuarios.add('xavier.juanola.molet@ibm.com.dev013');                
        
        List<User> userEmailList = [select Id,Email from User where Email like '%ibm.com.invalid' and username in :usuarios]; 
        
        for(User uc : userEmailList)     
        { 
            String addedPhrase = '.invalid'; 
            uc.Email = uc.Email.remove(addedPhrase); 
        } 
        
        if(userEmailList.size() > 0) 
        { 
             Update userEmailList; 
        } 
    }
}