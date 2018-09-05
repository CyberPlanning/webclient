module Color exposing
    ( Color
    , rgb, rgba, hsl, hsla, grayscale, greyscale, complement
    , toRgb, toHsl
    , black, blue, brown, charcoal, darkBlue, darkBrown, darkCharcoal, darkGray
    , darkGreen, darkGrey, darkOrange, darkPurple, darkRed, darkYellow, gray
    , green, grey, lightBlue, lightBrown, lightCharcoal, lightGray, lightGreen
    , lightGrey, lightOrange, lightPurple, lightRed, lightYellow, orange, purple
    , red, white, yellow
    )

{-| This module provides a simple way of describing colors as RGB with alpha transparency, based on this simple data structure:

    type alias Color =
        { red : Int, green : Int, blue : Int, alpha : Float }

The intention here is to provide a minimal and convenient representation of color for rendering purposes.


# The color representations:

@docs Color


# Constructors:

@docs rgb, rgba, hsl, hsla, grayscale, greyscale, complement


# Color space conversion/extraction:

@docs toRgb, toHsl


# Some basic colors to get you started:

@docs black, blue, brown, charcoal, darkBlue, darkBrown, darkCharcoal, darkGray
@docs darkGreen, darkGrey, darkOrange, darkPurple, darkRed, darkYellow, gray
@docs green, grey, lightBlue, lightBrown, lightCharcoal, lightGray, lightGreen
@docs lightGrey, lightOrange, lightPurple, lightRed, lightYellow, orange, purple
@docs red, white, yellow

-}

-- Public API


{-| A description of a color as computers see them.
-}
type alias Color =
    { red : Int, green : Int, blue : Int, alpha : Float }


{-| Builds an RGBA color from all of its components.
-}
rgba : Int -> Int -> Int -> Float -> Color
rgba =
    Color


{-| Builds an RGBA color from its RGB components at 100% opacity.
-}
rgb : Int -> Int -> Int -> Color
rgb r g b =
    { red = r, green = g, blue = b, alpha = 1 }


{-| Builds and RGBA color from its hue, saturation, lighness and alpha (HSLA) representation.
-}
hsla : Float -> Float -> Float -> Float -> Color
hsla hue saturation lightness alpha =
    let
        ( r, g, b ) =
            hslToRgb (hue - turns (toFloat (floor (hue / (2 * pi))))) saturation lightness
    in
    { red = round (255 * r), green = round (255 * g), blue = round (255 * b), alpha = alpha }


{-| Builds and RGBA color from its hue, saturation and lighness (HSL) representation at 100% opacity.
-}
hsl : Float -> Float -> Float -> Color
hsl hue saturation lightness =
    hsla hue saturation lightness 1


{-| Makes a grey level from 0 to 1.
-}
grayscale : Float -> Color
grayscale p =
    hsla 0 0 (1 - p) 1


{-| Makes a grey level from 0 to 1.
-}
greyscale : Float -> Color
greyscale p =
    hsla 0 0 (1 - p) 1


{-| Forms the complement of a color.
-}
complement : Color -> Color
complement color =
    let
        ( h, s, l ) =
            rgbToHsl color.red color.green color.blue
    in
    hsla (h + degrees 180) s l color.alpha


{-| Converts the RGBA color to its HSLA representation.
-}
toHsl : Color -> { hue : Float, saturation : Float, lightness : Float, alpha : Float }
toHsl color =
    let
        ( h, s, l ) =
            rgbToHsl color.red color.green color.blue
    in
    { hue = h, saturation = s, lightness = l, alpha = color.alpha }


{-| Converts the RGBA color to its RGBA representation - that is, does nothing.
-}
toRgb : Color -> { red : Int, green : Int, blue : Int, alpha : Float }
toRgb =
    identity



-- Helper functions for converting color spaces.


fmod : Float -> Int -> Float
fmod f n =
    let
        integer =
            floor f
    in
    toFloat (modBy n integer) + f - toFloat integer


