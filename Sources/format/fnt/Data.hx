package format.fnt;

// https://www.angelcode.com/products/bmfont/doc/file_format.html
typedef Data = {
    ?info:Info,
    ?common:Common,
    ?page:Page,
    ?chars:Array<Char>,
    ?kerning:Kerning
}

typedef Info = {
    ?face:String,        // This is the name of the true type font.
    ?size:Int,           // The size of the true type font.
    ?bold:Bool,          // The font is bold.
    ?italic:Bool,        // The font is italic.
    ?charset:String,     // The name of the OEM charset used (when not unicode).
    ?unicode:Int,        // Set to 1 if it is the unicode charset.
    ?stretchH:Int,       // The font height stretch in percentage. 100% means no stretch.
    ?smooth:Int,         // Set to 1 if smoothing was turned on.
    ?aa:Int,             // The supersampling level used. 1 means no supersampling was used.
    ?padding:Array<Int>, // The padding for each character (up, right, down, left).
    ?spacing:Array<Int>, // The spacing for each character (horizontal, vertical).
    ?outline:Int         // The outline thickness for the characters.
}

typedef Common = {
    ?lineHeight:Int,    // This is the distance in pixels between each line of text.
    ?base:Int,          // The number of pixels from the absolute top of the line to the base of the characters.
    ?scaleW:Int,        // The width of the texture, normally used to scale the x pos of the character image.
    ?scaleH:Int,        // The height of the texture, normally used to scale the y pos of the character image.
    ?pages:Int,         // The number of texture pages included in the font.
    ?packed:Int,        // Set to 1 if the monochrome characters have been packed into each of the texture channels. In this case alphaChnl describes what is stored in each channel.
    ?alphaChnl:Int,     // Set to 0 if the channel holds the glyph data, 1 if it holds the outline, 2 if it holds the glyph and the outline, 3 if its set to zero, and 4 if its set to one.
    ?redChnl:Int,       // Set to 0 if the channel holds the glyph data, 1 if it holds the outline, 2 if it holds the glyph and the outline, 3 if its set to zero, and 4 if its set to one.
    ?greenChnl:Int,     // Set to 0 if the channel holds the glyph data, 1 if it holds the outline, 2 if it holds the glyph and the outline, 3 if its set to zero, and 4 if its set to one.
    ?blueChnl:Int       // Set to 0 if the channel holds the glyph data, 1 if it holds the outline, 2 if it holds the glyph and the outline, 3 if its set to zero, and 4 if its set to one.
}

typedef Page = {
    ?id:Int,        // The page id.
    ?file:String    // The texture file name.
}

typedef Char = {
    ?id:Int,        // The character id.
    ?x:Int,         // The left position of the character image in the texture.
    ?y:Int,         // The top position of the character image in the texture.
    ?width:Int,     // The width of the character image in the texture.
    ?height:Int,    // The height of the character image in the texture.
    ?xoffset:Int,   // How much the current position should be offset when copying the image from the texture to the screen.
    ?yoffset:Int,   // How much the current position should be offset when copying the image from the texture to the screen.
    ?xadvance:Int,  // How much the current position should be advanced after drawing the character.
    ?page:Int,      // The texture page where the character image is found.
    ?chnl:Int       // The texture channel where the character image is found (1 = blue, 2 = green, 4 = red, 8 = alpha, 15 = all channels).
}

typedef Kerning = {
    ?first:Int,     // The first character id.
    ?second:Int,    // The second character id.
    ?amount:Int     // How much the x position should be adjusted when drawing the second character immediately following the first.
}