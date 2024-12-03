/**********************************************************************************************************************
Name:	  AV_MaskUtils
Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Métodos para calcular los campos a enmascarar
=======================================================================================================================
Historial
---------------------
VERSION		USER_STORY		AUTHOR				DATE				Description
1.0			App FSC			Esperanza Conde		10/07/2020			Init version

***********************************************************************************************************************/
public with sharing class AV_MaskUtils {
    
    private static final List<String> LETRAS_NIF = new List<String>{'T', 'R', 'W', 'A', 'G', 'M','Y', 'F', 'P', 'D', 'X', 'B', 'N', 'J', 'Z', 'S', 'Q', 'V', 'H','L', 'C', 'K', 'E'};
    private static final String AV_PARTICULAR = 'CC_ClientePA';
    private static final String AV_EMPRESA = 'CC_Cliente';
    
    /**
    * Update Field to mask description field in Account
    *
    * @param cliente cliente to update
    */
    public static void maskDescription(Account cliente) {
        
        String str = cliente.Description;
        String result = '';
        if(!String.isBlank(str)){
            for(integer i = 0; i < str.length(); i++) {
                if(!String.isBlank(str.mid(i,1))){
                    result += 'X';
                    system.debug('Result '+i+': ' +str.mid(i,1)+ ' sustituyo por X');
                }else{
                    result += ' ';
                    system.debug('Result '+i+': ' +str.mid(i,1)+ ' sustituyo por vacio');
                }   
            }  
            cliente.Description = result;
        }
    }
    
    /**
    * Update Field to mask Phone or PersonMobilePhone field in Account
    *
    * @param tipo string to indicate the account is person account (Cliente particular) or account (Cliente Empresa)
    * @param cliente cliente to update
    */
    public static void maskTelephone(Account cliente, String tipo) {
        Integer len = 8;
        String str = string.valueof(Math.abs(Crypto.getRandomLong()));
        String randomNumber = str.substring(0, len);
        system.debug('Random Number -' + randomNumber);
        if(tipo == AV_PARTICULAR){
            cliente.PersonMobilePhone = '6' +randomNumber;
        } 
        cliente.Phone = '9' +randomNumber;

    }
    
    /**
    * Update Field to mask FirstName, LastName, PersonEmail or Name field in Account
    *
    * @param tipo string to indicate the account is person account (Cliente particular) or account (Cliente Empresa)
    * @param cliente cliente to update
    */
    public static void maskPersonInformation(Account cliente, String tipo) {
        
        // Top 100 male and female from US data in 2014
        List<String> firstNames = new List<String> {'Aaliyah', 'Abigail', 'Addison', 'Alexa', 'Alexandra', 'Alexis', 'Alice', 'Allison', 'Alyssa', 'Amelia', 'Anna', 'Annabelle', 'Aria', 'Ariana', 'Arianna', 'Ashley', 'Aubree', 'Aubrey', 'Audrey', 'Autumn', 'Ava', 'Avery', 'Bella', 'Brianna', 'Brooklyn', 'Camila', 'Caroline', 'Charlotte', 'Chloe', 'Claire', 'Eleanor', 'Elizabeth', 'Ella', 'Ellie', 'Emily', 'Emma', 'Eva', 'Evelyn', 'Faith', 'Gabriella', 'Genesis', 'Gianna', 'Grace', 'Hadley', 'Hailey', 'Hannah', 'Harper', 'Isabella', 'Isabelle', 'Jasmine', 'Julia', 'Katherine', 'Kaylee', 'Kennedy', 'Khloe', 'Kylie', 'Lauren', 'Layla', 'Leah', 'Lillian', 'Lily', 'London', 'Lucy', 'Lydia', 'Mackenzie', 'Madeline', 'Madelyn', 'Madison', 'Maya', 'Melanie', 'Mia', 'Mila', 'Naomi', 'Natalie', 'Nevaeh', 'Nora', 'Olivia', 'Paisley', 'Penelope', 'Peyton', 'Piper', 'Riley', 'Ruby', 'Sadie', 'Samantha', 'Sarah', 'Savannah', 'Scarlett', 'Serenity', 'Skylar', 'Sofia', 'Sophia', 'Sophie', 'Stella', 'Taylor', 'Victoria', 'Violet', 'Vivian', 'Zoe', 'Zoey', 'Aaron', 'Adam', 'Adrian', 'Aiden', 'Alexander', 'Andrew', 'Angel', 'Anthony', 'Asher', 'Austin', 'Ayden', 'Benjamin', 'Bentley', 'Blake', 'Brandon', 'Brayden', 'Brody', 'Caleb', 'Camden', 'Cameron', 'Carson', 'Carter', 'Charles', 'Chase', 'Christian', 'Christopher', 'Colton', 'Connor', 'Cooper', 'Daniel', 'David', 'Dominic', 'Dylan', 'Easton', 'Eli', 'Elijah', 'Ethan', 'Evan', 'Gabriel', 'Gavin', 'Grayson', 'Henry', 'Hudson', 'Hunter', 'Ian', 'Isaac', 'Isaiah', 'Jace', 'Jack', 'Jackson', 'Jacob', 'James', 'Jason', 'Jaxon', 'Jaxson', 'Jayden', 'Jeremiah', 'John', 'Jonathan', 'Jordan', 'Jose', 'Joseph', 'Joshua', 'Josiah', 'Juan', 'Julian', 'Justin', 'Kayden', 'Kevin', 'Landon', 'Leo', 'Levi', 'Liam', 'Lincoln', 'Logan', 'Lucas', 'Luis', 'Luke', 'Mason', 'Matthew', 'Michael', 'Nathan', 'Nathaniel', 'Nicholas', 'Noah', 'Nolan', 'Oliver', 'Owen', 'Parker', 'Robert', 'Ryan', 'Ryder', 'Samuel', 'Sebastian', 'Thomas', 'Tristan', 'Tyler', 'William', 'Wyatt', 'Xavier', 'Zachary'};
            
        // Top 200 last names from US data in 2014
        List<String> lastNames = new List<String> {'Adams', 'Alexander', 'Allen', 'Alvarez', 'Anderson', 'Arnold', 'Bailey', 'Baker', 'Barnes', 'Bell', 'Bennett', 'Black', 'Boyd', 'Bradley', 'Brooks', 'Brown', 'Bryant', 'Burns', 'Butler', 'Campbell', 'Carter', 'Castillo', 'Castro', 'Chavez', 'Clark', 'Cole', 'Coleman', 'Collins', 'Cook', 'Cooper', 'Cox', 'Crawford', 'Cruz', 'Cunningham', 'Daniels', 'Davis', 'Diaz', 'Dixon', 'Dunn', 'Edwards', 'Elliott', 'Ellis', 'Evans', 'Ferguson', 'Fernandez', 'Fisher', 'Flores', 'Ford', 'Foster', 'Fox', 'Freeman', 'Garcia', 'Gardner', 'Gibson', 'Gomez', 'Gonzales', 'Gonzalez', 'Gordon', 'Graham', 'Grant', 'Gray', 'Green', 'Griffin', 'Gutierrez', 'Hall', 'Hamilton', 'Hansen', 'Harris', 'Harrison', 'Hart', 'Hawkins', 'Hayes', 'Henderson', 'Henry', 'Hernandez', 'Herrera', 'Hicks', 'Hill', 'Hoffman', 'Holmes', 'Howard', 'Hughes', 'Hunt', 'Hunter', 'Jackson', 'James', 'Jenkins', 'Jimenez', 'Johnson', 'Jones', 'Jordan', 'Kelley', 'Kelly', 'Kennedy', 'Kim', 'King', 'Knight', 'Lee', 'Lewis', 'Long', 'Lopez', 'Marshall', 'Martin', 'Martinez', 'Mason', 'Mcdonald', 'Medina', 'Mendoza', 'Meyer', 'Miller', 'Mills', 'Mitchell', 'Moore', 'Morales', 'Moreno', 'Morgan', 'Morris', 'Murphy', 'Murray', 'Myers', 'Nelson', 'Nguyen', 'Nichols', 'Olson', 'Ortiz', 'Owens', 'Palmer', 'Parker', 'Patel', 'Patterson', 'Payne', 'Perez', 'Perry', 'Peters', 'Peterson', 'Phillips', 'Pierce', 'Porter', 'Powell', 'Price', 'Ramirez', 'Ramos', 'Reed', 'Reyes', 'Reynolds', 'Rice', 'Richardson', 'Rivera', 'Roberts', 'Robertson', 'Robinson', 'Rodriguez', 'Rogers', 'Romero', 'Rose', 'Ross', 'Ruiz', 'Russell', 'Ryan', 'Sanchez', 'Sanders', 'Schmidt', 'Scott', 'Shaw', 'Simmons', 'Simpson', 'Smith', 'Snyder', 'Spencer', 'Stephens', 'Stevens', 'Stewart', 'Stone', 'Sullivan', 'Taylor', 'Thomas', 'Thompson', 'Torres', 'Tran', 'Tucker', 'Turner', 'Vasquez', 'Wagner', 'Walker', 'Wallace', 'Ward', 'Warren', 'Washington', 'Watson', 'Weaver', 'Webb', 'Wells', 'West', 'White', 'Williams', 'Wilson', 'Wood', 'Woods', 'Wright', 'Young'};
                
        // Create a random number that corresponds to index in first and last names lists
        Integer firstNameIndex = (Integer)(Math.random() * firstNames.size());
        Integer lastNameIndex = (Integer)(Math.random() * lastNames.size());
        
        // Select the first and last name from the lists based on random indices
        string firstNameSelected = firstNames[firstNameIndex];
        string lastNameSelected = lastNames[lastNameIndex];
       
        
        // Retrieving a selected first and last name based on logic above
        Integer clienteFirstNameIndex = (Integer)(Math.random() * firstNames.size());
        Integer clienteLastNameIndex = (Integer)(Math.random() * lastNames.size());
        
        String clienteFirstNameSelected = firstNames[clienteFirstNameIndex];
        String clienteLastNameSelected = lastNames[clienteLastNameIndex];
        
        
        // Creating a new Lead sobject and assigning our selected vaues to Lead fields
        if(tipo == AV_PARTICULAR){
            cliente.FirstName = clienteFirstNameSelected;
            cliente.LastName = clienteLastNameSelected;
            cliente.PersonEmail = cliente.FirstName+'.'+cliente.LastName+'@crm-caixabank.test.sfdc.com';
        }else{
            cliente.Name = clienteFirstNameSelected + ' ' +clienteLastNameSelected;    
        }
    }
    
    /**
    * Update Field to mask BirthDate field in Account
    *
    * @param cliente cliente to update
    */
    public static void maskBirthDate(Account cliente) {
        
        // Convert to DateTime values
        DateTime mint = Date.newInstance(1960, 1, 1), maxt = Date.newInstance(2000, 1, 1).addDays(1);
        // Then convert to milliseconds since Jan 1, 1970, and get difference in ms
        Long minms = mint.getTime(), maxms = maxt.getTime(), diff = maxms - minms;
        // Return a date between minms and maxms.
        cliente.PersonBirthdate = DateTime.newInstance(minms + Math.mod(Math.abs(Crypto.getRandomLong()), diff)).date();
        
    }
    
    /**
    * Update Field to mask CC_Numero_Documento__pc field in Account
    *
    * @param cliente cliente to update
    */
    public static void maskIdenNumber(Account cliente) {
        
        String nif = generaNif();
        cliente.CC_Numero_Documento__pc = nif; 
       
    }
    
    
    public static String generaNif() {
        
        Integer len = 8;
        String str = string.valueof(Math.abs(Crypto.getRandomLong()));
        String randomDNI = str.substring(0, len);
        
        Integer dniInt = Integer.valueOf(randomDNI);
        randomDNI = randomDNI + LETRAS_NIF[Math.Mod(dniInt, 23)];
        return randomDNI;
        
    }
    
}