
using StringTools;

class MoreStringTools extends StringTools {
    inline public static function deleteLastCharacter(s:String):String {
        if(s.length-1 != 0)
            return s.substring(0, s.length-1);
        else if(s.length != 0)
            return s.substring(0, s.length);
        else
            return s;
    }

    inline public static function deleteStupidCharacters(s:String):String {
        return s.trim().replace("-", '').replace(',', '').replace('%', '').replace('"', '').replace("'", '');
    }
}