package rabbitmq.externs.nodejs;

import js.node.Buffer;
import haxe.io.Bytes;

@:forward
abstract BytesBuffer(Buffer) from Buffer to Buffer {
    @:from public static function fromBytes(bytes:Bytes):BytesBuffer {
        return Buffer.hxFromBytes(bytes);
    }

    @:from public static function fromString(s:String):BytesBuffer {
        return Buffer.from(s);
    }

    @:to public function toBytes():Bytes {
        return this.hxToBytes();
    }
}