rgbToHsl : Int -> Int -> Int -> ( Float, Float, Float )
rgbToHsl redI greenI blueI =
    let
        r =
            toFloat redI / 255

        g =
            toFloat greenI / 255

        b =
            toFloat blueI / 255

        cMax =
            max (max r g) b

        cMin =
            min (min r g) b

        c =
            cMax - cMin

        hue =
            degrees 60
                * (if cMax == r then
                    fmod ((g - b) / c) 6

                   else if cMax == g then
                    ((b - r) / c) + 2

                   else
                    {- cMax == b -}
                    ((r - g) / c) + 4
                  )

        lightness =
            (cMax + cMin) / 2

        saturation =
            if lightness == 0 then
                0

            else
                c / (1 - abs (2 * lightness - 1))
    in
    ( hue, saturation, lightness )


hslToRgb : Float -> Float -> Float -> ( Float, Float, Float )
hslToRgb hue saturation lightness =
    let
        chroma =
            (1 - abs (2 * lightness - 1)) * saturation

        normHue =
            hue / degrees 60

        x =
            chroma * (1 - abs (fmod normHue 2 - 1))

        ( r, g, b ) =
            if normHue < 0 then
                ( 0, 0, 0 )

            else if normHue < 1 then
                ( chroma, x, 0 )

            else if normHue < 2 then
                ( x, chroma, 0 )

            else if normHue < 3 then
                ( 0, chroma, x )

            else if normHue < 4 then
                ( 0, x, chroma )

            else if normHue < 5 then
                ( x, 0, chroma )

            else if normHue < 6 then
                ( chroma, 0, x )

            else
                ( 0, 0, 0 )

        m =
            lightness - chroma / 2
    in
    ( r + m, g + m, b + m )



-- Some ready made colors to get you going.


{-| -}
lightRed : Color
lightRed =
    rgba 239 41 41 1


{-| -}
red : Color
red =
    rgba 204 0 0 1


{-| -}
darkRed : Color
darkRed =
    rgba 164 0 0 1


{-| -}
lightOrange : Color
lightOrange =
    rgba 252 175 62 1


{-| -}
orange : Color
orange =
    rgba 245 121 0 1


{-| -}
darkOrange : Color
darkOrange =
    rgba 206 92 0 1


{-| -}
lightYellow : Color
lightYellow =
    rgba 255 233 79 1


{-| -}
yellow : Color
yellow =
    rgba 237 212 0 1


{-| -}
darkYellow : Color
darkYellow =
    rgba 196 160 0 1


{-| -}
lightGreen : Color
lightGreen =
    rgba 138 226 52 1


{-| -}
green : Color
green =
    rgba 115 210 22 1


{-| -}
darkGreen : Color
darkGreen =
    rgba 78 154 6 1


{-| -}
lightBlue : Color
lightBlue =
    rgba 114 159 207 1


{-| -}
blue : Color
blue =
    rgba 52 101 164 1


{-| -}
darkBlue : Color
darkBlue =
    rgba 32 74 135 1


{-| -}
lightPurple : Color
lightPurple =
    rgba 173 127 168 1


{-| -}
purple : Color
purple =
    rgba 117 80 123 1


{-| -}
darkPurple : Color
darkPurple =
    rgba 92 53 102 1


{-| -}
lightBrown : Color
lightBrown =
    rgba 233 185 110 1


{-| -}
brown : Color
brown =
    rgba 193 125 17 1


{-| -}
darkBrown : Color
darkBrown =
    rgba 143 89 2 1


{-| -}
black : Color
black =
    rgba 0 0 0 1


{-| -}
white : Color
white =
    rgba 255 255 255 1


{-| -}
lightGrey : Color
lightGrey =
    rgba 238 238 236 1


{-| -}
grey : Color
grey =
    rgba 211 215 207 1


{-| -}
darkGrey : Color
darkGrey =
    rgba 186 189 182 1


{-| -}
lightGray : Color
lightGray =
    rgba 238 238 236 1


{-| -}
gray : Color
gray =
    rgba 211 215 207 1


{-| -}
darkGray : Color
darkGray =
    rgba 186 189 182 1


{-| -}
lightCharcoal : Color
lightCharcoal =
    rgba 136 138 133 1


{-| -}
charcoal : Color
charcoal =
    rgba 85 87 83 1


{-| -}
darkCharcoal : Color
darkCharcoal =
    rgba 46 52 54 1
