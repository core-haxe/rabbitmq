package rabbitmq.externs.nodejs;

import js.lib.Error;

@:jsRequire("amqplib/callback_api", "Connection")
extern class Connection {
    public function createChannel(callback:Error->Channel->Void):Void;
    public function createConfirmChannel(callback:Error->ConfirmChannel->Void):Void;
    public function on(event:String, callback:Any->Void):Void;
    public function close():Void;
}