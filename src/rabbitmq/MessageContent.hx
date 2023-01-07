package rabbitmq;

import haxe.io.Bytes;

@:forward
abstract MessageContent(Bytes) from Bytes to Bytes {
    @:from public static function fromString(s:String):MessageContent {
        return Bytes.ofString(s);
    }
}
