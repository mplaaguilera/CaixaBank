({
    cargarTagImgEmailTemplate : function(component, event) {

        //Buscar si la plantilla trae imagenes
        var parser = new DOMParser();
        var doc = parser.parseFromString(component.get('v.value'), 'text/html');
        var images = Array.from(doc.querySelectorAll('img'));
        const baseUrl = doc.baseURI;        

        //Si se han detectado imagenes en la plantilla, las procesamos
        if(images.length > 0){       
            let imageAltMap = component.get('v.imageAltMap') || {};

            //Recorro las imagenes, y si tiene atributo alt la añado en el mapa de tags
            images.forEach((image) => {
                if(image.src && image.src !== baseUrl){  //El navegador por defecto si una img viene con src='' le asigna la url base, para evitar que en caso de varias img sin src                     
                    imageAltMap[image.src] = image.alt;     //el mapa se rellene con un alt erroneo, añadimos la condición 'image.src !== baseUrl'                  
                }
            });

            component.set('v.imageAltMap', imageAltMap);
                            
            //Envío un evento al aura con el mapa de tags actualizado
            this.dispatchEvent(new CustomEvent('evtinforichtext', {
                detail: {
                    data: component.get('v.imageAltMap')
                }
            }));
        }
    },
    
    cargarTagImgEmailTemplate : function(component, event) {
        if(!component.get('v.isOpen')){
            const richTextElement = this.template.querySelector('[data-id="richText1"]');
            
            if (richTextElement) {
                richTextElement.blur();
            }
        }else{
            const richTextElement = this.template.querySelector('[data-id="richText2"]');

            if (richTextElement) {
                richTextElement.blur();
            }
        }
    },

    extractImages : function(value) {
        const parser = new DOMParser();
        const doc = parser.parseFromString(value, 'text/html');

        return Array.from(doc.querySelectorAll('img'));
    }
})