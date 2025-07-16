({
    cargarTagsImgCuerpo: function(component, comprobarTags){
        //El rich text borra los atributos 'alt' de las etiquetas img, por lo que cada vez que se actualiza tenemos que recorrer el map de tag de imagenes
        //y en caso de haber imagenes con tag, asignar el tag a cada una de estas

        //Recupero el contenido del cuerpo y el mapa de tag de imagenes
        var cuerpo = component.get("v.cuerpo");
        var imageMap = component.get("v.imageTagsMapPadre");
        
        //Encuentra todas las imagenes del cuerpo
        var parser = new DOMParser();
        var doc = parser.parseFromString(cuerpo, 'text/html');
        var images = Array.from(doc.querySelectorAll('img'));

        //Recorro las imagenes, y si tiene una entrada en el mapa de tags, le añado el atributo 'alt'
        images.forEach(function (image) {
			
            if(imageMap && imageMap.has(image.src)){
                var alt = imageMap.get(image.src);

                if (alt !== undefined && alt !== '') {
                    image.setAttribute('alt', alt);
                }else{
                    component.set('v.todasImgConTag', false);
                }
            }else{
                const baseUrl = doc.baseURI; 

                if(image.src !== baseUrl){
                    component.set('v.todasImgConTag', false);
                }
            }
        });       

        if(!comprobarTags){
            //Actualizo el valor del cuerpo con el contenido actualizado
            var updatedContent = doc.body.innerHTML;
            component.set("v.cuerpo", updatedContent);
        }
    }
})