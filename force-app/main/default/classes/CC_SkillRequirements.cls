public class CC_SkillRequirements {
    
    @InvocableMethod(label='Recuperar Skills' description='Recuperar Skills')
    public static List<String> recuperarSkills(List<List<SkillRequirement>> skillsRerquirement)
	{
        //CC_TrazaInt__c oTraza0 = new CC_TrazaInt__c();
        //CC_TrazaInt__c oTraza = new CC_TrazaInt__c();
        //oTraza0.Name = 'ENTRAMOS';
        Set<Id> setIdSkills = new Set<Id>();
        String idioma = '';
        String agenteohidden = '';
        String skillextra = '';
        String tipoChat = '';
        String str = '';
        String proveedorpordefecto = 'DXC';
        List <SkillRequirement> skillReqs = skillsRerquirement.get(0);
        
        //Recogemos los Skills ID de los SkillRequirements

        if(!skillReqs.isEmpty()){
            for(SkillRequirement skillrq : skillReqs){
                setIdSkills.add(skillrq.SkillId);
            }
        }
        List<Skill> listSkills = new List<Skill>();
        if(!setIdSkills.isEmpty()){
            listSkills = [SELECT DeveloperName FROM Skill WHERE Id IN :setIdSkills];    

        }
        //Guardamos las SKills y su developer name

        if(!listSkills.isEmpty()){
            for(Skill skill: listSkills){
                if (String.isNotBlank(skill.Developername)) {
                    system.debug('skill.Developername: '+skill.Developername);
                    if(skill.Developername.length() == 2){
                        idioma =skill.Developername.toLowerCase();
                    } else if (skill.Developername.startsWith('Agente') || skill.Developername.startsWith('Hidden')){
                        agenteohidden = skill.Developername;
                    }else if ( skill.Developername.length() > 3){
                        skillextra = skill.Developername;
                    }
                }
            }  
    		system.debug('tipoChat0: '+tipoChat);
            if(skillextra == 'NoaApp' || skillextra == 'GinaApp'){
            	tipoChat = 'Clientes';
            }else{
                tipoChat = 'Empleados';
            }
            
            system.debug('tipoChat: '+tipoChat);

            List<CC_Capacidad_Proveedores__c> capacidades = [SELECT CC_Proveedor__c, CC_Capacidad__c, CC_Cliente_Empleado__c FROM CC_Capacidad_Proveedores__c WHERE CC_Cliente_Empleado__c =: tipoChat AND CC_Idioma__c =: idioma AND CC_Tipo_Chat_Transcript__c =: agenteohidden AND CC_Queue_Name__c =: skillextra AND CC_Canal_Entrada__c = 'Chat' AND CC_Capacidad__c > 0];			
            
    
            if(!capacidades.isEmpty() && tipoChat == 'Empleados'){
                
                //Calculamos la capacidad acumulada de cada proveedor
    
                Map<Double,String> mapcapacidades = new Map<Double,String>();
                Double capacidadacumulada = 0;
                
                for(CC_Capacidad_Proveedores__c cap : capacidades){
                        
                    if(mapcapacidades.containsKey(capacidadacumulada)){
                        String captoadd = mapcapacidades.get(capacidadacumulada);
                        captoadd = cap.CC_Proveedor__c;
                        mapcapacidades.put(capacidadacumulada,captoadd);
                    }else{
                        String captoadd = '';
                        captoadd = cap.CC_Proveedor__c;
                        mapcapacidades.put(capacidadacumulada,captoadd);
                            
                    }
                        
                    capacidadacumulada += cap.CC_Capacidad__c/100;
                        
                }
                
                String proveedorfinal = '';
                Double randomNumber = Math.random();
                List<Double> listcaps = new List<Double>(mapcapacidades.keySet());
                listcaps.sort();
    
                //Ejecutamos la logica del numero aleatorio para elegir al ganador
                
                for (Integer i=0; i < listcaps.size(); i++) {
                    
                    if (randomNumber >= Double.valueOf(listcaps[i])) {
                        if (i+1 == listcaps.size()) {
                            // Se ha llegado al último elemento de la lista, por lo que se establece esta capacidad como la elegida
                            if (mapcapacidades.containsKey(listcaps[i])) {
                                proveedorfinal = mapcapacidades.get(listcaps[i]) ;
                            }
                        } else if (randomNumber < Double.valueOf(listcaps[i+1])) {
                            // Se establece esta capacidad como la elegida
                            if (mapcapacidades.containsKey(listcaps[i])) {
                                proveedorfinal = mapcapacidades.get(listcaps[i]) ;
                            }
                            break;
                        }
                    }
                }
   
            
                //Devolvemos la lista con el ganador
    
                List<String> listtoreturn = New List<String>();
                listtoreturn.add(proveedorfinal);
    
                //oTraza.CC_DetalleError__c = proveedorfinal;
                //Database.insert(oTraza);
                
                return listtoreturn;
            } else if(!capacidades.isEmpty() && tipoChat == 'Clientes'){
                //Calculamos la capacidad acumulada de cada proveedor
    
                Map<Double,String> mapcapacidadesCli = new Map<Double,String>();
                Double capacidadacumuladaCli = 0;
                
                for(CC_Capacidad_Proveedores__c capCli : capacidades){
                        
                    if(mapcapacidadesCli.containsKey(capacidadacumuladaCli)){
                        String captoaddCli = mapcapacidadesCli.get(capacidadacumuladaCli);
                        captoaddCli = capCli.CC_Proveedor__c;
                        mapcapacidadesCli.put(capacidadacumuladaCli,captoaddCli);
                    }else{
                        String captoaddCli = '';
                        captoaddCli = capCli.CC_Proveedor__c;
                        mapcapacidadesCli.put(capacidadacumuladaCli,captoaddCli);
                            
                    }
                        
                    capacidadacumuladaCli += capCli.CC_Capacidad__c/100;
                        
                }
                
                String proveedorfinalCli = '';
                Double randomNumberCli = Math.random();
                List<Double> listcapsCli = new List<Double>(mapcapacidadesCli.keySet());
                listcapsCli.sort();
    
                //Ejecutamos la logica del numero aleatorio para elegir al ganador
                
                for (Integer i=0; i < listcapsCli.size(); i++) {
                    
                    if (randomNumberCli >= Double.valueOf(listcapsCli[i])) {
                        if (i+1 == listcapsCli.size()) {
                            // Se ha llegado al último elemento de la lista, por lo que se establece esta capacidad como la elegida
                            if (mapcapacidadesCli.containsKey(listcapsCli[i])) {
                                proveedorfinalCli = mapcapacidadesCli.get(listcapsCli[i]) ;
                            }
                        } else if (randomNumberCli < Double.valueOf(listcapsCli[i+1])) {
                            // Se establece esta capacidad como la elegida
                            if (mapcapacidadesCli.containsKey(listcapsCli[i])) {
                                proveedorfinalCli = mapcapacidadesCli.get(listcapsCli[i]) ;
                            }
                            break;
                        }
                    }
                }
            
                //Devolvemos la lista con el ganador
    
                List<String> listtoreturnCli = New List<String>();
                listtoreturnCli.add(proveedorfinalCli);
                
                return listtoreturnCli;
            }else {
                
                List<String> lstproovpordefecto = New List<String>();
                lstproovpordefecto.add(proveedorpordefecto);
                
                return lstproovpordefecto;
                
                
            }
        }
        else{
            List<String> lstproovpordefecto = new List<String>();
            lstproovpordefecto.add(proveedorpordefecto);
            return lstproovpordefecto;
        }   
                
    }
}