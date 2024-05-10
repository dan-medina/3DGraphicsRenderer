'use strict'

/**
 * The Texture class is used to store texture information and load image data
 * 
 */
class Texture {

    /**
     * Create a new texture instance
     * 
     * @param {String} filename Path to the image texture to load
     * @param {WebGL2RenderingContext} gl The webgl2 rendering context
     * @param {Boolean} flip_y Determines if the texture should be flipped by WebGL (see Ch 7)
     */
    constructor(filename, gl, flip_y = true) {
        this.filename = filename 
        this.texture = null
        this.texture = this.createTexture( gl, flip_y )
    }

    /**
     * Get the GL handle to the texture
     * 
     * @returns {WebGLTexture} WebGL texture instance
     */
    getGlTexture() {
        return this.texture
    }

    /**
     * Loads image data from disk and creates a WebGL texture instance
     * 
     * @param {WebGL2RenderingContext} gl The webgl2 rendering context
     * @param {Boolean} flip_y Determines if the texture should be flipped by WebGL (see Ch 7)
     * @returns {WebGLTexture} WebGL texture instance
     */
    createTexture( gl, flip_y ) {

        gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, flip_y)
        let texture = gl.createTexture()
    
        // Set up texture config values
        const level = 0                  
        const internal_format = gl.RGBA        
        const src_format = gl.RGBA             
        const src_type = gl.UNSIGNED_BYTE               
    
        // Create a new image to load image data from disk
        const image = new Image();
        image.onload = () => {
            // Bind the texture and upload image data to the texture using the texture config values set above

            gl.bindTexture(gl.TEXTURE_2D, texture)
            gl.texImage2D(gl.TEXTURE_2D, level, internal_format, src_format, src_type, image)

            // Generate mipmap from the full-size texture
            gl.generateMipmap(gl.TEXTURE_2D)

            // Set up texture wrapping mode to repeat the texture
            gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
            gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)

            // Set up texture MIN/MAG filtering
            gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)
            gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR)

            // Use mipmapping and linear filtering   
            gl.bindTexture(gl.TEXTURE_2D, null)     
        }
        
        image.src = this.filename
    
        return texture
    }
}

export default Texture