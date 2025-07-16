import { LightningElement, api, wire, track } from 'lwc';

export default class Sac_ModificarTagImagenes extends LightningElement {
    @api recordId;
    @api cuerpo;
    @api imageTagsMap;
    imagenes = [];
    imageMapObject;
    imageAltMap = new Map();
    @track mostrarModificarImagen = false;
    @track noImagenes = false;

    mostrarModalModificarImagen() {
        this.noImagenes = false;

        // Si el mapa de imagenes no es nulo
        if(this.imageTagsMap != null) {             
                        console.log('mapa en lwc modificar imagenes dentro -> ' + JSON.stringify(Object.fromEntries(this.imageTagsMap), null, 2));
            // Se recupera el mapa con las imagénes pasadas desde el gestion emails y se formatea para mostrarlo en la tabla
            this.imageMapObject = Object.fromEntries(this.imageTagsMap);

            // Recuperar las imagenes que se pasan desde el mapa del gestión emails
            this.imagenes = Object.entries(this.imageMapObject).map(([src, alt]) => {
                return {
                    src: src,
                    alt: alt && alt.trim() ? alt : "Descripción vacía" // Si `alt` está vacío o es null, usar "Descripción vacía"
                };
            });

            // Expresión regular para capturar etiquetas <img>
            const imgTags = this.cuerpo.match(/<img[^>]*src="([^"]+)"[^>]*>/gi);

            // Extraer src y alt de las imágenes
            const imagenesCuerpo = imgTags ? imgTags.map((tag) => {
                const srcMatch = tag.match(/src="([^"]+)"/i);
                const altMatch = tag.match(/alt="([^"]+)"/i);

                return {
                    src: srcMatch ? srcMatch[1] : '',
                    alt: altMatch ? altMatch[1] : 'Descripción vacía'
                };
            })
            : [];

            // En el caso de que la longtud del mapa de imagenes recuperadas en el cuerpo no coincida con el mapa de imagenes del gestión emails quiere decir que se ha borrado una imagen y debe actualizarse el mapa
            if (this.imagenes.length != imagenesCuerpo.length) { 
                // // Crear un conjunto con los `src` de imagenesCuerpo, normalizando las URLs
                //const srcSetCuerpo = new Set(imagenesCuerpo.map(imagen => decodeURIComponent(imagen.src.replace(/&amp;/g, '&'))));

                // // Filtrar el mapa imagenes para mantener solo las entradas que también existen en imagenesCuerpo
                //this.imagenes = this.imagenes.filter(imagen => srcSetCuerpo.has(decodeURIComponent(imagen.src.replace(/&amp;/g, '&'))));

                // Crear un conjunto con los `src` de imagenes, normalizando las URLs
                const srcSetImagenes = new Set(this.imagenes.map(imagen => decodeURIComponent(imagen.src.replace(/&amp;/g, '&'))));

                // Filtrar el mapa imagenesCuerpo para mantener los registros comunes, pero respetando el atributo alt de imagenes
                //this.imagenes = this.imagenes.filter(imagen => srcSetImagenes.has(decodeURIComponent(imagen.src.replace(/&amp;/g, '&'))));
                this.imagenes = imagenesCuerpo.filter(imagenCuerpo => srcSetImagenes.has(decodeURIComponent(imagenCuerpo.src.replace(/&amp;/g, '&')))).map(imagenCuerpo => {
                    const normalizedSrc = decodeURIComponent(imagenCuerpo.src.replace(/&amp;/g, '&'));
                    const imagenEnImagenes = this.imagenes.find(imagen => decodeURIComponent(imagen.src.replace(/&amp;/g, '&')) === normalizedSrc);
                    return {
                        src: normalizedSrc,
                        alt: imagenEnImagenes ? imagenEnImagenes.alt : imagenCuerpo.alt // Usar el alt de imagenes si está disponible
                    };
                });

                // Agregar registros de imagenes que no estén en imagenesCuerpo
                imagenesCuerpo.forEach(imagen => {
                    const normalizedSrc = decodeURIComponent(imagen.src.replace(/&amp;/g, '&'));
                    if (!srcSetImagenes.has(normalizedSrc)) {                        
                        this.imagenes.push({ src: normalizedSrc, alt: imagen.alt });
                        srcSetImagenes.add(normalizedSrc); // Actualizamos el conjunto para evitar duplicados
                    }
                });
            }
            
            if (this.imagenes.length == 0) { 
                this.noImagenes = true;
            }  

            this.mostrarModificarImagen = true; 
        }
    }

    closeModalImagen() {
        this.mostrarModificarImagen = false;
    }

    
    modificarImagen() {
        // Convertir cuerpo a un elemento DOM
        const parser = new DOMParser();
        const doc = parser.parseFromString(this.cuerpo, 'text/html'); // Parseamos el HTML
        
        // Obtener todos los inputs en el DOM
        const inputs = this.template.querySelectorAll('lightning-input');

        inputs.forEach((input) => {

            const newAlt = input.value; // Nuevo valor del alt
            const src = input.dataset.id; // Identificar la imagen mediante su src

            // Buscar la imagen en el árbol DOM
            const imgElement = doc.querySelector(`img[src="${src}"]`);
            
            if (imgElement) {                
                // Actualizar el atributo alt
                imgElement.setAttribute('alt', newAlt);

                // Actualizar el mapa originalMap
                this.imageAltMap.set(src, newAlt);                    

                if (this.imageMapObject[src] !== undefined) {
                    this.imageMapObject[src] = newAlt; // Actualizar el valor del mapa
                }
            }
        });

        // Convertir el DOM modificado de vuelta a una cadena HTML
        this.cuerpo = doc.body.innerHTML;

        this.mostrarModificarImagen = false;
        
        //Envío un evento al aura con el mapa de tags actualizado
        this.dispatchEvent(new CustomEvent('evtmodimagen', {
            detail: {
                //cuerpo: this.cuerpo,
                imgMap: this.imageAltMap
            }
        }));
    }
}